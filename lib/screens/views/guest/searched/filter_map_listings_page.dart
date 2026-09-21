import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gozy/app.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/resources/app_colors.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/screens/views/guest/filter/guest_filter_controller.dart';
import 'package:gozy/screens/views/guest/searched/searched_listings_controller.dart';
import 'package:gozy/screens/views/home/home_controller.dart';
import 'package:gozy/screens/views/home/home_navigator.dart';
import 'package:gozy/widgets/common/custom_container/custom_border_container.dart';
import 'package:gozy/widgets/common/custom_painter/custom_map_marker.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/common/custom_button/custom_button.dart';
import 'package:gozy/widgets/common/custom_container/custom_container.dart';
import 'package:gozy/widgets/custom_stateful_widget.dart';
import 'package:gozy/widgets/custom_text.dart';
import 'package:gozy/widgets/show_google_map.dart';
import 'package:gozy/widgets/widget_size.dart';



class FilterMapListingsPage extends CustomStatefulWidget {
  final HomeController controller;
  const FilterMapListingsPage({super.key,required  this.controller});

  @override
  FilterMapListingsPageState createState() => FilterMapListingsPageState();
}

class FilterMapListingsPageState extends CustomStatefulWidgetState<FilterMapListingsPage>
    with TickerProviderStateMixin {
  SearchedListingsController mapfiltercontroller = Get.find();

  double _maxHeight = overALLThemeType == 4
          ? 320
          : overALLThemeType == 3
              ? 310
              : 340,
      _minHeight = 0;
  int _duration = 300;
  double _filterContainerHeight = 36;
  final RxInt _selectedId = 0.obs;
  Set<Marker> markerlist = <Marker>{};
  final _mapListingScrollController = PageController();
  List<Place> placesList = [];
  List<DateTime> _selectedDateTimes = [];
  HomeNavigator? homeNavigator = HomeNavigator();
  GoogleMapController? googlemapController;
  Color _sliderBarColor = appColors.textFieldInActiveIconColor;
  var filterImage = '';
  double mapBorderRadius = 0;

  @override
  void initState() {
    mapfiltercontroller.guestFilterController.val = Get.arguments['controller'] as GuestFilterController;
    if (Get.arguments['selectedFilterDates'] != null) {
      _selectedDateTimes = Get.arguments['selectedFilterDates'];
    }
    _selectedId.value = mapfiltercontroller.searchListingList.first.id;
    placesList.clear();
    _selectedId.value = mapfiltercontroller.searchListingList.first.id;
    _getMarker(searchList: mapfiltercontroller.searchListingList);
    _mapListingScrollController.addListener(() async {
      if (_mapListingScrollController.position.pixels ==
          _mapListingScrollController.position.maxScrollExtent) {
        if (mapfiltercontroller.searchListingListCount >
            mapfiltercontroller.searchListingList.length){
          mapfiltercontroller.searchCurrentpage++;
          mapfiltercontroller.checkNetwork(() async {
            await mapfiltercontroller.searchListing();
            if (mapfiltercontroller.searchCurrentpage.value != 1) {
              _getMarker(searchList: mapfiltercontroller.searchListingList);
            }
          });
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _duration = 0;
      _updateMapWidgetHeight(_maxHeight);
      Future.delayed(const Duration(milliseconds: 350)).then((value) {
        _duration = 300;
      });
    });
    App().setMapKey();
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    _initThemeLayout();
    return CustomScaffold(
      controller: mapfiltercontroller,
      isShowAppBar: false,
      body: GetBuilder<SearchedListingsController>(
          builder: (context) {
            return showBodyContent(context);
          }
      ),
    );
  }

  void _initThemeLayout(){
    switch(overALLThemeType){
      case 1:
        filterImage = Assets.drawableExploreFilter;
        mapBorderRadius = AppDimen.appBorderRadius;
      case 2:
        filterImage = Assets.theme2ExploreFilter;
        mapBorderRadius = AppDimen.appBorderRadius;
      case 3:
        filterImage = Assets.drawableTheme3Filter;
        mapBorderRadius = 30;
      case 4:
        filterImage = Assets.drawableTheme3Filter;
        mapBorderRadius = AppDimen.appBorderRadius;
        _sliderBarColor = appColors.black;
      default:
        filterImage = Assets.drawableExploreFilter;
        mapBorderRadius = AppDimen.appBorderRadius;
    }
  }

  Widget showBodyContent(context) {
    return [
      Obx(
            () {
          debugPrint("_selectedIndex.value: ${_selectedId.value} --- ${mapfiltercontroller.listingsWidgetHeight.value} --");
          double bottompad = 0;
          if(Platform.isIOS){

            bottompad = switch (mapfiltercontroller.listingsWidgetHeight.value) {
              var height when height == _minHeight || height == _maxHeight => height + 10,
              _ => 0.0,
            };
          }else {
            bottompad = mapfiltercontroller.listingsWidgetHeight.value >10 ?
            mapfiltercontroller.listingsWidgetHeight.value-30 : 0;
          }
          return
            CustomContainer(
                height: Get.height,
                padding: pad(bottom: (Platform.isIOS ? 20 : (bottompad + 50)) ),
                width: deviceWidth,
                body: showGoogleMap(
                  isBottomOnly: true,
                  borderRadius: mapBorderRadius,
                    initialLatLng: LatLng(
                        mapfiltercontroller.searchListingList[0].lat,
                        mapfiltercontroller.searchListingList[0].lng),
                    controller: mapfiltercontroller,
                    markers: markerlist,
                    padding: EdgeInsets.only(bottom: Platform.isAndroid ? 20 : bottompad ),
                    onMapCreated: (mapController) {
                      googlemapController = mapController;
                    })
            );
        },
      ),
      getBackIconWidget(
        borderColor: (overALLThemeType == 3 || overALLThemeType == 1) &&
                !mapfiltercontroller.isDarkMode()
            ? AppColors.staticwhite
            : null,
        iconBGColor: appColors.white,
        iconColor: appColors.black,
        backIcon: Assets.drawableSignupClose,
      ),
      GetBuilder(
        id: mapfiltercontroller.guestFilterController.val.rxIsFiltersSelected.id,
        init: mapfiltercontroller,
        builder: (context) {
          return Obx(
                () => AnimatedContainer(
              padding: pad(bottom: mapfiltercontroller.filderSize.value + 25),
              margin: const EdgeInsetsDirectional.only(end: AppDimen.startMargin),
              duration: Duration(milliseconds: _duration),
              child: CancelButton(
                  height: _filterContainerHeight,
                  buttonText: label_filter.tr,
                  borderRadius: overALLAppLayoutModel?.borderRadius,
                  dotWidget: mapfiltercontroller.guestFilterController.val.rxIsFiltersSelected.value ?
                  CustomContainer(
                    height: 6,
                    width: 6,
                    margin: pad(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle
                    ),
                  ): CustomText(
                    text: '',
                    color: AppColors.staticwhite,
                  ).toPad(bottom: 10),
                  color: appColors.mapblack,
                  fillcolor: appColors.white,
                  textColor: appColors.colorCommonLinkColor,
                  borderColor: appColors.colorCommonLinkColor,
                  verticalPadding: 4,
                  isExpand: false,
                  horizontalPadding: 13,
                  textSize: AppDimen.textSize_14,
                  mapIcon: filterImage,
                  mapColor: appColors.colorCommonLinkColor,
                  onTap: () {
                    mapfiltercontroller.setRecentSearchQuries();
                    homeNavigator?.navigateScreen(HomeScreen.filter,
                        controller: widget.controller,
                        param: {'isFrom': 'Map'});

                  }),
            ).toPositionedAlign(alignment: AlignmentDirectional.bottomEnd),
          );
        }
      ),
      Obx(() => GestureDetector(
            onVerticalDragStart: (details) {
              if (mapfiltercontroller.listingsWidgetHeight.value == _maxHeight) {
                _updateMapWidgetHeight(_minHeight);
              } else if (mapfiltercontroller.listingsWidgetHeight.value == _minHeight) {
                _updateMapWidgetHeight(_maxHeight);
              }
            },
            child: MeasureSize(onChange: (size){
              mapfiltercontroller.filderSize.value = size.height;
              debugPrint("MeasureSize: $size");
            }, child: AnimatedContainer(
              duration: Duration(milliseconds: _duration),
              height: mapfiltercontroller.listingsWidgetHeight.value > 10
                  ? mapfiltercontroller.listingsWidgetHeight.value + 46
                  : 41,
              width: deviceWidth,
              alignment: AlignmentDirectional.topCenter,
              color: appColors.white,
              child: ClipRect(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: [
                  CustomBorderContainer(
                    width: 57,
                    height: 5,
                    borderRadius: 20,
                    color: (overALLThemeType == 4 || overALLThemeType == 3) ? appColors.mapWidgetColor : _sliderBarColor,
                    margin: pad(bottom: 18,top: 18),
                ),
                AnimatedContainer(
                    duration: Duration(milliseconds: _duration),
                    child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if(_mapListingScrollController.hasClients) {
                            double maxOffset = _mapListingScrollController
                                .position.maxScrollExtent;
                            double offset = _mapListingScrollController.offset
                                .clamp(0, maxOffset);
                            int index = int.parse((offset / (deviceWidth * 0.85)).toStringAsFixed(0));
                            if (_selectedId.value !=
                                mapfiltercontroller.searchListingList[index].id) {
                              _updateMarker(isMarkerSelected: false);
                              _selectedId.value =
                                  mapfiltercontroller.searchListingList[index].id;
                              _updateMarker(isMarkerSelected: true);
                              googlemapController?.getZoomLevel().then((
                                  zoomlevel) {
                                LatLng markerLoc = LatLng(
                                    mapfiltercontroller
                                        .searchListingList[index].lat,
                                    mapfiltercontroller
                                        .searchListingList[index].lng);
                                CameraUpdate cameraUpdate =
                                CameraUpdate.newLatLngZoom(markerLoc, 15);
                                googlemapController?.animateCamera(cameraUpdate);
                              });
                            }
                            return true;
                          }
                          return false;
                        },
                        child: toHorizontalListingView(
                          controller: mapfiltercontroller,
                          isLoading: false,
                          key:  const PageStorageKey<String>('mapsearchhorizontal'),
                          themeType: overALLThemeType,
                          borderRadius: overALLThemeType == 3 ? 30 : AppDimen.appBorderRadius,
                          count: mapfiltercontroller.searchListingList.length,
                          scrollController: _mapListingScrollController,
                          itemWidth: deviceWidth * 0.8,
                          imageHeight: 165,
                          itemHeight: overALLThemeType == 4 ? 327 : overALLThemeType == 1 ? 340: null,
                          type: 'mapview',
                          isShowShimmer: false,
                          instantBookIcon: overALLAppLayoutModel?.instantBookIcon,
                          Listings: mapfiltercontroller.searchListingList,
                          onTaponWishlist: () {
                            if (mapfiltercontroller
                                .appPreference.accessToken!.isEmpty) {
                              homeNavigator?.navigateScreen(HomeScreen.signIn,
                                  param: '');
                            }
                          },
                          onListDetailTap: (recommendResults) {
                            mapfiltercontroller.setRecentSearchQuries();
                            homeNavigator!.navigateScreen(
                              HomeScreen.itemDetail,
                              param: [
                                recommendResults,
                                "mapview",
                                _selectedDateTimes,
                                mapfiltercontroller
                                    .guestFilterController.val.guestCount.value
                              ],
                            );
                          },
                        ))
                        .toPad(horizontal: 15, bottom: 5)),
              ].toColumn(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
              ),
            ),
            ),
            ))
        ).toPositionedAlign(alignment: AlignmentDirectional.bottomCenter),
      ),
    ].toStack();
  }

  void _updateMarker({required bool isMarkerSelected}) {
    // Keep marker currency symbol in sync with the user's preferred currency
    selectedCurrencySymbol = mapfiltercontroller.getCurrencySymbol();
    for (final (index, element) in mapfiltercontroller.searchListingList.indexed) {
      if (element.id == _selectedId.value) {
        markerlist.remove(MarkerId(element.id.toString()));
        String baseprice = mapfiltercontroller.getprice(
            element?.listingData?.basePrice, element?.listingData?.currency);
        Place place = Place(
            id: element.id.toString(),
            title: element.title,
            position: LatLng(element.lat ?? 0.0, element.lng ?? 0.0),
            price: baseprice);
        placesList.add(place);
        mapfiltercontroller.placeToMarker(place,
            isMarkerSelected: isMarkerSelected, onTap: () {
              _updateMapWidgetHeight(_maxHeight);
              _selectedId.value = element.id;
              _movetoindex(index);
            }, selectedId: _selectedId).then((marker) {
          markerlist.add(marker);
          _selectedId.refresh();
        });
      }
    }
  }

  void _getMarker({required List<dynamic> searchList}) {
    // Keep marker currency symbol in sync with the user's preferred currency
    selectedCurrencySymbol = mapfiltercontroller.getCurrencySymbol();
    for (final (index, element)
    in searchList.indexed) {
      String baseprice = mapfiltercontroller.getprice(
          element?.listingData?.basePrice, element?.listingData?.currency);
      Place place = Place(
          id: element.id.toString(),
          title: element.title,
          position: LatLng(element.lat ?? 0.0, element.lng ?? 0.0),
          price: baseprice);
      placesList.add(place);
      mapfiltercontroller
          .placeToMarker(place, isMarkerSelected: true, onTap: () {
        _updateMapWidgetHeight(_maxHeight);
        _selectedId.value = element.id;
        _movetoindex(index);
      }, selectedId: _selectedId).then((marker) {
        markerlist.add(marker);
        if (mapfiltercontroller.searchListingList.last.id == element.id) {
          _selectedId.refresh();
        }
      });
    }
  }

  Future<void> _updateMapWidgetHeight(double height) async {
    if (Platform.isIOS && (height == _maxHeight)) {
    }
    mapfiltercontroller.listingsWidgetHeight.value = height;
  }

  @override
  void dispose() {
    googlemapController?.dispose();
    googlemapController = null;
    super.dispose();
  }

  void _movetoindex(int index) {
    if (!_mapListingScrollController.hasClients) return;

    // Item slot width = item width + inter-item end padding (18)
    const double itemEndPadding = 18.0;
    // Leading padding applied on the ListView (.toPad(horizontal: 15)) + first-item start pad (2)
    const double leadingPadding = 15.0 + 2.0;

    final double itemWidth = deviceWidth * 0.8;
    final double slotWidth = itemWidth + itemEndPadding;
    final double viewportWidth = deviceWidth;

    // Center-align: position item center at viewport center
    double offset =
        (slotWidth * index) - (viewportWidth / 2) + (itemWidth / 2) + leadingPadding;

    // Clamp to valid scroll range (handles first/last items & small datasets)
    final double maxOffset = _mapListingScrollController.position.maxScrollExtent;
    offset = offset.clamp(0.0, maxOffset);

    _mapListingScrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }
}