import 'dart:async';
import 'dart:convert';

import 'package:flourish_flutter_sdk/config/endpoint.dart';
import 'package:flourish_flutter_sdk/config/environment_enum.dart';
import 'package:flourish_flutter_sdk/config/language.dart';
import 'package:flourish_flutter_sdk/events/event.dart';
import 'package:flourish_flutter_sdk/events/event_manager.dart';
import 'package:flourish_flutter_sdk/flourish.dart';
import 'package:flourish_flutter_sdk/web_view/auth_error_page.dart';
import 'package:flourish_flutter_sdk/web_view/webview_load_error_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
    if (kDebugMode) print(uri.toString());
    return controller.loadRequest(uri);
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
    if (kDebugMode) print(message.message);

    try {
      final json = jsonDecode(message.message);
      final eventName = json['eventName'];

      switch (eventName) {
        case "REFERRAL_COPY":
          unawaited(_handleReferralCopy(json['data']));
          break;
        case "INVALID_TOKEN":
          unawaited(handleAuthError());
          break;
        default:
          _handleGenericEvent(json);
      }
    } catch (e) {
      if (kDebugMode) print('Error handling JS message: $e');
    }
  }

  Future<void> _handleReferralCopy(dynamic data) async {
    final referralCode = data['referralCode'];
    if (referralCode == null) return print('referralCode is empty');
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

  Future<void> handleAuthError() async {
    final onAuthError = flourish.onAuthError;
    if (onAuthError != null) return onAuthError(context);
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AuthErrorPage(flourish: flourish),
      ),
    );
  }

  Future<dynamic> handleLoadingPageError(WebResourceError error) async {
    if (error.errorType == WebResourceErrorType.connect ||
        error.errorType == WebResourceErrorType.timeout ||
        error.errorType == WebResourceErrorType.hostLookup ||
        error.errorCode == -1009) {
      final onWebViewLoadError = flourish.onWebViewLoadError;
      if (onWebViewLoadError != null) return onWebViewLoadError(context, error);

      return Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WebViewLoadErrorPage(flourish: flourish),
        ),
      );
    }
  }
}
