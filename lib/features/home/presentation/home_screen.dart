import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/countries.dart';
import '../../../shared/privacy.dart';
import '../../../shared/user_facing_error.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../deeplink/application/deep_link_parser.dart';
import '../../mihomo/application/mihomo_controller.dart';
import '../../mihomo/domain/connection_state.dart';
import '../../settings/application/settings_controller.dart';
import '../../settings/domain/app_settings.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../subscription/data/subscription_repository.dart';
import '../../subscription/domain/subscription_profile.dart';
import '../../subscription/domain/vpn_node.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const _trayChannel = MethodChannel(AppConstants.trayChannel);
  static const _deepLinkChannel = MethodChannel(AppConstants.deepLinkChannel);

  bool _sortByPing = true;
  bool _pingingAll = false;
  bool _changingMode = false;
  final Set<int> _pingingNodes = {};
  final Set<int> _collapsedProfileIds = {};
  final Set<int> _refreshingProfileIds = {};
  final Map<int, DateTime> _lastProfileRefreshAt = {};
  DateTime? _lastRefreshAllAt;
  bool _refreshingAll = false;
  String? _lastTrayTooltip;
  bool _exitingFromTray = false;
  String? _lastDeepLink;
  DateTime? _lastDeepLinkAt;

  @override
  void initState() {
    super.initState();
    _trayChannel.setMethodCallHandler(_handleTrayCommand);
    _deepLinkChannel.setMethodCallHandler(_handleDeepLinkCommand);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _consumeInitialDeepLink();
      }
    });
  }

  @override
  void dispose() {
    _trayChannel.setMethodCallHandler(null);
    _deepLinkChannel.setMethodCallHandler(null);
    super.dispose();
  }

  Future<void> _handleTrayCommand(MethodCall call) async {
    switch (call.method) {
      case 'connectSelected':
        final connection = ref.read(mihomoControllerProvider);
        if (connection.isBusy || connection.isConnected) {
          return;
        }
        final node = await ref.read(selectedNodeProvider.future);
        if (!mounted) {
          return;
        }
        await _connect(context, node);
        return;
      case 'disconnect':
        final connection = ref.read(mihomoControllerProvider);
        if (!connection.isConnected && !connection.isBusy) {
          return;
        }
        await ref.read(mihomoControllerProvider.notifier).disconnect();
        return;
      case 'exitRequested':
        await _exitFromTray();
        return;
    }
  }

  Future<void> _handleDeepLinkCommand(MethodCall call) async {
    if (call.method != 'onLink') {
      return;
    }

    final arguments = call.arguments;
    final rawLink = switch (arguments) {
      final String value => value,
      final Map<Object?, Object?> map => map['url']?.toString(),
      _ => null,
    };
    if (rawLink == null || rawLink.trim().isEmpty) {
      return;
    }

    await _importFromDeepLink(rawLink);
  }

  Future<void> _consumeInitialDeepLink() async {
    try {
      final rawLink =
          await _deepLinkChannel.invokeMethod<String>('getInitialLink');
      if (rawLink == null || rawLink.trim().isEmpty || !mounted) {
        return;
      }
      await _importFromDeepLink(rawLink);
    } on MissingPluginException {
      // Native deep links are available only on Android and Windows builds.
    }
  }

  @override
  Widget build(BuildContext context) {
    final profiles = ref.watch(profilesProvider);
    final nodes = ref.watch(nodesProvider);
    final selectedNode = ref.watch(selectedNodeProvider).valueOrNull;
    final connection = ref.watch(mihomoControllerProvider);
    final settings = ref.watch(settingsControllerProvider).valueOrNull;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateTrayTooltip(connection, selectedNode);
      }
    });

    return Scaffold(
      body: DecoratedBox(
        decoration: _AppBackdrop.decoration(context),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: AsyncValueView(
              value: profiles,
              data: (profileList) => AsyncValueView(
                value: nodes,
                data: (nodeList) {
                  return _Dashboard(
                    profiles: profileList,
                    nodes: _orderedNodes(nodeList),
                    selectedNode: selectedNode,
                    connection: connection,
                    settings: settings ?? AppSettings(),
                    sortByPing: _sortByPing,
                    pingingAll: _pingingAll,
                    changingMode: _changingMode,
                    refreshingAll: _refreshingAll,
                    collapsedProfileIds: _collapsedProfileIds,
                    refreshingProfileIds: _refreshingProfileIds,
                    pingingNodes: _pingingNodes,
                    onSortChanged: (value) =>
                        setState(() => _sortByPing = value),
                    onImport: () => _showImportDialog(context),
                    onRefresh: _refreshAllSubscriptions,
                    onSettings: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                    onConnect: (node) => _connect(context, node),
                    onDisconnect: () => ref
                        .read(mihomoControllerProvider.notifier)
                        .disconnect(),
                    onSelectNode: (node) => ref
                        .read(subscriptionRepositoryProvider)
                        .selectNode(node.id),
                    onToggleProfile: _toggleProfile,
                    onRefreshProfile: _refreshProfile,
                    onConfigureProfile: _showProfileActions,
                    onPingAll: () => _pingAll(_orderedNodes(nodeList)),
                    onPingNode: _pingNode,
                    onModeChanged: _changeConnectionMode,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<VpnNode> _orderedNodes(List<VpnNode> nodes) {
    final copy = [...nodes];
    if (_sortByPing) {
      copy.sort((left, right) {
        final leftDelay = left.delayMs < 0 ? 1 << 30 : left.delayMs;
        final rightDelay = right.delayMs < 0 ? 1 << 30 : right.delayMs;
        final byPing = leftDelay.compareTo(rightDelay);
        return byPing == 0 ? left.name.compareTo(right.name) : byPing;
      });
    } else {
      copy.sort((left, right) => left.name.compareTo(right.name));
    }
    return copy;
  }

  Future<void> _changeConnectionMode(ConnectionMode mode) async {
    final current = ref.read(settingsControllerProvider).valueOrNull;
    if (current == null || current.connectionMode == mode || _changingMode) {
      return;
    }

    setState(() => _changingMode = true);
    final connection = ref.read(mihomoControllerProvider);
    final selectedNode = ref.read(selectedNodeProvider).valueOrNull;
    final reconnectNode = connection.isConnected ? selectedNode : null;

    try {
      if (connection.isConnected || connection.isBusy) {
        await ref.read(mihomoControllerProvider.notifier).disconnect();
      }

      final saved = await ref
          .read(settingsControllerProvider.notifier)
          .save((settings) => settings..connectionMode = mode);
      await ref
          .read(subscriptionRepositoryProvider)
          .rebuildMergedConfigs(saved);

      if (reconnectNode != null) {
        await ref
            .read(mihomoControllerProvider.notifier)
            .connect(reconnectNode);
      }
    } catch (error) {
      if (mounted) {
        _showSnack(error);
      }
    } finally {
      if (mounted) {
        setState(() => _changingMode = false);
      }
    }
  }

  Future<void> _pingAll(List<VpnNode> nodes) async {
    if (_pingingAll || nodes.isEmpty) {
      return;
    }

    setState(() => _pingingAll = true);
    try {
      await ref.read(mihomoControllerProvider.notifier).pingAll(nodes);
    } catch (error) {
      if (mounted) {
        _showSnack(error);
      }
    } finally {
      if (mounted) {
        setState(() => _pingingAll = false);
      }
    }
  }

  Future<void> _refreshAllSubscriptions() async {
    if (_refreshingAll || _isRefreshFlood(_lastRefreshAllAt)) {
      _showSnack(
          'Не так быстро: обновление уже идет или только что запускалось.');
      return;
    }

    setState(() {
      _refreshingAll = true;
      _lastRefreshAllAt = DateTime.now();
    });
    try {
      await ref.read(subscriptionRepositoryProvider).refreshAll();
    } catch (error) {
      if (mounted) {
        _showSnack(error);
      }
    } finally {
      if (mounted) {
        setState(() => _refreshingAll = false);
      }
    }
  }

  Future<void> _refreshProfile(SubscriptionProfile profile) async {
    if (_refreshingProfileIds.contains(profile.id) ||
        _isRefreshFlood(_lastProfileRefreshAt[profile.id])) {
      _showSnack('Не так быстро: эта подписка уже обновляется.');
      return;
    }

    setState(() {
      _refreshingProfileIds.add(profile.id);
      _lastProfileRefreshAt[profile.id] = DateTime.now();
    });
    try {
      await ref.read(subscriptionRepositoryProvider).refreshProfile(profile.id);
    } catch (error) {
      if (mounted) {
        _showSnack(error);
      }
    } finally {
      if (mounted) {
        setState(() => _refreshingProfileIds.remove(profile.id));
      }
    }
  }

  bool _isRefreshFlood(DateTime? lastRunAt) {
    return lastRunAt != null &&
        DateTime.now().difference(lastRunAt) < const Duration(seconds: 4);
  }

  void _toggleProfile(SubscriptionProfile profile) {
    setState(() {
      if (!_collapsedProfileIds.add(profile.id)) {
        _collapsedProfileIds.remove(profile.id);
      }
    });
  }

  Future<void> _pingNode(VpnNode node) async {
    if (_pingingNodes.contains(node.id)) {
      return;
    }

    setState(() => _pingingNodes.add(node.id));
    try {
      await ref.read(mihomoControllerProvider.notifier).delay(node);
    } catch (error) {
      if (mounted) {
        _showSnack(error);
      }
    } finally {
      if (mounted) {
        setState(() => _pingingNodes.remove(node.id));
      }
    }
  }

  Future<void> _connect(BuildContext context, VpnNode? node) async {
    if (node == null) {
      _showSnack('Сначала добавь подписку или проверь пинг для Авто.');
      return;
    }

    try {
      await ref.read(subscriptionRepositoryProvider).selectNode(node.id);
      await ref.read(mihomoControllerProvider.notifier).connect(node);
    } catch (error) {
      if (context.mounted) {
        _showSnack(error);
      }
    }
  }

  Future<void> _showProfileActions(SubscriptionProfile profile) async {
    final titleController = TextEditingController(text: profile.title);
    final intervalController =
        TextEditingController(text: profile.updateIntervalHours.toString());

    final action = await showDialog<_ProfileAction>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Настройки подписки'),
        content: SizedBox(
          width: 460,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Название',
                  prefixIcon: Icon(Icons.drive_file_rename_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: intervalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Автообновление, часов',
                  prefixIcon: Icon(Icons.schedule),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(_ProfileAction.delete),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Удалить'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(_ProfileAction.save),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );

    if (!mounted || action == null) {
      return;
    }

    try {
      final repository = ref.read(subscriptionRepositoryProvider);
      if (action == _ProfileAction.delete) {
        await repository.deleteProfile(profile.id);
        return;
      }

      await repository.updateProfileSettings(
        profileId: profile.id,
        title: titleController.text,
        updateIntervalHours: int.tryParse(intervalController.text.trim()) ??
            profile.updateIntervalHours,
      );
    } catch (error) {
      if (mounted) {
        _showSnack(error);
      }
    }
  }

  Future<void> _showImportDialog(BuildContext context) async {
    final controller = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить подписку'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 280,
            maxWidth: 620,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Ссылка подписки Remnawave',
                  prefixIcon: Icon(Icons.link),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.content_paste),
                  label: const Text('Вставить из буфера'),
                  onPressed: () async {
                    final data = await Clipboard.getData(Clipboard.kTextPlain);
                    controller.text = data?.text?.trim() ?? '';
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            icon: const Icon(Icons.add_link),
            label: const Text('Импорт'),
          ),
        ],
      ),
    );

    if (url == null || url.isEmpty || !context.mounted) {
      return;
    }

    await _run(context, () async {
      await ref.read(subscriptionRepositoryProvider).importFromUrl(url);
    });
  }

  Future<void> _importFromDeepLink(String rawLink) async {
    final now = DateTime.now();
    if (_lastDeepLink == rawLink &&
        _lastDeepLinkAt != null &&
        now.difference(_lastDeepLinkAt!) < const Duration(seconds: 3)) {
      return;
    }
    _lastDeepLink = rawLink;
    _lastDeepLinkAt = now;

    final subscriptionUrl = DeepLinkParser.extractSubscriptionUrl(rawLink);
    if (subscriptionUrl == null) {
      _showSnack(
          'Ссылка не похожа на подписку. Нужен формат happ://add/https://...');
      return;
    }

    await _run(context, () async {
      await ref
          .read(subscriptionRepositoryProvider)
          .importFromUrl(subscriptionUrl);
      if (mounted) {
        _showSnack('Подписка добавлена из deep link.');
      }
    });
  }

  Future<void> _run(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (error) {
      if (context.mounted) {
        _showSnack(error);
      }
    }
  }

  void _showSnack(Object error) {
    final settings = ref.read(settingsControllerProvider).valueOrNull;
    if (settings?.showConnectionMessages == false) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(userFacingErrorMessage(error))),
    );
  }

  Future<void> _updateTrayTooltip(
    PxxConnectionState connection,
    VpnNode? selectedNode,
  ) async {
    final status = switch (connection.phase) {
      VpnConnectionPhase.connected => 'Подключено',
      VpnConnectionPhase.connecting => 'Подключение',
      VpnConnectionPhase.disconnecting => 'Отключение',
      VpnConnectionPhase.error => 'Ошибка',
      VpnConnectionPhase.disconnected => 'Отключено',
    };
    final nodeName = connection.currentNodeName ?? selectedNode?.name;
    final protocol = connection.currentProtocol ?? selectedNode?.type;
    final tooltip = [
      AppConstants.appName,
      status,
      if (nodeName != null && nodeName.isNotEmpty)
        redactNetworkText(cleanNodeName(nodeName)),
      if (protocol != null && protocol.isNotEmpty) protocol.toUpperCase(),
    ].join('\n');

    if (tooltip == _lastTrayTooltip) {
      return;
    }

    _lastTrayTooltip = tooltip;
    try {
      await _trayChannel.invokeMethod<void>('setStatus', {
        'tooltip': tooltip,
        'connected': connection.isConnected,
        'busy': connection.isBusy,
        'hasSelected': selectedNode != null,
      });
    } on MissingPluginException {
      // The tray channel exists only in the Windows runner.
    }
  }

  Future<void> _exitFromTray() async {
    if (_exitingFromTray) {
      return;
    }

    _exitingFromTray = true;
    try {
      final connection = ref.read(mihomoControllerProvider);
      if (connection.isConnected || connection.isBusy) {
        await ref
            .read(mihomoControllerProvider.notifier)
            .disconnect()
            .timeout(const Duration(seconds: 12));
      }
    } catch (_) {
      // Exit should still be possible even if the core is already gone.
    }

    try {
      await _trayChannel.invokeMethod<void>('exit');
    } on MissingPluginException {
      // The tray channel exists only in the Windows runner.
    }
  }
}

enum _ProfileAction {
  save,
  delete,
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({
    required this.profiles,
    required this.nodes,
    required this.selectedNode,
    required this.connection,
    required this.settings,
    required this.sortByPing,
    required this.pingingAll,
    required this.changingMode,
    required this.refreshingAll,
    required this.collapsedProfileIds,
    required this.refreshingProfileIds,
    required this.pingingNodes,
    required this.onSortChanged,
    required this.onImport,
    required this.onRefresh,
    required this.onSettings,
    required this.onConnect,
    required this.onDisconnect,
    required this.onSelectNode,
    required this.onToggleProfile,
    required this.onRefreshProfile,
    required this.onConfigureProfile,
    required this.onPingAll,
    required this.onPingNode,
    required this.onModeChanged,
  });

  final List<SubscriptionProfile> profiles;
  final List<VpnNode> nodes;
  final VpnNode? selectedNode;
  final PxxConnectionState connection;
  final AppSettings settings;
  final bool sortByPing;
  final bool pingingAll;
  final bool changingMode;
  final bool refreshingAll;
  final Set<int> collapsedProfileIds;
  final Set<int> refreshingProfileIds;
  final Set<int> pingingNodes;
  final ValueChanged<bool> onSortChanged;
  final VoidCallback onImport;
  final VoidCallback onRefresh;
  final VoidCallback onSettings;
  final ValueChanged<VpnNode?> onConnect;
  final VoidCallback onDisconnect;
  final ValueChanged<VpnNode> onSelectNode;
  final ValueChanged<SubscriptionProfile> onToggleProfile;
  final ValueChanged<SubscriptionProfile> onRefreshProfile;
  final ValueChanged<SubscriptionProfile> onConfigureProfile;
  final VoidCallback onPingAll;
  final ValueChanged<VpnNode> onPingNode;
  final ValueChanged<ConnectionMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final profile = profiles.isEmpty ? null : profiles.first;
    final bestNode = _bestNode(nodes);
    final activeNode = selectedNode ?? bestNode;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 980;
        final androidTunOnly = defaultTargetPlatform == TargetPlatform.android;
        final top = _SubscriptionHeader(
          profile: profile,
          settings: settings,
          changingMode: changingMode,
          refreshing: refreshingAll,
          showModeSwitch: !androidTunOnly,
          onImport: onImport,
          onRefresh: onRefresh,
          onSettings: onSettings,
          onModeChanged: onModeChanged,
        );
        final serverPanel = _ServerPanel(
          profiles: profiles,
          nodes: nodes,
          selectedNode: selectedNode,
          bestNode: bestNode,
          shrinkWrap: !wide,
          sortByPing: sortByPing,
          pingingAll: pingingAll,
          pingingNodes: pingingNodes,
          collapsedProfileIds: collapsedProfileIds,
          refreshingProfileIds: refreshingProfileIds,
          onSortChanged: onSortChanged,
          onImport: onImport,
          onRefresh: onRefresh,
          onSelectNode: onSelectNode,
          onToggleProfile: onToggleProfile,
          onRefreshProfile: onRefreshProfile,
          onConfigureProfile: onConfigureProfile,
          onPingAll: onPingAll,
          onPingNode: onPingNode,
          onConnect: onConnect,
        );
        final dock = _ConnectionDock(
          activeNode: activeNode,
          bestNode: bestNode,
          connection: connection,
          settings: settings,
          onPower: () => connection.isConnected || connection.isBusy
              ? onDisconnect()
              : onConnect(activeNode),
          onAutoConnect: () => onConnect(bestNode),
          onPingAll: onPingAll,
          onImport: onImport,
          onSettings: onSettings,
          pingingAll: pingingAll,
        );

        if (!wide) {
          return SingleChildScrollView(
            child: Column(
              children: [
                top,
                const SizedBox(height: 12),
                dock,
                const SizedBox(height: 12),
                serverPanel,
              ],
            ),
          );
        }

        return Column(
          children: [
            top,
            const SizedBox(height: 14),
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: constraints.maxWidth * 0.42,
                    child: serverPanel,
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: dock),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  VpnNode? _bestNode(List<VpnNode> nodes) {
    final measured = nodes.where((node) => node.delayMs >= 0).toList();
    if (measured.isEmpty) {
      return null;
    }
    measured.sort((left, right) => left.delayMs.compareTo(right.delayMs));
    return measured.first;
  }
}

class _SubscriptionHeader extends StatelessWidget {
  const _SubscriptionHeader({
    required this.profile,
    required this.settings,
    required this.changingMode,
    required this.refreshing,
    required this.showModeSwitch,
    required this.onImport,
    required this.onRefresh,
    required this.onSettings,
    required this.onModeChanged,
  });

  final SubscriptionProfile? profile;
  final AppSettings settings;
  final bool changingMode;
  final bool refreshing;
  final bool showModeSwitch;
  final VoidCallback onImport;
  final VoidCallback onRefresh;
  final VoidCallback onSettings;
  final ValueChanged<ConnectionMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final used = (profile?.uploadBytes ?? 0) + (profile?.downloadBytes ?? 0);
    final total = profile?.totalBytes ?? 0;
    final progress = total <= 0 ? 0.0 : (used / total).clamp(0.0, 1.0);

    return _Panel(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 430;
              final title = Row(
                children: [
                  const _LogoMark(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            AppConstants.appName.toLowerCase(),
                            maxLines: 1,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  height: 1,
                                ),
                          ),
                        ),
                        Text(
                          profile?.title ?? 'подписка не добавлена',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
              final actions = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _IconGlass(
                    icon: Icons.add_link,
                    tooltip: 'Добавить подписку',
                    onPressed: onImport,
                  ),
                  const SizedBox(width: 8),
                  _IconGlass(
                    icon: Icons.refresh,
                    tooltip: 'Обновить',
                    onPressed: refreshing ? null : onRefresh,
                  ),
                  const SizedBox(width: 8),
                  _IconGlass(
                    icon: Icons.settings,
                    tooltip: 'Настройки',
                    onPressed: onSettings,
                  ),
                ],
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    const SizedBox(height: 12),
                    Align(alignment: Alignment.centerRight, child: actions),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: title),
                  const SizedBox(width: 12),
                  actions,
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 10,
                    value: progress,
                    backgroundColor:
                        colors.surfaceContainerHighest.withValues(alpha: 0.8),
                    valueColor: const AlwaysStoppedAnimation(
                      Color(0xFFE50914),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                total == 0
                    ? '${_formatBytes(used)} / ∞'
                    : '${_formatBytes(used)} / ${_formatBytes(total)}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              if (settings.showAnnouncements) ...[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: colors.surfaceContainerHighest.withValues(
                        alpha: Theme.of(context).brightness == Brightness.dark
                            ? 0.42
                            : 0.72,
                      ),
                      border: Border.all(
                        color: colors.outlineVariant.withValues(alpha: 0.7),
                      ),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Объявление',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                        SizedBox(height: 2),
                        Text('Добро пожаловать!'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ] else
                const Spacer(),
              if (showModeSwitch)
                _ModeSwitch(
                  value: settings.connectionMode,
                  busy: changingMode,
                  onChanged: onModeChanged,
                )
              else
                const _TunOnlyBadge(),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServerPanel extends StatelessWidget {
  const _ServerPanel({
    required this.profiles,
    required this.nodes,
    required this.selectedNode,
    required this.bestNode,
    required this.shrinkWrap,
    required this.sortByPing,
    required this.pingingAll,
    required this.pingingNodes,
    required this.collapsedProfileIds,
    required this.refreshingProfileIds,
    required this.onSortChanged,
    required this.onImport,
    required this.onRefresh,
    required this.onSelectNode,
    required this.onToggleProfile,
    required this.onRefreshProfile,
    required this.onConfigureProfile,
    required this.onPingAll,
    required this.onPingNode,
    required this.onConnect,
  });

  final List<SubscriptionProfile> profiles;
  final List<VpnNode> nodes;
  final VpnNode? selectedNode;
  final VpnNode? bestNode;
  final bool shrinkWrap;
  final bool sortByPing;
  final bool pingingAll;
  final Set<int> pingingNodes;
  final Set<int> collapsedProfileIds;
  final Set<int> refreshingProfileIds;
  final ValueChanged<bool> onSortChanged;
  final VoidCallback onImport;
  final VoidCallback onRefresh;
  final ValueChanged<VpnNode> onSelectNode;
  final ValueChanged<SubscriptionProfile> onToggleProfile;
  final ValueChanged<SubscriptionProfile> onRefreshProfile;
  final ValueChanged<SubscriptionProfile> onConfigureProfile;
  final VoidCallback onPingAll;
  final ValueChanged<VpnNode> onPingNode;
  final ValueChanged<VpnNode?> onConnect;

  @override
  Widget build(BuildContext context) {
    final entries = _buildEntries();
    final list = nodes.isEmpty
        ? _EmptyServers(onImport: onImport)
        : ListView.separated(
            shrinkWrap: shrinkWrap,
            physics: shrinkWrap
                ? const NeverScrollableScrollPhysics()
                : const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            itemCount: entries.length,
            separatorBuilder: (_, index) => SizedBox(
              height: entries[index].isHeader ? 7 : 6,
            ),
            itemBuilder: (context, index) {
              final entry = entries[index];
              final profile = entry.profile;
              if (profile != null) {
                return _SubscriptionCategoryHeader(
                  profile: profile,
                  collapsed: collapsedProfileIds.contains(profile.id),
                  refreshing: refreshingProfileIds.contains(profile.id),
                  onToggle: () => onToggleProfile(profile),
                  onRefresh: () => onRefreshProfile(profile),
                  onMore: () => onConfigureProfile(profile),
                );
              }

              final node = entry.node!;
              return _CountryServerTile(
                node: node,
                selected: node.id == selectedNode?.id,
                auto: node.id == bestNode?.id,
                pinging: pingingNodes.contains(node.id),
                onTap: () => onSelectNode(node),
                onPing: () => onPingNode(node),
              );
            },
          );

    return _Panel(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: _AutoRouteTile(
                    bestNode: bestNode,
                    onTap: bestNode == null
                        ? (pingingAll ? null : onPingAll)
                        : () => onConnect(bestNode),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    FilterChip(
                      label: const Text('по пингу'),
                      selected: sortByPing,
                      onSelected: onSortChanged,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed:
                            pingingAll || nodes.isEmpty ? null : onPingAll,
                        icon: pingingAll
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.speed),
                        label: const Text(
                          'Обновить пинг',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (shrinkWrap) list else Expanded(child: list),
        ],
      ),
    );
  }

  List<_ServerListEntry> _buildEntries() {
    final profilesById = {for (final profile in profiles) profile.id: profile};
    final grouped = <int, List<VpnNode>>{};
    for (final node in nodes) {
      grouped.putIfAbsent(node.profileId, () => <VpnNode>[]).add(node);
    }

    final entries = <_ServerListEntry>[];
    for (final profile in profiles) {
      final profileNodes = grouped.remove(profile.id);
      if (profileNodes == null || profileNodes.isEmpty) {
        continue;
      }
      entries.add(_ServerListEntry.profile(profile));
      if (!collapsedProfileIds.contains(profile.id)) {
        entries.addAll(profileNodes.map(_ServerListEntry.node));
      }
    }

    for (final item in grouped.entries) {
      final profile = profilesById[item.key];
      if (profile != null) {
        entries.add(_ServerListEntry.profile(profile));
      }
      if (profile == null || !collapsedProfileIds.contains(profile.id)) {
        entries.addAll(item.value.map(_ServerListEntry.node));
      }
    }

    return entries;
  }
}

class _ServerListEntry {
  const _ServerListEntry._({this.profile, this.node});

  factory _ServerListEntry.profile(SubscriptionProfile profile) {
    return _ServerListEntry._(profile: profile);
  }

  factory _ServerListEntry.node(VpnNode node) {
    return _ServerListEntry._(node: node);
  }

  final SubscriptionProfile? profile;
  final VpnNode? node;

  bool get isHeader => profile != null;
}

class _SubscriptionCategoryHeader extends StatelessWidget {
  const _SubscriptionCategoryHeader({
    required this.profile,
    required this.collapsed,
    required this.refreshing,
    required this.onToggle,
    required this.onRefresh,
    required this.onMore,
  });

  final SubscriptionProfile profile;
  final bool collapsed;
  final bool refreshing;
  final VoidCallback onToggle;
  final VoidCallback onRefresh;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final updated = DateFormat('dd.MM.yyyy HH:mm').format(profile.updatedAt);
    final interval = profile.updateIntervalHours <= 0
        ? ''
        : ' | Автообновление - ${profile.updateIntervalHours}ч.';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: colors.surface.withValues(alpha: 0.9),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: collapsed ? 'Развернуть подписку' : 'Свернуть подписку',
            onPressed: onToggle,
            icon: Icon(
              collapsed
                  ? Icons.keyboard_arrow_right
                  : Icons.keyboard_arrow_down,
              size: 22,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  '$updated$interval',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Обновить подписку',
            onPressed: refreshing ? null : onRefresh,
            icon: refreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Еще',
            onPressed: onMore,
            icon: const Icon(Icons.more_horiz),
          ),
        ],
      ),
    );
  }
}

