import 'package:flourish_flutter_sdk/environment_enum.dart';
import 'package:flourish_flutter_sdk/language.dart';

class Endpoint {

  final Environment environment;
  final Language language;

  const Endpoint(this.environment, this.language);

  final Map<Environment, String> _backendUrlMapper = const {
    Environment.production: "https://api.flourishsavings.com/api/v1",
    Environment.staging: "https://staging.flourishsavings.com/api/v1",
    Environment.development: "http://localhost:3000/api/v1",
  };

  final Map<Environment, String> _frontendUrlMapper = const {
    Environment.production: "https://flourish-app.flourishfi.com/",
    Environment.staging: "https://flourish-app-stg.flourishfi.com/",
    Environment.development: "http://localhost:8080/",
  };

  String getFrontend() {
    var baseUrl = _frontendUrlMapper[environment] ??
        _frontendUrlMapper[Environment.staging]!;
    String langPath = language.code() != null ? "${language.code()}/" : '';
    return baseUrl + langPath;
  }

  String getBackend() {
    return _backendUrlMapper[environment] ??
        _backendUrlMapper[Environment.staging]!;
  }
}