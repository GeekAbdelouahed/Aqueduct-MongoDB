import '../../hello_aqueduct.dart';

class ArticlesController extends ResourceController {
  ArticlesController(this._db) {
    acceptedContentTypes = [ContentType('multipart', 'form-data')];
  }
  final Db _db;

  final String _collection = 'articles';

  // TODO support emoji content
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
        'user_id': ObjectId.parse(
          await multipartsUtils.getValue('user_id'),
        ),
        'category_id': multipartsUtils.containsKey('category_id')
            ? ObjectId.parse(
                await multipartsUtils.getValue('category_id'),
              )
            : null,
        'images': imagesPath,
        'created_at': DateTime.now().toString(),
      });

      return Response.created('', body: {
        'status': true,
        'message': 'Article created successfully',
      });
    } catch (e) {
      print(e);
      return Response.serverError(body: {
        'status': false,
        'message': 'Article created failed!',
      });
    }
  }

  @Operation.get()
  Future<Response> getArticles({@Bind.query('query') String query}) async {
    try {
      final selector = where.sortBy('created_at', descending: true);

      // Search by title
      if (query?.isNotEmpty ?? false)
        selector.match(
          'title',
          query,
          caseInsensitive: true,
        );

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
    @requiredBinding @Bind.path('id') String id, {
    @Bind.query('userId') String userId,
  }) async {
    try {
      if (id?.isEmpty ?? true)
        return Response.badRequest(body: {
          'status': false,
          'message': 'Article id is required!',
        });

      final pipeline = AggregationPipelineBuilder()
          .addStage(Match(
            where.id(ObjectId.parse(id)).map['\$query'],
          ))
          .addStage(Lookup.withPipeline(
            from: 'favorites',
            let: {},
            pipeline: [
              Match(
                where
                    .eq(
                      'user_id',
                      userId != null ? ObjectId.parse(userId) : null,
                    )
                    .map['\$query'],
              ),
              Match(
                where.eq('article_id', ObjectId.parse(id)).map['\$query'],
              ),
            ],
            as: 'isFavorite',
          ))
          .addStage(Project(
            {
              'title': 1,
              'content': 1,
              'images': 1,
              'created_at': 1,
              'user_id': 1,
              'category_id': 1,
              'isFavorite': Gt(Size('\$isFavorite'), 0),
            },
          ))
          .build();

      final article = await _db
          .collection(_collection)
          .aggregateToStream(pipeline)
          .toList();

      if (article != null) {
        return Response.ok({
          'status': true,
          'message': 'Article found successfully',
          'data': article.first,
        });
      } else
        return Response.notFound(body: {
          'status': false,
          'message': 'Article not found!',
        });
    } catch (e) {
      print(e);
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

  @Operation.get('userId')
  Future<Response> getArticleByUser(
      @requiredBinding @Bind.path('userId') String userId) async {
    try {
      if (userId?.isEmpty ?? true)
        return Response.badRequest(body: {
          'status': false,
          'message': 'User id is required!',
        });

      final article = await _db.collection(_collection).find(
        {'user_id': ObjectId.parse(userId)},
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
