import 'package:flutter/material.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_text.dart';

import '../../../resources/app_font.dart';

class CustomHeaderWithLabelText extends StatelessWidget {
  final String? headerText;
  final String? labelText;
  final double? headerFontSize;
  final double? labelFontSize;
  final double? verticalPad;
  final Color? labelColor;
  final Color? headerColor;
  final FontWeight? headerFontWeight;
  final FontWeight? labelFontWeight;

  /*
  purpose - show header and description base text column view
  @headerText - text which have Heading based style  (Required)
  @labelText - text which have Heading based style  (Optional)
  @headerFontSize -  font size for header text  (Optional)
  @verticalPad -  space between header and label text (Optional)
   */

  const CustomHeaderWithLabelText({
    super.key,
    this.headerText,
    this.labelText,
    this.headerFontSize,
    this.labelFontSize,
    this.verticalPad,
    this.labelColor,
    this.headerColor,
    this.headerFontWeight,
    this.labelFontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return switch ((headerText, labelText)) {
      (String header, String label) => [
          Text(
            header,
            style: TextStyle(
                fontSize: headerFontSize ?? AppDimen.textSize_16,
                fontWeight: headerFontWeight ?? AppFont.medium,
                color: headerColor ?? appColors.customTextColor),
            textAlign: TextAlign.start,
          ),
          (verticalPad ?? 12).toHeight(),
          CustomText(
            text: label,
            color: labelColor ?? appColors.customTextColor,
            fontWeight: labelFontWeight ?? AppFont.regular,
            size: labelFontSize ?? AppDimen.textSize_14,
          ),
        ].toColumn(),
      (null, String label) => CustomText(
          text: label,
          color: labelColor ?? appColors.customTextColor,
          fontWeight: labelFontWeight ?? AppFont.medium,
          size: labelFontSize ?? AppDimen.textSize_16,
        ),
      (String? header, null) => Center(
          child: Text(
            header ?? '',
            style: TextStyle(
                fontFamily: AppFont.font,
                fontSize: headerFontSize ?? AppDimen.textSize_16,
                fontWeight: headerFontWeight ?? AppFont.medium,
                color: headerColor ?? appColors.customTextColor),
            textAlign: TextAlign.center,
          ),
        ),
    };
  }
}