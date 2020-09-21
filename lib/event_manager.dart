import 'dart:async';

import 'package:flourish_flutter_sdk/event.dart';

class EventManager {
  Stream<Event> _stream;
  final StreamController<Event> _eventStreamController =
      StreamController<Event>();

  Stream<Event> get onEvent {
    if (_stream == null) {
      _stream = _eventStreamController.stream.asBroadcastStream();
    }
    return _stream;
  }

  void notify(Event event) {
    if (_eventStreamController != null && !_eventStreamController.isClosed) {
      _eventStreamController.add(event);
    }
  }
}
