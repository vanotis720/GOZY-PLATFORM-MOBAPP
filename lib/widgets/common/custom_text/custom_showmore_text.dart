import 'package:flutter/material.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common_extension_functions.dart';

class CustomShowMoreText extends StatelessWidget {
  final String text;
  final double? size;
  final FontWeight? fontWeight;
  final Color? color;
  final bool? isReverseRotation;
  final String? showMoreIcon;
  final GestureTapCallback? onTap;
  final int? quarterTurns;
  final double? showMoreIconTopPadding;
  final double? showMoreIconsSize;

  const CustomShowMoreText(
      {super.key,
      required this.text,
      this.size = AppDimen.textSize_14,
      this.fontWeight = FontWeight.normal,
      this.color,
      this.onTap,
      this.isReverseRotation,
      this.showMoreIcon,
      this.quarterTurns,
      this.showMoreIconTopPadding,
      this.showMoreIconsSize});

  @override
  Widget build(BuildContext context) {
    return toOnTap(
        onTap: onTap,
        child: [
          Text(
            text.RTLAlignmentalText(),
            textAlign: TextAlign.start,
            style: TextStyle(
                color: color ?? appColors.secondaryColor,
                fontFamily: AppFont.font,
                fontSize: size ?? AppDimen.textSize_16,
                fontWeight: fontWeight),
          ),
          (showMoreIcon ?? Assets.drawableFilterCalendarArrow)
              .toSVG(
                  isReverseRotation: isReverseRotation ?? true,
                  quarterTurns: quarterTurns,
                  colour: color,
                  size: showMoreIconsSize??12)
              .toPad(top: showMoreIconTopPadding ?? 6, start: 5)
        ].toRow(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.start));
  }
}