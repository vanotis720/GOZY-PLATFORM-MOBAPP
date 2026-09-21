import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:gozy/config/client.dart';
import 'package:gozy/graphql/UserAuth/__generated__/user_auth.req.gql.dart';
import 'package:gozy/graphql/changepassword/__generated__/changepassword.req.gql.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/binding/auth_binding.dart';
import 'package:gozy/screens/views/auth/auth_controller.dart';
import 'package:gozy/utils/text_editing_controller.dart';
import 'package:gozy/widgets/common_extension_functions.dart';

import '../login/login.dart';



class ResetPasswordController extends AuthController {
  CustomTextEditingController currentPasswordController = CustomTextEditingController();
  CustomTextEditingController newPasswordController = CustomTextEditingController();
  CustomTextEditingController confirmPasswordController = CustomTextEditingController();
  CustomFocusNode confirmPasswordFocusNode = CustomFocusNode();
  CustomFocusNode currentPasswordFocusNode = CustomFocusNode();
  CustomFocusNode newPasswordFocusNode = CustomFocusNode();
  var isResetPassword1Visible = true.obs;
  var isResetPassword2Visible = true.obs;
  var isResetPassword3Visible = true.obs;
  Map<String,dynamic> ResetPwdTokenParams = {};
  String screenType = 'resetPassword';

  void validateCredentials(BuildContext context) {
    Map<String,bool> results =  {
      error_msg_empty.trParams({'field':'${label_your.tr.toLowerCase()} ${label_new.tr} ${label_login_password.tr}'.toLowerCase()}) : newPasswordController.text.toString().trim().isEmpty,
      error_msg_count_validation.trParams({'field':'${label_new.tr} ${label_login_password.tr}'.toLowerCase(), 'count': '$passwordCount'}) : newPasswordController.text.toString().trim().length< passwordCount,
      error_msg_empty.trParams({'field':'${label_your.tr.toLowerCase()} ${label_confirm.tr} ${label_login_password.tr}'.toLowerCase()}):  (confirmPasswordController.text.toString().trim().isEmpty),
      error_msg_count_validation.trParams({'field':'${label_confirm.tr} ${label_login_password.tr}'.toLowerCase(), 'count': '$passwordCount'}) : confirmPasswordController.text.toString().trim().length< passwordCount,
      error_mismatch_password_reset_password_page.tr : confirmPasswordController.text.toString().trim() != newPasswordController.text.toString().trim(),
    };
    if(screenType != 'resetPassword'){
      results = {}..addAll({ error_msg_empty.trParams({'field':'${label_your.tr.toLowerCase()} ${label_current.tr} ${label_login_password.tr}'.toLowerCase()}) : currentPasswordController.text.toString().trim().isEmpty})
        ..addAll(results);
    }


    bool validate = results.isValidate(controller: this);
    debugPrint("isValidatevalidate:$validate");
   if(validate) {
     if(screenType == "changePassword"){
       checkNetwork(changePassword);
     }
     else {
       checkNetwork(resetPassword);
     }
   }
  }

  void resetPassword() {
    final params = GResetPasswordReq((b) => b
      ..vars.email = ResetPwdTokenParams['email'].toString().trim()
      ..vars.token = ResetPwdTokenParams['token'].toString()
      ..vars.password = newPasswordController.text.toString()
      ..vars.build());
    FerryLoggerClient.makeRequest(params,this,resetPassword,isRemoveHeader: true, isDisableNavigation: false)?.then((res) async {
      isLoading.value = false;
      showSnackBar(success_reset_password_msg.tr, isltralign: true);
      Future.delayed(const Duration(milliseconds: 1000)).then((value) {
      Get.back();
      Future.delayed(const Duration(milliseconds: 10)).then((value) {
        Get.to(() => Login(), binding: AuthBinding(), routeName: "/login");
      });
    });
    });

  }

  void changePassword() {
    String oldPassword = currentPasswordController.text.toString();
    final params = GchangePasswordReq((b) => b
      ..vars.oldPassword = oldPassword
      ..vars.newPassword = newPasswordController.text.toString()
      ..vars.confirmPassword  = confirmPasswordController.text.toString()
      ..vars.build());
    FerryLoggerClient.makeRequest(params,this,changePassword)?.then((res) async {
      isLoading.value = false;
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
      Future.delayed(const Duration(milliseconds: 1000)).then((value) {
        Get.back();
      });
      showSnackBar(update_success.trParams({'field':label_login_password.tr}));
    });

  }


}