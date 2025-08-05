import 'package:dio/dio.dart';
import 'package:flourish_flutter_sdk/config/endpoint.dart';
import 'package:flourish_flutter_sdk/config/environment_enum.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  late final Dio httpClient;
  String? _token;

  ApiService(Environment env, Endpoint endpoint) {
    this.httpClient = Dio(
      BaseOptions(baseUrl: endpoint.getBackend().toString()),
    );
  }

  Future<Response> authenticate(
    String partnerId,
    String partnerSecret,
    String customerCode,
    String category,
    String language,
    String sdkVersion,
  ) async {
    final requestData = {
      "uuid": partnerId,
      "secret": partnerSecret,
      "customer_code": customerCode,
      "metadata": {
        "sdk_version": sdkVersion,
        "platform": "flutter",
        "language": language
      }
    };

    Response res = await httpClient.post(
      '/authentication',
      data: requestData,
    );
    return res;
  }

  Future<bool> signIn(String sdkVersion) async {
    await httpClient.post(
      '/sign_in',
      options: Options(
        headers: {
          "Authorization": "Bearer $_token",
          "Sdk-Version": "$sdkVersion"
        },
      ),
    );
    if (kDebugMode) print("[flourish]: logged in");
    return true;
  }
}
