import '../../hello_aqueduct.dart';

class LoginController extends ResourceController {
  LoginController(this._db);

  final Db _db;

  final String _collection = 'users';

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
      final savedUser = await _db.collection(_collection).findOne({
        'email': user['email'],
      });

      if (savedUser == null)
        return Response.notFound(body: {
          'status': false,
          'message': 'User not found!',
        });

      final isPasswordValid = PasswordUtils.isPasswordValid(
        user['password'] as String,
        savedUser['salt'] as String,
        savedUser['password'] as String,
      );

      if (isPasswordValid) {
        final token = TokenUtils.generatToken(
          [user['email'] as String],
        );

        return Response.ok({
          'status': true,
          'message': 'login successfully',
          'data': {
            '_id': savedUser['_id'],
            'token': token,
          }
        });
      } else
        return Response.unauthorized(body: {
          'status': false,
          'message': 'Email or password wrong!',
        });
    } catch (e) {
      return Response.serverError(body: {
        'status': false,
        'message': 'Login failed!',
      });
    }
  }
}
