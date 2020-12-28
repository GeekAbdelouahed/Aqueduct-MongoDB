import '../hello_aqueduct.dart';

class UsersController extends ResourceController {
  UsersController(this._db);

  final Db _db;

  @Operation.get('id')
  Future<Response> getUserByToken(
    @Bind.header('Authorization') String token,
    @requiredBinding @Bind.path('id') String id,
  ) async {
    if (id?.isEmpty ?? true)
      return Response.badRequest(body: {
        'status': false,
        'message': 'User id is required!',
      });

    final isTokenValid = TokenUtils.isTokenValid(token);
    if (isTokenValid) {
      final user = await _db.collection('users').findOne(
            where.id(ObjectId.parse(id)),
          );

      if (user != null) {
        user.remove('password');
        return Response.ok({
          'status': true,
          'message': 'User found successfully',
          'data': user,
        });
      } else
        return Response.notFound(body: {
          'status': false,
          'message': 'User not found!',
        });
    } else {
      return Response.unauthorized(body: {
        'status': false,
        'message': 'Request denied!',
      });
    }
  }
}
