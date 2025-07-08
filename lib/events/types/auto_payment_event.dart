import '../event.dart';

class AutoPaymentEvent extends Event {
  const AutoPaymentEvent() : super(name: Event.GO_TO_AUTO_PAYMENT);
}
