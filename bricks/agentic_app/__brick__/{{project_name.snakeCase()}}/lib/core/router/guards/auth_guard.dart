import 'package:auto_route/auto_route.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    // TODO(auth): Implement authentication check
    // if (isAuthenticated) {
    //   resolver.next();
    // } else {
    //   router.push(const LoginRoute());
    // }
    resolver.next();
  }
}
