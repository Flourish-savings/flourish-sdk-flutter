import 'package:dio/dio.dart';
import 'package:flourish_flutter_sdk/endpoint.dart';
import 'package:flourish_flutter_sdk/environment_enum.dart';

class MainService {
  Dio? _api;
  String? _token;

  MainService(Environment env, Endpoint endpoint) {
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

  Future<bool> checkForNotifications() async {
    try {
      Response res = await _api!.get(
        "/notifications",
        options: Options(
          headers: {
            "Authorization": "Bearer $_token", // set content-length
          },
        ),
      );
      return res.data['notifications'];
    } on DioError catch (e) {
      throw e;
    }
  }
}
