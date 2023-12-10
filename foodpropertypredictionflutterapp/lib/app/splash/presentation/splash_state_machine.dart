import '../../../../core/presentation/state_machine.dart';

class SplashStateMachine extends StateMachine<SplashState?, SplashEvent> {
  SplashStateMachine() : super(SplashInitState());

  @override
  SplashState? getStateOnEvent(SplashEvent event) {
    final eventType = event.runtimeType;
    SplashState? newState = getCurrentState();
    switch (eventType) {}
    return newState;
  }
}

abstract class SplashState {}

class SplashInitState extends SplashState {
  SplashInitState();
}

abstract class SplashEvent {}
