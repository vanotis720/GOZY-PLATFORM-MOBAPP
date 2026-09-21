import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:gozy/config/client.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_colors.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_layout.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common/custom_container/custom_counter_container.dart';
import 'package:gozy/widgets/common/custom_container/custom_container.dart';
import 'package:gozy/widgets/custom_stateful_widget.dart';
import 'package:gozy/widgets/common_extension_functions.dart';

import '../../app.dart';

class CustomScaffold extends CustomStatefulWidget {
  final Widget? body;
  final Widget? backIconWidget;
  final Widget? action;
  final String? title;
  final String? backIcon;
  final Function? customAppBarFunction;
  final bool? isShowAppBar;
  final bool? extendBody;
  final bool isEnableLoadingOff;
  final bool isShowBGOnLoader;
  final String? appBarContent;
  final double? appBartextFontSize;
  final FontWeight? appBarTextFontWeight;
  final CrossAxisAlignment? crossAxisAlignment;
  final bool resizeToAvoidBottomInset;
  final Color? backgroundColor;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final Color? appBarBGColor;
  final LottieLoaders? loader;
  final double? loaderSize;
  final int? titleLines;
  final bool isDisableLoader;
  final BaseController controller;

  const CustomScaffold(
      {super.key,
        this.backIconWidget,
        this.crossAxisAlignment,
        this.title,
        this.isEnableLoadingOff = true,
        this.action,
        this.appBartextFontSize,
        this.appBarContent,
        this.appBarTextFontWeight,
        this.titleLines,
        this.body,
        this.customAppBarFunction,
        required this.controller,
        this.isShowAppBar,
        this.isShowBGOnLoader = true,
        this.resizeToAvoidBottomInset = false,
        this.extendBody = false,
        this.backgroundColor,
        this.loader,
        this.backIcon,
        this.loaderSize,
        this.floatingActionButton,
        this.floatingActionButtonLocation,
        this.bottomNavigationBar,
        this.appBarBGColor,
        this.isDisableLoader = false,});

  @override
  CustomStatefulWidgetState<CustomStatefulWidget> createState() {
    return CustomScaffoldState();
  }
}

class CustomScaffoldState extends CustomStatefulWidgetState<CustomScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  BuildContext? scaffoldContext;
  Map<String, dynamic> returnMap = {};

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        appThemeChanged.value;
        final Color dynamicBGColor = widget.backgroundColor ??
            appColors.white;
        return ColoredBox(
          color: dynamicBGColor,
          child: SafeArea(
            child: PopScope(
              canPop: widget.customAppBarFunction == null,
              onPopInvokedWithResult: (didPop, Object? result) {
                if (widget.controller.isLoading.value) {
                  FerryLoggerClient.clearPendingRequestIds(reason: 'back_navigation');
                }
                if (widget.isEnableLoadingOff) {
                  widget.controller.isLoading.value = false;
                }
                if (didPop) {
                  return;
                }
                if (widget.customAppBarFunction != null) {
                  widget.customAppBarFunction!();
                }
              },
              child: Scaffold(
                key: _scaffoldKey,
                bottomNavigationBar: widget.bottomNavigationBar,
                extendBody: widget.extendBody ?? false,
                appBar: (widget.isShowAppBar ?? false)
                    ? App().showAppbar(
                        context,
                        appBarSize: 70,
                        backIconWidget: widget.backIconWidget ??
                            (widget.backIcon != null &&
                                    (widget.backIcon?.isNotEmpty ?? false)
                                ? getBackIconWidget(
                                    backIcon: widget.backIcon,
                                    onTap: widget.customAppBarFunction != null
                                        ? () {
                                            widget.customAppBarFunction!();
                                          }
                                        : null)
                                : null),
                        titleLines: widget.titleLines,
                        AppBarbgColor: widget.appBarBGColor ?? dynamicBGColor,
                        backPressFunction: widget.customAppBarFunction,
                        AppbarTitle: widget.title,
                        appBartextFontSize: widget.appBartextFontSize,
                        appBarTextFontWeight: widget.appBarTextFontWeight,
                        AppbarAction: widget.action,
                        crossAxisAlignment: widget.crossAxisAlignment,
                      )
                    : null,
                resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
                backgroundColor: dynamicBGColor,
                body: Builder(
                  builder: (BuildContext ctx) {
                    scaffoldContext = ctx;
                    ThemeData themedata = widget.controller.isDarkMode()
                        ? appTheme.darkTheme()
                        : appTheme.lightTheme();
                    return Obx(() {
                      debugPrint(
                          'isloader: ${widget.controller.isLoading.value}---$isShowLoader---${widget.controller}');
                      return Stack(
                        children: <Widget>[
                          Theme(data: themedata, child: widget.body!),
                          if (widget.controller.isLoading.value && isShowLoader && !widget.isDisableLoader)
                            showCenterLoading(
                              controller: widget.controller,
                              loader: widget.loader ?? LottieLoaders.world_loader,
                              Size: widget.loaderSize,
                              isShowBGOnLoader: widget.isShowBGOnLoader,
                            ),
                          ],
                        );

                      });
                    },
                  ),
                  floatingActionButton:
                  widget.floatingActionButton ?? const SizedBox.shrink(),
                  floatingActionButtonLocation: widget.floatingActionButtonLocation ??
                      FloatingActionButtonLocation.centerDocked,
                ),
              ),
            ),
          );
        }
    );
  }
}

