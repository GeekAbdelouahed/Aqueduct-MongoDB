import 'package:hello_aqueduct/hello_aqueduct.dart';

class Product extends ManagedObject<_Product> implements _Product {}

class _Product {
  @primaryKey // shorter
  // @Column(primaryKey: true , autoincrement: true)
  int id;
  //@Column(unique: true)
  String title;
  String description;
  double price;
}
