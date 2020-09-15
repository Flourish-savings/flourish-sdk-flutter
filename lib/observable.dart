import 'package:flourish_flutter_sdk/event.dart';
import 'package:flourish_flutter_sdk/observer.dart';

class Observable {
  final List<Observer> _observers = List<Observer>();

  void registerObserver(String eventName, Function callback) {
    this._observers.add(new Observer(eventName, callback));
  }

  void notifyObservers(Event event) {
    for (var observer in _observers) {
      observer.notify(event);
    }
  }
}
