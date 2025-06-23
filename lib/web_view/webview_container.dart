import 'dart:async';
import 'dart:convert';

import 'package:flourish_flutter_sdk/config/endpoint.dart';
import 'package:flourish_flutter_sdk/config/environment_enum.dart';
import 'package:flourish_flutter_sdk/events/event.dart';
import 'package:flourish_flutter_sdk/events/event_manager.dart';
import 'package:flourish_flutter_sdk/flourish.dart';
import 'package:flourish_flutter_sdk/web_view/error_view.dart';
import 'package:flourish_flutter_sdk/web_view/load_page_error_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../config/language.dart';

class WebviewContainer extends StatefulWidget {
  final Environment environment;
  final String apiToken;
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
    required this.language,
    required this.eventManager,
    required this.endpoint,
    required this.flourish,
    this.version,
    this.trackingId,
    this.sdkVersion,
  });

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
          onWebResourceError: (WebResourceError error) {
            openLoadPageErrorScreen(error);
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.endsWith('.pdf')) {
              unawaited(_launchURL(request.url));
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );
    _loadWebView();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _loadWebView();
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
    super.dispose();
  }

  void _loadWebView() {
    if (widget.version == "V2") {
      _loadV2WebView();
    } else {
      _loadV3WebView();
    }
  }

  void _loadV2WebView() {
    final uri = widget.endpoint.getFrontendV2();

    final queryParams = <String, String>{
      'token': widget.apiToken,
    };

    _addOptionalParams(queryParams);

    final finalUri = uri.replace(
      path: '${uri.path}/${widget.language.code}',
      queryParameters: queryParams,
    );

    _loadUri(finalUri);
  }

  void _loadV3WebView() {
    final uri = widget.endpoint.getFrontendV3();

    final queryParams = <String, String>{
      'token': widget.apiToken,
      'lang': widget.language.code,
    };

    _addOptionalParams(queryParams);

    final finalUri = uri.replace(queryParameters: queryParams);
    _loadUri(finalUri);
  }

  void _addOptionalParams(Map<String, String> queryParams) {
    if (widget.trackingId != null) {
      queryParams['ga_tracking'] = widget.trackingId!;
    }

    if (widget.sdkVersion != null) {
      queryParams['sdk_version'] = widget.sdkVersion!;
    }
  }

  void _loadUri(Uri uri) {
    if (kDebugMode) print(uri.toString());
    controller.loadRequest(uri);
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
          _handleReferralCopy(json['data']);
          break;
        case "INVALID_TOKEN":
          unawaited(openErrorScreen());
          break;
        default:
          _handleGenericEvent(json);
      }
    } catch (e) {
      if (kDebugMode) print('Error handling JS message: $e');
    }
  }

  void _handleReferralCopy(dynamic data) {
    final referralCode = data['referralCode'];
    if (referralCode == null) return;
    unawaited(Clipboard.setData(ClipboardData(text: referralCode)));
    unawaited(Share.share(referralCode));
  }

  void _handleGenericEvent(Map<String, dynamic> json) {
    final event = Event.fromJson(json);
    _notify(event);
  }

  void _notify(Event event) {
    widget.eventManager.notify(event);
  }

  Future<void> openErrorScreen() {
    return Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ErrorView(flourish: flourish),
      ),
    );
  }

  Future<dynamic> openLoadPageErrorScreen(WebResourceError error) async {
    if (error.errorType == WebResourceErrorType.connect ||
        error.errorType == WebResourceErrorType.timeout ||
        error.errorType == WebResourceErrorType.hostLookup ||
        error.errorCode == -1009) {
      return Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoadPageErrorView(flourish: flourish),
        ),
      );
    }
  }
}
