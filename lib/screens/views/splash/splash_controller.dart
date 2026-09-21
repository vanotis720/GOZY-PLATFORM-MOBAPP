import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/graphql/ListDetail/__generated__/ListingDetails.data.gql.dart';
import 'package:gozy/graphql/ListDetail/__generated__/ListingDetails.req.gql.dart';
import 'package:gozy/graphql/__generated__/listing_fragment.req.gql.dart';
import 'package:gozy/screens/binding/profile_binding.dart';
import 'package:gozy/screens/views/home/home_page.dart';
import 'package:gozy/screens/views/home_item_detail/home_item_detail_controller.dart';
import 'package:gozy/screens/views/profile/edit_profile/edit_profile_controller.dart';
import 'package:gozy/screens/views/splash/splash_navigator.dart';
import 'package:gozy/screens/views/static_page/not_found.dart';

import '../../../config/client.dart';
import '../../../graphql/UserProfile/__generated__/user_profile.req.gql.dart';
import '../../../resources/app_lang.dart';
import '../base_controller.dart';

class SplashController extends BaseController {
  SplashNavigator? navigator;
  int? deeplinkListId;
  RxBool isLogoIconVisible = false.obs;
  bool pendingDeeplinkItemDetail = false;
  AnimationController? animcontroller;

  Future<void> confirmEmailVerification({required String email, required String confirmCode}) async {
    getLink();
    final params = GCodeVerificationReq((v) => v
      ..vars.email = email
      ..vars.token = confirmCode
      ..vars.build());
    FerryLoggerClient.makeRequest(params, this, confirmEmailVerification)?.then((res) async {
      Future.delayed(const Duration(seconds: 1)).then((value) {
        EditProfileController.checkEmailVerification();
      });
      isLoading.value = false;
      showToast("${label_login_email.tr} ${label_verified.tr}");
    });
  }

  void gethomeItemDetail() {
    GviewListingDetailsFragmentReq reviewFragmentReq =
        GviewListingDetailsFragmentReq((b) => b..idFields = {'id': deeplinkListId});

    final params = GviewListingDetailsReq((b) => b
      ..vars.listId = deeplinkListId
      ..vars.preview = false
      ..vars.build());
    FerryLoggerClient.makeRequest(params, this, gethomeItemDetail, isToGet400Message: true)?.then((res) {
      GviewListingDetailsData? removeData = res.data as GviewListingDetailsData;
      print("Get.currentroute: ${Get.currentRoute}");
      if (removeData.viewListing?.status == 400) {
        animcontroller?.dispose();
        animcontroller = null;

        bool isBackEnable = Get.currentRoute != '/';
        bool ishomeItemDetailPage = Get.currentRoute == '/HomeItemDetailView';
        print("Get.currentroute: ${isBackEnable} --- ${ishomeItemDetailPage}");
        Get.to(
                () => NotFound(
                      errorMessage: removeData.viewListing?.errorMessage,
                    ),
                binding: ProfileBinding())
            ?.then((_) {
          if (!isBackEnable) {
            if (appPreference.accessToken != null && appPreference.accessToken!.isNotEmpty) {
              resetFerryClient();
              navigator?.navigateScreen(SplashScreen.guestHome, {});
            } else {
              navigator?.navigateScreen(SplashScreen.getStarted, {});
            }
          } else if (ishomeItemDetailPage) {
            HomeItemDetailController homeItemDetailController = Get.find();
            print("Get.currentroute: ${homeItemDetailController.itemInfo.id} --- ${deeplinkListId}");
            if (homeItemDetailController.itemInfo.id == deeplinkListId) {
              Get.offAll(
                () => HomePage(),
              );
            }
          }
        });
      } else {
        debugPrint("homeitemdetail navigation: 2");
        if (Get.isRegistered<HomeItemDetailController>()) {
          HomeItemDetailController homeItemDetailController = Get.find();
          if (homeItemDetailController.itemInfo == null ||
              homeItemDetailController.itemInfo.id != deeplinkListId) {
            navigator?.navigateScreen(SplashScreen.homeItemDetail, {
              'viewListingInfo': FerryLoggerClient.client?.cache.readFragment(reviewFragmentReq),
              'type': 'deeplink'
            });
          }
        } else {
          debugPrint("homeitemdetail navigation:");
          Get.lazyPut<HomeItemDetailController>(() => HomeItemDetailController(), fenix: true);
          navigator?.navigateScreen(SplashScreen.homeItemDetail, {
            'viewListingInfo': FerryLoggerClient.client?.cache.readFragment(reviewFragmentReq),
            'type': 'deeplink'
          });
        }
      }
    });
  }
}