class _ConnectionDock extends StatelessWidget {
  const _ConnectionDock({
    required this.activeNode,
    required this.bestNode,
    required this.connection,
    required this.settings,
    required this.onPower,
    required this.onAutoConnect,
    required this.onPingAll,
    required this.onImport,
    required this.onSettings,
    required this.pingingAll,
  });

  final VpnNode? activeNode;
  final VpnNode? bestNode;
  final PxxConnectionState connection;
  final AppSettings settings;
  final VoidCallback onPower;
  final VoidCallback onAutoConnect;
  final VoidCallback onPingAll;
  final VoidCallback onImport;
  final VoidCallback onSettings;
  final bool pingingAll;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final node = activeNode;
    final code = _countryCodeForNode(node);
    final palette = _paletteFor(code);

    return _Panel(
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _NodeFlagOrb(node: node, code: code, size: 58),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    node == null
                        ? Text(
                            'Авто',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                          )
                        : _NodeTitle(
                            name: node.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                    const SizedBox(height: 3),
                    Text(
                      node == null ? '—' : _nodeProtocolLabel(node),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: palette
                    .map((color) => color.withValues(alpha: 0.34))
                    .toList(growable: false),
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final metrics = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatusLine(connection: connection),
                    const SizedBox(height: 10),
                    _DockMetric(
                      label: 'IP',
                      value: connection.isConnected ? 'скрыт' : '—',
                    ),
                    const SizedBox(height: 6),
                    _DockMetric(
                      label: 'Режим',
                      value: defaultTargetPlatform == TargetPlatform.android ||
                              settings.connectionMode == ConnectionMode.tun
                          ? 'TUN'
                          : 'Proxy',
                    ),
                    const SizedBox(height: 6),
                    _DockMetric(
                      label: 'Пинг',
                      value: node == null ? '—' : _delayLabel(node.delayMs),
                    ),
                    if (connection.phase == VpnConnectionPhase.error &&
                        connection.message?.isNotEmpty == true) ...[
                      const SizedBox(height: 10),
                      Text(
                        redactNetworkText(connection.message!),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFFFFA0A8),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ],
                );

                final power = _PowerButton(
                  connected: connection.isConnected,
                  busy: connection.isBusy,
                  onPressed: onPower,
                  size: constraints.maxWidth < 520 ? 178 : 186,
                );

                if (constraints.maxWidth < 520) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      metrics,
                      const SizedBox(height: 18),
                      Center(child: power),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: metrics),
                    const SizedBox(width: 18),
                    Expanded(child: Center(child: power)),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          _AutoMini(
            bestNode: bestNode,
            onTap: bestNode == null
                ? (pingingAll ? null : onPingAll)
                : onAutoConnect,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _DockNavButton(icon: Icons.home_filled, onPressed: () {}),
              _DockNavButton(icon: Icons.dns, onPressed: () {}),
              _DockNavButton(icon: Icons.more_horiz, onPressed: onImport),
              _DockNavButton(icon: Icons.settings, onPressed: onSettings),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountryServerTile extends StatelessWidget {
  const _CountryServerTile({
    required this.node,
    required this.selected,
    required this.auto,
    required this.pinging,
    required this.onTap,
    required this.onPing,
  });

  final VpnNode node;
  final bool selected;
  final bool auto;
  final bool pinging;
  final VoidCallback onTap;
  final VoidCallback onPing;

  @override
  Widget build(BuildContext context) {
    final code = _countryCodeForNode(node);
    final viaCode = _viaCountryCodeForNode(node);
    final palette = _paletteFor(code);
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    const selectedColor = Color(0xFF36F27C);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: selected
                  ? selectedColor
                  : colors.outlineVariant.withValues(alpha: 0.42),
              width: selected ? 2.6 : 1,
            ),
            boxShadow: [
              if (selected)
                BoxShadow(
                  color: selectedColor.withValues(alpha: 0.16),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              if (selected)
                BoxShadow(
                  color: selectedColor.withValues(alpha: 0.28),
                  blurRadius: 22,
                ),
            ],
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                palette.first.withValues(alpha: dark ? 0.94 : 0.9),
                palette.length > 1
                    ? palette[1].withValues(alpha: dark ? 0.62 : 0.5)
                    : colors.surfaceContainerHighest,
                (palette.length > 2 ? palette[2] : palette.last)
                    .withValues(alpha: dark ? 0.28 : 0.22),
                colors.surfaceContainerHighest.withValues(
                  alpha: dark ? 0.78 : 0.96,
                ),
              ],
              stops: const [0, 0.18, 0.42, 1],
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 82,
                height: 64,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Center(child: _FlagPlate(code: code, width: 48)),
                    if (viaCode != null)
                      Positioned(
                        right: 8,
                        bottom: 7,
                        child: _ViaFlagBadge(code: viaCode),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _NodeTitle(
                            name: node.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                          ),
                        ),
                        if (auto) const _TinyBadge(label: 'AUTO'),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${node.type.toUpperCase()} • адрес скрыт',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _DelayPill(delayMs: node.delayMs),
              IconButton(
                tooltip: 'Пинг',
                iconSize: 18,
                visualDensity: VisualDensity.compact,
                onPressed: pinging ? null : onPing,
                icon: pinging
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.radar),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AutoRouteTile extends StatelessWidget {
  const _AutoRouteTile({
    required this.bestNode,
    required this.onTap,
  });

  final VpnNode? bestNode;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                colors.primary.withValues(alpha: 0.92),
                colors.primary.withValues(alpha: 0.22),
                colors.surfaceContainerHighest.withValues(alpha: 0.86),
              ],
            ),
          ),
          child: Row(
            children: [
              _NodeFlagOrb(
                node: bestNode,
                code: _countryCodeForNode(bestNode),
                size: 38,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Авто',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      bestNode == null
                          ? 'лучший пинг'
                          : '${_displayNodeName(bestNode!.name)} • ${bestNode!.delayMs} ms',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NodeTitle extends StatelessWidget {
  const _NodeTitle({
    required this.name,
    required this.style,
  });

  final String name;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ?? DefaultTextStyle.of(context).style;
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: effectiveStyle,
        children: _nodeTitleSpans(_displayNodeName(name), effectiveStyle),
      ),
    );
  }
}

List<InlineSpan> _nodeTitleSpans(String title, TextStyle style) {
  final spans = <InlineSpan>[];
  final parts = RegExp(r'\s+|/|[^\s/]+')
      .allMatches(title)
      .map((match) => match.group(0) ?? '')
      .where((part) => part.isNotEmpty);
  var afterVia = false;

  for (final part in parts) {
    if (part.trim().isEmpty) {
      spans.add(TextSpan(text: part));
      continue;
    }

    if (part == '/') {
      spans.add(const TextSpan(text: '/'));
      continue;
    }

    final code = _countryCodeFromToken(part);
    if (afterVia && code != null) {
      spans.add(TextSpan(text: countryFlagEmoji(code) ?? code, style: style));
      continue;
    }

    spans.add(TextSpan(text: part, style: style));
    afterVia = _plainWord(part).toLowerCase() == 'via';
  }

  return spans;
}

String? _countryCodeFromToken(String token) {
  final flagCode = countryCodeFromFlagEmoji(token);
  if (flagCode != null) {
    return flagCode;
  }
  final word = _plainWord(token);
  if (word.isEmpty) {
    return null;
  }
  return normalizeCountryCode(word);
}

String _plainWord(String token) {
  return token.replaceAll(RegExp(r'^[^\w]+|[^\w]+$'), '');
}

class _AutoMini extends StatelessWidget {
  const _AutoMini({
    required this.bestNode,
    required this.onTap,
  });

  final VpnNode? bestNode;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.auto_awesome),
      label: Text(
        bestNode == null
            ? 'Авто'
            : 'Авто: ${_displayNodeName(bestNode!.name)} / ${bestNode!.delayMs} ms',
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _TunOnlyBadge extends StatelessWidget {
  const _TunOnlyBadge();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.outline.withValues(alpha: 0.65)),
        color: colors.surfaceContainerHighest.withValues(alpha: 0.42),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield, size: 19, color: colors.primary),
          const SizedBox(width: 8),
          const Text('TUN', style: TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({
    required this.value,
    required this.busy,
    required this.onChanged,
  });

  final ConnectionMode value;
  final bool busy;
  final ValueChanged<ConnectionMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ConnectionMode>(
      showSelectedIcon: false,
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
      selected: {value},
      onSelectionChanged: busy ? null : (set) => onChanged(set.first),
    );
  }
}

class _PowerButton extends StatelessWidget {
  const _PowerButton({
    required this.connected,
    required this.busy,
    required this.onPressed,
    this.size = 168,
  });

