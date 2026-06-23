import 'dart:async';
import 'dart:convert';

import 'package:flourish_flutter_sdk/config/endpoint.dart';
import 'package:flourish_flutter_sdk/config/environment_enum.dart';
import 'package:flourish_flutter_sdk/config/language.dart';
import 'package:flourish_flutter_sdk/events/event.dart';
import 'package:flourish_flutter_sdk/events/event_manager.dart';
import 'package:flourish_flutter_sdk/events/types/v2/open_external_url_event.dart';
import 'package:flourish_flutter_sdk/flourish.dart';
import 'package:flourish_flutter_sdk/utils/logger.dart';
import 'package:flourish_flutter_sdk/web_view/auth_error_page.dart';
import 'package:flourish_flutter_sdk/web_view/error_presentation.dart';
import 'package:flourish_flutter_sdk/web_view/external_url_resolution.dart';
import 'package:flourish_flutter_sdk/web_view/webview_load_error_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'flourish_token_error_page.dart';

/// Builds the initial URL loaded into the WebView.
///
/// Always carries `token` and `lang`. The optional `redirectTo` (a web-app
/// page key) and `resourceId` (e.g. a store id for a dynamic route) are
/// appended only when non-empty — they let the host deep-link into a specific
/// page (see [WebviewContainer.initialLink] / [Flourish.home]). This function
/// is a pure forwarder: validation of these values is the web app's
/// responsibility.
@visibleForTesting
Uri buildInitialLink({
  required String platformUrl,
  required String token,
  required String langCode,
  String? redirectTo,
  String? resourceId,
  bool useHttp = false, // local dev serves the web app over plain HTTP
}) {
  final queryParams = <String, String>{
    'token': token,
    'lang': langCode,
  };

  if (redirectTo != null && redirectTo.isNotEmpty) {
    queryParams['redirectTo'] = redirectTo;
  }
  if (resourceId != null && resourceId.isNotEmpty) {
    queryParams['resourceId'] = resourceId;
  }

  final base = useHttp ? Uri.http(platformUrl) : Uri.https(platformUrl);
  return base.replace(queryParameters: queryParams);
}

/// Which handler an incoming JS-channel message routes to, keyed by its
/// `eventName`. Mirrors the dispatch in [WebviewContainerState].
enum JsMessageRoute { referralCopy, openExternalUrl, invalidToken, error, generic }

/// Pure routing decision for a JS-channel message's `eventName`. Unknown or
/// null names fall through to [JsMessageRoute.generic].
@visibleForTesting
JsMessageRoute resolveJsMessageRoute(String? eventName) {
  switch (eventName) {
    case 'REFERRAL_COPY':
      return JsMessageRoute.referralCopy;
    case 'OPEN_EXTERNAL_URL':
      return JsMessageRoute.openExternalUrl;
    case 'INVALID_TOKEN':
      return JsMessageRoute.invalidToken;
    case 'ERROR':
      return JsMessageRoute.error;
    default:
      return JsMessageRoute.generic;
  }
}

/// What [WebviewContainerState.handleLoadingPageError] should do for a given
/// WebView load error.
enum WebViewLoadAction {
  tokenErrorPage,
  invokeLoadErrorCallback,
  loadErrorPage,
  ignore,
}

