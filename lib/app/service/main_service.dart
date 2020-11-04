import 'package:dio/dio.dart';

class MainService {
  Dio _api = Dio(
    BaseOptions(baseUrl: "https://staging.flourishsavings.com/api/v1"),
  );

  String _token;

  Future<String> authenticate(String partnerId, String partnerSecret) async {
    try {
      Response res = await _api.post(
        '/access_token',
        data: {
          "partner_uuid": partnerId,
          "partner_secret": partnerSecret,
        },
      );
      _token = res.data['access_token'];
      return _token;
    } on DioError catch (e) {
      throw e;
    }
  }

  Future<bool> signIn(String customerCode) async {
    try {
      await _api.post(
        '/sign_in',
        data: {
          "customer_code": customerCode,
        },
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
      Response res = await _api.get("/notifications");
      return res.data['notifications'];
    } on DioError catch (e) {
      throw e;
    }
  }
}
