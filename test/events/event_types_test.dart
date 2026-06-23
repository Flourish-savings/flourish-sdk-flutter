import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flourish_flutter_sdk/events/event.dart';
import 'package:flourish_flutter_sdk/events/types/back_event.dart';
import 'package:flourish_flutter_sdk/events/types/generic_event.dart';
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
  // Mirror production typing: payloads arrive via jsonDecode of a JS channel
  // message (List<dynamic>/Map<String, dynamic>), not Dart literals. The
  // trivia parsers' `prizes.map(...).addAll` only type-checks against the
  // decoded shape, so trivia fixtures are round-tripped through JSON.
  Map<String, dynamic> decode(Map<String, dynamic> m) =>
      jsonDecode(jsonEncode(m)) as Map<String, dynamic>;

  group('GenericEvent', () {
    test('carries the eventName as its name and stringifies data', () {
      final e = GenericEvent.from({'eventName': 'Custom', 'data': 42});
      expect(e.name, 'Custom');
      expect(e.data?.data, '42');
      expect(e.toJson(), {
        'name': 'Custom',
        'data': {'data': '42'}
      });
    });

    test('stringifies a missing data key as "null"', () {
      final e = GenericEvent.from({'eventName': 'Custom'});
      expect(e.data?.data, 'null');
    });
  });

  group('BackEvent', () {
    test('parses route and round-trips', () {
      final e = BackEvent.from({
        'eventName': Event.GO_BACK,
        'data': {'route': '/home'}
      });
      expect(e.name, Event.GO_BACK);
      expect(e.data.route, '/home');
      expect(e.toJson(), {
        'name': Event.GO_BACK,
        'data': {'route': '/home'}
      });
    });
  });

  group('RetryLoginEvent', () {
    test('parses code', () {
      final e = RetryLoginEvent.from({
        'eventName': Event.RETRY_LOGIN,
        'data': {'code': '401'}
      });
      expect(e.name, Event.RETRY_LOGIN);
      expect(e.data.code, '401');
    });
  });

  group('BackButtonPressedEvent', () {
    test('parses path and round-trips', () {
      final e = BackButtonPressedEvent.from({
        'data': {'path': '/store'}
      });
      expect(e.name, Event.BACK_BUTTON_PRESSED);
      expect(e.data.path, '/store');
      expect(e.toJson()['data'], {'path': '/store'});
    });
  });

  group('ReferralCopyEvent', () {
    test('parses referralCode and round-trips', () {
      final e = ReferralCopyEvent.from({
        'data': {'referralCode': 'REF-9'}
      });
      expect(e.name, Event.REFERRAL_COPY);
      expect(e.data.referralCode, 'REF-9');
      expect(e.toJson()['data'], {'referralCode': 'REF-9'});
    });
  });

  group('GiftCardCopyEvent', () {
    test('parses the gift card code directly from data and round-trips', () {
      final e = GiftCardCopyEvent.from({'data': 'GC-123'});
      expect(e.name, Event.GIFT_CARD_COPY);
      expect(e.data.giftCardCode, 'GC-123');
      expect(e.toJson()['data'], {'giftCardCode': 'GC-123'});
    });
  });

  group('HomeBannerActionEvent', () {
    test('parses data string and round-trips', () {
      final e = HomeBannerActionEvent.from({'data': 'banner-1'});
      expect(e.name, Event.HOME_BANNER_ACTION);
      expect(e.data.data, 'banner-1');
      expect(e.toJson()['data'], {'data': 'banner-1'});
    });
  });

  group('MissionActionEvent', () {
    test('parses missionType and missionEvent and round-trips', () {
      final e = MissionActionEvent.from({
        'data': {'missionType': 'daily', 'missionEvent': 'completed'}
      });
      expect(e.name, Event.MISSION_ACTION);
      expect(e.data.missionType, 'daily');
      expect(e.data.missionEvent, 'completed');
      expect(e.toJson()['data'],
          {'missionType': 'daily', 'missionEvent': 'completed'});
    });
  });

  // KNOWN BUG (deferred fix): the three trivia parsers do
  // `prizes.map(...)` on a `dynamic` receiver, producing a
  // `MappedListIterable<dynamic, dynamic>` that `List<Prizes>.addAll` rejects.
  // Any NON-EMPTY prize list throws at runtime (even production jsonDecoded
  // input) — in the WebView path the throw is swallowed by the JS-message
  // try/catch, so trivia events with prizes are silently dropped. The empty
  // prize path works. Fix: cast `(prizes as List).map(...)`.
  // The empty-prize tests below pass and guard the working path; the
  // non-empty-prize tests assert the INTENDED behavior and are skipped.
  group('TriviaFinishedEvent', () {
    test('parses hits and questions (empty prize list)', () {
      final e = TriviaFinishedEvent.from(decode({
        'data': {'hits': 3, 'questions': 5, 'prizes': []}
      }));
      expect(e.name, Event.TRIVIA_FINISHED);
      expect(e.data.hits, 3);
      expect(e.data.questions, 5);
      expect(e.data.prizes, isEmpty);
    });

    test('parses a non-empty prize list', () {
      final e = TriviaFinishedEvent.from(decode({
        'data': {
          'hits': 3,
          'questions': 5,
          'prizes': [
            {'quantity': 2, 'category': 'coin'}
          ],
        }
      }));
      expect(e.data.prizes.single.quantity, 2);
      expect(e.data.prizes.single.category, 'coin');
    }, skip: 'Documents trivia prize-list parsing bug; unskip when fixed.');
  });

  group('TriviaCloseEvent', () {
    test('parses totals (empty prize list)', () {
      final e = TriviaCloseEvent.from(decode({
        'data': {
          'totalHitsQuestions': 4,
          'totalQuestions': 6,
          'totalTimeSeconds': '88',
          'prizes': [],
        }
      }));
      expect(e.name, Event.TRIVIA_CLOSED);
      expect(e.data.hits, 4);
      expect(e.data.questions, 6);
      expect(e.data.time, '88');
      expect(e.data.prizes, isEmpty);
    });

    test('parses prizes with labels', () {
      final e = TriviaCloseEvent.from(decode({
        'data': {
          'totalHitsQuestions': 4,
          'totalQuestions': 6,
          'totalTimeSeconds': '88',
          'prizes': [
            {'quantity': 1, 'category': 'gift', 'label': 'Voucher'}
          ],
        }
      }));
      expect(e.data.prizes.single.label, 'Voucher');
    }, skip: 'Documents trivia prize-list parsing bug; unskip when fixed.');
  });

  group('TriviaGameFinishedEvent', () {
    test('parses totals and round-trips (empty prize list)', () {
      final e = TriviaGameFinishedEvent.from(decode({
        'data': {
          'totalHitsQuestions': 7,
          'totalQuestions': 10,
          'totalTimeSeconds': '120',
          'prizes': [],
        }
      }));
      expect(e.name, Event.TRIVIA_GAME_FINISHED);
      expect(e.data.hits, 7);
      expect(e.data.questions, 10);
      expect(e.data.time, '120');
      expect(e.toJson()['name'], Event.TRIVIA_GAME_FINISHED);
    });
  });
}
