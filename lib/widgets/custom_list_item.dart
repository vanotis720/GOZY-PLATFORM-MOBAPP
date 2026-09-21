import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/resources/app_layout.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/bottom_sheet/bottom_sheet_refresh_controller.dart';
import 'package:gozy/widgets/camera_screen.dart';
import 'package:gozy/widgets/common/custom_bottomsheet/custom_bottomsheet.dart';
import 'package:gozy/widgets/common/custom_container/custom_border_container.dart';
import 'package:gozy/widgets/common/custom_container/custom_counter_container.dart';
import 'package:gozy/widgets/common/custom_container/custom_wishlist_container.dart';
import 'package:gozy/widgets/common/custom_network_image/custom_profile_network_image.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/conditional_parent_widget.dart';
import 'package:gozy/widgets/common/custom_container/custom_container.dart';
import 'package:gozy/widgets/theme4/custom_dash_divider.dart';
import 'custom_container_extensions.dart';
import 'custom_text.dart';

class CustomListItem extends GetView {
  final String text;
  double size;
  String? listTrailingIcon;
  String? listLeadingIcon;
  Color? trailingIconBgColor;
  bool? hideBorderColor;
  final FontWeight fontWeight;
  final Color? textColor;
  final Color? listTrailingIconBGColor;
  final double? dividerSpacing;
  final Color? dividerColor;
  final double? listTrailingIconSize;
  final double? listLeadingIconSize;
  final Color? listLeadingIconColor;
  final Color? borderColor;
  final double? listLeadingIconPadding;
  final Widget? trailingWidget;
  final Widget? listLeadingWidget;
  final bool isSoftWrap;
  final bool toAddPad;
  final String? isImageAsset;
  final bool? isImageDividerVisible;
  final bool? isFilterLocPage;
  final double? horizontalpadding;
  final GestureTapCallback? onTap;

  bool? showDashedDivider;
  bool? isReverseRotation;
  double? iconSpacing;
  bool? isCircular;
  bool isPass;
  double? leadingIconBgBorderRadius;

  CustomListItem({super.key,
    required this.text,
    this.size = AppDimen.textSize_16,
    this.fontWeight = AppFont.regular,
    this.textColor,
    this.listTrailingIconBGColor,
    this.dividerSpacing,
    this.dividerColor,
    this.onTap,
    this.iconSpacing,
    this.horizontalpadding,
    this.listTrailingIcon,
    this.listLeadingIconSize,
    this.listLeadingIconColor,
    this.listLeadingWidget,
    this.listLeadingIconPadding,
    this.trailingWidget,
    this.listTrailingIconSize,
    this.isReverseRotation,
    this.isCircular,
    this.isPass = false,
    this.listLeadingIcon,
    this.isSoftWrap = true,
    this.isImageAsset,
    this.toAddPad = false,
    this.isImageDividerVisible,
    this.isFilterLocPage,
    this.trailingIconBgColor,
    this.hideBorderColor,
    this.borderColor,
    this.showDashedDivider,
    this.leadingIconBgBorderRadius});

