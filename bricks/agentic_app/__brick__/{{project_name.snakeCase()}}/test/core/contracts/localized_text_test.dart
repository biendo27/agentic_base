import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name.snakeCase()}}/core/contracts/localized_text.dart';

void main() {
  test('returns an exact locale match first', () {
    const text = LocalizedText(
      values: <String, String>{
        'en': 'Hello',
        'vi': 'Xin chao',
      },
    );

    expect(text.valueFor('vi'), 'Xin chao');
  });

  test(
    'falls back from region tags to language codes and explicit fallbacks',
    () {
      const text = LocalizedText(
        values: <String, String>{
          'en': 'Hello',
          'fr': 'Bonjour',
        },
      );

      expect(text.valueFor('en-US'), 'Hello');
      expect(text.valueFor('vi', fallbacks: <String>['fr', 'en']), 'Bonjour');
    },
  );

  test('round-trips the flat locale map shape', () {
    final text = LocalizedText.fromJson(
      <String, Object?>{
        'en': 'Hello',
        'vi': 'Xin chao',
      },
    );

    expect(
      text.toJson(),
      <String, Object?>{
        'en': 'Hello',
        'vi': 'Xin chao',
      },
    );
  });
}
