part of 'home_item_detail.dart';

extension HomeItemDetailPart2 on HomeItemDetailState {
  Widget _showListingPhotos() {
    debugPrint("toClipListImage --- _getPagerView --- _showListingPhotos: ");
    return _getPagerView(
      pageController: _itemPhotosScrollcontroller,
      key: _itemKey,
      onTap: () {
        bool isAppBarExpanded =
            _nestedScrollController.hasClients && _nestedScrollController.offset > (250 - kToolbarHeight);
        if (!isAppBarExpanded) {
          int index = _itemPhotosScrollcontroller.page?.round() ?? 0;
          _pageController.jumpToPage(index);
          controller.startTransition(
            true,
            transitionWidget: _getPageImage(index),
          );
          Future.delayed(const Duration(milliseconds: 50)).then((value) {
            _drawnIndex++;
            controller.change(rxVariable: rxIsOverlayAdded, value: rxIsOverlayAdded.value);
          });
        }
      },
    ).toResizeWidget(height: _listImgHeight);
  }

  Widget _getPagerView(
      {PageController? pageController,
      GestureTapCallback? onTap,
      required GlobalKey<RectGetterState> key,
      TransformationController? transformationController}) {
    return RectGetter(
      key: key,
      child: GetBuilder(
          init: controller,
          id: controller.rxIsImageZoom.id,
          builder: (context) {
            return toPageView(
              itemCount: controller.itemInfo.listPhotos.length,
              controller: pageController,
              onPageChanged: (index) {
                controller.change(rxVariable: controller.rxPagerIndex, value: index);
              },
              physics:
                  controller.rxIsImageZoom.value ? NeverScrollableScrollPhysics() : ClampingScrollPhysics(),
              itemBuilder: (context, index) {
                return _getPageImage(index,
                    onTap: onTap,
                    transformationController:
                        transformationController != null ? _transformationController[index] : null);
              },
            );
          }),
    );
  }

  Widget _showPagerItemPhotos() {
    return _getPagerView(
        pageController: _pageController,
        key: _overlayKey,
        transformationController: _transformationController[0]);
  }

  Widget _getPageImage(int index,
      {GestureTapCallback? onTap, TransformationController? transformationController}) {
    String photo = '', thumbnailimage = '';
    if (controller.itemInfo.listPhotos[index] != null &&
        controller.itemInfo.listPhotos[index].name != null &&
        controller.itemInfo.listPhotos[index].name.isNotEmpty) {
      photo = imgListingOriginal + controller.itemInfo.listPhotos[index].name;
      thumbnailimage = imgListingSmall + controller.itemInfo.listPhotos[index].name;
    }

    return Material(
      color: Colors.transparent,
      child: toOnTap(
        onTap: onTap,
        child: transformationController != null
            ? InteractiveViewer(
                transformationController: transformationController,
                minScale: 1.0,
                maxScale: 4.0,
                onInteractionEnd: (_) {
                  final scale = transformationController.value.getMaxScaleOnAxis();
                  controller.change(rxVariable: controller.rxIsImageZoom, value: scale > 1.0);
                },
                child: CustomCachedNetworkImage(
                  imageUrl: photo,
                  width: deviceWidth,
                  height: deviceHeight,
                  fit: BoxFit.contain,
                  placeholder: thumbnailimage.isNotEmpty
                      ? CustomCachedNetworkImage(
                          imageUrl: thumbnailimage,
                          fit: BoxFit.contain,
                        )
                      : Center(
                          child: CupertinoActivityIndicator(color: AppColors.staticwhite, radius: 20),
                        ),
                  errorWidget: const Icon(Icons.error),
                ),
              )
            : CustomClipNetworkImage(
                imageUrl: photo,
                width: deviceWidth,
                isShimmerView: false,
                cacheKey: 'itemdetailpage',
                placeholderURL: thumbnailimage,
                placeholderWidget: onTap == null
                    ? Center(
                        child: CupertinoActivityIndicator(color: AppColors.staticwhite, radius: 20),
                      )
                    : null,
                isImageZoom: controller.rxIsImageZoom,
                transformationController: transformationController,
                baseController: controller,
              ),
      ),
    );
  }