  @override
  Widget build(BuildContext context) {
    debugPrint("leadingIconBgBorderRadius: $leadingIconBgBorderRadius");
    return toOnTap(
      onTap: onTap,
      child: ConditionalParentWidget(
        condition: isCircular != null,
        parentBuilder: (child) =>
            CustomBorderContainer(
              borderColor: appColors.myTripsDividerColor,
              padding: pad(h: isPass ? 8 : 15),
              margin: pad(w: 20, h: 8),
              borderRadius: 30,
              body: child,
            ),
        child: [
          if (isImageAsset != null || toAddPad) 10.toHeight(),
          [
            if (isImageAsset != null) ...[
              !(isImageAsset!.contains('.png')) ?
              isImageAsset!.toSVG(
                size: 25,
              ) :   isImageAsset!.toPng(
                  height: 25, width: 25
              ),
              15.toWidth()
            ],
            if (isImageAsset != null) 10.toHeight(),
            if (listLeadingWidget != null)
              listLeadingWidget!
            else
              if (listLeadingIcon != null)
             _getListLeadingIconWidget(),
            Expanded(
                child: CustomText(
                  text: text,
                  fontWeight: fontWeight,
                  color: textColor,
                  size: size,
                )),
            trailingWidget != null
                ? trailingWidget!
                : listTrailingIcon != null
                ? ConditionalParentWidget(
              condition: isCircular != null,
              parentBuilder: (child) =>
                  CustomWishlistContainer(
                    padding: pad(a: 12),
                    color: appColors.myTripsBGColor,
                    body: child,
                  ),
              child: listTrailingIcon!.toSVG(
                  colour: listTrailingIconBGColor,
                  size: listTrailingIconSize,
                  isReverseRotation: isReverseRotation),
            )
                : const SizedBox.shrink()
          ].toRow(mainAxisSize: MainAxisSize.min),
          if (isImageAsset != null || toAddPad) 10.toHeight(),
          if (isImageDividerVisible != false && isCircular == null)
            (showDashedDivider ?? false)
                ? CustomDashDivider(
              height: 2,
              width: deviceWidth,
              dashWidth: 4,
              color: appColors.filterDividerColor,
              isCircle: false,
              dashHeight: 1,
            )
                : Divider(
                color: dividerColor ?? appColors.filterDividerColor,
                height: 1,
                thickness: 0.5)
                .toPad(vertical: 7 + (dividerSpacing ?? 0)),
        ]
            .toColumn(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start)
            .toPad( horizontal: horizontalpadding ?? (isImageAsset != null ? 15 : 25)),
      ),
    );
  }

  Widget _getListLeadingIconWidget() {
    return    isFilterLocPage != null && isFilterLocPage! ?

      Container(
        color: isFilterLocPage != null && isFilterLocPage!
            ? null
            : trailingIconBgColor ??
            appColors.explore_search_icon_bg,
        padding:
        listLeadingIconPadding !=null ? pad(a: listLeadingIconPadding) :
        pad(start:  10, end:  5, top:  10, bottom: 10),
        margin: pad(end: iconSpacing ?? 15, h: 2.5),
        child: listLeadingIcon!.toSVG(
            height: listLeadingIconSize ?? 20,
            fit: BoxFit.fitHeight,
            colour: listLeadingIconColor))

    :leadingIconBgBorderRadius != null ?
    CustomBorderContainer(
        borderRadius: leadingIconBgBorderRadius,
        color: isFilterLocPage != null && isFilterLocPage!
            ? null
            : trailingIconBgColor ??
            appColors.explore_search_icon_bg,
        padding:
        listLeadingIconPadding !=null ? pad(a: listLeadingIconPadding) :
        pad(start:  10, end:  5, top:  10, bottom: 10),
        margin: pad(end: iconSpacing ?? 15, h: 2.5),
        borderColor: (hideBorderColor ?? false)
            ? null
            : borderColor ?? appColors.explore_search_icon_bg,
        body: listLeadingIcon!.toSVG(
            height: listLeadingIconSize ?? 20,
            fit: BoxFit.fitHeight,
            colour: listLeadingIconColor)) :
    CustomCounterContainer(
        color: isFilterLocPage != null && isFilterLocPage!
            ? null
            : trailingIconBgColor ??
            appColors.explore_search_icon_bg,
        padding:
        listLeadingIconPadding !=null ? pad(a: listLeadingIconPadding) :
        pad(start:  10, end:  5, top:  10, bottom: 10),
        margin: pad(end: iconSpacing ?? 15, h: 2.5),
        borderColor: (hideBorderColor ?? false)
            ? null
            : borderColor ?? appColors.explore_search_icon_bg,
        body: listLeadingIcon!.toSVG(
            height: listLeadingIconSize ?? 20,
            fit: BoxFit.fitHeight,
            colour: listLeadingIconColor));
  }
}

