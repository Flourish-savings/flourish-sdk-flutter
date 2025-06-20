import 'package:flourish_flutter_sdk/config/language.dart';
import 'package:flourish_flutter_sdk/events/event.dart';
import 'package:flourish_flutter_sdk/flourish.dart';
import 'package:flutter/material.dart';
import '../events/types/generic_event.dart';

class GenericErrorPageView extends StatefulWidget {
  final Flourish flourish;

  GenericErrorPageView({
    super.key,
    required this.flourish,
  });

  @override
  GenericErrorPageState createState() => GenericErrorPageState();
}

class GenericErrorPageState extends State<GenericErrorPageView> {
  String get title {
    switch (widget.flourish.language) {
      case Language.english:
        return 'Oops, something went wrong!';
      case Language.spanish:
        return 'Huy! Algo salió mal.';
      case Language.portugues:
        return 'Opa, algo deu errado.';
    }
  }

  String get description {
    switch (widget.flourish.language) {
      case Language.english:
        return 'Please, contact us through support.';
      case Language.spanish:
        return 'Por favor, contacta con soporte.';
      case Language.portugues:
        return 'Por favor, contate o nosso suporte.';
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
              GenericEvent(event: Event.ERROR_BACK_BUTTON_PRESSED),
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
                title,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 16),
              Text(
                description,
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
