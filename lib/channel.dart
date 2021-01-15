import 'hello_aqueduct.dart';

class HelloAqueductChannel extends ApplicationChannel {
  final _mongoDBController = MongoDBService();

  @override
  Future prepare() async {
    logger.onRecord.listen(
      (rec) => print('$rec ${rec.error ?? ''} ${rec.stackTrace ?? ''}'),
    );

    await _mongoDBController.open();
    await _mongoDBController.initIndex();

    return Future.value();
  }

  @override
  Controller get entryPoint {
    final router = Router();

    router
        .route('/files/articles/*')
        .link(() => FileController('public/images/articles'));

    router
        .route('/auth/login')
        .link(() => LoginController(_mongoDBController.db));

    router
        .route('/auth/register')
        .link(() => RegisterController(_mongoDBController.db));

    router
        .route('/users/[:id]')
        .linkFunction(AuthorizationUtils.verifyAuthorization)
        .link(() => UsersController(_mongoDBController.db));

    router.route('/categories/[:id]').linkFunction((request) {
      switch (request.method) {
        case 'GET':
          return request;
        default:
          return AuthorizationUtils.verifyAuthorization(request);
      }
    }).link(() => CategoriesController(_mongoDBController.db));

    router.route('/articles/[:id]').linkFunction((request) {
      switch (request.method) {
        case 'GET':
          return request;
        default:
          return AuthorizationUtils.verifyAuthorization(request);
      }
    }).link(() => ArticlesController(_mongoDBController.db));

    router.route('/articles/byCategory/[:categoryId]').linkFunction((request) {
      switch (request.method) {
        case 'GET':
          return request;
        default:
          return AuthorizationUtils.verifyAuthorization(request);
      }
    }).link(() => ArticlesController(_mongoDBController.db));

    router
        .route('/articles/byUser/[:userId]')
        .linkFunction(AuthorizationUtils.verifyAuthorization)
        .link(() => ArticlesController(_mongoDBController.db));

    router
        .route('/favorites/[:userId]')
        .linkFunction(AuthorizationUtils.verifyAuthorization)
        .link(() => FavoritesController(_mongoDBController.db));

    return router;
  }

  @override
  Future close() async {
    await _mongoDBController.close();
    return super.close();
  }
}
