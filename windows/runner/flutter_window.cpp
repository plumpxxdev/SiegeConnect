#include "flutter_window.h"

#include <flutter/method_call.h>
#include <flutter/standard_method_codec.h>
#include <strsafe.h>
#include <windows.h>

#include <algorithm>
#include <cwctype>
#include <optional>
#include <utility>
#include <variant>

#include "flutter/generated_plugin_registrant.h"
#include "resource.h"
#include "utils.h"

FlutterWindow::FlutterWindow(
    const flutter::DartProject& project,
    std::optional<std::string> initial_deep_link)
    : project_(project), initial_deep_link_(std::move(initial_deep_link)) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());

  tray_channel_ =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          flutter_controller_->engine()->messenger(), "app.siegeconnect/tray",
          &flutter::StandardMethodCodec::GetInstance());
  tray_channel_->SetMethodCallHandler(
      [this](
          const flutter::MethodCall<flutter::EncodableValue>& call,
          std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>
              result) {
        if (call.method_name() == "setTooltip") {
          auto tooltip = std::wstring(L"SiegeConnect");
          const auto* arguments = call.arguments();
          if (arguments &&
              std::holds_alternative<std::string>(*arguments)) {
            tooltip = Utf8ToWide(std::get<std::string>(*arguments));
          }
          AddOrUpdateTrayIcon(tooltip);
          result->Success();
          return;
        }

        if (call.method_name() == "setStatus") {
          const auto* arguments = call.arguments();
          if (arguments && std::holds_alternative<flutter::EncodableMap>(
                               *arguments)) {
            const auto& map = std::get<flutter::EncodableMap>(*arguments);
            tray_connected_ = GetBoolValue(map, "connected", false);
            tray_busy_ = GetBoolValue(map, "busy", false);
            tray_has_selected_ = GetBoolValue(map, "hasSelected", false);
            AddOrUpdateTrayIcon(
                GetStringValue(map, "tooltip", L"SiegeConnect"));
          }
          result->Success();
          return;
        }

        if (call.method_name() == "showWindow") {
          ShowFromTray();
          result->Success();
          return;
        }

        if (call.method_name() == "exit") {
          RemoveTrayIcon();
          if (GetHandle()) {
            DestroyWindow(GetHandle());
          }
          result->Success();
          return;
        }

        result->NotImplemented();
      });
  deep_link_channel_ =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          flutter_controller_->engine()->messenger(),
          "app.siegeconnect/deeplink",
          &flutter::StandardMethodCodec::GetInstance());
  deep_link_channel_->SetMethodCallHandler(
      [this](
          const flutter::MethodCall<flutter::EncodableValue>& call,
          std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>
              result) {
        if (call.method_name() == "getInitialLink") {
          if (initial_deep_link_) {
            result->Success(flutter::EncodableValue(*initial_deep_link_));
            initial_deep_link_.reset();
          } else if (auto pending_deep_link = ConsumePendingDeepLink()) {
            result->Success(
                flutter::EncodableValue(WideToUtf8(*pending_deep_link)));
          } else {
            result->Success();
          }
          return;
        }

        if (call.method_name() == "consumePendingLink") {
          if (auto pending_deep_link = ConsumePendingDeepLink()) {
            result->Success(
                flutter::EncodableValue(WideToUtf8(*pending_deep_link)));
          } else {
            result->Success();
          }
          return;
        }

        if (call.method_name() == "clearPendingLink") {
          ClearPendingDeepLink();
          result->Success();
          return;
        }

        result->NotImplemented();
      });
  RegisterUrlSchemes();
  AddOrUpdateTrayIcon(L"SiegeConnect");

  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  RemoveTrayIcon();

  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  if (message == WM_COPYDATA) {
    const auto* copy_data =
        reinterpret_cast<const COPYDATASTRUCT*>(lparam);
    if (copy_data && copy_data->dwData == kDeepLinkCopyData &&
        copy_data->lpData && copy_data->cbData >= sizeof(wchar_t)) {
      size_t character_count = copy_data->cbData / sizeof(wchar_t);
      const auto* raw = static_cast<const wchar_t*>(copy_data->lpData);
      if (character_count > 0 && raw[character_count - 1] == L'\0') {
        character_count--;
      }
      NotifyDeepLink(WideToUtf8(std::wstring(raw, character_count)));
      return TRUE;
    }
  }

  if (message == WM_CLOSE) {
    ShowWindow(hwnd, SW_HIDE);
    return 0;
  }

  if (message == kTrayMessage) {
    switch (LOWORD(lparam)) {
      case WM_LBUTTONUP:
      case WM_LBUTTONDBLCLK:
        ShowFromTray();
        return 0;
      case WM_RBUTTONUP:
        ShowTrayMenu();
        return 0;
    }
  }

  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}

