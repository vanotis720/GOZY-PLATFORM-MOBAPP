import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/screens/views/profile/about/about_navigator.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_list_item.dart';

import '../../../../constant.dart';
import '../../../../resources/app_layout.dart';
import '../../../../widgets/custom_stateful_widget.dart';

class AboutYourPage extends CustomStatefulWidget {
  const AboutYourPage({super.key});

  @override
  AboutYourPageState createState() => AboutYourPageState();
}

class AboutYourPageState extends CustomStatefulWidgetState<AboutYourPage> with TickerProviderStateMixin {
  AboutNavigator? aboutNavigator;
  static final AppLayoutModel? _profilelayout = appLayoutMap[AppLayout.profile];
  Map<String, String> _itemIcons = {};
  double iconBorderRadius = 100;
  String? backIcon;

  @override
  void initState() {
    aboutNavigator = AboutNavigator();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _itemIcons = {
      "why_owner": Assets.drawableAboutHost,
      "about": Assets.profileiconsAbout,
      "trust_safety": Assets.theme4TrustAndSafety,
    };

    switch (_profilelayout?.themeType) {
      case 1:
        _itemIcons['about'] = Assets.drawableAbout;
        _itemIcons['trust_safety'] = Assets.theme1Theme1TrustSafety;
        iconBorderRadius = 12;
        break;
      case 2:
        _itemIcons['trust_safety'] = Assets.theme2TrustSafety;
        break;
      case 3:
        _itemIcons = {};
        backIcon = appLayoutMap[AppLayout.profile]?.backIcon;
        break;
    }
    return CustomScaffold(
        controller: basecontroller,
        isShowAppBar: true,
        customAppBarFunction: () {
          onBack();
        },
        isShowBGOnLoader: false,
        loader: LottieLoaders.three_dots_loader,
        backIconWidget:
            getBackIconWidget(themeType: _profilelayout!.themeType, backIcon: _profilelayout!.backIcon),
        body: showBodyContent(context));
  }

  Widget showBodyContent(context) {
    AppLayoutModel? appLayoutModel = (_profilelayout ?? overALLAppLayoutModel);
    return [
      CustomTitleText(
        text: about.tr,
        size: AppDimen.textSize_22,
      ).toPad(horizontal: AppDimen.startMargin),
      15.toHeight(),
      getNavigationBar(
              horizontalpadding: 0,
              title: label_why_owner.tr.toUpperLowerCase(),
              borderRadius: iconBorderRadius,
              onTap: () {
                aboutNavigator?.navigateScreen(AboutScreen.whyHost);
              },
              leadingIcon: _itemIcons['why_owner'],
              applayoutModel: appLayoutModel)
          .toPad(bottom: 4),
      getNavigationBar(
              horizontalpadding: 0,
              title: label_about_us.tr,
              borderRadius: iconBorderRadius,
              onTap: () {
                aboutNavigator?.navigateScreen(AboutScreen.staticPageContent, '1');
              },
              leadingIcon: _itemIcons['about'],
              applayoutModel: appLayoutModel)
          .toPad(bottom: 4),
      getNavigationBar(
        horizontalpadding: 0,
        title: trust_safety.tr,
        borderRadius: iconBorderRadius,
        onTap: () {
          aboutNavigator?.navigateScreen(AboutScreen.staticPageContent, '2');
        },
        leadingIcon: _itemIcons['trust_safety'],
        applayoutModel: appLayoutModel,
        isShowItemDivider: false,
      ),
    ].toColumn(crossAxisAlignment: CrossAxisAlignment.start).toResizeWidget(isDeviceFit: true);
  }
}