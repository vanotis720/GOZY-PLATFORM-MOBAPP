import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/app.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_colors.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/resources/app_layout.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/screens/views/guest/wishlist/wishlist_group_item/wishlist_group_item.dart';
import 'package:gozy/screens/views/guest/wishlist/wishlist_modify_controller.dart';
import 'package:gozy/screens/views/home/home_controller.dart';
import 'package:gozy/widgets/common/custom_network_image/custom_clip_network_image.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/conditional_parent_widget.dart';
import 'package:gozy/widgets/custom_empty_view.dart';
import 'package:gozy/widgets/custom_stateful_widget.dart';
import 'package:gozy/widgets/custom_text.dart';
import 'package:gozy/widgets/shimmer.dart';

class GuestWishlistScreen extends CustomStatefulWidget {
  const GuestWishlistScreen({super.key});

  @override
  GuestWishlistScreenState createState() => GuestWishlistScreenState();
}

class GuestWishlistScreenState extends CustomStatefulWidgetState<GuestWishlistScreen>
    with TickerProviderStateMixin {
  late WishlistModifyController wishlistcontroller = Get.find();
  static AppLayoutModel? wishlistLayout = appLayoutMap[AppLayout.wishlist];

  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    isShowLoader = false;
    wishlistcontroller.wishlistViewAnimation =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: wishlistcontroller.wishlistViewAnimation,
        curve: Curves.easeOut,
      ),
    );
    wishlistcontroller.isBottomSheetOpen = false;
    wishlistcontroller.isLoading.value = true;
    wishlistcontroller.wishlistGroupScrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onRefresh();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: wishlistcontroller,
        id: "viewScreen",
        builder: (context) {
          return CustomScaffold(
              controller: wishlistcontroller,
              isShowAppBar: false,
              backIcon: null,
              title: wishlistLayout?.wishlistTitle.tr,
              body: [
                showBodyContentWidget(initThemeTypeData()),
                !wishlistcontroller.isViewScreen.value
                    ? 0.toHeight()
                    : SlideTransition(
                        position: _slideAnimation,
                        child: WishlistGroupItemScreen(
                          wishlistcontroller: wishlistcontroller,
                        )),
              ].toStack());
        });
  }

  String initThemeTypeData() {
    switch (wishlistLayout?.themeType) {
      case 1:
        return "gridView";
      case 2:
        return "column";
      case 3:
        return "stack";
      default:
        return "row";
    }
  }

  Widget showBodyContentWidget(String wishlistItemType) {
    return Obx(() {
      wishlistcontroller.wishlistGroupScrollController = ScrollController();
      wishlistcontroller.isLoadAllItems = false;
      return toReviewList(
        reviewListScrollController: wishlistcontroller.wishlistGroupScrollController,
        reviewList: wishlistcontroller.allWishListGroupList,
        reviewsCount: wishlistcontroller.overallWishlistCount,
        onApiFunction: wishlistcontroller.getAllWishlistWithGroup,
        bottomPosition: bottomPadForExtendBody,
        controller: wishlistcontroller,
        currentPage: wishlistcontroller.wishlistCurrentpage,
        isDisableLoader: true,
        emptyWidget: Center(
          child: CustomEmptyView(
            imagePath: Assets.drawableWishlistEmpty,
            emptyDescription: label_empty_wishlist_not_added.tr,
            buttonText: wishlistLayout?.wishlistTitle.tr ?? "",
            onTap: () {
              HomeController controller = Get.find();
              controller.change(rxVariable: controller.rxSelectedTab, value: 0);
            },
          ),
        ).toPad(top: 50),
        listView: showWishlists(wishlistItemType),
      ).toShimmer(controller: wishlistcontroller);
    });
  }

  Future<Null> onRefresh() async {
    wishlistcontroller.wishlistCurrentpage.value = 1;
    wishlistcontroller.allWishListGroupList.clear();
    wishlistcontroller.isLoading.value = true;
    wishlistcontroller.checkNetwork(wishlistcontroller.getAllWishlistWithGroup);
  }

  @override
  void dispose() {
    wishlistcontroller.allWishListGroupList.clear();
    wishlistcontroller.wishlistViewAnimation.dispose();
    super.dispose();
  }

  Widget showWishlists(String wishlistItemType) {
    double itemWidth = ((deviceWidth - (3 * AppDimen.startMargin)) / 2) + 7;
    if (wishlistItemType == "gridView") {
      return showGridWishlistGroupWidget(itemWidth);
    } else {
      return showWishlistTileWidget(itemWidth, wishlistItemType);
    }
  }

  Widget showGridWishlistGroupWidget(double itemWidth) {
    var data = _getCountAndLoadingStatus();
    bool isshimmerloading = data.$1;
    int count = data.$2;

    return <Widget>[
      CustomTitleText(
        text: wishlistLayout?.wishlistTitle.tr ?? "",
        fontWeight: AppFont.semiBold,
        size: AppDimen.textSize_26,
      ).toPad(top: AppDimen.startMargin, horizontal: AppDimen.startMargin, bottom: 18),
      toGridView(
        itemCount: count,
        itemSize: 130,
        baseController: wishlistcontroller,
        crossAxisSpacing: 20,
        mainAxisSpacing: 10,
        scrollController: wishlistcontroller.wishlistGroupScrollController,
        physics: AlwaysScrollableScrollPhysics(),
        padding: pad(w: AppDimen.startMargin, bottom: 25 + bottomViewPadding + bottomPadForExtendBody),
        itemBuilder: (BuildContext context, int index) {
          Map<String, dynamic>? item;
          String image = '';
          if (wishlistcontroller.allWishListGroupList.isNotEmpty &&
              index < wishlistcontroller.allWishListGroupList.length) {
            item = wishlistcontroller.allWishListGroupList[index];
            if (wishlistcontroller.allWishListGroupList[index]["wishListCover"] != null) {
              image = imgListingMedium + (item['wishListCover']?['listData']?['listPhotoName'] ?? '');
            }
          }
          return item?['isdelete'] == null
              ? toOnTap(
                  onTap: () {
                    if (!(wishlistcontroller.isLoading.value) && item != null) {
                      wishlistcontroller.wishlistGroupItemList.clear();
                      wishlistcontroller.wishListGroupId = item['id'];
                      wishlistcontroller.argumentGroupId = item['id'];
                      wishlistcontroller.allWishListGroupList = wishlistcontroller.allWishListGroupList;
                      wishlistcontroller.isViewScreen.value = true;
                      wishlistcontroller.update(["viewScreen"]);
                      wishlistcontroller.wishlistViewAnimation.forward();
                    }
                  },
                  child: [
                    [
                      ShimmerLoading(
                          isLoading: isshimmerloading,
                          widgetType: 'Wishlistlist',
                          isDarkMode: wishlistcontroller.isDarkMode(),
                          child: CustomClipNetworkImage(
                            imageUrl: image,
                            width: double.infinity,
                            borderRadius: BorderRadius.all(
                                Radius.circular(wishlistLayout?.borderRadius ?? AppDimen.appBorderRadius)),
                            height: 90,
                            isShimmerView: isshimmerloading,
                            placeholderURL: image.replaceAll('x_medium_', 'small_'),
                          )),
                      (isshimmerloading
                              ? Assets.drawableAboutHost.toSVG(size: 40, colour: AppColors.wishListTyreColor)
                              : item?['wishListCount'] == 0
                                  ? Assets.drawableAboutHost
                                      .toSVG(size: 40, colour: AppColors.wishListTyreColor)
                                  : const SizedBox.shrink())
                          .toPositionedAlign(alignment: AlignmentDirectional.center),
                    ].toStack().toPad(bottom: 10),
                    getTitleWidget(isLoading: isshimmerloading, itemWidth: itemWidth, item: item),
                  ].toColumn(),
                )
              : const SizedBox.shrink();
        },
      ).toStretch(),
    ].toColumn();
  }

  Widget showWishlistTileWidget(double itemWidth, String wishlistItemType) {
    var data = _getCountAndLoadingStatus();
    bool isshimmerloading = data.$1;
    int count = data.$2;

    Color? textColor = appColors.customTextColor;
    MainAxisAlignment? titleMainAxisAlignment;
    CrossAxisAlignment? layoutCrossAlignment;
    double imageHeight = 175;
    double imageWidth = double.infinity;
    if (wishlistItemType == 'stack') {
      textColor = AppColors.staticwhite;
      titleMainAxisAlignment = MainAxisAlignment.center;
    } else if (wishlistItemType == 'row') {
      imageHeight = 60;
      imageWidth = 80;
      layoutCrossAlignment = CrossAxisAlignment.center;
    }

    Widget listViewWidget = const SizedBox.shrink();
    listViewWidget = <Widget>[
      App().showAppbar(context,
          AppbarTitle: wishlistLayout?.wishlistTitle.tr,
          appBarSize: 70,
          appBartextFontSize: AppDimen.textSize_26,
          appBarTextFontWeight: AppFont.semiBold,
          AppBarbgColor: appColors.white),
      toListView(
          itemCount: count,
          shrinkWrap: true,
          key: const PageStorageKey<String>('wishlistitemlist'),
          physics: const AlwaysScrollableScrollPhysics(),
          controller: wishlistcontroller.wishlistGroupScrollController,
          itemBuilder: (context, index) {
            Map<String, dynamic>? item;
            String image = '';
            if (wishlistcontroller.allWishListGroupList.isNotEmpty &&
                index < wishlistcontroller.allWishListGroupList.length) {
              item = wishlistcontroller.allWishListGroupList[index];
              if (wishlistcontroller.allWishListGroupList[index]["wishListCover"] != null) {
                image = imgListingMedium + (item['wishListCover']?['listData']?['listPhotoName'] ?? '');
              }
            }

            Widget imageWidget = [
              ShimmerLoading(
                isLoading: isshimmerloading,
                widgetType: 'Wishlistlist',
                isDarkMode: wishlistcontroller.isDarkMode(),
                child: CustomClipNetworkImage(
                  imageUrl: image,
                  width: imageWidth,
                  height: imageHeight,
                  isShimmerView: isshimmerloading,
                  placeholderURL: image.replaceAll('x_medium_', 'small_'),
                  borderRadius: BorderRadius.all(
                      Radius.circular(wishlistLayout?.borderRadius ?? AppDimen.appBorderRadius)),
                ),
              ),
              if (isshimmerloading || (item != null && item['wishListCount'] == 0))
                Assets.drawableAboutHost
                    .toSVG(size: wishlistItemType == 'row' ? 30 : 40, colour: AppColors.wishListTyreColor)
                    .toPositionedAlign(alignment: AlignmentDirectional.center)
            ].toStack();

            Widget titleWidget = getTitleWidget(
                    isLoading: isshimmerloading,
                    itemWidth: itemWidth,
                    item: item,
                    mainAxisAlignment: titleMainAxisAlignment,
                    textColor: textColor,
                    fontWeight: wishlistItemType == 'stack' ? AppFont.semiBold : AppFont.regular,
                    size: AppDimen.textSize_16,
                    wishlistItemType: wishlistItemType)
                .toPad(bottom: 10, top: 10, start: wishlistItemType == "column" ? 0 : 10);

            return item?['isdelete'] == null
                ? toOnTap(
                    onTap: () {
                      if (!(wishlistcontroller.isLoading.value) && item != null) {
                        wishlistcontroller.wishlistGroupItemList.clear();
                        wishlistcontroller.wishListGroupId = item['id'];
                        wishlistcontroller.argumentGroupId = item['id'];
                        wishlistcontroller.allWishListGroupList = wishlistcontroller.allWishListGroupList;
                        wishlistcontroller.isViewScreen.value = true;
                        wishlistcontroller.update(["viewScreen"]);
                        wishlistcontroller.wishlistViewAnimation.forward();
                      }
                    },
                    child: ConditionalParentWidget(
                      condition: wishlistItemType == 'row' && index != count - 1,
                      parentBuilder: (child) => [
                        child,
                        filterDivider.toResizeWidget(width: deviceWidth - 50),
                        20.toHeight()
                      ].toColumn(crossAxisAlignment: CrossAxisAlignment.center),
                      child: [
                        if (wishlistItemType == 'stack')
                          imageWidget.toLinearGradientShaderMask(
                              shaderborderRadius: wishlistLayout?.borderRadius ?? 0,
                              colors: [Colors.transparent, Colors.black])
                        else
                          imageWidget,
                        if (wishlistItemType == 'stack')
                          titleWidget.toPositionedAlign(alignment: AlignmentDirectional.bottomCenter)
                        else
                          titleWidget
                      ]
                          .toFlexWidget(
                              widgetType: wishlistItemType,
                              crossAxisAlignment: layoutCrossAlignment ?? CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start)
                          .toPad(
                              horizontal: AppDimen.startMargin,
                              bottom: wishlistItemType == 'column' ? 10 : 20),
                    ),
                  )
                : const SizedBox.shrink();
          }).toStretch()
    ].toColumn();
    return listViewWidget;
  }

  Widget getTitleWidget(
      {bool? isLoading,
      double? itemWidth,
      Map<String, dynamic>? item,
      MainAxisAlignment? mainAxisAlignment,
      Color? textColor,
      FontWeight? fontWeight,
      double? size,
      String? wishlistItemType}) {
    return ShimmerLoading(
      isLoading: isLoading ?? false,
      widgetType: 'WishlistlistTitle',
      isDarkMode: wishlistcontroller.isDarkMode(),
      child: [
        ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: itemWidth! - 40,
            ),
            child: CustomText(
              shimmerColor: wishlistItemType == "stack" ? Colors.white38 : null,
              text: (isLoading ?? false)
                  ? 40.toGenerateEmptyString()
                  : item?['name'] != null
                      ? '${item?['name']} '
                      : 'tabbar_saved.tr',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              isShimmerView: isLoading ?? false,
              size: size ?? AppDimen.textSize_14,
              color: textColor,
              fontWeight: fontWeight,
            )),
        CustomText(
          text: item?['wishListCount'] != null ? '(${item?['wishListCount']})' : '',
          size: size ?? AppDimen.textSize_14,
          color: textColor,
          fontWeight: fontWeight,
        )
      ].toRow(mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start),
    );
  }

  (bool, int) _getCountAndLoadingStatus() {
    int count = 8;
    bool isshimmerloading = wishlistcontroller.isLoading.value &&
        wishlistcontroller.wishlistCurrentpage.value == 1 &&
        wishlistcontroller.allWishListGroupList.isEmpty;

    if (isshimmerloading) {
      count = 8;
    } else {
      count = wishlistcontroller.allWishListGroupList.length;
      int removingitems = wishlistcontroller.appendEmptyItemAtEnd();
      count = count - removingitems;
    }
    return (isshimmerloading, count);
  }
}