import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_layout.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/custom_textfield.dart';

class CustomTextfieldArea extends StatelessWidget {
  CustomTextfieldArea({
    super.key,
    required this.hintText,
    required this.controller,
    required this.minLines,
    required this.maxLines,
    required this.borderTextfieldPadding,
    this.characterlength,
    this.focusNode,
    this.enabled,
    this.readOnly,
    this.decoration,
    this.height,
  });

  TextEditingController? controller;
  String? hintText;
  EdgeInsetsGeometry? borderTextfieldPadding;
  FocusNode? focusNode;
  bool? enabled;
  bool? readOnly;
  int? characterlength;
  int? minLines;
  int? maxLines;
  Decoration? decoration;
  double? height;

  @override
  Widget build(BuildContext context) {
    bool? isunderline = appLayoutMap[AppLayout.inputType]?.themeType == 4;
    print('test9filed ${basecontroller.hashCode}');
    return Obx(() {
          changeTextFieldFocus.value;
          return isunderline
              ? Container(
                  height: height,
                  padding: borderTextfieldPadding,
                  decoration: decoration,
                  child: getTextFieldItem(),
                )
              : Container(
                  height: height,
                  padding: borderTextfieldPadding,
                  decoration: BoxDecoration(
                    color: appLayoutMap[AppLayout.inputType]?.themeType == 3
                        ? appColors.white
                        : null,
                    border: Border.all(
                        color: (focusNode?.hasFocus ?? false)
                            ? appColors.black
                            : appColors.customBorderColor,
                        width: 0.5),
                    borderRadius: BorderRadius.all(
                         Radius.circular( appLayoutMap[AppLayout.inputType]?.themeType == 3
                            ? appLayoutMap[AppLayout.inputType]!.borderRadius / 1.5
                            : appLayoutMap[AppLayout.inputType]?.borderRadius ?? 4.0)),
                    ),
                child: getTextFieldItem(),
              );
      });
  }

  Widget getTextFieldItem() {
    return Theme(
      data: ThemeData(
          textSelectionTheme: TextSelectionThemeData(
              selectionColor: appColors.black.withValues(alpha: 0.1), cursorColor: appColors.black)),
      child: CustomTextField(
        characterlength: characterlength,
        controller: controller,
        enabled: enabled,
        isReadOnly: readOnly,
        enableSuggestions: true,
        keyboardType: TextInputType.multiline,
        contentPadding: EdgeInsets.zero,
        hintFontWeight:  AppFont.regular,
        maxLines: maxLines ?? 1,
        minLines: minLines ?? 1,
        focusNode: focusNode,
        hintText: hintText,
      ),
    );
  }
}