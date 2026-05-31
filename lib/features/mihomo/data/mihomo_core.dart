import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../settings/domain/app_settings.dart';

class MihomoCore {
  MihomoCore({
    MethodChannel? mihomoChannel,
    MethodChannel? vpnChannel,
  })  : _mihomoChannel =
            mihomoChannel ?? const MethodChannel(AppConstants.mihomoChannel),
        _vpnChannel =
            vpnChannel ?? const MethodChannel(AppConstants.vpnChannel);

  final MethodChannel _mihomoChannel;
  final MethodChannel _vpnChannel;
  Process? _desktopProcess;
  int? _desktopPid;
  bool _startedViaWindowsTask = false;
  bool _systemProxyEnabled = false;
  _WindowsProxySnapshot? _previousProxy;

  Future<void> start({
    required String configPath,
    required AppSettings settings,
  }) async {
    final args = <String, Object?>{
      'configPath': configPath,
      'killSwitch': settings.killSwitch,
      'tunMode': settings.tunMode,
      'splitTunnelMode': settings.splitTunnelMode.name,
      'splitTunnelPackages': settings.splitTunnelPackages,
    };

    try {
      await _vpnChannel.invokeMethod<void>('start', args);
      return;
    } on MissingPluginException {
      await _startDesktop(configPath, settings);
    }
  }

  Future<void> stop() async {
    try {
      await _vpnChannel.invokeMethod<void>('stop');
    } on MissingPluginException {
      await _stopDesktop();
    }
  }

  Future<void> restart({
    required String configPath,
    required AppSettings settings,
  }) async {
    await stop();
    await start(configPath: configPath, settings: settings);
  }

  Future<int> delay({
    required String proxyName,
    required String server,
    required int port,
    String testUrl = 'https://www.gstatic.com/generate_204',
  }) async {
    try {
      final result = await _mihomoChannel.invokeMethod<int>('delay', {
        'proxyName': proxyName,
        'testUrl': testUrl,
        'timeoutMs': 5000,
      });
      if (result != null && result >= 0) {
        return result;
      }
    } on MissingPluginException {
      return _tcpDelay(server, port);
    }

    return _tcpDelay(server, port);
  }

  Future<bool> isAdministrator() async {
    if (!Platform.isWindows) {
      return true;
    }
    try {
      final result = await _vpnChannel.invokeMethod<bool>('isAdministrator');
      return result ?? false;
    } on MissingPluginException {
      final probe = await _runPowerShell(
        r'([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)',
      );
      return probe.stdout.toString().trim().toLowerCase() == 'true';
    }
  }

  Future<bool> trySelectProxy({
    required String groupName,
    required String proxyName,
  }) async {
    final encodedGroup = Uri.encodeComponent(groupName);
    final uri = Uri.parse(
      'http://${AppConstants.controllerAddress}/proxies/$encodedGroup',
    );

    for (var attempt = 0; attempt < 40; attempt++) {
      final client = HttpClient();
      try {
        final request =
            await client.putUrl(uri).timeout(const Duration(milliseconds: 900));
        request.headers.contentType = ContentType.json;
        request.write(jsonEncode({'name': proxyName}));
        final response =
            await request.close().timeout(const Duration(milliseconds: 900));
        await response.drain<void>();
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return true;
        }
      } catch (_) {
        // Mihomo may need a moment before the external controller is ready.
      } finally {
        client.close(force: true);
      }

      await Future<void>.delayed(const Duration(milliseconds: 500));
    }

