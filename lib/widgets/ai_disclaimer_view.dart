import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';

import '../screens/views/base_controller.dart';

class AIDisclaimerView extends StatelessWidget {
  const AIDisclaimerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontFamily: AppFont.font,
              fontSize: AppDimen.textSize_12,
              color: appColors.textColor,
              height: 1.4,
            ),
            children: [
              TextSpan(
                text: "${"label_ai_make_mistake".tr} ",
                style: const TextStyle(
                  fontWeight: AppFont.semiBold,
                ),
              ),
               TextSpan(
                text: "label_ai_important_info".tr,
                 style: TextStyle(
                   color: appColors.secondaryText,
                   fontWeight: AppFont.medium
                 )
              ),
            ],
          ),
        ),
      ),
    );
  }
}