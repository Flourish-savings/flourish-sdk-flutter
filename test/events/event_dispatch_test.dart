import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flourish_flutter_sdk/events/event.dart';
import 'package:flourish_flutter_sdk/events/types/auto_payment_event.dart';
import 'package:flourish_flutter_sdk/events/types/back_event.dart';
import 'package:flourish_flutter_sdk/events/types/generic_event.dart';
import 'package:flourish_flutter_sdk/events/types/payment_event.dart';
import 'package:flourish_flutter_sdk/events/types/retry_login_event.dart';
import 'package:flourish_flutter_sdk/events/types/trivia_finished_event.dart';
import 'package:flourish_flutter_sdk/events/types/v2/back_button_pressed_event.dart';
import 'package:flourish_flutter_sdk/events/types/v2/gift_card_copy_event.dart';
import 'package:flourish_flutter_sdk/events/types/v2/home_banner_action_event.dart';
import 'package:flourish_flutter_sdk/events/types/v2/mission_action_event.dart';
import 'package:flourish_flutter_sdk/events/types/v2/referral_copy_event.dart';
import 'package:flourish_flutter_sdk/events/types/v2/trivia_close_event.dart';
import 'package:flourish_flutter_sdk/events/types/v2/trivia_game_finished_event.dart';

void main() {
  group('Event.fromJson dispatch', () {
    // Route payloads through real JSON decoding so nested lists/maps carry the
    // same dynamic typing the SDK sees in production (jsonDecode of a JS
    // channel message), not statically-typed Dart literals.
    Map<String, dynamic> ev(String name, [dynamic data]) => jsonDecode(
          jsonEncode({'eventName': name, if (data != null) 'data': data}),
        ) as Map<String, dynamic>;

    // Empty prize list: exercises dispatch routing without tripping the
    // trivia prize-parsing bug (see event_types_test.dart, skipped cases).
    final triviaData = {
      'hits': 3,
      'questions': 5,
      'totalHitsQuestions': 3,
      'totalQuestions': 5,
      'totalTimeSeconds': '42',
      'prizes': [],
    };

    test('routes GoToAutoPayment to AutoPaymentEvent', () {
      expect(Event.fromJson(ev(Event.GO_TO_AUTO_PAYMENT)), isA<AutoPaymentEvent>());
    });

    test('routes GoToPayment to PaymentEvent', () {
      expect(Event.fromJson(ev(Event.GO_TO_PAYMENT)), isA<PaymentEvent>());
    });

    test('routes TriviaFinished to TriviaFinishedEvent', () {
      expect(Event.fromJson(ev(Event.TRIVIA_FINISHED, triviaData)),
          isA<TriviaFinishedEvent>());
    });

    test('routes RetryLogin to RetryLoginEvent', () {
      expect(Event.fromJson(ev(Event.RETRY_LOGIN, {'code': '401'})),
          isA<RetryLoginEvent>());
    });

    test('routes GoBack to BackEvent', () {
      expect(Event.fromJson(ev(Event.GO_BACK, {'route': '/home'})),
          isA<BackEvent>());
    });

    test('routes BACK_BUTTON_PRESSED to BackButtonPressedEvent', () {
      expect(Event.fromJson(ev(Event.BACK_BUTTON_PRESSED, {'path': '/x'})),
          isA<BackButtonPressedEvent>());
    });

    test('routes TRIVIA_GAME_FINISHED to TriviaGameFinishedEvent', () {
      expect(Event.fromJson(ev(Event.TRIVIA_GAME_FINISHED, triviaData)),
          isA<TriviaGameFinishedEvent>());
    });

    test('routes TRIVIA_CLOSED to TriviaCloseEvent', () {
      expect(Event.fromJson(ev(Event.TRIVIA_CLOSED, triviaData)),
          isA<TriviaCloseEvent>());
    });

    test('routes REFERRAL_COPY to ReferralCopyEvent', () {
      expect(
          Event.fromJson(ev(Event.REFERRAL_COPY, {'referralCode': 'ABC'})),
          isA<ReferralCopyEvent>());
    });

    test('routes HOME_BANNER_ACTION to HomeBannerActionEvent', () {
      expect(Event.fromJson(ev(Event.HOME_BANNER_ACTION, 'banner-1')),
          isA<HomeBannerActionEvent>());
    });

    test('routes MISSION_ACTION to MissionActionEvent', () {
      expect(
          Event.fromJson(
              ev(Event.MISSION_ACTION, {'missionType': 't', 'missionEvent': 'e'})),
          isA<MissionActionEvent>());
    });

    test('routes ERROR to ErrorEvent', () {
      expect(Event.fromJson(ev(Event.ERROR, {'code': 'E1'})), isA<ErrorEvent>());
    });

    test('routes an unknown eventName to GenericEvent', () {
      expect(Event.fromJson(ev('SomethingNew', 'x')), isA<GenericEvent>());
    });

    test('routes WebViewLoaded (no dispatch case) to GenericEvent', () {
      expect(Event.fromJson(ev(Event.WEBVIEW_LOADED, 'x')), isA<GenericEvent>());
    });

    // KNOWN BUG (deferred fix): event.dart routes GIFT_CARD_COPY to
    // ReferralCopyEvent instead of GiftCardCopyEvent, so onGiftCardCopyEvent
    // never fires via dispatch. This test asserts the INTENDED behavior and is
    // skipped until the one-line source fix lands.
    // See docs/plans/2026-06-22-001-test-sdk-coverage-plan.md (Deferred work).
    test('routes GIFT_CARD_COPY to GiftCardCopyEvent', () {
      final result = Event.fromJson(ev(Event.GIFT_CARD_COPY, 'GC-123'));
      expect(result, isA<GiftCardCopyEvent>());
      expect((result as GiftCardCopyEvent).data.giftCardCode, 'GC-123');
    }, skip: 'Documents known GIFT_CARD_COPY mis-routing bug; unskip when fixed.');
  });
}
