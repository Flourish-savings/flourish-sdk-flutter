import 'package:flutter_test/flutter_test.dart';
import 'package:flourish_flutter_sdk/events/event.dart';
import 'package:flourish_flutter_sdk/events/types/generic_event.dart';

void main() {
  group('ErrorEvent.fromJson', () {
    test('parses code and message from data', () {
      final event = ErrorEvent.fromJson({
        'eventName': 'ERROR',
        'data': {'code': 'NETWORK_ERROR', 'message': 'No connection'},
      });
      expect(event.code, 'NETWORK_ERROR');
      expect(event.message, 'No connection');
      expect(event.name, Event.ERROR);
    });

    test('defaults code to UNKNOWN_ERROR when code missing', () {
      final event = ErrorEvent.fromJson({'eventName': 'ERROR', 'data': {}});
      expect(event.code, 'UNKNOWN_ERROR');
      expect(event.message, isNull);
    });

    test('falls back to empty data when data key is absent', () {
      final event = ErrorEvent.fromJson({'eventName': 'ERROR'});
      expect(event.code, 'UNKNOWN_ERROR');
      expect(event.message, isNull);
    });

    test('falls back to empty data when data is not a map', () {
      final event = ErrorEvent.fromJson({'eventName': 'ERROR', 'data': 'oops'});
      expect(event.code, 'UNKNOWN_ERROR');
      expect(event.message, isNull);
    });

    test('coerces non-string code and message to string', () {
      final event = ErrorEvent.fromJson({
        'eventName': 'ERROR',
        'data': {'code': 500, 'message': 42},
      });
      expect(event.code, '500');
      expect(event.message, '42');
    });
  });

  group('Event.fromJson dispatch', () {
    test('routes ERROR eventName to ErrorEvent', () {
      final event = Event.fromJson({
        'eventName': 'ERROR',
        'data': {'code': 'X'},
      });
      expect(event, isA<ErrorEvent>());
      expect(event.name, Event.ERROR);
    });

    test('routes unknown eventName to GenericEvent', () {
      final event = Event.fromJson({'eventName': 'SOMETHING_NEW'});
      expect(event, isA<GenericEvent>());
    });
  });
}
