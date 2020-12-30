import 'package:http_server/http_server.dart';

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
    if (!multipartsUtils.containsKey('image'))
      return Response.badRequest(body: {
        'status': false,
        'message': 'Image is Required',
      });

    final articleId = ObjectId();

    final filePath = 'public/images/article${articleId.toHexString()}.jpg';

    await multipartsUtils.saveFile(filePath);

    try {
      await _db.collection('articles').insert({
        '_id': articleId,
        'title': await multipartsUtils.getValue('title'),
        'content': await multipartsUtils.getValue('content'),
        'user_id': await multipartsUtils.getValue('user_id'),
        'image': filePath,
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
}
