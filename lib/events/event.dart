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

  final String name;

  Event({required this.name});

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
      default:
        return GenericEvent.from(json);
    }
  }
}

class ErrorEvent extends Event {
  final String code;
  final String? message;
  ErrorEvent(this.code, this.message) : super(name: 'error');
}