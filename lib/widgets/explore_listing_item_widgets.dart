import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:gozy/constant.dart";
import "package:gozy/generated/assets.dart";
import "package:gozy/graphql/__generated__/base_listing_info_fragment.data.gql.dart";
import "package:gozy/resources/app_dimen.dart";
import "package:gozy/resources/app_font.dart";
import "package:gozy/resources/app_lang.dart";
import "package:gozy/screens/views/base_controller.dart";
import "package:gozy/widgets/common/custom_container/custom_border_container.dart";
import "package:gozy/widgets/common/custom_container/custom_counter_container.dart";
import "package:gozy/widgets/common/custom_text/custom_showmore_text.dart";
import "package:gozy/widgets/smooth_page_indicator.dart";
import "common_extension_functions.dart";
import "conditional_parent_widget.dart";
import "common/custom_container/custom_container.dart";
import "custom_text.dart";
import "explore_list_item.dart";

Widget scrollingDotWidget(
    {PageController? controller, int? count, double? height}) {
  return count != null && count > 1
      ? Align(
    alignment: AlignmentDirectional.topCenter,
    child: SmoothPageIndicator(
      controller: controller!,
      count: count,
      itemWidth: deviceWidth,
      effect: getScrollingDotEffect(dotColor: appColors.black),
    ).toPad(top: (height ?? 195) - 20),
  )
      : const SizedBox.shrink();
}

Widget getRatingTextView({
  dynamic rating,
  String? reviews,
  double? size,
  String? icon,
  bool isShowIcon = true,
  Color? iconColor,
  Color? theme3IconColor,
  Color? ratingColor,
  Color? textColor,
  FontWeight? reviewFontWeight,
  double? dotSize,
  double? iconSize,
  int? maxLines,
  double? dotBottomPadding,
}) {
  dotSize ??= 10;

  final textStyle = TextStyle(
    color: textColor ?? appColors.white,
    fontSize: size ?? AppDimen.textSize_16,
    fontWeight: reviewFontWeight ?? AppFont.medium,
    fontFamily: AppFont.font,
  );

  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [

      Flexible(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            if (isShowIcon)
              (icon ?? ((overALLThemeType==3) ? Assets.theme3Star : Assets.drawableListingRating)).toSVG(
                size: (iconSize ?? AppDimen.textSize_12) - 1,
                colour: (overALLThemeType==3) ? theme3IconColor ?? appColors.black : iconColor,
              ).toPad(horizontal: 2),

            Flexible(
              child: Text(
                '$rating',
                maxLines: maxLines ?? 1,
                overflow: TextOverflow.ellipsis,
                style: textStyle.copyWith(
                  color: ratingColor,
                  fontFamily: AppFont.font,
                  fontSize: size ?? AppDimen.textSize_14,
                ),
              ),
            ),

            if (dotSize != 0)
              CustomCounterContainer(
                margin: pad(
                    w: dotSize / 2),
                height: dotSize,
                width: dotSize,
                color: appColors.customTextColor,
              ),
          ],
        ),
      ),

      if (reviews != null)
        Text(
          reviews,
          style: textStyle,
          maxLines: 1,
          overflow: TextOverflow.visible,
        ),
    ],
  );
}

