import 'package:flourish_flutter_sdk/environment_enum.dart';
import 'package:flourish_flutter_sdk/webview_container.dart';

class Flourish {
  Environment environment;
  String userId;
  String secretKey;
  WebviewContainer _webviewContainer;
  static final Flourish _instance = Flourish._privateConstructor();

  Flourish._privateConstructor();

  factory Flourish.initialize(Environment env) {
    _instance.environment = env;
    return _instance;
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
    this._webviewContainer = new WebviewContainer(
        url: this._getUrl(), authenticationKey: authenticationKey);
  }

  void on(String eventName, Function callback) {
    this._webviewContainer?.registerObserver(eventName, callback);
  }

  WebviewContainer webviewContainer() {
    return this._webviewContainer;
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
