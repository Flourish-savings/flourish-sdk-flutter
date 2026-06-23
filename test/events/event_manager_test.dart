import 'package:flutter_test/flutter_test.dart';
import 'package:flourish_flutter_sdk/events/event.dart';
import 'package:flourish_flutter_sdk/events/event_manager.dart';
import 'package:flourish_flutter_sdk/events/types/payment_event.dart';
import 'package:flourish_flutter_sdk/events/types/auto_payment_event.dart';

void main() {
  group('EventManager', () {
    test('publishes a notified event on onEvent', () {
      final manager = EventManager();
      expectLater(manager.onEvent, emits(isA<PaymentEvent>()));
      manager.notify(PaymentEvent());
    });

    test('preserves notify order', () {
      final manager = EventManager();
      expectLater(
        manager.onEvent,
        emitsInOrder([isA<PaymentEvent>(), isA<AutoPaymentEvent>()]),
      );
      manager.notify(PaymentEvent());
      manager.notify(AutoPaymentEvent());
    });

    test('delivers each event to multiple subscribers (broadcast)', () async {
      final manager = EventManager();
      final a = <Event>[];
      final b = <Event>[];
      manager.onEvent.listen(a.add);
      manager.onEvent.listen(b.add);

      manager.notify(PaymentEvent());
      await Future<void>.delayed(Duration.zero);

      expect(a, hasLength(1));
      expect(b, hasLength(1));
      expect(a.single, isA<PaymentEvent>());
    });
  });
}
