import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:gozy/app.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/screens/views/splash/splash_navigator.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/common_extension_functions.dart';

import '../../screens/views/auth/login/login_controller.dart';

class Theme3AuthAppbarWidget extends StatefulWidget {
  final String title;
  final List<Widget>? titleWidgets;
  final GestureTapCallback? onTap;

  const Theme3AuthAppbarWidget({super.key,required this.title, this.titleWidgets,this.onTap  });

  @override
  State<Theme3AuthAppbarWidget> createState() => _Theme3AuthAppbarWidgetState();
}

class _Theme3AuthAppbarWidgetState extends State<Theme3AuthAppbarWidget> {
  final controller = Get.find<LoginController>();
  @override
  Widget build(BuildContext context) {
    return [
    [
      toOnTap(
        onTap: () {
          Get.back();
        },
        child: getBackIconWidget(
          themeType: 3,
          backIcon: Assets.drawableFilterCalendarArrow,
          borderColor: appColors.white,
          iconBGColor: appColors.white,
          iconColor: appColors.black,
          boxShadow: kElevationToShadow[0],
          margin: pad(a: 0)
        )
      ),
      Spacer(),
      toOnTap(
        onTap: () {
          controller.emailController.text = "";
          controller.passwordController.text = "";
          App().splash.state.navigateScreen(SplashScreen.guestHome, {});
        },
        child: Assets.drawableSignupClose.toSVG(size: 14, colour: appColors.black).toCircle(color: appColors.white,margin:0, padding: 10)
      ),
    ].toRow(
      mainAxisSize: MainAxisSize.max,
    ).toPad(top: AppDimen.startMargin, bottom: 8),
      Assets.drawableGuestTrips.toSVG(
        size: 55,
        colour: appColors.black
      ),
      AppDimen.startMargin.toHeight(),
      CustomTitleText(text:widget.title, textAlign: TextAlign.center,size: AppDimen.textSize_22,fontWeight: AppFont.semiBold),
      if(widget.titleWidgets!=null)...widget.titleWidgets!,
    ].toColumn(
      crossAxisAlignment: CrossAxisAlignment.center,
    );
  }
}