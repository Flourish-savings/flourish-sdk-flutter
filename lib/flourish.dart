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
import 'package:flourish_flutter_sdk/web_view/flourish_token_error_page.dart';
import 'package:flourish_flutter_sdk/web_view/webview_container.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'events/types/auto_payment_event.dart';
import 'events/types/back_event.dart';
import 'events/types/payment_event.dart';
import 'events/types/trivia_finished_event.dart';
import 'events/types/v2/back_button_pressed_event.dart';
import 'events/types/v2/gift_card_copy_event.dart';
import 'events/types/v2/home_banner_action_event.dart';
import 'events/types/v2/mission_action_event.dart';
import 'events/types/v2/open_external_url_event.dart';
import 'events/types/v2/referral_copy_event.dart';
import 'events/types/v2/trivia_close_event.dart';
import 'events/types/v2/trivia_game_finished_event.dart';

class Flourish {
  EventManager eventManager = EventManager();
  late ApiService service;
  late Environment environment;
  late String uuid;
  late String secret;
  String? version;
  String? trackingId;
  late Language language;
  late String customerCode;
  late String category;
  late WebviewContainer webviewContainer;
  late Endpoint endpoint;
  late bool reloadPageOnAppResume;
  void Function(BuildContext context, WebResourceError error)? onWebViewLoadError;
  void Function(BuildContext context)? onAuthError;

  /// Called when the web app emits an [Event.ERROR].
  ///
  /// When provided, the integrator owns the error UI and the SDK's default
  /// navigation to its generic error page is suppressed. Regardless of this
  /// callback, the [ErrorEvent] is always published on the [onErrorEvent]
  /// stream, so a stream subscription observes errors but does NOT suppress the
  /// default navigation — use this callback for that.
  void Function(BuildContext context, ErrorEvent error)? onError;
  Widget? onTokenErrorWidget;
  WebViewController? webViewController;
  String token = '';
  String url = '';

  Flourish._({
    required String uuid,
    required String secret,
    String? version,
    String? trackingId,
    required Environment env,
    required Language language,
    required String customerCode,
    required bool reloadPageOnAppResume,
    void Function(BuildContext context, WebResourceError error)? onWebViewLoadError,
    void Function(BuildContext context)? onAuthError,
    void Function(BuildContext context, ErrorEvent error)? onError,
    Widget? onTokenErrorWidget,
  }) {
    this.uuid = uuid;
    this.secret = secret;
    this.environment = env;
    this.language = language;
    this.version = version;
    this.trackingId = trackingId;
    this.endpoint = Endpoint(environment);
    this.service = ApiService(env, this.endpoint);
    this.customerCode = customerCode;
    this.reloadPageOnAppResume = reloadPageOnAppResume;
    this.onWebViewLoadError = onWebViewLoadError;
    this.onAuthError = onAuthError;
    this.onError = onError;
    this.onTokenErrorWidget = onTokenErrorWidget;
  }

  static Future<Flourish> create({
    required String uuid,
    required String secret,
    required Environment env,
    required Language language,
    required String customerCode,
    bool reloadPageOnAppResume = true,
    void Function(BuildContext context, WebResourceError error)? onWebViewLoadError,
    void Function(BuildContext context)? onAuthError,
    void Function(BuildContext context, ErrorEvent error)? onError,
    Widget? onTokenErrorWidget,
    String? version,
    String? trackingId,
  }) async {
    final flourish = Flourish._(
      uuid: uuid,
      secret: secret,
      version: version,
      trackingId: trackingId,
      env: env,
      language: language,
      customerCode: customerCode,
      reloadPageOnAppResume: reloadPageOnAppResume,
      onWebViewLoadError: onWebViewLoadError,
      onAuthError: onAuthError,
      onError: onError,
      onTokenErrorWidget: onTokenErrorWidget,
    );

    await flourish.authenticate(customerCode: customerCode);

    return flourish;
  }

  bool get isTokenValid => token.isNotEmpty;

  Future<String> refreshToken() async {
    return token = await this.authenticate(
      customerCode: customerCode,
      category: category,
    );
  }

  Future<String> authenticate({
    required String customerCode,
    String category = "",
  }) async {
    try {
      this.customerCode = customerCode;
      this.category = category;
      Response response = await service.authenticate(
        this.uuid,
        this.secret,
        customerCode,
        category,
        this.language.code,
        SdkInfo.version,
      );

      token = response.data['session_token'];
      url = response.data['url'];

      return token;
    } on DioException catch (_) {
      eventManager.notify(
        GenericEvent(event: Event.AUTHENTICATION_FAILURE),
      );
      return "";
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

  /// Fires when the web app opens an external URL (e.g. a partner store link).
  ///
  /// Event: [Event.OPEN_EXTERNAL_URL]. The SDK already opens the URL in the
  /// device's default browser; this stream is for observability only (e.g.
  /// analytics). [OpenExternalUrlEvent.data] exposes the `url`.
  StreamSubscription<Event> onOpenExternalUrlEvent(Function callback) {
    return this.onEvent.listen((Event e) {
      if (e is OpenExternalUrlEvent) {
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
  /// [Flourish.create] which provides a [BuildContext] for navigation.
  StreamSubscription<Event> onErrorEvent(Function callback) {
    return this.onEvent.listen((Event e) {
      if (e is ErrorEvent) {
        callback(e);
      }
    });
  }

  Stream<Event> get onEvent => eventManager.onEvent;

  /// Opens the Flourish module.
  ///
  /// Pass [redirectTo] to deep-link straight into a specific page instead of
  /// the default entry point — for example, to send a user who tapped a push
  /// notification directly to a partner store. [redirectTo] is a web-app page
  /// key (e.g. `'PARTNER_STORE_DETAIL'`) and [resourceId] is the optional id
  /// for pages that target a specific resource (e.g. the store id). Both are
  /// optional; omit them for the default behavior.
  ///
  /// ```dart
  /// // Default:
  /// flourish.home();
  /// // Deep-link to a specific store:
  /// flourish.home(redirectTo: 'PARTNER_STORE_DETAIL', resourceId: '123');
  /// ```
  Widget home({String? redirectTo, String? resourceId}) {
    final errorWidget =
        onTokenErrorWidget ?? FlourishTokenErrorPage(flourish: this);
    if (!isTokenValid) return errorWidget;
    return _openHome(redirectTo: redirectTo, resourceId: resourceId);
  }

  Widget _openHome({String? redirectTo, String? resourceId}) {
    return webviewContainer = WebviewContainer(
      flourish: this,
      environment: environment,
      apiToken: token,
      platformUrl: url,
      language: language,
      eventManager: eventManager,
      endpoint: endpoint,
      version: version,
      trackingId: trackingId,
      sdkVersion: SdkInfo.version,
      redirectTo: redirectTo,
      resourceId: resourceId,
    );
  }

  WebviewContainer getWebViewContainer() => webviewContainer;
}
