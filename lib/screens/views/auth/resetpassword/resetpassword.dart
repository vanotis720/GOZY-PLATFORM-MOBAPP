import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/auth/resetPassword/resetpassword_controller.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/widgets/common/custom_button/primary_button.dart';
import 'package:gozy/widgets/common/custom_text/adaptive_fitted_text.dart';
import 'package:gozy/widgets/common/custom_textfield/custom_password_textfield.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_stateful_widget.dart';
import 'package:gozy/widgets/custom_text.dart';
import 'package:gozy/widgets/show_done_view.dart';

import '../../../../resources/app_font.dart';
import '../../../../resources/app_layout.dart';
import '../../../../widgets/common/custom_container/custom_bottom_item_shadow_container.dart';
import '../../../../widgets/theme1/theme1_auth_appbar_widget.dart';
import '../../../../widgets/theme2/theme2_auth_appbar_widget.dart';
import '../../../../widgets/theme3/theme3_auth_appbar_widget.dart';
import '../../../../widgets/theme4/theme4_auth_appbar_widget.dart';
import '../../base_controller.dart';

class ResetPassword extends CustomStatefulWidget {
  const ResetPassword({super.key});

  @override
  _ResetPasswordStatefulWrapperState createState() =>
      _ResetPasswordStatefulWrapperState();
}

