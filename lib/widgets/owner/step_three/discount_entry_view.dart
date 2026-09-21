import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/screens/views/owner/step_three/step_three_controller.dart';
import 'package:gozy/widgets/common/custom_textfield/custom_percentage_textfield.dart';
import 'package:gozy/widgets/common_extension_functions.dart';

import '../../../resources/app_lang.dart';

class DiscountEntryView extends GetView {
  @override
  StepThreeController controller;

  DiscountEntryView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> discountWidgets = [
      AppDimen.startMargin.toHeight(),
      _weeklyDiscountEntryWidget(),
      AppDimen.startMargin.toHeight(),
      _monthlyDiscountEntryWidget(),
      10.toHeight(),
      '${label_discounts.tr} ${label_for_longer_rating.tr}'.toExplanationTip()
    ];

    return toListView(
        key: const PageStorageKey<String>('discountentry'),
        itemCount: discountWidgets.length,
        itemBuilder: (context, index) {
          return discountWidgets[index];
        });
  }

  Widget _weeklyDiscountEntryWidget() {
    return CustomPercentageTextfield(
      tooltipcontent: label_weekly_tooltip_content.tr,
      title: "label_weekly_discount".tr,
      controller: controller.weeklyDiscountEditController,
      focusNode: controller.weeklyDiscountFocusNode,
      hintText: label_discount_hint_off.tr,
      onSubmitted: (value) {
        controller.monthlyDiscountFocusNode.changeFocus();
      },
      textInputAction: TextInputAction.next,
    );
  }

  Widget _monthlyDiscountEntryWidget() {
    return CustomPercentageTextfield(
      title: "label_monthly_discount".tr,
      tooltipcontent: label_monthly_tooltip_content.tr,
      controller: controller.monthlyDiscountEditController,
      hintText: label_discount_hint_off.tr,
      focusNode: controller.monthlyDiscountFocusNode,
      textInputAction: TextInputAction.done,
    );
  }

  bool setValidation() {
    if (controller.isSaveAndExit) {
      controller.isSaveAndExit = false;
      return true;
    }
    if (controller.weeklyDiscountFocusNode.hasFocus && Platform.isIOS) {
      controller.monthlyDiscountFocusNode.requestFocus();
      return false;
    } else if (MediaQuery.of(Get.context!).viewInsets.bottom > 0.0) {
      FocusManager.instance.primaryFocus?.unfocus();
      return false;
    } else
      return true;
  }
}