Widget getNavigationBar({required String title,
  required GestureTapCallback onTap,
  required AppLayoutModel? applayoutModel,
  String? leadingIcon,
  String? trailingText,
  Color? trailIconColor,
  double? borderRadius,
  double? endArrowPadding,
  double? horizontalpadding,
  bool? isShowItemDivider,
  double? iconPadding,
  double? leadingIconSize,
  double? dividerSpacing,
  bool? isProfile,
  bool? isCurrencySymbolNeeded,
  EdgeInsetsGeometry? padding,
  bool? isResize = false})
{
  bool isShowItemBorder = false;
  bool isShowDashedDivider = false;
  Color? leadingIconBgColor,
      leadingIconBorderColor,
      trailingIconColor = appColors.secondaryColor,
      trailingIconBGColor;
  Color? trailingTextColor = trailIconColor ?? appColors.colorCommonLinkColor;
  bool isShowTrailingWidget = true;
  EdgeInsetsGeometry? itemMargin;
  if (isProfile ?? false) {
    trailingIconColor = appColors.black;
    isShowTrailingWidget = false;
  }
  double? arrowPad;
  double textpadding = 0;
  String? backIcon;
  double backIconSize = 38, arrowiconPadding = 10;
  double itemHeight = 61;

  switch (applayoutModel?.themeType) {
    case 1:
      if (!(isProfile ?? false)) {
        leadingIconBgColor = appColors.myTripsBGColor;
      }
      leadingIconBorderColor = appColors.myTripsDividerColor;
      iconPadding =7;
      horizontalpadding = 24;
      break;
    case 2:
      isShowTrailingWidget = true;
      leadingIconBgColor = appColors.theme4AppBarBg;
      arrowPad = 0;
      horizontalpadding = 24;
      break;
    case 3:
      isShowTrailingWidget = true;
      isShowItemDivider = false;
      isShowItemBorder = true;
      itemMargin = pad(w: AppDimen.startMargin, bottom: 13);
      trailingIconColor = appColors.black;
      trailingIconBGColor = appColors.myTripsBGColor;
      arrowPad = 10.0;
      textpadding = 18.0;
      backIconSize =  28;
      itemHeight = 52;
      arrowiconPadding = 7;
      backIcon = applayoutModel?.backIcon;
      break;
    case 4:
      leadingIconBgColor = appColors.theme4AppBarBg;
      isShowDashedDivider = true;
      horizontalpadding = 24;
      break;
  }
  if(endArrowPadding ==null && arrowPad !=null)
    endArrowPadding = arrowPad;

  CustomListItem customlistItem = CustomListItem(
    onTap: onTap,
    text: title,
    horizontalpadding: horizontalpadding,
    dividerSpacing: dividerSpacing,
    fontWeight: AppFont.regular,
    size: AppDimen.textSize_16,
    toAddPad: true,
    listLeadingWidget: leadingIcon != null
        ? _getIconWidget(
        iconSize: 18,
        iconPadding: iconPadding,
        icon: leadingIcon,
        size: leadingIconSize,
        leadingIconBgColor: leadingIconBgColor,
        leadingIconBorderColor: leadingIconBorderColor,
        borderRadius: borderRadius ?? 100
    ).toPad(end: 10, start: textpadding)
        : textpadding.toWidth(),
    trailingWidget: isShowTrailingWidget
        ?
    trailingText != null ? CustomText(
        text: trailingText,
        color: trailingTextColor,
        fontWeight: AppFont.regular,
        symbol: (isCurrencySymbolNeeded ?? true) ? selectedCurrencySymbol : null).toPad(end: textpadding) :
    _getIconWidget(
        icon:backIcon ?? Assets.viewcarsLeftArrow ,
        isreverserotation: true,
        padding: padding,
        iconColor: trailingIconColor,
        iconSize: 14,
        iconPadding:  arrowiconPadding,
        size: backIconSize,
        borderRadius: borderRadius ?? 100,
        leadingIconBgColor: trailingIconBGColor).toPad(end: endArrowPadding ?? 0)
        : null,
    isImageDividerVisible: isShowItemDivider,
    showDashedDivider: isShowDashedDivider,
  );

  return isShowItemBorder ? CustomBorderContainer(
    margin: itemMargin,
    height: isShowItemBorder ? itemHeight  : null,
    alignment: AlignmentDirectional.center,
    borderRadius: applayoutModel?.borderRadius,
    body: customlistItem,
  ) : Container(
    margin: itemMargin,
    height: isShowItemBorder ? itemHeight  : null,
    alignment: AlignmentDirectional.center,
    child: customlistItem,
  );
}

