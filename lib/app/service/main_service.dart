import 'package:dio/dio.dart';

class MainService {
  Dio _api = Dio(
    BaseOptions(baseUrl: "https://staging-api-flourish.herokuapp.com/api/v1"),
  );

  Future<String> authenticate(String partnerId, String partnerSecret) async {
    try {
      Response res = await _api.post(
        '/access_token',
        data: {"partner_uuid": partnerId, "partner_secret": partnerSecret},
      );
      return res.data['access_token'];
    } on DioError catch (e) {
      print(e);
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
