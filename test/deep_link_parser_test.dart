import 'package:flutter_test/flutter_test.dart';
import 'package:siegeconnect/features/deeplink/application/deep_link_parser.dart';

void main() {
  group('DeepLinkParser', () {
    test('extracts an encoded Happ subscription url', () {
      final url = DeepLinkParser.extractSubscriptionUrl(
        'happ://add/https%3A%2F%2Fexample.com%2Fsub%3Ftoken%3Dabc%26name%3Dmain',
      );

      expect(url, 'https://example.com/sub?token=abc&name=main');
    });

    test('keeps query parameters from an unencoded nested url', () {
      final url = DeepLinkParser.extractSubscriptionUrl(
        'happ://add/https://example.com/sub?token=abc&name=main',
      );

      expect(url, 'https://example.com/sub?token=abc&name=main');
    });

    test('supports query payloads and the SiegeConnect scheme', () {
      final url = DeepLinkParser.extractSubscriptionUrl(
        'siegeconnect://add?url=https%3A%2F%2Fexample.org%2Fvpn',
      );

      expect(url, 'https://example.org/vpn');
    });

    test('rejects unsupported links', () {
      expect(DeepLinkParser.extractSubscriptionUrl('happ://open/settings'),
          isNull);
      expect(DeepLinkParser.extractSubscriptionUrl('ftp://example.com/sub'),
          isNull);
    });
  });
}
