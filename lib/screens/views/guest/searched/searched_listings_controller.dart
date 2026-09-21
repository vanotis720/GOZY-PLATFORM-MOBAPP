import 'dart:async';

import 'package:built_collection/src/list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/config/client.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/graphql/SearchListing/__generated__/SearchListing.data.gql.dart';
import 'package:gozy/graphql/SearchListing/__generated__/SearchListing.req.gql.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/guest/filter/guest_filter_controller.dart';
import 'package:gozy/utils/late_init.dart';
import 'package:gozy/widgets/common_extension_functions.dart';

class SearchedListingsController extends BaseController {
  List<dynamic> searchListingList = [];
  int searchListingListCount = 0;
  Late<GuestFilterController> guestFilterController = Late();
  ScrollController searchListScrollController = ScrollController();
  RxDouble listingsWidgetHeight = 0.0.obs;
  RxInt searchCurrentpage = 1.obs;
  RxDouble filderSize = 0.0.obs;
  Timer? guestFilterFetchtimer;
  int _requestCount = 0;
  Map<String, dynamic> SearchedParams = {};

  @override
  void onReady() {
    _requestCount = 0;
    super.onReady();
  }

  Future<void> searchListing() async {
    if ((Get.isBottomSheetOpen ?? false) &&
        Get.currentRoute == '/guestHomePage' &&
        guestFilterController.val.guestHomeController.isSearchSelected.value) Get.back();

    if (guestFilterFetchtimer != null &&
        guestFilterFetchtimer!.isActive &&
        (Get.currentRoute != '/guestHomePage' ||
            !guestFilterController.val.guestHomeController.isSearchSelected.value)) {
      return;
    }
    debugPrint("_requestCount: $_requestCount");
    if (searchCurrentpage.value == 1) {
      _requestCount++;
    } else {
      _requestCount = 0;
    }
    debugPrint("_requestCount: 2 $_requestCount");
    await _getSearchListingsData();
  }

  Future<String> _getSearchListingsData() async {
    final Completer<String> completer = Completer<String>();
    final params = GSearchListingReq((b) => b
      ..vars.bookingType = guestFilterController.val.instantbookNotifier.value ? 'instant' : ''
      ..vars.transmission = guestFilterController.val.transmissionNotifier.value ? 1 : 0
      ..vars.make = guestFilterController.val.guestHomeController.makeType
      ..vars.dates = _getDates(guestFilterController.val.selectedDates)
      ..vars.carFeatures = ListBuilder<int>(guestFilterController.val.rxSelectedCarFeatures.value)
      ..vars.priceRange = ListBuilder<int>((guestFilterController.val.rangeValues.value.start !=
                      guestFilterController.val.Rangestart ||
                  guestFilterController.val.rangeValues.value.end != guestFilterController.val.Rangeend) &&
              (guestFilterController.val.rangeValues.value.end != 0 &&
                  guestFilterController.val.rangeValues.value.start != 0)
          ? [
              guestFilterController.val.rangeValues.value.start.toInt(),
              guestFilterController.val.rangeValues.value.end.toInt()
            ]
          : [])
      ..vars.carRules = ListBuilder<int>(guestFilterController.val.rxSelectedCarRules.value)
      ..vars.address = guestFilterController.val.rxSelectedLocation.value
      ..vars.carType = ListBuilder<int>(guestFilterController.val.rxSelectedCarType.value)
      ..vars.currency = appPreference.preferredCurrency
      ..vars.currentPage = searchCurrentpage.value
      ..vars.build());


    FerryLoggerClient.makeRequest(params, this, _getSearchListingsData,
            isViewErrorMessage: false, isToGet400Message: true)
        ?.then((res) {
      SearchedParams = params.varsToJson();
      SearchedParams["makeType"] = guestFilterController.val.guestHomeController.rxMakeTypeValue.value;
      guestFilterController.val.guestHomeController.SearchedParams = SearchedParams;
      GSearchListingData searchListingData = res.data as GSearchListingData;
      List<dynamic> searchlist = searchListingData.searchListing?.results?.toList() ?? [];
      searchListingListCount = searchListingData.searchListing?.count ?? 0;
      searchListScrollController = ScrollController();
      debugPrint("_requestCount: 3 $_requestCount---$searchCurrentpage");
      if (searchCurrentpage.value == 1) {
        _requestCount--;
        if (_requestCount <= 0) {
          searchListingList = searchlist;
          isLoading.value = false;
          update();
        } else {
          Future.delayed(const Duration(milliseconds: 3000)).then((value) {
            searchListingList = searchlist;
            isLoading.value = false;
            update();
          });
        }
      } else {
        searchListingList = searchListingList + searchlist;
        isLoading.value = false;
        update();
      }
      completer.complete("");
    });

    return completer.future;
  }

