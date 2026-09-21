import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/app.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/screens/views/base_controller.dart';

class CustomResizeText extends StatelessWidget {

  /*
  @text - content for text widget  (Required)
  @size - font size of  content for text widget (Optional)
  @fontWeight -  The typeface thickness to use when painting the text  (Optional)
  @color - The color to use when painting the text.(Optional)
  @textAlign - How the text should be aligned horizontally.(Optional)
  @maxLines -  An optional maximum number of lines for the text to span, wrapping if necessary.
   */
  final String text;
  double? size;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign textAlign;
  final dynamic maxLines;
  RxDouble rxTextSize = AppDimen.textSize_22.obs;


  CustomResizeText({
    super.key,
    required this.text,
    this.size,
    this.fontWeight = AppFont.medium,
    this.color,
    this.textAlign = TextAlign.start,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = TextStyle(
      color: color ?? appColors.customTextColor,
      fontSize: size ?? AppDimen.textSize_16,
      fontFamily: AppFont.font,
      fontWeight: fontWeight,
      fontFamilyFallback: ['Roboto'],
    );
    rxTextSize.value = size ?? AppDimen.textSize_16;
    return Obx(() {
      size = rxTextSize.value;
      textStyle = textStyle.copyWith(fontSize: size!);
      return Builder(builder: (context) {
        bool isoverflow = App().hasTextOverflow(text, textStyle, maxLines: maxLines, maxWidth: deviceWidth);
        if (isoverflow) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            rxTextSize.value = (size ?? AppDimen.textSize_16) - 0.2;
          });
        }
        return Opacity(
          opacity: isoverflow ? 0 : 1,
          child: Text(
            text,
            style: textStyle,
            textAlign: textAlign,
            maxLines: maxLines,
          ),
        );
      });
    });
  }
}