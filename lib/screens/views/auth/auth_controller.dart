import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/app_localizations.dart';
import 'package:gozy/constant.dart' as Constants;
import 'package:gozy/graphql/UserProfile/__generated__/user_profile.req.gql.dart';
import 'package:gozy/screens/views/auth/auth_navigator.dart';
import 'package:gozy/screens/views/splash/splash_navigator.dart';
import 'package:gozy/utils/common_api_controller.dart';

import '../../../app.dart';
import '../../../config/client.dart';
import '../../../widgets/common_extension_functions.dart';
import '../../binding/main_binding.dart';
import '../base_controller.dart';
import '../profile/edit_profile/edit_profile.dart';

class AuthController extends BaseController {
  final authNavigator = Get.find<AuthNavigator>();
  Rx<AnimationStatus> heroAnimationStatus = Rx<AnimationStatus>(AnimationStatus.forward);

  var isRxShowView = ReactiveVariable("isShowView", true);
  int heroFadeDurationInMilliSec = 100;

  void saveUserinfo(var result, String email, [String? verifyEmail, String? confirmCode]) {
    Constants.isShowLoader = false;
    appPreference.accessToken = result?.userToken;
    appPreference.userID = result?.userId;
    appPreference.firstName = result?.user?.firstName;
    appPreference.lastName = result?.user?.lastName;
    appPreference.description = result?.user?.info;
    appPreference.gender = result?.user?.gender;
    appPreference.birthDate = result?.user?.dateOfBirth;
    appPreference.location = result?.user?.location;
    if (result?.user?.appTheme != null && result!.user!.appTheme!.toString().isNotEmpty) {
      appPreference.appTheme = result?.user?.appTheme;
    }
    if (result?.user?.preferredLanguage != null && result!.user!.preferredLanguage!.isNotEmpty) {
      appPreference.preferredLanguage = result?.user?.preferredLanguage;
    } else {
      appPreference.preferredLanguage = appPreference.preferredLanguage ?? Constants.defaultLanguage;
    }
    var isLanguagePresent = false;
    for (var value in LocalizationService.languageModelList) {
      if(value.itemValue == appPreference.preferredLanguage) {
        isLanguagePresent = true;
        break;
      }
    }
    if(!isLanguagePresent) {
      appPreference.preferredLanguage = LocalizationService.languageModelList.first.itemValue;
    }
    if (result?.user?.preferredCurrency != null && result!.user!.preferredCurrency!.toString().isNotEmpty) {
      appPreference.preferredCurrency = result?.user?.preferredCurrency;
    }
    appPreference.profileImage = result?.user?.picture;
    appPreference.phoneNumber = result?.user?.phoneNumber;
    appPreference.countryCode = result?.user?.countryCode;
    appPreference.profileID = result?.user?.profileId ?? 1;
    appPreference.createdListingCount = result?.createListingCount;
    appPreference.email = email;
    resetFerryClient();
    Map<String, bool> map = {};
    map['isPhoneVerified'] = (result?.user?.verification?.isPhoneVerified) ?? false;
    map['isEmailConfirmed'] = (result?.user?.verification?.isEmailConfirmed) ?? false;
    map['isIdVerification'] = (result?.user?.verification?.isIdVerification == 1);
    map['isGoogleConnected'] = (result?.user?.verification?.isGoogleConnected) ?? false;
    appPreference.isUserVerified = map;
    isLoading.value = false;
    getReportTypes();
    changeTheme(isEnableForceUpdate: false);
    bool isUpdateNeeded = false;
    if (!Constants.downloadedLanguages.contains(appPreference.preferredLanguage)) {
      isUpdateNeeded = true;
    }
    LocalizationService.readJson(language: appPreference.preferredLanguage!, isUpdate: isUpdateNeeded)
        .then((value) {
      LocalizationService.changeLocale(languageCode: appPreference.preferredLanguage!);
      changeLanguage();
      if (appPreference.userID != null && appPreference.userID!.isNotEmpty) {
        App().viewMessageSocketListener(appPreference.userID ?? '');
        App().userLogoutSocketListener(appPreference.userID ?? '');
      }
      Future.delayed(const Duration(milliseconds: 350)).then((value) {
        getUnreadCount();
      });
      if (verifyEmail != null && confirmCode != null) {
        Get.to(() => EditProfilePage(),
            binding: MainBinding(),
            arguments: {'email': verifyEmail, 'confirmCode': confirmCode})?.then((value) {
          Get.back(result: 'refresh');
        });
      } else {
        debugPrint("previousroute: ${Get.previousRoute}");
        App().splash.state.navigateScreen(SplashScreen.guestHome, {'isFromauthRefresh': true});
      }
    });
  }

  void saveUserLanguage() {
    String languageCode = appPreference.preferredLanguage ?? Constants.defaultLanguage;
    appPreference.preferredLanguage = languageCode;
    final params = GuserUpdateReq((b) => b
      ..vars.userId = appPreference.userID
      ..vars.fieldName = "preferredLanguage"
      ..vars.fieldValue = languageCode
      ..vars.deviceType = Platform.isAndroid ? 'android' : 'ios'
      ..vars.deviceId = appPreference.deviceID
      ..vars.build());
    FerryLoggerClient.makeRequest(params, this, saveUserLanguage, isViewErrorMessage: false)?.then((res) async {
      isLoading.value = false;
    });
  }
}