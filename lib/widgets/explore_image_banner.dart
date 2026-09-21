import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:gozy/resources/app_colors.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common/custom_container/custom_counter_container.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/conditional_parent_widget.dart';
import 'package:gozy/widgets/custom_text.dart';

import '../constant.dart';
import '../generated/assets.dart';

class ExploreImageBanner extends GetView {
  final String? title;
  final String? description;
  final String? bannerImage;
  final bool? isShimmerView;
  final String? buttonLabel;
  final double? bannerBorderRadius;
  final VoidCallback? onTap;

  final int? themeType;

  const ExploreImageBanner(
      {super.key,
      this.title = '',
      this.description = '',
      this.bannerImage = '',
      this.isShimmerView = false,
      this.buttonLabel = '',
      this.bannerBorderRadius = 0,
      this.onTap,
      this.themeType});

  @override
  Widget build(BuildContext context) {
    return themeType == 1
        ? _showThemeImageBanner(themeType: themeType!)
        : themeType == 2
            ? _showThemeImageBanner(parentWidgetType: 'stack', themeType: themeType!)
            : themeType == 3
                ? _showThemeImageBanner(
                    arrowIcon: Assets.drawableFilterCalendarArrow,
                    themeType: themeType!,
                    isReverseRotate: true)
                : themeType == 4
                    ? _showThemeImageBanner(
                        parentWidgetType: 'stack',
                        arrowIcon: Assets.theme4BackArrow,
                        isReverseRotate: true,
                        isRoundedArrowIcon: true,
                        themeType: themeType!)
                    : 0.toHeight();
  }

  Widget _showThemeImageBanner(
      {String arrowIcon = Assets.drawableRightArrow,
      String? parentWidgetType,
      bool isReverseRotate = false,
      bool isRoundedArrowIcon = false,
      required int themeType}) {
    Widget bannerImageWidget = Container(
        height: (themeType == 1 || themeType == 3) ? 185 : 221,
        width: deviceWidth,
        padding: pad(top: parentWidgetType == 'stack' ? 10 : 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(bannerBorderRadius ?? 0)),
          color: (isShimmerView ?? false) ? appColors.shimmerplaceholderColor : null,
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(bannerBorderRadius ?? 0)),
          gradient: LinearGradient(
              colors: [Colors.transparent, Colors.black54],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0, 1]),
        ),
        child: CachedNetworkImage(
          imageUrl: bannerImage!,
          key: key,
          maxWidthDiskCache: deviceWidth.toInt(),
          maxHeightDiskCache: deviceHeight.toInt(),
          memCacheWidth: deviceWidth.toInt(),
          memCacheHeight: deviceHeight.toInt(),
          imageBuilder: (context, imageProvider) => Container(
            width: deviceWidth,
            height: 210,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(bannerBorderRadius ?? 0)),
              image:
                  (isShimmerView ?? false) ? null : DecorationImage(image: imageProvider, fit: BoxFit.cover),
              color: (isShimmerView ?? false) ? appColors.shimmerplaceholderColor : null,
            ),
          ),
        ),
    );

    Widget textButtonWidget = toOnTap(
        onTap: () => onTap!(),
        child: [
          CustomText(
            text: !(isShimmerView ?? false) ? (buttonLabel ?? "") : 70.toGenerateEmptyString(),
            color: parentWidgetType == 'stack' ? AppColors.staticwhite : appColors.secondaryColor,
            size: AppDimen.textSize_16,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            isShimmerView: isShimmerView ?? false,
          ).toStretch(isExpanded: false),
          5.toWidth(),
          (isShimmerView ?? false)
              ? 0.toWidth()
              : ConditionalParentWidget(
                  condition: isRoundedArrowIcon,
                  parentBuilder: (Widget child) => CustomCounterContainer(
                    body: child,
                    color: appColors.secondaryColor,
                    borderColor: appColors.secondaryColor,
                    width: 15,
                    height: 15,
                    padding: pad(a: 2),
                  ),
                  child: arrowIcon
                      .toSVG(
                          quarterTurns: Bidi.isRtlLanguage(Get.locale?.languageCode)
                              ? (isReverseRotate ? 0 : 2)
                              : (isReverseRotate ? 2 : 0),
                          size: 8,
                          colour:
                              parentWidgetType == 'stack' ? AppColors.staticwhite : appColors.secondaryColor)
                      .toPad(top: arrowIcon == Assets.drawableRightArrow ? 3 : 0),
                )
        ].toRow(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
        ));

    if (parentWidgetType != null && parentWidgetType == 'stack') {
      return <Widget>[bannerImageWidget, textButtonWidget.toPad(bottom: 18, horizontal: 18)]
          .toStack(alignment: Alignment.bottomCenter)
          .toPad(horizontal: AppDimen.startMargin - 5);
    } else {
      return <Widget>[bannerImageWidget, 18.toHeight(), textButtonWidget]
          .toColumn()
          .toPad(horizontal: AppDimen.startMargin - 5);
    }
  }
}