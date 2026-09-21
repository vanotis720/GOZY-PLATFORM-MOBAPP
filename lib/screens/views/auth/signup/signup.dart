import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/app.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/widgets/common/custom_container/custom_border_container.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/resources/app_layout.dart';
import 'package:gozy/screens/views/auth/auth_navigator.dart';
import 'package:gozy/screens/views/auth/signup/signup_controller.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/screens/views/splash/splash_navigator.dart';
import 'package:gozy/widgets/common/custom_button/primary_button.dart';
import 'package:gozy/widgets/common/custom_textfield/custom_password_textfield.dart';
import 'package:gozy/widgets/common/custom_textfield/custom_prefix_textfield.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_stateful_widget.dart';
import 'package:gozy/widgets/custom_text.dart';
import 'package:gozy/widgets/theme1/theme1_auth_appbar_widget.dart';
import 'package:gozy/widgets/theme2/theme2_auth_appbar_widget.dart';
import 'package:gozy/widgets/theme3/theme3_auth_appbar_widget.dart';
import 'package:gozy/widgets/theme4/theme4_auth_appbar_widget.dart';

import '../../../../widgets/show_done_view.dart';

class Signup extends CustomStatefulWidget {
  const Signup({super.key});

  @override
  _SignupStatefulWrapperState createState() => _SignupStatefulWrapperState();
}

