import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flourish_flutter_sdk/config/environment_enum.dart';
import 'package:flourish_flutter_sdk/config/language.dart';
import 'package:flourish_flutter_sdk/events/event.dart';
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
}