Widget showCenterLoading(
    {required LottieLoaders loader,
      double? Size,
      bool isShowBGOnLoader = true,
      required BaseController controller}) {
  return Center(
    child: CustomContainer(
      width: Size ?? 110,
      height: Size ?? 110,
      body: controller.getLoader(
          loader: loader.name,
          changed: appThemeChanged.value,
          color: appColors.secondaryColor),
    ).toPad(bottom: 50),
  ).toResizeWidget(
    isDeviceFit: true,
    color: Colors.transparent,
  );
}

Widget getBackIconWidget(
    {Color? iconBGColor,
      Color? borderColor,
      String? backIcon,
      GestureTapCallback? onTap,
      EdgeInsetsGeometry? margin,
      double? clickableSize,
      BoxFit? fit,
      isReverseRotate = false,
      Color? iconColor,
      int? quarterTurns,
      double? borderWidth,
      double? iconSize,
      List<BoxShadow>? boxShadow,
      double? size,
      int? themeType,
      double? iconPadding,

      bool isEnableProfileType = true}) {
  debugPrint(
      "isrtl: ${Bidi.isRtlLanguage(Get.locale?.languageCode)} --- ${Get.locale?.languageCode} --");
  return Obx(()
  {
    appThemeChanged.value;
    List<BoxShadow>? boxshadow = boxShadow;
    int resolvedThemeType = themeType ?? 1;
    Color? resolvedIconBGColor = iconBGColor;
    Color? resolvedBorderColor = borderColor;
    double? resolvedBorderWidth = borderWidth;

    if (isEnableProfileType) {
      switch (resolvedThemeType) {
        case 1:
        case 2:
          resolvedIconBGColor ??= Colors.transparent;
          resolvedBorderColor ??= appColors.myTripsDividerColor;
          resolvedBorderWidth ??= 1.5;
          break;
        case 3:
          resolvedBorderColor ??= Colors.transparent;
          resolvedIconBGColor ??= appColors.back_close_icon_bg;
          break;
        case 4:
          resolvedBorderColor ??= AppColors.staticwhite;
          resolvedIconBGColor ??= appColors.white;
          boxshadow ??= kElevationToShadow[1];
          break;
      }
    }
    return CustomCounterContainer(
        width: size ?? 33,
        height: size ?? 33,
        padding: pad(a: iconPadding ?? 7),
        borderWidth: resolvedBorderWidth,
        color: resolvedIconBGColor ?? appColors.back_close_icon_bg,
        borderColor:
        resolvedBorderColor ?? resolvedIconBGColor ?? appColors.back_close_icon_bg,
        margin:
        margin ?? pad(h: 15, end: 13, start: AppDimen.startMargin - 2),
        boxShadow: boxshadow,
        body: (backIcon ??
            overALLAppLayoutModel?.backIcon ??
            Assets.drawableFilterCalendarArrow)
            .toSVG(
            quarterTurns: quarterTurns ?? (Bidi.isRtlLanguage(Get.locale?.languageCode) ? 2 : 0),
            clickableSize: clickableSize,
            fit: fit,
            size: backIcon == null ? iconSize ?? 16 : null,
            colour: iconColor ?? getBackIconColor(themeType: resolvedThemeType)),
        onTap: onTap ?? onBack);
  },
  );
}

Widget getBackArrowWidget({
  GestureTapCallback? onTap,
  String? backIcon,
  Color? borderColor,
  double? iconPadding,
}) {
  return getBackIconWidget(
      iconBGColor: appColors.white,
      backIcon: backIcon ?? Assets.viewcarsLeftArrow,
      iconColor: appColors.black,
      isEnableProfileType: false,
      borderWidth: 1,
      borderColor: borderColor ?? appColors.BackIconBorderColor,
      size: 40,
      iconSize: 28,
      iconPadding: iconPadding,
      onTap: onTap ?? onBack
  );
}