void FlutterWindow::AddOrUpdateTrayIcon(const std::wstring& tooltip) {
  if (!GetHandle()) {
    return;
  }

  tray_icon_data_ = {};
  tray_icon_data_.cbSize = sizeof(NOTIFYICONDATAW);
  tray_icon_data_.hWnd = GetHandle();
  tray_icon_data_.uID = kTrayIconId;
  tray_icon_data_.uFlags = NIF_MESSAGE | NIF_ICON | NIF_TIP;
  tray_icon_data_.uCallbackMessage = kTrayMessage;
  tray_icon_data_.hIcon =
      LoadIcon(GetModuleHandle(nullptr), MAKEINTRESOURCE(IDI_APP_ICON));
  StringCchCopyW(tray_icon_data_.szTip, ARRAYSIZE(tray_icon_data_.szTip),
                 tooltip.c_str());

  Shell_NotifyIconW(tray_icon_added_ ? NIM_MODIFY : NIM_ADD,
                    &tray_icon_data_);
  tray_icon_added_ = true;
}

void FlutterWindow::RemoveTrayIcon() {
  if (!tray_icon_added_) {
    return;
  }

  Shell_NotifyIconW(NIM_DELETE, &tray_icon_data_);
  tray_icon_added_ = false;
}

void FlutterWindow::ShowFromTray() {
  if (!GetHandle()) {
    return;
  }

  ShowWindow(GetHandle(), IsIconic(GetHandle()) ? SW_RESTORE : SW_SHOW);
  SetForegroundWindow(GetHandle());
}

void FlutterWindow::ShowTrayMenu() {
  if (!GetHandle()) {
    return;
  }

  POINT cursor_position;
  GetCursorPos(&cursor_position);

  HMENU menu = CreatePopupMenu();
  AppendMenuW(menu, MF_STRING, kTrayMenuOpen,
              L"\x041e\x0442\x043a\x0440\x044b\x0442\x044c");
  AppendMenuW(menu, MF_SEPARATOR, 0, nullptr);
  const UINT connect_flags =
      MF_STRING |
      ((!tray_connected_ && !tray_busy_ && tray_has_selected_) ? 0
                                                               : MF_GRAYED);
  const UINT disconnect_flags =
      MF_STRING | ((tray_connected_ || tray_busy_) ? 0 : MF_GRAYED);
  AppendMenuW(menu, connect_flags, kTrayMenuConnectSelected,
              L"\x041f\x043e\x0434\x043a\x043b\x044e\x0447\x0438\x0442\x044c \x043a \x0432\x044b\x0431\x0440\x0430\x043d\x043d\x043e\x043c\x0443");
  AppendMenuW(menu, disconnect_flags, kTrayMenuDisconnect,
              L"\x041e\x0442\x043a\x043b\x044e\x0447\x0438\x0442\x044c VPN");
  AppendMenuW(menu, MF_SEPARATOR, 0, nullptr);
  AppendMenuW(menu, MF_STRING, kTrayMenuExit,
              L"\x0412\x044b\x0445\x043e\x0434");

  SetForegroundWindow(GetHandle());
  const UINT command = TrackPopupMenu(
      menu, TPM_RETURNCMD | TPM_NONOTIFY | TPM_RIGHTBUTTON,
      cursor_position.x, cursor_position.y, 0, GetHandle(), nullptr);
  DestroyMenu(menu);

  if (command == kTrayMenuOpen) {
    ShowFromTray();
  } else if (command == kTrayMenuConnectSelected) {
    if (tray_channel_) {
      tray_channel_->InvokeMethod(
          "connectSelected",
          std::make_unique<flutter::EncodableValue>());
    }
  } else if (command == kTrayMenuDisconnect) {
    if (tray_channel_) {
      tray_channel_->InvokeMethod(
          "disconnect",
          std::make_unique<flutter::EncodableValue>());
    }
  } else if (command == kTrayMenuExit) {
    RequestExitFromTray();
  }
}

void FlutterWindow::RequestExitFromTray() {
  if (tray_channel_) {
    tray_channel_->InvokeMethod("exitRequested",
                                std::make_unique<flutter::EncodableValue>());
    return;
  }

  RemoveTrayIcon();
  DestroyWindow(GetHandle());
}

void FlutterWindow::NotifyDeepLink(const std::string& url) {
  if (url.empty()) {
    return;
  }

  ShowFromTray();
  if (deep_link_channel_) {
    deep_link_channel_->InvokeMethod(
        "onLink", std::make_unique<flutter::EncodableValue>(url));
    return;
  }

  initial_deep_link_ = url;
}

