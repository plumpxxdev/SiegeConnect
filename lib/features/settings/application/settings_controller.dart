import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/isar_provider.dart';
import '../domain/app_settings.dart';

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, AppSettings>(
        SettingsController.new);

class SettingsController extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final isar = await ref.watch(isarProvider.future);
    final existing = await isar.appSettings.get(1);
    if (existing != null) {
      if (Platform.isAndroid && !existing.tunMode) {
        existing
          ..tunMode = true
          ..updatedAt = DateTime.now();
        await isar.writeTxn(() => isar.appSettings.put(existing));
      }
      return existing;
    }

    final defaults = AppSettings();
    if (Platform.isAndroid) {
      defaults.tunMode = true;
    }
    await isar.writeTxn(() => isar.appSettings.put(defaults));
    return defaults;
  }

  Future<AppSettings> save(
      AppSettings Function(AppSettings settings) mutate) async {
    final isar = await ref.read(isarProvider.future);
    final current = state.value ?? AppSettings();
    final next = mutate(current)..updatedAt = DateTime.now();
    if (Platform.isAndroid) {
      next.tunMode = true;
    }

    await isar.writeTxn(() => isar.appSettings.put(next));
    await _applyStartupSetting(next.launchAtStartup);
    state = AsyncData(next);
    return next;
  }

  Future<void> _applyStartupSetting(bool enabled) async {
    if (!Platform.isWindows) {
      return;
    }

    final exePath = Platform.resolvedExecutable;
    final script = enabled
        ? '''
\$path = 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Run'
Set-ItemProperty -Path \$path -Name SiegeConnect -Type String -Value ${_psQuote(exePath)}
'''
        : r'''
$path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
Remove-ItemProperty -Path $path -Name SiegeConnect -ErrorAction SilentlyContinue
''';

    final result = await Process.run(
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
    if (enabled && result.exitCode != 0) {
      final details = '${result.stdout}\n${result.stderr}'.trim();
      throw StateError('Не удалось включить автозапуск: $details');
    }
  }

  String _psQuote(String value) {
    return "'${value.replaceAll("'", "''")}'";
  }
}
