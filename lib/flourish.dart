import 'package:flourish_flutter_sdk/environment_enum.dart';
import 'package:flourish_flutter_sdk/webview_container.dart';
import 'package:flutter/material.dart';

class Flourish {
  Environment environment;
  String userId;
  String secretKey;
  Widget webviewContainer = WebviewContainer();

  Flourish.initialize(Environment env) {
    this.environment = env;
  }

  String authenticate(String userId, String secretKey) {
    return 'key';
  }

  String authenticateAndOpenDashboard(String userId, String secretKey) {
    String key = this.authenticate(userId, secretKey);
    this.openDashboard(key);
    return 'key';
  }

  void openDashboard(String authenticationKey) {
    // this.webviewContainer.loadUrl();
  }
}