    return false;
  }

  Future<void> _startDesktop(
    String configPath,
    AppSettings settings,
  ) async {
    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
      throw UnsupportedError('На этой платформе нужен нативный VPN-плагин');
    }

    await _stopDesktop();

    if (Platform.isWindows && settings.tunMode && !await isAdministrator()) {
      await _startWindowsTunTask(configPath);
      return;
    }

    final executable = await _findMihomoExecutable();
    if (Platform.isWindows) {
      _desktopPid = await _startWindowsHiddenProcess(
        executable.path,
        ['-f', configPath],
        executable.parent.path,
      );
    } else {
      _desktopProcess = await Process.start(
        executable.path,
        ['-f', configPath],
        mode: ProcessStartMode.normal,
        workingDirectory: executable.parent.path,
      );
    }

    if (Platform.isWindows && !settings.tunMode) {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      await _enableWindowsSystemProxy();
    }
  }

  Future<void> _stopDesktop() async {
    if (_startedViaWindowsTask) {
      final runtimeDir = await _windowsRuntimeDirectory();
      final runtimeConfig = p.join(runtimeDir.path, 'current.yaml');
      await _runWindowsCommand(
        'schtasks.exe',
        ['/End', '/TN', AppConstants.windowsTunTaskName],
      );
      await _stopWindowsRuntimeMihomo(runtimeConfig);
      _startedViaWindowsTask = false;
    }

    if (_desktopPid != null && Platform.isWindows) {
      await _runWindowsCommand(
        'taskkill.exe',
        ['/F', '/PID', _desktopPid.toString()],
      );
      _desktopPid = null;
    }

    _desktopProcess?.kill();
    _desktopProcess = null;

    if (_systemProxyEnabled) {
      await _restoreWindowsSystemProxy();
    }
  }

  Future<File> _findMihomoExecutable() async {
    final cwd = Directory.current;
    final executableDir = File(Platform.resolvedExecutable).parent;
    final supportDir = await getApplicationSupportDirectory();
    final names = Platform.isWindows
        ? ['mihomo.exe', 'mihomo-windows-amd64.exe']
        : ['mihomo'];
    final candidates = <File>[
      for (final name in names) File(p.join(executableDir.path, name)),
      for (final name in names) File(p.join(executableDir.path, 'bin', name)),
      for (final name in names) File(p.join(cwd.path, 'bin', name)),
      for (final name in names) File(p.join(supportDir.path, 'bin', name)),
    ];

    for (final file in candidates) {
      if (await file.exists()) {
        return file;
      }
    }

    throw StateError(
      'Ядро Mihomo не найдено. Запусти SiegeConnect-Setup.exe или положи '
      'mihomo.exe рядом с siegeconnect.exe.',
    );
  }

  Future<int> _tcpDelay(String server, int port) async {
    if (server.trim().isEmpty || port <= 0) {
      return -1;
    }

    final stopwatch = Stopwatch()..start();
    Socket? socket;
    try {
      socket = await Socket.connect(
        server,
        port,
        timeout: const Duration(seconds: 4),
      );
      stopwatch.stop();
      return stopwatch.elapsedMilliseconds.clamp(1, 9999).toInt();
    } catch (_) {
      return -1;
    } finally {
      socket?.destroy();
    }
  }

  Future<void> _startWindowsTunTask(String configPath) async {
    final runtimeDir = await _windowsRuntimeDirectory();
    await runtimeDir.create(recursive: true);
    final runtimeConfig = p.join(runtimeDir.path, 'current.yaml');
    await _stopWindowsRuntimeMihomo(runtimeConfig);
    await _runWindowsCommand(
      'schtasks.exe',
      ['/End', '/TN', AppConstants.windowsTunTaskName],
    );
    await File(configPath).copy(runtimeConfig);

    final query = await _runWindowsCommand(
      'schtasks.exe',
      ['/Query', '/TN', AppConstants.windowsTunTaskName],
    );
    if (query.exitCode != 0) {
      throw StateError(
        'Для TUN без запуска от администратора нужен установленный фоновой '
        'компонент. Запусти SiegeConnect-Setup.exe один раз, после этого '
        'обычный siegeconnect.exe будет включать TUN без UAC.',
      );
    }

    final run = await _runWindowsCommand(
      'schtasks.exe',
      ['/Run', '/TN', AppConstants.windowsTunTaskName],
    );
    if (run.exitCode != 0) {
      final details = '${run.stdout}\n${run.stderr}'.trim();
      throw StateError('Не удалось запустить фоновый TUN-компонент: $details');
    }

    _startedViaWindowsTask = true;
  }

  Future<void> _stopWindowsRuntimeMihomo(String runtimeConfig) async {
    if (!Platform.isWindows) {
      return;
    }

    final script = '''
\$needle = ${_psQuote(runtimeConfig)}
\$pattern = '*' + [WildcardPattern]::Escape(\$needle) + '*'
Get-CimInstance Win32_Process -Filter "name = 'mihomo.exe'" |
  Where-Object { \$_.CommandLine -like \$pattern } |
  ForEach-Object { Stop-Process -Id \$_.ProcessId -Force -ErrorAction SilentlyContinue }
''';
    await _runPowerShell(script);
  }

  Future<int> _startWindowsHiddenProcess(
    String executablePath,
    List<String> arguments,
    String workingDirectory,
  ) async {
    final quotedArgs = arguments.map(_psQuote).join(',');
    final script = '''
\$process = Start-Process -FilePath ${_psQuote(executablePath)} -ArgumentList @($quotedArgs) -WorkingDirectory ${_psQuote(workingDirectory)} -WindowStyle Hidden -PassThru
\$process.Id
''';
    final result = await _runPowerShell(script);
    if (result.exitCode != 0) {
      final details = '${result.stdout}\n${result.stderr}'.trim();
      throw StateError('Не удалось запустить Mihomo скрыто: $details');
    }
    return int.parse(result.stdout.toString().trim().split('\n').last.trim());
  }

  Future<Directory> _windowsRuntimeDirectory() async {
    final localAppData = Platform.environment['LOCALAPPDATA'];
    if (localAppData != null && localAppData.isNotEmpty) {
      return Directory(p.join(localAppData, 'SiegeConnect', 'runtime'));
    }

    final supportDir = await getApplicationSupportDirectory();
    return Directory(p.join(supportDir.path, 'runtime'));
  }

  Future<void> _enableWindowsSystemProxy() async {
    _previousProxy ??= await _readWindowsProxy();
    await _writeWindowsProxy(
      enabled: true,
      server: '127.0.0.1:${AppConstants.mixedProxyPort}',
      bypass:
          '<local>;localhost;127.*;10.*;172.16.*;172.17.*;172.18.*;172.19.*;'
          '172.20.*;172.21.*;172.22.*;172.23.*;172.24.*;172.25.*;172.26.*;'
          '172.27.*;172.28.*;172.29.*;172.30.*;172.31.*;192.168.*',
    );
    _systemProxyEnabled = true;
  }

  Future<void> _restoreWindowsSystemProxy() async {
    final snapshot = _previousProxy;
    if (snapshot == null) {
      await _writeWindowsProxy(enabled: false, server: '', bypass: '');
    } else {
      await _writeWindowsProxy(
        enabled: snapshot.enabled,
        server: snapshot.server,
        bypass: snapshot.bypass,
      );
    }
    _previousProxy = null;
    _systemProxyEnabled = false;
  }

  Future<_WindowsProxySnapshot> _readWindowsProxy() async {
    final result = await _runPowerShell(r'''
$path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'
$p = Get-ItemProperty -Path $path
[pscustomobject]@{
  ProxyEnable = if ($null -eq $p.ProxyEnable) { 0 } else { [int]$p.ProxyEnable }
  ProxyServer = if ($null -eq $p.ProxyServer) { '' } else { [string]$p.ProxyServer }
  ProxyOverride = if ($null -eq $p.ProxyOverride) { '' } else { [string]$p.ProxyOverride }
} | ConvertTo-Json -Compress
''');
    if (result.exitCode != 0) {
      return const _WindowsProxySnapshot(
        enabled: false,
        server: '',
        bypass: '',
      );
    }

    final data = jsonDecode(result.stdout.toString()) as Map<String, dynamic>;
    return _WindowsProxySnapshot(
      enabled: (data['ProxyEnable'] as num? ?? 0) != 0,
      server: data['ProxyServer']?.toString() ?? '',
      bypass: data['ProxyOverride']?.toString() ?? '',
    );
  }

  Future<void> _writeWindowsProxy({
    required bool enabled,
    required String server,
    required String bypass,
  }) async {
    final script = '''
\$path = 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings'
Set-ItemProperty -Path \$path -Name ProxyEnable -Type DWord -Value ${enabled ? 1 : 0}
Set-ItemProperty -Path \$path -Name ProxyServer -Type String -Value ${_psQuote(server)}
Set-ItemProperty -Path \$path -Name ProxyOverride -Type String -Value ${_psQuote(bypass)}
Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class WinInetRefresh {
  [DllImport("wininet.dll", SetLastError = true)]
  public static extern bool InternetSetOption(IntPtr hInternet, int option, IntPtr buffer, int length);
}
"@
[WinInetRefresh]::InternetSetOption([IntPtr]::Zero, 39, [IntPtr]::Zero, 0) | Out-Null
[WinInetRefresh]::InternetSetOption([IntPtr]::Zero, 37, [IntPtr]::Zero, 0) | Out-Null
''';
    final result = await _runPowerShell(script);
    if (result.exitCode != 0) {
      final details = '${result.stdout}\n${result.stderr}'.trim();
      throw StateError(
          'Не удалось обновить системный прокси Windows: $details');
    }
  }

  Future<ProcessResult> _runPowerShell(String script) {
    return Process.run(
      'powershell.exe',
      [
        '-NoProfile',
        '-WindowStyle',
        'Hidden',
        '-ExecutionPolicy',
        'Bypass',
        '-Command',
        script,
      ],
    );
  }

  Future<ProcessResult> _runWindowsCommand(
    String executable,
    List<String> arguments,
  ) {
    final command = '& ${_psQuote(executable)} '
        '${arguments.map(_psQuote).join(' ')}';
    return _runPowerShell(command);
  }

  String _psQuote(String value) {
    return "'${value.replaceAll("'", "''")}'";
  }
}

class _WindowsProxySnapshot {
  const _WindowsProxySnapshot({
    required this.enabled,
    required this.server,
    required this.bypass,
  });

  final bool enabled;
  final String server;
  final String bypass;
}
