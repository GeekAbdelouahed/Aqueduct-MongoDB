import '../../hello_aqueduct.dart';

class MongoDBController {
  Db _db;

  Db get db => _db;

  Future<void> open() async {
    _db = await Db.create(Constants.host);
    await _db.open();
    return Future.value();
  }

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
