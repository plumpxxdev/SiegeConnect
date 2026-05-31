import 'dart:convert';

import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';

import '../../../core/constants/app_constants.dart';

class MihomoYamlMergeService {
  const MihomoYamlMergeService();

  static const russianBypassRules = <String>[
    'DOMAIN-SUFFIX,ru,DIRECT',
    'GEOIP,RU,DIRECT,no-resolve',
  ];

  String buildMergedConfig(
    String originalYaml, {
    bool bypassRussia = true,
    bool enableTun = true,
    bool killSwitch = true,
    String? preferredProxyName,
  }) {
    final loaded = loadYaml(originalYaml);
    if (loaded is! YamlMap) {
      throw FormatException('Subscription is not a Clash YAML map');
    }

    final config = _toDartMap(loaded);
    final proxyGroupName = _ensureProxyGroup(
      config,
      preferredProxyName: preferredProxyName,
    );

    config['mode'] = 'rule';
    config['allow-lan'] = false;
    config['ipv6'] = false;
    config['log-level'] = 'info';
    config['mixed-port'] = AppConstants.mixedProxyPort;
    config['external-controller'] = AppConstants.controllerAddress;
    config['secret'] = '';

    if (enableTun) {
      config['tun'] = <String, Object?>{
        'enable': true,
        'stack': 'mixed',
        'auto-route': true,
        'auto-detect-interface': true,
        'strict-route': killSwitch,
        'dns-hijack': <String>['any:53'],
      };
    } else {
      config.remove('tun');
    }

    config['rules'] = <String>[
      if (bypassRussia) ...russianBypassRules,
      'MATCH,$proxyGroupName',
    ];

    return YamlWriter().write(config);
  }

  List<Map<String, Object?>> extractProxyNodes(String yaml) {
    final loaded = loadYaml(yaml);
    if (loaded is! YamlMap) {
      return const [];
    }

    final proxies = loaded['proxies'];
    if (proxies is! YamlList) {
      return const [];
    }

    return proxies
        .whereType<YamlMap>()
        .map(_toDartMap)
        .map((proxy) => proxy.cast<String, Object?>())
        .toList(growable: false);
  }

  String encodeRawProxy(Map<String, Object?> proxy) {
    return jsonEncode(proxy);
  }

  String _ensureProxyGroup(
    Map<String, Object?> config, {
    String? preferredProxyName,
  }) {
    final proxyNames = _preferProxy(
        (config['proxies'] is List ? config['proxies'] as List : const [])
            .whereType<Map>()
            .map((proxy) => proxy['name'])
            .whereType<String>()
            .toList(growable: false),
        preferredProxyName);
    final proxies = proxyNames.isEmpty ? <String>['DIRECT'] : proxyNames;
    final groups = config['proxy-groups'];
    if (groups is List) {
      final nextGroups =
          groups.whereType<Map>().map((group) => Map.of(group)).toList();
      final index = nextGroups.indexWhere(
        (group) => group['name'] == AppConstants.proxyGroupName,
      );
      final proxyGroup = <String, Object?>{
        'name': AppConstants.proxyGroupName,
        'type': 'select',
        'proxies': proxies,
      };
      if (index >= 0) {
        nextGroups[index] = <String, Object?>{
          ...nextGroups[index],
          ...proxyGroup,
        };
      } else {
        nextGroups.insert(0, proxyGroup);
      }
      config['proxy-groups'] = nextGroups;
      return AppConstants.proxyGroupName;
    }

    config['proxy-groups'] = <Map<String, Object?>>[
      <String, Object?>{
        'name': AppConstants.proxyGroupName,
        'type': 'select',
        'proxies': proxies,
      },
    ];

    return AppConstants.proxyGroupName;
  }

  List<String> _preferProxy(List<String> names, String? preferredProxyName) {
    if (preferredProxyName == null || !names.contains(preferredProxyName)) {
      return names;
    }
    return <String>[
      preferredProxyName,
      ...names.where((name) => name != preferredProxyName),
    ];
  }

  static Object? _toDartValue(Object? value) {
    if (value is YamlMap) {
      return _toDartMap(value);
    }
    if (value is YamlList) {
      return value.map(_toDartValue).toList(growable: true);
    }
    return value;
  }

  static Map<String, Object?> _toDartMap(YamlMap map) {
    return map.nodes.map(
      (key, value) => MapEntry(
        key.value.toString(),
        _toDartValue(value.value),
      ),
    );
  }
}
