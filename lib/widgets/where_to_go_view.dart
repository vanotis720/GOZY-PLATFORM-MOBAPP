import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:gozy/constant.dart";
import "package:gozy/generated/assets.dart";
import "package:gozy/resources/app_dimen.dart";
import "package:gozy/resources/app_font.dart";
import "package:gozy/resources/app_lang.dart";
import "package:gozy/screens/views/base_controller.dart";
import "package:gozy/widgets/common/custom_container/custom_border_container.dart";
import "common_extension_functions.dart";
import "common/custom_container/custom_container.dart";
import "custom_text.dart";

Widget WhereToGoSection({GestureTapCallback? onTapSearchLocation,GestureTapCallback? onBackPress,GestureTapCallback? onTapFilter, String? leadingIcon, bool isGuestExplore = false, String? showingLocationText, Color? HighlightColor, Color? iconColor, bool isShimmerView = false, int? themeType, Color? placeHolderColor, double? themeTypeBorderRadius, Color? fillColor, bool? isShowDot, bool? selectedLocationEmpty}){
  return
    themeType == 1 ? _toTheme1WhereToGoView(isShimmerView: isShimmerView, onTapFilter: onTapFilter, highlightColor: HighlightColor, themeTypeBorderRadius: themeTypeBorderRadius, onBackPress: onBackPress, onTapSearchLocation: onTapSearchLocation, leadingIcon: leadingIcon, isShowDot: isShowDot, fillColor: fillColor, filterHighlighter:HighlightColor, iconColor:iconColor, showingLocationText :showingLocationText, selectedLocationEmpty: selectedLocationEmpty, isGuestExplore: isGuestExplore) :
    themeType ==2 ? _toTheme2WhereToGoView(isShimmerView: isShimmerView, onTapFilter: onTapFilter, highlightColor: HighlightColor, themeTypeBorderRadius: themeTypeBorderRadius, onBackPress: onBackPress, onTapSearchLocation: onTapSearchLocation, leadingIcon :leadingIcon, showingLocationText :showingLocationText,HighlightColor:HighlightColor,iconColor:iconColor, isShowDot: isShowDot, selectedLocationEmpty: selectedLocationEmpty, isGuestExplore: isGuestExplore).toPad(horizontal: isGuestExplore ? 18 : 0) :
    themeType ==3 ? _toTheme3WhereToGoView(isShimmerView: isShimmerView, onTapFilter: onTapFilter, highlightColor: HighlightColor, themeTypeBorderRadius: themeTypeBorderRadius, onBackPress: onBackPress, onTapSearchLocation: onTapSearchLocation, leadingIcon :leadingIcon, showingLocationText :showingLocationText,HighlightColor:HighlightColor,iconColor:iconColor, fillColor: fillColor, isShowDot: isShowDot, selectedLocationEmpty: selectedLocationEmpty, isGuestExplore: isGuestExplore).toPad(horizontal: isGuestExplore ? 18 : 0) :
    themeType ==4 ? _toTheme4WhereToGoView(isShimmerView: isShimmerView, onTapFilter: onTapFilter, highlightColor: HighlightColor, themeTypeBorderRadius: themeTypeBorderRadius, onBackPress: onBackPress, onTapSearchLocation: onTapSearchLocation, leadingIcon :leadingIcon, showingLocationText :showingLocationText,HighlightColor:HighlightColor,iconColor:iconColor, isShowDot: isShowDot, selectedLocationEmpty: selectedLocationEmpty, isGuestExplore: isGuestExplore) :
    0.toHeight();
}

