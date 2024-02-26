import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flourish_flutter_sdk/config/endpoint.dart';
import 'package:flourish_flutter_sdk/config/environment_enum.dart';
import 'package:flourish_flutter_sdk/config/language.dart';
import 'package:flourish_flutter_sdk/events/event.dart';
import 'package:flourish_flutter_sdk/events/event_manager.dart';
import 'package:flourish_flutter_sdk/events/types/generic_event.dart';
import 'package:flourish_flutter_sdk/events/types/web_view_loaded_event.dart';
import 'package:flourish_flutter_sdk/network/api_service.dart';
import 'package:flourish_flutter_sdk/web_view/webview_container.dart';
import 'package:flutter/services.dart';

import 'events/types/auto_payment_event.dart';
import 'events/types/back_event.dart';
import 'events/types/payment_event.dart';
import 'events/types/trivia_finished_event.dart';

import 'events/types/v2/back_button_pressed_event.dart';
import 'events/types/v2/gift_card_copy_event.dart';
import 'events/types/v2/home_banner_action_event.dart';
import 'events/types/v2/mission_action_event.dart';
import 'events/types/v2/referral_copy_event.dart';
import 'events/types/v2/trivia_close_event.dart';
import 'events/types/v2/trivia_game_finished_event.dart';
import 'events/types/v2/invalid_token_event.dart';

class Flourish {
  EventManager eventManager = new EventManager();
  late ApiService _service;
  late Environment environment;
  late String partnerId;
  late String secret;
  late String customerCode;
  late WebviewContainer _webviewContainer;
  late String _token;
  late Endpoint _endpoint;

  static const MethodChannel _channel =
      const MethodChannel('flourish_flutter_sdk');

  Flourish._(String token, Environment env, Language language) {
    this._token = token;
    this.environment = env;
    this._endpoint = Endpoint(environment, language);
    this._service = ApiService(env, this._endpoint);
  }

  factory Flourish.initialize({
    required String token,
    required Language language,
    Environment env = Environment.production,
  }) {
    return Flourish._(token, env, language);
  }

  Future<String> refreshToken() async {
    _token = await this.authenticate(customerCode: customerCode);
    return _token;
  }

  Future<String> authenticate({required String customerCode}) async {
    this.customerCode = customerCode;
    await signIn();
    return _token;
  }

  Future<bool> signIn() async {
    try {
      await _service.signIn(_token);
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


  StreamSubscription<Event> onBackButtonPressedEvent(Function callback) {
    return this.onEvent.listen((Event e) {
      if (e is BackButtonPressedEvent) {
        callback(e);
      }
    });
  }

  StreamSubscription<Event> onTriviaGameFinishedEvent(Function callback) {
    return this.onEvent.listen((Event e) {
      if (e is TriviaGameFinishedEvent) {
        callback(e);
      }
    });
  }

  StreamSubscription<Event> onTriviaCloseEvent(Function callback) {
    return this.onEvent.listen((Event e) {
      if (e is TriviaCloseEvent) {
        callback(e);
      }
    });
  }

  StreamSubscription<Event> onReferralCopyEvent(Function callback) {
    return this.onEvent.listen((Event e) {
      if (e is ReferralCopyEvent) {
        callback(e);
      }
    });
  }

  StreamSubscription<Event> onGiftCardCopyEvent(Function callback) {
    return this.onEvent.listen((Event e) {
      if (e is GiftCardCopyEvent) {
        callback(e);
      }
    });
  }

  StreamSubscription<Event> onHomeBannerActionEvent(Function callback) {
    return this.onEvent.listen((Event e) {
      if (e is HomeBannerActionEvent) {
        callback(e);
      }
    });
  }

  StreamSubscription<Event> onMissionActionEvent(Function callback) {
    return this.onEvent.listen((Event e) {
      if (e is MissionActionEvent) {
        callback(e);
      }
    });
  }

  StreamSubscription<Event> onInvalidTokenEvent(Function callback) {
    return this.onEvent.listen((Event e) {
      if (e is InvalidTokenEvent) {
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
        eventManager: this.eventManager,
        endpoint: this._endpoint,
        flourish: this);
  }

  WebviewContainer getWebViewContainer() {
    return _webviewContainer;
  }

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