  final bool connected;
  final bool busy;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onPressed,
      customBorder: const CircleBorder(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: connected
                ? const [Color(0xFF161616), Color(0xFF3D3D42)]
                : const [Color(0xFFFF1D2D), Color(0xFF780008)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: (connected ? Colors.black : const Color(0xFFE50914))
                  .withValues(alpha: 0.42),
              blurRadius: 34,
              spreadRadius: 2,
              offset: const Offset(0, 18),
            ),
          ],
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.16),
            width: 1.2,
          ),
        ),
        child: Center(
          child: busy
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: size * 0.4,
                      height: size * 0.4,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 4,
                      ),
                    ),
                    Icon(Icons.close, color: Colors.white, size: size * 0.3),
                  ],
                )
              : Icon(
                  Icons.power_settings_new,
                  color: Colors.white,
                  size: size * 0.46,
                ),
        ),
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.connection});

  final PxxConnectionState connection;

  @override
  Widget build(BuildContext context) {
    final text = switch (connection.phase) {
      VpnConnectionPhase.connected => 'Подключено',
      VpnConnectionPhase.connecting => 'Подключение',
      VpnConnectionPhase.disconnecting => 'Отключение',
      VpnConnectionPhase.error => 'Ошибка',
      VpnConnectionPhase.disconnected => 'Отключено',
    };
    final color = connection.isConnected
        ? const Color(0xFF36F27C)
        : const Color(0xFFFF3340);

    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.55), blurRadius: 14),
            ],
          ),
        ),
        const SizedBox(width: 9),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w900)),
      ],
    );
  }
}

