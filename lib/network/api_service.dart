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

  Future<String> authenticate(
    String partnerId,
    String partnerSecret,
    String customerCode,
    String category,
  ) async {
    final requestData = <String, String>{
      "partner_uuid": partnerId,
      "partner_secret": partnerSecret,
      "customer_code": customerCode,
      if (category.isNotEmpty) "category": category,
    };

    Response res = await httpClient.post(
      '/access_token',
      data: requestData,
    );
    _token = res.data['access_token'];
    return _token!;
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
