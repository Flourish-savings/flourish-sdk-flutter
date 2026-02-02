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
import 'package:flourish_flutter_sdk/web_view/webview_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
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

  void Function(BuildContext context, WebResourceError error)? onWebViewLoadError;
  void Function(BuildContext context)? onAuthError;
  void Function(BuildContext context, ErrorEvent error)? onError;

  static const MethodChannel _channel =
      const MethodChannel('flourish_flutter_sdk');

  Flourish({
    required String partnerId,
    required String secret,
    String? version,
    String? trackingId,
    required Environment env,
    required Language language,
    required String customerCode,
    this.onWebViewLoadError,
    this.onAuthError,
    this.onError,
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

    authenticate(customerCode: customerCode);
  }

  Future<String> refreshToken() async {
    token = await this.authenticate(customerCode: customerCode, category: category);
    return token;
  }

  Future<String> authenticate({required String customerCode, String category = ""}) async {
    this.customerCode = customerCode;
    this.category = category;
    token = await service.authenticate(this.partnerId, this.secret, customerCode, category);
    await signIn();
    return token;
  }

  Future<bool> signIn() async {
    try {
      await service.signIn(SdkInfo.version);
      return true;
    } on DioException catch (e) {
      eventManager.notify(
        ErrorEvent('FAILED_TO_SIGN_IN', e.message),
      );
      return false;
    }
  }

  /// Listens to ALL events dispatched by the SDK.
  ///
  /// Useful for centralized logging in production:
  /// ```dart
  /// flourish.onAllEvent((Event event) {
  ///   developer.log('Event: ${event.name}', name: 'MyApp');
  /// });
  /// ```
  StreamSubscription<Event> onAllEvent(Function callback) {
    return this.onEvent.listen((Event e) {
        callback(e);
    });
  }

  /// Listens to unmapped events (events without a dedicated listener).
  ///
  /// Captures new events from the web app without requiring an SDK update.
  /// Also receives [Event.ERROR_BACK_BUTTON_PRESSED] when the user
  /// presses back on an error page.
  ///
  /// ```dart
  /// flourish.onGenericEvent((GenericEvent event) {
  ///   developer.log('${event.name} - data: ${jsonEncode(event.data?.toJson())}', name: 'MyApp');
  /// });
  /// ```
  StreamSubscription<Event> onGenericEvent(Function callback) {
    return this.onEvent.listen((Event e) {
      if (e is GenericEvent) {
        callback(e);
      }
    });
  }

  /// Fires when the WebView finishes loading the Flourish web app.
  StreamSubscription<Event> onWebViewLoadedEvent(Function callback) {
    return this.onEvent.listen((Event e) {
      if (e is WebViewLoadedEvent) {
        callback(e);
      }
    });
  }

  /// Fires when the user navigates to auto-payment setup.
  StreamSubscription<Event> onAutoPaymentEvent(Function callback) {
    return this.onEvent.listen((Event e) {
      if (e is AutoPaymentEvent) {
        callback(e);
      }
    });
  }

  /// Fires when the user navigates to payment.
  StreamSubscription<Event> onPaymentEvent(Function callback) {
    return this.onEvent.listen((Event e) {
      if (e is PaymentEvent) {
        callback(e);
      }
    });
  }

  /// Fires when a Trivia game finishes (legacy v1 event).
  ///
  /// Prefer [onTriviaGameFinishedEvent] for the v2 event with structured data.
  StreamSubscription<Event> onTriviaFinishedEvent(Function callback) {
    return this.onEvent.listen((Event e) {
      if (e is TriviaFinishedEvent) {
        callback(e);
      }
    });
  }

  /// Fires when the user presses the back button (legacy v1 event).
  ///
  /// Prefer [onBackButtonPressedEvent] for the v2 event with structured data.
  StreamSubscription<Event> onBackEvent(Function callback) {
    return this.onEvent.listen((Event e) {
      if (e is BackEvent) {
        callback(e);
      }
    });
  }

  /// Fires when the user presses the back menu button on the platform.
  ///
  /// Event: [Event.BACK_BUTTON_PRESSED]
  ///
  /// ```dart
  /// flourish.onBackButtonPressedEvent((BackButtonPressedEvent event) {
  ///   developer.log('${event.name} - data: ${jsonEncode(event.data.toJson())}', name: 'MyApp');
  /// });
  /// ```
  StreamSubscription<Event> onBackButtonPressedEvent(Function callback) {
    return this.onEvent.listen((Event e) {
      if (e is BackButtonPressedEvent) {
        callback(e);
      }
    });
  }

  /// Fires when the user finishes a Trivia game.
  ///
  /// Event: [Event.TRIVIA_GAME_FINISHED]
  ///
  /// ```dart
  /// flourish.onTriviaGameFinishedEvent((TriviaGameFinishedEvent event) {
  ///   developer.log('${event.name} - data: ${jsonEncode(event.data.toJson())}', name: 'MyApp');
  /// });
  /// ```
  StreamSubscription<Event> onTriviaGameFinishedEvent(Function callback) {
    return this.onEvent.listen((Event e) {
      if (e is TriviaGameFinishedEvent) {
        callback(e);
      }
    });
  }

  /// Fires when the user closes the Trivia game.
  ///
  /// Event: [Event.TRIVIA_CLOSED]
  StreamSubscription<Event> onTriviaCloseEvent(Function callback) {
    return this.onEvent.listen((Event e) {
      if (e is TriviaCloseEvent) {
        callback(e);
      }
    });
  }

  /// Fires when the user copies the referral code.
  ///
  /// Event: [Event.REFERRAL_COPY]
  StreamSubscription<Event> onReferralCopyEvent(Function callback) {
    return this.onEvent.listen((Event e) {
      if (e is ReferralCopyEvent) {
        callback(e);
      }
    });
  }

  /// Fires when the user copies the Gift Card code.
  ///
  /// Event: [Event.GIFT_CARD_COPY]
  StreamSubscription<Event> onGiftCardCopyEvent(Function callback) {
    return this.onEvent.listen((Event e) {
      if (e is GiftCardCopyEvent) {
        callback(e);
      }
    });
  }

  /// Fires when the user clicks on the home banner.
  ///
  /// Event: [Event.HOME_BANNER_ACTION]
  StreamSubscription<Event> onHomeBannerActionEvent(Function callback) {
    return this.onEvent.listen((Event e) {
      if (e is HomeBannerActionEvent) {
        callback(e);
      }
    });
  }

  /// Fires when the user clicks on a mission card.
  ///
  /// Event: [Event.MISSION_ACTION]
  StreamSubscription<Event> onMissionActionEvent(Function callback) {
    return this.onEvent.listen((Event e) {
      if (e is MissionActionEvent) {
        callback(e);
      }
    });
  }

  /// Listens to ERROR events from the web app (network, business logic,
  /// onboarding, maintenance errors).
  ///
  /// Event: [Event.ERROR]. The [ErrorEvent] contains [ErrorEvent.code]
  /// and [ErrorEvent.message] with error details.
  ///
  /// For production logging, use `dart:developer` `log()`:
  /// ```dart
  /// flourish.onErrorEvent((ErrorEvent event) {
  ///   developer.log(
  ///     'Error: ${event.code} - ${event.message}',
  ///     name: 'MyApp',
  ///     level: 1000,
  ///   );
  /// });
  /// ```
  ///
  /// **Note:** You can also handle errors via the [onError] callback in
  /// the [Flourish] constructor which provides a [BuildContext] for navigation.
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

  WebviewContainer home() {
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
