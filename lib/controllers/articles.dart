import '../hello_aqueduct.dart';

class ArticlesController extends ResourceController {
  ArticlesController(this._db) {
    acceptedContentTypes = [ContentType('multipart', 'form-data')];
  }
  final Db _db;

  @Operation.post()
  Future<Response> create() async {
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
    /*if (!multipartsUtils.containsKey('image'))
      return Response.badRequest(body: {
        'status': false,
        'message': 'Image is Required',
      });*/

    final articleId = ObjectId();

    final imagesPath = await multipartsUtils.saveFiles(articleId.toHexString());

    try {
      await _db.collection('articles').insert({
        '_id': articleId,
        'title': await multipartsUtils.getValue('title'),
        'content': await multipartsUtils.getValue('content'),
        'user_id': await multipartsUtils.getValue('user_id'),
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
  Future<Response> getArticles() async {
    try {
      final articles = await _db.collection('articles').find().toList();

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

      final article = await _db.collection('articles').findOne(
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

  @Operation.delete('id')
  Future<Response> deleteArticle(
      @requiredBinding @Bind.path('id') String id) async {
    try {
      if (id?.isEmpty ?? true)
        return Response.badRequest(body: {
          'status': false,
          'message': 'Article id is required!',
        });

      await _db.collection('articles').remove(
        {
          '_id': ObjectId.parse(id),
        },
      );

      await MultipartsUtils.deleteFiles(id);

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
