import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/widgets/bottom_sheet/add_phone_number/add_phone_controller.dart';
import 'package:gozy/widgets/common/custom_bottomsheet/custom_bottomsheet.dart';
import 'package:gozy/widgets/common/custom_button/primary_button.dart';
import 'package:gozy/widgets/common/custom_text/custom_showmore_text.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/common/custom_container/custom_container.dart';
import 'package:gozy/widgets/custom_text.dart';
import 'package:gozy/widgets/custom_textfield.dart';

import '../../../generated/assets.dart';
import '../../../resources/app_layout.dart';
import '../../common/custom_container/custom_bottom_item_shadow_container.dart';

class OtpScreenBottomSheet extends BaseController {
  final AddPhoneController _controller = Get.find();

  OtpScreenBottomSheet({required BaseController controller,int? themeType}) {
    showCustomBottomSheet(
      contentWidget: Obx(() {
        appThemeChanged.value;
        return CustomContainer(
          body: [
            [
              CustomText(
                text: label_otp_content.trParams({
                  'field': "${_controller.selectedCountryCode} ${_controller.phoneNumberController.text}."
                }),
                size: AppDimen.textSize_16,
                fontWeight: AppFont.regular,
                color: appColors.customTextColor,
              ),
              _showOTPField(),
              5.toHeight(),
              toOnTap(
                onTap: () {
                    controller.checkNetwork(() {
                      _controller.addPhoneNumber(isFromOtp: true);
                    });
                },
                child: RichText(
                  text: TextSpan(
                      text: doesnt_arrive_click_cancel.tr,
                      children: [
                        TextSpan(
                            text: ' ${label_try_again.tr}',
                            style: TextStyle(
                              fontSize: AppDimen.textSize_16,
                              color: appColors.secondaryColor,
                              fontWeight: AppFont.regular,
                              fontFamily: AppFont.font
                            ))
                      ],
                      style: TextStyle(
                        fontSize: AppDimen.textSize_16,
                        color: appColors.customTextColor,
                        fontWeight: AppFont.regular,
                        fontFamily: AppFont.font
                      )),
                ),
              ),
              24.toHeight(),
              toOnTap(
                onTap: () {
                  onBack();
                },
                child: CustomShowMoreText(
                  text: label_chnage_number.tr,
                  size: AppDimen.textSize_16,
                  color: appColors.secondaryColor,
                  showMoreIcon: Assets.drawableRightArrow,
                  fontWeight: AppFont.regular,
                  isReverseRotation: false,
                  showMoreIconTopPadding: 0,
                )
              ),
            ].toColumn().toPad(horizontal: AppDimen.startMargin),
            Spacer(),
            CustomBottomItemShadowContainer(
              padding: pad(w: AppDimen.startMargin, h: AppDimen.startMargin),
              body: PrimaryButton(
                buttonText: label_verify.tr,
                onTap: () {
                  bool isvalidate = _controller.validateCredentials("otp");
                  if (isvalidate) {
                    controller.checkNetwork(_controller.validateOTP);
                  }
                },
              ),
            )
          ].toColumn(mainAxisAlignment: MainAxisAlignment.start),
        );
      }),
      sheetCloseListener: () {
        _controller.otpController.clear();
      },
      title: label_verification_content.tr,
      backButtonWidget: getBackIconWidget(
        themeType: appLayoutMap[AppLayout.profile]?.themeType,
      ),
      titleFontSize: AppDimen.textSize_20,
    );
  }

  Widget _showOTPField() {
    return TitleTextField(
      focusNode: FocusNode(),
      title: label_defalut_digit.trParams({'field': "$characterLengthOTP"}),
      controller: _controller.otpController,
      textInputAction: TextInputAction.done,
      hintTextColor: appColors.textfieldHintColor,
      keyboardType: TextInputType.number,
      characterlength: characterLengthOTP,
      filteringTextInputFormatter: [FilteringTextInputFormatter.digitsOnly],
      hintText:
          label_digit_code.trParams({'field': "$characterLengthOTP - ${label_digit.tr.toUpperLowerCase()}"}),
    ).toPad(top: 16, bottom: 16);
  }
}