Widget getRecommandedItem(
    {required var listing_data,
      required double itemWidth,
      required int themeType,
      required double borderRadius,
      required   String? instantBookIcon,
      double? itemHeight,
      double? listpriceHeight,
      String? type,
      Function(dynamic)? onListDetailTap,
      bool? isshimmerview,
      String? currencySymbol,
      GestureTapCallback? onTaponWishlist,
      VoidCallback? onitemClick,
      BaseController? controller}) {
  var recommendResults = listing_data;
  if (recommendResults != null) {

    GviewListingShortFragmentData? recommendCacheResult = controller?.getShortListingFragmentData(id: recommendResults?.id).$1;

    if (recommendCacheResult != null) {
      bool wishliststatus = recommendCacheResult.wishListStatus ?? false;
      if (wishliststatus) {
        wishlistedIds.add(recommendCacheResult.id ?? 1);
      } else {
        wishlistedIds.remove(recommendCacheResult.id ?? 1);
      }
      recommendResults = recommendCacheResult;
    }
  }
  debugPrint("recommend_results: ${recommendResults?.listPhotoName}");

  late String coverPhoto = '';
  if (recommendResults != null &&
      recommendResults.listPhotoName != null &&
      recommendResults.listPhotoName!.isNotEmpty) {
    coverPhoto = imgListingMedium + recommendResults.listPhotoName!;
  }

  String baseprice = '0';
  if (recommendResults != null && recommendResults.listingData != null) {
    baseprice = double.parse(
        recommendResults?.listingData?.basePrice?.toString() ?? '0')
        .currencyConverted(
        convertedCurrency:
        recommendResults?.listingData?.currency ?? defaultCurrency);
  }
  String listingTitle = '';
  String listingCarType = '';
  listingTitle = recommendResults?.title ?? '';
  listingCarType = recommendResults?.carType ?? 'Car';


  return toOnTap(
    onTap: () {
      if (onListDetailTap != null) {
        onListDetailTap(recommendResults);
      } else if (onitemClick != null) onitemClick();
    },
    child: ListingItem(
      id: recommendResults != null ? recommendResults.id : 0,
      hostId: recommendResults != null ? recommendResults.userId : '',
      listingWidth: itemWidth,
      coverPhoto: coverPhoto,
      themeType: themeType,
      instantBookIcon:instantBookIcon,
      borderRadius: borderRadius,
      isshimmerview: isshimmerview,
      wishListStatus:
      recommendResults != null ? recommendResults.wishListStatus : false,
      isListOwner:
      recommendResults != null ? recommendResults.isListOwner : false,
      basePrice: baseprice,
      transmission: recommendResults != null
          ? (recommendResults.transmission ?? "")
          : "",
      listingHeight: itemHeight,
      listingType: type,
      controller: controller,

      onTaponWishlist: onTaponWishlist,
      listPhotos: recommendResults?.listPhotos?.toList(),
      listingPriceTextSize: listpriceHeight,
      roomType: listingCarType,
      currencySymbol: currencySymbol,
      itemInfo: recommendResults,
      reviewsStarRating: recommendResults != null
          ? (recommendResults.reviewsStarRating ?? 0)
          : 0,
      reviewsCount:
      recommendResults != null ? recommendResults.reviewsCount : 1,
      title: listingTitle,
      bookingType:
      recommendResults != null ? recommendResults.bookingType : '',
    ),
  );
}

Widget carTypeIconTitleView({String? icon,  required String title, bool isShowDot = false,isShowAsChip = false, double? maxWidth,double? borderRadius, bool? isshimmerview, double? fontSize, double? iconSize}){
  return ConditionalParentWidget(
    condition: isShowAsChip,
    parentBuilder: (Widget child) =>
        CustomBorderContainer(
            color: appColors.myTripsBGColor,
            borderRadius: borderRadius,
            padding: pad(h: 5,w: 10),
            body: child),
    child: CustomContainer(
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? 1000
      ),
      body: [
        if(isShowDot)
          CustomContainer(
            height: 4,
            margin: pad(end:7),
            width: 4,
            decoration: BoxDecoration(shape: BoxShape.circle, color: appColors.black),
          ),

          if(icon !=null && !(isshimmerview ?? false))
            icon.toSVG(colour: appColors.customTextColor,size: iconSize ?? 10).toPad(end:5),

        CustomText(
          text: !(isshimmerview ?? false) ? title : 30.toGenerateEmptyString(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          size: fontSize ?? AppDimen.textSize_14,
          fontWeight: AppFont.regular,
          color: appColors.textColor,
          isShimmerView: isshimmerview
        ).toStretch(isExpanded: false)
      ].toRow(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.start),
    ),
  );
}


