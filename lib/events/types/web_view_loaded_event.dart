import '../event.dart';

class WebViewLoadedEvent extends Event {

  static const EVENT_NAME = "WebViewLoaded";

  WebViewLoadedEvent()
      : super(name: EVENT_NAME);

}
