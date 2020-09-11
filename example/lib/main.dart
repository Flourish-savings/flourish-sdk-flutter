import 'package:flourish_flutter_sdk/environment_enum.dart';
import 'package:flutter/material.dart';
import 'package:flourish_flutter_sdk/flourish.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Flourish flourish = Flourish.initialize(Environment.development);

  @override
  void initState() {
    super.initState();
    flourish.authenticateAndOpenDashboard('a', 'b');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: null,
        body: Center(
          child: flourish.webviewContainer,
        ),
      ),
    );
  }
}