void FlutterWindow::RegisterUrlSchemes() {
  wchar_t executable_path[MAX_PATH] = {};
  if (GetModuleFileNameW(nullptr, executable_path, MAX_PATH) == 0) {
    return;
  }

  RemoveUrlSchemeIfOwned(L"happ");

  const std::wstring command =
      L"\"" + std::wstring(executable_path) + L"\" \"%1\"";
  for (const wchar_t* scheme : {L"siegeconnect"}) {
    const std::wstring scheme_key =
        L"Software\\Classes\\" + std::wstring(scheme);
    HKEY key = nullptr;
    if (RegCreateKeyExW(HKEY_CURRENT_USER, scheme_key.c_str(), 0, nullptr, 0,
                        KEY_WRITE, nullptr, &key, nullptr) != ERROR_SUCCESS) {
      continue;
    }

    const std::wstring label = L"URL:SiegeConnect Subscription Link";
    RegSetValueExW(key, nullptr, 0, REG_SZ,
                   reinterpret_cast<const BYTE*>(label.c_str()),
                   static_cast<DWORD>((label.size() + 1) * sizeof(wchar_t)));
    const wchar_t empty[] = L"";
    RegSetValueExW(key, L"URL Protocol", 0, REG_SZ,
                   reinterpret_cast<const BYTE*>(empty), sizeof(empty));
    RegCloseKey(key);

    const std::wstring command_key = scheme_key + L"\\shell\\open\\command";
    if (RegCreateKeyExW(HKEY_CURRENT_USER, command_key.c_str(), 0, nullptr, 0,
                        KEY_WRITE, nullptr, &key, nullptr) != ERROR_SUCCESS) {
      continue;
    }
    RegSetValueExW(key, nullptr, 0, REG_SZ,
                   reinterpret_cast<const BYTE*>(command.c_str()),
                   static_cast<DWORD>((command.size() + 1) * sizeof(wchar_t)));
    RegCloseKey(key);
  }
}

void FlutterWindow::RemoveUrlSchemeIfOwned(const std::wstring& scheme) {
  const std::wstring command_key =
      L"Software\\Classes\\" + scheme + L"\\shell\\open\\command";
  HKEY key = nullptr;
  if (RegOpenKeyExW(HKEY_CURRENT_USER, command_key.c_str(), 0, KEY_READ,
                    &key) != ERROR_SUCCESS) {
    return;
  }

  wchar_t command[2048] = {};
  DWORD command_size = sizeof(command);
  const LSTATUS read_status =
      RegQueryValueExW(key, nullptr, nullptr, nullptr,
                       reinterpret_cast<LPBYTE>(command), &command_size);
  RegCloseKey(key);
  if (read_status != ERROR_SUCCESS) {
    return;
  }

  std::wstring lower_command(command);
  std::transform(lower_command.begin(), lower_command.end(),
                 lower_command.begin(),
                 [](wchar_t value) { return std::towlower(value); });
  if (lower_command.find(L"siegeconnect") == std::wstring::npos) {
    return;
  }

  const std::wstring scheme_key = L"Software\\Classes\\" + scheme;
  RegDeleteTreeW(HKEY_CURRENT_USER, scheme_key.c_str());
}

std::wstring FlutterWindow::Utf8ToWide(const std::string& value) {
  if (value.empty()) {
    return {};
  }

  const int wide_size = MultiByteToWideChar(
      CP_UTF8, MB_ERR_INVALID_CHARS, value.data(),
      static_cast<int>(value.size()), nullptr, 0);
  if (wide_size <= 0) {
    return std::wstring(value.begin(), value.end());
  }

  std::wstring result(wide_size, L'\0');
  MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, value.data(),
                      static_cast<int>(value.size()), result.data(),
                      wide_size);
  return result;
}

std::string FlutterWindow::WideToUtf8(const std::wstring& value) {
  if (value.empty()) {
    return {};
  }

  const int utf8_size = WideCharToMultiByte(
      CP_UTF8, WC_ERR_INVALID_CHARS, value.data(),
      static_cast<int>(value.size()), nullptr, 0, nullptr, nullptr);
  if (utf8_size <= 0) {
    return {};
  }

  std::string result(utf8_size, '\0');
  WideCharToMultiByte(CP_UTF8, WC_ERR_INVALID_CHARS, value.data(),
                      static_cast<int>(value.size()), result.data(),
                      utf8_size, nullptr, nullptr);
  return result;
}

bool FlutterWindow::GetBoolValue(const flutter::EncodableMap& map,
                                 const char* key,
                                 bool fallback) {
  const auto it = map.find(flutter::EncodableValue(std::string(key)));
  if (it == map.end() || !std::holds_alternative<bool>(it->second)) {
    return fallback;
  }
  return std::get<bool>(it->second);
}

std::wstring FlutterWindow::GetStringValue(const flutter::EncodableMap& map,
                                           const char* key,
                                           const std::wstring& fallback) {
  const auto it = map.find(flutter::EncodableValue(std::string(key)));
  if (it == map.end() || !std::holds_alternative<std::string>(it->second)) {
    return fallback;
  }
  return Utf8ToWide(std::get<std::string>(it->second));
}
