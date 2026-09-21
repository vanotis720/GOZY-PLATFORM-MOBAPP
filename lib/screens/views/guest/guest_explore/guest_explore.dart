import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/graphql/ExploreListing/__generated__/explore_list.data.gql.dart';
import 'package:gozy/graphql/__generated__/base_listing_info_fragment.data.gql.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/resources/app_layout.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/screens/views/guest/filter/guest_filter_controller.dart';
import 'package:gozy/screens/views/home/home_controller.dart';
import 'package:gozy/screens/views/home/home_navigator.dart';
import 'package:gozy/utils/common_api_controller.dart';
import 'package:gozy/widgets/common/custom_container/custom_border_container.dart';
import 'package:gozy/widgets/common/custom_network_image/custom_clip_network_image.dart';
import 'package:gozy/widgets/common/custom_network_image/custom_profile_network_image.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_empty_view.dart';
import 'package:gozy/widgets/custom_stateful_widget.dart';
import 'package:gozy/widgets/custom_text.dart';
import 'package:gozy/widgets/explore_image_banner.dart';
import 'package:gozy/widgets/explore_listing_item_widgets.dart';
import 'package:gozy/widgets/shimmer.dart';
import 'package:gozy/widgets/smooth_page_indicator.dart';
import 'package:gozy/widgets/where_to_go_view.dart';
import 'package:gozy/widgets/widget_size.dart';

import '../../../../config/client.dart';
import '../../../../generated/assets.dart';
import '../../../../widgets/common/custom_container/custom_container.dart';
import '../../profile/profile_navigator.dart';

class GuestExploreScreen extends CustomStatefulWidget {
  const GuestExploreScreen({key}) : super(key: key);

  @override
  _StatefulWrapperState createState() => _StatefulWrapperState();
}

