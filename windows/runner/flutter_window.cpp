#include "flutter_window.h"

#include <flutter/method_call.h>
#include <flutter/standard_method_codec.h>
#include <strsafe.h>
#include <windows.h>

#include <optional>
#include <variant>

#include "flutter/generated_plugin_registrant.h"
#include "resource.h"

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

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
  AppendMenuW(menu, MF_STRING, kTrayMenuExit,
              L"\x0412\x044b\x0445\x043e\x0434");

  SetForegroundWindow(GetHandle());
  const UINT command = TrackPopupMenu(
      menu, TPM_RETURNCMD | TPM_NONOTIFY | TPM_RIGHTBUTTON,
      cursor_position.x, cursor_position.y, 0, GetHandle(), nullptr);
  DestroyMenu(menu);

  if (command == kTrayMenuOpen) {
    ShowFromTray();
  } else if (command == kTrayMenuExit) {
    RemoveTrayIcon();
    DestroyWindow(GetHandle());
  }
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
