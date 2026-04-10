import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{project_name.snakeCase()}}/app/observers/app_bloc_observer.dart';
import 'package:{{project_name.snakeCase()}}/app/i18n/translations.g.dart';
import 'package:{{project_name.snakeCase()}}/core/di/injection.dart';

Future<void> bootstrap(Widget Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(LocaleSettings.useDeviceLocale());
  Bloc.observer = AppBlocObserver();
  await configureDependencies();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kReleaseMode) {
      // Hook crash reporting here.
    }
  };
  runZonedGuarded(
    () {
      runApp(builder());
    },
    (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Uncaught error: $error\nStack trace: $stackTrace');
      }
    },
  );
}
