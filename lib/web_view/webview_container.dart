import 'dart:convert';

import 'package:clipboard/clipboard.dart';
import 'package:flourish_flutter_sdk/config/endpoint.dart';
import 'package:flourish_flutter_sdk/config/environment_enum.dart';
import 'package:flourish_flutter_sdk/events/event.dart';
import 'package:flourish_flutter_sdk/events/event_manager.dart';
import 'package:flourish_flutter_sdk/flourish.dart';
import 'package:flourish_flutter_sdk/web_view/error_view.dart';
import 'package:flourish_flutter_sdk/web_view/load_page_error_view.dart';
import 'package:flutter/material.dart';
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

class WebviewContainerState extends State<WebviewContainer> with WidgetsBindingObserver {
  late Flourish flourish;
  late WebViewController controller;
  bool _wasPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = WebViewController()
      ..setBackgroundColor(Colors.white)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'AppChannel',
        onMessageReceived: (JavaScriptMessage message) {
          print(message.message);

          Map<String, dynamic> json = jsonDecode(message.message);
          final eventName = json['eventName'];
          if (eventName == "REFERRAL_COPY") {
            var referralCode = json['data']['referralCode'];
            FlutterClipboard.copy(referralCode);
            Share.share(referralCode);
            return;
          }
          if (eventName == "INVALID_TOKEN") {
            openErrorScreen();
          }
          Event event = Event.fromJson(json);
          this._notify(event);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {
            openLoadPageErrorScreen(error);
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.endsWith('.pdf')) {
              _launchURL(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );
    _loadWebView();
  }

  void _loadWebView() {
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

    print(fullUrl);
    final encoded = Uri.encodeFull(fullUrl);

    controller.loadRequest(Uri.parse(encoded));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _loadWebView();
    }
  }

  void config(Flourish flourish) {
    this.flourish = flourish;
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

  void _notify(Event event) {
    widget.eventManager.notify(event);
  }

  void openErrorScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => ErrorView(flourish: this.flourish)),
    );
  }

  void openLoadPageErrorScreen(WebResourceError error) {
    if (error.errorType == WebResourceErrorType.connect ||
        error.errorType == WebResourceErrorType.timeout ||
        error.errorType == WebResourceErrorType.hostLookup ||
        error.errorCode == -1009) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => LoadPageErrorView(flourish: this.flourish)),
      );
    }
  }
}