  void _clearOverlayTransition() {
    _drawnIndex = -1;
    controller.change(rxVariable: rxIsOverlayAdded, value: rxIsOverlayAdded.value);
    for (int index = 0; index < controller.itemInfo?.listPhotos?.length; index++) {
      _transformationController[index].value = Matrix4.identity();
    }
    controller.change(rxVariable: controller.rxIsImageZoom, value: false);
    int index = _pageController.page?.round() ?? 0;
    _itemPhotosScrollcontroller.jumpToPage(index);
    Future.delayed(const Duration(milliseconds: 80)).then((value) {
      controller.startTransition(false, transitionWidget: _getPageImage(index));
    });
  }

  Widget _showPhotosOverlayContent() {
    return GetBuilder(
        id: rxIsOverlayAdded.id,
        init: controller,
        builder: (context) {
          debugPrint("rxIsOverlayAdded.value: ${rxIsOverlayAdded.value}");
          return [
            [
              toGetBackArrow(icon: Assets.drawableSignupClose, iconSize: 15),
              toGetShareIcon(),
            ]
                .toRow(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween)
                .toPad(all: 10),
            Center(
              child: AnimatedSize(
                  duration: const Duration(milliseconds: 700),
                  child: _showPagerItemPhotos()
                      .toResizeWidget(height: _drawnIndex < 0 ? _listImgHeight : double.infinity)),
            ).toResizeWidget(height: deviceHeight - 155),
            if (rxIsOverlayAdded.value)
              GetBuilder(
                id: controller.rxPagerIndex.id,
                init: controller,
                builder: (context) => CustomText(
                  text: '${controller.rxPagerIndex.value + 1}/${controller.itemInfo?.listPhotos?.length}',
                  color: Colors.white,
                ).toPad(vertical: 5, horizontal: 10),
              ).toPad(bottom: 10)
          ]
              .toColumn(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
              )
              .toOverlayWidget(rxIsOverlayAdded);
        });
  }

  Widget _showAppBarContent({bool isShowEndActions = true}) {
    bool isTheme3 = HomeItemDetailState._onViewCarThemeType == 3;
    return [
      (isTheme3)
          ? getBackIconWidget(
            margin: EdgeInsets.zero,
            backIcon: Assets.drawableFilterCalendarArrow,
            iconColor: AppColors.staticblack,
            iconBGColor: AppColors.staticwhite
          )
          : toGetBackArrow(isViewCar: true),
      const Spacer(),
      if (isShowEndActions) toGetWishListIcon(),
      if (isShowEndActions) toGetShareIcon(),
    ].toRow().toPad(top: isTheme3 ? 18 : 20, bottom: 5, start: AppDimen.startMargin - 5, end: 10);
  }

  Widget toGetBackArrow({String? icon, double? iconSize, bool? isViewCar}) {
    return (icon ?? HomeItemDetailState._onViewCarBackIcon!)
        .toSVG(size: isViewCar ?? false ? 15 : iconSize ?? 17)
        .toPad(all: 3)
        .toCircle(
            color: AppColors.staticwhite,
            padding: 6,
            onTap: () {
              isShowLoader = false;
              HomeController homeController = Get.find();
              controller.isLoading.value = false;
              homeController.isLoading.value = false;
              if (rxIsOverlayAdded.value) {
                _clearOverlayTransition();
              } else {
                Get.back();
              }
            });
  }

  Widget toGetWishListIcon() {
    if (controller.appPreference.userID != controller.itemInfo.userId) {
      return (controller.itemInfo.wishListStatus != null && controller.itemInfo.wishListStatus!
              ? Assets.drawableGuestWishlistChecked
              : Assets.drawableGuestWishlist)
          .toSVG(
            size: 17,
          )
          .toPad(top: 3)
          .toCircle(
              color: AppColors.staticwhite,
              padding: 7,
              onTap: () {
                if (controller.appPreference.accessToken != null &&
                    controller.appPreference.accessToken!.isNotEmpty) {
                  WishlistModificationSheet wishlistSheet = Get.find();
                  wishlistSheet
                    ..init(updateController: controller, itemInfo: controller.itemInfo)
                    ..show();
                } else {
                  controller.homeItemDetailNavigator?.navigateSigninScreen();
                }
              });
    } else {
      return 0.toHeight();
    }
  }