class _DockMetric extends StatelessWidget {
  const _DockMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 48,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _DelayPill extends StatelessWidget {
  const _DelayPill({required this.delayMs});

  final int delayMs;

  @override
  Widget build(BuildContext context) {
    final color = delayMs < 0
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : delayMs < 120
            ? const Color(0xFF32E66B)
            : delayMs < 260
                ? const Color(0xFFFFB020)
                : const Color(0xFFFF3340);

    return Container(
      constraints: const BoxConstraints(minWidth: 70),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.34)),
      ),
      child: Text(
        _delayLabel(delayMs),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _FlagPlate extends StatelessWidget {
  const _FlagPlate({required this.code, required this.width});

  final String? code;
  final double width;

  @override
  Widget build(BuildContext context) {
    final normalized = normalizeCountryCode(code);
    final url = countryFlagUrl(normalized, width: 160);
    final height = width * 0.62;
    if (url == null) {
      return _UnknownFlag(width: width, height: height);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _UnknownFlag(
            width: width, height: height, label: normalized ?? '??'),
      ),
    );
  }
}

class _FlagOrb extends StatelessWidget {
  const _FlagOrb({required this.code, required this.size});

  final String? code;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.18),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: FittedBox(
        fit: BoxFit.contain,
        child: _FlagPlate(code: code, width: size),
      ),
    );
  }
}

