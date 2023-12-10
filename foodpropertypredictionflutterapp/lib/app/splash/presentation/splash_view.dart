import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart'
    as fa;
import 'splash_controller.dart';
import 'splash_state_machine.dart';

class SplashPage extends fa.View {
  @override
  State<StatefulWidget> createState() => SplashViewState();
}

class SplashViewState
    extends fa.ResponsiveViewState<SplashPage, SplashController> {
  SplashViewState() : super(SplashController());

  @override
  Widget get desktopView => throw UnimplementedError();

  @override
  Widget get mobileView => fa.ControlledWidgetBuilder<SplashController>(
        builder: (context, controller) {
          final currentState = controller.getCurrentState();
          final currentStateType = controller.getCurrentState().runtimeType;
          print("buildMobileView called with state $currentStateType");

          switch (currentStateType) {
            case SplashInitState:
              return _buildSplashScreen(controller);
          }
          throw Exception("Unrecognized state $currentStateType encountered");
        },
      );

  @override
  Widget get tabletView => mobileView;

  @override
  Widget get watchView => throw UnimplementedError();

  Widget _buildSplashScreen(SplashController controller) {
    Future.delayed(const Duration(seconds: 3), (){
      controller.navigateToHomePage();
    });

    return Scaffold(
      body: Center(
        child: Container(
          child: Image.asset(
            'assets/food1.png',
            width: 200,
          ),
        ),
      ),
    );
  }
}
