import 'package:dio/dio.dart';
import 'package:flourish_flutter_sdk/config/endpoint.dart';
import 'package:flourish_flutter_sdk/config/environment_enum.dart';

class ApiService {
  Dio? _api;
  String? _token;

  ApiService(Environment env, Endpoint endpoint) {
    var baseOptions = BaseOptions(baseUrl: endpoint.getBackend());
    this._api = Dio(baseOptions);
  }

  Future<String> authenticate(
      String partnerId, String partnerSecret, String customerCode) async {
    try {
      Response res = await _api!.post(
        '/access_token',
        data: {
          "partner_uuid": partnerId,
          "partner_secret": partnerSecret,
          "customer_code": customerCode
        },
      );
      _token = res.data['access_token'];
      return _token!;
    } on DioError catch (e) {
      throw e;
    }
  }

  Future<bool> signIn(String apiToken) async {
    try {
      await _api!.post(
        '/sign_in',
        options: Options(
          headers: {
            "Authorization": "Bearer $apiToken", // set content-length
          },
        ),
      );
      print("logged in");
      return true;
    } on DioError catch (e) {
      throw e;
    }
  }
}
