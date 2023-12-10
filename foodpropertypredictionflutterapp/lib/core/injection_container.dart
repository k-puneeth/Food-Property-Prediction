import 'package:foodpropertyprediction/core/navigation_service.dart';
import 'package:get_it/get_it.dart';

final serviceLocator = GetIt.instance;

Future<void> init() async {
  
  serviceLocator
      .registerLazySingleton<NavigationService>(() => AppNavigationService());
}
