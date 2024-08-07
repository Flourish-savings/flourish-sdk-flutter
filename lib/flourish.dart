import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flourish_flutter_sdk/config/endpoint.dart';
import 'package:flourish_flutter_sdk/config/configuration.dart';
import 'package:flourish_flutter_sdk/config/environment_enum.dart';
import 'package:flourish_flutter_sdk/events/event.dart';
import 'package:flourish_flutter_sdk/events/event_manager.dart';
import 'package:flourish_flutter_sdk/events/types/generic_event.dart';
import 'package:flourish_flutter_sdk/config/language.dart';
import 'package:flourish_flutter_sdk/events/types/web_view_loaded_event.dart';
import 'package:flourish_flutter_sdk/network/api_service.dart';
import 'package:flourish_flutter_sdk/web_view/generic_error_pageview.dart';
import 'package:flourish_flutter_sdk/web_view/webview_container.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
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

class Flourish {
  EventManager eventManager = new EventManager();
  late ApiService service;
  late Environment environment;
  late String partnerId;
  late String secret;
  late String? version;
  late String? trackingId;
  late Language language;
  late String customerCode;
  late String category;
  late WebviewContainer webviewContainer;
  late Endpoint endpoint;
  String token = '';

  static const MethodChannel _channel =
      const MethodChannel('flourish_flutter_sdk');

  Flourish._({
    required String partnerId,
    required String secret,
    String? version,
    String? trackingId,
    required Environment env,
    required Language language,
    required String customerCode
  }) {
    this.partnerId = partnerId;
    this.secret = secret;
    this.environment = env;
    this.language = language;
    this.version = version;
    this.trackingId = trackingId;
    this.endpoint = Endpoint(environment);
    this.service = ApiService(env, this.endpoint);
    this.customerCode = customerCode;
  }

  static Future<Flourish> create({
    required String partnerId,
    required String secret,
    required Environment env,
    required Language language,
    required String customerCode,
    String? version,
    String? trackingId
  }) async {

    Flourish flourish = Flourish._(
        partnerId: partnerId,
        secret: secret,
        version: version,
        trackingId: trackingId,
        env: env,
        language: language,
        customerCode: customerCode
    );

    await flourish.authenticate(customerCode: customerCode);

    return flourish;
  }

  Future<String> refreshToken() async {
    token = await this.authenticate(customerCode: customerCode, category: category);
    return token;
  }

  Future<String> authenticate({required String customerCode, String category = ""}) async {
    try {
      this.customerCode = customerCode;
      this.category = category;
      token = await service.authenticate(this.partnerId, this.secret, customerCode, category);
      await signIn();
      return token;
    } on DioException catch (e) {
      eventManager.notify(
        GenericEvent(event: "AUTHENTICATION_FAILURE"),
      );
      return "";
    }
  }

  Future<bool> signIn() async {
    try {
      await service.signIn(SdkInfo.version);
      return true;
    } on DioException catch (e) {
      eventManager.notify(
        GenericEvent(event: "SIGN_IN_FAILED"),
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

  StreamSubscription<Event> onErrorEvent(Function callback) {
    return this.onEvent.listen((Event e) {
      if (e is ErrorEvent) {
        callback(e);
      }
    });
  }

  Stream<Event> get onEvent {
    return eventManager.onEvent;
  }

  Widget home() {
    if(this.token.isEmpty){
      return GenericErrorPageView(flourish: this);
    }
    this._openHome();
    return this.webviewContainer;
  }

  void _openHome() {
    this.webviewContainer = new WebviewContainer(
      environment: this.environment,
      apiToken: this.token,
      language: this.language,
      eventManager: this.eventManager,
      endpoint: this.endpoint,
      flourish: this,
      version: version,
      trackingId: trackingId,
      sdkVersion: SdkInfo.version,
    );
  }

  WebviewContainer getWebViewContainer() {
    return webviewContainer;
  }

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
