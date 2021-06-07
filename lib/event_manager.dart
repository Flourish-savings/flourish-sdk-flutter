import 'dart:async';

import 'package:flourish_flutter_sdk/event.dart';

class EventManager {
  final StreamController<Event> _eventStreamController =
      StreamController<Event>();
  late Stream<Event>? _stream =
      _eventStreamController.stream.asBroadcastStream();

  Stream<Event> get onEvent {
    if (_stream == null) {
      _stream = _eventStreamController.stream.asBroadcastStream();
    }
    return _stream!;
  }

  void notify(Event event) {
    if (!_eventStreamController.isClosed) {
      _eventStreamController.add(event);
    }
  }
}
