import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_layout.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_textfield.dart';

class CustomPasswordTextField extends StatelessWidget {

  /*
  @hintText - content for before enter the text from keyboard (Optional)
  @controller - A controller for an editable text field.(Optional)
  @textInputAction -  An action the user has requested the text input control to perform.  (Optional)
  @prefixIcon - to show prefix icon to denote which type of textfield(Optional)
  @title - to show prefix title to denote which type of textfield(Optional)
  @onTap -  function when click that TextField (Optional)
  @borderTextfieldPadding - padding for customTextfield (Optional)
  @isPasswordVisible - bool is visble thr
   */

  CustomPasswordTextField({
    super.key,
    this.hintText,
    this.controller,
    this.textInputAction,
    this.prefixIcon,
    this.title,
    this.onTap,
    this.borderTextfieldPadding,
    this.isPasswordVisible,
    this.focusNode,
    this.onSubmitted,
  });

  TextEditingController? controller;
  String? hintText;
  String? title;
  String? prefixIcon;
  ValueChanged<String>? onSubmitted;
  TextInputAction? textInputAction;
  GestureTapCallback? onTap;
  EdgeInsetsGeometry? borderTextfieldPadding;
  FocusNode? focusNode;
  RxBool? isPasswordVisible;

  @override
  Widget build(BuildContext context) {
    bool? isunderline = appLayoutMap[AppLayout.inputType]?.themeType == 4;

    return [
      if (title != null && title!.isNotEmpty)
        CustomTitleText(
          text: title!,
          size: AppDimen.textSize_18,
        ).toPad(bottom: (isunderline) ? 0 : 10),
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
                    color: appLayoutMap[AppLayout.inputType]?.themeType == 3 ? appColors.white : null,
                    border: Border.all(
                        color: (focusNode?.hasFocus ?? false)
                            ? appColors.black
                            : appColors.customBorderColor,
                        width: 0.5),
                    borderRadius: BorderRadius.all(
                        Radius.circular(appLayoutMap[AppLayout.inputType]?.borderRadius ?? 4.0)),
                  ),
                  child: getTextFieldItem(),
                );
        }),
      ),
    ].toColumn();
  }

  Widget getTextFieldItem() {
    return [
      if (prefixIcon != null)
       (prefixIcon!.contains('.svg'))
              ? prefixIcon!.toSVG(size: 16)
              : prefixIcon!.toPng(width: 16, height: 16),
      if (prefixIcon != null) 10.toWidth(),
      Expanded(
        child: Theme(
          data: ThemeData(
              textSelectionTheme: TextSelectionThemeData(
                  selectionColor: appColors.black.withValues(alpha: 0.1), cursorColor: appColors.black)),
          child: CustomTextField(
            textColor: appColors.customTextColor,
            hintText: hintText ?? title,
            controller: controller,
            maxLines: 1,
            obscureText: isPasswordVisible?.value,
            textInputAction: textInputAction,
            characterlength: textFieldCharacterLength,
            onSubmitted: onSubmitted,
            focusNode: focusNode,
            isCharOnly: true,
          ),
        ),
      ),
      15.toWidth(),
      toOnTap(
          isRetainFocus: true,
          onTap: () {
            if (isPasswordVisible != null) isPasswordVisible?.value = !isPasswordVisible!.value;
          },
          child: (isPasswordVisible != null && isPasswordVisible!.value
                  ? Assets.drawablePasswordInvisible
                  : Assets.drawablePasswordVisible)
              .toSVG(colour: appColors.black)),
    ].toRow();
  }
}