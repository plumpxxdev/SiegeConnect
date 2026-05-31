import 'package:flutter_test/flutter_test.dart';
import 'package:siegeconnect/shared/countries.dart';

void main() {
  test('converts unicode regional flag prefix to country code', () {
    expect(countryCodeFromText('🇫🇮 direct by Eversiege'), 'FI');
    expect(countryCodeFromText('🇬🇧 GB direct'), 'GB');
    expect(countryCodeFromText('🇬🇪 direct by plumpxx'), 'GE');
  });

  test('treats subscription GE prefix on Frankfurt nodes as Germany', () {
    expect(
        countryCodeFromText('GE direct by plumpxx', 'ge.fra.node.test'), 'DE');
    expect(countryCodeFromText('GE direct by plumpxx'), 'DE');
  });

  test('cleans emoji and ascii country prefixes from node names', () {
    expect(cleanNodeName('🇫🇮 FI direct by Eversiege'), 'direct by Eversiege');
    expect(cleanNodeName('DE direct by plumpxx'), 'direct by plumpxx');
    expect(cleanNodeName('direct by Eversiege'), 'direct by Eversiege');
    expect(cleanNodeName('BY via de by fayzetwin'), 'via de by fayzetwin');
  });
}
