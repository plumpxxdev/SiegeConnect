const knownCountryCodes = <String>{
  'AD',
  'AE',
  'AF',
  'AL',
  'AM',
  'AR',
  'AT',
  'AU',
  'AZ',
  'BA',
  'BE',
  'BG',
  'BH',
  'BR',
  'BY',
  'CA',
  'CH',
  'CN',
  'CZ',
  'DE',
  'DK',
  'EE',
  'ES',
  'FI',
  'FR',
  'GB',
  'GE',
  'GR',
  'HK',
  'HR',
  'HU',
  'ID',
  'IE',
  'IL',
  'IN',
  'IR',
  'IS',
  'IT',
  'JP',
  'KR',
  'KZ',
  'LT',
  'LU',
  'LV',
  'MD',
  'MX',
  'MY',
  'NL',
  'NO',
  'PL',
  'PT',
  'RO',
  'RS',
  'RU',
  'SE',
  'SG',
  'TH',
  'TR',
  'TW',
  'UA',
  'UK',
  'US',
  'VN',
};

const _countryHints = <String, String>{
  'finland': 'FI',
  'helsinki': 'FI',
  'suomi': 'FI',
  'germany': 'DE',
  'deutschland': 'DE',
  'frankfurt': 'DE',
  'russia': 'RU',
  'moscow': 'RU',
  'japan': 'JP',
  'tokyo': 'JP',
  'canada': 'CA',
  'toronto': 'CA',
  'netherlands': 'NL',
  'amsterdam': 'NL',
  'singapore': 'SG',
  'sweden': 'SE',
  'stockholm': 'SE',
  'france': 'FR',
  'paris': 'FR',
  'poland': 'PL',
  'warsaw': 'PL',
  'bulgaria': 'BG',
  'sofia': 'BG',
  'belarus': 'BY',
  'georgia': 'GE',
  'tbilisi': 'GE',
  'united states': 'US',
  'usa': 'US',
  'united kingdom': 'GB',
  'great britain': 'GB',
  'britain': 'GB',
  'london': 'GB',
};

String? normalizeCountryCode(String? value) {
  final code = value?.trim().toUpperCase();
  if (code == null || code.isEmpty) {
    return null;
  }
  final normalized = code == 'UK' ? 'GB' : code;
  return knownCountryCodes.contains(normalized) ? normalized : null;
}

String? countryCodeFromText(String name, [String server = '']) {
  final emojiCode = countryCodeFromFlagEmoji(name);
  if (emojiCode != null) {
    return emojiCode;
  }

  final prefix =
      RegExp(r'^\s*[\[(]?([A-Za-z]{2}|UK)(?=$|[\s\])(_.-])').firstMatch(name);
  final fromPrefix = _normalizeSubscriptionPrefix(
    prefix?.group(1),
    name,
    server,
  );
  if (fromPrefix != null) {
    return fromPrefix;
  }

  final text = '$name $server'.toLowerCase();
  for (final entry in _countryHints.entries) {
    if (text.contains(entry.key)) {
      return entry.value;
    }
  }

  final domainPrefix = RegExp(r'\b([A-Za-z]{2})[-.]').firstMatch(server);
  return _normalizeSubscriptionPrefix(domainPrefix?.group(1), name, server);
}

String? countryCodeFromFlagEmoji(String text) {
  final runes = text.runes.toList(growable: false);
  for (var index = 0; index < runes.length - 1; index++) {
    final first = runes[index];
    final second = runes[index + 1];
    if (_isRegionalIndicator(first) && _isRegionalIndicator(second)) {
      final codeUnits = <int>[
        0x41 + first - 0x1F1E6,
        0x41 + second - 0x1F1E6,
      ];
      return normalizeCountryCode(String.fromCharCodes(codeUnits));
    }
  }
  return null;
}

String cleanNodeName(String name) {
  final withoutEmoji = name.replaceFirst(
    RegExp(r'^\s*(?:[\u{1F1E6}-\u{1F1FF}]{2}\s*)+', unicode: true),
    '',
  );
  final withoutCode = _removeLeadingCountryCode(withoutEmoji);
  final cleaned = withoutCode.trim();
  return cleaned.isEmpty ? name.trim() : cleaned;
}

String? countryFlagUrl(String? code, {int width = 80}) {
  final normalized = normalizeCountryCode(code);
  if (normalized == null) {
    return null;
  }
  return 'https://flagcdn.com/w$width/${normalized.toLowerCase()}.png';
}

String? countryFlagEmoji(String? code) {
  final normalized = normalizeCountryCode(code);
  if (normalized == null) {
    return null;
  }
  final letters = normalized.runes.toList(growable: false);
  if (letters.length != 2) {
    return null;
  }
  return String.fromCharCodes([
    0x1F1E6 + letters[0] - 0x41,
    0x1F1E6 + letters[1] - 0x41,
  ]);
}

bool _isRegionalIndicator(int rune) {
  return rune >= 0x1F1E6 && rune <= 0x1F1FF;
}

String? _normalizeSubscriptionPrefix(
  String? value,
  String name,
  String server,
) {
  final raw = value?.trim().toUpperCase();
  if (raw == null || raw.isEmpty) {
    return null;
  }

  final text = '$name $server'.toLowerCase();
  if (raw == 'GE') {
    if (text.contains('georgia') || text.contains('tbilisi')) {
      return 'GE';
    }
    return 'DE';
  }

  return normalizeCountryCode(raw);
}

String _removeLeadingCountryCode(String value) {
  final match = RegExp(r'^\s*[\[(]?([A-Za-z]{2}|UK)[\])]?(?=$|[\s\])(_.\-:|])')
      .firstMatch(value);
  final code = normalizeCountryCode(match?.group(1));
  if (match == null || code == null) {
    return value;
  }

  return value.substring(match.end).replaceFirst(
        RegExp(r'^\s*[-|:_.)\]]?\s*'),
        '',
      );
}
