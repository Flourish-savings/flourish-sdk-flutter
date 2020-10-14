import 'package:dio/dio.dart';

class MainService {
  Dio _api = Dio(
    BaseOptions(baseUrl: "https://flourish-bknd.herokuapp.com/api/v1/"),
  );

  Future<String> authenticate(int clientId, String clientSecret) async {
    Response res = await _api.post(
      '/access_token',
      data: {
        "client_id": clientId,
        "client_secret": clientSecret,
      },
    );
    return res.data['access_token'];
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
