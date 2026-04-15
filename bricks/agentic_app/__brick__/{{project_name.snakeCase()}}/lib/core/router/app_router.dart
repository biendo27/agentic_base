import 'package:auto_route/auto_route.dart';
import 'package:{{project_name.snakeCase()}}/core/router/app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: HomeRoute.page, initial: true),
    AutoRoute(page: StarterDetailRoute.page),
    AutoRoute(page: StarterSettingsRoute.page),
    AutoRoute(page: StarterMonetizationRoute.page),
  ];
}
