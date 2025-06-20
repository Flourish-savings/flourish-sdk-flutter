import 'dart:async';

import 'package:flourish_flutter_sdk/events/event.dart';

class EventManager {
  final StreamController<Event> _eventStreamController = StreamController();
  late Stream<Event> _stream =
      _eventStreamController.stream.asBroadcastStream();

  Stream<Event> get onEvent => _stream;

  void notify(Event event) {
    if (_eventStreamController.isClosed) return;
    _eventStreamController.add(event);
  }
}
