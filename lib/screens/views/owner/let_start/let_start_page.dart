import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:gozy/config/client.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_colors.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/owner/owner_property_list/owner_property_list_controller.dart';
import 'package:gozy/screens/views/owner/step_three/step_three_controller.dart';
import 'package:gozy/utils/common_api_controller.dart';
import 'package:gozy/widgets/common/custom_network_image/custom_profile_network_image.dart';
import 'package:gozy/widgets/common/custom_text/custom_resize_text.dart';
import 'package:gozy/widgets/common/custom_text/expandable_collapse_text.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/common/custom_button/custom_button.dart';
import 'package:gozy/widgets/custom_stateful_widget.dart';

import '../../base_controller.dart';
import '../../custom_scaffold.dart';
import '../owner_property_list/owner_property_list_navigator.dart';
import '../step_one/step_one_controller.dart';

class LetStartScreen extends CustomStatefulWidget {
  const LetStartScreen({super.key});

  @override
  _LetStartScreenState createState() => _LetStartScreenState();
}

class _LetStartScreenState extends CustomStatefulWidgetState<LetStartScreen> {
  late OwnerPropertyListController controller;

  late StepOneController stepOneController = Get.find();
  String bottomImage = Assets.theme1LstStartPageTheme1;

  @override
  void initState() {
    controller = Get.find();
    debugPrint('controller.tabController: ${controller.tabController} --${controller.hashCode}');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (countriesData == null) {
        controller.getCountries().then((value) {
          controller.isLoading.value = false;
        });
      }
    });

    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    switch (overALLThemeType) {
      case 1:
        bottomImage =
            controller.isDarkMode() ? Assets.theme1LetsStartPageDarkTheme : Assets.theme1LstStartPageTheme1;
        break;
      case 2:
        bottomImage =
            controller.isDarkMode() ? Assets.theme2LetsStartDarkTheme2 : Assets.theme2LetsStartTheme2;
        break;
      case 3:
        bottomImage =
            controller.isDarkMode() ? Assets.theme3LetsStartDarkTheme3 : Assets.theme3LetsStartTheme3;
        break;
      case 4:
        bottomImage =
            controller.isDarkMode() ? Assets.theme4LetsStartDarkTheme4 : Assets.theme4LetsStartTheme4;
        break;
    }
    return CustomScaffold(
      controller: controller,
      isShowAppBar: true,
      customAppBarFunction: () {
        isShowLoader = false;
        Get.back();
      },
      backIconWidget: getBackIconWidget(
          onTap: () {
            isShowLoader = false;
            Get.back();
          },
      ),
      body: showBodyContent(context),
    );
  }

  Widget showBodyContent(context) {
    return [
      const Spacer(),
      _getProfileView().toPad(horizontal: AppDimen.startMargin),
      18.toHeight(),
      [
        _getWelcomeTextView().toPad(horizontal: AppDimen.startMargin),
        15.toHeight(),
        _getWelcomeTextDescriptionView().toPad(horizontal: AppDimen.startMargin),
        23.toHeight(),
        _getStartButtonView().toPad(horizontal: AppDimen.startMargin),
      ].toColumn(crossAxisAlignment: CrossAxisAlignment.center, mainAxisSize: MainAxisSize.max).toPad(horizontal: AppDimen.startMargin),
      const Spacer(),
      _getBottomImageView(),
    ].toColumn(crossAxisAlignment: CrossAxisAlignment.center, mainAxisSize: MainAxisSize.max);
  }

  Widget _getProfileView() {
    var hostProfileImage = appPreference.profileImage ?? "";
    return CustomProfileNetworkImage(
      paddingForNewCircle: 7,
      isRoundIcon: true,
      imageUrl: hostProfileImage,
      profileImageType: "newcirclesecondary",
      all: 116
    ).toCircle(color: Colors.transparent, padding: 4, margin: 0);
  }

  Widget _getWelcomeTextView() {
    var hostName = appPreference.firstName ?? "";
    return [
      Assets.drawableWelcomeHostIcon
          .toPng(
            width: 24,
            height: 24,
          )
          .toPad(top: 3),
      5.toWidth(),
      ExpandableCollapseText(
        "${label_hi.tr} $hostName!",
        lastTextValue: ' ${hostName.length > 15 ? hostName.substring(hostName.length - 15) : ''}!',
        trimLines: 4,
        fontWeight: AppFont.semiBold,
        textAlign: TextAlign.center,
        size: AppDimen.textSize_22,
      ).toStretch(isExpanded: false)
    ].toRow(crossAxisAlignment: CrossAxisAlignment.start);
  }

  Widget _getWelcomeTextDescriptionView() {
    return CustomResizeText(
      text: label_welcome_description_owner.tr,
      size: AppDimen.textSize_18,
      fontWeight: AppFont.regular,
      textAlign: TextAlign.center,
      maxLines: 3,
    );
  }

  Widget _getStartButtonView() {
    return CancelButton(
        isExpand: false,
        verticalPadding: 10,
        fillcolor: appColors.primaryColor,
        borderColor: appColors.primaryColor,
        buttonText: label_let_start.tr,
        onTap: () {
          Get.delete<StepThreeController>();
          Get.lazyPut<StepThreeController>(() => StepThreeController(), fenix: true);
          bool tabSwitch = false;
          controller.ownerPropertyListNavigator.navigateScreen(OwnerPropertyListScreen.stepOne, param: {
            'isfrom': 'letstart',
            'refresh': (id) {
              if (controller.appPreference.isOwner ?? false) {
                tabSwitch = true;
                if (Get.arguments != null && Get.arguments['whyhostfunction'] != null) {
                  Get.arguments['whyhostfunction']();
                } else {
                  Get.back();
                }
              } else {
                Get.close(2);
              }
              controller.ownerPropertyListNavigator.navigateScreen(OwnerPropertyListScreen.stepFinal,
                  param: {'listid': id, 'isTabSwitch': tabSwitch});
            }
          });
        },
        textColor: AppColors.staticwhite);
  }

  Widget _getBottomImageView() => bottomImage.toSVG();
}