/// Pure decision for a WebView load error: a 403 shows the token error page;
/// connectivity errors (connect/timeout/hostLookup or the iOS `-1009` offline
/// code) defer to the integrator callback when present, else the load-error
/// page; anything else is ignored.
@visibleForTesting
WebViewLoadAction resolveWebViewLoadError({
  required int errorCode,
  required WebResourceErrorType? errorType,
  required bool hasCallback,
}) {
  if (errorCode == 403) return WebViewLoadAction.tokenErrorPage;
  if (errorType == WebResourceErrorType.connect ||
      errorType == WebResourceErrorType.timeout ||
      errorType == WebResourceErrorType.hostLookup ||
      errorCode == -1009) {
    return hasCallback
        ? WebViewLoadAction.invokeLoadErrorCallback
        : WebViewLoadAction.loadErrorPage;
  }
  return WebViewLoadAction.ignore;
}

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

  /// Optional deep-link target page (a web-app page key, e.g.
  /// `PARTNER_STORE_DETAIL`). When null/empty the web app lands on its default
  /// entry point.
  final String? redirectTo;

  /// Optional resource id for a dynamic [redirectTo] route (e.g. a store id).
  final String? resourceId;

  /// Whether to load [platformUrl] over plain HTTP. Set only for local
  /// development (see [Flourish] debug overrides); HTTPS otherwise.
  final bool useHttp;

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
    this.redirectTo,
    this.resourceId,
    this.useHttp = false,
  });

  Uri get initialLink => buildInitialLink(
        platformUrl: platformUrl,
        token: apiToken,
        langCode: language.code,
        redirectTo: redirectTo,
        resourceId: resourceId,
        useHttp: useHttp,
      );

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
          // coverage:ignore-start
          // Runs JS in the live WebView engine to detect a 403/AccessDenied
          // page; unreachable in unit tests (no real engine).
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
          // coverage:ignore-end
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

  Future<void> _launchURL(
    String url, {
    LaunchMode mode = LaunchMode.platformDefault,
  }) async {
    final Uri uri = Uri.parse(url);
    await launchUrl(uri, mode: mode);
  }

  void _handleJavaScriptMessage(JavaScriptMessage message) {
    try {
      final json = jsonDecode(message.message);
      final eventName = json['eventName'];
      FlourishLog.info('JS event received: $eventName');

      switch (resolveJsMessageRoute(eventName)) {
        case JsMessageRoute.referralCopy:
          unawaited(_handleReferralCopy(json['data']));
          break;
        case JsMessageRoute.openExternalUrl:
          unawaited(_handleOpenExternalUrl(json));
          break;
        case JsMessageRoute.invalidToken:
          unawaited(handleAuthError());
          break;
        case JsMessageRoute.error:
          unawaited(handleWebAppError(json));
          break;
        case JsMessageRoute.generic:
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

  /// Handles an `OPEN_EXTERNAL_URL` event from the web app.
  ///
  /// The web app asks the host to open an absolute URL outside the WebView
  /// sandbox (e.g. a partner store link). The SDK opens it in the device's
  /// default browser via `url_launcher` with [LaunchMode.externalApplication],
  /// and also publishes the typed [OpenExternalUrlEvent] on the event stream so
  /// integrators can observe the navigation.
  ///
  /// Only `http(s)` URLs are honored (see [resolveExternalUrl]); a missing,
  /// empty, or non-http(s) URL is ignored and not published. The launch is
  /// fire-and-forget, so any launcher failure is caught and logged here rather
  /// than escaping as an uncaught async error.
  Future<void> _handleOpenExternalUrl(Map<String, dynamic> json) async {
    final event = OpenExternalUrlEvent.from(json);
    final url = event.data.url;

    switch (resolveExternalUrl(url)) {
      case ExternalUrlDecision.empty:
        FlourishLog.warning('OPEN_EXTERNAL_URL received with empty url');
        return;
      case ExternalUrlDecision.disallowedScheme:
        FlourishLog.warning(
            'OPEN_EXTERNAL_URL rejected: URL scheme is not http(s)');
        return;
      case ExternalUrlDecision.launch:
        break;
    }

    _notify(event);
    try {
      await _launchURL(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      FlourishLog.severe('Failed to open external URL', error: e);
    }
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

    final onWebViewLoadError = flourish.onWebViewLoadError;
    switch (resolveWebViewLoadError(
      errorCode: error.errorCode,
      errorType: error.errorType,
      hasCallback: onWebViewLoadError != null,
    )) {
      case WebViewLoadAction.tokenErrorPage:
        return _replaceWithErrorPage(FlourishTokenErrorPage(flourish: flourish));
      case WebViewLoadAction.invokeLoadErrorCallback:
        FlourishLog.warning(
          'Network connectivity error detected - invoking error handler',
        );
        return onWebViewLoadError!(context, error);
      case WebViewLoadAction.loadErrorPage:
        FlourishLog.warning(
          'Network connectivity error detected - invoking error handler',
        );
        return _replaceWithErrorPage(WebViewLoadErrorPage(flourish: flourish));
      case WebViewLoadAction.ignore:
        return null;
    }
  }
}
