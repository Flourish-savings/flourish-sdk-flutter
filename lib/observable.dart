import 'package:flourish_flutter_sdk/event.dart';
import 'package:flourish_flutter_sdk/observer.dart';

class Observable {
  List<Observer> _observers;

  void on(String eventName, Function callback) {
    this._observers.add(new Observer(eventName, callback));
  }

  void notifyObservers(Event event) {
    for (var observer in _observers) {
      observer.notify(event);
    }
  }
}