  Widget toGetShareIcon() {
    return HomeItemDetailState._onViewCarShareIcon!.toSVG(size: 16, colour: AppColors.staticblack).toCircle(
        padding: 9,
        color: AppColors.staticwhite,
        margin: 0,
        onTap: () {
          _showShareDialog();
        });
  }

  Widget _showListingHeaderInfo(
      {bool isAddBackground = false,
      Color? titleSectionBGColor,
      bool isDisableBottomPad = false,
      Color? iconColor}) {
    String title = controller.itemInfo.title;
    debugPrint("rat_showListingHeaderInfoing: ${controller.itemInfo.reviewsStarRating}");
    double? starrating;
    if (controller.itemInfo.reviewsStarRating != null) {
      starrating = double.parse(controller.itemInfo.reviewsStarRating.toString());
    }
    return ConditionalParentWidget(
      condition: isAddBackground,
      parentBuilder: (child) => topHeaderParentWidget(child: child, titleSectionBGColor: titleSectionBGColor),
      child: [
        Material(
            color: Colors.transparent,
            child: CustomTitleText(
              text: title,
              size: AppDimen.textSize_18,
              fontWeight: AppFont.semiBold,
              color: appColors.customTextColor,
            )),
        8.toHeight(),
        [
          if (starrating != null &&
              controller.itemInfo.reviewsStarRating != null &&
              controller.itemInfo.reviewsCount != null)
            getRatingTextView(
              icon: HomeItemDetailState._onViewCarRatingIcon,
              iconColor: iconColor,
              dotSize: 8,
              dotBottomPadding: 5,
              rating: double.parse((starrating / controller.itemInfo.reviewsCount).toString()).toInt(),
              reviews: '',
              textColor: appColors.customTextColor
            ),
          CustomText(
            text: controller.getAddressText(itemInfo: controller.itemInfo),
            size: AppDimen.textSize_16,
            overflow: TextOverflow.ellipsis,
          ).toStretch(isExpanded: false)
        ].toRow(mainAxisAlignment: MainAxisAlignment.start)
      ].toColumn(),
    ).toPad(top: isAddBackground || isDisableBottomPad ? 0 : 20);
   }

  Widget topHeaderParentWidget({required Widget child, Color? titleSectionBGColor}) {
    return IntrinsicHeight(
      child: CustomBorderContainer(
        color: titleSectionBGColor ?? appColors.famousLocationBGColor,
        borderRadiusGeometry: const BorderRadiusDirectional.only(
          bottomStart: Radius.circular(30),
          bottomEnd: Radius.circular(30),
        ),
        padding: pad(
          start: AppDimen.startMargin,
          end: AppDimen.startMargin,
          top: AppDimen.startMargin,
          bottom: HomeItemDetailState._onViewCarThemeType == 3 ? 10 : AppDimen.startMargin,
        ),
        body: child,
      ).toFitToDeviceWidth(),
    );
  }

