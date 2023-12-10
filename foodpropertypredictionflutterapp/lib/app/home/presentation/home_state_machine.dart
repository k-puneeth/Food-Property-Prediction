import 'dart:typed_data';

import '../../../../core/presentation/state_machine.dart';

class HomeStateMachine extends StateMachine<HomeState?, HomeEvent> {
  HomeStateMachine() : super(HomeInitState(imagesSelected: []));

  @override
  HomeState? getStateOnEvent(HomeEvent event) {
    final eventType = event.runtimeType;
    HomeState? newState = getCurrentState();
    switch (eventType) {
      case HomeLoadingEvent:
        newState = HomeLoadingState();

      case HomeImageSelectionEvent:
        HomeImageSelectionEvent homeImageSelectionEvent =
            event as HomeImageSelectionEvent;
        newState = HomeImageSelectedState(
            imagesSelected: homeImageSelectionEvent.images);

      case HomeRemoveImageEvent:
        HomeRemoveImageEvent homeRemoveImageEvent =
            event as HomeRemoveImageEvent;
        newState = HomeImageSelectedState(
            imagesSelected: homeRemoveImageEvent.updatedImages);

      case HomeBackEvent:
        HomeBackEvent backEvent =
            event as HomeBackEvent;
        newState = HomeInitState(imagesSelected: backEvent.images);
    }
    return newState;
  }
}

abstract class HomeState {}

class HomeInitState extends HomeState {
  final List<Uint8List> imagesSelected;
  HomeInitState({required this.imagesSelected});
}

class HomeImageSelectedState extends HomeState {
  final List<Uint8List> imagesSelected;
  HomeImageSelectedState({required this.imagesSelected});
}

class HomeLoadingState extends HomeState {}

abstract class HomeEvent {}

class HomeLoadingEvent extends HomeEvent {}

class HomeImageSelectionEvent extends HomeEvent {
  final List<Uint8List> images;
  HomeImageSelectionEvent({required this.images});
}

class HomeRemoveImageEvent extends HomeEvent {
  final List<Uint8List> updatedImages;
  HomeRemoveImageEvent({required this.updatedImages});
}

class HomeBackEvent extends HomeEvent {
  final List<Uint8List> images;
  HomeBackEvent({required this.images});
}

