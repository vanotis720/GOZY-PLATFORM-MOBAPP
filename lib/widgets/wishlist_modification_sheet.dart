import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_colors.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/resources/app_layout.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/screens/views/guest/wishlist/wishlist_modify_controller.dart';
import 'package:gozy/widgets/bottom_sheet/bottom_sheet_refresh_controller.dart';
import 'package:gozy/widgets/common/custom_bottomsheet/custom_bottomsheet.dart';
import 'package:gozy/widgets/common/custom_bottomsheet/custom_getx_bottomsheet.dart';
import 'package:gozy/widgets/common/custom_button/bottom_shadow_button.dart';
import 'package:gozy/widgets/common/custom_container/custom_border_container.dart';
import 'package:gozy/widgets/common/custom_network_image/custom_clip_network_image.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/common/custom_textfield/custom_prefix_textfield.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/conditional_parent_widget.dart';
import 'package:gozy/widgets/custom_text.dart';

import 'common/custom_container/custom_wishlist_container.dart';

class WishlistModificationSheet {
  WishlistModifyController controller = Get.find();
  String type = 'add';

  int? themeType;
  double? borderRadius;
  late String wishlistTitle;

  void init({
    String? type,
    required updateController,
    required dynamic itemInfo,
  }) {
    if (type != null) {
      this.type = type;
    }
    controller.listingId = itemInfo.id;

    controller.isBottomSheetOpen = true;
    controller.change(
        rxVariable: controller.isRxBottomSheetLoading, value: true);
    controller.wishlistGroupScrollController = ScrollController();

    controller.centerloadingIndex = -1;
    controller.allWishListGroupList.clear();
    controller.isLoadAllItems = true;
    themeType = appLayoutMap[AppLayout.wishlist]?.themeType;
    borderRadius = appLayoutMap[AppLayout.wishlist]?.borderRadius;
    wishlistTitle = appLayoutMap[AppLayout.wishlist]?.wishlistTitle ?? '';
    controller.checkNetwork(controller.getAllWishlistWithGroup);
  }

