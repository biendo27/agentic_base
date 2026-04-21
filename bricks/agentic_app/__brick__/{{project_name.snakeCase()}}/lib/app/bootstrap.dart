import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
{{#is_riverpod}}
import 'package:flutter_riverpod/flutter_riverpod.dart';
{{/is_riverpod}}
{{#is_cubit}}
import 'package:flutter_bloc/flutter_bloc.dart';
{{/is_cubit}}
import 'package:{{project_name.snakeCase()}}/app/locale/app_locale_contract.dart';
import 'package:{{project_name.snakeCase()}}/app/flavors.dart';
{{#is_riverpod}}
import 'package:{{project_name.snakeCase()}}/app/modules/module_providers.dart';
{{/is_riverpod}}
{{#is_cubit}}
import 'package:{{project_name.snakeCase()}}/app/observers/app_bloc_observer.dart';
{{/is_cubit}}
{{^is_riverpod}}
import 'package:{{project_name.snakeCase()}}/core/di/injection.dart';
{{/is_riverpod}}
import 'package:{{project_name.snakeCase()}}/core/observability/redaction_policy.dart';
import 'package:{{project_name.snakeCase()}}/core/observability/observability_service.dart';

const _observabilityRedactionPolicy = RedactionPolicy();

Future<void> bootstrap(
  Widget Function() builder, {
  bool initializeModules = true,
}) async {
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      ObservabilityService.instance.bootstrap(
        flavor: FlavorConfig.instance.flavor.name,
        appName: FlavorConfig.instance.appName,
      );
      unawaited(AppLocaleContract.useDeviceLocale());
{{#is_cubit}}
      Bloc.observer = AppBlocObserver();
{{/is_cubit}}
{{^is_riverpod}}
      await configureDependencies(initializeModules: initializeModules);
{{/is_riverpod}}
{{#is_riverpod}}
      final container = ProviderContainer();
      if (initializeModules) {
        await initializeModuleProviders(container);
      }
{{/is_riverpod}}
      final existingFlutterErrorHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        existingFlutterErrorHandler?.call(details);
      };
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
      ObservabilityService.instance.log(
        'bootstrap.uncaught_error',
        level: 'error',
        fields: <String, Object?>{
          'error_type': error.runtimeType.toString(),
          'error_message': _observabilityRedactionPolicy.summarizeObject(error),
          'stack_frame_count': _countStackFrames(stackTrace),
        },
      );
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

int _countStackFrames(StackTrace stackTrace) {
  return stackTrace
      .toString()
      .split('\n')
      .where((line) => line.trim().isNotEmpty)
      .length;
}
