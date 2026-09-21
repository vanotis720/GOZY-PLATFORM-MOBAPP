import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_text.dart';
import 'package:gozy/widgets/theme4/custom_dash_divider.dart';

import '../resources/app_font.dart';

class CustomPopupMenu {
  BaseController controller;
  List<Map<String, dynamic>> PopupMenuItems;
  Offset offset;
  bool? isShowDashDivider;
  double? endOffset;
  bool? isPadNeedForDivider;
  double? borderRadius;

  CustomPopupMenu(
      {Key? key,
      required this.controller,
      required this.PopupMenuItems,
      required this.offset,
      this.isShowDashDivider,
      this.endOffset,
      this.isPadNeedForDivider,
      this.borderRadius}) {
    double calculatedWidth = 0;
    for (var item in PopupMenuItems) {
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: item['text'],
          style: TextStyle(
            fontSize: AppDimen.textSize_14,
            fontWeight: AppFont.regular,
            fontFamily: AppFont.font,
          ),
        ),
        textDirection: controller.isRTL() ? TextDirection.rtl : TextDirection.ltr,
      )..layout();
      if (textPainter.width > calculatedWidth) {
        calculatedWidth = textPainter.width;
      }
    }
    // Add horizontal padding (10+10 = 20) plus a 10px buffer for safety.
    calculatedWidth = (PopupMenuItems[0]['maxlength']?.toDouble() ?? (calculatedWidth + 30));
    
    isPopUpMenuOpen = true;
    debugPrint('calculatedWidth: $calculatedWidth --- $isPopUpMenuOpen');

    List<Widget> listWidgets;
    listWidgets = List.generate(PopupMenuItems.length, (index) {
      Map<String, dynamic> item = PopupMenuItems[index];
      return toOnTap(
        onTap: () {
          Get.back();
          item['ontap']();
        },
        child: CustomText(
          text: item['text'],
          size: AppDimen.textSize_14,
        ).toPad(start: 10, end: 10, vertical: 10).toResizeWidget(
            width: calculatedWidth),
      );
    });
    showMenu(
        context: Get.context!,
        menuPadding: EdgeInsets.zero,
        color: appColors.white,
        constraints: BoxConstraints(
          minHeight: 0,
          maxWidth: calculatedWidth,
        ),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: appColors.customBorderColor),
            borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? overALLAppLayoutModel?.borderRadius ?? 5))),
        position: RelativeRect.fromDirectional(
          textDirection:
              controller.isRTL() ? TextDirection.rtl : TextDirection.ltr,
          start: offset.dx + 90,
          top: offset.dy + 15,
          end: endOffset ?? 25,
          bottom: 0,
        ),
        items: [
          PopupMenuItem(
              padding: EdgeInsets.zero,
              enabled: false,
              height: 0,
              child: [
                for (final (index, itemWidget) in listWidgets.indexed) ...[
                  itemWidget,
                  if (index != listWidgets.length - 1)
                    (isShowDashDivider ?? false)
                        ? fullWidthDashDivider(width: 150)
                        : (isPadNeedForDivider ?? false) ? filterDivider.toPad(horizontal: 10) : filterDivider
                ]
              ].toColumn(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min)),
        ]).then((value) {
      debugPrint('value: $value');
      isPopUpMenuOpen = false;
    });
  }
}