import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/config/client.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/binding/main_binding.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/screens/views/home/home_controller.dart';
import 'package:gozy/screens/views/home/home_page.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/common_extension_functions.dart';

import '../../../widgets/custom_stateful_widget.dart';
import '../guest/filter/guest_filter_controller.dart';

class UserRoleChangePage extends CustomStatefulWidget {
  const UserRoleChangePage({super.key});

  @override
  UserRoleChangePageState createState() => UserRoleChangePageState();
}

class UserRoleChangePageState extends CustomStatefulWidgetState<UserRoleChangePage>
    with TickerProviderStateMixin {
  HomeController get controller => Get.find<HomeController>();
  GuestFilterController filterController = Get.find();

  @override
  void initState() {
    controller.resetFerryClient(isCacheClear: false);
    Future.delayed(const Duration(milliseconds: 3000)).then((value) {
      filterController.locationNameController.text = "";
      filterController.locationList.clear();
      filterController.change(rxVariable: filterController.rxSelectedLocation, value: '');
      filterController.update();
      filterController.clearFilters();
      MainBinding mainBinding = MainBinding();
      if (Get.arguments != null && Get.arguments['selectedTab'] != null) {
        Get.to(() => HomePage(), arguments: Get.arguments, binding: mainBinding, routeName: "/guestHomePage");
      } else {
        // mainBinding.clearOwnerPropertyListData();
        Get.until((route) {
          print("Setting name--> ${route.settings.name}");
          return route.settings.name == '/guestHomePage';
        });
        controller.clearExploreData();
        Get.forceAppUpdate();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      controller: controller,
      isShowAppBar: false,
      customAppBarFunction: () {},
      body: showBodyContent(context),
    );
  }

  Widget showBodyContent(context) {
    return [
      Assets.drawableSwitchHost.toPng(),
      30.toHeight(),
      CustomTitleText(
          text: appPreference.isOwner! ? switch_to_hosting.tr : switch_to_renter.tr,
          size: AppDimen.textSize_24)
    ]
        .toColumn(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center)
        .toResizeWidget(isDeviceFit: true);
  }
}