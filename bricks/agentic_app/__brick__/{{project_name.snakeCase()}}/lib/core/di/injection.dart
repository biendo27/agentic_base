{{#uses_get_it}}
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:{{project_name.snakeCase()}}/app/modules/module_registrations.dart';
import 'package:{{project_name.snakeCase()}}/core/di/injection.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  await Future.sync(getIt.init);
  await registerModuleServices(getIt);
  await initializeModuleServices(getIt);
}

{{/uses_get_it}}
{{^uses_get_it}}
Future<void> configureDependencies() async {}

{{/uses_get_it}}
