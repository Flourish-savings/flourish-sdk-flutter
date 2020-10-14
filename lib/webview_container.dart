import 'dart:convert';

import 'package:flourish_flutter_sdk/environment_enum.dart';
import 'package:flourish_flutter_sdk/event.dart';
import 'package:flourish_flutter_sdk/event_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';

class WebviewContainer extends StatefulWidget {
  WebviewContainer({
    Key key,
    this.environment,
    this.apiToken,
    this.userId,
    this.eventManager,
  }) : super(key: key);

  final WebviewContainerState _wcs = new WebviewContainerState();

  final Environment environment;
  final String apiToken;
  final String userId;
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
    // this._controller.loadUrl(url, headers: {
    //   "x-flourish-partner-key": widget.partnerId,
    //   "x-flourish-external-user-id": widget.userId,
    //   "x-flourish-external-session-id": widget.sessionId,
    //   "Authorization":
    //       'Basic AXVubzpwQDU1dzByYM==', // this is our JTW (Flourish) that we got from the authentication process
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: SafeArea(
        top: true,
        child: WebView(
          initialUrl: "${_getUrl(widget.environment)}?token=${widget.apiToken}&code=${widget.userId}",
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
            Event event = WebviewLoadedEvent();
            _controller = controller;
            this._notify(event);
          },
        ),
      ),
    );
  }

  String _getUrl(Environment env) {
    switch (env) {
      case Environment.production:
        {
          // return http://api.flourish.com/v1/dashboard
          return "http://bancosol-mvp.s3-website-us-east-1.amazonaws.com/";
        }
      // case Environment.development:
      //   {
      //     return "https://flourish-engine.herokuapp.com/webviews/dashboard/230";
      //   }
      // case Environment.staging:
      //   {
      //     return "https://flourish-engine.herokuapp.com/webviews/dashboard/230";
      //   }

      default:
        {
          return "http://bancosol-mvp.s3-website-us-east-1.amazonaws.com/";
        }
    }
  }

  void _notify(Event event) {
    widget.eventManager.notify(event);
  }
}
