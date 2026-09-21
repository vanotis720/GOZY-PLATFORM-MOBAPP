import 'package:flutter/material.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common_extension_functions.dart';

class CustomRangefilterText extends StatelessWidget {

  /*
  purpose - show first and second text with hypen with header view
  @labelFirst - text which first range selection content  (Optional)
  @labelSecond - text which second range selection content  (Optional)
  @headerText -  content  for header title text  (Optional)
  @symbol -  align & apply various styleto the text widget based on currency symbol(Optional)
   */
  final String labelFirst;
  final String labelSecond;
  final String headerText;

  final double? headerTextFontSize;

  final FontWeight? headerTextFontWeight;

  final String? symbol;

  const CustomRangefilterText({
    super.key,
    this.labelFirst = "",
    this.labelSecond = "",
    this.headerText = "",
    this.headerTextFontSize,
    this.headerTextFontWeight,
    this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    return [
      Text(
        headerText,
        textAlign: TextAlign.start,
        style: TextStyle(
            fontSize: headerTextFontSize ?? AppDimen.textSize_16,
            fontWeight: headerTextFontWeight ?? FontWeight.w600,
            color: appColors.customTextColor),
      ).toCurrencyText(symbol: symbol),
      12.toHeight(),
      [
        Text(
          labelFirst,
          style: TextStyle(
              fontSize: AppDimen.textSize_14,
              fontWeight: FontWeight.normal,
              color: appColors.customTextColor),
        ),
        2.5.toWidth(),
        Text(
          '-',
          style: TextStyle(
              fontSize: AppDimen.textSize_14,
              fontWeight: FontWeight.normal,
              color: appColors.customTextColor),
        ),
        2.5.toWidth(),
        Text(
          labelSecond,
          style: TextStyle(
              fontSize: AppDimen.textSize_14,
              fontWeight: FontWeight.normal,
              color: appColors.customTextColor),
        ).toCurrencyText(symbol: symbol),
      ].toRow(mainAxisAlignment: MainAxisAlignment.start),
    ].toColumn();
  }
}