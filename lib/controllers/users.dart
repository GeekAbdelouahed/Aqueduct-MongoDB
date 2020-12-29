import '../hello_aqueduct.dart';

class UsersController extends ResourceController {
  UsersController(this._db);

  final Db _db;

  @Operation.get('id')
  Future<Response> getUserInformation(
      @requiredBinding @Bind.path('id') String id) async {
    try {
      if (id?.isEmpty ?? true)
        return Response.badRequest(body: {
          'status': false,
          'message': 'User id is required!',
        });

      final user = await _db.collection('users').findOne(
            where.id(ObjectId.parse(id)),
          );

      if (user != null) {
        user..remove('password')..remove('salt');
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
    } catch (e) {
      return Response.serverError(body: {
        'status': false,
        'message': 'User not found!',
      });
    }
  }

  @Operation.put('id')
  Future<Response> updateUserInformation(
    @requiredBinding @Bind.path('id') String id,
    @requiredBinding @Bind.body() Map<String, dynamic> user,
  ) async {
    try {
      if (id?.isEmpty ?? true)
        return Response.badRequest(body: {
          'status': false,
          'message': 'User id is required!',
        });

      await _db.collection('users').update(
        {
          '_id': ObjectId.parse(id),
        },
        {
          '\$set': {
            'first_name': user['first_name'],
            'last_name': user['last_name'],
            'email': user['email'],
          }
        },
      );

      return Response.ok({
        'status': true,
        'message': 'User updated successfully',
      });
    } catch (e) {
      return Response.serverError(body: {
        'status': false,
        'message': 'User not found!',
      });
    }
  }

  @Operation.delete('id')
  Future<Response> deleteUserInformation(
    @requiredBinding @Bind.path('id') String id,
  ) async {
    try {
      if (id?.isEmpty ?? true)
        return Response.badRequest(body: {
          'status': false,
          'message': 'User id is required!',
        });

      await _db.collection('users').remove(
        {
          '_id': ObjectId.parse(id),
        },
      );

      return Response.ok({
        'status': true,
        'message': 'User deleted successfully',
      });
    } catch (e) {
      return Response.serverError(body: {
        'status': false,
        'message': 'User not found!',
      });
    }
  }
}
