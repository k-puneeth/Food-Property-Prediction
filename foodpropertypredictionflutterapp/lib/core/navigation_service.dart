import 'package:flutter/material.dart';
import 'package:foodpropertyprediction/app/home/presentation/home_view.dart';
import 'package:foodpropertyprediction/app/splash/presentation/splash_view.dart';

class AppNavigationService extends NavigationService {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case NavigationService.splashScreen:
        return MaterialPageRoute(builder: (_) => SplashPage());

      case NavigationService.homeScreen:
        return MaterialPageRoute(builder: (_) => HomePage());


      case '/':
        // don't generate route on start-up
        return null;

      default:
        return MaterialPageRoute(builder: (_) => SplashPage());
    }
  }

  @override
  Future<void> navigateTo(String routeName,
      {bool shouldReplace = false, Object? arguments}) {
    if (shouldReplace) {
      return navigatorKey.currentState!
          .pushReplacementNamed(routeName, arguments: arguments);
    }
    return navigatorKey.currentState!
        .pushNamed(routeName, arguments: arguments);
  }

  @override
  void navigateBack() {
    return navigatorKey.currentState!.pop();
  }

  void popUntil(String popUntilRoute) {
    return navigatorKey.currentState!
        .popUntil(ModalRoute.withName(popUntilRoute));
  }

  @override
  GlobalKey<NavigatorState> get navigatorKey => super.navigatorKey;
}

abstract class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static const String splashScreen = '/splash';

  static const String homeScreen = '/home';

  Future<void> navigateTo(String routeName,
      {bool shouldReplace = false, Object? arguments});

  void navigateBack();

  void popUntil(String popUntilRoute);
}
