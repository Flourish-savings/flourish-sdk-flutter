import '../event.dart';

class PaymentEvent extends Event {

  static const EVENT_NAME = "GoToPayment";

  PaymentEvent()
      : super(name: EVENT_NAME);

}
