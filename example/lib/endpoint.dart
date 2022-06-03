import 'package:flourish_flutter_sdk/endpoint.dart';
import 'package:flourish_flutter_sdk/environment_enum.dart';
import 'package:flourish_flutter_sdk_example/client_enum.dart';
import 'package:flourish_flutter_sdk_example/language.dart';

class BancosolEndpoint extends Endpoint {
  const BancosolEndpoint(environment) : super(environment);

  final Map<Environment, String> _frontendUrlMapper = const {
    Environment.production: "https://dkcpfxodv482r.cloudfront.net/",
    Environment.preproduction: "https://d1yku7yute1fiy.cloudfront.net/",
    Environment.staging: "https://d2hkfqbf7qz8b6.cloudfront.net/",
    Environment.development: "http://localhost:8080/",
  };

  @override
  String getFrontend() {
    return _frontendUrlMapper[environment] ??
        _frontendUrlMapper[Environment.staging]!;
  }
}

class PlatformEndpoint extends Endpoint {
  const PlatformEndpoint(environment, this.language) : super(environment);

  final Language language;

  final Map<Environment, String> _frontendUrlMapper = const {
    Environment.production: "https://flourish-app.flourishfi.com/",
    Environment.preproduction: "https://flourish-app-stg.flourishfi.com/",
    Environment.staging: "https://flourish-app-stg.flourishfi.com/",
    Environment.development: "http://localhost:8080/",
  };

  @override
  String getFrontend() {
    var baseUrl = _frontendUrlMapper[environment] ??
        _frontendUrlMapper[Environment.staging]!;
    String langPath = language.code() != null ? "${language.code()}/" : '' ;
    return baseUrl + langPath;
  }
}

class EndpointFactory {
  EndpointFactory({
    required this.clientEnum,
    required this.environment,
    required this.language,
  });

  final ClientEnum clientEnum;
  final Environment environment;
  final Language language;

  Endpoint build() {
    switch(clientEnum) {
      case ClientEnum.bancosol:
        return BancosolEndpoint(environment);
      default:
        return PlatformEndpoint(environment, language);
    }
  }
}
