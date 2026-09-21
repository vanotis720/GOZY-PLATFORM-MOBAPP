import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:gozy/app.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_colors.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/resources/app_layout.dart';
import 'package:gozy/screens/views/auth/auth_controller.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/screens/views/splash/splash_navigator.dart';
import 'package:gozy/utils/common_api_controller.dart';
import 'package:gozy/widgets/common/custom_button/primary_button.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/common/custom_button/custom_button.dart';
import 'package:gozy/widgets/custom_stateful_widget.dart';
import 'package:gozy/widgets/custom_text.dart';
import 'package:gozy/widgets/smooth_page_indicator.dart';
import 'package:gozy/widgets/theme1/theme1_auth_top_image_widget.dart';


class GetStarted extends CustomStatefulWidget  {
  const GetStarted({super.key});

  @override
  _GetStartedStatefulWrapperState createState() => _GetStartedStatefulWrapperState();
}
class _GetStartedStatefulWrapperState extends CustomStatefulWidgetState<GetStarted> {
  AuthController controller = Get.find();
  List<String> carouselImageList = [];
  var _carouselScrollController;
  static final int? _onBoardThemeType = appLayoutMap[AppLayout.onBoardPage]?.themeType;
  final bool _isTheme1 = (_onBoardThemeType == 1 && appLayoutMap[AppLayout.loginPage]?.themeType == 1);

