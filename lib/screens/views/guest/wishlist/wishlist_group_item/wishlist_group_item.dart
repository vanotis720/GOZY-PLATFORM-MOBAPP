import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/resources/app_layout.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/screens/views/guest/wishlist/wishlist_modify_controller.dart';
import 'package:gozy/screens/views/home/home_controller.dart';
import 'package:gozy/screens/views/home/home_navigator.dart';
import 'package:gozy/widgets/common/custom_bottomsheet/custom_bottomsheet.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_stateful_widget.dart';
import 'package:gozy/widgets/custom_text.dart';
import 'package:gozy/widgets/explore_listing_item_widgets.dart';
import 'package:gozy/widgets/shimmer.dart';

import '../../../../../resources/app_colors.dart';
import '../../../../../widgets/bottom_sheet/bottom_sheet_refresh_controller.dart';
import '../../../../../widgets/common/custom_dialog/custom_dialog.dart';
import '../../../../../widgets/wishlist_modification_sheet.dart';

class WishlistGroupItemScreen extends CustomStatefulWidget {
  WishlistModifyController? wishlistcontroller;

  WishlistGroupItemScreen({super.key, this.wishlistcontroller});

  @override
  WishlistGroupItemScreenState createState() => WishlistGroupItemScreenState();
}

class WishlistGroupItemScreenState extends CustomStatefulWidgetState<WishlistGroupItemScreen>
    with TickerProviderStateMixin {
  late WishlistModifyController wishlistcontroller;
  int? TitlenumberOfLines;
  RxString wishListGroupName = ''.obs;
  String wishlistEditIcon = '';
  String wishlistDeleteIcon = '';
  static AppLayoutModel? wishlistLayout;
  Color? iconColor;

  @override
  void initState() {
    wishlistcontroller = widget.wishlistcontroller ?? Get.find();
    wishlistLayout = appLayoutMap[AppLayout.wishlist];

    ever(wishlistcontroller.updatedGroupName, (value) {
      debugPrint("ismounted: $mounted");
      wishListGroupName.value = value;
      _getTitleLines();
    });

    super.initState();
  }

  void initThemeType() {
    wishlistDeleteIcon = wishlistLayout?.deleteAccountIcon ?? '';
    iconColor = appColors.secondaryColor;
    switch (wishlistLayout?.themeType) {
      case 1:
        wishlistEditIcon = Assets.theme1WishlistEdit;
      case 2:
        wishlistEditIcon = Assets.theme2WishlistEdit;
      case 3:
        wishlistEditIcon = Assets.theme3WishlistEdit;
        iconColor = AppColors.staticblack;
      case 4:
        wishlistEditIcon = Assets.theme4WishlistEdit;
      default:
        wishlistEditIcon = Assets.theme1WishlistEdit;
    }
  }

  void _getTitleLines() {
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: wishListGroupName.value,
        style: const TextStyle(
          fontSize: AppDimen.textSize_20,
          fontFamily: AppFont.font,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: deviceWidth - 150);
    List<ui.LineMetrics> lines = textPainter.computeLineMetrics();
    TitlenumberOfLines = lines.length;
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onRefresh().then((value) {
        for (var element in wishlistcontroller.allWishListGroupList) {
          if (element['id'].toString() == wishlistcontroller.wishListGroupId.toString()) {
            wishListGroupName.value = element['name'];
            break;
          }
        }
        _getTitleLines();
      });
    });
    initThemeType();
    return CustomScaffold(
        controller: wishlistcontroller,
        isShowAppBar: true,
        titleLines: TitlenumberOfLines,
        isEnableLoadingOff: false,
        backIconWidget: getBackIconWidget(
          backIcon: wishlistLayout?.backIcon,
          themeType: wishlistLayout?.themeType,
          onTap: () {
            wishlistcontroller.isViewScreen.value = false;
            wishlistcontroller.wishlistViewAnimation.reverse();
            wishlistcontroller.isLoading.value = true;
            wishlistcontroller.checkNetwork(wishlistcontroller.getAllWishlistWithGroup);
          }
        ),
        action: [
          getBackIconWidget(
            themeType: wishlistLayout?.themeType,
            backIcon: wishlistEditIcon,
            iconColor: iconColor,
            quarterTurns: wishlistcontroller.isRTL() ? 4 : 0,
            onTap: () {
              WishlistModificationSheet wishlistSheet = Get.find();
              showCustomBottomSheet(
                contentWidget: GetBuilder<BottomSheetController>(
                  builder: (newController) => wishlistSheet.getWishlistModificationWidget(
                    isEdit: true,
                    groupName: wishListGroupName.value,
                    groupId: wishlistcontroller.wishListGroupId,
                    allWishListGroupList: wishlistcontroller.allWishListGroupList,
                    borderRadius: wishlistLayout?.borderRadius
                  ),
                ),
                backButtonWidget: getBackIconWidget(
                  themeType: overALLThemeType,
                  backIcon:overALLAppLayoutModel!.backIcon,
                ),
              );
            }
          ),
          getBackIconWidget(
            themeType: wishlistLayout?.themeType,
            backIcon: wishlistDeleteIcon,
            iconColor: iconColor,
            quarterTurns: wishlistcontroller.isRTL() ? 4 : 0,
            margin: pad(h: 15),
            onTap: () {
              showAlertDialog(
                title: label_delete.tr,
                contentText: "label_are_you_sure_want_to_delete_this".tr,
                appLayout: AppLayout.wishlist,
                onOkPressed: () {
                  Get.back();
                  if (!wishlistcontroller.isLoading.value) {
                    wishlistcontroller.checkNetwork(wishlistcontroller.deleteWishlistGroup);
                  }
                },
                cancelButtonContent :label_cancel.tr,
                okButtonContent: label_delete.tr
              );
            }
          ),
          AppDimen.startMargin.toWidth(),
        ].toRow(),
        body: showBodyContentWidget()
    );
  }

  Widget showBodyContentWidget() {
    double itemWidth = (deviceWidth - (2 * AppDimen.startMargin));
    return [
      Obx(() => CustomTitleText(
            text: wishListGroupName.value,
        size: AppDimen.textSize_26,
        fontWeight: AppFont.semiBold,
          ).toPad(horizontal: AppDimen.startMargin, bottom: 18)),
      Obx(() {
        bool isload =
            (wishlistcontroller.isLoading.value && wishlistcontroller.wishlistGroupItemList.isEmpty);
        bool isshimmerloading = wishlistcontroller.wishlistGroupsCurrentpage.value == 1 && isload;
        debugPrint('isshimmerloading: $isshimmerloading');
        return (wishlistcontroller.overallWishlistGroupItemsCount == 0 &&
                !wishlistcontroller.isLoading.value) ?
        _getWishlistGroupEmptyWidget()
        : toReviewList(
          reviewListScrollController: wishlistcontroller.wishlistGroupItemScrollController,
          reviewList: wishlistcontroller.wishlistGroupItemList,
          reviewsCount: wishlistcontroller.overallWishlistGroupItemsCount,
          onApiFunction: wishlistcontroller.getWishListGroup,
          controller: wishlistcontroller,
          currentPage: wishlistcontroller.wishlistGroupsCurrentpage,
          isDisableLoader: true,
          emptyWidget: _getWishlistGroupEmptyWidget(),
          emptyViewPhysics: const NeverScrollableScrollPhysics(),
          listView: wishListListingWidget(
              count: wishlistcontroller.wishlistGroupItemList.isNotEmpty
                  ? wishlistcontroller.wishlistGroupItemList.length
                  : wishlistcontroller.isLoading.value
                      ? 5
                      : 0,
              itemWidth: itemWidth,
              isShimmerLoading: isshimmerloading),
        ).toShimmer(controller: wishlistcontroller);
      }).toStretch()
    ].toColumn();
  }

  Future<Null> onRefresh() async {
    wishlistcontroller.isLoading.value = true;
    wishlistcontroller.wishlistGroupItemList.clear();
    wishlistcontroller.overallWishlistGroupItemsCount = 0;
    wishlistcontroller.wishlistGroupsCurrentpage.value = 1;
    wishlistcontroller.checkNetwork(wishlistcontroller.getWishListGroup);
  }

  Widget wishListListingWidget(
      {required int count, required double itemWidth, required bool isShimmerLoading}) {
    return List.generate(
      count,
      (index) {
        dynamic item;
        if (wishlistcontroller.wishlistGroupItemList.isNotEmpty) {
          dynamic currentitem = wishlistcontroller.wishlistGroupItemList[index];
          item = currentitem?.toJson()['listData'] != null ? currentitem?.listData : currentitem;
        }
        return Center(
          child: ShimmerLoading(
            widgetType: 'wishlishtGroupitem',
            isLoading: isShimmerLoading,
            isDarkMode: wishlistcontroller.isDarkMode(),
            child: getRecommandedItem(
                    listing_data: item,
                    themeType: wishlistLayout?.themeType ?? 1,
                    instantBookIcon: wishlistLayout?.instantBookIcon,
                    borderRadius: wishlistLayout?.borderRadius ?? 1,
                    itemWidth: itemWidth,
                    itemHeight: 180,
                    type: 'wishlist',
                    currencySymbol: wishlistcontroller.getCurrencySymbol(),
                    isshimmerview: isShimmerLoading,
                    controller: wishlistcontroller,
                    onTaponWishlist: () {
                      if (!wishlistcontroller.isLoading.value) {
                        wishlistcontroller.listingId = item?.id;
                        wishlistcontroller.isAddItemToGroup.value = false;
                        wishlistcontroller.checkNetwork(wishlistcontroller.updateItemToWishlistGroup);
                      }
                    },
                    onListDetailTap: (recommendResults) {
                      if (!wishlistcontroller.isLoading.value && recommendResults != null) {
                        HomeController controller = Get.find();
                        controller.homeNavigator!.navigateScreen(
                          HomeScreen.itemDetail,
                          param: [
                            recommendResults,
                            "wishlist",
                          ],
                        );
                      }
                    },
                    listpriceHeight: AppDimen.textSize_22)
                .toPad(bottom: 30),
          ),
        );
      },
    ).toScroll(
      padding: pad(bottom: 40),
      scrollController: wishlistcontroller.wishlistGroupItemScrollController,
      physics: AlwaysScrollableScrollPhysics(),
    );
  }

  Widget _getWishlistGroupEmptyWidget() {
    return [
      (deviceHeight * 0.15).toHeight(),
      Assets.drawableEmptyWishlist.toSVG(),
      15.toHeight(),
      CustomText(
        text: "${label_sorry.tr}, ${empty_title_you_dont_have.trParams({
              "field": "${label_wishlist.tr} ${label_tabbar_cars.tr.toLowerCase()}"
            })}",
        fontWeight: FontWeight.normal,
        size: AppDimen.textSize_14,
      ),
      15.toHeight(),
      CustomText(
        text: label_empty_start_explore.tr,
        color: appColors.secondaryColor,
        onTap: () {
          HomeController controller = Get.find();
          wishlistcontroller.isViewScreen.value = false;
          wishlistcontroller.wishlistViewAnimation.reverse();
          controller.change(rxVariable: controller.rxSelectedTab, value: 0);
        },
      )
    ].toColumn(
      crossAxisAlignment: CrossAxisAlignment.center,
    ).toResizeWidget(width: deviceWidth);
  }


  @override
  void dispose() {
    wishlistcontroller.argumentGroupId = null;
    super.dispose();
  }
}