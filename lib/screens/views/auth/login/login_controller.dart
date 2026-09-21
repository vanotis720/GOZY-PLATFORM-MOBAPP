import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gozy/config/client.dart';
import 'package:gozy/constant.dart' as Constants;
import 'package:gozy/graphql/UserAuth/__generated__/user_auth.data.gql.dart';
import 'package:gozy/graphql/UserAuth/__generated__/user_auth.req.gql.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/auth/auth_controller.dart';
import 'package:gozy/utils/text_editing_controller.dart';
import 'package:gozy/widgets/common_extension_functions.dart';

import '../../../../app_localizations.dart';

class LoginController extends AuthController {
  CustomTextEditingController emailController = CustomTextEditingController();
  CustomTextEditingController passwordController =
      CustomTextEditingController();
  GoogleSignInAccount? googleSignInAccount;
  String registerType = 'google';
  RxBool isPasswordVisible = true.obs;
  UserCredential? userCredential;
  CustomFocusNode passwordFocusNode = CustomFocusNode();
  CustomFocusNode emailFocusNode = CustomFocusNode();

  void validateCredentials() {
    Map<String, bool> results = {
      error_msg_valid.trParams({'field': error_email_address.tr.toLowerCase()}):
          !isValidEmail(emailController.text),
      error_msg_empty.trParams({
        'field':
            '${label_your.tr.toLowerCase()} ${label_login_password.tr.toLowerCase()}'
      }): passwordController.text.toString().isEmpty,
      error_msg_count_validation.trParams({
        'field':
            '${label_your.tr.capitalizeFirst} ${label_login_password.tr.toLowerCase()}',
        'count': '$passwordCount'
      }): passwordController.text.toString().trim().length < passwordCount,
    };
    bool validate = results.isValidate(controller: this);
    debugPrint("isValidatevalidate:$validate");
    if (validate) {
      checkNetwork(checkLogin, isNeedRetry: false);
    }
  }

  void checkLogin() {
    final params = GLoginReq((b) => b
      ..vars.email = emailController.Ttext
      ..vars.password = passwordController.text.toString()
      ..vars.deviceType = Platform.isAndroid ? 'android' : 'ios'
      ..vars.deviceId = appPreference.deviceID
      ..vars.build());
    FerryLoggerClient.makeRequest(params, this, checkLogin)?.then((res) async {
      GLoginData loginData = res.data as GLoginData;
      Constants.renterServicePlanAIFeatureStatus = loginData.userLogin?.result?.user?.renterServicePlanAIFeatureStatus ?? false;
      Constants.ownerServicePlanAIFeatureStatus = loginData.userLogin?.result?.user?.ownerServicePlanAIFeatureStatus ?? false;
      saveUserinfo(loginData.userLogin?.result, emailController.Ttext,
          Constants.verificationEmail, Constants.confirmationCode);
      appPreference.type = 'email';
      debugPrint("isValidatevalidate:${loginData.userLogin?.result?.userToken}");
      saveUserLanguage();
    });
  }

  void checkSocialLogin() {
    String displayname = '';
    String email = '';
    String? photo = '';
    if(this.googleSignInAccount !=null) {
      displayname = this.googleSignInAccount!.displayName.toString().trim();
      registerType = 'google';
      email = this.googleSignInAccount!.email.toString().trim();
      photo =  this.googleSignInAccount!.photoUrl.toString().trim();
    }else if(userCredential !=null){
      email =  userCredential!.additionalUserInfo?.profile!['email'];
      displayname = userCredential!.user!.displayName ?? '';
      photo =  userCredential!.user!.photoURL ?? null;
      registerType = 'apple';
    }
    GSocialLoginReq params = GSocialLoginReq((b) => b
      ..vars.email = email
      ..vars.firstName =  displayname.split(' ')[0]
      ..vars.lastName =  displayname.contains(' ')?displayname.split(' ')[1] : ""
      ..vars.deviceType = Platform.isAndroid ? 'android': 'ios'
      ..vars.deviceId = appPreference.deviceID
      ..vars.profilePicture = photo
      ..vars.registerType = registerType
      ..vars.build());
    FerryLoggerClient.makeRequest(params,this,checkSocialLogin, isViewLoader: Platform.isIOS ? false : true)?.then((res) async {
      GSocialLoginData loginData = res.data as GSocialLoginData;
      Constants.renterServicePlanAIFeatureStatus = loginData.userSocialLogin?.result?.user?.renterServicePlanAIFeatureStatus ?? false;
      Constants.ownerServicePlanAIFeatureStatus = loginData.userSocialLogin?.result?.user?.ownerServicePlanAIFeatureStatus ?? false;
      saveUserinfo(loginData.userSocialLogin?.result, email,
          Constants.verificationEmail, Constants.confirmationCode);
      saveUserLanguage();
    });

  }
}