import 'dart:convert';

import 'package:flourish_flutter_sdk/event.dart';
import 'package:flourish_flutter_sdk/observable.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';

class WebviewContainer extends StatefulWidget {
  WebviewContainer({Key key, this.authenticationKey, this.url})
      : super(key: key);

  final WebviewContainerState _wcs = new WebviewContainerState();

  // final String title;
  final String url;
  final String authenticationKey;

  void loadUrl(String url) {
    _wcs.loadUrl(url);
  }

  void registerObserver(String eventName, Function callback) {
    _wcs.registerObserver(eventName, callback);
  }

  @override
  WebviewContainerState createState() => _wcs;
}

class WebviewContainerState extends State<WebviewContainer> with Observable {
  WebViewController _controller;

  void loadUrl(String url) {
    this._controller.loadUrl(url);
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
            Event event = new Event(name: 'webview_created', data: null);
            _controller = controller;
            this.notifyObservers(event);
            // _loadHtmlFromAssets('assets/sortorama/index.html', _controller);
          },
        ),
      ),
    );
  }
}
