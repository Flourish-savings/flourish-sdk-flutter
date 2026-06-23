import 'package:flutter_test/flutter_test.dart';
import 'package:flourish_flutter_sdk/config/endpoint.dart';
import 'package:flourish_flutter_sdk/config/environment_enum.dart';

void main() {
  group('Endpoint.getBackend', () {
    test('returns the production auth host for production', () {
      expect(Endpoint(Environment.production).getBackend(),
          Uri.https('auth.flourishfi.com', '/api/v3'));
    });

    test('returns the staging auth host for staging', () {
      expect(Endpoint(Environment.staging).getBackend(),
          Uri.https('auth-stg.flourishfi.com', '/api/v3'));
    });

    test('development points at the staging auth host', () {
      expect(Endpoint(Environment.development).getBackend(),
          Uri.https('auth-stg.flourishfi.com', '/api/v3'));
    });

    test('falls back to staging for an unmapped environment', () {
      // preproduction has no entry in the backend map.
      expect(Endpoint(Environment.preproduction).getBackend(),
          Uri.https('auth-stg.flourishfi.com', '/api/v3'));
    });
  });

  group('Endpoint frontend URLs', () {
    test('getFrontendV3 returns the production platform host', () {
      expect(Endpoint(Environment.production).getFrontendV3(),
          Uri.https('platform.flourishfi.com'));
    });

    test('getFrontendV2 returns the production app host', () {
      expect(Endpoint(Environment.production).getFrontendV2(),
          Uri.https('flourish-app.flourishfi.com'));
    });

    test('getFrontendV3 falls back to staging for an unmapped environment', () {
      expect(Endpoint(Environment.preproduction).getFrontendV3(),
          Uri.https('platform-stg.flourishfi.com'));
    });
  });
}
