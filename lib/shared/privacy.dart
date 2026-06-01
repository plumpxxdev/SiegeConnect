const _redactedNetworkValue = '•••';

const _fileLikeSuffixes = <String>{
  'apk',
  'bat',
  'cmd',
  'cpp',
  'dart',
  'dll',
  'exe',
  'gz',
  'h',
  'ico',
  'json',
  'log',
  'msi',
  'png',
  'ps1',
  'txt',
  'yaml',
  'yml',
  'zip',
};

final _urlPattern = RegExp(
  r'\b(?:https?|wss?|socks5|hysteria2?)://[^\s<>()]+',
  caseSensitive: false,
);

final _ipv4Pattern = RegExp(
  r'\b(?:\d{1,3}\.){3}\d{1,3}(?::\d{1,5})?\b',
);

final _bracketedIpv6Pattern = RegExp(
  r'\[[0-9a-fA-F:]{3,}\](?::\d{1,5})?',
);

final _domainPattern = RegExp(
  r'(?<!@)\b(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,63}(?::\d{1,5})?(?:/[^\s|,;)]*)?',
);

String redactNetworkText(String value) {
  if (value.isEmpty) {
    return value;
  }

  return value
      .replaceAll(_urlPattern, _redactedNetworkValue)
      .replaceAll(_ipv4Pattern, _redactedNetworkValue)
      .replaceAll(_bracketedIpv6Pattern, _redactedNetworkValue)
      .replaceAllMapped(_domainPattern, (match) {
    final text = match.group(0) ?? '';
    final withoutPath = text.split('/').first;
    final withoutPort = withoutPath.split(':').first;
    final suffix = withoutPort.split('.').last.toLowerCase();
    if (_fileLikeSuffixes.contains(suffix)) {
      return text;
    }
    return _redactedNetworkValue;
  });
}

String redactNetworkTextNullable(String? value, {String fallback = '—'}) {
  if (value == null || value.trim().isEmpty) {
    return fallback;
  }
  return redactNetworkText(value);
}
