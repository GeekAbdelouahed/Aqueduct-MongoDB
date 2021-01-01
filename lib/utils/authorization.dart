import '../hello_aqueduct.dart';

abstract class AuthorizationUtils {
  static Future<RequestOrResponse> verifyAuthorization(Request request) async {
    final token = request.raw.headers.value('Authorization');

    final isTokenValid = TokenUtils.isTokenValid(token);

    if (isTokenValid)
      return request;
    else
      return Response.unauthorized(body: {
        'status': false,
        'message': 'Unauthorized',
      });
  }
}
