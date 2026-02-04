import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:clipboard/clipboard.dart';
import 'package:flourish_flutter_sdk/config/endpoint.dart';
import 'package:flourish_flutter_sdk/config/environment_enum.dart';
import 'package:flourish_flutter_sdk/events/event.dart';
import 'package:flourish_flutter_sdk/events/event_manager.dart';
import 'package:flourish_flutter_sdk/flourish.dart';
import 'package:flourish_flutter_sdk/web_view/error_view.dart';
import 'package:flourish_flutter_sdk/web_view/load_page_error_view.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/language.dart';
import 'package:share_plus/share_plus.dart';

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
    Key? key,
    required this.environment,
    required this.apiToken,
    required this.language,
    required this.eventManager,
    required this.endpoint,
    required this.flourish,
    this.version,
    this.trackingId,
    this.sdkVersion,
  }) : super(key: key);

  final WebviewContainerState _wcs = new WebviewContainerState();

  @override
  WebviewContainerState createState() {
    _wcs.config(this.flourish);
    return _wcs;
  }
}

class WebviewContainerState extends State<WebviewContainer> {
  late Flourish flourish;
  bool _isLoading = true;

  void config(Flourish flourish) {
    this.flourish = flourish;
  }

  @override
  Widget build(BuildContext context) {
    String url = "";
    String fullUrl = "";

    if (widget.version != null && widget.version != "") {
      url = widget.version == "V2"
          ? widget.endpoint.getFrontendV2()
          : widget.endpoint.getFrontendV3();

      fullUrl = widget.version == "V2"
          ? "$url/${widget.language.code()}?token=${widget.apiToken}"
          : "$url?${widget.language.code()}&token=${widget.apiToken}";
    } else {
      url = widget.endpoint.getFrontendV3();
      fullUrl = "$url?lang=${widget.language.code()}&token=${widget.apiToken}";
    }

    if (widget.trackingId != null) {
      fullUrl = "$fullUrl&ga_tracking=${widget.trackingId}";
    }

    if (widget.sdkVersion != null) {
      fullUrl = "$fullUrl&sdk_version=${widget.sdkVersion}";
    }

    developer.log('Loading URL: $fullUrl', name: 'FlourishSDK');

    var controller = WebViewController()
      ..setBackgroundColor(Colors.white)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'AppChannel',
        onMessageReceived: (JavaScriptMessage message) {
          _handleJavaScriptMessage(message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {
              handleLoadingPageError(error);
            },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.endsWith('.pdf')) {
              _launchURL(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(fullUrl));


    return Container(
      color: Colors.white,
      child: SafeArea(
        top: true,
        child: WebViewWidget(controller: controller),
      ),
    );
  }

  void _handleJavaScriptMessage(JavaScriptMessage message) {
    developer.log('JS message received: ${message.message}', name: 'FlourishSDK');

    try {
      Map<String, dynamic> json = jsonDecode(message.message);
      final eventName = json['eventName'];

      switch (eventName) {
        case "REFERRAL_COPY":
          var referralCode = json['data']['referralCode'];
          if (referralCode == null) {
            developer.log('referralCode is empty', name: 'FlourishSDK', level: 900);
            return;
          }
          FlutterClipboard.copy(referralCode);
          Share.share(referralCode);
          break;
        case "INVALID_TOKEN":
          handleAuthError();
          break;
        case "ERROR":
          unawaited(handleWebAppError(json));
          break;
        default:
          Event event = Event.fromJson(json);
          _notify(event);
      }
    } catch (e) {
      developer.log('Error handling JS message', name: 'FlourishSDK', error: e);
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    await launchUrl(uri);
  }

  void _notify(Event event) {
    widget.eventManager.notify(event);
  }

  void handleAuthError() {
    if (!mounted) return;

    final onAuthError = flourish.onAuthError;
    if (onAuthError != null) return onAuthError(context);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => ErrorView(flourish: this.flourish)),
    );
  }

  Future<void> handleWebAppError(Map<String, dynamic> json) async {
    final errorEvent = ErrorEvent.fromJson(json);
    _notify(errorEvent);

    if (!mounted) return;

    final onError = flourish.onError;
    if (onError != null) return onError(context, errorEvent);

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => ErrorView(flourish: this.flourish)),
    );
  }

  void handleLoadingPageError(WebResourceError error) {
    developer.log(
      'WebView Load Error - code: ${error.errorCode}, '
      'type: ${error.errorType}, '
      'description: ${error.description}, '
      'isForMainFrame: ${error.isForMainFrame}',
      name: 'FlourishSDK',
      level: 1000,
    );

    if (error.errorCode == 403) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ErrorView(flourish: this.flourish)),
        );
      }
      return;
    }

    if (error.errorType == WebResourceErrorType.connect ||
        error.errorType == WebResourceErrorType.timeout ||
        error.errorType == WebResourceErrorType.hostLookup ||
        error.errorCode == -1009) {
      developer.log(
        'Network connectivity error detected - invoking error handler',
        name: 'FlourishSDK',
        level: 900,
      );

      this._notify(
        ErrorEvent('NETWORK_CONNECTION_ERROR', error.description),
      );

      final onWebViewLoadError = flourish.onWebViewLoadError;
      if (onWebViewLoadError != null) return onWebViewLoadError(context, error);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => LoadPageErrorView(flourish: this.flourish)),
        );
      }
    }
  }
}
