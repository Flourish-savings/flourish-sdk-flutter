import 'package:flourish_flutter_sdk/event.dart';
import 'package:flourish_flutter_sdk/event_handler.dart';

class EventManager {
  final String all = '*';
  List<EventHandler> eventHandlers = List<EventHandler>();
  void on(String eventName, Function callback) {
    eventHandlers.add(EventHandler(eventName, callback));
  }

  void notify(Event event) {
    eventHandlers.forEach((e) => {
          if (event.type == e.eventName || event.type == all)
            {e.callback(event)}
        });
  }
}
