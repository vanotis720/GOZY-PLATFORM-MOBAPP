import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_colors.dart';
import 'package:gozy/resources/app_layout.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common/custom_container/custom_border_container.dart';
import 'package:gozy/widgets/conditional_parent_widget.dart';
import 'package:gozy/widgets/custom_text.dart';
import 'package:gozy/widgets/common_extension_functions.dart';

import '../../../resources/app_dimen.dart';

/*
named as secondary button
    this.verticalPadding, this.topPadding,this.bottomPadding, this.horizontalPadding, --- EdgeInsetGeometry
    Remove maxlines
    isPrimaryButton remove need to  update with borderColor, fillcolor, textcolor,
    mapIcon, mapSize, mapColor remove must be from trailingWidget
    duration, isArrowNeeded, isFlexibleText removed. we may use isButtonLayout false avoid isArrowNeeded
    trailingwidget name change to leadingwidget , dotwidget name change to trailingwidget
 */
class CancelButton extends StatelessWidget {
  const CancelButton({
    super.key,
    this.buttonText,
    this.height,
    this.onTap,
    this.color,
    this.fillcolor,
    this.textColor,
    this.borderColor,
    this.mapColor,
    this.mapIcon,
    this.mapSize,
    this.trailingWidget,
    this.verticalPadding,
    this.topPadding,
    this.bottomPadding,
    this.horizontalPadding,
    this.boxShadow,
    this.textSize,
    this.dotWidget,
    this.borderRadius,
    this.isPrimaryButton = false,
    this.isExpand = true,
    this.isArrowNeeded = true,
    this.isButtonLayout = true,
    this.symbol,
    this.isResizeText = false,
  });

  final String? buttonText;
  final double? height;
  final GestureTapCallback? onTap;
  final Color? color;
  final Color? fillcolor;
  final Color? textColor;
  final Color? borderColor;
  final Color? mapColor;
  final String? mapIcon;
  final double? mapSize;
  final Widget? trailingWidget;
  final double? verticalPadding;
  final double? topPadding;
  final double? bottomPadding;
  final double? horizontalPadding;
  final List<BoxShadow>? boxShadow;
  final double? textSize;
  final Widget? dotWidget;
  final double? borderRadius;
  final bool isPrimaryButton;
  final bool isExpand;
  final bool isArrowNeeded;
  final bool isButtonLayout;
  final String? symbol;
  final bool isResizeText;

  @override
  Widget build(BuildContext context) {
    final BaseController controller = BaseController();

    final Color resolvedColor =
    isPrimaryButton ? appColors.primaryColor : color ?? appColors.primaryColor;

    final Color resolvedFillColor =
    isPrimaryButton ? appColors.primaryColor : fillcolor ?? appColors.white;

    final Color resolvedTextColor =
    isPrimaryButton
        ? (controller.isDarkMode()
        ? appColors.buttonTextColor
        : AppColors.staticwhite)
        : textColor ?? resolvedColor;

    debugPrint(
        "isshowbuttonarrow: ${appLayoutMap[AppLayout.buttonType]?.isButtonArrowShow}");

    return CustomBorderContainer(
      onTap: onTap ?? onBack,
      height: height ?? AppDimen.button_height,
      padding: pad(
        w: horizontalPadding ?? 18,
      ),
      color: resolvedFillColor,
      borderColor: borderColor ?? resolvedColor,
      borderWidth: 1,
      boxShadow: boxShadow,
      borderRadius:
      borderRadius ?? appLayoutMap[AppLayout.buttonType]?.borderRadius,
      body: [
        if (trailingWidget != null) trailingWidget!,
        if (mapIcon != null)
          mapIcon!
              .toSVG(
            size: mapSize ?? 13,
            colour: mapColor ?? AppColors.staticwhite,
          )
              .toPad(end: 5),
            ConditionalParentWidget(
              condition: isExpand,
              parentBuilder: (child) => Flexible(child: child),
              child: CustomText(
                text: buttonText ?? "cancel".tr,
                color: resolvedTextColor,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                size: textSize,
                symbol: symbol,
              ),
            ),
        if (isArrowNeeded)
          dotWidget ??
              (isButtonLayout &&
                  (appLayoutMap[AppLayout.buttonType]
                      ?.isButtonArrowShow ??
                      false)
                  ? Assets.drawableRightArrow
                  .toSVG(
                colour: resolvedTextColor,
                size: 10,
              )
                  .toPad(start: 5, top: 2)
                  : const SizedBox.shrink())
        else
          const SizedBox.shrink(),
      ].toRow(
        mainAxisSize: isExpand ? MainAxisSize.max : MainAxisSize.min,
      ),
    );
  }
}

/*
remove that button use same secondary button
 */
Widget PrimaryColorButton({ required String text,GestureTapCallback? onTap, bool isExpand = true, double? textSize,double? horizontalPadding ,bool? isBottomSheetButton, bool isArrowNeeded = true, double? borderRadius}){
  return  CancelButton(
    buttonText: text,
    isExpand: isExpand,
    onTap: onTap,
    verticalPadding: 10,
    horizontalPadding:horizontalPadding,
    color:  appColors.primaryColor ,
    fillcolor:appColors.primaryColor,
    textColor: AppColors.staticwhite,
    textSize: textSize,
    isArrowNeeded: isArrowNeeded,
    borderRadius: borderRadius
  );

}