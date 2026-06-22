import 'dart:async';
import 'dart:convert';

import 'package:flourish_flutter_sdk/config/endpoint.dart';
import 'package:flourish_flutter_sdk/config/environment_enum.dart';
import 'package:flourish_flutter_sdk/config/language.dart';
import 'package:flourish_flutter_sdk/events/event.dart';
import 'package:flourish_flutter_sdk/events/event_manager.dart';
import 'package:flourish_flutter_sdk/flourish.dart';
import 'package:flourish_flutter_sdk/utils/logger.dart';
import 'package:flourish_flutter_sdk/web_view/auth_error_page.dart';
import 'package:flourish_flutter_sdk/web_view/error_presentation.dart';
import 'package:flourish_flutter_sdk/web_view/webview_load_error_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'flourish_token_error_page.dart';

class WebviewContainer extends StatefulWidget {
  final Environment environment;
  final String apiToken;
  final String platformUrl;
  final Language language;
  final EventManager eventManager;
  final Endpoint endpoint;
  final Flourish flourish;
  final String? version;
  final String? trackingId;
  final String? sdkVersion;

  WebviewContainer({
    super.key,
    required this.environment,
    required this.apiToken,
    required this.platformUrl,
    required this.language,
    required this.eventManager,
    required this.endpoint,
    required this.flourish,
    this.version,
    this.trackingId,
    this.sdkVersion,
  });

  Uri get initialLink {
    final uri = Uri.https(platformUrl);

    final queryParams = <String, String>{
      'token': apiToken,
      'lang': language.code,
    };

    return uri.replace(queryParameters: queryParams);
  }

  @override
  WebviewContainerState createState() => WebviewContainerState();
}

class WebviewContainerState extends State<WebviewContainer>
    with WidgetsBindingObserver {
  late Flourish flourish;
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    flourish = widget.flourish;
    controller = WebViewController()
      ..setBackgroundColor(Colors.white)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'AppChannel',
        onMessageReceived: _handleJavaScriptMessage,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: handleLoadingPageError,
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.endsWith('.pdf')) {
              unawaited(_launchURL(request.url));
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageFinished: (String url) async {
            final statusCode = await controller.runJavaScriptReturningResult(
                'window.performance.getEntries().find(e => e.entryType === "navigation").responseStatus'
            );

            final content = await controller.runJavaScriptReturningResult(
                'document.documentElement.innerText'
            ) as String;

            if (statusCode == 403 &&
                content.contains('AccessDenied')) {
              await _replaceWithErrorPage(FlourishTokenErrorPage(flourish: flourish));
            }
          },
        ),
      );
    flourish.webViewController = controller;
    unawaited(_loadWebView(widget.initialLink));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (flourish.reloadPageOnAppResume && state == AppLifecycleState.resumed) {
      unawaited(_loadWebView(widget.initialLink));
    }
  }

  @override
  void didUpdateWidget(WebviewContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.flourish != oldWidget.flourish) {
      flourish = widget.flourish;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    flourish.webViewController = null;
    super.dispose();
  }

  Future<void> _loadWebView(Uri uri) async {
    FlourishLog.info('Loading URL: ${FlourishLog.redactUri(uri)}');
    return controller.loadRequest(uri);
  }

  /// Replaces the current route with [page], guarding against a disposed widget.
  ///
  /// Centralizes the `mounted` check + `pushReplacement` boilerplate shared by
  /// every error-page navigation in this container.
  Future<void> _replaceWithErrorPage(Widget page) async {
    if (!mounted) return;
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: true,
        child: WebViewWidget(controller: controller),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    await launchUrl(uri);
  }

  void _handleJavaScriptMessage(JavaScriptMessage message) {
    try {
      final json = jsonDecode(message.message);
      final eventName = json['eventName'];
      FlourishLog.info('JS event received: $eventName');

      switch (eventName) {
        case "REFERRAL_COPY":
          unawaited(_handleReferralCopy(json['data']));
          break;
        case "INVALID_TOKEN":
          unawaited(handleAuthError());
          break;
        case "ERROR":
          unawaited(handleWebAppError(json));
          break;
        default:
          _handleGenericEvent(json);
      }
    } catch (e) {
      FlourishLog.severe('Error handling JS message', error: e);
    }
  }

  Future<void> _handleReferralCopy(dynamic data) async {
    final referralCode = data['referralCode'];
    if (referralCode == null) {
      FlourishLog.warning('referralCode is empty');
      return;
    }
    await Clipboard.setData(ClipboardData(text: referralCode));
    await Share.share(referralCode);
  }

  void _handleGenericEvent(Map<String, dynamic> json) {
    final event = Event.fromJson(json);
    _notify(event);
  }

  void _notify(Event event) {
    widget.eventManager.notify(event);
  }

  /// Handles an `INVALID_TOKEN` (401) event from the web app.
  ///
  /// Contract: if [Flourish.onAuthError] is provided, the integrator takes over
  /// the UI and the default navigation is suppressed. Otherwise the SDK shows
  /// [AuthErrorPage]. (Auth failures are not emitted on the event stream.)
  Future<void> handleAuthError() async {
    final onAuthError = flourish.onAuthError;
    switch (resolveErrorPresentation(
        isMounted: mounted, hasCallback: onAuthError != null)) {
      case ErrorPresentation.none:
        return;
      case ErrorPresentation.invokeCallback:
        return onAuthError!(context);
      case ErrorPresentation.navigateToFallback:
        return _replaceWithErrorPage(AuthErrorPage(flourish: flourish));
    }
  }

  /// Handles an `ERROR` event from the web app (network, business logic,
  /// onboarding, maintenance, etc.).
  ///
  /// Contract: the [ErrorEvent] is ALWAYS published on the event stream
  /// ([Flourish.onErrorEvent]) for observers. Separately, if
  /// [Flourish.onError] is provided, the integrator takes over the UI and the
  /// default navigation is suppressed; otherwise the SDK falls back to
  /// [FlourishTokenErrorPage], which renders a generic "something went wrong /
  /// contact support" screen (despite its name, it is not auth-specific).
  Future<void> handleWebAppError(Map<String, dynamic> json) async {
    final errorEvent = ErrorEvent.fromJson(json);
    _notify(errorEvent);

    final onError = flourish.onError;
    switch (resolveErrorPresentation(
        isMounted: mounted, hasCallback: onError != null)) {
      case ErrorPresentation.none:
        return;
      case ErrorPresentation.invokeCallback:
        return onError!(context, errorEvent);
      case ErrorPresentation.navigateToFallback:
        return _replaceWithErrorPage(FlourishTokenErrorPage(flourish: flourish));
    }
  }

  Future<dynamic> handleLoadingPageError(WebResourceError error) async {
    FlourishLog.severe(
      'WebView Load Error - code: ${error.errorCode}, '
      'type: ${error.errorType}, '
      'description: ${error.description}, '
      'isForMainFrame: ${error.isForMainFrame}',
    );

    if (error.errorCode == 403) {
      return _replaceWithErrorPage(FlourishTokenErrorPage(flourish: flourish));
    }

    if (error.errorType == WebResourceErrorType.connect ||
        error.errorType == WebResourceErrorType.timeout ||
        error.errorType == WebResourceErrorType.hostLookup ||
        error.errorCode == -1009) {
      FlourishLog.warning(
        'Network connectivity error detected - invoking error handler',
      );

      final onWebViewLoadError = flourish.onWebViewLoadError;
      if (onWebViewLoadError != null) return onWebViewLoadError(context, error);

      return _replaceWithErrorPage(WebViewLoadErrorPage(flourish: flourish));
    }
  }
}
