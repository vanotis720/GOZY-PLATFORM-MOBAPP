import 'package:flutter/material.dart';
import 'package:gozy/app.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/screens/views/base_controller.dart';

class CustomOverflowFunctionText extends StatelessWidget {
  final String text;
  final double? size;
  final double? maxWidth;
  final FontWeight? fontWeight;
  final TextAlign textAlign;
  final TextOverflow overflow;
  final ValueChanged<bool>? onTextOverflowed;
  final dynamic maxLines;
  /*
  @text - content for text widget  (Required)
  @size - font size of  content for text widget (Optional)
  @fontWeight -  The typeface thickness to use when painting the text  (Optional)
  @maxWidth -   based on given width apply textoverflow (Optional)
  @onTextOverflowed - function to find that text is overflow for given width(Optional)
  @overflow - How visual overflow should be handled.(Optional)
  @maxLines -  An optional maximum number of lines for the text to span, wrapping if necessary.(Optional)
   */

  const CustomOverflowFunctionText({
    super.key,
    required this.text,
    this.size,
    this.fontWeight = AppFont.medium,
    this.maxWidth,
    this.onTextOverflowed,
    this.textAlign = TextAlign.start,
    this.overflow = TextOverflow.visible,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = TextStyle(
      color: appColors.customTextColor,
      fontSize: size ?? AppDimen.textSize_16,
      fontFamily: AppFont.font,
      fontWeight: fontWeight,
      fontFamilyFallback: ['Roboto'],
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (onTextOverflowed != null) {
        bool isoverflow =
        App().hasTextOverflow(text, textStyle, maxLines: maxLines, maxWidth: maxWidth ?? deviceWidth);
        onTextOverflowed!(isoverflow);
      }
    });
    return Text(
      text,
      style: textStyle,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }

}