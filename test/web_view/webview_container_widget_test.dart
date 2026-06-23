import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flourish_flutter_sdk/config/environment_enum.dart';
import 'package:flourish_flutter_sdk/config/language.dart';
import 'package:flourish_flutter_sdk/events/event.dart';
import 'package:flourish_flutter_sdk/events/types/generic_event.dart';
import 'package:flourish_flutter_sdk/events/types/v2/open_external_url_event.dart';
import 'package:flourish_flutter_sdk/flourish.dart';
import 'package:flourish_flutter_sdk/web_view/auth_error_page.dart';
import 'package:flourish_flutter_sdk/web_view/flourish_token_error_page.dart';
import 'package:flourish_flutter_sdk/web_view/webview_container.dart';
import 'package:mocktail/mocktail.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import '../helpers/fake_webview_platform.dart';
import '../helpers/test_doubles.dart';

void main() {
  setUp(() {
    WebViewPlatform.instance = FakeWebViewPlatform();
    FakeWebViewController.lastOnMessageReceived = null;
    // share_plus has no platform implementation under test; stub its channel
    // so _handleReferralCopy's Share.share(...) doesn't throw.
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('dev.fluttercommunity.plus/share'),
            (_) async => null);
  });

  // Mounts the WebView container via flourish.home() (which wires every
  // constructor argument) and returns its State for driving handlers.
  // The handlers are invoked with unawaited(...) — exactly as production does —
  // because their navigation (Navigator.pushReplacement) returns a Future that
  // only completes when the pushed route is later popped.
  Future<WebviewContainerState> mount(
      WidgetTester tester, Flourish flourish) async {
    await tester.pumpWidget(MaterialApp(home: flourish.home()));
    await tester.pump();
    return tester.state<WebviewContainerState>(find.byType(WebviewContainer));
  }

  group('handleWebAppError', () {
    testWidgets('always publishes the ErrorEvent and navigates to the '
        'token error page when no callback is set', (tester) async {
      final flourish = await flourishWithStaticToken(token: 't');
      final events = <Event>[];
      flourish.onEvent.listen(events.add);

      final state = await mount(tester, flourish);
      unawaited(state.handleWebAppError({
        'data': {'code': 'E1', 'message': 'boom'}
      }));
      await tester.pumpAndSettle();

      expect(events.whereType<ErrorEvent>(), hasLength(1));
      expect(find.byType(FlourishTokenErrorPage), findsOneWidget);
    });

    testWidgets('publishes the ErrorEvent and invokes onError without '
        'navigating when a callback is set', (tester) async {
      ErrorEvent? received;
      final flourish = await Flourish.create(
        uuid: 'u',
        secret: 's',
        env: Environment.development,
        language: Language.english,
        customerCode: 'c',
        debugStaticToken: 't',
        onError: (_, e) => received = e,
      );
      final events = <Event>[];
      flourish.onEvent.listen(events.add);

      final state = await mount(tester, flourish);
      unawaited(state.handleWebAppError({
        'data': {'code': 'E2'}
      }));
      await tester.pumpAndSettle();

      expect(events.whereType<ErrorEvent>(), hasLength(1));
      expect(received?.code, 'E2');
      expect(find.byType(FlourishTokenErrorPage), findsNothing);
    });
  });

  group('handleAuthError', () {
    testWidgets('navigates to AuthErrorPage when no callback is set',
        (tester) async {
      // AuthErrorPage auto-refreshes in initState and navigates to home() on
      // success, so back the container with a mock whose refresh fails hard
      // (a non-Dio throw propagates out of authenticate -> refreshToken, and
      // AuthErrorPage's own catch swallows it) — keeping the page on screen.
      final service = MockApiService();
      when(() => service.authenticate(
              any(), any(), any(), any(), any(), any()))
          .thenAnswer((_) async => authResponse({
                'session_token': 't',
                'url': 'h',
              }));
      final flourish = await flourishWithMockService(service);
      when(() => service.authenticate(
              any(), any(), any(), any(), any(), any()))
          .thenThrow(Exception('refresh blocked'));

      final state = await mount(tester, flourish);

      unawaited(state.handleAuthError());
      // AuthErrorPage shows an infinite SpinKit animation, so pumpAndSettle
      // would never return — advance finite frames past the route transition.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(AuthErrorPage), findsOneWidget);
    });

    testWidgets('invokes onAuthError without navigating when set',
        (tester) async {
      var called = false;
      final flourish = await Flourish.create(
        uuid: 'u',
        secret: 's',
        env: Environment.development,
        language: Language.english,
        customerCode: 'c',
        debugStaticToken: 't',
        onAuthError: (_) => called = true,
      );
      final state = await mount(tester, flourish);

      unawaited(state.handleAuthError());
      await tester.pumpAndSettle();

      expect(called, isTrue);
      expect(find.byType(AuthErrorPage), findsNothing);
    });
  });

  group('handleLoadingPageError', () {
    testWidgets('a 403 navigates to the token error page', (tester) async {
      final flourish = await flourishWithStaticToken(token: 't');
      final state = await mount(tester, flourish);

      unawaited(state.handleLoadingPageError(
        WebResourceError(errorCode: 403, description: 'forbidden'),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(FlourishTokenErrorPage), findsOneWidget);
    });
  });

  group('JS channel messages', () {
    // Drives _handleJavaScriptMessage through the captured channel callback,
    // exercising the private handlers end-to-end.
    Future<List<Event>> fire(WidgetTester tester, Flourish flourish,
        Map<String, dynamic> payload) async {
      final events = <Event>[];
      flourish.onEvent.listen(events.add);
      await mount(tester, flourish);
      FakeWebViewController.lastOnMessageReceived!
          .call(JavaScriptMessage(message: jsonEncode(payload)));
      await tester.pump();
      return events;
    }

    testWidgets('OPEN_EXTERNAL_URL publishes the event for a valid url',
        (tester) async {
      final flourish = await flourishWithStaticToken();
      final events = await fire(tester, flourish, {
        'eventName': 'OPEN_EXTERNAL_URL',
        'data': {'url': 'https://store.example.com'}
      });
      expect(events.whereType<OpenExternalUrlEvent>(), hasLength(1));
    });

    testWidgets('OPEN_EXTERNAL_URL ignores an empty url', (tester) async {
      final flourish = await flourishWithStaticToken();
      final events = await fire(tester, flourish, {
        'eventName': 'OPEN_EXTERNAL_URL',
        'data': {'url': ''}
      });
      expect(events.whereType<OpenExternalUrlEvent>(), isEmpty);
    });

    testWidgets('REFERRAL_COPY with a code runs without error', (tester) async {
      final flourish = await flourishWithStaticToken();
      await fire(tester, flourish, {
        'eventName': 'REFERRAL_COPY',
        'data': {'referralCode': 'CODE-1'}
      });
      expect(tester.takeException(), isNull);
    });

    testWidgets('REFERRAL_COPY with a null code is a no-op', (tester) async {
      final flourish = await flourishWithStaticToken();
      await fire(tester, flourish, {
        'eventName': 'REFERRAL_COPY',
        'data': <String, dynamic>{}
      });
      expect(tester.takeException(), isNull);
    });

    testWidgets('an unknown eventName publishes a GenericEvent',
        (tester) async {
      final flourish = await flourishWithStaticToken();
      final events = await fire(
          tester, flourish, {'eventName': 'BRAND_NEW_THING', 'data': 'x'});
      expect(events.whereType<GenericEvent>(), hasLength(1));
    });

    testWidgets('a malformed message is caught and does not crash',
        (tester) async {
      final flourish = await flourishWithStaticToken();
      flourish.onEvent.listen((_) {});
      await mount(tester, flourish);
      FakeWebViewController.lastOnMessageReceived!
          .call(const JavaScriptMessage(message: 'not json{'));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
