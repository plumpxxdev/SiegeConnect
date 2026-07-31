class DeepLinkParser {
  const DeepLinkParser._();

  static const supportedSchemes = <String>{
    'siegeconnect',
  };

  static String? extractSubscriptionUrl(String rawLink) {
    final raw = rawLink.trim();
    if (raw.isEmpty) {
      return null;
    }

    final directUrl = _normaliseSubscriptionUrl(raw);
    if (directUrl != null) {
      return directUrl;
    }

    for (final scheme in supportedSchemes) {
      for (final prefix in <String>[
        '$scheme://add/',
        '$scheme://add?url=',
        '$scheme://add?subscription=',
        '$scheme://add?sub=',
      ]) {
        if (raw.toLowerCase().startsWith(prefix)) {
          return _normaliseSubscriptionUrl(raw.substring(prefix.length));
        }
      }
    }

    final uri = Uri.tryParse(raw);
    if (uri == null || !supportedSchemes.contains(uri.scheme.toLowerCase())) {
      return null;
    }
    if (uri.host.toLowerCase() != 'add' &&
        (uri.pathSegments.isEmpty ||
            uri.pathSegments.first.toLowerCase() != 'add')) {
      return null;
    }

    for (final key in const <String>['url', 'subscription', 'sub']) {
      final value = uri.queryParameters[key];
      final parsed = value == null ? null : _normaliseSubscriptionUrl(value);
      if (parsed != null) {
        return parsed;
      }
    }

    final pathPayload = uri.host.toLowerCase() == 'add'
        ? (uri.path.startsWith('/') ? uri.path.substring(1) : uri.path)
        : uri.pathSegments.skip(1).join('/');
    if (pathPayload.isEmpty) {
      return null;
    }

    final withQuery = uri.hasQuery ? '$pathPayload?${uri.query}' : pathPayload;
    return _normaliseSubscriptionUrl(withQuery);
  }

  static String? _normaliseSubscriptionUrl(String value) {
    var candidate = value.trim();
    if (candidate.startsWith('{{') && candidate.endsWith('}}')) {
      candidate = candidate.substring(2, candidate.length - 2).trim();
    }
    if (candidate.isEmpty) {
      return null;
    }

    for (var i = 0; i < 2; i++) {
      if (_looksLikeWebUrl(candidate)) {
        break;
      }
      final String decoded;
      try {
        decoded = Uri.decodeFull(candidate);
      } on FormatException {
        break;
      }
      if (decoded == candidate) {
        break;
      }
      candidate = decoded;
    }

    if (candidate.startsWith('/')) {
      candidate = candidate.substring(1);
    }

    final uri = Uri.tryParse(candidate);
    if (uri == null ||
        (uri.scheme.toLowerCase() != 'http' &&
            uri.scheme.toLowerCase() != 'https') ||
        uri.host.isEmpty) {
      return null;
    }

    return candidate;
  }

  static bool _looksLikeWebUrl(String value) {
    final lower = value.toLowerCase();
    return lower.startsWith('https://') || lower.startsWith('http://');
  }
}
