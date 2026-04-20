const defaultRedactedObservabilityKeys = <String>{
  'authorization',
  'basic',
  'bearer',
  'cookie',
  'set-cookie',
  'token',
  'access_token',
  'refresh_token',
  'api_key',
  'x-api-key',
  'password',
  'secret',
  'client_secret',
  'session',
  'session_id',
};

class RedactionPolicy {
  const RedactionPolicy({
    this.redactedKeys = defaultRedactedObservabilityKeys,
  });

  static final RegExp _uuidPattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    caseSensitive: false,
  );
  static final RegExp _opaqueSegmentPattern = RegExp(
    r'^[A-Za-z0-9_-]{24,}$',
  );
  static final RegExp _bearerPattern = RegExp(
    r'bearer\s+[A-Za-z0-9\-._~+/]+=*',
    caseSensitive: false,
  );
  static final RegExp _basicPattern = RegExp(
    r'basic\s+[A-Za-z0-9+/=]+',
    caseSensitive: false,
  );
  static final RegExp _credentialPattern = RegExp(
    r'\b(authorization|token|access_token|refresh_token|api[_-]?key|x-api-key|password|secret|client_secret|session(?:_id)?|cookie|set-cookie)\b(?:\s*[:=]\s*|\s+)([^&\s,;]+)',
    caseSensitive: false,
  );

  final Set<String> redactedKeys;

  Map<String, dynamic> sanitizeMap(Map<String, Object?> values) {
    return values.map((key, value) {
      return MapEntry(key, _sanitizeValue(key, value));
    });
  }

  List<String> sanitizeKeys(Iterable<Object?> keys) {
    return keys
        .map((key) => key.toString())
        .map((key) => _shouldRedact(key) ? '[redacted]' : key)
        .toSet()
        .toList(growable: false)
      ..sort();
  }

  String sanitizePath(String path) {
    final withoutQuery = path.split('?').first;
    final segments = withoutQuery.split('/').map((segment) {
      if (segment.isEmpty) {
        return segment;
      }

      final decoded = Uri.decodeComponent(segment);
      if (int.tryParse(decoded) != null ||
          _uuidPattern.hasMatch(decoded) ||
          decoded.contains('@') ||
          _opaqueSegmentPattern.hasMatch(decoded)) {
        return ':id';
      }
      return decoded;
    }).toList(growable: false);
    return segments.join('/');
  }

  String summarizeObject(Object? value, {int maxLength = 160}) {
    return sanitizeText(value?.toString() ?? 'null', maxLength: maxLength);
  }

  String sanitizeText(String value, {int maxLength = 240}) {
    var sanitized = value.trim();
    sanitized = sanitized.replaceAll(_bearerPattern, 'Bearer [redacted]');
    sanitized = sanitized.replaceAll(_basicPattern, 'Basic [redacted]');
    sanitized = sanitized.replaceAllMapped(_credentialPattern, (match) {
      return '${match.group(1)}=[redacted]';
    });
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');
    if (sanitized.length > maxLength) {
      return '${sanitized.substring(0, maxLength)}...';
    }
    return sanitized;
  }

  dynamic _sanitizeValue(String key, Object? value) {
    if (_shouldRedact(key)) {
      return '[redacted]';
    }
    if (value is String) {
      return sanitizeText(value, maxLength: _shouldSummarize(key) ? 160 : 240);
    }
    if (value is Map) {
      return sanitizeMap(
        value.map(
          (nestedKey, nestedValue) => MapEntry(
            nestedKey.toString(),
            nestedValue,
          ),
        ),
      );
    }
    if (value is Iterable) {
      return value
          .map((entry) => _sanitizeValue(key, entry))
          .toList(growable: false);
    }
    return value;
  }

  bool _shouldRedact(String key) {
    final normalized = key.trim().toLowerCase();
    return redactedKeys.any(
      (blocked) => normalized == blocked || normalized.contains(blocked),
    );
  }

  bool _shouldSummarize(String key) {
    final normalized = key.trim().toLowerCase();
    return normalized.contains('error') ||
        normalized.contains('message') ||
        normalized.contains('stack') ||
        normalized.contains('reason');
  }
}