Widget _getIconWidget({String? icon,
  Color? leadingIconBgColor,
  Color? leadingIconBorderColor,
  bool? isreverserotation,
  Color? iconColor,
  double? borderRadius,
  double? iconPadding,
  EdgeInsetsGeometry? padding,
  double? size,
  double? iconSize}) {
  Widget svgIconWidget = (icon ?? '').toSVG(
      isReverseRotation: isreverserotation,
      colour: iconColor ?? appColors.black,
      size: iconSize ?? 20);
  return leadingIconBgColor != null
      ? CustomContainer(
          padding: padding ?? pad(a: iconPadding ?? 10),
          height:size?? 40,
    width: size??40,
    decoration: BoxDecoration(
        color: leadingIconBgColor,
        borderRadius: BorderRadius.circular(borderRadius ?? 100),
        border: Border.all(color: leadingIconBorderColor ?? Colors.transparent)
    ),
    body: svgIconWidget,
  ) : svgIconWidget;
}

class CustomCheckBoxListItem extends GetView {
  Widget? checkBox;
  Widget? iconWidget;
  String itemPropertyText;
  Widget? textWidget;
  double? fontSize;
  FontWeight? fontWeight;
  double? topPadding;
  Color? color;
  bool? isFlexible;
  bool? isCenter;

  CustomCheckBoxListItem({super.key,
    this.checkBox,
    this.iconWidget,
    this.textWidget,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.topPadding,
    this.isCenter,
    this.isFlexible,
    required this.itemPropertyText});

  @override
  Widget build(BuildContext context) {
    isFlexible ??= true;

    return IntrinsicHeight(
      child: [
        checkBox ?? const SizedBox.shrink(),
        iconWidget ?? const SizedBox.shrink(),
        iconWidget != null ? 6.toWidth() : const SizedBox.shrink(),
        textWidget ??
            CustomText(
              text: itemPropertyText.toString().trim(),
              fontWeight: fontWeight ?? FontWeight.normal,
              size: fontSize ?? AppDimen.textSize_16,
              color: color?? appColors.customTextColor,
            ).toPad(top: topPadding ?? 0).toStretch(isExpanded: false)

      ].toRow(
          mainAxisSize: isFlexible! ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: isCenter != null && isCenter!
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start),
    );
  }
}

Widget getuploadingWidget(String filepath) {
  if (filepath.toLowerCase().endsWith('.pdf') ||
      filepath.toLowerCase().endsWith('.doc') ||
      filepath.toLowerCase().endsWith('.docx')) {
    return CustomBorderContainer(
      width: deviceWidth,
      height: deviceHeight,
      borderWidth: 0,
      borderRadius: AppDimen.appBorderRadius,
      padding: pad(a: 30),
      color: appColors.popularLocationBottomShadowColor,
      body: Assets.drawablePdf.toSVG(),
    );
  }
  return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(AppDimen.appBorderRadius)),
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Image.file(
          File(filepath),
          width: deviceWidth,
          height: deviceHeight,
          fit: BoxFit.cover,
        ),
      ));
}

