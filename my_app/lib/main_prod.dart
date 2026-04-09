import 'package:my_app/app/app.dart';
import 'package:my_app/app/bootstrap.dart';
import 'package:my_app/app/flavors.dart';

Future<void> main() async {
  FlavorConfig.init(Flavor.prod);
  await bootstrap(() => const App());
}
