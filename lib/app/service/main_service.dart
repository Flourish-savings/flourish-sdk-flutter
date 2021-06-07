import 'package:dio/dio.dart';
import 'package:flourish_flutter_sdk/environment_enum.dart';

class MainService {
  Dio? _api;
  String? _token;

  MainService(Environment env) {
    this._api = Dio(
      BaseOptions(
        baseUrl: selectEnvironmentUrl(env),
      ),
    );
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

  String selectEnvironmentUrl(Environment env) {
    switch (env) {
      case Environment.production:
        return "https://api.flourishsavings.com/api/v1";
      case Environment.preproduction:
        return "https://preproduction.flourishsavings.com/api/v1";
      case Environment.development:
      case Environment.staging:
        return "https://staging.flourishsavings.com/api/v1";
      default:
        return "https://staging.flourishsavings.com/api/v1";
    }
  }
}
