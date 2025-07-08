import 'package:flourish_flutter_sdk/events/types/v2/back_button_pressed_event.dart';
import 'package:flourish_flutter_sdk/events/types/v2/home_banner_action_event.dart';
import 'package:flourish_flutter_sdk/events/types/v2/mission_action_event.dart';
import 'package:flourish_flutter_sdk/events/types/v2/referral_copy_event.dart';
import 'package:flourish_flutter_sdk/events/types/v2/trivia_close_event.dart';
import 'package:flourish_flutter_sdk/events/types/v2/trivia_game_finished_event.dart';

import 'types/auto_payment_event.dart';
import 'types/back_event.dart';
import 'types/payment_event.dart';
import 'types/generic_event.dart';
import 'types/retry_login_event.dart';
import 'types/trivia_finished_event.dart';

class Event {
  static const String GO_TO_AUTO_PAYMENT = 'GoToAutoPayment';
  static const String GO_TO_PAYMENT = 'GoToPayment';
  static const String TRIVIA_FINISHED = 'TriviaFinished';
  static const String RETRY_LOGIN = 'RetryLogin';
  static const String GO_BACK = 'GoBack';
  static const String WEBVIEW_LOADED = 'WebViewLoaded';

  /// When you need to know when the user clicks on the back menu button on our platform.
  static const String BACK_BUTTON_PRESSED = 'BACK_BUTTON_PRESSED';
  /// When you need to know when the user finishes a Trivia game on our platform.
  static const String TRIVIA_GAME_FINISHED = 'TRIVIA_GAME_FINISHED';
  /// When you need to know when the user closed the Trivia game on our platform.
  static const String TRIVIA_CLOSED = 'TRIVIA_CLOSED';
  /// When you need to know when the user copy the referral code to the clipboard area.
  static const String REFERRAL_COPY = 'REFERRAL_COPY';
  /// When you need to know when the user copy the Gift code to the clipboard area.
  static const String GIFT_CARD_COPY = 'GIFT_CARD_COPY';
  /// When you need to know when the user clicks on the home banner.
  static const String HOME_BANNER_ACTION = 'HOME_BANNER_ACTION';
  /// When you need to know when the user clicks on a mission card.
  static const String MISSION_ACTION = 'MISSION_ACTION';
  /// When you need to know when the user clicks on the back menu button on our error page.
  static const String ERROR_BACK_BUTTON_PRESSED = 'ERROR_BACK_BUTTON_PRESSED';
  /// When you need to know when the Authentication failed.
  static const String AUTHENTICATION_FAILURE = 'AUTHENTICATION_FAILURE';
  static const String SIGN_IN_FAILED = 'SIGN_IN_FAILED';

  final String name;

  const Event({required this.name});

  factory Event.fromJson(Map<String, dynamic> json) {
    final eventName = json['eventName'];
    switch (eventName) {
      case GO_TO_AUTO_PAYMENT:
        return AutoPaymentEvent();
      case GO_TO_PAYMENT:
        return PaymentEvent();
      case TRIVIA_FINISHED:
        return TriviaFinishedEvent.from(json);
      case RETRY_LOGIN:
        return RetryLoginEvent.from(json);
      case GO_BACK:
        return BackEvent.from(json);
      case BACK_BUTTON_PRESSED:
        return BackButtonPressedEvent.from(json);
      case TRIVIA_GAME_FINISHED:
        return TriviaGameFinishedEvent.from(json);
      case TRIVIA_CLOSED:
        return TriviaCloseEvent.from(json);
      case REFERRAL_COPY:
        return ReferralCopyEvent.from(json);
      case GIFT_CARD_COPY:
        return ReferralCopyEvent.from(json);
      case HOME_BANNER_ACTION:
        return HomeBannerActionEvent.from(json);
      case MISSION_ACTION:
        return MissionActionEvent.from(json);
      default:
        return GenericEvent.from(json);
    }
  }
}

class ErrorEvent extends Event {
  final String code;
  final String? message;
  const ErrorEvent(this.code, this.message) : super(name: 'ErrorEvent');
}