class _SignupStatefulWrapperState extends CustomStatefulWidgetState<Signup> with TickerProviderStateMixin {
  final controller = Get.find<SignupController>();
  static int? _onLoginThemeType = appLayoutMap[AppLayout.loginPage]?.themeType;
  final bool _isTheme1 = (appLayoutMap[AppLayout.onBoardPage]?.themeType == 1 && _onLoginThemeType == 1);
  List<Map<String, dynamic>> theme4_signup_layout_items = [];
  List<int> signupPages = [];
  Widget? _cachedTheme4Body;

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cachedTheme4Body = null;
      appThemeChanged.refresh();
    });
  }

  @override
  void initState() {
    super.initState();
    ever(appThemeChanged, (_) {
      _cachedTheme4Body = null;
    });
    controller.change(rxVariable: controller.isRxShowView, value: !_isTheme1);
    controller.choosedsignupIndex.value = 0;
    if (!controller.isRxShowView.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(Duration(milliseconds: controller.heroFadeDurationInMilliSec)).then((value) {
          controller.change(rxVariable: controller.isRxShowView, value: true);
        });
      });
    }
    signupPages.add(0);
    controller.hideKeyBoard();
    controller.firstnameController.text = "";
    controller.lastnameController.text = "";
    controller.passwordController.text = "";
    controller.emailController.text = "";
    controller.dobController.text = "";
    controller.initialDate = null;
    _addItemsToSignupLayouts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.change(rxVariable: controller.isTermAndPolicySelected, value: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        controller: controller,
        isShowAppBar: false,
        backgroundColor: _onLoginThemeType == 3 ? appColors.myTripsBGColor : null,
        customAppBarFunction: () {
          customBackFunction();
        },
        resizeToAvoidBottomInset: false,
        body: InputDoneView(controller, toppadding: 20, parentWidget: Obx(() {
          appThemeChanged.value;
          return (((_onLoginThemeType == 1 || _onLoginThemeType == 2 || _onLoginThemeType == 3)
                  ? showTheme123BodyContent(themeType: _onLoginThemeType)
                  : _onLoginThemeType == 4
                      ? _showTheme4Bodycontent()
                      : 0.toHeight())
              .toPad(bottom: MediaQuery.of(context).viewInsets.bottom));
        }),
        ),
    );
  }

  Widget showTheme123BodyContent({int? themeType}) {
    return [
      switch (themeType) {
        1 => Theme1AuthAppbarWidget(
            title: label_create_your_account.tr,
            titleWidgets: const [],
            onTap: customBackFunction,
          ),
        2 => Theme2AuthAppbarWidget(
            title: label_create_your_account.tr,
          ).toPad(horizontal: AppDimen.startMargin),
        3 => Theme3AuthAppbarWidget(
            title: label_signup.tr,
          ).toPad(horizontal: AppDimen.startMargin),
        _ => 0.toHeight(),
      },
      AppDimen.startMargin.toHeight(),
      GetBuilder(
          id: controller.isRxShowView.id,
          init: controller,
          builder: (context) {
            return AnimatedOpacity(
                opacity: controller.isRxShowView.value ? 1.0 : 0.0,
                duration: Duration(milliseconds: controller.heroFadeDurationInMilliSec),
                child: [
                  _showFirstnameSection(),
                  _showLastnameSection(),
                  _showEmailSection(),
                  _showPasswordSection(),
                  _showDOBSection(),
                  _showSignupContent(),
                  AppDimen.startMargin.toHeight(),
                  _showSignupButton(),
                ].toScroll(padding: pad(w: AppDimen.startMargin)));
          }).toStretch(flex: 6),
    ].toColumn();
  }

  Widget _showTheme4Bodycontent() {
    if (_cachedTheme4Body == null) {
      _addItemsToSignupLayouts();
      _cachedTheme4Body = toPropertyCreationColumn(
          stepLayoutItems: theme4_signup_layout_items,
          controller: controller,
          containerColor: appColors.white,
          titleWidget: Theme4AuthAppbarWidget(
            title: label_create_a_new_account.tr,
            onTap: customBackFunction,
          ),
          bottomWidget: ColoredBox(color: appColors.white, child: _showAlreadyLoginContent()),
          stepBasedPages: signupPages,
          progressShowArea: 'top',
          buttonText: label_signup.tr,
          choosedIndex: controller.choosedsignupIndex,
          tickerprovider: this,
          selectedChipIndex: 0.obs,
          onTaponSaveExit: () {
            controller.validateCredentials(type: '');
          }).toResizeWidget(isDeviceFit: true).toScroll();
    }

    return _cachedTheme4Body!;
  }

  void _addItemsToSignupLayouts() {
    theme4_signup_layout_items.clear();
    addAccountCreationMap(
        type: 'name',
        typeWidget: [
          AppDimen.startMargin.toHeight(),
          _showFirstnameSection(),
          _showLastnameSection(),
        ].toColumn());
    addAccountCreationMap(
        type: 'email',
        typeWidget: [
          AppDimen.startMargin.toHeight(),
          _showEmailSection(),
          _showPasswordSection(),
        ].toColumn());
    addAccountCreationMap(
        type: '',
        typeWidget: [
          AppDimen.startMargin.toHeight(),
          _showDOBSection().toStretch(),
          _showSignupContent(),
          18.toHeight()
        ].toColumn());
  }

  void addAccountCreationMap({required String type, required Widget typeWidget}) {
    Map<String, dynamic> accountCreationMap = {};
    accountCreationMap['widget'] = typeWidget;
    accountCreationMap['onnext'] = () {
      return controller.validateCredentials(type: type);
    };
    accountCreationMap['mainvalidation'] = () {
      controller.validateCredentials(type: type);
    };
    theme4_signup_layout_items.add(accountCreationMap);
  }

  Widget _showFirstnameSection() {
    return CustomPrefixTextField(
        title: label_first_name.tr,
        prefixIcon: isShowTextFieldIcon ? Assets.drawableGuestProfile : null,
        controller: controller.firstnameController,
        keyboardType: TextInputType.name,
        focusNode: controller.firstnameFocusNode,
        characterlength: textFieldCharacterLength,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.next,
        onSubmitted: (value) {
          controller.lastnameFocusNode.requestFocus();
        }).toPad(bottom: signUpTextFieldPadding);
  }

  Widget _showLastnameSection() {
    return CustomPrefixTextField(
        title: label_last_name.tr,
        controller: controller.lastnameController,
        prefixIcon: isShowTextFieldIcon ? Assets.drawableGuestProfile : null,
        keyboardType: TextInputType.name,
        focusNode: controller.lastnameFocusNode,
        characterlength: textFieldCharacterLength,
        textInputAction: TextInputAction.next,
        textCapitalization: TextCapitalization.sentences,
        onSubmitted: (value) {
          controller.emailFocusNode.requestFocus();
        }).toPad(bottom: signUpTextFieldPadding);
  }

  Widget _showEmailSection() {
    return CustomPrefixTextField(
        title: label_login_email.tr,
        hintText: error_email_address.tr.capitalizeFirst,
        prefixIcon: isShowTextFieldIcon ? Assets.theme4LoginEmail : null,
        controller: controller.emailController,
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        focusNode: controller.emailFocusNode,
        textInputAction: TextInputAction.next,
        onSubmitted: (value) {
          controller.passwordFocusNode.requestFocus();
        }).toPad(bottom: signUpTextFieldPadding);
  }

  Widget _showPasswordSection() {
    return CustomPasswordTextField(
      title: label_login_password.tr,
      controller: controller.passwordController,
      prefixIcon: isShowTextFieldIcon ? Assets.theme4LoginPassword : null,
      textInputAction: TextInputAction.done,
      focusNode: controller.passwordFocusNode,
      isPasswordVisible: controller.isPasswordVisible,
    ).toPad(bottom: signUpTextFieldPadding);
  }

  Widget _showDOBSection() {
    return CustomPrefixTextField(
      title: label_birthday.tr,
      hintText: birthdayHintFormat,
      controller: controller.dobController,
      prefixIcon: isShowTextFieldIcon ? Assets.theme4SignupDob : null,
      enabled: false,
      onTap: () async {
        DateTime currentDate = DateTime.now();
        DateTime lastDate = DateTime(currentDate.year - 18, currentDate.month, currentDate.day);
        DateTime firstDate = DateTime(1920, 01, 01);
        showAppDatePicker(
          context: context,
          controller: controller,
          appLayout: AppLayout.loginPage,
          initialDate: controller.initialDate ?? lastDate,
          firstDate: firstDate,
          lastDate: lastDate,
          locale: Get.locale,
          okButtonContent: label_confirm.tr,
          dateFormat: dobDialogFormat,
          onConfirm: ((String, DateTime)? selectedDate) {
            if (selectedDate != null) {
              debugPrint('selectedFirstDate: $selectedDate');
              FocusManager.instance.primaryFocus!.unfocus();
              controller.dobController.text = selectedDate.$1;
              controller.initialDate = selectedDate.$2;
            }
          }
        );
      },
    ).toPad(bottom: 25);
  }

  Widget _showSignupContent() {
    String primaryText = label_signup_content.toLowerCase().trParams(
        {'terms': label_terms_of_service.tr.toLowerCase(), 'privacy': privacy_policy.tr.toLowerCase()});
    Map<String, GestureTapCallback> searchTextWithLinks = {};
    searchTextWithLinks[label_terms_of_service.tr.toLowerCase()] = () {
      controller.authNavigator.navigateScreen(AuthScreen.staticPageContent, '7');
    };
    searchTextWithLinks[privacy_policy.tr.toLowerCase()] = () {
      controller.authNavigator.navigateScreen(AuthScreen.staticPageContent, '4');
    };
    return [
      GetBuilder(
          init: controller,
          id: controller.isTermAndPolicySelected.id,
          builder: (context) => CustomBorderContainer(
                width: 20,
                height: 20,
                borderRadius: 4,
                borderWidth: 1,
                borderColor: controller.isTermAndPolicySelected.value
                    ? appColors.secondaryColor
                    : appColors.myTripsDividerColor,
                color: controller.isTermAndPolicySelected.value
                    ? appColors.secondaryColor
                    : Colors.transparent,
                padding: pad(a: 3),
                onTap: () => controller.change(
                    rxVariable: controller.isTermAndPolicySelected,
                    value: !controller.isTermAndPolicySelected.value),
                body: controller.isTermAndPolicySelected.value
                    ? Assets.drawableViewdetailReportTick
                        .toSVG(colour: Colors.white)
                    : null,
              ).toPad(end: 5, top: 2),
      ),
      RichText(
        text: TextSpan(
          children: getTextSpans(
            searchTextWithLinks: searchTextWithLinks,
            primaryText: primaryText,
          ),
          style: TextStyle(
              fontFamily: AppFont.font, color: appColors.black, fontSize: AppDimen.textSize_16, height: 1.2),
        ),
      ).toStretch()
    ].toRow(crossAxisAlignment: CrossAxisAlignment.start);
  }

  Widget _showSignupButton() {
    return [
      PrimaryButton(
        buttonText: label_signup.tr,
        onTap: () {
          controller.validateCredentials(type: '');
        },
      ),
      _showAlreadyLoginContent().toPad(vertical: AppDimen.startMargin)
    ].toColumn();
  }

  Widget _showAlreadyLoginContent() {
    Map<String, GestureTapCallback> searchTextWithLinks = {};
    searchTextWithLinks[btn_label_login.tr] = () {
      debugPrint("getpreviousroute: ${Get.previousRoute}");
      if (Get.previousRoute != '/Login') {
        controller.firstnameController.text = "";
        controller.lastnameController.text = "";
        controller.passwordController.text = "";
        controller.emailController.text = "";
        controller.dobController.text = "";
        controller.initialDate = null;
        theme4_signup_layout_items = [];
        signupPages = [];
        _cachedTheme4Body = null;
        controller.choosedsignupIndex.value = 0;
        signupPages.add(0);
        App().splash.state.navigateScreen(SplashScreen.login, {});
      } else {
        Get.back();
      }
    };
    return Center(
      child: RichText(
        text: TextSpan(
          children: getTextSpans(
              searchTextWithLinks: searchTextWithLinks,
              primaryText: '${label_already_have_an_account.tr} ${btn_label_login.tr}'),
          style: TextStyle(
            fontFamily: AppFont.font,
            fontWeight: AppFont.regular,
            color: appColors.customTextColor,
            fontSize: AppDimen.textSize_16,
          ),
        ),
      ).toPad(bottom: AppDimen.startMargin + bottomViewPadding),
    ).toResizeWidget(color: _onLoginThemeType == 3 ? appColors.myTripsBGColor : appColors.white);
  }

  void customBackFunction() {
    if (_isTheme1) {
      controller.change(rxVariable: controller.isRxShowView, value: false);
      Get.back();
    } else if (_onLoginThemeType == 4) {
      debugPrint("_onLoginThemeType: $_onLoginThemeType");
      if (signupPages.isNotEmpty) {
        signupPages.removeLast();
        if (signupPages.isEmpty) {
          Get.back();
        } else {
          controller.choosedsignupIndex.value = signupPages[signupPages.length - 1];
        }
      } else {
        Get.back();
      }
    } else {
      Get.back();
    }
  }
}