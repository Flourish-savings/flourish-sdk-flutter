import 'package:dio/dio.dart';
import 'package:flourish_flutter_sdk/config/environment_enum.dart';
import 'package:flourish_flutter_sdk/config/language.dart';
import 'package:flourish_flutter_sdk/flourish.dart';
import 'package:flourish_flutter_sdk/network/api_service.dart';
import 'package:mocktail/mocktail.dart';

/// Mock [ApiService] for driving the auth flow without hitting the network.
class MockApiService extends Mock implements ApiService {}

/// Builds a Dio [Response] carrying [data] for stubbing
/// [ApiService.authenticate].
Response<dynamic> authResponse(Map<String, dynamic> data) {
  return Response<dynamic>(
    requestOptions: RequestOptions(path: '/authentication'),
    data: data,
    statusCode: 200,
  );
}

/// A [DioException] for stubbing the auth-failure path.
DioException dioError() {
  return DioException(requestOptions: RequestOptions(path: '/authentication'));
}

/// Builds an authenticated [Flourish] without touching the network.
///
/// Uses the debug static-token override so [Flourish.create] skips the auth
/// backend. Tests that exercise the real auth flow then swap in a
/// [MockApiService] via the returned instance's public `service` field and call
/// `authenticate()` / `refreshToken()` directly.
Future<Flourish> flourishWithStaticToken({
  String token = 'tok',
  Language language = Language.english,
  Environment env = Environment.development,
}) {
  return Flourish.create(
    uuid: 'u',
    secret: 's',
    env: env,
    language: language,
    customerCode: 'c',
    debugStaticToken: token,
  );
}
