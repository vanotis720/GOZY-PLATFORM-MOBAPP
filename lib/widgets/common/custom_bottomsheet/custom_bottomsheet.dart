import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/bottom_sheet/bottom_sheet_refresh_controller.dart';
import 'package:gozy/widgets/common/custom_bottomsheet/custom_getx_bottomsheet.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/common_extension_functions.dart';

import '../../../constant.dart';



/*
@title - title for bottomsheet (Optional)
@titleWidget - custom widget for title view (Optional)
@backButtonWidget - closeicon or back icon based on theme view with function (Optional)
@actionWidget - action option for end of backbutton (Optional)
@contentWidget - content view for bottom sheet - (Required)
@sheetCloseListener - perform function after close the bottomsheet (Optional)
@textType - Title header text type (Optional)
@barrierColor - background color after opening the bottomsheet (Optional)
apply padding title, backicon, content padding set by contentwidget button affected
 */
void showCustomBottomSheet({
  String? title,
  Widget? titleWidget,
  Widget? backButtonWidget,
  bool? isSelectCountry,
  Widget? actionWidget,
  required Widget contentWidget,
  Function? sheetCloseListener,
  double? titleFontSize,
}) {
  Widget bottomSheetWidget = SafeArea(
    bottom: Platform.isAndroid,
    child: GetBuilder<BottomSheetController>(
        builder: (newController) => ColoredBox(
              color: (isSelectCountry ?? false) ? appColors.countryBottomSheetBGColor : appColors.white,
              child: [
                topViewPadding.toHeight(),
                [
                  if (backButtonWidget != null) backButtonWidget,
                  Spacer(),
                  if (actionWidget != null) actionWidget
                ].toRow(),
                if (title != null || titleWidget != null)
                  (titleWidget ??
                          CustomTitleText(
                            text: title ?? '',
                            size: titleFontSize ?? AppDimen.textSize_24,
                          ))
                      .toPad(horizontal: AppDimen.startMargin, bottom: 10),
                contentWidget.toStretch(),
              ].toColumn(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start),
            )),
  );
  GetXBottomSheet(
      borderRadius: 0,
      bottomSheetWidget: bottomSheetWidget,
      sheetCloseListener: sheetCloseListener);
}