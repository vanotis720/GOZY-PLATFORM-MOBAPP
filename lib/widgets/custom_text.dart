import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/conditional_parent_widget.dart';

double maxwidthamountWidget = 150;

class CustomText extends GetView {
  String text;
  double? size;
  double? maxWidth;
  FontWeight? fontWeight;
  Color? color;
  final Color? decorationColor;
  final Color? shimmerColor;
  TextAlign textAlign;
  final bool isSoftWrap;
  final String? font;
  final bool? isShimmerView;
  final String? symbol;
  final TextOverflow? overflow;
  final TextStyle? textStyle;
  TextDirection? textDirection;
  final AlignmentGeometry? alignment;
  final TextDecoration? textDecoration;
  final GestureTapCallback? onTap;
  dynamic maxLines;

  CustomText({
    super.key,
    required this.text,
    this.size,
    this.fontWeight = AppFont.medium,
    this.color,
    this.decorationColor,
    this.onTap,
    this.maxWidth,
    this.shimmerColor,
    this.textStyle,
    this.font,
    this.textDirection,
    this.symbol,
    this.alignment,
    this.textAlign = TextAlign.start,
    this.isSoftWrap = true,
    this.textDecoration,
    this.isShimmerView = false,
    this.overflow = TextOverflow.visible,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = TextStyle(
        color: isShimmerView! && shimmerColor == null
            ? appColors.shimmerplaceholderColor
            : isShimmerView! && shimmerColor != null
                ? shimmerColor
                : color ?? appColors.customTextColor,
        fontSize: size ?? AppDimen.textSize_16,
        fontFamily: font ?? AppFont.font,
        fontWeight: fontWeight,
        fontFamilyFallback: ['Roboto'],
        decoration: textDecoration,
        decorationColor: decorationColor);
    return ConditionalParentWidget(
      condition: isShimmerView!,
      parentBuilder: (Widget child) => Container(
          height: ((size ?? AppDimen.textSize_16) + 8) * 1,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(AppDimen.appBorderRadius)),
            color: shimmerColor ?? appColors.shimmerplaceholderColor,
          ),
          child: child),
      child: toOnTap(
        onTap: onTap,
        child: _getText(updatedStyle: textStyle),
      ),
    );
  }

  Widget _getText({required TextStyle updatedStyle}) {
    return Text(
      isShimmerView! ? ' $text ' : text,
      style: updatedStyle,
      textAlign: textAlign,
      softWrap: isSoftWrap,
      textDirection: textDirection,
      overflow: overflow,
      maxLines: maxLines,
    ).toCurrencyText(symbol: symbol);
  }
}

Widget flexibleText(
    {required dynamic itemPropertyName,
    double? fontSize,
    double? topPadding,
    int? maxLines,
    Color? color,
    bool? isFlexible,
    FontWeight? fontWeight,
    TextAlign? textAlign}) {
  return ConditionalParentWidget(
    condition: isFlexible!,
    parentBuilder: (Widget child) {
      return child.toStretch(isExpanded: false);
    },
    child: CustomText(
      text: itemPropertyName.toString().trim(),
      fontWeight: fontWeight ?? FontWeight.normal,
      maxLines: maxLines,
      size: fontSize ?? AppDimen.textSize_14,
      textAlign: textAlign ?? TextAlign.start,
      color: color ?? appColors.primaryColor,
    ).toPad(top: topPadding ?? 0),
  );
}

List<TextSpan>? getTextSpans(
    {Map<String, GestureTapCallback>? searchTextWithLinks,
    required String primaryText,
    FontWeight? fontWeight,
      FontWeight? primaryTextFontWeight,
      double? fontSize,
      Color? primaryColor,
    List<String>? highlightWords,
    Color? highlightColor}) {
  List<Match> linkmatches = [];
  List<Match> highlightmatches = [];
  if (searchTextWithLinks != null) {
    for (var searchText in searchTextWithLinks.keys) {
      linkmatches.addAll(searchText.allMatches(primaryText));
    }
  }
  if (highlightWords != null) {
    for (var searchText in highlightWords) {
      highlightmatches.addAll(searchText.allMatches(primaryText));
    }
  }

  final spans = <TextSpan>[];
  if (linkmatches.isEmpty && highlightmatches.isEmpty) {
    spans.add(
      TextSpan(
          text: primaryText,
          style: TextStyle(
              fontFamily: AppFont.font,
              fontWeight: primaryTextFontWeight,
              color: primaryColor ?? appColors.customTextColor,
              fontSize: fontSize)),
    );
  } else {
    if (linkmatches.isNotEmpty) {
      spans.addAll(getLinkTextSpanList(
          matches: linkmatches,
          primaryTextFontWeight: primaryTextFontWeight,
          primaryText: primaryText,
          primaryColor: primaryColor,
          fontSize: fontSize,
          searchTextWithLinks: searchTextWithLinks,
          fontWeight: fontWeight,
          highlightColor: highlightColor));
    } else {
      spans.addAll(getLinkTextSpanList(
          matches: highlightmatches,
          primaryTextFontWeight: primaryTextFontWeight,
          fontSize: fontSize,
          primaryText: primaryText,
          primaryColor: primaryColor,
          fontWeight: fontWeight,
          highlightColor: highlightColor));
    }
  }

  return spans;
}

List<TextSpan> getLinkTextSpanList(
    {required List<Match> matches,
    required String primaryText,
    Map<String, GestureTapCallback>? searchTextWithLinks,
    FontWeight? fontWeight,
      Color? primaryColor,
      FontWeight? primaryTextFontWeight,
      double? fontSize,
    Color? highlightColor}) {
  final spans = <TextSpan>[];
  for (var i = 0; i < matches.length; i++) {
    final strStart = i == 0 ? 0 : matches[i - 1].end;
    final match = matches[i];
    spans.add(
      TextSpan(
        text: primaryText.substring(
          strStart,
          match.start,
        ),
        style: TextStyle(fontFamily: AppFont.font, fontSize: fontSize, color: primaryColor ?? appColors.customTextColor, fontWeight: primaryTextFontWeight,)
      ),
    );
    spans.add(
      TextSpan(
        text: primaryText.substring(
          match.start,
          match.end,
        ),
        recognizer: (TapGestureRecognizer()
          ..onTap = searchTextWithLinks != null
              ? searchTextWithLinks[primaryText.substring(
                  match.start,
                  match.end,
                )]
              : null),
        style: TextStyle(color: highlightColor ?? appColors.secondaryColor, fontWeight: fontWeight, fontFamily: AppFont.font, fontSize: fontSize),
      ),
    );
  }
  spans.add(TextSpan(text: primaryText.substring(matches.last.end), style: TextStyle(fontFamily: AppFont.font, fontSize: fontSize, color: primaryColor ?? appColors.customTextColor, fontWeight: primaryTextFontWeight,)));
  return spans;
}