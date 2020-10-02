import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flourish_flutter_sdk/environment_enum.dart';
import 'package:flourish_flutter_sdk/event.dart';
import 'package:flourish_flutter_sdk/event_manager.dart';
import 'package:flourish_flutter_sdk/webview_container.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class Flourish {
  EventManager eventManager = new EventManager();
  Environment environment;
  String _url;
  Dio _api;
  String apiKey;
  String secret;
  String userId;
  String sessionId;
  WebviewContainer _webviewContainer;

  Map<String, StreamSubscription> _callbacks = {
    'points_earned': null,
    'webview_loaded': null,
  };

  static const MethodChannel _channel =
      const MethodChannel('flourish_flutter_sdk');

  Flourish._(this.apiKey, this.environment) {
    _url = this._getUrl(this.environment);
    _api = Dio(BaseOptions(baseUrl: this._url));
  }

  factory Flourish.initialize({
    @required String apiKey,
    @required String secret,
    Environment env = Environment.production,
  }) {
    return Flourish._(apiKey, env);
  }

  Future<String> authenticate({
    @required String userId,
    @required String sessionId,
  }) async {
    // TODO: Call Flourish backend to authenticate
    // We should inform the apiKey, userId and sessionId (if we decide to use it)
    // Nice to have: We could encrypt or generate a signature using the secret value
    // If the backend return ok. We are authenticated and the backend should return a JWT token
    // to our API

    // and finally we should start the polling process checking for notifications
    // e.g. GET /api/v1/notifications
    // and if there are notification we notify via de notify method
    return 'key';
  }

  Future<bool> checkActivityAvailable() async {
    Response res = await _api.request('/api/v1/activity.json');
    return res.data['hasActivityAvailable'];
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

  Stream<Event> get onEvent {
    return eventManager.onEvent;
  }

  WebviewContainer dashboard() {
    this._openDashboard();
    return this._webviewContainer;
  }

  void _openDashboard() {
    this._webviewContainer = new WebviewContainer(
        environment: this.environment,
        apiKey: this.apiKey,
        secret: this.secret,
        userId: this.userId,
        sessionId: this.sessionId,
        eventManager: this.eventManager);
  }

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
