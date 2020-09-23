import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flourish_flutter_sdk/environment_enum.dart';
import 'package:flourish_flutter_sdk/event.dart';
import 'package:flourish_flutter_sdk/event_manager.dart';
import 'package:flourish_flutter_sdk/firestore_manager.dart';
import 'package:flourish_flutter_sdk/webview_container.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class Flourish {
  EventManager eventManager = new EventManager();
  FirestoreManager firestoreManager;
  Environment environment;
  String apiKey;
  String userId;
  String secretKey;
  WebviewContainer _webviewContainer;

  Map<String, StreamSubscription> _callbacks = {
    'points_earned': null,
    'webview_loaded': null,
  };

  static const MethodChannel _channel =
      const MethodChannel('flourish_flutter_sdk');

  Flourish._(this.apiKey, this.environment);

  factory Flourish.initialize({
    @required String apiKey,
    Environment env = Environment.production,
  }) {
    return Flourish._(apiKey, env);
  }

  Future<String> authenticate({
    @required String userId,
    @required String secretKey,
  }) async {
    firestoreManager = await FirestoreManager.from(userId);
    return 'key';
  }

  Future<String> authenticateAndOpenDashboard({
    @required String userId,
    @required String secretKey,
  }) async {
    String key = await this.authenticate(userId: userId, secretKey: secretKey);
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

  void on(String eventName, Function callback) {
    switch (eventName) {
      case 'points_earned':
        _callbacks[eventName] = this.onPointsEarned(callback);
        break;
      case 'webview_loaded':
        _callbacks[eventName] = this.onWebviewLoaded(callback);
        break;
      case 'notifications':
        _callbacks[eventName] = this.listenFirestore(callback);
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

  StreamSubscription<DocumentSnapshot> listenFirestore(Function callback) {
    return this.firestoreManager.onNotification.listen((doc) {
      callback(doc);
    });
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
