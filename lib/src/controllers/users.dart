import '../../hello_aqueduct.dart';

class UsersController extends ResourceController {
  UsersController(this._db);

  final Db _db;

  final String _collection = 'users';

  @Operation.get('id')
  Future<Response> getUserInformation(
      @requiredBinding @Bind.path('id') String id) async {
    try {
      if (id?.isEmpty ?? true)
        return Response.badRequest(body: {
          'status': false,
          'message': 'User id is required!',
        });

      final pipeline = AggregationPipelineBuilder()
          .addStage(Match(
            where.id(ObjectId.parse(id)).map['\$query'],
          ))
          .addStage(Project({
            'password': 0,
            'salt': 0,
            'created_at': 0,
            'updated_at': 0,
          }))
          .build();

      final user = await _db
          .collection(_collection)
          .aggregateToStream(pipeline)
          .toList();

      if (user != null) {
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

      await _db.collection(_collection).update(
        {
          '_id': ObjectId.parse(id),
        },
        {
          '\$set': {
            'first_name': user['first_name'],
            'last_name': user['last_name'],
            'email': user['email'],
            'updated_at': DateTime.now().toString(),
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

  @Operation.delete()
  Future<Response> deleteUserInformation(
      @Bind.body() Map<String, dynamic> user) async {
    try {
      if (!user.containsKey('user_id'))
        return Response.badRequest(body: {
          'status': false,
          'message': 'User id is required!',
        });

      await _db.collection(_collection).remove(
        {
          '_id': ObjectId.parse(user['user_id'] as String),
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
