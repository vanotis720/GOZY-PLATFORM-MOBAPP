import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common/custom_container/custom_border_container.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/common/custom_container/custom_container.dart';
import 'package:gozy/widgets/custom_text.dart';
import 'package:gozy/widgets/dotted_border/dotted_border.dart';

Widget UserVerifiedInfo(
    {GestureTapCallback? onTap,
      required bool isVerified,
      String? communicationIcon,
      FontWeight? headingFontWeight,
      String? communicationType,
      String? verificationText,
      double? borderRadius,
      bool isEdited = false,
      bool isDashDivider = false,
      String? suffixIcon,
      Widget? tooltipWidget,
      VoidCallback? verifyCallback})
{
  Widget rowItem = [
    if (communicationIcon != null) communicationIcon.toSVG(size: 20),
    isEdited
        ? Text.rich(
      textDirection: intl.Bidi.isRtlLanguage(Get.locale?.languageCode)
          ? TextDirection.rtl
          : TextDirection.ltr,
      textAlign: intl.Bidi.isRtlLanguage(Get.locale?.languageCode)
          ? TextAlign.end
          : TextAlign.start,
      TextSpan(
        children: [
          TextSpan(
              text: communicationType,
              style: TextStyle(
                  color: appColors.textColor,
                  fontSize: AppDimen.textSize_14,
                  fontWeight: headingFontWeight ?? FontWeight.normal)),
          if (tooltipWidget != null)
            WidgetSpan(child: tooltipWidget.toPad(top: 3)),
        ],
      ),
    ).toPad(start: 6)
        : CustomText(
      text: communicationType ?? '',
      size: AppDimen.textSize_14,
      fontWeight: headingFontWeight ?? FontWeight.normal,
    ).toPad(start: 6),
    const Spacer(),
    toOnTap(
        onTap: verifyCallback,
        child: [
          CustomText(
            text: verificationText ?? label_verified.tr,
            color: isVerified ? appColors.approvedStatusColor : appColors.secondaryColor,
            size: AppDimen.textSize_14,
            fontWeight: FontWeight.normal,
          ),
          isVerified
              ? Assets.drawableInstantBookTick.toSVG(colour: appColors.approvedStatusColor).toPad(start: 5)
              : (suffixIcon ?? overALLAppLayoutModel!.backIcon).toSVG(colour: appColors.secondaryColor, isReverseRotation: true, size: 10).toPad(start: 5)
        ].toRow()
    )
  ].toRow();
  if(isDashDivider) {
    return DottedBorderView(child: rowItem.toPad(all:15),borderRadius: borderRadius).toPad(horizontal: 2);
  } else {
    return CustomBorderContainer(
      onTap: onTap,
      padding: pad(a: 15),
      borderRadius: borderRadius,
      body: rowItem
    );
  }
}


Widget topCornerClipContainer({Widget? child, bool isshowBorder = true, bool isEnablepadding = true, Color? topRadiusColor, BorderRadiusGeometry? cornerRadius, double? borderWidth}){
  return ColoredBox(
      color: topRadiusColor ?? appColors.theme4AppBarBg,
      child: CustomContainer(
          width: deviceWidth,
          decoration: BoxDecoration(
            color: appColors.white,
            border: isshowBorder ? Border(
              top: BorderSide(width: borderWidth ?? 2, color: appColors.popularLocationShimmerPlaceholderColor),
            ) : null,
            borderRadius: cornerRadius ?? const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          body: child !=null  ? isEnablepadding ? child.toPad(horizontal: AppDimen.startMargin): child : null
      ),
    ) ;
}

Widget topCornerClipCurvedContainer({
  Widget? child,
  bool isshowBorder = true,
  bool isEnablepadding = true,
  Color? topRadiusColor,
  BorderRadiusGeometry? cornerRadius,
  double borderWidth = 2,
})
{
  final radius = cornerRadius ??
      const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      );

  return CustomContainer(
    decoration: BoxDecoration(
        color: appColors.white,
        border: BorderDirectional(
          top: BorderSide(width: borderWidth, color: appColors.popularLocationShimmerPlaceholderColor),
        ),
        borderRadius: radius
    ),
  );
}