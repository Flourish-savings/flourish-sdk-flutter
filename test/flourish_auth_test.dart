import 'package:flutter_test/flutter_test.dart';
import 'package:flourish_flutter_sdk/config/environment_enum.dart';
import 'package:flourish_flutter_sdk/config/language.dart';
import 'package:flourish_flutter_sdk/events/event.dart';
import 'package:flourish_flutter_sdk/events/types/generic_event.dart';
import 'package:flourish_flutter_sdk/flourish.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers/test_doubles.dart';

void main() {
  late MockApiService service;

  setUp(() {
    service = MockApiService();
  });

  void stubAuthSuccess({String token = 'T', String url = 'host'}) {
    when(() => service.authenticate(
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
            ))
        .thenAnswer(
            (_) async => authResponse({'session_token': token, 'url': url}));
  }

  group('Flourish.authenticate', () {
    test('sets token and url from the auth response', () async {
      stubAuthSuccess(token: 'session-1', url: 'platform-stg.flourishfi.com');
      final flourish = await flourishWithMockService(service);

      expect(flourish.token, 'session-1');
      expect(flourish.url, 'platform-stg.flourishfi.com');
      expect(flourish.isTokenValid, isTrue);
    });

    test('forwards uuid, secret, customerCode and language code', () async {
      stubAuthSuccess();
      await flourishWithMockService(service, language: Language.portugues);

      verify(() => service.authenticate('u', 's', 'c', '', 'pt', any()))
          .called(1);
    });

    test('on DioException returns "" and emits AUTHENTICATION_FAILURE',
        () async {
      stubAuthSuccess();
      final flourish = await flourishWithMockService(service);

      // Re-stub to fail, then drive authenticate directly so we can observe
      // the event (the create-time call already completed).
      when(() => service.authenticate(
                any(),
                any(),
                any(),
                any(),
                any(),
                any(),
              ))
          .thenThrow(dioError());

      final events = <Event>[];
      flourish.onEvent.listen(events.add);

      final result = await flourish.authenticate(customerCode: 'c');
      await Future<void>.delayed(Duration.zero);

      expect(result, '');
      expect(events.single, isA<GenericEvent>());
      expect((events.single as GenericEvent).name,
          Event.AUTHENTICATION_FAILURE);
    });
  });

  group('Flourish.refreshToken', () {
    test('re-authenticates and updates the token', () async {
      stubAuthSuccess(token: 'first');
      final flourish = await flourishWithMockService(service);
      expect(flourish.token, 'first');

      stubAuthSuccess(token: 'second');
      final refreshed = await flourish.refreshToken();

      expect(refreshed, 'second');
      expect(flourish.token, 'second');
    });
  });

  group('Flourish.isTokenValid', () {
    test('is false for an empty token and true otherwise', () async {
      stubAuthSuccess(token: 'x');
      final flourish = await flourishWithMockService(service);

      expect(flourish.isTokenValid, isTrue);
      flourish.token = '';
      expect(flourish.isTokenValid, isFalse);
    });
  });

  group('Flourish debug static token', () {
    test('skips the backend and uses the provided token', () async {
      final flourish = await flourishWithStaticToken(token: 'local-token');
      expect(flourish.token, 'local-token');
    });

    test('debug base URL rewrites url and selects scheme', () async {
      final flourish = await Flourish.create(
        uuid: 'u',
        secret: 's',
        env: Environment.development,
        language: Language.english,
        customerCode: 'c',
        debugStaticToken: 'tok',
        debugBaseUrl: 'http://localhost:5173',
      );
      expect(flourish.url, 'localhost:5173');
      expect(flourish.useHttp, isTrue);
    });
  });
}
