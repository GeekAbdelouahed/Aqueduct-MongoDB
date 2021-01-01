import '../../hello_aqueduct.dart';

class MongoDBController {
  final _db = Db(Constants.host);

  Db get db => _db;

  Future<void> open() => _db.open();

  Future<void> initIndex() => Future.any(
        [
          _db.collection('users').createIndex(
            keys: {'email': 1},
            unique: true,
          ),
          _db.collection('categories').createIndex(
            keys: {'name': 1},
            unique: true,
          )
        ],
      );

  Future<void> close() => _db.close();
}
