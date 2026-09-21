import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/app.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/resources/app_colors.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/resources/app_layout.dart';
import 'package:gozy/screens/views/auth/auth_navigator.dart';
import 'package:gozy/screens/views/auth/login/login_controller.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/screens/views/splash/splash_navigator.dart';
import 'package:gozy/utils/google_signin_setup.dart';
import 'package:gozy/widgets/common/custom_button/primary_button.dart';
import 'package:gozy/widgets/common/custom_container/custom_border_container.dart';
import 'package:gozy/widgets/common/custom_container/custom_counter_container.dart';
import 'package:gozy/widgets/common/custom_text/adaptive_fitted_text.dart';
import 'package:gozy/widgets/common/custom_textfield/custom_password_textfield.dart';
import 'package:gozy/widgets/common/custom_textfield/custom_prefix_textfield.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/common/custom_button/custom_button.dart';
import 'package:gozy/widgets/custom_container_extensions.dart';
import 'package:gozy/widgets/custom_stateful_widget.dart';
import 'package:gozy/widgets/custom_text.dart';
import 'package:gozy/widgets/show_done_view.dart';
import 'package:gozy/widgets/theme1/theme1_auth_appbar_widget.dart';
import 'package:gozy/widgets/theme2/theme2_auth_appbar_widget.dart';
import 'package:gozy/widgets/theme3/theme3_auth_appbar_widget.dart';
import 'package:gozy/widgets/theme4/custom_dash_divider.dart';
import 'package:gozy/widgets/theme4/theme4_auth_appbar_widget.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../generated/assets.dart';

class Login extends CustomStatefulWidget {
  const Login({super.key});

  @override
  _LoginStatefulWrapperState createState() => _LoginStatefulWrapperState();
}

class _LoginStatefulWrapperState extends CustomStatefulWidgetState<Login> {
  final controller = Get.find<LoginController>();
  static int? _onLoginThemeType = appLayoutMap[AppLayout.loginPage]?.themeType;
  final bool _isTheme1 = (appLayoutMap[AppLayout.onBoardPage]?.themeType == 1 && _onLoginThemeType == 1);
  double _socialLoginBorderRadius = 100;
  bool isHideSocialLoginText = false;

