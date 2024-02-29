import 'package:flourish_flutter_sdk/config/environment_enum.dart';

class Endpoint {

  final Environment environment;

  const Endpoint(this.environment);

  final Map<Environment, String> _backendUrlMapper = const {
    Environment.production: "https://api.flourishfi.com/api/v1",
    Environment.staging: "https://api-stg.flourishfi.com/api/v1",
    Environment.development: "http://10.0.2.2:3000/api/v1",
  };

  final Map<Environment, String> _frontendUrlMapperV2 = const {
    Environment.production: "https://flourish-app.flourishfi.com",
    Environment.staging: "https://flourish-app-stg.flourishfi.com",
    Environment.development: "http://10.0.2.2:3001",
  };

  final Map<Environment, String> _frontendUrlMapperV3 = const {
    Environment.production: "https://platform.flourishfi.com",
    Environment.staging: "https://platform-stg.flourishfi.com",
    Environment.development: "http://10.0.2.2:3001",
  };

  String getFrontendV2() {
    return _frontendUrlMapperV2[environment] ??
        _frontendUrlMapperV2[Environment.staging]!;
  }

  String getFrontendV3() {
    return _frontendUrlMapperV3[environment] ??
        _frontendUrlMapperV3[Environment.staging]!;
  }

  String getBackend() {
    return _backendUrlMapper[environment] ??
        _backendUrlMapper[Environment.staging]!;
  }
}