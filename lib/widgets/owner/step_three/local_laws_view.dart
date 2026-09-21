import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/screens/views/owner/step_three/step_three_controller.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_text.dart';

import '../../../resources/app_lang.dart';

class LocalLawsView extends GetView {
  @override
  StepThreeController controller;

  LocalLawsView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return [
      AppDimen.startMargin.toHeight(),
      CustomText(
        text: label_attention.tr,
        size: AppDimen.textSize_14,
        fontWeight: AppFont.bold,
      ),
      12.toHeight(),
      CustomText(
        text: label_local_laws_header_text.tr,
        size: AppDimen.textSize_14,
      ),
      AppDimen.startMargin.toHeight(),
      CustomText(
        text: label_local_laws_desc_text.trParams({'field': APP_NAME}),
        textAlign: TextAlign.start,
        fontWeight: AppFont.regular,
        size: AppDimen.textSize_14,
      ),
      AppDimen.startMargin.toHeight(),
    ].toScroll();
  }
}