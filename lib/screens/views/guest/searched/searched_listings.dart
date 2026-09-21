import 'dart:async';
import 'package:gozy/resources/app_colors.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/explore_listing_item_widgets.dart';
import 'package:gozy/widgets/where_to_go_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/screens/views/guest/filter/guest_filter_controller.dart';
import 'package:gozy/screens/views/guest/searched/searched_listings_controller.dart';
import 'package:gozy/screens/views/home/home_controller.dart';
import 'package:gozy/screens/views/home/home_navigator.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/conditional_parent_widget.dart';
import 'package:gozy/widgets/common/custom_button/custom_button.dart';
import 'package:gozy/widgets/common/custom_container/custom_container.dart';
import 'package:gozy/widgets/custom_stateful_widget.dart';
import 'package:gozy/widgets/custom_text.dart';
import 'package:gozy/widgets/rect_getter.dart';
import 'package:gozy/widgets/shimmer.dart';

import '../../../../widgets/custom_empty_view.dart';

class SearchedListingsScreen extends CustomStatefulWidget {
  final HomeController controller;
  const SearchedListingsScreen({key, required  this.controller}) : super(key: key);

  @override
  SearchedListingsScreenState createState() => SearchedListingsScreenState();
}

class SearchedListingsScreenState extends CustomStatefulWidgetState<SearchedListingsScreen> with SingleTickerProviderStateMixin{
  late SearchedListingsController searchedListingsController = Get.find();
  StreamSubscription? _streamSubscription;
  bool  listingTopPaddingNeeded = false;
  List<DateTime> selectedFilterDates = [];

  String mapIcon = Assets.drawableSearchedMap;

