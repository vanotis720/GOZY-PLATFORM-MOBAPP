import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:gozy/app.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_colors.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/screens/views/splash/splash_navigator.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/common_extension_functions.dart';

import '../../screens/views/auth/login/login_controller.dart';
import '../common/custom_button/custom_button.dart';

class Theme4AuthAppbarWidget extends StatefulWidget {
  final String title;
  final List<Widget>? titleWidgets;
  final GestureTapCallback? onTap;

  const Theme4AuthAppbarWidget({super.key,required this.title, this.titleWidgets,this.onTap,});

  @override
  State<Theme4AuthAppbarWidget> createState() => _Theme4AuthAppbarWidgetState();
}

class _Theme4AuthAppbarWidgetState extends State<Theme4AuthAppbarWidget> {
  final controller = Get.find<LoginController>();
  @override
  Widget build(BuildContext context) {
    return [
      [
        getBackIconWidget(
            margin: pad(top: AppDimen.startMargin),
          backIcon:  Assets.theme4BackArrow,
          themeType: 4,
            onTap:(){
              if(widget.onTap !=null) {
                widget.onTap!();
              } else {
                Get.back();
              }
            }
        ),

        CancelButton(
          buttonText:label_login_skip.tr,
          height: 34,
          borderRadius: 25,
          horizontalPadding: AppDimen.startMargin,
          borderColor: AppColors.staticwhite,
          isButtonLayout: false,
          fillcolor: AppColors.staticwhite,
          color: AppColors.staticblack,
          isExpand: false,
          onTap: (){
            bool exists = false;

            Get.until((route) {
              if (route.settings.name == '/guestHomePage') {
                debugPrint("previousroute: ${Get.previousRoute} --- ${route.settings.name }");
                exists = true;
                return true;
              }
              return false;
            });

            if(!exists) {
              controller.emailController.text = "";
              controller.passwordController.text = "";
              App().splash.state.navigateScreen(SplashScreen.guestHome, {});
            }
          }
        ).toPad(top: AppDimen.startMargin)
      ].toRow(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween
      ),
      30.toHeight(),
      Assets.drawableGuestTrips.toSVG(
          size: AppDimen.button_height,
          colour: appColors.black
      ),
      12.toHeight(),
      CustomTitleText(text:widget.title, textAlign: TextAlign.center,size: AppDimen.textSize_20,),
      if(widget.titleWidgets!=null)...widget.titleWidgets!,
      AppDimen.startMargin.toHeight(),
    ].toColumn().toPad(horizontal: AppDimen.startMargin).toResizeWidget(color: appColors.theme4AppBarBg);
  }
}