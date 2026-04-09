import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/app/observers/app_bloc_observer.dart';
import 'package:my_app/core/di/injection.dart';

Future<void> bootstrap(Widget Function() builder) async {
  // 1. Ensure Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Set up Bloc observer
  Bloc.observer = AppBlocObserver();

  // 3. Initialize dependency injection
  await configureDependencies();

  // 4. Set up error handling
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kReleaseMode) {
      // Log to crash reporting service (e.g. Firebase Crashlytics)
    }
  };

  // 5. Handle async errors
  runZonedGuarded(
    () {
      // 6. Run app
      runApp(builder());
    },
    (error, stackTrace) {
      // 7. Handle uncaught errors
      if (kDebugMode) {
        debugPrint('Uncaught error: $error\nStack trace: $stackTrace');
      }
    },
  );
}
