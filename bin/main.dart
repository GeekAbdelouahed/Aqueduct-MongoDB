import 'package:hello_aqueduct/hello_aqueduct.dart';

Future main() async {
  final app = Application<HelloAqueductChannel>()
    ..options.configurationFilePath = "config.yaml"
    ..options.port = 8888;

  await app.start();
}
