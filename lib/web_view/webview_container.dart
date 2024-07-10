import 'dart:convert';

import 'package:flourish_flutter_sdk/config/endpoint.dart';
import 'package:flourish_flutter_sdk/config/environment_enum.dart';
import 'package:flourish_flutter_sdk/events/event.dart';
import 'package:flourish_flutter_sdk/events/event_manager.dart';
import 'package:flourish_flutter_sdk/flourish.dart';
import 'package:flourish_flutter_sdk/web_view/load_page_error_view.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../events/types/web_view_loaded_event.dart';

class WebviewContainer extends StatefulWidget {
  WebviewContainer({
    Key? key,
    required this.environment,
    required this.apiToken,
    required this.eventManager,
    required this.endpoint,
    required this.flourish,
  }) : super(key: key);

  final WebviewContainerState _wcs = new WebviewContainerState();

  final Environment environment;
  final String apiToken;
  final EventManager eventManager;
  final Endpoint endpoint;
  final Flourish flourish;

  void loadUrl(String url) {
    _wcs.loadUrl(url);
  }

  @override
  WebviewContainerState createState() {
    _wcs.config(this.flourish);
    return _wcs;
  }
}

class WebviewContainerState extends State<WebviewContainer> {
  late WebViewController _controller;
  late Flourish flourish;
  bool isVisible = true;

  late String title;
  late String description;
  late String buttonText;

  void config(Flourish flourish) {
    this.flourish = flourish;

    switch (flourish.language.name) {
      case "english":
        this.title = 'No internet \n connection';
        this.description = 'Please, make sure your internet \n connection is working and try again!';
        this.buttonText = 'Try again';
        break;
      case "spanish":
        this.title = 'No hay conexión \n a internet';
        this.description = 'Por favor, asegúrese de que su conexión a \n internet esté funcionando correctamente \n e intente nuevamente.';
        this.buttonText = 'Intentar  nuevamente';
        break;
      case "portugues":
        this.title = 'Não há conexão \n de internet';
        this.description = 'Por favor, assegura-se de que sua \n conexão com a internet está funcionando \n corretamente e tente novamente';
        this.buttonText = 'Tentar novamente';
        break;
    }
  }

  void toggleVisibility() {
    setState(() {
      isVisible = !isVisible;
    });
  }

  void loadUrl(String url) {
    this._controller.loadUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    String url = widget.endpoint.getFrontend();
    String fullUrl = "$url&token=${widget.apiToken}&sdk_version=2.5.5";
    debugPrint("Full URL $fullUrl");
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: true,
        child: isVisible
            ? WebView(
          initialUrl: fullUrl,
          debuggingEnabled: true,
          onWebResourceError: (error) {
            toggleVisibility();
          },
          navigationDelegate: (NavigationRequest request) {
            if (request.url.endsWith('.pdf')) {
              _launchURL(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          javascriptMode: JavascriptMode.unrestricted,
          javascriptChannels: Set.from([
            JavascriptChannel(
                name: 'AppChannel',
                onMessageReceived: (JavascriptMessage message) {
                  Map<String, dynamic> json = jsonDecode(message.message);
                  final eventName = json['eventName'];
                  Event event = Event.fromJson(json);
                  this._notify(event);
                })
          ]),
          onWebViewCreated: (WebViewController controller) {
            Event event = WebViewLoadedEvent();
            _controller = controller;
            this._notify(event);
          },
        )
            :
        Container(
          color: Colors.white,
          height: double.infinity,
          alignment: Alignment.center,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: 40.0,
              vertical: 120.0,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.signal_wifi_off,
                    size: 120.0,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20.0),
                  Padding(
                    padding: EdgeInsets.only(bottom: 10.0), // 20.0 is the margin value
                    child: Center(
                      child: Text(
                        this.title,
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                          fontSize: 24.0,
                          fontFamily: 'OpenSans',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 30.0), // 20.0 is the margin value
                    child: Center(
                      child: Text(
                        this.description,
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                          fontFamily: 'OpenSans',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 4, // Change the elevation to add a shadow
                      shadowColor: Colors.black, // Optionally change the shadow color
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.white54,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      minimumSize:
                      Size(MediaQuery.of(context).size.width / 1.12, 60),
                    ),
                    onPressed: () {
                      toggleVisibility();
                    },
                    child: Text(
                      this.buttonText,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    await launchUrl(uri);
  }

  void openLoadPageErrorScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => LoadPageErrorView(flourish: this.flourish)),
    );
  }

  void _notify(Event event) {
    widget.eventManager.notify(event);
  }
}
