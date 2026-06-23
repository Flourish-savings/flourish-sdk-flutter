import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flourish_flutter_sdk/events/event.dart';
import 'package:flourish_flutter_sdk/events/types/auto_payment_event.dart';
import 'package:flourish_flutter_sdk/events/types/back_event.dart';
import 'package:flourish_flutter_sdk/events/types/generic_event.dart';
import 'package:flourish_flutter_sdk/events/types/payment_event.dart';
import 'package:flourish_flutter_sdk/events/types/trivia_finished_event.dart';
import 'package:flourish_flutter_sdk/events/types/web_view_loaded_event.dart';
import 'package:flourish_flutter_sdk/events/types/v2/back_button_pressed_event.dart';
import 'package:flourish_flutter_sdk/events/types/v2/gift_card_copy_event.dart';
import 'package:flourish_flutter_sdk/events/types/v2/home_banner_action_event.dart';
import 'package:flourish_flutter_sdk/events/types/v2/mission_action_event.dart';
import 'package:flourish_flutter_sdk/events/types/v2/open_external_url_event.dart';
import 'package:flourish_flutter_sdk/events/types/v2/referral_copy_event.dart';
import 'package:flourish_flutter_sdk/events/types/v2/trivia_close_event.dart';
import 'package:flourish_flutter_sdk/events/types/v2/trivia_game_finished_event.dart';
import 'package:flourish_flutter_sdk/flourish.dart';

import 'helpers/test_doubles.dart';

Map<String, dynamic> _d(Map<String, dynamic> m) =>
    jsonDecode(jsonEncode(m)) as Map<String, dynamic>;

void main() {
  late Flourish flourish;

  setUp(() async {
    flourish = await flourishWithStaticToken();
  });

  /// Asserts [register] forwards [match] to its callback and ignores [other].
  Future<void> firesOnlyFor(
    StreamSubscription Function(Function) register,
    Event match,
    Event other,
  ) async {
    final got = <dynamic>[];
    register((dynamic e) => got.add(e));
    flourish.eventManager.notify(other);
    flourish.eventManager.notify(match);
    await Future<void>.delayed(Duration.zero);
    expect(got, hasLength(1));
    expect(identical(got.single, match), isTrue);
  }

  final emptyTrivia = _d({
    'data': {
      'hits': 0,
      'questions': 0,
      'totalHitsQuestions': 0,
      'totalQuestions': 0,
      'totalTimeSeconds': '0',
      'prizes': []
    }
  });

  group('typed event subscriptions fire only for their event', () {
    test('onPaymentEvent', () => firesOnlyFor(
        flourish.onPaymentEvent, PaymentEvent(), AutoPaymentEvent()));

    test('onAutoPaymentEvent', () => firesOnlyFor(
        flourish.onAutoPaymentEvent, AutoPaymentEvent(), PaymentEvent()));

    test('onTriviaFinishedEvent', () => firesOnlyFor(
        flourish.onTriviaFinishedEvent,
        TriviaFinishedEvent.from(emptyTrivia),
        PaymentEvent()));

    test('onBackEvent', () => firesOnlyFor(
        flourish.onBackEvent,
        BackEvent.from({
          'data': {'route': '/'}
        }),
        PaymentEvent()));

    test('onBackButtonPressedEvent', () => firesOnlyFor(
        flourish.onBackButtonPressedEvent,
        BackButtonPressedEvent.from({
          'data': {'path': '/'}
        }),
        PaymentEvent()));

    test('onTriviaGameFinishedEvent', () => firesOnlyFor(
        flourish.onTriviaGameFinishedEvent,
        TriviaGameFinishedEvent.from(emptyTrivia),
        PaymentEvent()));

    test('onTriviaCloseEvent', () => firesOnlyFor(
        flourish.onTriviaCloseEvent,
        TriviaCloseEvent.from(emptyTrivia),
        PaymentEvent()));

    test('onReferralCopyEvent', () => firesOnlyFor(
        flourish.onReferralCopyEvent,
        ReferralCopyEvent.from({
          'data': {'referralCode': 'R'}
        }),
        PaymentEvent()));

    test('onGiftCardCopyEvent', () => firesOnlyFor(
        flourish.onGiftCardCopyEvent,
        GiftCardCopyEvent.from({'data': 'G'}),
        PaymentEvent()));

    test('onHomeBannerActionEvent', () => firesOnlyFor(
        flourish.onHomeBannerActionEvent,
        HomeBannerActionEvent.from({'data': 'B'}),
        PaymentEvent()));

    test('onMissionActionEvent', () => firesOnlyFor(
        flourish.onMissionActionEvent,
        MissionActionEvent.from({
          'data': {'missionType': 't', 'missionEvent': 'e'}
        }),
        PaymentEvent()));

    test('onOpenExternalUrlEvent', () => firesOnlyFor(
        flourish.onOpenExternalUrlEvent,
        OpenExternalUrlEvent.from({
          'data': {'url': 'https://x'}
        }),
        PaymentEvent()));

    test('onWebViewLoadedEvent', () => firesOnlyFor(
        flourish.onWebViewLoadedEvent, WebViewLoadedEvent(), PaymentEvent()));

    test('onErrorEvent', () => firesOnlyFor(
        flourish.onErrorEvent,
        const ErrorEvent(code: 'E1', message: 'boom'),
        PaymentEvent()));
  });

  group('broad subscriptions', () {
    test('onAllEvent fires for every event', () async {
      final got = <dynamic>[];
      flourish.onAllEvent((dynamic e) => got.add(e));
      flourish.eventManager.notify(PaymentEvent());
      flourish.eventManager.notify(AutoPaymentEvent());
      await Future<void>.delayed(Duration.zero);
      expect(got, hasLength(2));
    });

    test('onGenericEvent fires only for GenericEvent', () async {
      final got = <dynamic>[];
      flourish.onGenericEvent((dynamic e) => got.add(e));
      flourish.eventManager.notify(PaymentEvent());
      flourish.eventManager.notify(GenericEvent.from({'eventName': 'X'}));
      await Future<void>.delayed(Duration.zero);
      expect(got, hasLength(1));
      expect(got.single, isA<GenericEvent>());
    });
  });
}
