import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/storage/isar_provider.dart';
import '../../../shared/countries.dart';
import '../../logs/application/log_repository.dart';
import '../../settings/application/settings_controller.dart';
import '../../settings/domain/app_settings.dart';
import '../../mihomo/application/yaml_merge_service.dart';
import '../domain/subscription_profile.dart';
import '../domain/vpn_node.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      headers: {'User-Agent': AppConstants.subscriptionUserAgent},
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
});

final yamlMergeServiceProvider =
    Provider((ref) => const MihomoYamlMergeService());

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository(ref);
});

final profilesProvider =
    StreamProvider<List<SubscriptionProfile>>((ref) async* {
  final isar = await ref.watch(isarProvider.future);
  yield* isar.subscriptionProfiles
      .where()
      .sortByUpdatedAtDesc()
      .watch(fireImmediately: true);
});

final nodesProvider = StreamProvider<List<VpnNode>>((ref) async* {
  final isar = await ref.watch(isarProvider.future);
  yield* isar.vpnNodes
      .where()
      .sortByDelayMs()
      .thenByName()
      .watch(fireImmediately: true);
});

final selectedNodeProvider = StreamProvider<VpnNode?>((ref) async* {
  final isar = await ref.watch(isarProvider.future);
  yield* isar.vpnNodes
      .filter()
      .isSelectedEqualTo(true)
      .watch(fireImmediately: true)
      .map((nodes) => nodes.isEmpty ? null : nodes.first);
});

class SubscriptionRepository {
  SubscriptionRepository(this._ref);

  final Ref _ref;

  Future<SubscriptionProfile> importFromUrl(String url) async {
    final dio = _ref.read(dioProvider);
    final response = await dio.get<String>(
      url,
      options: Options(responseType: ResponseType.plain),
    );

    final yaml = response.data ?? '';
    if (yaml.trim().isEmpty) {
      throw StateError('Subscription returned an empty YAML');
    }

    final title =
        _decodeProfileTitle(response.headers.value('profile-title')) ??
            _filenameTitle(response.headers.value('content-disposition')) ??
            Uri.tryParse(url)?.host ??
            'Remnawave';

    final settings = await _ref.read(settingsControllerProvider.future);
    final profile = await _saveYamlProfile(
      url: url,
      title: title,
      yaml: yaml,
      settings: settings,
      headers: response.headers,
    );

    await _ref.read(logRepositoryProvider).add(
          level: 'info',
          source: 'subscription',
          message: 'Imported ${profile.title}',
        );

    return profile;
  }

  Future<void> refreshAll() async {
    final isar = await _ref.read(isarProvider.future);
    final profiles = await isar.subscriptionProfiles.where().findAll();
    for (final profile in profiles) {
      await importFromUrl(profile.subscriptionUrl);
    }
  }

  Future<void> refreshProfile(int profileId) async {
    final isar = await _ref.read(isarProvider.future);
    final profile = await isar.subscriptionProfiles.get(profileId);
    if (profile == null) {
      throw StateError('Подписка не найдена');
    }
    await importFromUrl(profile.subscriptionUrl);
  }

  Future<void> updateProfileSettings({
    required int profileId,
    required String title,
    required int updateIntervalHours,
  }) async {
    final isar = await _ref.read(isarProvider.future);
    await isar.writeTxn(() async {
      final profile = await isar.subscriptionProfiles.get(profileId);
      if (profile == null) {
        return;
      }
      profile
        ..title = title.trim().isEmpty ? profile.title : title.trim()
        ..updateIntervalHours = updateIntervalHours.clamp(1, 720)
        ..updatedAt = DateTime.now();
      await isar.subscriptionProfiles.put(profile);
    });
  }

  Future<void> deleteProfile(int profileId) async {
    final isar = await _ref.read(isarProvider.future);
    await isar.writeTxn(() async {
      await isar.vpnNodes.filter().profileIdEqualTo(profileId).deleteAll();
      await isar.subscriptionProfiles.delete(profileId);
    });
  }

  Future<void> rebuildMergedConfigs(AppSettings settings) async {
    final isar = await _ref.read(isarProvider.future);
    final mergeService = _ref.read(yamlMergeServiceProvider);
    final supportDir = await getApplicationSupportDirectory();
    final configDir = Directory(p.join(supportDir.path, 'configs'));
    await configDir.create(recursive: true);

    final profiles = await isar.subscriptionProfiles.where().findAll();
    for (final profile in profiles) {
      final mergedYaml = mergeService.buildMergedConfig(
        profile.originalYaml,
        bypassRussia: settings.bypassRussia,
        enableTun: Platform.isAndroid || settings.tunMode,
        killSwitch: settings.killSwitch,
      );
      final configPath = profile.mergedYamlPath.isEmpty
          ? p.join(
              configDir.path,
              '${Uri.encodeComponent(profile.subscriptionUrl)}.yaml',
            )
          : profile.mergedYamlPath;
      await File(configPath).writeAsString(mergedYaml);
      profile
        ..mergedYamlPath = configPath
        ..updatedAt = DateTime.now();
    }

    await isar.writeTxn(() => isar.subscriptionProfiles.putAll(profiles));
  }

