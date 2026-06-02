import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../logs/application/log_repository.dart';
import '../../settings/application/settings_controller.dart';
import '../../subscription/data/subscription_repository.dart';
import '../../subscription/domain/vpn_node.dart';
import '../data/mihomo_core.dart';
import '../domain/connection_state.dart';

final mihomoCoreProvider = Provider<MihomoCore>((ref) => MihomoCore());

final publicIpProvider = FutureProvider.autoDispose<String>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get<String>('https://api.ipify.org');
  return response.data?.trim() ?? '';
});

final mihomoControllerProvider =
    StateNotifierProvider<MihomoController, PxxConnectionState>((ref) {
  return MihomoController(ref);
});

class MihomoController extends StateNotifier<PxxConnectionState> {
  MihomoController(this._ref) : super(const PxxConnectionState.disconnected());

  final Ref _ref;
  int _connectionRunId = 0;

  Future<void> connect(VpnNode node) async {
    final runId = ++_connectionRunId;
    final settings = await _ref.read(settingsControllerProvider.future);
    final core = _ref.read(mihomoCoreProvider);
    final configPath = await _ref
        .read(subscriptionRepositoryProvider)
        .buildRuntimeConfigForNode(node, settings);
    String? ipBeforeConnect;
    if (!Platform.isAndroid && settings.tunMode) {
      ipBeforeConnect = await _readPublicIpSafely(
        timeout: const Duration(seconds: 5),
      );
    }

    state = PxxConnectionState(
      phase: VpnConnectionPhase.connecting,
      currentNodeName: node.name,
      currentProtocol: node.type,
      message: 'Запуск Mihomo',
    );

    try {
      await core
          .start(configPath: configPath, settings: settings)
          .timeout(const Duration(seconds: 90));
      if (!_isCurrentRun(runId)) {
        return;
      }

      if (!Platform.isAndroid) {
        final proxySelected = await core
            .trySelectProxy(
              groupName: AppConstants.proxyGroupName,
              proxyName: node.name,
            )
            .timeout(const Duration(seconds: 35), onTimeout: () => false);
        if (!proxySelected) {
          final controllerAvailable = await core.isControllerAvailable();
          if (controllerAvailable) {
            await _ref.read(logRepositoryProvider).add(
                  level: 'warn',
                  source: 'mihomo',
                  message:
                      'PROXY group was not switched; using the first proxy from the generated config.',
                );
          } else {
            throw StateError(
              'Mihomo запустился, но группу PROXY не удалось переключить на выбранный сервер.',
            );
          }
        }
      }
      if (!_isCurrentRun(runId)) {
        return;
      }

      if (Platform.isAndroid) {
        await Future<void>.delayed(const Duration(seconds: 2));
      }
      final ip = Platform.isAndroid
          ? null
          : await _readPublicIpSafely(
              timeout: const Duration(seconds: 7),
            );
      if (!Platform.isAndroid &&
          ipBeforeConnect != null &&
          ip != null &&
          ip == ipBeforeConnect) {
        throw StateError(
          'TUN запустился, но внешний IP не изменился. Проверь разрешения и попробуй другой сервер.',
        );
      }
      if (!_isCurrentRun(runId)) {
        return;
      }

      state = PxxConnectionState(
        phase: VpnConnectionPhase.connected,
        currentNodeName: node.name,
        currentProtocol: node.type,
        currentIp: ip,
        startedAt: DateTime.now(),
      );

      await _ref.read(logRepositoryProvider).add(
            level: 'info',
            source: 'mihomo',
            message: 'Подключено к ${node.name}',
          );
    } catch (error) {
      if (!_isCurrentRun(runId)) {
        return;
      }
      try {
        await core.stop();
      } catch (_) {
        // The original connection error is more useful for the UI.
      }
      state = PxxConnectionState(
        phase: VpnConnectionPhase.error,
        currentNodeName: node.name,
        currentProtocol: node.type,
        message: error.toString(),
      );
      rethrow;
    }
  }

  Future<void> disconnect() async {
    _connectionRunId++;
    state = state.copyWith(phase: VpnConnectionPhase.disconnecting);
    await _ref.read(mihomoCoreProvider).stop();
    state = const PxxConnectionState.disconnected();
  }

  Future<int> delay(VpnNode node) async {
    final delay = await _ref.read(mihomoCoreProvider).delay(
          proxyName: node.name,
          server: node.server,
          port: node.port,
        );
    final repository = _ref.read(subscriptionRepositoryProvider);
    await repository.updateNodeDelay(node.id, delay);
    return delay;
  }

  Future<void> pingAll(List<VpnNode> nodes) async {
    final repository = _ref.read(subscriptionRepositoryProvider);
    final core = _ref.read(mihomoCoreProvider);

    for (final node in nodes) {
      final delay = await core.delay(
        proxyName: node.name,
        server: node.server,
        port: node.port,
      );
      await repository.updateNodeDelay(node.id, delay);
    }

    await _ref.read(logRepositoryProvider).add(
          level: 'info',
          source: 'ping',
          message: 'Пинг обновлен для ${nodes.length} узлов',
        );
  }

  bool _isCurrentRun(int runId) => runId == _connectionRunId;

  Future<String?> _readPublicIpSafely({required Duration timeout}) async {
    try {
      final response = await _ref
          .read(dioProvider)
          .get<String>('https://api.ipify.org')
          .timeout(timeout);
      return response.data?.trim();
    } catch (_) {
      return null;
    }
  }
}
