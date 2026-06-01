import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../logs/application/log_repository.dart';
import '../../mihomo/application/mihomo_controller.dart';
import '../../subscription/data/subscription_repository.dart';
import '../../settings/application/settings_controller.dart';
import '../../settings/domain/app_settings.dart';
import '../../../shared/privacy.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  AppSettings? _draft;
  DateTime? _loadedAt;
  bool _dirty = false;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final logs = ref.watch(recentLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        actions: [
          TextButton.icon(
            onPressed: !_dirty || _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: const Text('Сохранить'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: settings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (value) {
          if (_draft == null || (!_dirty && _loadedAt != value.updatedAt)) {
            _draft = value.copy();
            _loadedAt = value.updatedAt;
          }
          final draft = _draft!;

          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 96),
            children: [
              _SettingsSection(
                title: 'Режим соединения',
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                    child: SegmentedButton<ConnectionMode>(
                      segments: const [
                        ButtonSegment(
                          value: ConnectionMode.proxy,
                          icon: Icon(Icons.public),
                          label: Text('Proxy'),
                        ),
                        ButtonSegment(
                          value: ConnectionMode.tun,
                          icon: Icon(Icons.shield),
                          label: Text('TUN'),
                        ),
                      ],
                      selected: {draft.connectionMode},
                      onSelectionChanged: (value) => _mutate(
                        (settings) => settings.connectionMode = value.first,
                      ),
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Kill Switch'),
                    subtitle: const Text('Строгий маршрут при обрыве TUN'),
                    value: draft.killSwitch,
                    onChanged: (enabled) =>
                        _mutate((settings) => settings.killSwitch = enabled),
                  ),
                  SwitchListTile(
                    title: const Text('Обход .ru доменов'),
                    subtitle: const Text(
                      'Когда включено, .ru и российские IP идут напрямую',
                    ),
                    value: draft.bypassRussia,
                    onChanged: (enabled) =>
                        _mutate((settings) => settings.bypassRussia = enabled),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _SettingsSection(
                title: 'Подписка',
                children: [
                  SwitchListTile(
                    title: const Text('Автообновление'),
                    subtitle: const Text('Обновлять конфиг при запуске'),
                    value: draft.autoUpdateSubscription,
                    onChanged: (enabled) => _mutate(
                      (settings) => settings.autoUpdateSubscription = enabled,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
                    child: TextFormField(
                      initialValue: draft.autoUpdateHours.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Интервал, часов',
                        prefixIcon: Icon(Icons.schedule),
                      ),
                      onChanged: (value) => _mutate(
                        (settings) => settings.autoUpdateHours =
                            int.tryParse(value) ?? settings.autoUpdateHours,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _SettingsSection(
                title: 'Запуск и сообщения',
                children: [
                  SwitchListTile(
                    title: const Text('Автозапуск Windows'),
                    subtitle: const Text(
                        'Запускать SiegeConnect после входа в систему'),
                    value: draft.launchAtStartup,
                    onChanged: (enabled) => _mutate(
                      (settings) => settings.launchAtStartup = enabled,
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Сообщения'),
                    subtitle:
                        const Text('Показывать подсказки, ошибки и статусы'),
                    value: draft.showConnectionMessages,
                    onChanged: (enabled) => _mutate(
                      (settings) => settings.showConnectionMessages = enabled,
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Объявление на главной'),
                    subtitle:
                        const Text('Показывать блок приветствия под квотой'),
                    value: draft.showAnnouncements,
                    onChanged: (enabled) => _mutate(
                      (settings) => settings.showAnnouncements = enabled,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _SettingsSection(
                title: 'Внешний вид',
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
                    child: DropdownButtonFormField<ThemePreference>(
                      initialValue: draft.theme,
                      decoration: const InputDecoration(
                        labelText: 'Тема',
                        prefixIcon: Icon(Icons.contrast),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: ThemePreference.system,
                          child: Text('Системная'),
                        ),
                        DropdownMenuItem(
                          value: ThemePreference.dark,
                          child: Text('Черная'),
                        ),
                        DropdownMenuItem(
                          value: ThemePreference.light,
                          child: Text('Белая'),
                        ),
                      ],
                      onChanged: (theme) {
                        if (theme != null) {
                          _mutate((settings) => settings.theme = theme);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _SettingsSection(
                title: 'Сплит-туннелинг',
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
                    child: DropdownButtonFormField<SplitTunnelMode>(
                      initialValue: draft.splitTunnelMode,
                      decoration: const InputDecoration(
                        labelText: 'Приложения',
                        prefixIcon: Icon(Icons.call_split),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: SplitTunnelMode.disabled,
                          child: Text('Выключен'),
                        ),
                        DropdownMenuItem(
                          value: SplitTunnelMode.onlySelectedApps,
                          child: Text('Только выбранные'),
                        ),
                        DropdownMenuItem(
                          value: SplitTunnelMode.excludeSelectedApps,
                          child: Text('Все, кроме выбранных'),
                        ),
                      ],
                      onChanged: (mode) {
                        if (mode != null) {
                          _mutate(
                            (settings) => settings.splitTunnelMode = mode,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Логи',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              logs.when(
                loading: () => const LinearProgressIndicator(),
                error: (error, _) => Text(error.toString()),
                data: (items) => SelectableText(
                  items.isEmpty
                      ? 'Пока пусто'
                      : items
                          .map(
                            (item) => '[${item.createdAt.toIso8601String()}] '
                                '${item.level}/${item.source}: '
                                '${redactNetworkText(item.message)}',
                          )
                          .join('\n'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(18),
        child: FilledButton.icon(
          onPressed: !_dirty || _saving ? null : _save,
          icon: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save),
          label: Text(_dirty ? 'Сохранить и переподключить' : 'Сохранено'),
        ),
      ),
    );
  }

  void _mutate(void Function(AppSettings settings) change) {
    final draft = _draft;
    if (draft == null) {
      return;
    }
    setState(() {
      change(draft);
      _dirty = true;
    });
  }

  Future<void> _save() async {
    final draft = _draft;
    if (draft == null || _saving) {
      return;
    }

    setState(() => _saving = true);
    final connection = ref.read(mihomoControllerProvider);
    final selectedNode = ref.read(selectedNodeProvider).valueOrNull;
    final reconnectNode = connection.isConnected ? selectedNode : null;

    try {
      if (connection.isConnected || connection.isBusy) {
        await ref.read(mihomoControllerProvider.notifier).disconnect();
      }

      final saved = await ref
          .read(settingsControllerProvider.notifier)
          .save((settings) => settings..applyFrom(draft));
      await ref
          .read(subscriptionRepositoryProvider)
          .rebuildMergedConfigs(saved);

      if (reconnectNode != null) {
        await ref
            .read(mihomoControllerProvider.notifier)
            .connect(reconnectNode);
      }

      if (!mounted) {
        return;
      }
      setState(() {
        _dirty = false;
        _loadedAt = saved.updatedAt;
        _draft = saved.copy();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Настройки сохранены')),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(redactNetworkText(error.toString()))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
