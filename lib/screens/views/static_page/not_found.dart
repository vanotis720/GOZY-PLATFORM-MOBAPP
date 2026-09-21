import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/widgets/common_extension_functions.dart';

import '../../../resources/app_dimen.dart';
import '../../../resources/app_font.dart';
import '../../../resources/app_lang.dart';
import '../../../widgets/custom_text.dart';
import '../base_controller.dart';

class NotFound extends StatelessWidget {
  final String? errorMessage;

  const NotFound({super.key, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      isShowAppBar: true,
      backIconWidget: getBackIconWidget(
          themeType: overALLThemeType,
          onTap: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.back();
            });
          }),
      controller: basecontroller,
      body: show404Widget(),
    );
  }

  Widget show404Widget() {
    return [
      CustomText(
        text: label_write_review_empty.tr,
        alignment: Alignment.center,
        size: AppDimen.textSize_26,
        color: appColors.textColor,
        fontWeight: AppFont.semiBold,
      ),
      CustomText(
        text: errorMessage ?? label_write_review_error_content.tr,
        textAlign: TextAlign.center,
        size: AppDimen.textSize_16,
        color: appColors.textColor,
        fontWeight: AppFont.medium,
      ),
      CustomText(
        text: label_write_review_error_code.tr,
        alignment: Alignment.center,
        size: AppDimen.textSize_12,
        color: appColors.textfieldHintColor,
        fontWeight: AppFont.medium,
      ),
    ]
        .toColumn(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center)
        .toPad(start: 24, end: 24)
        .toResizeWidget(isDeviceFit: true);
  }
}