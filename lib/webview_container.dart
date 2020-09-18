import 'dart:convert';

import 'package:flourish_flutter_sdk/event.dart';
import 'package:flourish_flutter_sdk/event_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';

class WebviewContainer extends StatefulWidget {
  WebviewContainer(
      {Key key, this.authenticationKey, this.url, this.eventManager})
      : super(key: key);

  final WebviewContainerState _wcs = new WebviewContainerState();

  // final String title;
  final String url;
  final String authenticationKey;
  final EventManager eventManager;

  void loadUrl(String url) {
    _wcs.loadUrl(url);
  }

  @override
  WebviewContainerState createState() => _wcs;
}

class WebviewContainerState extends State<WebviewContainer> {
  WebViewController _controller;

  void loadUrl(String url) {
    this._controller.loadUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: SafeArea(
        top: true,
        child: WebView(
          initialUrl: widget.url,
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
            Event event = WebviewLoaded();
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
