import 'package:{{project_name.snakeCase()}}/app/app.dart';
import 'package:{{project_name.snakeCase()}}/app/bootstrap.dart';
import 'package:{{project_name.snakeCase()}}/app/flavors.dart';

Future<void> main() async {
  FlavorConfig.init(Flavor.prod);
  await bootstrap(() => const App());
}