Widget _toTheme4WhereToGoView({bool isShimmerView = false, GestureTapCallback? onTapFilter, Color? highlightColor, double? themeTypeBorderRadius, GestureTapCallback? onTapSearchLocation,GestureTapCallback? onBackPress,String? leadingIcon, String? showingLocationText,Color? HighlightColor, Color? iconColor, bool? isShowDot, bool? selectedLocationEmpty, bool? isGuestExplore}) {
  return [
    [
      leadingIcon  != null ? CustomContainer(
        padding: pad(start:10, top: 10, bottom: 10),
        onTap: onBackPress ?? onTapSearchLocation,
        body: leadingIcon.toSVG(colour: appColors.black),
      ) : Assets.theme4ExploreSearchLocation.toSVG(colour: appColors.black),
      6.toWidth(),
      toOnTap(
          onTap: onTapSearchLocation,
          child: CustomText(text: showingLocationText ?? label_theme2_search_your_location.tr,
            fontWeight: FontWeight.normal,
            size: AppDimen.textSize_16,
          )).toStretch(),
      [
        Assets.drawableTheme3Filter.toSVG(colour: (isShowDot ?? false) ? (HighlightColor ?? appColors.black) : appColors.black,onTap: onTapFilter).toPad(all: 7),
        (isShowDot ?? false) ? PositionedDirectional(
            top: 0.5,
            end: 0.5,
            child: CustomContainer(
              height: 6,
              width: 6,
              decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle
              ),
            )
        ) : 0.toWidth()
      ].toStack(),
    ].toRow().toPad(horizontal: (isGuestExplore ?? false) ? 18 : 0),
    (isGuestExplore ?? false) ? 20.toHeight() : 0.toHeight(),
    leadingIcon != null ? 0.toHeight() : filterDivider
  ].toColumn();
}
Widget _toTheme2WhereToGoView({bool isShimmerView = false, GestureTapCallback? onTapFilter, Color? highlightColor, double? themeTypeBorderRadius, GestureTapCallback? onTapSearchLocation,GestureTapCallback? onBackPress,String? leadingIcon, String? showingLocationText,Color? HighlightColor, Color? iconColor, bool? isShowDot, bool? selectedLocationEmpty, bool? isGuestExplore}){
  return
    toOnTap(
      onTap: onTapSearchLocation,
      child: CustomContainer(
        width:deviceWidth,
        height: 50,
        decoration:  BoxDecoration(
            color: isShimmerView ?  appColors.shimmerplaceholderColor : appColors.white,
            borderRadius: BorderRadius.circular(AppDimen.appBorderRadius),
            border: Border.all(color: appColors.myTripsDividerColor, width: 1)
        ) ,
        body: isShimmerView ? null :
        <Widget>[
          15.toWidth(),
          toOnTap(
              onTap: onBackPress,
              child: leadingIcon != null ? leadingIcon.toSVG(colour: appColors.black) : Assets.drawableFamousLocation.toSVG(size: 18,colour: appColors.secondaryColor)
          ),
          CustomText(
            text: showingLocationText !=null && showingLocationText.isNotEmpty ? showingLocationText : label_theme2_search_your_location.tr,
            fontWeight: FontWeight.normal,
            textAlign: TextAlign.center,
            size: AppDimen.textSize_16,
            color: appColors.customTextColor,
          ).toScroll(scrollDirection: Axis.horizontal).toPad(start:  8, end:18).toStretch(),
          [
            CustomBorderContainer(
              color: (isShowDot ?? false) ? appColors.theme4AppBarBg : appColors.famousLocationBGColor,
              width: 50,
              onTap: onTapFilter,
              alignment: AlignmentDirectional.center,
              borderRadius: 0,
              body: Assets.theme2ExploreFilter.toSVG(size: 20,colour: appColors.black),
            ),
            (isShowDot ?? false) ? PositionedDirectional(
                top: 6,
                end: 8,
                child: CustomContainer(
                  height: 8,
                  width: 8,
                  decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(width: 1, color: Colors.white)
                  ),
                )
            ) : const SizedBox.shrink()
          ].toStack()

        ].toRow(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center
        ),
      ),
    );
}
Widget _toTheme3WhereToGoView({
  bool isShimmerView = false,
  GestureTapCallback? onTapFilter,
  Color? highlightColor,
  double? themeTypeBorderRadius,
  GestureTapCallback? onTapSearchLocation,
  GestureTapCallback? onBackPress,
  String? leadingIcon,
  String? showingLocationText,
  Color? HighlightColor,
  Color? iconColor,
  Color? fillColor,
  bool? isShowDot,
  bool? selectedLocationEmpty,
  bool? isGuestExplore,
}) {
  return [
     toOnTap(
        onTap: onTapSearchLocation,
        child: CustomContainer(
          decoration: BoxDecoration(
            color: isShimmerView
                ? appColors.shimmerplaceholderColor
                : appColors.white,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
                color: appColors.myTripsDividerColor, width: 1),
          ),
          body: isShimmerView
              ? null
              : [

            if (leadingIcon != null)
              CustomContainer(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                height: 35,
                width: 35,
                padding: pad(a: 10),
                margin: pad(start: 2),
                onTap:
                onBackPress ?? onTapSearchLocation,
                body: leadingIcon.toSVG(
                  size: 15,
                  colour: appColors.black,
                ),
              )
            else
              18.toWidth(),

            CustomText(
              text: showingLocationText != null &&
                  showingLocationText.isNotEmpty
                  ? showingLocationText
                  : label_search_your_car_location.tr,
              fontWeight: AppFont.regular,
              textAlign: TextAlign.start,
              size: AppDimen.textSize_16,
              overflow: TextOverflow.ellipsis,
            )
                .toScroll(
                scrollDirection:
                Axis.horizontal)
                .toPad(
                top: 12,
                bottom: 16,
                end: 18).toStretch(),

            9.toWidth(),
          ].toRow(crossAxisAlignment: CrossAxisAlignment.center),
        ),
      ).toStretch(isExpanded: false),
    [

      toOnTap(
        onTap: onTapFilter,
        child: CustomContainer(
          decoration: BoxDecoration(
            color: isShimmerView
                ? appColors.shimmerplaceholderColor
                : fillColor ?? appColors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: HighlightColor ??
                  appColors.myTripsDividerColor,
              width: 1,
            ),
          ),
          padding: pad(w: 14, h: 15),
          margin: pad(start: 5),
          body: isShimmerView
              ? const SizedBox(width: 20, height: 50)
              : Assets.drawableTheme3Filter.toSVG(
            size: 14,
            colour: iconColor ?? appColors.black,
            colourBlendMode: BlendMode.srcIn,
          ),
        ),
      ),

      /// 🔴 Dot indicator
      if (isShowDot ?? false)
        PositionedDirectional(
          top: 8,
          end: 10,
          child: CustomContainer(
            height: 7,
            width: 7,
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
              border: Border.all(
                  width: 1, color: Colors.white),
            ),
          ),
        ),
    ].toStack(),
  ].toRow().toResizeWidget(width: deviceWidth, height: 50);
}

