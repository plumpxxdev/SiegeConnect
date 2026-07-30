import 'package:flutter_test/flutter_test.dart';
import 'package:siegeconnect/features/mihomo/application/yaml_merge_service.dart';

void main() {
  test('injects Russian direct rules and keeps a proxy group', () {
    const original = '''
proxies:
  - name: DE direct
    type: hysteria2
    server: example.com
    port: 443
proxy-groups:
  - name: PROXY
    type: select
    proxies:
      - DE direct
rules:
  - MATCH,PROXY
''';

    final merged = const MihomoYamlMergeService().buildMergedConfig(original);

    expect(merged, contains('DOMAIN-SUFFIX,2ip.ru,PROXY'));
    expect(
      merged.indexOf('DOMAIN-SUFFIX,2ip.ru,PROXY'),
      lessThan(merged.indexOf('DOMAIN-SUFFIX,ru,DIRECT')),
    );
    expect(merged, contains('DOMAIN-SUFFIX,ru,DIRECT'));
    expect(merged, contains('GEOIP,RU,DIRECT,no-resolve'));
    expect(merged, contains('MATCH,PROXY'));
    expect(merged, contains('mixed-port: 7890'));
    expect(merged, contains('strict-route'));
    expect(merged, contains('dns:'));
    expect(merged, contains('enhanced-mode: "fake-ip"'));
    expect(merged, contains('listen: "127.0.0.1:1053"'));
    expect(merged, contains('proxy-server-nameserver:'));
  });

  test('proxy mode removes tun block', () {
    const original = '''
proxies:
  - name: DE direct
    type: hysteria2
    server: example.com
    port: 443
tun:
  enable: true
rules:
  - MATCH,PROXY
''';

    final merged = const MihomoYamlMergeService().buildMergedConfig(
      original,
      enableTun: false,
    );

    expect(merged, isNot(contains('tun:')));
    expect(merged, contains('mixed-port: 7890'));
    expect(merged, contains('enhanced-mode: "redir-host"'));
  });

  test('extracts proxy nodes from subscription yaml', () {
    const original = '''
proxies:
  - name: FI direct
    type: vless
    server: node.example
    port: 8443
''';

    final nodes = const MihomoYamlMergeService().extractProxyNodes(original);

    expect(nodes, hasLength(1));
    expect(nodes.first['name'], 'FI direct');
    expect(nodes.first['type'], 'vless');
  });
}