  @override
  void initState() {
    super.initState();
    controller.hideKeyBoard();
    debugPrint("app layout: $_onBoardThemeType --- $overALLThemeType");
    carouselImageList.clear();
    switch (_onBoardThemeType) {
      case 2:
        debugPrint("listimage: ${'res/drawable/theme_2'.getAssetList()}");
        carouselImageList = 'res/drawable/theme_2/get_started'.getAssetList();
        carouselImageList.remove('res/drawable/theme_2/get_started/.DS_Store');
        _carouselScrollController = PageController(initialPage: 0, viewportFraction: 1);
        break;
      case 3:
        carouselImageList = 'res/drawable/theme_3/get_started'.getAssetList();
        debugPrint("carouselImageList: $carouselImageList");
        carouselImageList.remove('res/drawable/theme_3/get_started/.DS_Store');
        _carouselScrollController = PageController(initialPage: 0, viewportFraction: 1);
        break;
      case 4:
        controller.change(rxVariable: controller.isRxShowView, value: false);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 350)).then((value) {
            controller.change(rxVariable: controller.isRxShowView, value: true);
          });
        });
        break;
    }

    if(currencyRates ==null){
      isShowLoader = false;
      controller.getCurrencyRates();
    }


  }


  @override
  Widget build(BuildContext context) {
    return  CustomScaffold(
      controller: controller,
      isShowAppBar: false,
      backgroundColor: _onBoardThemeType ==3 ?  appColors.profile_bg : null,
      isShowBGOnLoader: false,
      customAppBarFunction: (){
        App().closeApp();
      },
      body: switch (_onBoardThemeType) {
        1 => showTheme1Bodycontent(),
        2 => showTheme2Bodycontent(),
        3 => showTheme3Bodycontent(),
        4 => showTheme4Bodycontent(),
        _ => const SizedBox.shrink(),
      },
    ).toAnnotatedRegion(controller: controller);
  }

  Widget showTheme1Bodycontent() {
    return [
      const Theme1AuthTopImageWidget(isShowBackArrow: false, flex: 7,),
      GetBuilder(
        init: controller,
        id: controller.isRxShowView.id,
        builder: (context) {
          return [
            12.toHeight(),
            getStartedTitleText(),
            12.toHeight(),
            getStartedDescText(),
            28.toHeight(),
            _getStartedLoginButton(isButtonLayout: false),
            getStartedSignupButton(),
          ].toColumn().toPad(horizontal: AppDimen.startMargin).toFadeSlideAnimateWidget(rxbool: controller.isRxShowView, controller: controller, fromOffset: Offset(0, 2)).toStretch(flex: 4);
        }
      ),
      bottomViewPadding.toHeight(),
    ].toColumn();


  }

  Widget showTheme2Bodycontent() {
    return [

      Image.asset(Assets.getStartedTheme2Slide2,fit: BoxFit.fitWidth).combinedBuilder(
          deductionHeight: 50,
          controller: controller, builder: (constraints, imagesize,  isSpaceLess){
        return   getviewPager(isSpaceLess: isSpaceLess,isClipPath: true);
      }).toStretch(flex: 10),
      Assets.drawableGuestTrips.toSVG(size: 50,colour: appColors.black).toPad(bottom:  20),
      getStartedTitleText(),
      12.toHeight(),
      getStartedDescText(fontSize:AppDimen.textSize_16),
      18.toHeight(),
      _showScrollingDotView(),
      Spacer(),
      IntrinsicHeight(
        child: [
          AppDimen.startMargin.toWidth(),
          CustomText(
          text: label_login_skip.tr,
          size: AppDimen.textSize_16,
          color: appColors.secondaryColor,
          decorationColor: appColors.secondaryColor,
          onTap: (){
            App().splash.state.navigateScreen(SplashScreen.guestHome, {});
          },
        ),
          Spacer(),

          getBackArrowWidget(
              backIcon: Assets.drawableRightArrow,
             borderColor: appColors.myTripsDividerColor,
            onTap: (){
                if(_carouselScrollController.page?.round() == carouselImageList.length-1){
                  App().splash.state.navigateScreen(SplashScreen.login, {});
                  Future.delayed(const Duration(milliseconds: 350)).then((value) {
                    _carouselScrollController.jumpToPage(0);
                  });

                } else{
                  _carouselScrollController.nextPage( duration: Duration(milliseconds: 500),
                      curve: Curves.easeIn);
                }
                debugPrint("_carouselScrollController.page: ${_carouselScrollController.page}");

            }
          ),
          6.toWidth(),
        ].toRow().toFitToDeviceWidth(),
      ),
      bottomViewPadding.toHeight(),
    ].toColumn()
        .toPad(horizontal: AppDimen.startMargin);
  }

  Widget showTheme3Bodycontent() {
    debugPrint("profileImageType: --- ${appLayoutMap[AppLayout.onBoardPage]?.profileIconType}");
    return [
     Align(
       alignment: AlignmentDirectional.topEnd,
       child: toOnTap(
         onTap: () {
           App().splash.state.navigateScreen(SplashScreen.guestHome, {});
         },
         child: Assets.drawableSignupClose.toSVG(size: 14, colour: appColors.black).toCircle(color: appColors.white,margin:0, padding: 10)).toPad(top: 15),
     ),
      getviewPager(fit: BoxFit.scaleDown).toStretch(flex: 7),
      20.toHeight(),
      _showScrollingDotView(dotColor: appColors.secondaryColor),
      38.toHeight(),
      getStartedTitleText(),
      12.toHeight(),
      getStartedDescText(textAlign: TextAlign.center,fontSize: AppDimen.textSize_16),
      18.toHeight(),
      Spacer(),
      PrimaryButton(
        buttonText: btn_label_get_started.tr,
        shadowOpacity: 0.0,
        buttonTextFontSize: AppDimen.textSize_18,
        onTap: () {
          App().splash.state.navigateScreen(SplashScreen.login, {});
        },
      ).toPad( bottom: AppDimen.startMargin+bottomViewPadding),
    ].toColumn(crossAxisAlignment: CrossAxisAlignment.center).toPad(horizontal: AppDimen.startMargin);
  }

  Widget showTheme4Bodycontent() {

    String welcomeText = '${label_login_welcome.tr}\n$APP_NAME';
    return [
      Assets.theme4GetStarted
          .toPng(width: deviceWidth,height: deviceHeight,fit: BoxFit.cover)
      .toLinearGradientShaderMask(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, Colors.black.withAlpha( 200)],),

      CancelButton(buttonText:label_login_skip.tr,
          height: 30,
          borderColor: AppColors.staticwhite,
          color: appColors.black,
          borderRadius: 25,
          isButtonLayout: false,
          isExpand: false,
          onTap: (){
            App().splash.state.navigateScreen(SplashScreen.guestHome, {});
      }).toPad(top: AppDimen.startMargin,end: AppDimen.startMargin).toFadeSlideAnimateWidget(rxbool: controller.isRxShowView,controller: controller,fromOffset: Offset(0, -2)).toPositionedAlign(alignment: AlignmentDirectional.topEnd),
      [
        TweenAnimationBuilder<int>(
            duration: const Duration(seconds: 3),
            tween: IntTween(begin: 0, end: welcomeText.length),
            builder: (BuildContext? context, int? value, Widget? child) {
            return getStartedTitleText(fontSize: AppDimen.textSize_24, textColor: AppColors.staticwhite,text: welcomeText.substring(0, value));
          }
        ),
        AppDimen.startMargin.toHeight(),

        _getStartedLoginButton(fillcolor: AppColors.staticwhite,
            borderColor: AppColors.staticwhite,
            textColor: AppColors.staticblack)
            .toFadeSlideAnimateWidget(rxbool: controller.isRxShowView,controller: controller,),

        15.toHeight(),
        _getStartedLoginButton(btnText: label_signup.tr,borderColor: AppColors.staticwhite,textColor: AppColors.staticwhite, isButtonLayout: false, )
            .toFadeSlideAnimateWidget(rxbool: controller.isRxShowView,controller: controller,),
        AppDimen.startMargin.toHeight(),
      ].toColumn(mainAxisSize: MainAxisSize.min).toPad(horizontal: AppDimen.startMargin).toPositionedAlign(alignment: Alignment.bottomCenter)

    ].toStack();
  }

  Widget getviewPager({bool isSpaceLess = false, bool isClipPath = false, BoxFit? fit}) {  return toPageView(
    itemCount: carouselImageList.length,
    controller: _carouselScrollController,
    clipBehavior: Clip.none,
    scrollDirection: Axis.horizontal,
    itemBuilder: (context, index) {

      return AnimatedBuilder(
        animation: _carouselScrollController,
        builder: (context, child) {
          double scale = 1.0;

          if (_carouselScrollController.position.hasContentDimensions) {
            double page = _carouselScrollController.page ?? 0.0;
            double pageOffset = page - index;
            const double minScale = 0.8;
            scale = 1.0 - (pageOffset.abs() * (1.0 - minScale));
            scale = scale.clamp(minScale, 1.0);
          }
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: Builder(
            builder: (context) {
              Widget carouselImage = carouselImageList[index].toPng(
                  imageAlignment: !isSpaceLess ? Alignment.bottomCenter : Alignment.topCenter,
                  fit: fit ?? BoxFit.cover,
                  width: deviceWidth
              );

              if (isClipPath) {
                return ClipPath(
                  clipper: DiagonalCutClipper(),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: carouselImage,
                );
              } else {
                return carouselImage;
              }
            }
        ),
      );
    },
  ).toFitToDeviceWidth();
  }


  Widget _showScrollingDotView({Color? dotColor}){
    return  SmoothPageIndicator(
      controller: _carouselScrollController,
      count: carouselImageList.length,
      itemWidth: deviceWidth+50,
      effect: getScrollingDotEffect(dotColor: dotColor,inActiveStrokeColor: appColors.ratingBarDefaultColor, maxVisibleDots: 3),
    );
  }

  Widget getStartedTitleText({double? fontSize, Color? textColor,String? text}) {
    return CustomTitleText(text: text ?? '${label_login_welcome.tr} $APP_NAME',size: fontSize ?? AppDimen.textSize_22, color: textColor, fontWeight: AppFont.semiBold,);
  }

  Widget getStartedDescText({TextAlign? textAlign,double? fontSize}) {
    return  CustomTitleText(text: label_get_started_description.tr,size: fontSize ??AppDimen.textSize_16,fontWeight: AppFont.regular,textAlign: textAlign ?? TextAlign.start,);
  }

 Widget _getStartedLoginButton({Color? fillcolor, Color? textColor,Color? borderColor,String? btnText, bool? isButtonLayout}) {
    return  CancelButton(
      buttonText: btnText ?? btn_label_login.tr,
      color: textColor?? appColors.textColor,
      height: AppDimen.button_height,
      isButtonLayout: isButtonLayout ?? true,
      fillcolor: fillcolor ?? Colors.transparent,
      borderColor: borderColor ?? appColors.customBorderColor,
      onTap: () {
        if(_isTheme1) {
          controller.change(rxVariable: controller.isRxShowView, value: false);
          App().splash.state.navigateScreen(SplashScreen.login, {'updatelayout': (){
            controller.change(rxVariable: controller.isRxShowView, value: true);
          }}
              , ThemeType:1);

        } else{
          App().splash.state.navigateScreen(btnText == label_signup.tr ?SplashScreen.signup : SplashScreen.login, {});
        }

      },
    );
  }

  Widget getStartedSignupButton() {
    return  PrimaryButton(
      buttonText: label_signup.tr,
      shadowOpacity: 0.0,
      onTap: () {
        if (_isTheme1) {
          controller.change(rxVariable: controller.isRxShowView, value: false);
          App().splash.state.navigateScreen(SplashScreen.signup, {'updatelayout': (){
            controller.change(rxVariable: controller.isRxShowView, value: true);
          }}, ThemeType: 1);

        } else {
          App().splash.state.navigateScreen(SplashScreen.signup, {});
        }
      },
    ).toPad(top: 15.0, bottom: 30);
  }
}

class DiagonalCutClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path()
      ..lineTo(0.0, Bidi.isRtlLanguage(Get.locale?.languageCode) ? size.height :size.height - 70.0)
      ..lineTo(size.width, Bidi.isRtlLanguage(Get.locale?.languageCode) ? size.height - 70.0 :size.height)
      ..lineTo(size.width, 0.0)
    ..close();
    return path;
  }

  @override
  bool shouldReclip(DiagonalCutClipper oldClipper) => false;
}