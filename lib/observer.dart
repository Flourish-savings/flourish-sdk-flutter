import 'package:flourish_flutter_sdk/event.dart';

class Observer {
  String eventName;
  Function callback;

  Observer(this.eventName, this.callback);

  void notify(Event event) {
    this.callback(event);
  }
}