class _NodeFlagOrb extends StatelessWidget {
  const _NodeFlagOrb({
    required this.node,
    required this.code,
    required this.size,
  });

  final VpnNode? node;
  final String? code;
  final double size;

  @override
  Widget build(BuildContext context) {
    final viaCode = node == null ? null : _viaCountryCodeForNode(node!);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _FlagOrb(code: code, size: size),
          if (viaCode != null)
            Positioned(
              right: -2,
              bottom: -2,
              child: _ViaFlagBadge(code: viaCode),
            ),
        ],
      ),
    );
  }
}

class _ViaFlagBadge extends StatelessWidget {
  const _ViaFlagBadge({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 24,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.72),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.32),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.contain,
        child: _FlagPlate(code: code, width: 26),
      ),
    );
  }
}

class _UnknownFlag extends StatelessWidget {
  const _UnknownFlag({
    required this.width,
    required this.height,
    this.label = '??',
  });

  final double width;
  final double height;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: width * 0.22,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _TinyBadge extends StatelessWidget {
  const _TinyBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 22,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              softWrap: false,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyServers extends StatelessWidget {
  const _EmptyServers({required this.onImport});

  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.travel_explore,
            size: 56,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 14),
          const Text('Добавь подписку, и здесь появятся локации'),
          const SizedBox(height: 14),
          FilledButton.icon(
            icon: const Icon(Icons.add_link),
            label: const Text('Добавить ссылку'),
            onPressed: onImport,
          ),
        ],
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFFF1D2D), Color(0xFF770008)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE50914).withValues(alpha: 0.45),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset('assets/app_icon.png', fit: BoxFit.cover),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: dark ? 0.86 : 0.94),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: dark ? 0.56 : 0.92),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.34 : 0.08),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class _IconGlass extends StatelessWidget {
  const _IconGlass({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
    );
  }
}

