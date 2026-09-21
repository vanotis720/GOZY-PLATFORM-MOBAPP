import 'package:flutter/material.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common_extension_functions.dart';

class AdaptiveFittedText extends StatelessWidget {

  /*
  @text - content for text widget  (Required)
  @size - font size of  content for text widget (Optional)
  @fontWeight -  The typeface thickness to use when painting the text  (Optional)
  @color - The color to use when painting the text.(Optional)
  @textAlign - How the text should be aligned horizontally.(Optional)
  @symbol -  align & apply various styleto the text widget based on currency symbol(Optional)
  @overflow - How visual overflow should be handled.(Optional)
  @onTap - function when click that text (Optional)
   */
  final String text;
  final double? size;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign textAlign;
  final String? symbol;
  final TextOverflow overflow;
  final GestureTapCallback? onTap;

  const AdaptiveFittedText({
    super.key,
    required this.text,
    this.size,
    this.fontWeight = AppFont.medium,
    this.color,
    this.onTap,
    this.symbol,
    this.textAlign = TextAlign.start,
    this.overflow = TextOverflow.visible,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
        fit: BoxFit.scaleDown,
        child: toOnTap(
          onTap: onTap,
          child: Text(
            text,
            style: TextStyle(
              color: color ?? appColors.customTextColor,
              fontSize: size ?? AppDimen.textSize_16,
              fontFamily: AppFont.font,
              fontWeight: fontWeight,
              fontFamilyFallback: ['Roboto'],
              letterSpacing:  -0.1,
            ),
            textAlign: textAlign,
            overflow: overflow,
          ).toCurrencyText(symbol: symbol),
        ));
  }
}