  @override
  void initState() {
    GoogleSigninSetup.init();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.change(rxVariable: controller.isRxShowView, value: !_isTheme1);
      if (!controller.isRxShowView.value) {
        Future.delayed(Duration(milliseconds: controller.heroFadeDurationInMilliSec)).then((value) {
          controller.change(rxVariable: controller.isRxShowView, value: true);
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch (_onLoginThemeType) {
      case 2:
        _socialLoginBorderRadius = 0;
        isHideSocialLoginText = true;
        break;
    }
    return CustomScaffold(
      controller: controller,
      backgroundColor: _onLoginThemeType == 3 ? appColors.myTripsBGColor : null,
      customAppBarFunction: () {
        backfunction();
      },
      resizeToAvoidBottomInset: false,
      body: InputDoneView(
        controller,
        toppadding: 20,
        parentWidget: switch (_onLoginThemeType) {
          1 => showTheme1Bodycontent(),
          2 => showTheme2Bodycontent(),
          3 => showTheme3Bodycontent(),
          4 => showTheme4Bodycontent(),
          _ => const SizedBox.shrink(),
        }
            .toPad(bottom: MediaQuery.of(context).viewInsets.bottom),
      ),
    );
  }

  Widget showTheme1Bodycontent() {
    return [
      Theme1AuthAppbarWidget(
        title: label_login_with.tr,
        onTap: () {
          backfunction();
        },
        titleWidgets: [
          if (Platform.isIOS)
            [
              _showSocialLogin(Assets.drawableGoogleLogo),
              18.toWidth(),
              _showSocialLogin(Assets.drawableAppleLogo),
            ].toRow(),
          if (Platform.isAndroid) _showSocialLogin(Assets.drawableGoogleLogo),
        ],
      ),
      GetBuilder(
          init: controller,
          id: controller.isRxShowView.id,
          builder: (context) {
            return AnimatedOpacity(
              opacity: controller.isRxShowView.value ? 1.0 : 0.0,
              duration: Duration(milliseconds: controller.heroFadeDurationInMilliSec),
              child: [
                AppDimen.startMargin.toHeight(),
                _showEmailSection(),
                _showPasswordSection(),
                _showForgotPassword(),
                PrimaryButton(
                  buttonText: btn_label_login.tr,
                  onTap: () {
                    controller.validateCredentials();
                  },
                ).toPad(top: AppDimen.startMargin, bottom: AppDimen.startMargin),
                _showSignupWidget(),
              ].toColumn().toPad(horizontal: AppDimen.startMargin, bottom: AppDimen.startMargin),
            ).toStretch(flex: 6);
          }),
    ].toColumn().toResizeWidget(height: deviceHeight, width: deviceWidth).toScroll();
  }

  Widget showTheme2Bodycontent() {
    return [
      Theme2AuthAppbarWidget(
        title: '${label_login_welcome.tr} $APP_NAME',
      ).toPad(bottom: 12),
      CustomText(
        text: label_get_started_description.tr,
        size: AppDimen.textSize_16,
        fontWeight: AppFont.regular,
      ),
      AppDimen.startMargin.toHeight(),
      _showEmailSection(),
      _showPasswordSection(),
      _showForgotPassword(),
      PrimaryButton(
        buttonText: btn_label_login.tr,
        onTap: () {
          controller.validateCredentials();
        },
      ).toPad(top: AppDimen.startMargin, bottom: AppDimen.startMargin),
      [
        _showDivider(),
        5.toWidth(),
        CustomText(
          text: label_continue_with.tr,
          size: AppDimen.textSize_14,
        ),
        5.toWidth(),
        _showDivider(),
      ].toRow(),
      AppDimen.startMargin.toHeight(),
      if (Platform.isIOS)
        [
          _showSocialLogin(Assets.drawableGoogleLogo),
          20.toWidth(),
          _showSocialLogin(Assets.drawableAppleLogo),
        ].toRow(),
      if (Platform.isAndroid) _showSocialLogin(Assets.drawableGoogleLogo),
      AppDimen.startMargin.toHeight(),
      _showSignupWidget(),
    ].toScroll(padding: pad(w: 30, bottom: 20), shrinkWrap: false);
  }

  Widget showTheme3Bodycontent() {
    return [
      Theme3AuthAppbarWidget(
        title: btn_label_login.tr,
        onTap: () {
          controller.emailController.text = "";
          controller.passwordController.text = "";
          App().splash.state.navigateScreen(SplashScreen.guestHome, {});
        },
        titleWidgets: [
          24.toHeight(),
          _showFullWidthSocialLogin(Assets.drawableGoogleLogo,
              borderColor: appColors.black, btnText: 'Google'),
          if (Platform.isIOS) ...[
            18.toHeight(),
            _showFullWidthSocialLogin(Assets.drawableAppleLogo,
                borderColor: appColors.black, btnText: 'Apple'),
          ]
        ],
      ),
      AppDimen.startMargin.toHeight(),
      _showEmailSection(),
      _showPasswordSection(),
      _showForgotPassword(),
      PrimaryButton(
        buttonText: btn_label_login.tr,
        buttonTextFontSize: AppDimen.textSize_18,
        shadowOpacity: 0.0,
        onTap: () {
          controller.validateCredentials();
        },
      ).toPad(top: AppDimen.startMargin, bottom: AppDimen.startMargin),
      _showSignupWidget(),
    ].toScroll(padding: pad(w: AppDimen.startMargin, bottom: 20), shrinkWrap: false);
  }

  Widget showTheme4Bodycontent() {
    return [
      Theme4AuthAppbarWidget(title: label_login_your_account.tr,),
      topCornerClipContainer(
        borderWidth: 0.1,
        child: [
          AppDimen.startMargin.toHeight(),
          _showEmailSection(),
          _showPasswordSection(),
          _showForgotPassword(alignment: AlignmentDirectional.centerEnd),
          PrimaryButton(
            buttonText: btn_label_login.tr,
            buttonTextFontSize: AppDimen.textSize_18,
            shadowOpacity: 0.0,
            onTap: () {
              controller.validateCredentials();
            },
          ).toPad(top: AppDimen.startMargin, bottom: 14),
          [
            CustomDashDivider(),
            5.toWidth(),
            CustomText(
              text: label_continue_with.tr,
              size: AppDimen.textSize_12,
            ),
            5.toWidth(),
            CustomDashDivider(),
          ].toRow().toPad(bottom: 14),
          _showFullWidthSocialLogin(
            Assets.drawableGoogleLogo,
            borderColor: appColors.myTripsBGColor,
            btnText: 'Google',
            fillcolor: appColors.myTripsBGColor,
            trailWidget: CustomCounterContainer(
                borderColor: AppColors.staticwhite,
                margin: pad(end: 10),
                height: 34,
                width: 34,
                color: AppColors.staticwhite,
                body: Assets.drawableGoogleLogo.toSVG().toPad(all: 6)),
          ),
          if (Platform.isIOS) 18.toHeight(),
          if (Platform.isIOS)
            _showFullWidthSocialLogin(
              Assets.drawableAppleLogo,
              borderColor: appColors.myTripsBGColor,
              btnText: 'Apple',
              fillcolor: appColors.myTripsBGColor,
              trailWidget: CustomCounterContainer(
                  borderColor: AppColors.staticwhite,
                  margin: pad(end: 10),
                  height: 34,
                  width: 34,
                  color: AppColors.staticwhite,
                  body: Assets.drawableAppleLogo.toSVG().toPad(all: 6)),
            ),
          AppDimen.startMargin.toHeight(),
          _showSignupWidget(),
        ].toColumn(),
      )
    ].toScroll(padding: pad(bottom: 20), shrinkWrap: false);
  }

  Widget _showEmailSection() {
    debugPrint("_isShowPreFixIcon: $isShowTextFieldIcon");
    return CustomPrefixTextField(
      title: label_login_email.tr,
      prefixIcon: isShowTextFieldIcon ? Assets.theme4LoginEmail : null,
      controller: controller.emailController,
      focusNode: controller.emailFocusNode,
      onTap: () {
        controller.hideSnackBar();
      },
      hintText: error_email_address.tr.capitalizeFirst,
      keyboardType: TextInputType.emailAddress,
      onSubmitted: (value) {
        controller.passwordFocusNode.requestFocus();
      },
      textInputAction: TextInputAction.next,
    );
  }

  Widget _showPasswordSection() {
    debugPrint("controller.isPasswordVisible: ${controller.isPasswordVisible.value}");
    return CustomPasswordTextField(
          title: label_login_password.tr,
          controller: controller.passwordController,
          focusNode: controller.passwordFocusNode,
          isPasswordVisible: controller.isPasswordVisible,
          onTap: () {
            controller.hideSnackBar();
          },
          prefixIcon: isShowTextFieldIcon ? Assets.theme4LoginPassword : null,
          textInputAction: TextInputAction.done,
        ).toPad(top: 16, bottom: 8);
  }

  Widget _showForgotPassword({AlignmentGeometry? alignment}) {
    return Align(
      alignment: alignment ?? AlignmentDirectional.centerStart,
      child: AdaptiveFittedText(
        text: label_forget_password.tr,
        size: AppDimen.textSize_16,
        fontWeight: AppFont.regular,
        color: appColors.secondaryColor,
        onTap: () {
          controller.emailController.text = "";
          controller.passwordController.text = "";
          FocusManager.instance.primaryFocus!.unfocus();
          controller.authNavigator.navigateScreen(AuthScreen.forgetPassword, '');
        },
      ),
    );
  }

  Widget _showDivider() {
    return Divider(
      color: appColors.customTextColor,
      thickness: 1.2,
    ).toResizeWidget(width: 30);
  }

  Widget _showSocialLogin(String logoSvg) {
    return Center(
      child: CustomBorderContainer(
          borderRadius: _socialLoginBorderRadius,
          height: 50,
          width: 50,
          padding: pad(a: 12),
          borderColor: controller.isDarkMode() ? Colors.white : appColors.filterDividerColor,
          borderWidth: 1,
          onTap: () async {
            _getSocialLogin(logoSvg);
          },
          body: _showSocialLoginLogo(logoSvg),
      ),
    );
  }

  void backfunction() {
    debugPrint("loginpage_isTheme1: $_isTheme1");
    if (_isTheme1) {
      controller.emailController.text = "";
      controller.passwordController.text = "";
      controller.change(rxVariable: controller.isRxShowView, value: false);
      Future.delayed(Duration(milliseconds: controller.heroFadeDurationInMilliSec)).then((value) {
        Get.back();
      });
    } else {
      Get.back();
    }
  }

  Widget _showSignupWidget() {
    Map<String, GestureTapCallback> searchTextWithLinks = {};
    searchTextWithLinks[label_signup.tr] = () {
      debugPrint("getpreviousroute: ${Get.previousRoute}");
      if (Get.previousRoute != '/Signup') {
        controller.emailController.text = "";
        controller.passwordController.text = "";
        App().splash.state.navigateScreen(SplashScreen.signup, {});
      } else {
        Get.back();
      }
    };
    return Center(
      child: RichText(
        text: TextSpan(
          children: getTextSpans(
              searchTextWithLinks: searchTextWithLinks,
              primaryText: '${label_did_not_have_account.tr} ${label_signup.tr}'),
          style: TextStyle(
            fontFamily: AppFont.font,
            color: appColors.black,
            fontSize: AppDimen.textSize_16,
            fontWeight: AppFont.regular,
          ),
        ),
      ),
    );
  }

  Widget _showFullWidthSocialLogin(String socialLoginLogo,
      {Color? fillcolor, Color? textColor, Color? borderColor, String? btnText, Widget? trailWidget}) {
    return CancelButton(
      buttonText: btnText ?? btn_label_login.tr,
      textSize: AppDimen.textSize_18,
      color: textColor ?? appColors.textColor,
      topPadding: trailWidget != null ? 4 : 8,
      isButtonLayout: false,
      trailingWidget: trailWidget ?? _showSocialLoginLogo(socialLoginLogo).toPad(end: 10),
      bottomPadding: trailWidget != null ? 6 : 10,
      fillcolor: fillcolor ?? Colors.transparent,
      borderColor: borderColor ?? appColors.customBorderColor,
      onTap: () {
        _getSocialLogin(socialLoginLogo);
      },
    );
  }

  Widget _showSocialLoginLogo(String socialLoginLogo) {
    return socialLoginLogo.toSVG(
        size: 20, colour: socialLoginLogo == Assets.drawableAppleLogo ? appColors.black : null);
  }

  void _getSocialLogin(String logoSvg) async {
    controller.hideKeyBoard();
    try {
      if (logoSvg == Assets.drawableGoogleLogo) {
        controller.googleSignInAccount = await GoogleSigninSetup.signin();
        if (controller.googleSignInAccount != null) {
          controller.checkNetwork(controller.checkSocialLogin);
        }
      } else {
        final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
        SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
          webAuthenticationOptions: WebAuthenticationOptions(
            clientId: IOS_PACKAGE_NAME,
            redirectUri: Uri.parse(
              'https://${FIREBASE_PROJECT_ID}.firebaseapp.com/__/auth/handler',
            ),
          ),
        ).then((value) {
          debugPrint("apple login: ${value.email} --- ${value.givenName} --- ${value.familyName} --- ${value.userIdentifier}");
          OAuthProvider authProvider = OAuthProvider('apple.com');
          if (value.givenName != null) {
            Map<String, String> map = {};
            map["name"] = '${value.givenName} ${value.familyName}';
            authProvider.setCustomParameters(map);
          }

          final oauthCredential = authProvider.credential(
            idToken: value.identityToken,
            secret: value.authorizationCode,
            rawNonce: '${value.givenName} ${value.familyName}',
            accessToken: value.authorizationCode,
          );

          firebaseAuth
              .signInWithCredential(oauthCredential)
              .then((authvalue) {
            debugPrint("Firebase login: ${authvalue.user}");
            if (value.givenName != null) {
              firebaseAuth.currentUser!
                  .updateDisplayName('${value.givenName} ${value.familyName}')
                  .then((value) {
                controller.googleSignInAccount = null;
                controller.userCredential = authvalue;
                controller.checkNetwork(controller.checkSocialLogin);
              });
            } else {
              controller.googleSignInAccount = null;
              controller.userCredential = authvalue;
              controller.checkNetwork(controller.checkSocialLogin);
            }
          });
        });
      }
    } catch (error) {
      print("errorsignin: ${error}");
    }
  }
}