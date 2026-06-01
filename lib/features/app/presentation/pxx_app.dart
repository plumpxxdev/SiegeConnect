import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../home/presentation/home_screen.dart';
import '../../settings/application/settings_controller.dart';
import '../../settings/domain/app_settings.dart';

class PxxApp extends ConsumerWidget {
  const PxxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final themeMode = switch (settings.valueOrNull?.theme) {
      ThemePreference.light => ThemeMode.light,
      ThemePreference.dark => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      home: const _ThemeGate(child: HomeScreen()),
    );
  }

  ThemeData _buildDarkTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFE50914),
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFFFF2633),
      secondary: const Color(0xFFFF6B6B),
      surface: const Color(0xFF141416),
      surfaceContainerHighest: const Color(0xFF202024),
      outlineVariant: const Color(0xFF34343A),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF08080A),
      fontFamily: 'Segoe UI',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF141416),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1B1B20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFE50914),
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFFE50914),
      secondary: const Color(0xFF15151A),
      surface: Colors.white,
      surfaceContainerHighest: const Color(0xFFF3F3F5),
      outlineVariant: const Color(0xFFE2E2E8),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF7F7FA),
      fontFamily: 'Segoe UI',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF141416),
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF0F0F4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _ThemeGate extends ConsumerStatefulWidget {
  const _ThemeGate({required this.child});

  final Widget child;

  @override
  ConsumerState<_ThemeGate> createState() => _ThemeGateState();
}

class _ThemeGateState extends ConsumerState<_ThemeGate> {
  bool _dialogOpen = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider).valueOrNull;
    if (settings != null && !settings.themeChosen && !_dialogOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showThemeDialog();
        }
      });
    }

    return widget.child;
  }

  Future<void> _showThemeDialog() async {
    if (_dialogOpen) {
      return;
    }

    setState(() => _dialogOpen = true);
    final selected = await showDialog<ThemePreference>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Выбери тему'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ThemeChoiceTile(
              title: 'Черная',
              subtitle: 'Темный красно-черный стиль',
              icon: Icons.dark_mode,
              onTap: () => Navigator.of(context).pop(ThemePreference.dark),
            ),
            const SizedBox(height: 8),
            _ThemeChoiceTile(
              title: 'Белая',
              subtitle: 'Светлый интерфейс',
              icon: Icons.light_mode,
              onTap: () => Navigator.of(context).pop(ThemePreference.light),
            ),
            const SizedBox(height: 8),
            _ThemeChoiceTile(
              title: 'Как в системе',
              subtitle: 'Автоматически по Windows/Android',
              icon: Icons.brightness_auto,
              onTap: () => Navigator.of(context).pop(ThemePreference.system),
            ),
          ],
        ),
      ),
    );

    final theme = selected ?? ThemePreference.system;
    await ref.read(settingsControllerProvider.notifier).save(
          (settings) => settings
            ..theme = theme
            ..themeChosen = true,
        );

    if (mounted) {
      setState(() => _dialogOpen = false);
    }
  }
}

class _ThemeChoiceTile extends StatelessWidget {
  const _ThemeChoiceTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerHighest.withValues(alpha: 0.58),
      borderRadius: BorderRadius.circular(18),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        leading: Icon(icon, color: colors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }
}
