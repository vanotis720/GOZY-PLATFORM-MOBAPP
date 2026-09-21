import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/screens/views/owner/step_three/step_three_controller.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_text.dart';

import '../../../resources/app_dimen.dart';
import '../../../resources/app_lang.dart';
import '../../../screens/views/base_controller.dart';

class GuestRequirementsView extends GetView {
  @override
  StepThreeController controller;

  GuestRequirementsView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return [
      AppDimen.startMargin.toHeight(),
      CustomText(
        text: label_let_renters_know.tr,
        size: AppDimen.textSize_18,
        fontWeight: AppFont.medium,
      ),
      12.toHeight(),
      CustomText(
        text: "${label_let_renters_can_book_instantly.tr}:",
        size: AppDimen.textSize_16,
        fontWeight: AppFont.regular,
      ),
      18.toHeight(),
      for (dynamic element in controller.guestRequirementsList)
        [
          Assets.drawableTickStyle.toSVG(
              size: AppDimen.textSize_14,
              colour: appColors.discountAmountColor),
          12.toWidth(),
          CustomText(
            text: element.itemName,
            size: AppDimen.textSize_14,
          ).toStretch(isExpanded: false)
        ]
            .toRow(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center)
            .toPad(bottom: 15),
      3.toHeight(),
      label_renter_requirements_hint.tr.toExplanationTip(),
      18.toHeight()
    ].toScroll();
  }
}