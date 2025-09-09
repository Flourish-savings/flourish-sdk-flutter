import 'dart:async';

import 'package:flourish_flutter_sdk/flourish.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AuthErrorPage extends StatefulWidget {
  const AuthErrorPage({
    super.key,
    required this.flourish,
  });

  final Flourish flourish;

  @override
  State<StatefulWidget> createState() => AuthErrorPageState();
}

class AuthErrorPageState extends State<AuthErrorPage> {
  @override
  void initState() {
    super.initState();
    unawaited(refreshToken());
  }

  @override
  void reassemble() {
    super.reassemble();
    unawaited(refreshToken());
  }

  Future<void> refreshToken() async {
    try {
      await widget.flourish.refreshToken();
      if (!mounted) return;
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => widget.flourish.home()),
      );
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: 40.0,
          vertical: 120.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
    );
  }
}
