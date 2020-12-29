import '../hello_aqueduct.dart';

class RegisterController extends ResourceController {
  RegisterController(this._db);

  final Db _db;

  @Operation.post()
  Future<Response> register(@Bind.body() Map<String, dynamic> user) async {
    if (!user.containsKey('first_name'))
      return Response.badRequest(body: {
        'status': false,
        'message': 'FirstName is Required',
      });
    if (!user.containsKey('last_name'))
      return Response.badRequest(body: {
        'status': false,
        'message': 'LastName is Required',
      });
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

    final salt = PasswordUtils.getRandomSlat();
    final hashedPassword =
        PasswordUtils.hashPassword('${user['password']}', salt);
    final token = TokenUtils.generatToken([
      user['first_name'] as String,
      user['last_name'] as String,
      user['email'] as String,
    ]);

    try {
      final createdUser = await _db.collection('users').insert({
        'first_name': user['first_name'],
        'last_name': user['last_name'],
        'email': user['email'],
        'password': hashedPassword,
        'salt': salt,
        'token': token,
      });
      if (createdUser != null)
        return Response.created('', body: {
          'status': true,
          'message': 'user created successfully',
          'token': token,
        });
      else
        return Response.serverError(body: {
          'status': false,
          'message': 'user created failed!',
        });
    } catch (e) {
      return Response.serverError(body: {
        'status': false,
        'message': 'Email already exist!',
      });
    }
  }
}
