import 'package:flourish_flutter_sdk/config/environment_enum.dart';
import 'package:flourish_flutter_sdk/config/language.dart';

class Endpoint {

  final Environment environment;
  final Language language;

  const Endpoint(this.environment, this.language);

  final Map<Environment, String> _backendUrlMapper = const {
    Environment.production: "https://api.flourishsavings.com/api/v1",
    Environment.staging: "https://staging.flourishsavings.com/api/v1",
    Environment.development: "http://10.0.2.2:3000/api/v1",
  };

  final Map<Environment, String> _frontendUrlMapper = const {
    Environment.production: "https://platform.flourishfi.com/",
    Environment.staging: "https://platform-stg.flourishfi.com/",
    Environment.development: "http://10.0.2.2:3001/",
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