  Widget _showHostDetailsInfo(
      {Color? indicatorColor,
      Color? borderColor,
      Color? fillColor,
      double? imageSize,
      String? ownerName,
      bool isAddBackground = false,
      Color? titleSectionBGColor}) {
    return ConditionalParentWidget(
      condition: isAddBackground,
      parentBuilder: (child) => topHeaderParentWidget(child: child, titleSectionBGColor: titleSectionBGColor),
      child: ConditionalParentWidget(
        condition: borderColor != null,
        parentBuilder: (child) => CustomBorderContainer(
            borderColor: borderColor ?? appColors.myTripsDividerColor,
            borderWidth: 1,
            borderRadius: HomeItemDetailState._onViewCarBorderRadius,
            color: fillColor ?? appColors.theme4AppBarBg,
            padding: pad(w: 12, h: 8),
            body: child),
        child: toOnTap(
          onTap: () {
            debugPrint("_showHostInfo called");
            _showHostInfo(
                hostItem: controller.itemInfo.user,
                profileId: controller.itemInfo.user?.profile?.profileId,
                isHost: true);
          },
          child: [
            CustomProfileNetworkImage(
              profileImageType: HomeItemDetailState._onViewCarProfileIconType ?? '',
              imageUrl: controller.itemInfo.user?.profile?.picture.toString(),
              all: imageSize ?? 60,
              indicatorColor: indicatorColor,
            ),
            12.toWidth(),
            [
              if (isAddBackground)
                CustomText(text: controller.itemInfo.user?.profile?.firstName)
              else
                RichText(
                  text: TextSpan(
                    children: ownerName != null
                        ? getTextSpans(
                            highlightWords: [label_owner.tr],
                            primaryText: '${label_owner.tr}: $ownerName',
                            highlightColor: appColors.black,
                            fontSize: AppDimen.textSize_14,
                            fontWeight: AppFont.semiBold)
                        : getTextSpans(
                            primaryText:
                                '${label_owned_by.tr} ${controller.itemInfo.user?.profile?.firstName}',
                            searchTextWithLinks: <String, GestureTapCallback>{
                              controller.itemInfo.user?.profile?.firstName: () {
                                debugPrint("_showHostInfo called");
                                _showHostInfo(
                                    hostItem: controller.itemInfo.user,
                                    profileId: controller.itemInfo.user?.profile?.profileId,
                                    isHost: true);
                              }
                            },
                            highlightWords: [label_owned_by.tr],
                            fontSize: AppDimen.textSize_18,
                            fontWeight: AppFont.medium,
                            primaryTextFontWeight: AppFont.medium,
                            highlightColor: indicatorColor),
                    style: TextStyle(
                      fontFamily: AppFont.font,
                      color: appColors.black,
                      fontSize:
                          ownerName != null && isAddBackground ? AppDimen.textSize_14 : AppDimen.textSize_17,
                    ),
                  ),
                ),
              5.toHeight(),
              CustomText(
                text:
                    "${label_joined_in.tr} ${getDateFormat(dateFormat: userProfileCreateFormat, milliSec: controller.itemInfo.user?.profile?.createdAt).$1.replaceAll(' ', ' ')}",
                fontWeight: AppFont.regular,
                size: ownerName != null ? AppDimen.textSize_16 : AppDimen.textSize_16,
              ),
            ].toColumn(mainAxisAlignment: MainAxisAlignment.center).toStretch(),
            if (isAddBackground) toGetWishListIcon(),
            if (isAddBackground) toGetShareIcon(),
          ].toRow(mainAxisAlignment: MainAxisAlignment.start),
        ),
      ),
    );
  }

  Widget _showCarFeatureGrid({
    bool? isEnableDottedBorder,
    Color? itemFillColor,
    bool? isShowicon,
  }) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 20, mainAxisSpacing: 20, childAspectRatio: 154 / 110),
      children: List.generate(controller.hostListInfo.length, (index) {
        Widget gridItem = [
          if (isShowicon ?? true)
            controller.hostListInfo[index]['placeholder']
                .toString()
                .toSVG(size: 30, colour: appColors.black)
                .toResizeWidget(width: 30)
                .toPad(bottom: 4),
          CustomText(
            text: controller.hostListInfo[index]['title'],
            size: AppDimen.textSize_14,
            color: appColors.customTextColor,
            fontWeight: AppFont.semiBold,
          ).toStretch(isExpanded: false),
          CustomText(
            text: controller.hostListInfo[index]['itemName'],
            size: AppDimen.textSize_14,
            fontWeight: AppFont.regular,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            alignment: Alignment.center,
            textAlign: TextAlign.center,
          ).toPad(horizontal: 5).toStretch(isExpanded: false)
        ].toColumn(
            crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center);
        return CustomBorderContainer(
          borderRadius: 12,
          color: itemFillColor ?? appColors.myTripsBGColor,
          borderColor: appColors.myTripsDividerColor,
          borderWidth: isEnableDottedBorder != null && isEnableDottedBorder ? 0 : 1.5,
          body: isEnableDottedBorder != null && isEnableDottedBorder
              ? DottedBorderView(
                      child: Center(child: gridItem),
                      borderRadius: HomeItemDetailState._onViewCarBorderRadius,
                      dottedlineColor: appColors.colorCommonLinkColor)
                  .toResizeWidget(width: deviceWidth)
              : gridItem,
        );
      }),
    );
  }
}