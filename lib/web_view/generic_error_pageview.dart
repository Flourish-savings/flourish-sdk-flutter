import 'package:flourish_flutter_sdk/flourish.dart';
import 'package:flutter/material.dart';
import '../events/types/generic_event.dart';

class GenericErrorPageView extends StatefulWidget {

  final GenericErrorPageState _wcs = new GenericErrorPageState();
  final Flourish flourish;

  GenericErrorPageView({
    Key? key,
    required this.flourish,
  }) : super(key: key);

  @override
  GenericErrorPageState createState() {
    _wcs.config(flourish);
    return _wcs;
  }
}

class GenericErrorPageState extends State<GenericErrorPageView> {
  late String title;
  late String description;

  void config(Flourish flourish) {
    switch (flourish.language.name) {
      case "english":
        this.title = 'Oops, something went wrong!';
        this.description = 'Please, contact us through support.';
        break;
      case "spanish":
        this.title = 'Huy! Algo salió mal.';
        this.description = 'Por favor, contacta con soporte.';
        break;
      case "portugues":
        this.title = 'Opa, algo deu errado.';
        this.description = 'Por favor, contate o nosso suporte.';
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            widget.flourish.eventManager.notify(
              GenericEvent(event: "ERROR_BACK_BUTTON_PRESSED"),
            );
          },
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 100),
              Image.asset(
                'packages/flourish_flutter_sdk/assets/images/page_error.png',
                width: 100,
                height: 100,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 24),
              Text(
                'Error',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                this.title,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 16),
              Text(
                this.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
