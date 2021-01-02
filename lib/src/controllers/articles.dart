import '../../hello_aqueduct.dart';

class ArticlesController extends ResourceController {
  ArticlesController(this._db) {
    acceptedContentTypes = [ContentType('multipart', 'form-data')];
  }
  final Db _db;

  final String _collection = 'articles';

  @Operation.post()
  Future<Response> createArticle() async {
    final multipartsUtils = MultipartsUtils(request: request);
    await multipartsUtils.parse();

    if (!multipartsUtils.containsKey('user_id'))
      return Response.badRequest(body: {
        'status': false,
        'message': 'User id is Required',
      });
    if (!multipartsUtils.containsKey('title'))
      return Response.badRequest(body: {
        'status': false,
        'message': 'Title is Required',
      });
    if (!multipartsUtils.containsKey('content'))
      return Response.badRequest(body: {
        'status': false,
        'message': 'Content is Required',
      });
    if (!multipartsUtils.containsFiles())
      return Response.badRequest(body: {
        'status': false,
        'message': 'Image is Required',
      });

    final articleId = ObjectId();

    final imagesPath = await multipartsUtils.saveFiles(articleId.toHexString());

    try {
      await _db.collection(_collection).insert({
        '_id': articleId,
        'title': await multipartsUtils.getValue('title'),
        'content': await multipartsUtils.getValue('content'),
        'user_id': ObjectId.parse(await multipartsUtils.getValue('user_id')),
        'category_id':
            ObjectId.parse(await multipartsUtils.getValue('category_id')),
        'images': imagesPath,
      });

      return Response.created('', body: {
        'status': true,
        'message': 'Article created successfully',
      });
    } catch (e) {
      return Response.serverError(body: {
        'status': false,
        'message': 'Article created failed!',
      });
    }
  }

  @Operation.get()
  Future<Response> getArticles({@Bind.query('query') String query}) async {
    try {
      final selector = query?.isNotEmpty ?? false
          ? where.match('title', query,
              caseInsensitive: true) // Search by title
          : null;

      final articles =
          await _db.collection(_collection).find(selector).toList();

      if (articles != null) {
        return Response.ok({
          'status': true,
          'message': 'Articles found successfully',
          'data': articles,
        });
      } else
        return Response.notFound(body: {
          'status': false,
          'message': 'Articles not found!',
        });
    } catch (e) {
      return Response.serverError(body: {
        'status': false,
        'message': 'Articles not found!',
      });
    }
  }

  @Operation.get('id')
  Future<Response> getArticleById(
      @requiredBinding @Bind.path('id') String id) async {
    try {
      if (id?.isEmpty ?? true)
        return Response.badRequest(body: {
          'status': false,
          'message': 'Article id is required!',
        });

      final article = await _db.collection(_collection).findOne(
            where.id(ObjectId.parse(id)),
          );

      if (article != null) {
        return Response.ok({
          'status': true,
          'message': 'Article found successfully',
          'data': article,
        });
      } else
        return Response.notFound(body: {
          'status': false,
          'message': 'Article not found!',
        });
    } catch (e) {
      return Response.serverError(body: {
        'status': false,
        'message': 'Article not found!',
      });
    }
  }

  @Operation.get('categoryId')
  Future<Response> getArticleByCategory(
      @requiredBinding @Bind.path('categoryId') String categoryId) async {
    try {
      if (categoryId?.isEmpty ?? true)
        return Response.badRequest(body: {
          'status': false,
          'message': 'Category id is required!',
        });

      final article = await _db.collection(_collection).find(
        {'category_id': ObjectId.parse(categoryId)},
      ).toList();

      if (article != null) {
        return Response.ok({
          'status': true,
          'message': 'Articles found successfully',
          'data': article,
        });
      } else
        return Response.notFound(body: {
          'status': false,
          'message': 'Articles not found!',
        });
    } catch (e) {
      print(e);
      return Response.serverError(body: {
        'status': false,
        'message': 'Articles not found!',
      });
    }
  }

  @Operation.delete()
  Future<Response> deleteArticle(
      @Bind.body() Map<String, dynamic> article) async {
    try {
      if (!article.containsKey('article_id'))
        return Response.badRequest(body: {
          'status': false,
          'message': 'Article id is required!',
        });

      await _db.collection(_collection).remove(
        {
          '_id': ObjectId.parse(article['article_id'] as String),
        },
      );

      await MultipartsUtils.deleteFiles(article['article_id'] as String);

      return Response.ok({
        'status': true,
        'message': 'Article deleted successfully',
      });
    } catch (e) {
      print(e);
      return Response.serverError(body: {
        'status': false,
        'message': 'Article not found!',
      });
    }
  }
}
