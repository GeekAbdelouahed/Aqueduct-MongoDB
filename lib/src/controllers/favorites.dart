import '../../hello_aqueduct.dart';

class FavoritesController extends ResourceController {
  FavoritesController(this._db);
  final Db _db;

  final String _collection = 'favorites';

  @Operation.post()
  Future<Response> createFavorite(
      @Bind.body() Map<String, dynamic> favorite) async {
    if (!favorite.containsKey('user_id'))
      return Response.badRequest(body: {
        'status': false,
        'message': 'User id is Required',
      });

    if (!favorite.containsKey('article_id'))
      return Response.badRequest(body: {
        'status': false,
        'message': 'Article id is Required',
      });

    try {
      final createdFavorite = await _db.collection(_collection).insert({
        'user_id': ObjectId.parse(favorite['user_id'] as String),
        'article_id': ObjectId.parse(favorite['article_id'] as String),
        'created_at': DateTime.now().toString(),
      });
      if (createdFavorite != null)
        return Response.created('', body: {
          'status': true,
          'message': 'Favorite created successfully',
        });
      else
        return Response.serverError(body: {
          'status': false,
          'message': 'Favorite created failed!',
        });
    } catch (e) {
      print(e);
      return Response.serverError(body: {
        'status': false,
        'message': 'Favorite already exist!',
      });
    }
  }

  @Operation.get('userId')
  Future<Response> getFavorites(@Bind.path('userId') String userId) async {
    try {
      final pipeline = AggregationPipelineBuilder()
          .addStage(Match(
            where.eq('user_id', ObjectId.parse(userId)).map['\$query'],
          ))
          .addStage(Lookup(
            from: 'articles',
            localField: 'article_id',
            foreignField: '_id',
            as: 'article',
          ))
          .addStage(Project(
            {
              'article': 1,
            },
          ))
          .addStage(Unwind(
            const Field('article'),
            preserveNullAndEmptyArrays: true,
          ))
          .build();

      final favorites = await _db
          .collection(_collection)
          .aggregateToStream(pipeline)
          .toList();

      if (favorites != null) {
        return Response.ok({
          'status': true,
          'message': 'Favorites found successfully',
          'data': favorites,
        });
      } else
        return Response.notFound(body: {
          'status': false,
          'message': 'Favorites not found!',
        });
    } catch (e) {
      print(e);
      return Response.serverError(body: {
        'status': false,
        'message': 'Favorites not found!',
      });
    }
  }

  @Operation.delete()
  Future<Response> deleteFavorite(
      @Bind.body() Map<String, dynamic> body) async {
    try {
      if (!body.containsKey('favorite_id'))
        return Response.badRequest(body: {
          'status': false,
          'message': 'Favorite id is required!',
        });

      await _db.collection(_collection).remove(
        {
          '_id': ObjectId.parse(body['favorite_id'] as String),
        },
      );

      return Response.ok({
        'status': true,
        'message': 'Favorite deleted successfully',
      });
    } catch (e) {
      print(e);
      return Response.serverError(body: {
        'status': false,
        'message': 'Favorite not found!',
      });
    }
  }
}
