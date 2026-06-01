#ifndef RUNNER_FLUTTER_WINDOW_H_
#define RUNNER_FLUTTER_WINDOW_H_

#include <flutter/dart_project.h>
#include <flutter/encodable_value.h>
#include <flutter/flutter_view_controller.h>
#include <flutter/method_channel.h>
#include <windows.h>
#include <shellapi.h>

#include <memory>
#include <string>

#include "win32_window.h"

// A window that does nothing but host a Flutter view.
class FlutterWindow : public Win32Window {
 public:
  // Creates a new FlutterWindow hosting a Flutter view running |project|.
  explicit FlutterWindow(const flutter::DartProject& project);
  virtual ~FlutterWindow();

 protected:
  // Win32Window:
  bool OnCreate() override;
  void OnDestroy() override;
  LRESULT MessageHandler(HWND window, UINT const message, WPARAM const wparam,
                         LPARAM const lparam) noexcept override;

 private:
  void AddOrUpdateTrayIcon(const std::wstring& tooltip);
  void RemoveTrayIcon();
  void ShowFromTray();
  void ShowTrayMenu();
  static std::wstring Utf8ToWide(const std::string& value);

  static constexpr UINT kTrayMessage = WM_APP + 1;
  static constexpr UINT kTrayIconId = 1;
  static constexpr UINT kTrayMenuOpen = 1001;
  static constexpr UINT kTrayMenuExit = 1002;
  static constexpr UINT kTrayMenuConnectSelected = 1003;
  static constexpr UINT kTrayMenuDisconnect = 1004;

  // The project to run.
  flutter::DartProject project_;

  // The Flutter instance hosted by this window.
  std::unique_ptr<flutter::FlutterViewController> flutter_controller_;
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>
      tray_channel_;
  NOTIFYICONDATAW tray_icon_data_ = {};
  bool tray_icon_added_ = false;
};

#endif  // RUNNER_FLUTTER_WINDOW_H_
