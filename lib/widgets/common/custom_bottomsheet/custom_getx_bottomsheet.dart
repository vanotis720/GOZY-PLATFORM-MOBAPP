import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/widgets/bottom_sheet/bottom_sheet_refresh_controller.dart';

void GetXBottomSheet({
  required Widget bottomSheetWidget,
  Function? sheetCloseListener,
  isDismissible = true,
  double? borderRadius = 20,
}) {
  Get.bottomSheet(
    GetBuilder<BottomSheetController>(
      builder: (newController) => SafeArea(
        bottom: Platform.isAndroid,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius !=null && borderRadius != 0
                ? BorderRadius.only(
                    topLeft: Radius.circular(borderRadius),
                    topRight: Radius.circular(borderRadius),
                  )
                : null,
          ),
          child: bottomSheetWidget,
        ),
      ),
    ),
    isDismissible: isDismissible,
    isScrollControlled: true,
    enableDrag: false,
  ).whenComplete(() {
    sheetCloseListener != null ? sheetCloseListener() : ();
  });
}