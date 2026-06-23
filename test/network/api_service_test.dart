import 'package:flutter_test/flutter_test.dart';
import 'package:flourish_flutter_sdk/config/endpoint.dart';
import 'package:flourish_flutter_sdk/config/environment_enum.dart';
import 'package:flourish_flutter_sdk/network/api_service.dart';

void main() {
  group('ApiService', () {
    test('builds a Dio client pointed at the environment backend', () {
      final endpoint = Endpoint(Environment.staging);
      final service = ApiService(Environment.staging, endpoint);

      expect(service.httpClient.options.baseUrl,
          endpoint.getBackend().toString());
    });
  });
}