List<Widget> getImagePickerOptions({required controller,
  required Function([bool?]) onTap,
  required String isFrom,
  required RxString selectedImageOption,
  String? dividerType}) {
  debugPrint("getImagePickerOptions: ${selectedImageOption.value}");
  return [
    15.toHeight(),
    GetBuilder<BottomSheetController>(builder: (ctrl) {
      return _getImagePickerItem(
          title: isFrom == 'documentVerification'
              ? label_document.tr
              : label_camera.tr,
          icon: isFrom == 'documentVerification'
              ? Icons.file_copy_outlined
              : Icons.add_a_photo,
          selectedImageOption: selectedImageOption.value == label_camera.tr,
          onTap: () {
            selectedImageOption.value = label_camera.tr;
            if (isFrom == 'documentVerification') {
              onTap(false);
            } else {
              onBack();
              Get.to(() => CameraScreen(),
                  arguments: {"isFrom": isFrom, "controller": controller});
            }
          });
    }).toPad(horizontal: AppDimen.startMargin),
    GetBuilder<BottomSheetController>(builder: (ctrl) {
      return [
        15.toHeight(),
        if (dividerType == 'line')
          filterDivider
        else
          if (dividerType == 'dot')
            fullWidthDashDivider().toPad(horizontal: AppDimen.startMargin),
        15.toHeight()
      ].toColumn();
    }),
    GetBuilder<BottomSheetController>(builder: (ctrl) {
      return _getImagePickerItem(
          title: label_gallery.tr,
          selectedImageOption: selectedImageOption.value == label_gallery.tr,
          icon: Icons.camera,
          onTap: () {
            selectedImageOption.value = label_gallery.tr;
            if (isFrom == 'documentVerification') {
              onTap(true);
            } else {
              onTap();
            }
          });
    }).toPad(horizontal: AppDimen.startMargin),
  ];
}

Widget _getImagePickerItem({required bool selectedImageOption,
  required String title,
  required IconData icon,
  required VoidCallback onTap}) {
  return toOnTap(
    onTap: onTap,
    child: [
      Icon(
        icon,
        color: selectedImageOption
            ? appColors.secondaryColor
            : appColors.textColor,
        size: 22,
      ),
      10.toWidth(),
      CustomText(
        text: title,
        color: selectedImageOption
            ? appColors.secondaryColor
            : appColors.customTextColor,
        fontWeight: AppFont.regular,
      ).toStretch(),
      if (selectedImageOption)
        Assets.drawableViewdetailReportTick
            .toSVG(size: 10, colour: appColors.secondaryColor)
            .toPad(start: 8)
    ].toRow(mainAxisAlignment: MainAxisAlignment.start),
  );
}

