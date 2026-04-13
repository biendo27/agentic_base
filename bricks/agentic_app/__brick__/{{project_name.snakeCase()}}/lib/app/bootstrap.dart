import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
{{#is_cubit}}
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{project_name.snakeCase()}}/app/observers/app_bloc_observer.dart';
{{/is_cubit}}
{{#is_riverpod}}
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:{{project_name.snakeCase()}}/app/modules/module_providers.dart';
{{/is_riverpod}}
{{^is_riverpod}}
import 'package:{{project_name.snakeCase()}}/app/i18n/translations.g.dart';
import 'package:{{project_name.snakeCase()}}/core/di/injection.dart';
{{/is_riverpod}}
{{#is_riverpod}}
import 'package:{{project_name.snakeCase()}}/app/i18n/translations.g.dart';
{{/is_riverpod}}

Future<void> bootstrap(Widget Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(LocaleSettings.useDeviceLocale());
{{#is_cubit}}
  Bloc.observer = AppBlocObserver();
{{/is_cubit}}
{{^is_riverpod}}
  await configureDependencies();
{{/is_riverpod}}
{{#is_riverpod}}
  final container = ProviderContainer();
  await initializeModuleProviders(container);
{{/is_riverpod}}
  final existingFlutterErrorHandler = FlutterError.onError;
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    existingFlutterErrorHandler?.call(details);
  };
  runZonedGuarded(
    () {
{{#is_riverpod}}
      runApp(
        UncontrolledProviderScope(
          container: container,
          child: builder(),
        ),
      );
{{/is_riverpod}}
{{^is_riverpod}}
      runApp(builder());
{{/is_riverpod}}
    },
    (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'bootstrap',
          context: ErrorDescription('while running the application zone'),
        ),
      );
      if (kDebugMode) {
        debugPrint('Uncaught error: $error\nStack trace: $stackTrace');
      }
    },
  );
}
