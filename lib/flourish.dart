import 'package:flourish_flutter_sdk/environment_enum.dart';
import 'package:flourish_flutter_sdk/webview_container.dart';

class Flourish {
  Environment environment;
  String userId;
  String secretKey;
  WebviewContainer webviewContainer;
  static final Flourish _instance = Flourish._privateConstructor();

  Flourish._privateConstructor();

  factory Flourish() {
    return _instance;
  }

  Flourish.initialize(Environment env) {
    this.environment = env;
  }

  String authenticate(String userId, String secretKey) {
    return 'key';
  }

  String authenticateAndOpenDashboard(String userId, String secretKey) {
    String key = this.authenticate(userId, secretKey);
    this.openDashboard(key);
    return key;
  }

  void openDashboard(String authenticationKey) {
    this.webviewContainer = new WebviewContainer(
        url: this._getUrl(), authenticationKey: authenticationKey);
    // this.webviewContainer.loadUrl();
  }

  void on(String eventName, Function callback) {
    this.webviewContainer.registerObserver(eventName, callback);
  }

  String _getUrl() {
    switch (this.environment) {
      case Environment.production:
        {
          return "https://flourish-engine.herokuapp.com/webviews/dashboard/230";
        }
      // case Environment.development:
      //   {
      //     return "https://flourish-engine.herokuapp.com/webviews/dashboard/230";
      //   }
      // case Environment.staging:
      //   {
      //     return "https://flourish-engine.herokuapp.com/webviews/dashboard/230";
      //   }

      default:
        {
          return "https://flourish-engine.herokuapp.com/webviews/dashboard/230";
        }
    }
  }
}
