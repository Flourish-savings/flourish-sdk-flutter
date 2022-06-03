import 'package:flourish_flutter_sdk/environment_enum.dart';
import 'package:flourish_flutter_sdk_example/client_enum.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Credential {
  final String parterId;
  final String secretId;
  final Environment environment;
  final ClientEnum clientEnum;

  Credential({
    required this.parterId,
    required this.secretId,
    required this.clientEnum,
    required this.environment,
  });

  bool empty() {
    return this.parterId.isEmpty || this.secretId.isEmpty;
  }
}

class CredentialFactory {
  CredentialFactory({
    required this.clientEnum,
    required this.environment,
  });

  final Environment environment;
  final ClientEnum clientEnum;

  static const PARTNER_ID_PREFIX = 'PARTNER_ID_';
  static const PARTNER_SECRET_PREFIX = 'PARTNER_SECRET_';

  Future<Credential> credential() async {
    await dotenv.load(fileName: '.env');
    String? partnerId = dotenv.env[partnerIdEnvKey()];
    String? secretId = dotenv.env[partnerSecretEnvKey()];
    return Credential(
      parterId: partnerId ?? '',
      secretId: secretId ?? '',
      clientEnum: this.clientEnum,
      environment: this.environment
    );
  }

  String partnerIdEnvKey() {
    return "$PARTNER_ID_PREFIX${_suffix()}";
  }

  String partnerSecretEnvKey() {
    return "$PARTNER_SECRET_PREFIX${_suffix()}";
  }

  String _suffix() {
    return "${environment.toEnvValue()}_${clientEnum.toEnvValue()}";
  }
}
