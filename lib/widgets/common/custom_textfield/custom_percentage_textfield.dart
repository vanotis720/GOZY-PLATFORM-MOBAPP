import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_layout.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_text.dart';
import 'package:gozy/widgets/custom_textfield.dart';

import '../../../generated/assets.dart';
import '../../../resources/app_colors.dart';
import '../../custom_tool_tip.dart';
import '../../rect_getter.dart';
import '../custom_painter/custom_tooltip_painter.dart';

class CustomPercentageTextfield extends StatelessWidget {
  CustomPercentageTextfield({
    super.key,
    this.hintText,
    this.controller,
    this.textInputAction,
    this.title,
    this.onTap,
    this.focusNode,
    this.onSubmitted,
    this.tooltipcontent
  });

  TextEditingController? controller;
  String? hintText;
  String? title;
  BorderRadiusGeometry? borderRadiusGeometry;
  ValueChanged<String>? onSubmitted;
  TextInputAction? textInputAction;
  GestureTapCallback? onTap;
  FocusNode? focusNode;
  String? tooltipcontent;

  Widget _getToolTips() {
    CustomTooltipPainter customShapePointer = CustomTooltipPainter(
        isItemSelected: true,
        borderRadius: 6,
        fontSize: AppDimen.textSize_14,
        isDisableStroke: true,
        contentBGColor: appColors.black,
        padding: overALLThemeType == 3
            ? EdgeInsets.only(left: 18, right: 18, bottom: 7, top: 5)
            : null,
        textColor: appColors.white,
        content: tooltipcontent ?? ""
    );

    return getToolTipWidget(
      customShapePointer: customShapePointer,
      startMargin: 6,
      controller: basecontroller,
      globalKey: RectGetter.createGlobalKey(),
      pagetype: 'textfield',
      overlayWidget: Assets.drawableInfoToolTip.toSVG(size: 13, fit: BoxFit.scaleDown, colour: AppColors.staticblack),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool? isunderline = appLayoutMap[AppLayout.inputType]?.themeType == 4;

    return [
      if (title != null && title!.isNotEmpty)
        [
          CustomTitleText(
            text: title!,
            size: AppDimen.textSize_18,
          ).toPad(bottom: (isunderline) ? 0 : 10),
          if (tooltipcontent != null && tooltipcontent!.isNotEmpty)
            _getToolTips().toPad(bottom: appLayoutMap[AppLayout.inputType]?.themeType == 4 ? 0 : 5),
        ].toRow(mainAxisAlignment: MainAxisAlignment.start),
      toOnTap(
        onTap: onTap,
        child: Obx(() {
          changeTextFieldFocus.value;
          return isunderline
              ? Container(
                  padding: appLayoutMap[AppLayout.inputType]?.themeType == 4
                      ? EdgeInsets.zero
                      : pad(start: 18),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                          color: (focusNode?.hasFocus ?? false)
                              ? appColors.black
                              : (appLayoutMap[AppLayout.inputType]?.themeType == 3
                                      ? appColors.customBorderColor
                                      : null) ??
                                  appColors.customBorderColor,
                          width: 0.5),
                    ),
                  ),
                  child: getTextFieldItem(),
                )
              : Container(
                  padding: pad(start: 18),
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
      Expanded(
        child: Theme(
          data: ThemeData(
              textSelectionTheme: TextSelectionThemeData(
                  selectionColor: appColors.black.withValues(alpha: 0.1), cursorColor: appColors.black)),
          child: CustomTextField(
            controller: controller,
            textInputAction: textInputAction,

            keyboardType: TextInputType.numberWithOptions(decimal: true),
            filteringTextInputFormatter: [
              LengthLimitingTextInputFormatter(5),
              FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}\.?\d{0,2}')),
              TextInputFormatter.withFunction((oldValue, newValue) {
                final text = newValue.text;
                if (text.isNotEmpty && (text == '00' || text[0] == '.')) return oldValue;
                return text.isNotEmpty && double.parse(text) > 99.99 ? oldValue : newValue;
              }),
            ],
            hintText: hintText ?? title,
            textColor: appColors.customTextColor,
            onSubmitted: onSubmitted,
            focusNode: focusNode,
          ),
        ),
      ),
      Container(
        width: 48,
        height: 48,
        alignment: AlignmentDirectional.center,
        decoration: appLayoutMap[AppLayout.inputType]?.themeType != 4 ? BoxDecoration(
          color: appColors.black,
          border: Border.all(color: appColors.black, width: 0.5),
          borderRadius: borderRadiusGeometry ?? BorderRadiusGeometry.horizontal(end: Radius.circular(appLayoutMap[AppLayout.inputType]!.borderRadius))
        ) : null,
        child: CustomText(
          text: '%',
          color: appLayoutMap[AppLayout.inputType]?.themeType == 4 ? appColors.black : appColors.white,
        ),
      )
    ].toRow();
  }
}