import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:foodpropertyprediction/core/injection_container.dart';
import 'package:foodpropertyprediction/core/navigation_service.dart';

import '../../../../core/presentation/observer.dart';
import 'splash_presenter.dart';
import 'splash_state_machine.dart';

class SplashController extends Controller {
  final SplashStateMachine _stateMachine = new SplashStateMachine();
  final NavigationService _navigationService =
      serviceLocator<NavigationService>();

  SplashController() : super();

  @override
  void initListeners() {}

  @override
  void onDisposed() {
    super.onDisposed();
  }

  SplashState? getCurrentState() {
    return _stateMachine.getCurrentState();
  }

  void navigateToHomePage(){
    _navigationService.navigateTo(NavigationService.homeScreen,shouldReplace: true);
    
  }
}
