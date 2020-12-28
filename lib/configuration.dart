import 'hello_aqueduct.dart';

class MyConfiguration extends Configuration {
  MyConfiguration() : super.fromFile(File('../config.yaml'));

  DatabaseConfiguration database;
}
