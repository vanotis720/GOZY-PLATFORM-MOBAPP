import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:gozy/app.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/splash/splash_navigator.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_text.dart';

import '../../screens/views/auth/login/login_controller.dart';

class Theme2AuthAppbarWidget extends StatefulWidget {
  final String? title;
  const Theme2AuthAppbarWidget({super.key,this.title});

  @override
  State<Theme2AuthAppbarWidget> createState() => _Theme2AuthAppbarWidgetState();
}

class _Theme2AuthAppbarWidgetState extends State<Theme2AuthAppbarWidget> {
  final controller = Get.find<LoginController>();
  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: [
        [
          Assets.drawableGuestTrips.toSVG(
              size: 75,
              colour: appColors.black
          ),
          CustomText(
            text: label_login_skip.tr,
            size: AppDimen.textSize_16,
            color: appColors.secondaryColor,
            fontWeight: AppFont.regular,
            decorationColor: appColors.secondaryColor,
            onTap: (){
              controller.emailController.text = "";
              controller.passwordController.text = "";
              App().splash.state.navigateScreen(SplashScreen.guestHome, {});
            },
          ),
        ].toRow(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween
        ),
        widget.title != null ? CustomTitleText(text: widget.title ?? '', size: AppDimen.textSize_22, fontWeight: AppFont.semiBold,).toPad(top: 18) : 0.toHeight()
      ].toColumn()
    ).toPad(top:AppDimen.startMargin);
  }
}