class _StatefulWrapperState extends CustomStatefulWidgetState<GuestExploreScreen>
    with TickerProviderStateMixin {
  late var _recommandedScrollcontroller;
  PageController? _mostViewedHorizontalScrollcontroller;
  HomeController get controller => Get.find<HomeController>();


  ScrollController exploreScrollController = ScrollController();
  final heightNotifier = ValueNotifier<double>(1.0);
  final ScrollController _popularLocationscrollController = ScrollController();
  static final int _onRecommendOrderType = appLayoutMap[AppLayout.recommend]?.orderType ?? 1;
  static final String? _onRecommendInstantBookIcon = appLayoutMap[AppLayout.recommend]?.instantBookIcon;
  static final int _onPopularLocOrderType = appLayoutMap[AppLayout.places]?.orderType ?? 1;
  static final int _onmostViewedOrderType = appLayoutMap[AppLayout.mostViewed]?.orderType ?? 1;
  static final int _onBannerOrderType = appLayoutMap[AppLayout.banner]?.orderType ?? 1;
  static final int? _onFamousLocationsThemeType = appLayoutMap[AppLayout.places]?.themeType;
  static final int? _onBannerThemeType = appLayoutMap[AppLayout.banner]?.themeType;
  static final double? _onBannerBorderRadius = appLayoutMap[AppLayout.banner]?.borderRadius;
  static final double? _onRecommendedBorderRadius = appLayoutMap[AppLayout.banner]?.borderRadius;
  static final double? _onMostViewedBorderRadius = appLayoutMap[AppLayout.banner]?.borderRadius;
  static final int? _onRecommendThemeType = appLayoutMap[AppLayout.recommend]?.themeType;
  static final int? _onMostViewedThemeType = appLayoutMap[AppLayout.mostViewed]?.themeType;
  static final String? _onMostViewedInstantBookIcon = appLayoutMap[AppLayout.mostViewed]?.instantBookIcon;
  static final double _popularLocBorderRadius = appLayoutMap[AppLayout.places]?.borderRadius ?? 0;
  static final int? _onOverAllThemeType = appLayoutMap[AppLayout.themeType]?.themeType;

  @override
  void initState() {
    super.initState();
    isShowLoader = false;

    _recommandedScrollcontroller = PageController(initialPage: 0, viewportFraction: 0.8);
    if (_onMostViewedThemeType == 4) {
      _mostViewedHorizontalScrollcontroller = PageController(initialPage: 0, viewportFraction: 0.8);
    }
    if (controller.getExploreListingsData == null) {
      isShowLoader = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.isLoading.value = true;
        controller.change(rxVariable: rxguestUnreadCount, value: rxguestUnreadCount.value);
      });
      controller.checkNetwork(controller.getCurrencyRateValues);
    }

    controller.isToUpdateExplore.stream.listen((event) {
      if (event) {
        onRefresh();
        controller.isToUpdateExplore.value = false;
      }
    });

    controller.isExploreDataReceived.stream.listen((event) {
      if (_popularLocationscrollController.hasClients) {
        _popularLocationscrollController.jumpTo(0.0);
      }
      if (_recommandedScrollcontroller.hasClients) {
        _recommandedScrollcontroller.jumpTo(0.0);
      }
      if (_mostViewedHorizontalScrollcontroller != null &&
          _mostViewedHorizontalScrollcontroller!.hasClients) {
        _mostViewedHorizontalScrollcontroller!.jumpTo(0.0);
      }
      if (exploreScrollController.hasClients) {
        exploreScrollController.jumpTo(0.0);
      }
      heightNotifier.value = 1.0;
    });
  }

  Future<Null> onRefresh() async {
    if (!controller.isLoading.value) {
      controller.popularLocationsResponse = null;
      controller.getExploreListingsData = null;
      controller.checkNetwork(controller.getCurrencyRateValues);
      Future.delayed(const Duration(milliseconds: 20)).then((value) {
        if(_popularLocationscrollController.hasClients) {
          _popularLocationscrollController.jumpTo(0.0);
        }
        if(_recommandedScrollcontroller.hasClients) {
          _recommandedScrollcontroller.jumpTo(0.0);
        }
        if (_mostViewedHorizontalScrollcontroller != null &&
            _mostViewedHorizontalScrollcontroller!.hasClients) {
          _mostViewedHorizontalScrollcontroller!.jumpTo(0.0);
        }
        exploreScrollController.jumpTo(0.0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    isShowLoader = false;
    return CustomScaffold(
        controller: controller,
        extendBody: true,
        isDisableLoader: true,
        customAppBarFunction: () {
          if (Platform.isAndroid) {
            SystemNavigator.pop();
          } else if (Platform.isIOS) {
            exit(0);
          }
        },
        body: GetBuilder<HomeController>(builder: (newController) {
          Map<int, Widget> ordermap = {};

          ordermap[_onRecommendOrderType] = [
            if (_onRecommendThemeType == 4) ...[
              _showMostViewedListings('title',
                  title: label_our_recommendation.tr, listingType: "Recommended"),
              _showMostViewedListings('list', listingType: "Recommended"),
            ] else ...[
              _showRecommendedListings('title').toPad(start: 10.0),
              _showRecommendedListings('list'),
            ]
          ]
              .toColumn()
              .toPad(horizontal: 10, top: _onRecommendOrderType == 1 ? 0 : 12, bottom: 12)
              .toResizeWidget(color: appColors.white);

          ordermap[_onBannerOrderType] = _showImageBanner().toResizeWidget(color: appColors.white).toPad(
              top: (_onBannerOrderType == 1 ||
                      (!controller.isLoading.value &&
                          _onBannerOrderType == 2 &&
                          _onRecommendOrderType == 1 &&
                          (controller.getExploreListingsData?.getRecommend?.results?.isEmpty ?? false)))
                  ? 0
                  : AppDimen.startMargin);

          ordermap[_onmostViewedOrderType] = [
            if (_onMostViewedThemeType == 4) ...[
              _showRecommendedListings('title', title: label_most_loved.tr, listingType: 'mostviewed')
                  .toPad(start: 10.0),
              _showRecommendedListings('list', listingType: 'mostviewed'),
            ] else ...[
              _showMostViewedListings('title'),
              _showMostViewedListings('list'),
            ]
          ]
              .toColumn()
              .toPad(
                  horizontal: 10,
                  top: (_onmostViewedOrderType == 1 ||
                          (!controller.isLoading.value &&
                              _onmostViewedOrderType == 2 &&
                              _onRecommendOrderType == 1 &&
                              (controller.getExploreListingsData?.getRecommend?.results?.isEmpty ?? false)))
                      ? 0
                      : 12,
                  bottom: 12)
              .toResizeWidget(color: appColors.white);

          ordermap[_onPopularLocOrderType] = [
            _showPopularLocations('title').toPad(start: 10.0),
            _showPopularLocations('list').toPad(start: 10.0),
          ]
              .toColumn()
              .toPad(
                  horizontal: 10,
                  top: (_onPopularLocOrderType == 1 ||
                          (!controller.isLoading.value &&
                              _onPopularLocOrderType == 2 &&
                              _onRecommendOrderType == 1 &&
                              (controller.getExploreListingsData?.getRecommend?.results?.isEmpty ?? false)))
                      ? 0
                      : 12)
              .toResizeWidget(color: appColors.white);

          var mapEntries = ordermap.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

          ordermap
            ..clear()
            ..addEntries(mapEntries);

          return [
            _showWhereToGoPage(),
            toListView(
                    itemCount: ordermap.values.length,
                    controller: exploreScrollController,
                    key: const PageStorageKey<String>('explorelist'),
                    padding: pad(bottom: AppDimen.startMargin),
                    itemBuilder: (context, index) {
                      return ordermap.values.toList()[index];
                    })
                .toShowEmpty(
                    controller: controller,
                    emptyWidget: _showEmptyWidget(),
                    isShowEmpty: () {
                      return controller.getExploreListingsData != null &&
                          controller.getExploreListingsData?.getRecommend?.results?.length == 0 &&
                          homeBannerData?.getImageBanner == null &&
                          controller.popularLocationsResponse?.results?.length == 0 &&
                          controller.getExploreListingsData?.getMostViewedListing?.results?.length == 0;
                    })
                .toRefresh(onRefresh: onRefresh)
                .toStretch(),
          ]
              .toColumn(mainAxisSize: MainAxisSize.max)
              .toResizeWidget(
                isDeviceFit: true,
                color: appColors.white,
              );
        }).toShimmer(controller: controller));
  }

  CustomEmptyView _showEmptyWidget() {
    return CustomEmptyView(
      emptyImageWidget: Assets.drawableNoListingFound.toSVG(size: 150),
      emptyTitle: label_empty_listing.tr,
    );
  }

  Widget _showWhereToGoPage() {
    return <Widget>[
      _onOverAllThemeType == 1 ? _toTheme1TopView() : 0.toHeight(),
      CustomContainer(
        color: appColors.white,
        padding: _onOverAllThemeType == 1
            ? pad(top: AppDimen.startMargin, bottom: 14, w: 18)
            : pad(top: 18, bottom: 14),
        body: [
          WhereToGoSection(
            themeTypeBorderRadius: AppDimen.appBorderRadius,
            selectedLocationEmpty: true,
            isGuestExplore: true,
            onTapSearchLocation: () {
              controller.homeNavigator!.navigateScreen(HomeScreen.FilterLocation,
                  controller: controller.GuestFilterController ?? Get.find<GuestFilterController>());
            },
            onTapFilter: () {
              controller.homeNavigator!.navigateScreen(HomeScreen.filter, controller: controller);
            },
            themeType: _onOverAllThemeType
          ),
        ].toColumn(),
      )
    ].toColumn();
  }

  Widget _showPopularLocations(String type) {
    int count = 5;
    return Obx(() {
      if (controller.isLoading.value) {
        count = 5;
      }
      GgetExploreListingsData_getPopularLocations? popularLocations = controller.popularLocationsResponse;
      if (popularLocations != null) {
        count = popularLocations.results!.length;
      }
      return type == 'list'
          ? _showPopularLocationsList(count, popularLocations)
          : controller.isLoading.value || count > 0
              ? _showTitle(
                  _onFamousLocationsThemeType == 1 ? label_popular_locations.tr : label_famous_location.tr)
              : const SizedBox.shrink();
    });
  }

  Widget _showPopularLocationsList(int count, GgetExploreListingsData_getPopularLocations? popularLocations) {
    double itemWidth = (deviceWidth - 50.0) / 2.50;
    double itemHeight = itemWidth * 1.3;
    switch (_onFamousLocationsThemeType) {
      case 3:
        itemHeight = itemWidth * 0.4;
        break;
      case 4:
        itemWidth = deviceWidth / 2;
        itemHeight = 70;
        break;
      case 2:
        itemWidth = (deviceWidth - 50.0) / 3.5;
        itemHeight = itemWidth * 1.5;
        break;
    }

    debugPrint("_showPopularLocationsListitemWidth: $itemWidth ---$itemHeight ");
    return toListView(
        scrollDirection: Axis.horizontal,
        itemCount: count,
        key: const PageStorageKey<String>('popularlocationshorizontal'),
        controller: _popularLocationscrollController,
        isLoading: controller.isLoading.value || popularLocations == null,
        isShowShimmer: true,
        itemBuilder: (contex, index) {
          return count > 0
              ? ShimmerLoading(
                  widgetType: 'popularlocation',
                  isLoading: controller.isLoading.value || popularLocations == null,
                  isDarkMode: controller.isDarkMode(),
                  child: toOnTap(
                    onTap: () {
                      if (!controller.isLoading.value && popularLocations != null) {
                        controller.selectedPopularLocation =
                            popularLocations.results![index]!.locationAddress.toString();
                        controller.isSearchSelected.value = true;
                        controller.isSearchSelected.refresh();
                      }
                      debugPrint("guestexplorecontroller: ${controller.isSearchSelected.value}");
                    },
                    child: _onFamousLocationsThemeType == 4
                        ? _showTheme4PopularLocation(
                                itemHeight: itemHeight,
                                itemWidth: itemWidth,
                                imageUrl: !controller.isLoading.value &&
                                        popularLocations != null &&
                                        popularLocations.results![index]?.image != null
                                    ? (imgListingPopularMedium +
                                        popularLocations.results![index]!.image.toString())
                                    : null,
                                placeholderURL: !controller.isLoading.value &&
                                        popularLocations != null &&
                                        popularLocations.results![index]?.image != null
                                    ? (imgListingPopularSmall +
                                        popularLocations.results![index]!.image.toString())
                                    : null,
                                location: !controller.isLoading.value && popularLocations != null
                                    ? popularLocations.results![index]!.location.toString()
                                    : ' abc ',
                                isShimmerView: controller.isLoading.value || popularLocations == null)
                            .toPad(end: index != count - 1 ? 15.0 : 0.0)
                        : _onFamousLocationsThemeType == 3
                            ? _showTheme3PopularLocation(
                                    itemHeight: itemHeight,
                                    itemWidth: itemWidth,
                                    location: !controller.isLoading.value && popularLocations != null
                                        ? popularLocations.results![index]!.location.toString()
                                        : ' abc ',
                                    isShimmerView: controller.isLoading.value || popularLocations == null)
                                .toPad(end: index != count - 1 ? 15.0 : 0.0)
                            : _onFamousLocationsThemeType == 1
                                ? _showTheme1PopularLocation(
                                    itemHeight: itemHeight,
                                    itemWidth: itemWidth,
                                    location: !controller.isLoading.value && popularLocations != null
                                        ? popularLocations.results![index]!.location.toString()
                                        : ' abc ',
                                    imageUrl: popularLocations != null
                                        ? popularLocations.results![index]?.image != null
                                            ? (imgListingPopularMedium +
                                                popularLocations.results![index]!.image.toString())
                                            : null
                                        : null,
                                    isShimmerView: controller.isLoading.value || popularLocations == null)
                                : [
                                    !controller.isLoading.value && popularLocations != null
                                        ? imgListingPopularMedium +
                                            popularLocations.results![index]!.image.toString()
                                        : '',
                                    !controller.isLoading.value && popularLocations != null
                                        ? popularLocations.results![index]!.location.toString()
                                        : ' abc ',
                                  ]
                                    .toPopularLocationList(
                                        itemWidth: itemWidth,
                                        itemHeight: itemHeight,
                                        borderRadius: itemWidth / 2,
                                        AreaOfBorderRadius: 'top',
                                        parentWidget: 'column',
                                        placeholderURL: popularLocations != null &&
                                                popularLocations.results![index]?.image != null
                                            ? (imgListingPopularSmall + popularLocations.results![index]!.image.toString())
                                            : null,
                                        isShimmerView: controller.isLoading.value || popularLocations == null)
                                    .toPad(end: index != count - 1 ? 15.0 : 0.0),
                  ),
                )
              : const SizedBox.shrink();
        }).toResizeWidget(height: count > 0 ? itemHeight : 0.0).toPad(top: count > 0 ? 5.0 : 0);
  }

  Widget _showTheme1PopularLocation(
      {double? itemHeight, double? itemWidth, String? location, String? imageUrl, bool? isShimmerView}) {
    debugPrint("popular location imageUrl --> $imageUrl");
    return CustomBorderContainer(
      height: itemHeight,
      width: itemWidth,
      padding: pad(h: 12),
      borderRadius: _popularLocBorderRadius,
      borderWidth: 1,
      borderColor: appColors.myTripsDividerColor,
      color: isShimmerView! ? appColors.shimmerplaceholderColor : null,
      body: <Widget>[
        CustomContainer(
          height: itemWidth != null ? itemWidth - 20 : null,
          width: itemWidth != null ? itemWidth - 20 : null,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: appColors.myTripsBGColor,
          ),
          padding: pad(a: 12),
          body: CustomClipNetworkImage(
            imageUrl: imageUrl ?? '',
            height: itemWidth != null ? itemWidth - 30 : null,
            width: itemWidth != null ? itemWidth - 30 : null,
            borderRadius: BorderRadius.all(
                Radius.circular(itemWidth != null ? itemWidth - 30 : AppDimen.appBorderRadius)),
            placeholderURL: imageUrl?.replaceAll('x_medium_', 'small_'),
          ),
        ),
        const Spacer(),
        CustomText(
          text: !isShimmerView ? location! : 20.toGenerateEmptyString(),
          isShimmerView: isShimmerView,
          overflow: TextOverflow.ellipsis,
          shimmerColor: appColors.myTripsBGColor,
        ).toPad(horizontal: 10),
      ].toColumn(crossAxisAlignment: CrossAxisAlignment.center),
    ).toPad(end: 18);
  }

  Widget _showTheme3PopularLocation(
      {required double itemHeight,
      required double itemWidth,
      required String location,
      required bool isShimmerView}) {
    return CustomContainer(
      height: itemHeight,
      decoration: BoxDecoration(
          color: isShimmerView ? appColors.shimmerplaceholderColor : appColors.theme4AppBarBg,
          borderRadius: BorderRadius.circular(100)),
      body: [
        if (!isShimmerView) showFamousLocationIcon(),
        10.toWidth(),
        isShimmerView
            ? CustomText(
                text: 25.toGenerateEmptyString(),
                color: appColors.shimmerplaceholderColor,
                size: AppDimen.textSize_16,
                isShimmerView: isShimmerView,
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.w500)
            : CustomText(
                text: location,
                color: appColors.textColor,
                size: AppDimen.textSize_16,
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.w500),
        10.toWidth(),
      ].toRow(mainAxisAlignment: MainAxisAlignment.start).toPad(start: 6, end: 6),
    );
  }

  Widget _showTheme4PopularLocation(
      {required double itemHeight,
      required double itemWidth,
      required String location,
      required bool isShimmerView,
      String? imageUrl,
      String? placeholderURL}) {
    return CustomBorderContainer(
      height: itemHeight,
      color: isShimmerView ? appColors.shimmerplaceholderColor : appColors.myTripsBGColor,
      borderRadius: 12,
      body: [
        CustomBorderContainer(
          height: itemHeight,
          color: appColors.myTripsBGColor,
          borderRadius: 12,
          body: imageUrl != null
              ? CustomClipNetworkImage(
                  imageUrl: imageUrl,
                  width: itemHeight,
                  height: itemHeight,
                  isShimmerView: isShimmerView,
                  placeholderURL: placeholderURL,
                  borderRadius: BorderRadius.all(Radius.circular(_popularLocBorderRadius)))
              : 0.toHeight(),
        ),
        8.toWidth(),
        isShimmerView
            ? CustomText(
                text: 30.toGenerateEmptyString(),
                size: AppDimen.textSize_16,
                isShimmerView: isShimmerView,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.w500)
            : CustomText(
                text: location,
                size: AppDimen.textSize_16,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                fontWeight: FontWeight.w500),
        8.toWidth(),
      ].toRow(mainAxisAlignment: MainAxisAlignment.start),
    );
  }

  Widget _toTheme1TopView() {
    return CustomContainer(
      padding: pad(w: AppDimen.startMargin),
      decoration: BoxDecoration(
          color: appColors.theme4AppBarBg,
          borderRadius: const BorderRadius.only(
            bottomRight: Radius.circular(30),
            bottomLeft: Radius.circular(30),
          )),
      body: _toTopDesignView(),
    ).toResizeWidget(
      width: deviceWidth,
      height: 100,
    );
  }

  Widget _toTopDesignView() {
    return <Widget>[
      InkWell(
          onTap: () {
            if (appPreference.accessToken!.isNotEmpty) {
              controller.homeNavigator?.navigateScreen(HomeScreen.profile);
            } else {
              controller.homeNavigator?.navigateScreen(HomeScreen.signIn);
            }
          },
          child: appPreference.profileImage != null && appPreference.profileImage != ''
              ? CustomProfileNetworkImage(
                  profileImageType: 'circle', imageUrl: appPreference.profileImage!, all: 50)
              : Assets.homeDefaultAvatar.toSVG()),
      10.toWidth(),
      [
        [
          Assets.drawableWelcomeHostIcon.toPng(
            height: 16,
            width: 16,
          ),
          5.toWidth(),
          CustomText(
            text: label_good_day.tr,
            size: AppDimen.textSize_16,
            fontWeight: AppFont.regular,
          ),
        ].toRow(mainAxisAlignment: MainAxisAlignment.start),
        (appPreference.accessToken != '' && (appPreference.firstName?.isNotEmpty ?? false)) ? CustomText(
          text: appPreference.accessToken == '' ? label_new_user.tr : appPreference.firstName!,
          size: AppDimen.textSize_22,
          fontWeight: AppFont.semiBold,
          overflow: TextOverflow.ellipsis,
        ) : SizedBox.shrink(),
      ].toColumn(mainAxisAlignment: MainAxisAlignment.center).toResizeWidget(width: deviceWidth * 0.55),
      const Spacer(),
      CustomContainer(
        height: 45,
        width: 45,
        onTap: () {
          if (appPreference.accessToken!.isNotEmpty) {
            controller.homeNavigator?.navigateScreen(HomeScreen.settings);
          } else {
            controller.homeNavigator?.navigateScreen(HomeScreen.signIn);
          }
        },
        padding: pad(a: 9),
        body: Assets.drawableSettings.toSVG(height: 20, width: 20, colour: appColors.black),
        decoration: BoxDecoration(
            color: appColors.white,
            shape: BoxShape.circle,
            border: Border.all(color: appColors.customBorderColor)),
      ),
    ].toRow(mainAxisAlignment: MainAxisAlignment.start);
  }

  Widget showFamousLocationIcon() {
    return CustomContainer(
      height: 40,
      width: 40,
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      body: Assets.drawableFamousLocation.toSVG().toPad(all: 8),
    );
  }

  Widget _showTitle(String title) {
    return [
      Obx(
        () => ShimmerLoading(
            widgetType: 'exploreTitle',
            isLoading: controller.isLoading.value || controller.getExploreListingsData == null,
            isDarkMode: controller.isDarkMode(),
            child: CustomTitleText(
              text: title,
              size: AppDimen.textSize_24,
              overflow: TextOverflow.ellipsis,
              fontWeight: AppFont.semiBold,
              isShimmerView: controller.isLoading.value || controller.getExploreListingsData == null,
            )),
      ).toPad(bottom: 15, top: 10).toStretch(isExpanded: false),
    ].toRow(mainAxisAlignment: MainAxisAlignment.start);
  }

  Widget _showRecommendedListings(String type, {String? title, String? listingType}) {
    int ThemeType = _onRecommendThemeType ?? 1;
    double borderradius = _onRecommendedBorderRadius ?? 0.1;
    PageController scrollcontroller = _recommandedScrollcontroller;
    if (listingType == 'mostviewed') {
      ThemeType = _onMostViewedThemeType ?? 1;
      borderradius = _onMostViewedBorderRadius ?? 0.1;
      scrollcontroller = _mostViewedHorizontalScrollcontroller!;
    }
    int count = 5;
    double itemWidth = (deviceWidth - 50.0) / 1.20;
    return Obx(() {
      if (controller.isLoading.value) {
        count = 5;
      }
      if (controller.getExploreListingsData != null) {
        count = listingType == 'mostviewed'
            ? controller.getExploreListingsData!.getMostViewedListing!.results!.length
            : controller.getExploreListingsData!.getRecommend!.results!.length;
      }
      print("ListingType--> $listingType --> $count");
      return type == 'list'
          ? count > 0
              ? _showRecommendedList(count, itemWidth,
                  themeType: ThemeType,
                  borderradius: borderradius,
                  listingType: listingType,
                  scrollcontroller: scrollcontroller)
              : const SizedBox.shrink()
          : type == 'title'
              ? controller.isLoading.value || count > 0
                  ? _showTitle(title ??
                      (ThemeType == 3 || ThemeType == 2 ? label_our_recommendation.tr : label_recommended.tr))
                  : const SizedBox.shrink()
              : controller.isLoading.value || count > 2
                  ? Center(child: _showScrollingDotView(itemWidth))
                  : const SizedBox.shrink();
    });
  }

  Widget _showRecommendedList(int count, double itemWidth,
      {required int themeType,
      required double borderradius,
      String? listingType,
      PageController? scrollcontroller}) {
    bool isload = controller.isLoading.value || controller.getExploreListingsData == null;

    return themeType == 3
        ? Center(
            child: List.generate(
              count,
              (index) {
                GviewListingShortFragment? item;
                if (controller.getExploreListingsData != null) {
                  item = listingType == 'mostviewed'
                      ? controller.getExploreListingsData?.getMostViewedListing?.results![index]
                      : controller.getExploreListingsData?.getRecommend?.results![index];
                }

                bool isload = controller.isLoading.value || controller.getExploreListingsData == null;
                return ShimmerLoading(
                    widgetType: 'exploreRecommended',
                    isLoading: isload,
                    isDarkMode: controller.isDarkMode(),
                    child: getRecommandedItem(
                            itemHeight: 185,
                            themeType: themeType,
                            instantBookIcon: listingType == 'mostviewed'
                                ? _onMostViewedInstantBookIcon
                                : _onRecommendInstantBookIcon,
                            borderRadius: borderradius,
                            listing_data: item,
                            itemWidth: (deviceWidth - 35.0),
                            type: listingType ?? 'Recommended',
                            currencySymbol: controller.getCurrencySymbol(),
                            isshimmerview: isload,
                            controller: controller,
                            onListDetailTap: (recommendResults) {
                              if (!isload) {
                                controller.homeNavigator!.navigateScreen(
                                  HomeScreen.itemDetail,
                                  param: [recommendResults, listingType ?? "Recommended"],
                                  controller: controller,
                                );
                              }
                            },
                            listpriceHeight: AppDimen.textSize_22)
                        .toPad(bottom: (index != (count - 1)) ? 20 : 0));
              },
            ).toColumn(),
          )
        : toHorizontalListingView(
            itemHeight: _onRecommendThemeType == 4
                ? 300
                : _onRecommendThemeType == 2
                    ? 320
                    : 350,
            isDisableLoader: false,
            imageHeight: 165,
            controller: controller,
            key: const PageStorageKey<String>('explorehorizontal'),
            isLoading: isload,
            themeType: themeType,
            borderRadius: borderradius,
            instantBookIcon:
                listingType == 'mostviewed' ? _onMostViewedInstantBookIcon : _onRecommendInstantBookIcon,
            count: count,
            scrollController: scrollcontroller ?? _recommandedScrollcontroller,
            itemWidth: itemWidth,
            type: listingType ?? 'Recommended',
            isShowShimmer: true,
            Listings: listingType == 'mostviewed'
                ? controller.getExploreListingsData?.getMostViewedListing?.results
                : controller.getExploreListingsData?.getRecommend?.results,
            onListDetailTap: (recommendResults) {
              debugPrint("controller.homeNavigator: ${controller.homeNavigator}");
              if (!isload) {
                controller.homeNavigator!.navigateScreen(
                  HomeScreen.itemDetail,
                  param: [recommendResults, listingType ?? "Recommended"],
                  controller: controller,
                );
              }
            },
          ).toPad(start: 10.0);
  }

  Widget _showScrollingDotView(double itemWidth) {
    int count = 5;
    if (controller.getExploreListingsData != null) {
      count = controller.getExploreListingsData!.getRecommend!.results!.length;
    }
    return SmoothPageIndicator(
      controller: _recommandedScrollcontroller,
      count: count,
      itemWidth: itemWidth + 10,
      effect: getScrollingDotEffect(),
    );
  }

  Widget _showImageBanner() {
    var popularLocations = controller.popularLocationsResponse;
    if (controller.getExploreListingsData?.getMostViewedListing?.results?.length == 0 &&
        popularLocations!.results!.isEmpty &&
        controller.getExploreListingsData?.getRecommend?.results?.length == 0) {
      controller.checkEmptyData.value = true;
    } else {
      controller.checkEmptyData.value = false;
    }
    return Obx(() {
      String bannerimg = controller.isLoading.value || homeBannerData == null
          ? ''
          : homeBannerData!.getImageBanner!.result!.image!;
      print("BannerImg--> $bannerimg");
      String bannerLabel = controller.isLoading.value || homeBannerData == null
          ? ''
          : homeBannerData!.getImageBanner!.result!.buttonLabel!;
      String bannerTitle = controller.isLoading.value || homeBannerData == null
          ? ''
          : homeBannerData!.getImageBanner!.result!.title!;
      String bannerDesc = controller.isLoading.value || homeBannerData == null
          ? ''
          : homeBannerData!.getImageBanner!.result!.description!;

      if (bannerimg.isNotEmpty) {
        bannerimg = imgBanner + bannerimg;
      }
      return ShimmerLoading(
          widgetType: 'exploreBanner',
          isLoading: controller.isLoading.value || controller.getExploreListingsData == null,
          isDarkMode: controller.isDarkMode(),
          child: ExploreImageBanner(
            title: bannerTitle,
            bannerImage: bannerimg,
            description: bannerDesc,
            buttonLabel: bannerLabel,
            bannerBorderRadius: _onBannerThemeType == 3 ? 30 : _onBannerBorderRadius,
            isShimmerView: !(!controller.isLoading.value && controller.getExploreListingsData != null),
            onTap: becomeHost,
            themeType: _onBannerThemeType,
          ));
    });
  }

  Widget _showMostViewedListings(String type, {String? title, String? listingType}) {
    int count = 5;

    if (type == 'title') {
      return Obx(() {
        if (controller.getExploreListingsData != null && !controller.isLoading.value) {
          count = listingType == 'Recommended'
              ? controller.getExploreListingsData!.getRecommend!.results!.length
              : controller.getExploreListingsData!.getMostViewedListing!.results!.length;
        }

        if (controller.isLoading.value) {
          count = 5;
        }
        return controller.isLoading.value || count > 0
            ? _showTitle(title ??
                    (_onMostViewedThemeType == 3 || _onMostViewedThemeType == 2
                        ? label_most_loved.tr
                        : label_most_viewed.tr))
                .toPad(start: 10.0)
            : const SizedBox.shrink();
      });
    }

    double itemWidth = (deviceWidth - 35.0);
    return count > 0
        ? Obx(() {
            if (controller.getExploreListingsData != null && !controller.isLoading.value) {
              count = listingType == 'Recommended'
                  ? controller.getExploreListingsData!.getRecommend!.results!.length
                  : controller.getExploreListingsData!.getMostViewedListing!.results!.length;
            }

            return Center(
              child: List.generate(
                count,
                (index) {
                  GviewListingShortFragment? item;
                  if (controller.getExploreListingsData != null) {
                    item = listingType == 'Recommended'
                        ? controller.getExploreListingsData!.getRecommend!.results![index]
                        : controller.getExploreListingsData!.getMostViewedListing!.results![index];
                  }

                  bool isload = controller.isLoading.value || controller.getExploreListingsData == null;
                  return ShimmerLoading(
                      widgetType: 'exploreMostViewed',
                      isLoading: isload,
                      isDarkMode: controller.isDarkMode(),
                      child: getRecommandedItem(
                              listing_data: item,
                              itemWidth: itemWidth,
                              itemHeight: 185,
                              instantBookIcon: listingType == 'Recommended'
                                  ? _onRecommendInstantBookIcon
                                  : _onMostViewedInstantBookIcon,
                              themeType: (listingType == 'Recommended'
                                      ? _onRecommendThemeType
                                      : _onMostViewedThemeType) ??
                                  1,
                              borderRadius: (listingType == 'Recommended'
                                      ? _onMostViewedBorderRadius
                                      : _onMostViewedBorderRadius) ??
                                  0,
                              type: listingType ?? 'mostviewed',
                              currencySymbol: controller.getCurrencySymbol(),
                              isshimmerview: isload,
                              controller: controller,
                              onListDetailTap: (recommendResults) {
                                if (!isload) {
                                  controller.homeNavigator!.navigateScreen(
                                    HomeScreen.itemDetail,
                                    param: [recommendResults, listingType ?? "mostviewed"],
                                    controller: controller,
                                  );
                                }
                              },
                              listpriceHeight: AppDimen.textSize_22)
                          .toPad(bottom: (index != (count - 1)) ? 20 : 0));
                },
              ).toColumn(),
            );
          })
        : const SizedBox.shrink();
  }

  void becomeHost() {
    if (appPreference.accessToken!.isNotEmpty) {
      appPreference.isOwner = !appPreference.isOwner!;
      ProfileNavigator().navigateScreen(ProfileScreen.userRoleChanger);
    } else {
      controller.homeNavigator?.navigateScreen(HomeScreen.signIn);
    }
  }
}