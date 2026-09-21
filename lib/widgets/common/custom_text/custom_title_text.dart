import 'package:flutter/material.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/conditional_parent_widget.dart';

class CustomTitleText extends StatelessWidget {
  String text;
  double? size;
  FontWeight? fontWeight;
  Color? color;
  final Color? shimmerColor;
  TextAlign textAlign;
  final bool? isShimmerView;
  final TextOverflow overflow;
  TextDirection? textDirection;
  dynamic maxLines;

  CustomTitleText({
    super.key,
    required this.text,
    this.size,
    this.fontWeight = AppFont.medium,
    this.color,
    this.shimmerColor,
    this.textDirection,
    this.textAlign = TextAlign.start,
    this.isShimmerView = false,
    this.overflow = TextOverflow.visible,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return ConditionalParentWidget(
      condition: isShimmerView!,
      parentBuilder: (Widget child) => Container(
          height: (size ?? AppDimen.textSize_16) + 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(AppDimen.appBorderRadius)),
            color: shimmerColor ?? appColors.shimmerplaceholderColor,
          ),
          child: child),
      child: Text(
        isShimmerView! ? ' $text ' : text,
        style: TextStyle(
          color: isShimmerView! && shimmerColor == null
              ? appColors.shimmerplaceholderColor
              : isShimmerView! && shimmerColor != null
                  ? shimmerColor
                  : color ?? appColors.customTextColor,
          fontSize: size ?? AppDimen.textSize_16,
          fontFamily: AppFont.font,
          fontWeight: fontWeight ?? AppFont.medium,
          fontFamilyFallback: ['Roboto'],
          letterSpacing: -0.1,
        ),
        textAlign: textAlign,
        textDirection: textDirection,
        overflow: overflow,
        maxLines: maxLines,
      ),
    );
  }
}