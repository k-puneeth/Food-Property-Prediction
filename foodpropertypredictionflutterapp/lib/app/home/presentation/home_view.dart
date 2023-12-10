import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart'
    as fa;
import 'package:image_picker/image_picker.dart';
import 'home_controller.dart';
import 'home_state_machine.dart';

class HomePage extends fa.View {
  @override
  State<StatefulWidget> createState() => HomeViewState();
}

class HomeViewState extends fa.ResponsiveViewState<HomePage, HomeController> {
  HomeViewState() : super(HomeController());

  @override
  Widget get desktopView => throw UnimplementedError();

  @override
  Widget get mobileView => fa.ControlledWidgetBuilder<HomeController>(
        builder: (context, controller) {
          final currentState = controller.getCurrentState();
          final currentStateType = controller.getCurrentState().runtimeType;
          print("buildMobileView called with state $currentStateType");

          switch (currentStateType) {
            case HomeLoadingState:
              return _buildHomeLoadingState();
            case HomeInitState:
              HomeInitState homeInitState = currentState as HomeInitState;
              return _buildHomeInitScreen(controller, homeInitState);

            case HomeImageSelectedState:
              return _buildHomeImageSelectedState(
                  controller, currentState as HomeImageSelectedState);
          }
          throw Exception("Unrecognized state $currentStateType encountered");
        },
      );

  @override
  Widget get tabletView => mobileView;

  @override
  Widget get watchView => throw UnimplementedError();

  Widget _buildHomeLoadingState() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildHomeImageSelectedState(
      HomeController controller, HomeImageSelectedState state) {
    return Scaffold(
      floatingActionButton: GestureDetector(
        onTap: () {},
        child: Container(
          margin: EdgeInsets.all(10),
          width: 150,
          height: 60,
          decoration: BoxDecoration(
              color: state.imagesSelected.isNotEmpty
                  ? Color.fromARGB(255, 243, 162, 76)
                  : Colors.grey,
              borderRadius: BorderRadius.circular(20)),
          child: const Center(
            child: Text(
              'Track Calories',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
          ),
        ),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            controller.handleBackButtonPressed(state.imagesSelected);
          },
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.89,
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Wrap(
                children: [
                  for (Uint8List image in state.imagesSelected)
                    _buildImageContainer(
                        onRemove: () {
                          controller.removeSelectedImage(image);
                        },
                        image: Image.memory(image)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContainer({
    required Function() onRemove,
    required Image image,
  }) {
    return Container(
      padding: const EdgeInsets.all(5),
      child: Column(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.black38,
                      builder: (context) {
                        return buildEnlargedImage(
                          context: context,
                          image: image,
                        );
                      });
                },
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: MediaQuery.of(context).size.width * 0.4,
                  margin: const EdgeInsets.all(5),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(width: 1, color: const Color(0xFFE7E9E9)),
                  ),
                  child: Image(
                    image: image.image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                child: GestureDetector(
                  onTap: onRemove,
                  child: const CircleAvatar(
                    backgroundColor: Colors.red,
                    radius: 12,
                    child: Center(
                      child: Icon(
                        Icons.clear,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildEnlargedImage({
    required BuildContext context,
    required Widget image,
  }) {
    return Stack(
      children: [
        Container(
          color: Colors.transparent,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: InteractiveViewer(child: image),
          ),
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height / 10,
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: GestureDetector(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.black54),
                    child: const Icon(
                      Icons.close_sharp,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHomeInitScreen(HomeController controller, HomeInitState state) {
    return Scaffold(
        appBar: AppBar(
            leading: null,
            automaticallyImplyLeading: false,
            title: const Text(
              "Track your Calories !",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
            )),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 2,
                      color: Color.fromARGB(255, 240, 147, 49),
                    ),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        size: 100,
                        color: Color.fromARGB(255, 240, 147, 49),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Capture Image",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w200),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 70,
              ),
              GestureDetector(
                onTap: () {
                  controller
                      .handleImageSelectionFromGallery(state.imagesSelected);
                },
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 2,
                      color: Color.fromARGB(255, 240, 147, 49),
                    ),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.upload_file,
                        size: 100,
                        color: Color.fromARGB(255, 240, 147, 49),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Upload Image",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w200),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              GestureDetector(
                onTap: () {
                  if (state.imagesSelected.isNotEmpty) {
                    controller.goToImageSelectedPage(state.imagesSelected);
                  }
                },
                child: Container(
                  width: 150,
                  height: 50,
                  decoration: BoxDecoration(
                      color: state.imagesSelected.isNotEmpty
                          ? Color.fromARGB(255, 243, 162, 76)
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(20)),
                  child: const Center(
                    child: Text(
                      'Continue',
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
