import 'package:freezed_annotation/freezed_annotation.dart';

part 'localized_text.freezed.dart';

@freezed
abstract class LocalizedText with _$LocalizedText {
  const LocalizedText._();

  const factory LocalizedText({
    @Default(<String, String>{}) Map<String, String> values,
  }) = _LocalizedText;

  factory LocalizedText.fromJson(Map<String, Object?> json) {
    final values = <String, String>{};

    for (final entry in json.entries) {
      final locale = _normalizeLocale(entry.key);
      final text = _readString(entry.value);
      if (locale.isEmpty || text == null) {
        continue;
      }
      values[locale] = text;
    }

    return LocalizedText(values: values);
  }
}

extension LocalizedTextX on LocalizedText {
  bool get isEmpty => values.isEmpty;
  bool get isNotEmpty => values.isNotEmpty;

  String? valueFor(
    String localeTag, {
    Iterable<String> fallbacks = const <String>['en'],
  }) {
    final normalized = _normalizeLocale(localeTag);
    final exact = values[normalized];
    if (exact != null && exact.isNotEmpty) {
      return exact;
    }

    final languageOnly = normalized.split('-').first;
    final languageValue = values[languageOnly];
    if (languageValue != null && languageValue.isNotEmpty) {
      return languageValue;
    }

    for (final fallback in fallbacks) {
      final normalizedFallback = _normalizeLocale(fallback);
      final fallbackValue =
          values[normalizedFallback] ??
          values[normalizedFallback.split('-').first];
      if (fallbackValue != null && fallbackValue.isNotEmpty) {
        return fallbackValue;
      }
    }

    for (final text in values.values) {
      if (text.isNotEmpty) {
        return text;
      }
    }

    return null;
  }

  String valueOrDefault(
    String localeTag, {
    Iterable<String> fallbacks = const <String>['en'],
    String defaultValue = '',
  }) {
    return valueFor(localeTag, fallbacks: fallbacks) ?? defaultValue;
  }

  Map<String, Object?> toJson() => Map<String, Object?>.from(values);
}

String _normalizeLocale(String value) {
  return value.trim().toLowerCase().replaceAll('_', '-');
}

String? _readString(Object? value) {
  if (value is String && value.trim().isNotEmpty) {
    return value.trim();
  }
  return null;
}
