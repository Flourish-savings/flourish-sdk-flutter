import 'dart:convert';

import 'package:flourish_flutter_sdk/event.dart';
import 'package:flourish_flutter_sdk/observable.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';

class WebviewContainer extends StatefulWidget {
  const WebviewContainer({Key key, this.title, this.authenticationKey})
      : super(key: key);

  final String title;
  final String authenticationKey;

  @override
  _WebviewContainerState createState() => _WebviewContainerState();
}

class _WebviewContainerState extends State<WebviewContainer> with Observable {
  String _url = "https://flourish-engine.herokuapp.com/webviews/dashboard/230";
  WebViewController _controller;

  void loadUrl() {
    this._controller.loadUrl(this._url);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Container(
      color: Theme.of(context).primaryColor,
      child: SafeArea(
        top: true,
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: WebView(
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
                name: 'Print',
                onMessageReceived: (JavascriptMessage message) {
                  //This is where you receive message from
                  //javascript code and handle in Flutter/Dart
                  //like here, the message is just being printed
                  //in Run/LogCat window of android studio
                  print(message.message);
                  Map<String, dynamic> json = jsonDecode(message.message);
                  Event event = Event.fromJson(json);
                  this.notifyObservers(event);
                })
          ]),
          onWebViewCreated: (WebViewController controller) {
            _controller = controller;
            // _loadHtmlFromAssets('assets/sortorama/index.html', _controller);
          },
        ),
      ),
    );
  }
}