  Future<String> buildRuntimeConfigForNode(
    VpnNode node,
    AppSettings settings,
  ) async {
    final isar = await _ref.read(isarProvider.future);
    final profile = await isar.subscriptionProfiles.get(node.profileId);
    if (profile == null) {
      throw StateError('Подписка выбранного сервера не найдена');
    }

    final mergeService = _ref.read(yamlMergeServiceProvider);
    final supportDir = await getApplicationSupportDirectory();
    final runtimeDir = Directory(p.join(supportDir.path, 'runtime'));
    await runtimeDir.create(recursive: true);

    final mergedYaml = mergeService.buildMergedConfig(
      profile.originalYaml,
      bypassRussia: settings.bypassRussia,
      enableTun: Platform.isAndroid || settings.tunMode,
      killSwitch: settings.killSwitch,
      preferredProxyName: node.name,
    );
    final configPath = p.join(runtimeDir.path, 'selected.yaml');
    await File(configPath).writeAsString(mergedYaml);
    return configPath;
  }

  Future<void> selectNode(int nodeId) async {
    final isar = await _ref.read(isarProvider.future);
    await isar.writeTxn(() async {
      final selected =
          await isar.vpnNodes.filter().isSelectedEqualTo(true).findAll();
      for (final node in selected) {
        node.isSelected = false;
        await isar.vpnNodes.put(node);
      }

      final next = await isar.vpnNodes.get(nodeId);
      if (next != null) {
        next.isSelected = true;
        await isar.vpnNodes.put(next);
      }
    });
  }

  Future<void> updateNodeDelay(int nodeId, int delayMs) async {
    final isar = await _ref.read(isarProvider.future);
    await isar.writeTxn(() async {
      final node = await isar.vpnNodes.get(nodeId);
      if (node == null) {
        return;
      }
      node
        ..delayMs = delayMs
        ..updatedAt = DateTime.now();
      await isar.vpnNodes.put(node);
    });
  }

  Future<SubscriptionProfile> _saveYamlProfile({
    required String url,
    required String title,
    required String yaml,
    required AppSettings settings,
    required Headers headers,
  }) async {
    final isar = await _ref.read(isarProvider.future);
    final mergeService = _ref.read(yamlMergeServiceProvider);
    final supportDir = await getApplicationSupportDirectory();
    final configDir = Directory(p.join(supportDir.path, 'configs'));
    await configDir.create(recursive: true);

    final existing = await isar.subscriptionProfiles
        .filter()
        .subscriptionUrlEqualTo(url)
        .findFirst();
    final profile = existing ?? SubscriptionProfile()
      ..subscriptionUrl = url
      ..createdAt = DateTime.now();

    final mergedYaml = mergeService.buildMergedConfig(
      yaml,
      bypassRussia: settings.bypassRussia,
      enableTun: Platform.isAndroid || settings.tunMode,
      killSwitch: settings.killSwitch,
    );

    final configPath =
        p.join(configDir.path, '${Uri.encodeComponent(url)}.yaml');
    await File(configPath).writeAsString(mergedYaml);

    final userInfo = _parseUserInfo(headers.value('subscription-userinfo'));
    profile
      ..title = title
      ..originalYaml = yaml
      ..mergedYamlPath = configPath
      ..uploadBytes = userInfo['upload'] ?? 0
      ..downloadBytes = userInfo['download'] ?? 0
      ..totalBytes = userInfo['total'] ?? 0
      ..expireAtSeconds = userInfo['expire'] ?? 0
      ..updateIntervalHours =
          int.tryParse(headers.value('profile-update-interval') ?? '') ?? 24
      ..updatedAt = DateTime.now();

    final proxyNodes = mergeService.extractProxyNodes(yaml);

    await isar.writeTxn(() async {
      final profileId = await isar.subscriptionProfiles.put(profile);
      await isar.vpnNodes.filter().profileIdEqualTo(profileId).deleteAll();

      for (final proxy in proxyNodes) {
        final node = VpnNode()
          ..profileId = profileId
          ..name = proxy['name']?.toString() ?? 'Unnamed'
          ..type = proxy['type']?.toString() ?? 'unknown'
          ..server = proxy['server']?.toString() ?? ''
          ..port = int.tryParse(proxy['port']?.toString() ?? '') ?? 0
          ..countryCode = countryCodeFromText(
                proxy['name']?.toString() ?? '',
                proxy['server']?.toString() ?? '',
              ) ??
              ''
          ..network = proxy['network']?.toString() ?? ''
          ..security = proxy['tls'] == true ? 'tls' : ''
          ..rawYaml = mergeService.encodeRawProxy(proxy)
          ..updatedAt = DateTime.now();
        await isar.vpnNodes.put(node);
      }

      final selected =
          await isar.vpnNodes.filter().isSelectedEqualTo(true).findFirst();
      if (selected == null) {
        final firstNode = await isar.vpnNodes
            .filter()
            .profileIdEqualTo(profileId)
            .findFirst();
        if (firstNode != null) {
          firstNode.isSelected = true;
          await isar.vpnNodes.put(firstNode);
        }
      }
    });

    return profile;
  }

  Map<String, int> _parseUserInfo(String? header) {
    final result = <String, int>{};
    for (final part in (header ?? '').split(';')) {
      final pieces = part.split('=');
      if (pieces.length != 2) {
        continue;
      }
      result[pieces.first.trim()] = int.tryParse(pieces.last.trim()) ?? 0;
    }
    return result;
  }

  String? _decodeProfileTitle(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.startsWith('base64:')) {
      return utf8.decode(base64Decode(value.substring(7)));
    }
    return Uri.decodeComponent(value);
  }

  String? _filenameTitle(String? contentDisposition) {
    final value = contentDisposition;
    if (value == null) {
      return null;
    }
    final match = RegExp('filename="?([^";]+)"?').firstMatch(value);
    return match?.group(1);
  }
}
