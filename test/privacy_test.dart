import 'package:flutter_test/flutter_test.dart';
import 'package:siegeconnect/shared/privacy.dart';

void main() {
  test('redacts IP addresses and endpoint domains', () {
    expect(redactNetworkText('95.216.8.160:8443'), '•••');
    expect(redactNetworkText('ge.fra.node.example.top:443'), '•••');
    expect(redactNetworkText('https://example.com/sub/path'), '•••');
  });

  test('does not redact local file names as domains', () {
    expect(redactNetworkText('mihomo.exe рядом с siegeconnect.exe'),
        'mihomo.exe рядом с siegeconnect.exe');
  });
}
