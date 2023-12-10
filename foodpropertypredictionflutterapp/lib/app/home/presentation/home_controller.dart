import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:foodpropertyprediction/core/injection_container.dart';
import 'package:foodpropertyprediction/core/navigation_service.dart';
import 'package:image_picker/image_picker.dart';

import 'home_state_machine.dart';

class HomeController extends Controller {
  final HomeStateMachine _stateMachine = new HomeStateMachine();
  final NavigationService _navigationService =
      serviceLocator<NavigationService>();
  CameraController? cameraController;

  HomeController() : super();

  @override
  void initListeners() {}

  @override
  void onDisposed() {
    super.onDisposed();
  }

  HomeState? getCurrentState() {
    return _stateMachine.getCurrentState();
  }

  void handleImageSelectionFromGallery(List<Uint8List> selectedImages) async {
    _stateMachine.onEvent(HomeLoadingEvent());
    refreshUI();
    ImagePicker _imagePicker = ImagePicker();
    List<XFile> images = await _imagePicker.pickMultiImage();
    List<Uint8List> imagesInBytes = [];
    imagesInBytes.addAll(selectedImages);
    for (int i = 0; i < images.length; i++) {
      imagesInBytes.add(await images[i].readAsBytes());
    }

    if (imagesInBytes.isEmpty) {
      _stateMachine.onEvent(HomeBackEvent(images: []));
      refreshUI();
    } else {
      _stateMachine.onEvent(HomeImageSelectionEvent(images: imagesInBytes));
      refreshUI();
    }
  }

  void removeSelectedImage(Uint8List image) {
    HomeImageSelectedState selectedState =
        getCurrentState() as HomeImageSelectedState;
    List<Uint8List> selectedImage = selectedState.imagesSelected;
    selectedImage.remove(image);

    if (selectedImage.isEmpty) {
      _stateMachine.onEvent(HomeBackEvent(images: []));
      refreshUI();
    } else {
      _stateMachine.onEvent(HomeRemoveImageEvent(updatedImages: selectedImage));
      refreshUI();
    }
  }

  void handleBackButtonPressed(List<Uint8List> images) {
    _stateMachine.onEvent(HomeBackEvent(images: images));
    refreshUI();
  }

  void goToImageSelectedPage(List<Uint8List> images) {
    _stateMachine.onEvent(HomeImageSelectionEvent(images: images));
    refreshUI();
  }

  void initalizeCamera(List<Uint8List> images) async {
    _stateMachine.onEvent(HomeLoadingEvent());
    refreshUI();

    cameraController = CameraController(
        const CameraDescription(
            name: "0",
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 0),
        ResolutionPreset.veryHigh);
    await cameraController!.initialize();

    _stateMachine.onEvent(HomeCameraCaptureEvent(images: images));
    refreshUI();
  }

  void captureImage(List<Uint8List> images) async {
    _stateMachine.onEvent(HomeCameraImageCaptureEvent());
    refreshUI();

    XFile capturedImage = await cameraController!.takePicture();
    List<Uint8List> imagesInBytes = [];
    imagesInBytes.addAll(images);
    imagesInBytes.add(await capturedImage.readAsBytes());

    if (imagesInBytes.isEmpty) {
      _stateMachine.onEvent(HomeBackEvent(images: []));
      refreshUI();
    } else {
      _stateMachine.onEvent(HomeImageSelectionEvent(images: imagesInBytes));
      refreshUI();
    }
  }
}
