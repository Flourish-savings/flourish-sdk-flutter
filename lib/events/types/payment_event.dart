import '../event.dart';

class PaymentEvent extends Event {
  const PaymentEvent() : super(name: Event.GO_TO_PAYMENT);
}
