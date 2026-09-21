import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/widgets/bottom_sheet/bottom_sheet_refresh_controller.dart';
import 'package:gozy/widgets/common_extension_functions.dart';

import '../screens/views/base_controller.dart';

class CustomStatefulWidget extends StatefulWidget {
 const CustomStatefulWidget({super.key});

  @override
  CustomStatefulWidgetState createState() => CustomStatefulWidgetState();
}

class CustomStatefulWidgetState<T extends CustomStatefulWidget> extends State<T> with WidgetsBindingObserver {
  BottomSheetController bottomSheetController = Get.find();
  @override
  void initState() {
    disbpsablePageObjects[toString()] = disposableObjects.isNotEmpty ? disposableObjects: [];
    disposableObjects.clear();

    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
  @override
  void dispose() {
    if( disbpsablePageObjects[toString()] !=null) {
      disbpsablePageObjects[toString()]!.disposeAll();
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    debugPrint("didChangePlatformBrightness called");
    super.didChangePlatformBrightness();
    PlatformBrightnessUpdateTimer?.cancel();
    PlatformBrightnessUpdateTimer = Timer(Duration(milliseconds: 300), () {
      bottomSheetController.changeTheme();
      print('Brightness changed to: ${Get.theme} ');
    });


  }


}