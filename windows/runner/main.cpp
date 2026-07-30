#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include <algorithm>
#include <cctype>
#include <cstdlib>
#include <optional>
#include <string>
#include <vector>

#include "flutter_window.h"
#include "utils.h"

namespace {

constexpr const wchar_t kSingleInstanceMutexName[] =
    L"Local\\SiegeConnectSingleInstance";
constexpr const wchar_t kWindowClassName[] = L"FLUTTER_RUNNER_WIN32_WINDOW";
constexpr ULONG_PTR kDeepLinkCopyData = 0x5343444c;

std::string ToLowerAscii(std::string value) {
  std::transform(value.begin(), value.end(), value.begin(),
                 [](unsigned char character) {
                   return static_cast<char>(std::tolower(character));
                 });
  return value;
}

bool IsDeepLinkArgument(const std::string& argument) {
  const std::string lower = ToLowerAscii(argument);
  return lower.rfind("happ://", 0) == 0 ||
         lower.rfind("siegeconnect://", 0) == 0;
}

std::optional<std::string> FindDeepLinkArgument(
    const std::vector<std::string>& arguments) {
  for (const auto& argument : arguments) {
    if (IsDeepLinkArgument(argument)) {
      return argument;
    }
  }
  return std::nullopt;
}

std::wstring WideFromUtf8(const std::string& value) {
  if (value.empty()) {
    return {};
  }

  const int wide_size = MultiByteToWideChar(
      CP_UTF8, MB_ERR_INVALID_CHARS, value.data(),
      static_cast<int>(value.size()), nullptr, 0);
  if (wide_size <= 0) {
    return {};
  }

  std::wstring result(wide_size, L'\0');
  MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, value.data(),
                      static_cast<int>(value.size()), result.data(),
                      wide_size);
  return result;
}

bool ActivateExistingInstance(const std::optional<std::string>& deep_link) {
  HWND window = FindWindowW(kWindowClassName, L"SiegeConnect");
  if (!window) {
    return false;
  }

  ShowWindow(window, SW_SHOWNORMAL);
  SetForegroundWindow(window);

  if (deep_link) {
    const std::wstring payload = WideFromUtf8(*deep_link);
    if (!payload.empty()) {
      COPYDATASTRUCT copy_data = {};
      copy_data.dwData = kDeepLinkCopyData;
      copy_data.cbData =
          static_cast<DWORD>((payload.size() + 1) * sizeof(wchar_t));
      copy_data.lpData = const_cast<wchar_t*>(payload.c_str());
      SendMessageW(window, WM_COPYDATA, 0,
                   reinterpret_cast<LPARAM>(&copy_data));
    }
  }

  return true;
}

}  // namespace

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();
  std::optional<std::string> initial_deep_link =
      FindDeepLinkArgument(command_line_arguments);

  HANDLE single_instance_mutex =
      CreateMutexW(nullptr, TRUE, kSingleInstanceMutexName);
  const bool already_running =
      single_instance_mutex && GetLastError() == ERROR_ALREADY_EXISTS;
  if (already_running && ActivateExistingInstance(initial_deep_link)) {
    CloseHandle(single_instance_mutex);
    return EXIT_SUCCESS;
  }

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project, initial_deep_link);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(473, 640);
  if (!window.Create(L"SiegeConnect", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  if (single_instance_mutex) {
    CloseHandle(single_instance_mutex);
  }
  return EXIT_SUCCESS;
}
