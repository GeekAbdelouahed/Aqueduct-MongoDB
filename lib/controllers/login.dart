import '../hello_aqueduct.dart';

class LoginController extends ResourceController {
  LoginController(this._db);

  final Db _db;

  @Operation.post()
  Future<Response> login(@Bind.body() Map<String, dynamic> user) async {
    if (!user.containsKey('email'))
      return Response.badRequest(body: {
        'status': false,
        'message': 'Email is Required',
      });
    if (!user.containsKey('password'))
      return Response.badRequest(body: {
        'status': false,
        'message': 'Password is Required',
      });

    try {
      final oldUser = await _db.collection('users').findOne({
        'email': user['email'],
      });

      if (oldUser == null)
        return Response.notFound(body: {
          'status': false,
          'message': 'User not found!',
        });

      final isPasswordValid = PasswordUtils.isPasswordValid(
        user['password'] as String,
        oldUser['salt'] as String,
        oldUser['password'] as String,
      );

      if (isPasswordValid)
        return Response.ok({
          'status': true,
          'message': 'login successfully',
          'token': oldUser['token'],
        });
      else
        return Response.unauthorized(body: {
          'status': false,
          'message': 'Email or password wrong!',
        });
    } catch (e) {
      return Response.badRequest(body: {
        'status': false,
        'message': 'Email already exist!',
      });
    }
  }
}
