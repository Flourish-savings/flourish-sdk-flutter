import 'dart:async';

import 'package:flourish_flutter_sdk/flourish.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ErrorView extends StatefulWidget {
  const ErrorView({
    super.key,
    required this.flourish,
  });

  final Flourish flourish;

  @override
  State<StatefulWidget> createState() => ErrorViewState();
}

class ErrorViewState extends State<ErrorView> {
  late Flourish _flourish;

  @override
  void initState() {
    super.initState();
    setup();
  }

  @override
  void didUpdateWidget(covariant oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.flourish != oldWidget.flourish ||
        widget.flourish.token != oldWidget.flourish.token) {
      setup();
    }
  }

  Future<void> refreshToken() async {
    try {
      await _flourish.refreshToken();
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => _flourish.home()),
      );
    } on Object catch (e) {
      if (kDebugMode) print(e);
    }
  }

  void setup() {
    this._flourish = widget.flourish;
    unawaited(refreshToken());
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
                    Text(
                      'Too long out. Renewing your experience',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 32.0,
                        fontFamily: 'OpenSans',
                      ),
                    ),
                    SpinKitThreeBounce(color: Colors.black),
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