Widget _toTheme1WhereToGoView({
  bool? isShimmerView,
  GestureTapCallback? onTapFilter,
  Color? highlightColor,
  double? themeTypeBorderRadius,
  GestureTapCallback? onTapSearchLocation,
  GestureTapCallback? onBackPress,
  String? leadingIcon,
  Color? fillColor,
  Color? iconColor,
  bool? isShowDot,
  Color? filterHighlighter,
  String? showingLocationText,
  bool? selectedLocationEmpty,
  bool? isGuestExplore,
}) {
  return [
    Flexible(
      child: toOnTap(
        onTap: onTapSearchLocation,
        child: CustomContainer(
          decoration: BoxDecoration(
            color: isShimmerView!
                ? appColors.shimmerplaceholderColor
                : appColors.white,
            border: Border.all(
                color: appColors.myTripsDividerColor, width: 1),
            borderRadius: BorderRadiusDirectional.circular(8),
          ),
          body: [
            toOnTap(
              onTap: onBackPress ?? onTapSearchLocation,
              child: CustomContainer(
                padding: pad(start: 10, top: 10, bottom: leadingIcon != null ? 10 : 12),
                margin: pad(start: 7),
                onTap: onBackPress ?? onTapSearchLocation,
                body: leadingIcon != null
                ? leadingIcon.toSVG(colour: appColors.black)
                : Assets.drawableSearch.toSVG(
                  size: leadingIcon != null ? 13 : 14,
                  colour: appColors.textfieldHintColor,
                ),
              ),
            ),

            CustomText(
              text: showingLocationText ??
                  "${label_destination.tr}, "
                      "${label_city.tr.toLowerCase()}, "
                      "${address.tr.toLowerCase()}",
              fontWeight: FontWeight.normal,
              textAlign: TextAlign.center,
              size: AppDimen.textSize_16,
              color: !(selectedLocationEmpty ?? true)
                  ? appColors.customTextColor
                  : appColors.textfieldHintColor,
            )
                .toScroll(scrollDirection: Axis.horizontal)
                .toPad(
              top: 12.5,
              bottom: 12.5,
              start: (isGuestExplore ?? false) ? 4 : 8,
              end: 18,
            ).toStretch(),
          ].toRow(crossAxisAlignment: CrossAxisAlignment.center),
        ),
      ),
    ),

    /// 🔹 FILTER BUTTON WITH DOT
    [

      toOnTap(
        onTap: onTapFilter,
        child: CustomContainer(
          decoration: BoxDecoration(
            color: isShimmerView
                ? appColors.shimmerplaceholderColor
                : fillColor ?? appColors.white,
            border: Border.all(
              color: filterHighlighter ??
                  appColors.myTripsDividerColor,
              width: 1,
            ),
            borderRadius:
            BorderRadiusDirectional.circular(8),
          ),
          padding: pad(w: 14, h: 15),
          margin: pad(start: 6),
          body: isShimmerView
              ? const SizedBox(width: 20, height: 50)
              : Assets.drawableExploreFilter.toSVG(
            size: 18,
            colour: appColors.black,
            colourBlendMode: BlendMode.srcIn,
          ),
        ),
      ),

      /// 🔴 Dot indicator
      if (isShowDot ?? false)
         PositionedDirectional(
          top: 9,
          end: 9,
          child: CustomContainer(
            height: 8,
            width: 8,
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        ),
    ].toStack(),
  ].toRow().toResizeWidget(width: deviceWidth, height: 50);
}