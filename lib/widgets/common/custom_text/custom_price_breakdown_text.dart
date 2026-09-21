import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:gozy/constant.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_text.dart';

class CustomPriceBreakdownText extends StatelessWidget {

  /*
  @label - on price view, what is that price  (Required)
  @amount - the amount for selected pice (Required)
  @isTotal -  highlight the amount and its label (Optional)
  @isSelectedSymbolNotNeeded -   avoid to apply the currency symbol (Optional)
  @tooltipWidget - add the tooltip to denote what is that price(Optional)
  @isDiscount - when price is discount need to apply font color & apply to minus value denote as deduction (Optional)
  @isHostServiceFee -   apply to minus value denote as deduction to host side without change colour (Optional)
  @isEstimatedEarning - denote that the amount is not original , estimated one change the color (Optional)
  @amountFontSize - amount font size (Optional)
  @isToolTipFirst - when true, show tooltip first before the label(Optional)
   */

  final String label;
  final String amount;
  final bool isTotal;
  final bool isSelectedSymbolNotNeeded;
  final Widget? tooltipWidget;
  final bool isDiscount;
  final bool isHostServiceFee;
  final bool isEstimatedEarning;
  final double? amountFontSize;
  final bool isToolTipFirst;
  final bool canConvertDouble;
  final String? symbol;

  const CustomPriceBreakdownText({
    super.key,
    required this.label,
    required this.amount,
    this.isTotal = false,
    this.isSelectedSymbolNotNeeded = false,
    this.tooltipWidget,
    this.isDiscount = false,
    this.isHostServiceFee = false,
    this.isEstimatedEarning = false,
    this.amountFontSize,
    this.isToolTipFirst = false,
    this.canConvertDouble = true,
    this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    final double parsedAmount = double.tryParse(amount) ?? 0.0;

    if (parsedAmount <= 0.0 && !isTotal) {
      return const SizedBox.shrink();
    }

    final Color textColor = isDiscount ? appColors.discountAmountColor : appColors.customTextColor;

    final FontWeight fontWeight = (isTotal || isEstimatedEarning) ? AppFont.medium : AppFont.regular;

    final Color priceColor =
        isDiscount || isSelectedSymbolNotNeeded ? appColors.discountAmountColor : textColor;

    final String effectiveSymbol = symbol ?? selectedCurrencySymbol;

    final String formattedAmount = amount.toNumberFormat(symbol: effectiveSymbol, canConvertDouble: canConvertDouble);
    final bool isRtl = intl.Bidi.isRtlLanguage(Get.locale?.languageCode ?? 'en');

    return [
      10.toHeight(),
      [
        _buildLabel(textColor, fontWeight, isRtl).toStretch(),
        5.toWidth(),
        if (isDiscount || isHostServiceFee)
          Text(
            '- ',
            style: TextStyle(color: priceColor),
          ),
        _buildAmount(formattedAmount, priceColor, fontWeight),
      ].toRow(
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
      10.toHeight(),
    ].toColumn(
      mainAxisSize: MainAxisSize.min,
    );
  }

  Widget _buildLabel(Color color, FontWeight weight, bool isRtl) {
    if (tooltipWidget != null) {
      return Text.rich(
        textDirection: TextDirection.ltr,
        textAlign: isRtl ? TextAlign.end : TextAlign.start,
        TextSpan(
          children: [
            if (isToolTipFirst && !isRtl) WidgetSpan(child: tooltipWidget!.toPad(top: 3, end: 3)),
            ...TextSpan(
              text: label,
              style: TextStyle(color: color, fontWeight: weight, fontSize: amountFontSize,fontFamily: AppFont.font),
            ).toCurrencyTextSpan(symbol: isSelectedSymbolNotNeeded ? "" : (symbol ?? selectedCurrencySymbol)),
            if ((!isToolTipFirst) || (isRtl && isToolTipFirst)) WidgetSpan(child: tooltipWidget!.toPad(top: 3, end: (isRtl && isToolTipFirst) ? 3 : 0)),
          ],
        ),
      );
    }

    return Text(
      label,
      style: TextStyle(
          color: color,
          fontWeight: weight,
          fontSize: amountFontSize,
          fontFamily: AppFont.font),
      maxLines: 3,
      textDirection: TextDirection.ltr,
      textAlign: isRtl ? TextAlign.end : TextAlign.start,
    ).toCurrencyText(
      symbol: isSelectedSymbolNotNeeded ? "" : (symbol ?? selectedCurrencySymbol),
    );
  }

  Widget _buildAmount(String text, Color color, FontWeight weight) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxwidthamountWidget),
      child: Text(
        text,
        style: TextStyle(
            color: color,
            fontWeight: weight,
            fontSize: amountFontSize,
            fontFamily: AppFont.font),
        textAlign: TextAlign.end,
      ).toCurrencyText(
        symbol: symbol ?? selectedCurrencySymbol,
      ),
    );
  }
}