import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_layout.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/bottom_sheet/bottom_sheet_refresh_controller.dart';
import 'package:gozy/widgets/common/custom_button/secondary_button.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_text.dart';

/*

@title - title for dialog (Optional)
@contentText - body content string (Optional)
@appLayout - selected theme layout as a enumtype (Optional)
@content - content predefined view for dialog (Optional)
@barrierDismissible - condition to close dialog when click outside of dialog (Optional)
@onOkPressed - accept button click listener (Optional)
@okButtonContent - accept button content (Optional)
@cancelButtonContent - modal decline button content (Optional)
@padding - content padding (Optional)

 */

void showAlertDialog({
  String title = "",
  String? contentText,
  AppLayout? appLayout,
  Widget? content,
  bool? barrierDismissible,
  VoidCallback? onOkPressed,
  String? okButtonContent,
  String? cancelButtonContent,
  EdgeInsetsGeometry? padding,
}) {
  int themeType = overALLThemeType;
  double borderRadius = AppDimen.appBorderRadius;
  if (appLayout != null) {
    themeType = appLayoutMap[appLayout]!.themeType;
    borderRadius = appLayoutMap[appLayout]!.borderRadius;
  }
  EdgeInsetsGeometry titlePadding = pad(w: 18, h: themeType == 3 ? 18 : 12);
  EdgeInsetsGeometry contentPadding = padding ?? pad(w: 18, h: 24);
  bool isShowDivider = false,
      isShowBottomDiver = false,
      isCustomActionsInButton = false,
      isCenterAlignment = false,
      isActionsRightAlign = false;
  Color? fillColor;
  double width = deviceWidth - (2 * AppDimen.startMargin);

  Get.dialog(
    barrierDismissible: barrierDismissible ?? false,
    GetBuilder<BottomSheetController>(
      builder: (newController) {
        switch (themeType) {
          case 1:
            isShowDivider = true;
            isCustomActionsInButton = true;
            isCenterAlignment = true;
            break;
          case 2:
            isShowDivider = true;
            isShowBottomDiver = true;
            isCustomActionsInButton = (okButtonContent == null && cancelButtonContent == null) ;
            break;
          case 3:
            isActionsRightAlign = true;
            fillColor = appColors.myTripsBGColor;
            isCustomActionsInButton = true;
            break;
          case 4:
            fillColor = appColors.theme4AppBarBg;
            isCustomActionsInButton = (okButtonContent == null && cancelButtonContent == null) ;
            isShowBottomDiver = true;
            break;
          default:
            break;
        }
        return PopScope(
          canPop: barrierDismissible ?? false,
          child: AlertDialog(
            backgroundColor: appColors.white,
            insetPadding: EdgeInsets.zero,
            contentPadding: EdgeInsets.zero,
            actionsPadding: pad(
                w: 18,
                top: 12,
                bottom: themeType == 2 || themeType == 4 ? 12 : 20),
            titlePadding: EdgeInsets.zero,
            title: title.isNotEmpty
                ? _getTitleWidget(
                    title: title,
                    padding: titlePadding,
                    width: width,
                    isShowDivider: isShowDivider,
                    fillColor: fillColor,
                    isCenterAlignment: isCenterAlignment,
                    borderRadius: borderRadius,
                  )
                : const SizedBox.shrink(),
            content: [
              (isCenterAlignment
                      ? Center(
                          child: (content ??
                              CustomText(
                                  text: contentText ?? '',
                                  fontWeight: AppFont.regular,
                                  font: AppFont.font,
                                  size: AppDimen.textSize_16,
                                  textAlign: TextAlign.center)),
                        )
                      : (content ??
                          CustomText(
                              text: contentText ?? '',
                              fontWeight: AppFont.regular,
                              font: AppFont.font,
                              size: AppDimen.textSize_16,
                              textAlign: TextAlign.start)))
                  .toPad(edgeInsetsGeometry: contentPadding),
              if (isShowBottomDiver && !isCustomActionsInButton) filterDivider,
              if (isCustomActionsInButton && !isActionsRightAlign)
                [
                  if (cancelButtonContent != null) 20.toWidth(),
                  if (cancelButtonContent != null)
                    SecondaryButton(
                      padding: isActionsRightAlign ? EdgeInsets.symmetric(horizontal: 18): null,
                        buttonText: cancelButtonContent,
                        borderColor: appColors.black,
                        isButtonLayout: false,
                        borderRadius: borderRadius,
                        isExpand: false,
                        onTap: () {
                          if (Get.context != null && MediaQuery.of(Get.context!).viewInsets.bottom != 0) {
                            FocusManager.instance.primaryFocus!.unfocus();
                          }
                          Get.back();
                        }).toStretch(),
                  20.toWidth(),
                  if (okButtonContent != null && onOkPressed != null)
                    SecondaryButton(
                        buttonText: okButtonContent,
                        padding: isActionsRightAlign ? EdgeInsets.symmetric(horizontal: 18): EdgeInsets.symmetric(horizontal: 6),
                        fillcolor: appColors.black,
                        borderColor: appColors.black,
                        isButtonLayout: !(isActionsRightAlign),
                        textColor: appColors.white,
                        borderRadius: borderRadius ,
                        isExpand: true,
                        onTap: () {
                          onOkPressed();
                        }).toStretch(),
                  20.toWidth(),
                ].toRow(mainAxisAlignment: MainAxisAlignment.end).toPad(bottom: okButtonContent != null || cancelButtonContent != null ? 20 : 0)
              else if(isCustomActionsInButton && isActionsRightAlign)[
                if (cancelButtonContent != null)
                  SecondaryButton(
                      buttonText: cancelButtonContent,
                      borderColor: appColors.black,
                      padding: pad(w: 10),
                      isButtonLayout: false,
                      isResizeText: false,
                      borderRadius: borderRadius,
                      isExpand: true,
                      onTap: () {
                        if (Get.context != null && MediaQuery.of(Get.context!).viewInsets.bottom != 0) {
                          FocusManager.instance.primaryFocus!.unfocus();
                        }
                        Get.back();
                      }).toResizeWidget(width: deviceWidth * 0.22),
                18.toWidth(),
                if (okButtonContent != null && onOkPressed != null)
                  SecondaryButton(
                      buttonText: okButtonContent,
                      padding: pad(w: 10),
                      fillcolor: appColors.black,
                      borderColor: appColors.black,
                      isButtonLayout: false,
                      isResizeText: false,
                      textColor: appColors.white,
                      borderRadius: borderRadius ,
                      isExpand: true,
                      onTap: () {
                        onOkPressed();
                      }).toResizeWidget(width: deviceWidth * 0.22),
                18.toWidth(),
              ].toRow(mainAxisAlignment: MainAxisAlignment.end).toPad(bottom: okButtonContent != null || cancelButtonContent != null ? 20 : 0)
            ].toColumn(mainAxisSize: MainAxisSize.min).toResizeWidget(width: width),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ),
            ),
            actions: isCustomActionsInButton
                ? null
                : <Widget>[
                    if (cancelButtonContent != null)
                      CustomText(
                        text: cancelButtonContent,
                        size: AppDimen.textSize_16,
                        fontWeight: AppFont.regular,
                        onTap: () {
                          if (Get.context != null && MediaQuery.of(Get.context!).viewInsets.bottom != 0) {
                            FocusManager.instance.primaryFocus!.unfocus();
                            Get.back();
                          } else {
                            Get.back();
                          }
                        },
                      ),
                    if (okButtonContent != null && onOkPressed != null)
                      CustomText(
                        color: appColors.secondaryColor,
                        size: AppDimen.textSize_16,
                        text: okButtonContent,
                        fontWeight: AppFont.regular,
                        onTap: () {
                          onOkPressed();
                        },
                      ).toPad(start: 20),
                  ],
          ).toPad(horizontal: AppDimen.startMargin),
        );
      },
    ),
  );
}

Widget _getTitleWidget({
  required String title,
  double? width,
  EdgeInsetsGeometry? padding,
  bool? isShowDivider,
  Color? fillColor,
  bool? isCenterAlignment,
  double? borderRadius,
}) {
  Widget titleWidget = Container(
    width: width,
    padding: padding,
    alignment: isCenterAlignment != null && isCenterAlignment
        ? AlignmentDirectional.center
        : AlignmentDirectional.centerStart,
    decoration: BoxDecoration(
      color: fillColor,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(borderRadius ?? AppDimen.appBorderRadius),
        topRight: Radius.circular(borderRadius ?? AppDimen.appBorderRadius),
      ),
    ),
    child: CustomTitleText(
      size: AppDimen.textSize_18,
      text: title,
      fontWeight: AppFont.medium,
    ),
  );

  if (isShowDivider ?? false) {
    return [
      titleWidget,
      filterDivider,
    ].toColumn();
  } else {
    return titleWidget;
  }
}