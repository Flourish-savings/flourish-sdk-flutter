import 'package:flourish_flutter_sdk/flourish.dart';
import 'package:flourish_flutter_sdk/web_view/webview_container.dart';
import 'package:flutter/material.dart';

class LoadPageErrorView extends StatefulWidget {

  final LoadPageErrorState _wcs = new LoadPageErrorState();
  final Flourish flourish;

  LoadPageErrorView({
    Key? key,
    required this.flourish,
  }) : super(key: key);

  @override
  LoadPageErrorState createState() {
    _wcs.config(flourish);
    return _wcs;
  }
}

class LoadPageErrorState extends State<LoadPageErrorView> {
  late Flourish _flourish;

  late String title;
  late String description;
  late String buttonText;

  void config(Flourish flourish) {
    this._flourish = flourish;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget> [
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>WebviewContainer(
                              environment: this._flourish.environment,
                              apiToken: this._flourish.token,
                              language: this._flourish.language,
                              eventManager: this._flourish.eventManager,
                              endpoint: this._flourish.endpoint,
                              flourish: this._flourish,
                              version: this._flourish.version,
                              trackingId: this._flourish.trackingId
                            )
                        ),
                      );
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
        ],
      ),
    );
  }
}
