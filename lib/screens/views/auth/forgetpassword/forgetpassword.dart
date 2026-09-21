import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_colors.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/auth/forgetpassword/forgetpassword_controller.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/widgets/common/custom_button/primary_button.dart';
import 'package:gozy/widgets/common/custom_text/adaptive_fitted_text.dart';
import 'package:gozy/widgets/common/custom_textfield/custom_prefix_textfield.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_stateful_widget.dart';
import 'package:gozy/widgets/custom_text.dart';

import '../../../../resources/app_layout.dart';
import '../../../../widgets/theme1/theme1_auth_appbar_widget.dart';
import '../../../../widgets/theme2/theme2_auth_appbar_widget.dart';
import '../../../../widgets/theme3/theme3_auth_appbar_widget.dart';
import '../../../../widgets/theme4/theme4_auth_appbar_widget.dart';

class ForgetPassword extends CustomStatefulWidget {
  const ForgetPassword({super.key});

  @override
  _ForgetPasswordStatefulWrapperState createState() => _ForgetPasswordStatefulWrapperState();
}

class _ForgetPasswordStatefulWrapperState extends CustomStatefulWidgetState<ForgetPassword> {
  final controller = Get.find<ForgetPasswordController>();

  static int? onForgotPasswordThemeType = appLayoutMap[AppLayout.forgotPassword]?.themeType;

  FocusNode forgotPassFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    controller.emailController.clear();
    controller.hideKeyBoard();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        backgroundColor: onForgotPasswordThemeType == 3 ? appColors.myTripsBGColor : null,
        resizeToAvoidBottomInset: true,
        controller: controller,
        isShowAppBar: false,
        isShowBGOnLoader: false,
        body: switch (onForgotPasswordThemeType) {
          1 => showTheme1BodyContent(),
          2 => showTheme2BodyContent(),
          3 => showTheme3BodyContent(),
          4 => showTheme4BodyContent(),
          _ => const SizedBox.shrink(),
        });
  }

  Widget showTheme1BodyContent() {
    return [
      Theme1AuthAppbarWidget(title: label_forget_password.tr, titleWidgets: const []),
      [
        _showForgetPasswordDesc(),
        _showEmailSection(),
        const Spacer(),
        _showForgetPasswordButton(),
      ].toColumn().toPad(horizontal: AppDimen.startMargin).toStretch(flex: 7),
    ].toColumn().toResizeWidget(height: deviceHeight * 0.95).toScroll();
  }

  Widget showTheme2BodyContent() {
    return [
      Theme2AuthAppbarWidget(
        title: label_forget_password.tr,
      ),
      _showForgetPasswordDesc(),
      _showEmailSection().toStretch(),
      _showForgetPasswordButton().toPad(bottom: AppDimen.startMargin),
    ].toColumn().toPad(horizontal: AppDimen.startMargin).toResizeWidget(isDeviceFit: true).toScroll();
  }

  Widget showTheme3BodyContent() {
    return [
      Theme3AuthAppbarWidget(title: label_forget_password.tr,),
      _showForgetPasswordDesc(isCenter: true),
      _showEmailSection().toStretch(),
      _showForgetPasswordButton().toPad(bottom: AppDimen.startMargin),
    ].toColumn().toPad(horizontal: AppDimen.startMargin).toResizeWidget(isDeviceFit: true).toScroll();
  }

  Widget showTheme4BodyContent() {
    return [
      Theme4AuthAppbarWidget(
        title: label_forget_password.tr,
      ),
      [
        _showForgetPasswordDesc(),
        _showEmailSection(),
        const Spacer(),
        _showForgetPasswordButton(),
      ].toColumn().toPad(horizontal: AppDimen.startMargin).toTopCornerWidget(radius: 20, bgcolor: appColors.white).toStretch()
    ].toColumn().toResizeWidget(height: deviceHeight * 0.97).toScroll();
  }

  Widget _showForgetPasswordDesc({bool? isCenter = false}) {
    return CustomText(
            textAlign: (isCenter ?? false) ? TextAlign.center : TextAlign.start,
            text: label_forget_password_desc.trParams({'field': reset_your_password.tr.toLowerCase()}),
            size: AppDimen.textSize_16,
            fontWeight: AppFont.regular)
        .toPad(top: 12);
  }

  Widget _showEmailSection() {
    return [
      CustomPrefixTextField(
        title: label_login_email.tr,
        focusNode: forgotPassFocusNode,
        prefixIcon: isShowTextFieldIcon ? Assets.theme4LoginEmail : null,
        hintTextColor: AppColors().textfieldHintColor,
        hintText: error_email_address.tr.toUpperLowerCase(),
        controller: controller.emailController,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
      )
    ].toColumn().toPad(top: AppDimen.startMargin);
  }

  Widget _showForgetPasswordButton() {
    return [
      PrimaryButton(
        buttonText: label_send_reset_link.tr,
        onTap: () {
          controller.validateCredentials(context);
        },
      ),
      if (onForgotPasswordThemeType == 2) _showBackToLogin()
    ].toColumn().toPad(
        top: AppDimen.startMargin, bottom: Platform.isIOS ? AppDimen.startMargin + 20 : AppDimen.startMargin);
  }

  Widget _showBackToLogin() {
    return Center(
      child: AdaptiveFittedText(
        text: back_to_login.tr,
        size: AppDimen.textSize_14,
        fontWeight: AppFont.regular,
        color: appColors.secondaryColor,
        onTap: () {
          FocusManager.instance.primaryFocus!.unfocus();
          Get.back();
        },
      ),
    ).toPad(top: AppDimen.startMargin);
  }
}