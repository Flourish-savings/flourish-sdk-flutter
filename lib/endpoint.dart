import 'package:flourish_flutter_sdk/environment_enum.dart';

abstract class Endpoint {

  final Environment environment;

  const Endpoint(this.environment);

  final Map<Environment, String> _backendUrlMapper = const {
    Environment.production: "https://api.flourishsavings.com/api/v1",
    Environment.preproduction: "https://preproduction.flourishsavings.com/api/v1",
    Environment.staging: "https://staging.flourishsavings.com/api/v1",
    Environment.development: "http://localhost:3000/api/v1",
  };

  String getFrontend();

  String getBackend() {
    return _backendUrlMapper[environment] ?? _backendUrlMapper[Environment.staging]!;
  }
}