  void show() {
    Color? titleBGColor;
    bool? isShowDivider;

    switch (themeType) {
      case 2:
        isShowDivider = true;
        borderRadius = 0;
        break;

      case 3:
        titleBGColor = appColors.myTripsBGColor;
        borderRadius = 30;
        break;

      case 4:
        titleBGColor = appColors.theme4AppBarBg;
        borderRadius = 12;
        break;
    }
    GetXBottomSheet(
      isDismissible: true,
      borderRadius: borderRadius ?? 0,
      bottomSheetWidget:
          GetBuilder<BottomSheetController>(builder: (newController) {
        switch (themeType) {
          case 2:
            isShowDivider = true;
            break;

          case 3:
            titleBGColor = appColors.myTripsBGColor;
            break;

          case 4:
            titleBGColor = appColors.theme4AppBarBg;
            break;
        }
        final Widget content = ColoredBox(
          color: appColors.white,
          child: _getBottomSheetWidget(
            titleBGColor: titleBGColor,
            isShowDivider: isShowDivider,
          ),
        );

        if (themeType != 4 && themeType != 3 && themeType != 1) return content;
        print("theme Type ???? ${themeType}");
        return ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(themeType == 4
                ? 12
                : themeType == 1
                    ? 8
                    : 35),
          ),
          child: content,
        );
      }),
    );
  }

  Widget _getBottomSheetWidget({Color? titleBGColor, bool? isShowDivider}) {
    return [
      ConditionalParentWidget(
          condition: titleBGColor != null,
          parentBuilder: (child) {
            return CustomBorderContainer(
              borderColor: Colors.transparent,
              borderRadiusGeometry: BorderRadiusDirectional.only(
                topEnd: Radius.circular(borderRadius ?? 0),
                topStart: Radius.circular(borderRadius ?? 0),
              ),
              color: titleBGColor,
              body: child,
            );
          },
          child: [
            CustomTitleText(
                text: wishlistTitle.tr,
                size: AppDimen.textSize_26,
                fontWeight: AppFont.semiBold),
            Assets.drawableCountIncrement.toSVG(
                colour: appColors.secondaryColor,
                size: 20,
                onTap: () {
                  if (!controller.isRxBottomSheetLoading.value) {
                    controller.wishListGroupId = null;
                    controller.groupTitleEditingController.clear();
                    showCustomBottomSheet(
                        contentWidget: getWishlistModificationWidget(
                            borderRadius: borderRadius),
                        backButtonWidget: getBackIconWidget(
                          backIcon: overALLAppLayoutModel!.backIcon,
                          themeType:
                              appLayoutMap[AppLayout.wishlist]?.themeType,
                        ),
                        sheetCloseListener: () {
                          controller.change(
                              rxVariable: controller.isRxBottomSheetLoading,
                              value: false);
                        });
                  }
                }),
          ]
              .toRow(mainAxisAlignment: MainAxisAlignment.spaceBetween)
              .toPad(vertical: 18, horizontal: AppDimen.startMargin)),
      if (isShowDivider ?? false) filterDivider,
      if ((isShowDivider != null || titleBGColor != null) && controller.allWishListGroupList.isNotEmpty) 20.toHeight(),
      Center(
        child: GetBuilder(
            id: controller.isRxBottomSheetLoading.id,
            init: controller,
            builder: (context) {
              return [
                controller.allWishListGroupList.isEmpty
                    ? !controller.isRxBottomSheetLoading.value &&
                            controller.centerloadingIndex == -1
                        ? CustomText(
                            text: label_wishlist_empty_content.tr,
                            alignment: Alignment.center,
                            size: AppDimen.textSize_16,
                            fontWeight: AppFont.regular,
                            textAlign: TextAlign.center,
                          ).toPad(horizontal: 40)
                        : const SizedBox.shrink()
                    : _getWishListItems(),
                if (controller.isRxBottomSheetLoading.value &&
                    controller.centerloadingIndex == -1)
                  dotCenter120HeightLoader!,
              ].toStack();
            }),
      ).toStretch(),
    ].toColumn().toResizeWidget(height: 275);
  }

  Widget getWishlistModificationWidget(
      {bool isEdit = false,
      String? groupName,
      int? groupId,
      List<Map<String, dynamic>>? allWishListGroupList,
      double? borderRadius}) {
    if (groupName != null) {
      controller.groupTitleEditingController.text = groupName;
    }
    if (groupId != null) {
      controller.wishListGroupId = groupId;
    }

    if (allWishListGroupList != null) {
      controller.allWishListGroupList = allWishListGroupList;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.change(
          rxVariable: controller.isRxBottomSheetLoading, value: false);
    });
    debugPrint(
        "allWishListGroupList--- length: emftrt ${controller.allWishListGroupList.length}");
    return GetBuilder<BottomSheetController>(builder: (newController) {
      return ColoredBox(
          color: appColors.white,
          child: GetBuilder(
                  init: controller,
                  id: controller.isRxBottomSheetLoading.id,
                  builder: (context) => controller
                              .isRxBottomSheetLoading.value &&
                          controller.centerloadingIndex == -1
                      ? dotCenter120HeightLoader!
                      : [
                          20.toHeight(),
                          CustomPrefixTextField(
                            title: isEdit
                                ? label_edit_your_wish_list.tr
                                : label_create_a_wish_list.tr,
                            controller: controller.groupTitleEditingController,
                            hintText: isEdit
                                ? label_edit_your_wish_list.tr
                                : label_create_a_wish_list.tr,
                            characterlength: 50,
                            maxLines: 1,
                            focusNode: controller.groupTitleFocusNode,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                          ).toPad(horizontal: AppDimen.startMargin),
                          const Spacer(),
                          BottomShadowButton(
                              buttonPadding: pad(a: 24),
                              buttonText: isEdit
                                  ? btn_label_save.tr
                                  : label_create_a_wish_list.tr,
                              borderRadiusGeometry:
                                  BorderRadiusDirectional.only(
                                      topStart:
                                          Radius.circular(borderRadius ?? 0),
                                      topEnd:
                                          Radius.circular(borderRadius ?? 0)),
                              onTap: () async {
                                if (!controller.isRxBottomSheetLoading.value)
                                  controller.checkValidate();
                              })
                        ].toColumn())
              .toResizeWidget(
                  height:
                      deviceHeight + MediaQuery.of(Get.context!).padding.bottom)
              .toFitToDeviceWidth());
    });
  }

  Widget _getWishListItems() {
    double itemWidth = (deviceWidth - 50.0) / 1.35;
    return toListView(
        scrollDirection: Axis.horizontal,
        key: const PageStorageKey<String>('wishlistgrouphorizontal'),
        controller: controller.wishlistGroupScrollController,
        itemCount: controller.allWishListGroupList.length,
        itemBuilder: (contex, index) {
          String image = '';
          bool isWishlisted = false;
          if (controller.allWishListGroupList[index]['wishListCover'] != null) {
            image = imgListingMedium +
                (controller.allWishListGroupList[index]['wishListCover']
                        ?['listData']?['listPhotoName'] ??
                    '');
            controller.allWishListGroupList[index]['wishLists']
                .forEach((element) {
              if (element?['listId'] == controller.listingId) {
                isWishlisted = true;
              }
            });
          }

          return toOnTap(
            onTap: () {
              if (!controller.isRxBottomSheetLoading.value) {
                controller.isAddItemToGroup.value = (!isWishlisted);
                controller.wishListGroupId =
                    controller.allWishListGroupList[index]['id'];
                controller.centerloadingIndex = index;
                controller.isRxBottomSheetLoading.value = true;
                controller.checkNetwork(controller.updateItemToWishlistGroup);
              }
            },
            child: [
              [
                CustomClipNetworkImage(
                    imageUrl: image,
                    width: itemWidth,
                    height: 140,
                    placeholderURL: image.replaceAll('x_medium_', 'small_'),
                    borderRadius: BorderRadius.all(Radius.circular(
                        borderRadius ?? AppDimen.appBorderRadius))),
                CustomWishlistContainer(
                  color: Colors.white70,
                  margin: pad(a: 12),
                  padding: pad(w: 8, bottom: 8, top: 10),
                  body: isWishlisted != null && !isWishlisted!
                      ? Assets.drawableGuestWishlist
                          .toSVG(fit: BoxFit.scaleDown, size: 22)
                      : Assets.drawableGuestWishlistChecked
                          .toSVG(fit: BoxFit.scaleDown, size: 22),
                ).toPositionedAlign(
                  alignment: AlignmentDirectional.center,
                ),
                if (controller.isRxBottomSheetLoading.value &&
                    controller.centerloadingIndex == index)
                  dotCenter120HeightLoader!.toPositionedAlign(
                      alignment: AlignmentDirectional.center),
              ].toStack().toPad(end: 20, bottom: 10),
              [
                ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: itemWidth - 40,
                    ),
                    child: CustomText(
                        text:
                            '${controller.allWishListGroupList[index]['name']} ',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        size: AppDimen.textSize_16,
                        fontWeight: AppFont.regular)),
                CustomText(
                  text:
                      '(${controller.allWishListGroupList[index]['wishListCount']})',
                  size: AppDimen.textSize_16,
                  fontWeight: AppFont.regular,
                )
              ]
                  .toRow(mainAxisAlignment: MainAxisAlignment.start)
                  .toResizeWidget(width: itemWidth),
            ].toColumn(),
          ).toPad(start: index == 0 ? AppDimen.startMargin : 0);
        });
  }
}