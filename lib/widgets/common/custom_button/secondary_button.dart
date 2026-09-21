import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_layout.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/conditional_parent_widget.dart';
import 'package:gozy/widgets/custom_text.dart';

class SecondaryButton extends StatelessWidget {
  /*
 purpose - use as border apply fill any other colors- react as secondary button
 @buttonText - content for button (Required)
 @height - height of the container (Optional)
 @onTap - function to be perform after click the button (Required)
 @fillcolor - fillcolor to button button (Optional)
 @textColor - button content color  (Optional)
 @borderColor - button border color (Optional)
 @trailingWidget - trailing widget to row wise (Optional)
 @leadingWidget - leading widget to row wise (Optional)
 @buttonTextFontSize - content size within the button (Optional)
 @padding - paddinggeometry for button inner alignment (Optional)
 @boxShadow - shadow effect for this button (Optional)
 @borderRadius - button border radius based on various theme mode (Optional)
 @isExpand - inner alignment for content within button
 @isButtonLayout - on some time to no need to show the arrow when correct theme
 @symbol - currency symbol based custom text alignment
 @isResizeText - to adjust the font size based on  button width and height

   */

  const SecondaryButton({
    super.key,
    required this.buttonText,
    required this.onTap,
    this.height,
    this.fillcolor,
    this.textColor,
    this.borderColor,
    this.trailingWidget,
    this.leadingWidget,
    this.padding,
    this.boxShadow,
    this.buttonTextFontSize,
    this.borderRadius,
    this.isExpand = true,
    this.isButtonLayout = true,
    this.symbol,
    this.isResizeText = false,
  });

  final String? buttonText;
  final double? height;
  final GestureTapCallback? onTap;
  final Color? fillcolor;
  final Color? textColor;
  final Color? borderColor;
  final Widget? trailingWidget;
  final EdgeInsetsGeometry? padding;
  final List<BoxShadow>? boxShadow;
  final double? buttonTextFontSize;
  final Widget? leadingWidget;
  final double? borderRadius;
  final bool isExpand;
  final bool isButtonLayout;
  final String? symbol;
  final bool isResizeText;

  @override
  Widget build(BuildContext context) {
    return toOnTap(
      onTap: onTap ?? onBack,
      child: Container(
        height: height ?? AppDimen.button_height,
        padding: padding,
        decoration: BoxDecoration(
            color: fillcolor,
            shape: BoxShape.rectangle,
            border: Border.all(color: borderColor ?? fillcolor ?? appColors.customBorderColor, width: 1),
            borderRadius: BorderRadius.all(
                Radius.circular(borderRadius ?? appLayoutMap[AppLayout.buttonType]?.borderRadius ?? 0)),
            boxShadow: boxShadow),
        child: [
          if (leadingWidget != null) leadingWidget!,
          ConditionalParentWidget(
            condition: isExpand,
            parentBuilder: (child) => Flexible(child: child),
            child: (isResizeText)
                ? CustomText(
                    text: buttonText ?? "cancel".tr,
                    color: textColor,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    size: buttonTextFontSize,
                    symbol: symbol,
                  )
                : CustomText(
                    text: buttonText ?? "cancel".tr,
                    color: textColor,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    size: buttonTextFontSize,
                    symbol: symbol,
                  ),
          ),
          trailingWidget ?? (isButtonLayout && (appLayoutMap[AppLayout.buttonType]?.isButtonArrowShow ?? false)
              ? Assets.drawableRightArrow
              .toSVG(
            colour: textColor,
            size: 10,
          )
              .toPad(start: 5, top: 2)
              : const SizedBox.shrink())
        ].toRow(
          mainAxisSize: isExpand ? MainAxisSize.max : MainAxisSize.min,
        ).toPad(horizontal: isExpand ? 0 : 15),
      ),
    );
  }
}