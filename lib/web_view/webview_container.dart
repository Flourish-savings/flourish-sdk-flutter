import 'dart:convert';

import 'package:flourish_flutter_sdk/config/endpoint.dart';
import 'package:flourish_flutter_sdk/config/environment_enum.dart';
import 'package:flourish_flutter_sdk/events/event.dart';
import 'package:flourish_flutter_sdk/events/event_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';

import '../events/types/web_view_loaded_event.dart';

class WebviewContainer extends StatefulWidget {
  WebviewContainer({
    Key? key,
    required this.environment,
    required this.apiToken,
    required this.eventManager,
    required this.endpoint,
  }) : super(key: key);

  final WebviewContainerState _wcs = new WebviewContainerState();

  final Environment environment;
  final String apiToken;
  final EventManager eventManager;
  final Endpoint endpoint;

  void loadUrl(String url) {
    _wcs.loadUrl(url);
  }

  @override
  WebviewContainerState createState() => _wcs;
}

class WebviewContainerState extends State<WebviewContainer> {
  late WebViewController _controller;

  void loadUrl(String url) {
    this._controller.loadUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    String url = widget.endpoint.getFrontend();
    String fullUrl = "$url?token=${widget.apiToken}";
    //debugPrint("Full URL $fullUrl");
    return Container(
      color: Theme.of(context).primaryColor,
      child: SafeArea(
        top: true,
        child: WebView(
          initialUrl: fullUrl,
          debuggingEnabled: true,
          onWebResourceError: (error) {
            print(error.description);
            print(error.domain);
          },
          navigationDelegate: (action) {
            print(action.url);
            return NavigationDecision.navigate;
          },
          javascriptMode: JavascriptMode.unrestricted,
          javascriptChannels: Set.from([
            JavascriptChannel(
                name: 'AppChannel',
                onMessageReceived: (JavascriptMessage message) {
                  Map<String, dynamic> json = jsonDecode(message.message);
                  Event event = Event.fromJson(json);
                  this._notify(event);
                })
          ]),
          onWebViewCreated: (WebViewController controller) {
            Event event = WebViewLoadedEvent();
            _controller = controller;
            this._notify(event);
          },
        ),
      ),
    );
  }

  void _notify(Event event) {
    widget.eventManager.notify(event);
  }
}