Widget itemDetailSpecificationList({required String title,
  required List<Map<String, dynamic>> propertyInfoList,
  Color? textColor,
  bool? isShowMoreItems,
  Widget? showMoreWidget,
  String? indicatorIcon,
  double? indicatorIconPadding,
  double? dotSize,
  required BaseController controller,
  bool? isShowLeadingIcon}) {
  isShowMoreItems ??= false;
  if (propertyInfoList.isEmpty) {
    return const SizedBox.shrink();
  }

  debugPrint("propertlylist: $propertyInfoList");
  return GetBuilder<BottomSheetController>(
    builder: (newController) =>
        [
          if (!isShowMoreItems!)
            CustomTitleText(
              text:title,
              size:  AppDimen.textSize_18,
              fontWeight: AppFont.medium,
            ).toPad(bottom: 13,),
          for (var i = 0;
          !isShowMoreItems && propertyInfoList.length > 3
              ? i < 3
              : i < propertyInfoList.length;
          i++) ...[
            if (indicatorIcon != null)
              CustomCheckBoxListItem(
                  itemPropertyText: propertyInfoList[i]['itemPropertyText'],
                  color: textColor ?? appColors.customTextColor,
                  iconWidget: indicatorIcon == 'dotindicator'
                      ? CustomCounterContainer(
                    height: dotSize ?? 10,
                    width: dotSize ?? 10,
                    margin: pad(top: 5, end: 5),
                    color: appColors.customTextColor,
                  )
                      : propertyInfoList[i]['iconWidget'] != null &&
                      (propertyInfoList[i]['iconWidget'] is String)
                      ? propertyInfoList[i]['iconWidget'].toString().toSVG(
                      colour: appColors.black,
                      isReverseRotation: intl.Bidi.isRtlLanguage(
                          Get.locale?.languageCode)).toPad(top: 2.5) :
                  propertyInfoList[i]['iconWidget'] != null &&
                      (propertyInfoList[i]['iconWidget'] is Widget) ?
                  (propertyInfoList[i]['iconWidget'] as Widget)
                      .toPad(top: 4)
                      : (indicatorIcon)
                      .toSVG(size: 12, colour: appColors.black)
                      .toPad(end: indicatorIconPadding ?? 15, top: 4),
                  textWidget: (propertyInfoList[i]['itemPropertyHighlightText'] != null)
                      ? RichText(
                    text: TextSpan(
                      children: getTextSpans(
                        highlightWords: [propertyInfoList[i]['itemPropertyHighlightText']],
                        primaryText: propertyInfoList[i]['itemPropertyText'],
                        highlightColor: appColors.customTextColor,
                        fontWeight: AppFont.medium
                      ),
                      style: TextStyle(
                        fontFamily: AppFont.font,
                        color: appColors.customTextColor,
                        fontSize: AppDimen.textSize_16
                      ),
                    ),
                  ) : null,
                  fontSize: AppDimen.textSize_16)
            else
              if (propertyInfoList[i]['itemPropertyHighlightText'] != null)
                RichText(
                  text: TextSpan(
                    children: getTextSpans(
                        highlightWords: [
                          propertyInfoList[i]['itemPropertyHighlightText']
                        ],
                        primaryText: propertyInfoList[i]['itemPropertyText'],
                        highlightColor: appColors.customTextColor,
                        fontWeight: AppFont.medium),
                    style: TextStyle(
                        fontFamily: AppFont.font,
                        color: appColors.customTextColor,
                        fontSize: AppDimen.textSize_16),
                  ),
                )
              else
                CustomText(
                  text: propertyInfoList[i]['itemPropertyText'],
                  fontWeight: AppFont.regular,
                  size: AppDimen.textSize_16,
                ),
            isShowMoreItems ? 20.toHeight() : ((!isShowMoreItems && propertyInfoList.length > 3 && i == 2) || (!isShowMoreItems && propertyInfoList.length <= 3 && i == (propertyInfoList.length - 1))) ? 0.toHeight() : 10.toHeight()
          ],
          if (!isShowMoreItems &&
              propertyInfoList.length > 3 &&
              showMoreWidget != null)
            toOnTap(
                child: showMoreWidget,
                onTap: () {
                  showCustomBottomSheet(
                      contentWidget:
                      GetBuilder<BottomSheetController>(
                          builder: (newController)=>
                              itemDetailSpecificationList(
                                  title: title,
                                  propertyInfoList: propertyInfoList,
                                  isShowMoreItems: true,
                                  controller: controller)),
                      title: title,
                  );
                }
            ).toPad(top: 10),
        ].toScroll(
            physics: isShowMoreItems
                ? AlwaysScrollableScrollPhysics()
                : NeverScrollableScrollPhysics()),
  );
}

