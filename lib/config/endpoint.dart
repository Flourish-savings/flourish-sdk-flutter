import 'package:flourish_flutter_sdk/config/environment_enum.dart';

class Endpoint {
  final Environment environment;

  Endpoint(this.environment);

  final Map<Environment, Uri> _backendUriMapper = {
    Environment.production: Uri.https('auth.flourishfi.com', '/api/v3'),
    Environment.staging: Uri.https('auth-stg.flourishfi.com', '/api/v3'),
    Environment.development: Uri.https('auth-stg.flourishfi.com', '/api/v3'),
  };

  final Map<Environment, Uri> _frontendUriMapperV2 = {
    Environment.production: Uri.https('flourish-app.flourishfi.com'),
    Environment.staging: Uri.https('flourish-app-stg.flourishfi.com'),
    Environment.development: Uri.http('10.0.2.2:3001'),
  };

  final Map<Environment, Uri> _frontendUriMapperV3 = {
    Environment.production: Uri.https('platform.flourishfi.com'),
    Environment.staging: Uri.https('platform-stg.flourishfi.com'),
    Environment.development: Uri.http('10.0.2.2:3001'),
  };

  Uri getFrontendV2() {
    return _frontendUriMapperV2[environment] ??
        _frontendUriMapperV2[Environment.staging]!;
  }

  Uri getFrontendV3() {
    return _frontendUriMapperV3[environment] ??
        _frontendUriMapperV3[Environment.staging]!;
  }

  Uri getBackend() {
    return _backendUriMapper[environment] ??
        _backendUriMapper[Environment.staging]!;
  }
}
