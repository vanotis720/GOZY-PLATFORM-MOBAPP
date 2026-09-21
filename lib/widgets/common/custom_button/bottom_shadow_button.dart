import 'package:flutter/material.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_layout.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_text.dart';

class BottomShadowButton extends StatelessWidget {
  /*
   purpose - apply bottom notch area based alignment changes button
   @buttonText - content for button (Optional)
   @onTap - function to be perform after click the button (Optional)
   @child - already created child applied to button (Optional)
   @buttonBGColor - use button background colour (Optional)
   @shadowBGColor - after applied shadow overall background color without padding (Optional)
   @buttonTextColor - text colour on button (Optional)
   @borderRadiusGeometry - particular without apply overall corner radius custom applied for this container (Optional)
   @buttonPadding - padding geometry for button layout on overlall width container
   */
  const BottomShadowButton({
    super.key,
    this.buttonText,
    this.onTap,
    this.child,
    this.buttonBGColor,
    this.shadowBGColor,
    this.buttonTextColor,
    this.borderRadiusGeometry,
    this.buttonPadding,
  });

  final String? buttonText;
  final GestureTapCallback? onTap;
  final Widget? child;
  final Color? buttonBGColor;
  final Color? shadowBGColor;
  final Color? buttonTextColor;
  final BorderRadiusGeometry? borderRadiusGeometry;
  final EdgeInsetsGeometry? buttonPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: deviceWidth,
        padding: buttonPadding,
        decoration: BoxDecoration(
            borderRadius: borderRadiusGeometry,
            color: shadowBGColor ?? appColors.white,
            boxShadow: getBottomBoxShadows()),
        child: child ??
            toOnTap(
              onTap: onTap,
              child: Container(
                  padding: pad(a: 8),
                  constraints: BoxConstraints(
                    minHeight: AppDimen.button_height,
                  ),
                  width: deviceWidth,
                  alignment: AlignmentDirectional.center,
                  decoration: BoxDecoration(
                    color: buttonBGColor ?? appColors.primaryColor,
                    borderRadius: BorderRadius.circular(
                      appLayoutMap[AppLayout.buttonType]?.borderRadius ?? 0,
                    ),
                  ),
                  child: [
                    CustomText(
                      text: buttonText ?? '',
                      color: buttonTextColor ?? appColors.buttonTextColor,
                      textAlign: TextAlign.start,
                      size: AppDimen.textSize_16,
                      fontWeight: FontWeight.w500,
                    ).toStretch(isExpanded: false),
                    if ((appLayoutMap[AppLayout.buttonType]?.isButtonArrowShow ?? false))
                      Assets.drawableRightArrow
                          .toSVG(colour: buttonTextColor ?? appColors.buttonTextColor, size: 10)
                          .toPad(start: 5, top: 2),
                  ].toRow(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center)),
            ));
  }
}