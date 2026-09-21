import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:gozy/config/client.dart';
import 'package:gozy/graphql/UserAuth/__generated__/user_auth.data.gql.dart';
import 'package:gozy/graphql/UserAuth/__generated__/user_auth.req.gql.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/auth/auth_controller.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/utils/text_editing_controller.dart';
import 'package:gozy/widgets/common_extension_functions.dart';

import '../../../../constant.dart';

class SignupController extends AuthController {
  CustomTextEditingController firstnameController = CustomTextEditingController();
  CustomTextEditingController lastnameController = CustomTextEditingController();
  CustomTextEditingController emailController = CustomTextEditingController();
  CustomTextEditingController passwordController = CustomTextEditingController();
  CustomTextEditingController dobController = CustomTextEditingController();
  CustomFocusNode lastnameFocusNode = CustomFocusNode();
  CustomFocusNode firstnameFocusNode = CustomFocusNode();
  CustomFocusNode emailFocusNode = CustomFocusNode();
  CustomFocusNode passwordFocusNode = CustomFocusNode();
  var isPasswordVisible = true.obs;
  var isTermAndPolicySelected = ReactiveVariable('isTermAndPolicySelected', false);
  DateTime? initialDate;
  RxInt choosedsignupIndex = 0.obs;

  bool validateCredentials({required String type}) {
    debugPrint("validateCredentials:  -- $type");
    Map<String, bool> namevalidationMap = (type.isEmpty || type == 'name')
        ? {
            error_msg_empty.trParams(
                    {'field': '${label_your.tr.toLowerCase()} ${label_first_name.tr.toLowerCase()}'}):
                firstnameController.text.toString().trim().isEmpty,
            error_msg_empty.trParams(
                    {'field': '${label_your.tr.toLowerCase()} ${label_last_name.tr.toLowerCase()}'}):
                lastnameController.text.toString().trim().isEmpty,
          }
        : {};
    Map<String, bool> emailvalidationMap = (type.isEmpty || type == 'email')
        ? {
            error_msg_valid.trParams({'field': error_email_address.tr.toLowerCase()}):
                !(isValidEmail(emailController.text)),
            error_msg_empty.trParams(
                    {'field': '${label_your.tr.toLowerCase()} ${label_login_password.tr.toLowerCase()}'}):
                passwordController.text.toString().isEmpty,
            error_msg_count_validation.trParams({
              'field': '${label_your.tr.capitalizeFirst} ${label_login_password.tr.toLowerCase()}',
              'count': '$passwordCount'
            }): passwordController.text.toString().trim().length < passwordCount,
          }
        : {};

    Map<String, bool> dobvalidationMap = (type.isEmpty || type == 'dob')
        ? {
            error_msg_dob.tr: dobController.text.toString().trim().isEmpty,
            error_terms_and_privacy_acknowledge.tr: !isTermAndPolicySelected.value,
          }
        : {};

    bool validate =
        {...namevalidationMap, ...emailvalidationMap, ...dobvalidationMap}.isValidate(controller: this);

    if (validate && type.isEmpty) {
      checkNetwork(checkSignup);
    }
    return validate;
  }

  void checkSignup() {
    final params = GSignupReq((b) => b
      ..vars.email = emailController.Ttext
      ..vars.password = passwordController.text.toString()
      ..vars.deviceType = Platform.isAndroid ? 'android' : 'ios'
      ..vars.deviceId = appPreference.deviceID
      ..vars.firstName = firstnameController.initalCapitalText
      ..vars.lastName = lastnameController.initalCapitalText
      ..vars.dateOfBirth = initialDate?.convert_MDY(format: dobAPIFormat).$1
      ..vars.build());
    FerryLoggerClient.makeRequest(params, this, checkSignup, isStartLoader: false)?.then((res) async {
      GSignupData loginData = res.data as GSignupData;
      ownerServicePlanAIFeatureStatus = loginData.createUser?.result?.user?.ownerServicePlanAIFeatureStatus ?? false;
      renterServicePlanAIFeatureStatus = loginData.createUser?.result?.user?.renterServicePlanAIFeatureStatus ?? false;
      appPreference.type = "email";
      Get.close(1);
      saveUserinfo(loginData.createUser?.result, emailController.Ttext);
      saveUserLanguage();
    });
  }

}