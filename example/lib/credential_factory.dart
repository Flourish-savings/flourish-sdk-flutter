import 'package:flutter_dotenv/flutter_dotenv.dart';

class Credential {
  final String partnerId;
  final String secretId;

  Credential({
    required this.partnerId,
    required this.secretId,
  });

  bool empty() {
    return this.partnerId.isEmpty || this.secretId.isEmpty;
  }
}

class CredentialFactory {

  static const ENV_FILE = '.env';
  static const PARTNER_ID_KEY = 'PARTNER_ID';
  static const PARTNER_SECRET_KEY = 'PARTNER_SECRET';

  Future<Credential> fromEnv() async {
    await dotenv.load(fileName: ENV_FILE);
    String? partnerId = dotenv.env[PARTNER_ID_KEY];
    String? secretId = dotenv.env[PARTNER_SECRET_KEY];
    return Credential(partnerId: partnerId ?? '', secretId: secretId ?? '');
  }
}
