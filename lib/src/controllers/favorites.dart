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
        'user_id': favorite['user_id'],
        'category_id': favorite['category_id'],
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

  @Operation.get()
  Future<Response> getFavorites() async {
    try {
      final favorites = await _db.collection(_collection).find().toList();

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

  @Operation.delete('id')
  Future<Response> deleteCategory(
      @requiredBinding @Bind.path('id') String id) async {
    try {
      if (id?.isEmpty ?? true)
        return Response.badRequest(body: {
          'status': false,
          'message': 'Favorite id is required!',
        });

      await _db.collection(_collection).remove(
        {
          '_id': ObjectId.parse(id),
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
