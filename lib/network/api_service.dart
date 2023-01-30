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
      String partnerId, String partnerSecret, String customerCode, String category) async {
    try {
      final Map<String, String> requestData = {
        "partner_uuid": partnerId,
        "partner_secret": partnerSecret,
        "customer_code": customerCode
      };

      if (category.isNotEmpty) {
        requestData["category"] = category;
      }

      Response res = await _api!.post(
        '/access_token',
        data: requestData,
      );
      _token = res.data['access_token'];
      return _token!;
    } on DioError catch (e) {
      throw e;
    }
  }

  Future<bool> signIn() async {
    try {
      await _api!.post(
        '/sign_in',
        options: Options(
          headers: {
            "Authorization": "Bearer $_token", // set content-length
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