Widget hostInfoItem({dynamic hostItem,
  int? profileId,
  required BaseController controller,
  required Widget userReviewList,
  required String profileIconType,
  bool? isHost,
  String? title,
  GestureTapCallback? reportUseronTap,
  bool? isBackarrow,
  Color? ownerNameColor,
  bool? isNotEmptyUserReviews,
  double? borderRadius}) {
  String picture = '',
      firstName = '',
      location = '',
      createdAt = '',
      info = '',
      userId = '';
  bool isEmailConfirmed = false,
      isGoogleConnected = false,
      isPhoneVerified = false,
      isIdVerified = false;
  int reviewsCount = 0;
  dynamic fetchvalue, verificationfetch;

  if ((isHost ?? false) && (hostItem?.toJson().containsKey('profile') ?? false)) {
    fetchvalue = hostItem?.profile;
    verificationfetch = hostItem?.verification;
  } else {
    if (hostItem?.toJson()['authorData'] != null) {
      fetchvalue = hostItem?.authorData;
    } else {
      fetchvalue = hostItem;
    }
    Map<String, dynamic> fetchJson = {};
    try {
      fetchJson = fetchvalue?.toJson() ?? {};
    } catch (_) {}

    verificationfetch = fetchJson.containsKey('userVerification')
        ? fetchvalue?.userVerification
        : (fetchJson.containsKey('verification')
            ? (fetchvalue?.toJson().containsKey('verification') ?? false ? fetchvalue?.verification : null)
            : null);
    reviewsCount = fetchJson['reviewsCount'] ?? 0;
  }

  picture = fetchvalue?.picture ?? '';
  firstName = fetchvalue?.firstName ?? '';
  location = (fetchvalue?.toJson().containsKey('location') ?? false) ? (fetchvalue?.location ?? '') : '';
  createdAt = fetchvalue?.createdAt ?? '';
  userId = verificationfetch?.userId ?? '';
  isEmailConfirmed = verificationfetch?.isEmailConfirmed ?? false;
  isGoogleConnected = verificationfetch?.isGoogleConnected ?? false;
  isPhoneVerified = verificationfetch?.isPhoneVerified ?? false;
  isIdVerified = verificationfetch?.isIdVerification ?? false;
  info = fetchvalue?.info ?? '';

  Widget HostInfoHeader = [
    CustomTitleText(
      text: title ?? label_owner.tr,
      size: AppDimen.textSize_22,
    ),
    18.toHeight(),
    [
    CustomProfileNetworkImage(
      profileImageType: profileIconType,
    imageUrl: picture,
        all: 80,
      ),
      10.toWidth(),
      [
        CustomTitleText(
          text: firstName,
          size: AppDimen.textSize_18,
          color: ownerNameColor,
        ),
        CustomText(
            text:
            '${label_joined_in.tr} ${getDateFormat(
                milliSec: createdAt, dateFormat: userProfileCreateFormat).$1}',
            size: AppDimen.textSize_16,
            fontWeight: FontWeight.normal,
            color: appColors.textColor)
            .toPad(top: 2),
        if (location.isNotEmpty)
          CustomText(
            text: '${label_lives_in_the_city.tr}, $location',
            fontWeight: FontWeight.normal,
            size: AppDimen.textSize_16,
            overflow: TextOverflow.ellipsis,
            color: appColors.textColor,
          ).toPad(top: 2),
      ].toColumn().toStretch()
    ].toRow(mainAxisAlignment: MainAxisAlignment.start)
  ].toColumn();

  Widget aboutUser = info.isNotEmpty
      ? [
    CustomTitleText(
      text: about.tr,
    ).toPad(bottom: 13,),
    CustomText(
      text: info,
      size: AppDimen.textSize_14,
      fontWeight: AppFont.regular,
    ),
  ].toColumn()
      : 0.toHeight();

  debugPrint("reviewsCount: $isNotEmptyUserReviews");
  isNotEmptyUserReviews;
  Widget userReviewsUser = (isNotEmptyUserReviews ?? true)
      ? [
    CustomTitleText(
      text: label_review.trPlural(reviewPlural.tr, reviewsCount),
    ).toPad(bottom: 13,),

    userReviewList,
  ].toColumn()
      : 0.toHeight();

  Widget? userVeriifedInfo =
  (isEmailConfirmed || isGoogleConnected || isPhoneVerified || isIdVerified)
      ? [
    CustomTitleText(
      text: '${label_verified.tr} ${label_info.tr.toLowerCase()}',
    ).toPad(bottom: 13,),

    if (isEmailConfirmed)
      UserVerifiedInfo(
          isVerified: isEmailConfirmed,
          communicationIcon: Assets.drawableProfileEmailVerified,
          communicationType: label_login_email.tr,
          borderRadius: borderRadius).toPad(end: 1, start: 1),
    if (isGoogleConnected)
      UserVerifiedInfo(
          isVerified: isGoogleConnected,
          communicationIcon: Assets.drawableProfileGmailVerified,
          communicationType: label_gmail.tr,
          borderRadius: borderRadius)
          .toPad(top: 10,end: 1, start: 1),
    if (isPhoneVerified)
      UserVerifiedInfo(
          isVerified: isPhoneVerified,
          communicationIcon: Assets.drawableProfilePhoneVerified,
          communicationType: label_phone_number.tr,
          borderRadius: borderRadius)
          .toPad(top: 10,end: 1, start: 1),
    if (isIdVerified)
      UserVerifiedInfo(
          isVerified: isIdVerified,
          communicationIcon: Assets.drawableDocumentVerify,
          communicationType: label_document.tr,
          borderRadius: borderRadius)
          .toPad(top: 10,end: 1, start: 1, bottom: 12),
  ].toColumn()
      : null;

  Widget reportUserInfo = [

    CustomTitleText(
      text: label_report.tr,
    ).toPad(bottom: 13,),

    [
    CustomText(
      text: '${label_report_this.tr} ${label_user.tr.toLowerCase()}',
      color: appColors.secondaryColor,
      size: AppDimen.textSize_14,
      fontWeight: FontWeight.normal,
      onTap: reportUseronTap,
    ),
      3.toWidth(),
      if ((appLayoutMap[AppLayout.viewCar]?.themeType == 1))
        Assets.drawableRightArrow
            .toSVG(size: 10, colour: appColors.secondaryColor)
    ].toRow(mainAxisAlignment: MainAxisAlignment.start)
  ].toColumn().toPad(bottom: AppDimen.startMargin);
  overALLThemeType;
  double _dividerPadding = (appLayoutMap[AppLayout.viewCar]?.themeType == 4)
      ? 0.0
      : AppDimen.startMargin;
  // .toPad(horizontal: AppDimen.startMargin, top: Get.height * 0.1).toResizeWidget(width: Get.width)
  List<Widget> ListItemWidgets = [];
  ListItemWidgets.add(HostInfoHeader);
  if(info.isNotEmpty)
  ListItemWidgets.add(aboutUser);
  if (isNotEmptyUserReviews ?? true) {
    ListItemWidgets.add(userReviewsUser);
  }
  if(userVeriifedInfo != null) {
    ListItemWidgets.add(userVeriifedInfo.toPad(
        bottom: userId != controller.appPreference.userID ? 0 : 20));
  }
  if (userId != controller.appPreference.userID) {
    ListItemWidgets.add(reportUserInfo);
  }

  bool isTheme4 = appLayoutMap[AppLayout.viewCar]?.themeType == 4;

  return Obx(() =>
  controller.isLoading.value && isShowLoader
      ? Center(
      child: controller
          .getLoader(
          loader: LottieLoaders.three_dots_loader.name,
          changed: appThemeChanged.value,
          color: appColors.secondaryColor)
          .toResizeWidget(all: 120))
      : isTheme4
        ? toListScroll(WidgetList: ListItemWidgets.map(
            (w) => w.toPad(horizontal: AppDimen.startMargin)).toList(), isRemoveDivider: false, horizontalPad: _dividerPadding)
        : toListScroll(WidgetList: ListItemWidgets, isRemoveDivider: false, horizontalPad: _dividerPadding).toPad(horizontal: AppDimen.startMargin));
}
Widget commonReviewSectionItem({
  required int index,
  required List<dynamic>? itemReviews,
  int? count,
  int? maxLines,
  Function? showMoreOnTap,
  bool? isVertical,
  required Function(dynamic hostItem) onSelectedHost,
}) {
  dynamic itemReviewsInfo = itemReviews?[index];

  return reviewListItem(
    itemReviewsInfo: itemReviewsInfo,
    maxLines: maxLines,
    showMoreOnTap: showMoreOnTap,
    width: count != null ? (deviceWidth - 110) : (isVertical ?? false) ? deviceWidth : deviceWidth - 80,
    onSelectedHost: onSelectedHost,
  );
}