import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flourish_flutter_sdk/config/endpoint.dart';
import 'package:flourish_flutter_sdk/config/environment_enum.dart';
import 'package:flourish_flutter_sdk/events/event.dart';
import 'package:flourish_flutter_sdk/events/event_manager.dart';
import 'package:flourish_flutter_sdk/events/types/generic_event.dart';
import 'package:flourish_flutter_sdk/config/language.dart';
import 'package:flourish_flutter_sdk/events/types/web_view_loaded_event.dart';
import 'package:flourish_flutter_sdk/network/api_service.dart';
import 'package:flourish_flutter_sdk/web_view/webview_container.dart';
import 'package:flutter/services.dart';
import 'events/types/auto_payment_event.dart';
import 'events/types/back_event.dart';
import 'events/types/payment_event.dart';
import 'events/types/trivia_finished_event.dart';


class Flourish {
  EventManager eventManager = new EventManager();
  late ApiService _service;
  late Environment environment;
  late String partnerId;
  late String secret;
  late String? version;
  late String? trackingId;
  late Language language;
  late String customerCode;
  late String category;
  late WebviewContainer _webviewContainer;
  late String _token;
  late Endpoint _endpoint;

  static const MethodChannel _channel =
      const MethodChannel('flourish_flutter_sdk');

  Flourish._(
    String partnerId,
    String secret,
    String? version,
    String? trackingId,
    Environment env,
    Language language
  ) {
    this.partnerId = partnerId;
    this.secret = secret;
    this.environment = env;
    this.language = language;
    this.version = version;
    this.trackingId = trackingId;
    this._endpoint = Endpoint(environment);
    this._service = ApiService(env, this._endpoint);
  }

  factory Flourish.initialize({
    required String partnerId,
    required String secret,
    required Language language,
    String? version,
    String? trackingId,
    Environment env = Environment.production,
  }) {
    return Flourish._(partnerId, secret, version, trackingId, env, language);
  }

  Future<String> refreshToken() async {
    _token = await this.authenticate(customerCode: customerCode, category: category);
    return _token;
  }

  Future<String> authenticate({required String customerCode, String category = ""}) async {
    this.customerCode = customerCode;
    this.category = category;
    _token = await _service.authenticate(this.partnerId, this.secret, customerCode, category);
    await signIn();
    return _token;
  }

  Future<bool> signIn() async {
    try {
      await _service.signIn();
      return true;
    } on DioException catch (e) {
      eventManager.notify(
        ErrorEvent('FAILED_TO_SIGN_IN', e.message),
      );
      return false;
    }
  }

  StreamSubscription<Event> onAllEvent(Function callback) {
    return this.onEvent.listen((Event e) {
        callback(e);
    });
  }

  StreamSubscription<Event> onGenericEvent(Function callback) {
    return this.onEvent.listen((Event e) {
      if (e is GenericEvent) {
        callback(e);
      }
    });
  }

  StreamSubscription<Event> onWebViewLoadedEvent(Function callback) {
    return this.onEvent.listen((Event e) {
      if (e is WebViewLoadedEvent) {
        callback(e);
      }
    });
  }

  StreamSubscription<Event> onAutoPaymentEvent(Function callback) {
    return this.onEvent.listen((Event e) {
      if (e is AutoPaymentEvent) {
        callback(e);
      }
    });
  }

  StreamSubscription<Event> onPaymentEvent(Function callback) {
    return this.onEvent.listen((Event e) {
      if (e is PaymentEvent) {
        callback(e);
      }
    });
  }

  StreamSubscription<Event> onTriviaFinishedEvent(Function callback) {
    return this.onEvent.listen((Event e) {
      if (e is TriviaFinishedEvent) {
        callback(e);
      }
    });
  }

  StreamSubscription<Event> onBackEvent(Function callback) {
    return this.onEvent.listen((Event e) {
      if (e is BackEvent) {
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
      apiToken: this._token,
      language: this.language,
      eventManager: this.eventManager,
      endpoint: this._endpoint,
      flourish: this,
      version: version,
      trackingId: trackingId,
    );
  }

  WebviewContainer getWebViewContainer() {
    return _webviewContainer;
  }

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
