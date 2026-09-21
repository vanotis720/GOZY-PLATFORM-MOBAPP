import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/owner/step_three/step_three_controller.dart';
import 'package:gozy/widgets/checkbox_group.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_text.dart';

class CarRulesSelectionView extends GetView {
  @override
  StepThreeController controller;

  CarRulesSelectionView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return [
      CustomText(
        text: label_let_know_your_condition.tr,
        size: AppDimen.textSize_16,
        fontWeight: AppFont.medium,
      ).toPad(top: AppDimen.startMargin),
      SingleChildScrollView(
        child: GetBuilder(
            init: controller,
            id: controller.rxSelectedHouseRules.id,
            builder: (context) {
              return ListingsFeaturesGroup(
                isFromFilter: true,
                showLessFilterItemCount: 2,
                topPadding: 0,
                labels: controller.houseRules,
                onSelected: controller.rxSelectedHouseRules,
                isShowNetworkIcon: false,
                isShowDivider: false,
                isRemoveShowLessAndMore: true,
                controller: controller,
              ).toPad(top: 15);
            }),
      ).toStretch(),
    ].toColumn(crossAxisAlignment: CrossAxisAlignment.start);
  }

  Future<bool> setValidation() async {
    if (controller.listingSettingData != null) {
      return Future.value(true);
    } else {
      controller.checkNetwork(controller.listOfCurrencies!.isEmpty
          ? controller.getCurrenciesList
          : controller.getListingSettings);
      return Future.value(false);
    }
  }
}