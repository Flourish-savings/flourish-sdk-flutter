import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flourish_flutter_sdk/app/service/main_service.dart';
import 'package:flourish_flutter_sdk/environment_enum.dart';
import 'package:flourish_flutter_sdk/event.dart';
import 'package:flourish_flutter_sdk/event_manager.dart';
import 'package:flourish_flutter_sdk/webview_container.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class Flourish {
  EventManager eventManager = new EventManager();
  MainService _service = MainService();
  Environment environment;
  String partnerId;
  String secret;
  String userId;
  String sessionId;
  WebviewContainer _webviewContainer;
  Timer _notificationsPoll;
  String _token;

  Map<String, StreamSubscription> _callbacks = {
    'points_earned': null,
    'webview_loaded': null,
    'notifications': null
  };

  static const MethodChannel _channel =
      const MethodChannel('flourish_flutter_sdk');

  Flourish._(this.partnerId, this.environment);

  factory Flourish.initialize({
    @required String partnerId,
    @required String secret,
    Environment env = Environment.production,
  }) {
    return Flourish._(partnerId, env);
  }

  Future<String> authenticate({
    @required String userId,
    @required String sessionId,
  }) async {
    _token = await _service.authenticate(
      1,
      "95380d599062bce7879ea32e89dbc1d3",
    );
    print(_token);
    // TODO: Call Flourish backend to authenticate
    // We should inform the apiKey, userId and sessionId (if we decide to use it)
    // Nice to have: We could encrypt or generate a signature using the secret value
    // If the backend return ok. We are authenticated and the backend should return a JWT token
    // to our API
    checkActivityAvailable();
    startPollingNotifications();
    // and finally we should start the polling process checking for notifications
    // e.g. GET /api/v1/notifications
    // and if there are notification we notify via de notify method
    return _token;
  }

  void checkActivityAvailable() async {
    bool res = false;
    try {
      res = await _service.checkForNotifications();
    } on DioError catch (e) {
      print(e.message);
      eventManager.notify(
        ErrorEvent('FAILED_TO_RETRIEVE_NOTIFICATION', e.message),
      );
    }

    if (res) {
      eventManager.notify(NotificationAvailable());
    }
    // Response res = await _api.request('/api/v1/activity.json');
    // return res.data['hasActivityAvailable'];
  }

  void startPollingNotifications() async {
    _notificationsPoll = Timer.periodic(Duration(minutes: 3), (timer) async {
      checkActivityAvailable();
    });
  }

  void stopPolling() {
    _notificationsPoll.cancel();
  }

  void on(String eventName, Function callback) {
    switch (eventName) {
      case 'points_earned':
        _callbacks[eventName] = this.onPointsEarned(callback);
        break;
      case 'webview_loaded':
        _callbacks[eventName] = this.onWebviewLoaded(callback);
        break;
      case 'notifications':
        _callbacks[eventName] = this.onNotification(callback);
        break;
      default:
        throw Exception('Event not found');
    }
  }

  void off(String eventName) {
    _getSubscription(eventName)?.cancel();
  }

  StreamSubscription<Event> _getSubscription(String eventName) {
    if (_callbacks.containsKey(eventName)) {
      return _callbacks[eventName];
    }
    return null;
  }

  StreamSubscription<Event> onPointsEarned(Function callback) {
    return this.onEvent.listen((Event e) {
      if (e is PointsEarnedEvent) {
        callback(e);
      }
    });
  }

  StreamSubscription<Event> onWebviewLoaded(Function callback) {
    return this.onEvent.listen((Event e) {
      if (e is WebviewLoadedEvent) {
        callback(e);
      }
    });
  }

  StreamSubscription<Event> onNotification(Function callback) {
    return this.onEvent.listen((Event e) {
      if (e is NotificationAvailable) {
        callback(e);
      }
    });
  }

  Stream<Event> get onEvent {
    return eventManager.onEvent;
  }

  WebviewContainer home() {
    this._openHome();
    return this._webviewContainer;
  }

  void _openHome() {
    this._webviewContainer = new WebviewContainer(
      environment: this.environment,
      apiToken: _token,
      userId: userId,
      eventManager: this.eventManager,
    );
  }

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
