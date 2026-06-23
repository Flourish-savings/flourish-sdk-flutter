import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flourish_flutter_sdk/config/language.dart';
import 'package:flourish_flutter_sdk/events/event.dart';
import 'package:flourish_flutter_sdk/events/types/generic_event.dart';
import 'package:flourish_flutter_sdk/web_view/auth_error_page.dart';
import 'package:flourish_flutter_sdk/web_view/flourish_token_error_page.dart';
import 'package:flourish_flutter_sdk/web_view/webview_container.dart';
import 'package:flourish_flutter_sdk/web_view/webview_load_error_page.dart';
import 'package:mocktail/mocktail.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../helpers/fake_webview_platform.dart';
import '../helpers/test_doubles.dart';

void main() {
  setUp(() {
    WebViewPlatform.instance = FakeWebViewPlatform();
  });

  Future<void> pumpPage(WidgetTester tester, Widget page) async {
    await tester.pumpWidget(MaterialApp(home: page));
    await tester.pump();
    // The error pages render an Image.asset / icons whose asset bundle is
    // absent under test; swallow the resulting load error so it doesn't fail
    // the test (the widget tree itself built fine).
    tester.takeException();
  }

  group('FlourishTokenErrorPage', () {
    testWidgets('shows the localized title per language', (tester) async {
      final cases = {
        Language.english: 'Oops, something went wrong!',
        Language.spanish: 'Huy! Algo salió mal.',
        Language.portugues: 'Opa, algo deu errado.',
      };
      for (final entry in cases.entries) {
        final flourish =
            await flourishWithStaticToken(language: entry.key);
        await pumpPage(tester, FlourishTokenErrorPage(flourish: flourish));
        expect(find.text(entry.value), findsOneWidget);
      }
    });

    testWidgets('back button notifies ERROR_BACK_BUTTON_PRESSED',
        (tester) async {
      final flourish = await flourishWithStaticToken();
      final events = <Event>[];
      flourish.onEvent.listen(events.add);

      await pumpPage(tester, FlourishTokenErrorPage(flourish: flourish));
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      expect(events.single, isA<GenericEvent>());
      expect((events.single as GenericEvent).name,
          Event.ERROR_BACK_BUTTON_PRESSED);
    });
  });

  group('WebViewLoadErrorPage', () {
    testWidgets('shows the localized title and retry button', (tester) async {
      final flourish = await flourishWithStaticToken(language: Language.spanish);
      await pumpPage(tester, WebViewLoadErrorPage(flourish: flourish));

      expect(find.textContaining('No hay conexión'), findsOneWidget);
      expect(find.text('Intentar  nuevamente'), findsOneWidget);
      expect(find.byIcon(Icons.signal_wifi_off), findsOneWidget);
    });

    testWidgets('the retry button navigates to a WebviewContainer',
        (tester) async {
      final flourish = await flourishWithStaticToken();
      await pumpPage(tester, WebViewLoadErrorPage(flourish: flourish));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      await tester.pump();

      expect(find.byType(WebviewContainer), findsOneWidget);
    });
  });

  group('AuthErrorPage', () {
    testWidgets('renders the loading message', (tester) async {
      // Back it with a mock whose refresh fails hard so the page does not
      // immediately navigate away (see webview_container_widget_test.dart).
      final service = MockApiService();
      when(() =>
              service.authenticate(any(), any(), any(), any(), any(), any()))
          .thenAnswer(
              (_) async => authResponse({'session_token': 't', 'url': 'h'}));
      final flourish = await flourishWithMockService(service);
      when(() =>
              service.authenticate(any(), any(), any(), any(), any(), any()))
          .thenThrow(Exception('refresh blocked'));

      await tester.pumpWidget(MaterialApp(home: AuthErrorPage(flourish: flourish)));
      // Infinite SpinKit animation — finite pumps only.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
          find.text('Too long out. Renewing your experience'), findsOneWidget);
    });
  });
}
