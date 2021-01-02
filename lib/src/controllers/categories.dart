import '../../hello_aqueduct.dart';

class CategoriesController extends ResourceController {
  CategoriesController(this._db);
  final Db _db;

  final String _collection = 'categories';

  @Operation.post()
  Future<Response> createCategory(
      @Bind.body() Map<String, dynamic> category) async {
    if (!category.containsKey('name'))
      return Response.badRequest(body: {
        'status': false,
        'message': 'Name is Required',
      });

    try {
      final createdCategory = await _db.collection(_collection).insert({
        'name': category['name'],
      });
      if (createdCategory != null)
        return Response.created('', body: {
          'status': true,
          'message': 'Category created successfully',
        });
      else
        return Response.serverError(body: {
          'status': false,
          'message': 'Category created failed!',
        });
    } catch (e) {
      print(e);
      return Response.serverError(body: {
        'status': false,
        'message': 'Category already exist!',
      });
    }
  }

  @Operation.get()
  Future<Response> getCategories() async {
    try {
      final categories = await _db.collection(_collection).find().toList();

      if (categories != null) {
        return Response.ok({
          'status': true,
          'message': 'Categories found successfully',
          'data': categories,
        });
      } else
        return Response.notFound(body: {
          'status': false,
          'message': 'Categories not found!',
        });
    } catch (e) {
      print(e);
      return Response.serverError(body: {
        'status': false,
        'message': 'Categories not found!',
      });
    }
  }

  @Operation.delete()
  Future<Response> deleteCategory(
      @Bind.body() Map<String, dynamic> category) async {
    try {
      if (!category.containsKey('category_id'))
        return Response.badRequest(body: {
          'status': false,
          'message': 'Category id is required!',
        });

      await _db.collection(_collection).remove(
        {
          '_id': ObjectId.parse(category['category_id'] as String),
        },
      );

      return Response.ok({
        'status': true,
        'message': 'Category deleted successfully',
      });
    } catch (e) {
      print(e);
      return Response.serverError(body: {
        'status': false,
        'message': 'Category not found!',
      });
    }
  }
}
