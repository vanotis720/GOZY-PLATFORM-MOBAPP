import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_layout.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_textfield.dart';

class CustomPrefixTextField extends StatelessWidget {
  CustomPrefixTextField({
    super.key,
    this.hintText,
    this.controller,
    this.textInputAction,
    this.prefixIcon,
    this.prefixIconWidget,
    this.suffixIconWidget,
    this.suffixIconQuarterTurns,
    this.suffixIcon,
    this.title,
    this.maxLines,
    this.minLines,
    this.textSize,
    this.keyboardType,
    this.textCapitalization,
    this.filteringTextInputFormatter,
    this.onTap,
    this.hintFontWeight,
    this.onChanged,
    this.borderTextfieldPadding,
    this.contentPadding,
    this.characterlength,
    this.focusNode,
    this.onSubmitted,
    this.enabled,
    this.filled,
    this.fillColor,
    this.applayout,
    this.borderWidth,
    this.inputBorder,
    this.hintTextColor,
    this.isReadOnly
  });

  TextEditingController? controller;
  String? hintText;
  bool? isReadOnly;
  String? title;
  String? prefixIcon;
  double? prefixIconSize;
  double? textSize;
  double? suffixIconSize;
  Widget? prefixIconWidget;
  Widget? suffixIconWidget;
  String? suffixIcon;
  int? maxLines;
  int? minLines;
  FontWeight? hintFontWeight;
  TextInputType? keyboardType;
  int? suffixIconQuarterTurns;
  TextCapitalization? textCapitalization;
  ValueChanged<String>? onSubmitted;
  ValueChanged<String>? onChanged;
  TextInputAction? textInputAction;
  GestureTapCallback? onTap;
  EdgeInsetsGeometry? borderTextfieldPadding;
  EdgeInsetsGeometry? contentPadding;
  List<TextInputFormatter>? filteringTextInputFormatter;
  FocusNode? focusNode;
  bool? enabled;
  Color? hintTextColor;
  int? characterlength;
  bool? filled;
  AppLayout? applayout;
  double? borderWidth;
  Color? fillColor;
  InputBorder? inputBorder;

  @override
  Widget build(BuildContext context) {
    int theme =  appLayoutMap[applayout ?? AppLayout.inputType]?.themeType ?? 1;
    double borderRadius =  appLayoutMap[ applayout ??AppLayout.inputType]?.borderRadius ?? 1;
    bool? isunderline = theme == 4;

    return [
      if (title != null && title!.isNotEmpty)
        CustomTitleText(
          text: title!,
          size: AppDimen.textSize_18,
        ).toPad(bottom: (isunderline ?? false) ? 0 : 10),
      toOnTap(
        onTap: onTap,
        child: Obx(() {
          changeTextFieldFocus.value;
          return isunderline
              ? Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                          color: (focusNode?.hasFocus ?? false)
                              ? appColors.black
                              : appColors.customBorderColor,
                          width: 0.5),
                    ),
                  ),
                  child: getTextFieldItem(),
                )
              : Container(
                  padding: borderTextfieldPadding ?? pad(w: 18),
                  decoration: BoxDecoration(
                    color: theme == 3 ? appColors.white : null,
                    border: Border.all(
                        color: (focusNode?.hasFocus ?? false)
                            ? appColors.black
                            : appColors.customBorderColor,
                        width: borderWidth ?? 0.5),
                    borderRadius: BorderRadius.all(
                        Radius.circular(borderRadius)),
                  ),
                  child: getTextFieldItem(),
                );
        }),
      ),
    ].toColumn();
  }

  Widget getTextFieldItem() {
    int? currentMaxLines =
        (controller != null && controller!.text.isNotEmpty) ? 1 : maxLines;
    int? currentMinLines =
        (controller != null && controller!.text.isNotEmpty) ? 1 : minLines;
    return [
      if (prefixIconWidget != null) prefixIconWidget!,
      if (prefixIcon != null)
        !(prefixIcon!.contains('.png'))
            ? prefixIcon!.toSVG(size: 16)
            : prefixIcon!.toPng(width: 16, height: 16),
      if (prefixIcon != null) 10.toWidth(),
      Expanded(
        child: Theme(
          data: ThemeData(
              textSelectionTheme: TextSelectionThemeData(
                  selectionColor: appColors.black.withValues(alpha: 0.1),
                  cursorColor: appColors.black)),
          child: CustomTextField(
            textColor: appColors.customTextColor,
            hintText: hintText ?? title,
            controller: controller,
            contentPadding: contentPadding,
            textInputAction: textInputAction,
            enabled: enabled,
            isReadOnly: isReadOnly,
            textSize: textSize,
            hintTextColor: hintTextColor,
            onChanged: onChanged,
            filled: filled,
            minLines: currentMinLines,
            maxLines: currentMaxLines,
            inputBorder: inputBorder,
            fillColor: fillColor,
            keyboardType: keyboardType,
            hintFontWeight: hintFontWeight,
            filteringTextInputFormatter: filteringTextInputFormatter,
            characterlength: characterlength,
            onSubmitted: onSubmitted,
            textCapitalization: textCapitalization,
            focusNode: focusNode,
          ),
        ),
      ),
      if (suffixIconWidget != null) suffixIconWidget!,
      if (suffixIcon != null)
        (suffixIcon!.contains('.svg'))
            ? suffixIcon!.toSVG(
                colour: appColors.black,
                quarterTurns: suffixIconQuarterTurns,
                size: 13,
              )
            : suffixIcon!.toPng(
                colour: appColors.black,
                quarterTurns: suffixIconQuarterTurns,
                width: 13,
                height: 13,
              ),
    ].toRow();
  }
}