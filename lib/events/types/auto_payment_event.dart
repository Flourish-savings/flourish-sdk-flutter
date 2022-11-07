import '../event.dart';

class AutoPaymentEvent extends Event {

  static const EVENT_NAME = "GoToAutoPayment";

  AutoPaymentEvent()
      : super(name: EVENT_NAME);

}