class _DockNavButton extends StatelessWidget {
  const _DockNavButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: onPressed,
      icon: Icon(icon),
    );
  }
}

class _AppBackdrop {
  const _AppBackdrop._();

  static BoxDecoration decoration(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      gradient: LinearGradient(
        colors: dark
            ? const [Color(0xFF050505), Color(0xFF160709), Color(0xFF09090B)]
            : const [Color(0xFFFFFFFF), Color(0xFFFFF1F2), Color(0xFFF5F5F7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }
}

String _delayLabel(int delayMs) {
  if (delayMs < 0) {
    return '—';
  }
  return '$delayMs ms';
}

String _formatBytes(int value) {
  if (value <= 0) {
    return '0 B';
  }
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  var size = value.toDouble();
  var unit = 0;
  while (size >= 1024 && unit < units.length - 1) {
    size /= 1024;
    unit++;
  }
  return '${size.toStringAsFixed(size >= 10 ? 0 : 1)} ${units[unit]}';
}

String _displayNodeName(String name) {
  return redactNetworkText(cleanNodeName(name));
}

String _nodeProtocolLabel(VpnNode node) {
  final parts = <String>[node.type.toUpperCase()];
  if (node.network.trim().isNotEmpty) {
    parts.add(node.network.toUpperCase());
  }
  if (node.security.trim().isNotEmpty) {
    parts.add(node.security.toUpperCase());
  }
  return parts.join(' • ');
}

String? _countryCodeForNode(VpnNode? node) {
  if (node == null) {
    return null;
  }
  return countryCodeFromText(node.name, node.server) ??
      normalizeCountryCode(node.countryCode);
}

String? _viaCountryCodeForNode(VpnNode node) {
  final parts = RegExp(r'\s+|/|[^\s/]+')
      .allMatches(cleanNodeName(node.name))
      .map((match) => match.group(0) ?? '')
      .where((part) => part.trim().isNotEmpty && part != '/')
      .toList(growable: false);

  for (var index = 0; index < parts.length - 1; index++) {
    if (_plainWord(parts[index]).toLowerCase() != 'via') {
      continue;
    }
    final code = _countryCodeFromToken(parts[index + 1]);
    if (code != null) {
      return code;
    }
  }

  return null;
}

List<Color> _paletteFor(String? code) {
  return switch (normalizeCountryCode(code)) {
    'DE' => const [Color(0xFF050505), Color(0xFFD30918), Color(0xFFFFD21E)],
    'FI' => const [Color(0xFFF5F7FA), Color(0xFF0B4EA2), Color(0xFFF5F7FA)],
    'GB' => const [Color(0xFF00247D), Color(0xFFFFFFFF), Color(0xFFCF142B)],
    'GE' => const [Color(0xFFFFFFFF), Color(0xFFE01B2F), Color(0xFFFFFFFF)],
    'BG' => const [Color(0xFFFFFFFF), Color(0xFF00966E), Color(0xFFD62612)],
    'CA' => const [Color(0xFFD80621), Color(0xFFFFFFFF), Color(0xFFD80621)],
    'JP' => const [Color(0xFFFFFFFF), Color(0xFFBC002D), Color(0xFFFFFFFF)],
    'RU' => const [Color(0xFFFFFFFF), Color(0xFF0039A6), Color(0xFFD52B1E)],
    'BY' => const [Color(0xFFC8313E), Color(0xFF4AA657), Color(0xFFFFFFFF)],
    'US' => const [Color(0xFF3C3B6E), Color(0xFFFFFFFF), Color(0xFFB22234)],
    'FR' => const [Color(0xFF0055A4), Color(0xFFFFFFFF), Color(0xFFEF4135)],
    'NL' => const [Color(0xFFAE1C28), Color(0xFFFFFFFF), Color(0xFF21468B)],
    'PL' => const [Color(0xFFFFFFFF), Color(0xFFDC143C), Color(0xFFFFFFFF)],
    'SE' => const [Color(0xFF006AA7), Color(0xFFFECC00), Color(0xFF006AA7)],
    'SG' => const [Color(0xFFEF3340), Color(0xFFFFFFFF), Color(0xFFEF3340)],
    _ => const [Color(0xFFE50914), Color(0xFF1A1A1D), Color(0xFF2A2A2F)],
  };
}
