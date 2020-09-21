import 'package:flourish_flutter_sdk/environment_enum.dart';
import 'package:flourish_flutter_sdk/event.dart';
import 'package:flourish_flutter_sdk/event_manager.dart';
import 'package:flourish_flutter_sdk/webview_container.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class Flourish {
  EventManager eventManager = new EventManager();
  Environment environment;
  String apiKey;
  String userId;
  String secretKey;
  WebviewContainer _webviewContainer;
  static final Flourish _instance = Flourish._privateConstructor();

  static const MethodChannel _channel =
      const MethodChannel('flourish_flutter_sdk');

  Flourish._privateConstructor();

  factory Flourish.initialize({
    @required String apiKey,
    Environment env = Environment.production,
  }) {
    _instance.apiKey = apiKey;
    _instance.environment = env;
    return _instance;
  }

  factory Flourish() {
    return _instance;
  }

  String authenticate({
    @required String userId,
    @required String secretKey,
  }) {
    return 'key';
  }

  String authenticateAndOpenDashboard({
    @required String userId,
    @required String secretKey,
  }) {
    String key = this.authenticate(userId: userId, secretKey: secretKey);
    this.openDashboard(authenticationKey: key);
    return key;
  }

  void openDashboard({
    @required String authenticationKey,
  }) {
    this._webviewContainer = new WebviewContainer(
        url: this._getUrl(),
        authenticationKey: authenticationKey,
        eventManager: eventManager);
  }

  Stream<Event> get onEvent {
    return eventManager.onEvent;
  }

  WebviewContainer webviewContainer() {
    return this._webviewContainer;
  }

  String _getUrl() {
    switch (this.environment) {
      case Environment.production:
        {
          return "http://localhost:8080/";
        }
      // case Environment.development:
      //   {
      //     return "https://flourish-engine.herokuapp.com/webviews/dashboard/230";
      //   }
      // case Environment.staging:
      //   {
      //     return "https://flourish-engine.herokuapp.com/webviews/dashboard/230";
      //   }

      default:
        {
          return "http://localhost:8080/";
        }
    }
  }

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
