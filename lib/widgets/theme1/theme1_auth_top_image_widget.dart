import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/app.dart';
import 'package:gozy/constant.dart' show startMargin, deviceWidth;
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_colors.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/auth/auth_controller.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/screens/views/splash/splash_navigator.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/common/custom_button/custom_button.dart';

import '../../screens/views/auth/login/login_controller.dart';

class Theme1AuthTopImageWidget extends StatefulWidget {
  final bool isShowBackArrow;
  final int flex;
  final GestureTapCallback? onTap;
  const Theme1AuthTopImageWidget({
    super.key,
    required this.isShowBackArrow,
    required this.flex,
    this.onTap,
  });

  @override
  State<Theme1AuthTopImageWidget> createState() => _Theme1AuthTopImageWidgetState();
}

class _Theme1AuthTopImageWidgetState extends State<Theme1AuthTopImageWidget> {
  final controller = Get.find<LoginController>();
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'loginhero',
      flightShuttleBuilder: (
        BuildContext flightContext,
        Animation<double> animation,
        HeroFlightDirection flightDirection,
        BuildContext fromHeroContext,
        BuildContext toHeroContext,
      ) {
        AuthController authController = Get.find();
        authController.heroAnimationStatus.value = animation.status;
        return getHeroWidget();
      },
      child: getHeroWidget(),
    ).toStretch(flex: widget.flex);
  }

  Material getHeroWidget() {
    return Material(
      color: widget.isShowBackArrow ? appColors.profile_bg : appColors.white,
      child: [
        ClipRect(
          child: Assets.theme1GetStarted.toPng(
              fit: BoxFit.cover,
              width: deviceWidth,
              imageAlignment: Alignment.bottomCenter),
        ),
        if (widget.isShowBackArrow) getBackArrowWidget(onTap: widget.onTap, iconPadding: 10).toPad(top: 10),
        CancelButton(
                buttonText: label_login_skip.tr,
                height: 35,
                borderRadius: 25,
                horizontalPadding: AppDimen.startMargin,
                boxShadow: getBoxShadow(shadowColor: Colors.black12),
                isButtonLayout: false,
                textSize: AppDimen.textSize_14,
                fillcolor: AppColors.skipBgColor,
                color: AppColors.staticwhite,
                isExpand: false,
                onTap: () {
                  debugPrint("route.name:---${Get.routeTree}");
                  controller.emailController.text = "";
                  controller.passwordController.text = "";
                  App().splash.state.navigateScreen(SplashScreen.guestHome, {});
                })
            .toPad(end: AppDimen.startMargin, top: AppDimen.startMargin + 5)
            .toPositionedAlign(alignment: AlignmentDirectional.topEnd),
      ].toStack(),
    );
  }
}