List<Widget> ConfirmPayListingHeaderWidget(
    {required dynamic itemInfo,
    String? listTitle,
    bool? isOrderChangeVar,
    bool? showDotForCarType,
    bool isChipView = false,
    bool isShowMoreCar = false,
    bool isShow = false,
    Color? ratingColor,
    dynamic sizeOfSvg,
    String? ratingIcon,
    Function()? showMoreCarOnTap}) {
  Widget titleWidget = CustomText(
    text: listTitle ?? itemInfo.title,
    maxLines: 1,
    fontWeight: AppFont.regular,
    size: AppDimen.textSize_16,
    overflow: TextOverflow.ellipsis,
    color: appColors.customTextColor
  );

  Widget ratingview =  (itemInfo.reviewsStarRating != null && itemInfo.reviewsStarRating > 0) ?
  getRatingTextView(rating: (itemInfo.reviewsStarRating / itemInfo.reviewsCount).toStringAsFixed(0),dotSize:0, ratingColor: ratingColor, icon: ratingIcon) : 0.toHeight();
  Widget carTypeWidget;
  String transmissionValue = itemInfo.transmission == "1" ? label_automatic.tr : label_manual.tr;
  String? roomType = itemInfo.carType;
  String? cartypeicon,transmissionicon;
  Widget showMoreCarWidget;
  bool transmissionDot = true;
  bool isOrderChange = false;
  if(overALLThemeType ==1) {
    cartypeicon =  Assets.theme1CarIcon;
    isOrderChange = true;
  }  else if(overALLThemeType ==2){
    isOrderChange = true;
  }  else if(overALLThemeType ==3){
    cartypeicon = Assets.theme3CarType;
    transmissionicon = Assets.theme3Transmission;
  }else if(overALLThemeType ==4){
    cartypeicon = Assets.theme4ExploreCartype;
    transmissionDot = false;
    transmissionicon = Assets.viewcarsViewcarTransmission;
  }
  isOrderChange = isOrderChangeVar ?? isOrderChange;
  carTypeWidget = [
    if(roomType != null)...[
      if(cartypeicon != null && !isChipView)...[
        cartypeicon.toSVG(colour: appColors.black),
        5.toWidth()
      ],
      if (!isChipView)
        Flexible(
          fit: FlexFit.loose,
          child: CustomText(
            text: roomType,
            fontWeight: AppFont.regular,
            overflow: TextOverflow.ellipsis,
            size: AppDimen.textSize_12,
          ),
        ),
      if(isChipView && cartypeicon != null)
        Flexible(
          fit: FlexFit.loose,
          child: IntrinsicWidth(
            child: CustomContainer(
              constraints: BoxConstraints(maxWidth: Get.width*0.35),
              decoration: BoxDecoration(
                  color: appColors.white,
                  borderRadius: BorderRadius.circular(30)
              ),
              padding: pad(start:8,end: 12, h: 5),
              body: [
                cartypeicon.toSVG(colour: appColors.black, size: 14),
                5.toWidth(),
                Flexible(child: CustomText(text: roomType, fontWeight: AppFont.regular, size: AppDimen.textSize_12, overflow: TextOverflow.ellipsis, maxLines: 1))
              ].toRow(mainAxisAlignment: MainAxisAlignment.start),
            ),
          ),
        )
    ],
    5.toWidth(),
    if(showDotForCarType ?? false)...[
      CustomContainer(
        height: 5,
        width: 5,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: appColors.black
        ),
      ).toPad(top: 2),
      5.toWidth()
    ],
    if(transmissionicon != null && !isChipView)...[
      transmissionicon.toSVG(colour: appColors.black, size: 13),
      5.toWidth()
    ],
    if(!isChipView)
      CustomText(text: transmissionValue,
        fontWeight: AppFont.regular,
        size: AppDimen.textSize_12,
      ),
    if(isChipView && transmissionicon != null)
      Flexible(
        fit: FlexFit.loose,
        child: IntrinsicWidth(
          child: CustomContainer(
            constraints: BoxConstraints(maxWidth: Get.width*0.35),
            decoration: BoxDecoration(
                color: appColors.white,
                borderRadius: BorderRadius.circular(30)
            ),
            padding: pad(start:8,end: 12, h: 5),
            body: [
              transmissionicon.toSVG(colour: appColors.black, size: 14),
              5.toWidth(),
              Flexible(
                child: CustomText(
                  text: transmissionValue,
                  size: AppDimen.textSize_12,
                  fontWeight: AppFont.regular,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ].toRow(mainAxisAlignment: MainAxisAlignment.start),
          ),
        ),
      )
  ].toRow(mainAxisAlignment: MainAxisAlignment.start);
  showMoreCarWidget = isShowMoreCar ?
  CustomShowMoreText(text: label_more_cars.tr,
    showMoreIconsSize:10,
    color: appColors.secondaryColor,
    quarterTurns: 3,
    onTap: showMoreCarOnTap,
      showMoreIconTopPadding: 3) : 0.toHeight();
  return [
    isOrderChange ? carTypeWidget : titleWidget,
    4.toHeight(),
    isOrderChange ? titleWidget : carTypeWidget,
    4.toHeight(),
    ratingview,
    showMoreCarWidget
  ];
}