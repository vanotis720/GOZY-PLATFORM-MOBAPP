import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/screens/binding/auth_binding.dart';
import 'package:gozy/screens/binding/profile_binding.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/guest/filter/filter_location.dart';
import 'package:gozy/screens/views/guest/filter/guest_filter.dart';
import 'package:gozy/screens/views/guest/filter/guest_filter_controller.dart';
import 'package:gozy/screens/views/guest/searched/filter_map_listings_page.dart';
import 'package:gozy/screens/views/guest/view_message/view_message.dart';
import 'package:gozy/screens/views/home/home_controller.dart';
import 'package:gozy/screens/views/home_item_detail/home_item_detail.dart';
import 'package:gozy/screens/views/profile/edit_profile/edit_profile.dart';

import '../auth/login/login.dart';
import '../profile/settings/app_settings.dart';

enum HomeScreen {
  getStarted,
  signIn,
  filter,
  filterForListing,
  itemDetail,
  phoneNumber,
  FilterLocation,
  viewMessage,
  FilterMapListings,
  moveToLogin,
  settings,
  profile,
  splash
}

class HomeNavigator {
  void navigateScreen(HomeScreen screen, {BaseController? controller, dynamic param, Function()? fun}) {
    switch (screen) {
      case HomeScreen.signIn:
        if (Get.previousRoute == '/Login')
          Get.back();
        else {
          Get.to(() => Login(), binding: AuthBinding())?.then((value) {
            debugPrint("signin back: $value --- ${Get.currentRoute}");
            if (value != null && value == 'refresh') {
              HomeController controller = Get.find();
              if (controller.isSearchSelected.value) {
                controller.isSearchSelected.value = false;
              }
              controller.isToUpdateExplore.value = true;
              Get.until((route) => route.settings.name == '/guestHomePage');
            }
          });
        }
      case HomeScreen.filter:
        Get.to(
            () => GuestFilterScreen(
                controller: controller != null ? controller as HomeController : Get.find<HomeController>()),
            transition: Transition.downToUp,
            arguments: param);
      case HomeScreen.filterForListing:
        Get.off(
            () => GuestFilterScreen(
                controller: controller != null ? controller as HomeController : Get.find<HomeController>()),
            transition: Transition.downToUp,
            arguments: param);
      case HomeScreen.FilterLocation:
        Get.to(() => FilterLocationScreen(
              filterController: controller != null
                  ? controller as GuestFilterController
                  : Get.find<GuestFilterController>(),
            ));
      case HomeScreen.FilterMapListings:
        Get.to(
          () => FilterMapListingsPage(
            controller: controller != null ? controller as HomeController : Get.find<HomeController>(),
          ),
          arguments: param,
        );
      case HomeScreen.viewMessage:
        Get.to(
          () => ViewMessagePage(),
          arguments: param,
        )?.then((value) {
          if (fun != null) {
            fun();
          }
        });
      case HomeScreen.itemDetail:
        Get.to(
          () => HomeItemDetailView(),
          arguments: param,
        );
      case HomeScreen.moveToLogin:
        Get.off(() => Login(), binding: AuthBinding());
      case HomeScreen.settings:
        Get.to(() => AppSettings(), binding: ProfileBinding());
      case HomeScreen.profile:
        Get.to(() => EditProfilePage(), binding: ProfileBinding());
      default:
    }
  }

  void showDialog() {}

  void clearLoginSession() {}
}