  String? _getDates(List<DateTime> value) {
    if (value.length == 2) {
      return '${(value[0].toString().split(' ')[0])} AND ${(value[1].toString().split(' ')[0])}';
    }
    return null;
  }

  void setRecentSearchQuries() {
    debugPrint("SearchedParams: $SearchedParams");
    if (SearchedParams.isNotEmpty) {
      guestFilterController.val.instantbookNotifier.value =
          SearchedParams['bookingType'].toString().isNotEmpty;
      guestFilterController.val.transmissionNotifier.value = SearchedParams['transmission'] == 1;
      guestFilterController.val.guestHomeController.makeType = SearchedParams['make'];
      guestFilterController.val.guestHomeController.change(rxVariable: guestFilterController.val.guestHomeController.rxMakeTypeValue, value: SearchedParams['makeType']);
      debugPrint("SearchedParams: $SearchedParams");
      guestFilterController.val.change(
          rxVariable: guestFilterController.val.rxSelectedCarType,
          value: List<int>.from(SearchedParams['carType'].cast<int>()));
      guestFilterController.val.change(
          rxVariable: guestFilterController.val.rxSelectedCarFeatures,
          value: List<int>.from(SearchedParams['carFeatures'].cast<int>()));
      guestFilterController.val.change(
          rxVariable: guestFilterController.val.rxSelectedCarRules,
          value: List<int>.from(SearchedParams['carRules'].cast<int>()));
      guestFilterController.val
          .change(rxVariable: guestFilterController.val.rxSelectedLocation, value: SearchedParams['address']);
      if (SearchedParams['priceRange'] != null && SearchedParams['priceRange'].isNotEmpty) {
        guestFilterController.val.rangeValues.value = RangeValues(
            double.parse(SearchedParams['priceRange'].cast<int>()[0].toString()),
            double.parse(SearchedParams['priceRange'].cast<int>()[1].toString()));
      } else {
        guestFilterController.val.rangeValues.value =
            RangeValues(guestFilterController.val.Rangestart ?? 0, guestFilterController.val.Rangeend ?? 0);
      }

      if (SearchedParams['dates'] != null) {
        guestFilterController.val.selectedDates.value = _getFilterDates(SearchedParams['dates']);
      } else {
        guestFilterController.val.selectedDates.clear();
      }

      debugPrint(
          "setRecentSearchQuries: amenitiessearch: ${guestFilterController.val.rxSelectedCarType.value}---$SearchedParams");
    }
  }

  List<DateTime> _getFilterDates(String dates) {
    var datelist = dates.split('AND');
    List<DateTime> dateTimeList = [];
    dateTimeList.add(DateTime.parse(datelist[0].trim()));
    dateTimeList.add(DateTime.parse(datelist[1].trim()));
    return dateTimeList;
  }


  String getprice(double? basePrice, String? itemCurrency) {
    return double.parse(basePrice?.toString() ?? '0')
        .currencyConverted(convertedCurrency: itemCurrency ?? defaultCurrency);
  }

  void clear() {
    _requestCount = 0;
    searchListingList.clear();
    searchListingListCount = 0;
    searchCurrentpage.value = 1;
    SearchedParams.clear();
  }
}