  @override
  void initState() {
    searchedListingsController.guestFilterController.val = widget.controller.GuestFilterController !=null ? widget.controller.GuestFilterController as GuestFilterController :Get.find<GuestFilterController>();
    searchedListingsController.guestFilterController.val.guestHomeController = widget.controller;
    searchedListingsController.isLoading.value = true;
    if(widget.controller.selectedPopularLocation.isNotEmpty) {
      searchedListingsController.change(rxVariable: searchedListingsController.guestFilterController.val.rxSelectedLocation, value: widget.controller.selectedPopularLocation);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint("SearchedParams: 3 ${searchedListingsController.guestFilterController.val.guestHomeController.SearchedParams}");
      if(Get.currentRoute == '/guestHomePage'){
        if(widget.controller.isSearchSelected.value && searchedListingsController.guestFilterController.val.guestHomeController.SearchedParams.isNotEmpty){
          searchedListingsController.SearchedParams = searchedListingsController.guestFilterController.val.guestHomeController.SearchedParams;
          searchedListingsController.setRecentSearchQuries();
          searchedListingsController.guestFilterController.val.isFilterSelected();
        }

          searchedListingsController.searchListScrollController.jumpTo(0);
          searchedListingsController.searchCurrentpage.value = 1;
          searchedListingsController.searchListingList.clear();
          searchedListingsController.checkNetwork(searchedListingsController.searchListing);
          _streamSubscription =  searchedListingsController.guestFilterController.val.guestHomeController.isSearchSelected.stream.listen((event) {
            if(event){
              if (searchedListingsController.searchListScrollController.hasClients) {
                searchedListingsController.searchListScrollController.jumpTo(0);
              }
              searchedListingsController.searchCurrentpage.value = 1;
              searchedListingsController.searchListingList.clear();
              searchedListingsController.checkNetwork(searchedListingsController.searchListing);
            }else{
              searchedListingsController.guestFilterController.val.guestHomeController.SearchedParams.clear();
            }
          });
      }
    });
    selectedFilterDates =searchedListingsController.guestFilterController.val.selectedDates;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch(overALLThemeType){
      case 1:
        mapIcon = Assets.homeMapIcon;
      case 2:
        mapIcon = Assets.drawableFamousLocation;
        listingTopPaddingNeeded = true;
      case 3:
        mapIcon = Assets.theme3Map;
      case 4:
        mapIcon = Assets.theme4Theme4Location;
        listingTopPaddingNeeded = true;
      default:
        mapIcon = Assets.homeMapIcon;
    }
    return CustomScaffold(
      controller: widget.controller,
      body: showContentDataWidget(),
      customAppBarFunction: _backpressFunction,
      backgroundColor: overALLThemeType == 2 ? appColors.white : null,
    );
  }

  Widget showContentDataWidget() {
    return [
      20.toHeight(),
      GetBuilder(
        id: searchedListingsController.guestFilterController.val.rxSelectedLocation.id,
        init: searchedListingsController.guestFilterController.val,
        builder: (context) {
        String selectedLoc = searchedListingsController.guestFilterController.val.rxSelectedLocation.value;
        bool isFilterSelected = searchedListingsController.guestFilterController.val.rxIsFiltersSelected.value;
        return WhereToGoSection(
          isShowDot: isFilterSelected,
          themeType: overALLThemeType,
          leadingIcon: overALLAppLayoutModel?.backIcon,
          fillColor: isFilterSelected ? appColors.theme4AppBarBg : appColors.white,
          showingLocationText: selectedLoc.isEmpty ? '${label_destination.tr}, ${label_city.tr.toLowerCase()}, ${address.tr.toLowerCase()}' : selectedLoc,
          HighlightColor: isFilterSelected ? appColors.secondaryColor : null,
          selectedLocationEmpty: selectedLoc.isEmpty,
          iconColor:  isFilterSelected ? appColors.black : appColors.black,
          onBackPress: _backpressFunction,
          onTapSearchLocation: () {
            widget.controller.GuestFilterController =  searchedListingsController.guestFilterController.val;
            widget.controller.homeNavigator!.navigateScreen(HomeScreen.FilterLocation, controller:widget.controller.GuestFilterController );
          },
          onTapFilter: () {
            searchedListingsController.setRecentSearchQuries();
            widget.controller.GuestFilterController =  searchedListingsController.guestFilterController.val;
            widget.controller.homeNavigator!.navigateScreen(HomeScreen.filter,controller:  widget.controller);
          },
        ).toPad(bottom: 12);
      }
      ).toPad(
        horizontal: AppDimen.startMargin,
      ),
      ConditionalParentWidget(
          condition: overALLThemeType == 4 || overALLThemeType == 2,
          parentBuilder: (child) => CustomContainer(
            color: overALLThemeType == 2 ? appColors.myTripsBGColor : appColors.theme4AppBarBg,
            body: child,
          ),
          child: _showSearchListingView()
      ).toStretch(),
    ].toColumn();
  }

  Widget _showSearchListingView() {
    double itemWidth = (deviceWidth - 35.0);
    return  [
        Obx(() {
          bool isEmpty = !searchedListingsController.isLoading.value && searchedListingsController.searchListingList.isEmpty;
          if(searchedListingsController.guestFilterFetchtimer != null) {
            isEmpty =  isEmpty && !(searchedListingsController.guestFilterFetchtimer!.isActive);
          }
         return toReviewList(
            reviewListScrollController: searchedListingsController
                .searchListScrollController,
            reviewList: searchedListingsController.searchListingList,
            reviewsCount: searchedListingsController.searchListingListCount,
            onApiFunction: searchedListingsController.searchListing,
            controller: searchedListingsController,
            currentPage: searchedListingsController.searchCurrentpage,
            isDisableLoader: true,
            bottomPosition: bottomPadForExtendBody,
            listView: searchListWidget(
              count: searchedListingsController.searchListingList.isNotEmpty
                ? searchedListingsController.searchListingList.length
                : searchedListingsController.isLoading.value ? 5 : 0,
              isDateFilterSelected: !searchedListingsController.isLoading.value &&
                searchedListingsController.searchListingList.isNotEmpty &&
                selectedFilterDates.isNotEmpty,
              itemWidth: itemWidth
            ),
           emptyWidget: isEmpty ? _showEmptyWidget() : null
          ).toShimmer(controller: searchedListingsController).toPad(top: listingTopPaddingNeeded ? 10 : 0);
        }),

        Obx(() =>
        (!searchedListingsController.isLoading.value && searchedListingsController.searchListingList.isNotEmpty) ?
        CancelButton(
          isButtonLayout: false,
          height: 40,
          borderRadius: AppDimen.appBorderRadius,
          buttonText:btn_search_in_map.tr,
          color: appColors.secondaryColor,
          fillcolor: appColors.secondaryColor,
          textColor: AppColors.staticwhite,
          horizontalPadding: 12,
          isExpand: false,
          mapIcon: mapIcon,
          mapSize: 18,
          mapColor: AppColors.staticwhite,
          onTap: () {
            widget.controller.homeNavigator!.navigateScreen(HomeScreen.FilterMapListings, param:{'controller':  searchedListingsController.guestFilterController.val,'selectedFilterDates':selectedFilterDates},controller:  widget.controller);
          }
        ) :
        const SizedBox.shrink()).toPad(bottom: 30).toPositionedAlign(alignment: AlignmentDirectional.bottomCenter),
    ].toStack();

  }

  CustomEmptyView _showEmptyWidget() {
    return CustomEmptyView(
      emptyImageWidget: [
        Assets.drawableEmptyCommonCloud.toSVG(),
        Assets.drawableEmptySearchListings.toSVG(),
      ].toStack(),
      emptyTitle: label_no_results.tr,
      emptyTitleFontSize: AppDimen.textSize_20,
      emptyTitleFontWeight: AppFont.medium,
      emptyDescription: label_no_result_content.tr,
      descriptionTitleFontSize: AppDimen.textSize_14,
    );
  }


  @override
  void dispose() {
    searchedListingsController.searchListingList.clear();
    _streamSubscription?.cancel();
    searchedListingsController.clear();
    super.dispose();
  }

  Widget searchListWidget({required int count, required bool isDateFilterSelected, required double itemWidth}){
    return  List.generate(
      count, (index) {
        var item;
        if (searchedListingsController.searchListingList.isNotEmpty) {
          item = searchedListingsController.searchListingList[index];
        }
        bool isload = (searchedListingsController.isLoading.value && searchedListingsController.searchListingList.isEmpty || (searchedListingsController.guestFilterFetchtimer !=null && searchedListingsController.guestFilterFetchtimer!.isActive));
        bool isshimmerloading = isload ;
        return Center(
          child: ShimmerLoading(
              isLoading:  isshimmerloading ,
              widgetType: 'searchListing',
              isDarkMode: widget.controller.isDarkMode(),
              child: getRecommandedItem(
                  listing_data: item,
                  itemWidth: itemWidth,
                  instantBookIcon: overALLAppLayoutModel?.instantBookIcon,
                  themeType: overALLThemeType,
                  borderRadius: overALLThemeType == 3 ? 30 : AppDimen.appBorderRadius,
                  itemHeight: 165,
                  type: 'search',
                  currencySymbol: searchedListingsController.getCurrencySymbol(),
                  isshimmerview: isshimmerloading,
                  controller: widget.controller,

                  onListDetailTap: (recommendResults) {
                    if(!isload) {
                      widget.controller.homeNavigator!.navigateScreen(
                        HomeScreen.itemDetail,
                        param: [recommendResults, "search", selectedFilterDates, searchedListingsController.guestFilterController.val.guestCount.value],
                        controller: searchedListingsController,
                      );
                    }
                  },

                  listpriceHeight: AppDimen.textSize_22)
                  .toPad(bottom: AppDimen.startMargin)),
        );
      },
    ).toScroll(padding: pad(top: 20, w: AppDimen.startMargin, bottom: (!searchedListingsController.isLoading.value && searchedListingsController.searchListingList.isNotEmpty) ? 50 : 24),scrollController: searchedListingsController.searchListScrollController,physics: AlwaysScrollableScrollPhysics());
  }



  void _backpressFunction() {
    widget.controller.GuestFilterController = null;
    searchedListingsController.change(rxVariable: searchedListingsController.guestFilterController.val.rxSelectedLocation, value: '');
    searchedListingsController.guestFilterController.val.change(rxVariable: searchedListingsController.guestFilterController.val.rxIsFiltersSelected, value: false);
    searchedListingsController.guestFilterController.val.clearFilters();
    searchedListingsController.guestFilterController.val.guestHomeController.isSearchSelected.value = false;
  }
}