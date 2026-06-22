import 'package:flutter_test/flutter_test.dart';
import 'package:flourish_flutter_sdk/events/event.dart';
import 'package:flourish_flutter_sdk/events/types/generic_event.dart';
import 'package:flourish_flutter_sdk/events/types/v2/open_external_url_event.dart';

void main() {
  group('OpenExternalUrlEvent.from', () {
    test('parses url from data', () {
      final event = OpenExternalUrlEvent.from({
        'eventName': 'OPEN_EXTERNAL_URL',
        'data': {'url': 'https://store.example.com/track?id=1'},
      });
      expect(event.data.url, 'https://store.example.com/track?id=1');
      expect(event.name, Event.OPEN_EXTERNAL_URL);
    });

    test('defaults url to empty string when url missing', () {
      final event = OpenExternalUrlEvent.from({
        'eventName': 'OPEN_EXTERNAL_URL',
        'data': {},
      });
      expect(event.data.url, '');
    });

    test('falls back to empty data when data key is absent', () {
      final event = OpenExternalUrlEvent.from({'eventName': 'OPEN_EXTERNAL_URL'});
      expect(event.data.url, '');
    });

    test('falls back to empty data when data is not a map', () {
      final event = OpenExternalUrlEvent.from({
        'eventName': 'OPEN_EXTERNAL_URL',
        'data': 'oops',
      });
      expect(event.data.url, '');
    });

    test('coerces non-string url to string', () {
      final event = OpenExternalUrlEvent.from({
        'eventName': 'OPEN_EXTERNAL_URL',
        'data': {'url': 42},
      });
      expect(event.data.url, '42');
    });

    test('toJson round-trips name and url', () {
      final event = OpenExternalUrlEvent.from({
        'eventName': 'OPEN_EXTERNAL_URL',
        'data': {'url': 'https://a.test'},
      });
      expect(event.toJson(), {
        'name': Event.OPEN_EXTERNAL_URL,
        'data': {'url': 'https://a.test'},
      });
    });
  });

  group('Event.fromJson dispatch', () {
    test('routes OPEN_EXTERNAL_URL eventName to OpenExternalUrlEvent', () {
      final event = Event.fromJson({
        'eventName': 'OPEN_EXTERNAL_URL',
        'data': {'url': 'https://b.test'},
      });
      expect(event, isA<OpenExternalUrlEvent>());
      expect(event.name, Event.OPEN_EXTERNAL_URL);
      expect((event as OpenExternalUrlEvent).data.url, 'https://b.test');
    });

    test('does not route OPEN_EXTERNAL_URL to GenericEvent', () {
      final event = Event.fromJson({
        'eventName': 'OPEN_EXTERNAL_URL',
        'data': {'url': 'https://c.test'},
      });
      expect(event, isNot(isA<GenericEvent>()));
    });
  });
}
