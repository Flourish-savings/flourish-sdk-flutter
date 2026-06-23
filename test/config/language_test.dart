import 'package:flutter_test/flutter_test.dart';
import 'package:flourish_flutter_sdk/config/language.dart';
import 'package:flourish_flutter_sdk/config/environment_enum.dart';

void main() {
  group('Language.code', () {
    test('maps each language to its ISO code', () {
      expect(Language.spanish.code, 'es');
      expect(Language.english.code, 'en');
      expect(Language.portugues.code, 'pt');
    });
  });

  group('Environment.toEnvValue', () {
    test('upper-cases the enum name', () {
      expect(Environment.development.toEnvValue(), 'DEVELOPMENT');
      expect(Environment.production.toEnvValue(), 'PRODUCTION');
      expect(Environment.preproduction.toEnvValue(), 'PREPRODUCTION');
    });
  });
}
