import 'package:flourish_flutter_sdk/config/language.dart';
import 'package:flourish_flutter_sdk/flourish.dart';
import 'package:flourish_flutter_sdk/web_view/webview_container.dart';
import 'package:flutter/material.dart';

class LoadPageErrorView extends StatefulWidget {
  final Flourish flourish;

  LoadPageErrorView({
    super.key,
    required this.flourish,
  });

  @override
  LoadPageErrorState createState() => LoadPageErrorState();
}

class LoadPageErrorState extends State<LoadPageErrorView> {
  String get title {
    switch (widget.flourish.language) {
      case Language.english:
        return 'No internet \n connection';
      case Language.spanish:
        return 'No hay conexión \n a internet';
      case Language.portugues:
        return 'Não há conexão \n de internet';
    }
  }

  String get description {
    switch (widget.flourish.language) {
      case Language.english:
        return 'Please, make sure your internet \n connection is working and try again!';
      case Language.spanish:
        return 'Por favor, asegúrese de que su conexión a \n internet esté funcionando correctamente \n e intente nuevamente.';
      case Language.portugues:
        return 'Por favor, assegura-se de que sua \n conexão com a internet está funcionando \n corretamente e tente novamente';
    }
  }

  String get buttonText {
    switch (widget.flourish.language) {
      case Language.english:
        return 'Try again';
      case Language.spanish:
        return 'Intentar  nuevamente';
      case Language.portugues:
        return 'Tentar novamente';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
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
                      padding: EdgeInsets.only(
                        bottom: 10.0,
                      ), // 20.0 is the margin value
                      child: Center(
                        child: Text(
                          title,
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
                      padding: EdgeInsets.only(
                        bottom: 30.0,
                      ), // 20.0 is the margin value
                      child: Center(
                        child: Text(
                          description,
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
                        elevation: 4,
                        // Change the elevation to add a shadow
                        shadowColor: Colors.black,
                        // Optionally change the shadow color
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.white54,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        minimumSize: Size(
                          MediaQuery.sizeOf(context).width / 1.12,
                          60,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WebviewContainer(
                              environment: widget.flourish.environment,
                              apiToken: widget.flourish.token,
                              platformUrl: widget.flourish.url,
                              language: widget.flourish.language,
                              eventManager: widget.flourish.eventManager,
                              endpoint: widget.flourish.endpoint,
                              flourish: widget.flourish,
                              version: widget.flourish.version,
                              trackingId: widget.flourish.trackingId,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        buttonText,
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
        ],
      ),
    );
  }
}