class _ResetPasswordStatefulWrapperState
    extends CustomStatefulWidgetState<ResetPassword> {
  final controller = Get.find<ResetPasswordController>();
  static AppLayoutModel? profilelayout = appLayoutMap[AppLayout.profile];
  static int? onForgotPasswordThemeType =
      appLayoutMap[AppLayout.forgotPassword]?.themeType;
  double textFieldSpacing = 18;
  double buttonBorderRadius = 0;

  @override
  void initState() {
    super.initState();
    print("ResetPassword Init--> ${Get.arguments}");
    if (Get.arguments['screenType'] != null) {
      controller.screenType = Get.arguments['screenType'];
    } else {
      controller.ResetPwdTokenParams = Get.arguments;
    }
    controller.hideKeyBoard();
    controller.confirmPasswordController.text = "";
    controller.newPasswordController.text = "";
    controller.currentPasswordController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    switch (onForgotPasswordThemeType) {
      case 1:
        buttonBorderRadius = 20;
        break;
      case 3:
        buttonBorderRadius = 30;
        break;
      default:
        buttonBorderRadius = 12;
        break;
    }

    return CustomScaffold(
      isShowAppBar: controller.screenType == 'changePassword' ? true : false,
      backIconWidget: controller.screenType == 'changePassword'
          ? getBackIconWidget(
          themeType: profilelayout!.themeType,
              backIcon: profilelayout!.backIcon,
        size: AppDimen.backIconSize
      )
          : getBackIconWidget(),
      backgroundColor: controller.screenType != 'changePassword' ? onForgotPasswordThemeType == 3 ? appColors.myTripsBGColor : null : null,
      backIcon: Assets.drawableSignupClose,
      isShowBGOnLoader: false,
      controller: controller,
      body: InputDoneView(
          controller,
          toppadding: 20,
          parentWidget: showBodycontent().toPad(bottom: MediaQuery.of(context).viewInsets.bottom + (MediaQuery.of(context).viewInsets.bottom > 0 ? 50 : 0)),

      ),
    ).toAnnotatedRegion(controller: controller);
  }

  Widget showBodycontent() {
    return controller.screenType == 'changePassword' ? [
      _showResetPasswordTitle(),
      [
        if (controller.screenType == 'changePassword')
          _showCurrentPasswordSection(),
        _showNewPasswordSection().toPad(top: 18),
        _showConfirmPasswordSection(),
      ].toColumn(),
      (deviceHeight * (Platform.isIOS ? 0.33 : 0.35))
          .toHeight(),
      _showResetPasswordButton(),
    ].toScroll() : [
      _showResetPasswordTitle(),
      [
      _showNewPasswordSection().toPad(top: 18),
      _showConfirmPasswordSection(),
      ].toColumn(),
      Spacer(),
      _showResetPasswordButton(),
    ].toColumn().toResizeWidget(height: deviceHeight * 0.95).toScroll();
  }

  Widget _showCurrentPasswordSection() {
    return CustomPasswordTextField(
        title: '${label_current.tr} ${label_login_password.tr.toLowerCase()}',
        hintText:
            '${enter_your.tr} ${label_current.tr.toLowerCase()} ${label_login_password.tr.toLowerCase()}',
        controller: controller.currentPasswordController,
        prefixIcon: isShowTextFieldIcon ? Assets.theme4LoginPassword : null,
        focusNode: controller.currentPasswordFocusNode,
        isPasswordVisible: controller.isResetPassword1Visible,
        textInputAction: TextInputAction.next,
        onSubmitted: (value) {
          controller.confirmPasswordFocusNode.nextFocus();
        },
      ).toPad(horizontal: AppDimen.startMargin);
  }

  Widget _showNewPasswordSection() {
    return CustomPasswordTextField(
        title: "${label_new.tr} ${label_login_password.tr.toLowerCase()}",
        hintText: controller.screenType == 'changePassword'
            ? '${enter_your.tr} ${label_new.tr.toLowerCase()} ${label_login_password.tr.toLowerCase()}'
            : "${label_new.tr} ${label_login_password.tr.toLowerCase()}",
        controller: controller.newPasswordController,
        isPasswordVisible: controller.isResetPassword2Visible,
        prefixIcon: isShowTextFieldIcon ? Assets.theme4LoginPassword : null,
        focusNode: controller.newPasswordFocusNode,
        textInputAction: TextInputAction.next,
        onSubmitted: (value) {
          controller.confirmPasswordFocusNode.nextFocus();
        },
      ).toPad(horizontal: AppDimen.startMargin, bottom: textFieldSpacing);
  }

  Widget _showConfirmPasswordSection() {
    return CustomPasswordTextField(
        title:
            "${label_confirm.tr} ${label_new.tr.toLowerCase()} ${label_login_password.tr.toLowerCase()}",
        controller: controller.confirmPasswordController,
        textInputAction: TextInputAction.done,
        isPasswordVisible: controller.isResetPassword3Visible,
        prefixIcon: isShowTextFieldIcon ? Assets.theme4LoginPassword : null,
        focusNode: controller.confirmPasswordFocusNode,
      ).toPad(horizontal: AppDimen.startMargin, bottom: textFieldSpacing);
  }

  Widget _showResetPasswordTitle() {
    if (controller.screenType == 'changePassword') {
      return CustomText(
        text: label_change_your_password.tr,
        fontWeight: AppFont.semiBold,
        size: AppDimen.textSize_22,
      ).toPad(horizontal: AppDimen.startMargin, bottom: 15);
    } else {
      return switch (onForgotPasswordThemeType) {
        1 => Theme1AuthAppbarWidget(
          title: reset_your_password.tr,
          titleWidgets: const [],
        ),
        2 => Theme2AuthAppbarWidget(
          title: reset_your_password.tr,
        ).toPad(horizontal: AppDimen.startMargin),
        3 => Theme3AuthAppbarWidget(
          title: reset_your_password.tr,
        ).toPad(horizontal: AppDimen.startMargin),
        _ => Theme4AuthAppbarWidget(
          title: reset_your_password.tr,
        ),
      };
    }
  }

  Widget _showResetPasswordButton() {
    return Align(
      alignment: AlignmentDirectional.bottomCenter,
      child: controller.screenType == 'changePassword'
          ? CustomBottomItemShadowContainer(
              padding: pad(
                w: AppDimen.startMargin,
                h: AppDimen.startMargin
              ),
              body: PrimaryButton(
                buttonText:
                    "${label_update.tr} ${label_login_password.tr.toLowerCase()}",
                onTap: () {
                  controller.validateCredentials(context);
                },
              ),
            )
          : [
              PrimaryButton(
                buttonText: label_reset.tr,
                onTap: () {
                  controller.validateCredentials(context);
                },
              ),
              onForgotPasswordThemeType == 2
                  ? _showCancel()
                  : const SizedBox.shrink()
            ].toColumn().toPad(
              horizontal: AppDimen.startMargin),
    );
  }

  Widget _showCancel() {
    return Center(
      child: AdaptiveFittedText(
        text: label_cancel.tr,
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