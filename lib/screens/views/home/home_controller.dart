import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/app.dart';
import 'package:gozy/config/client.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/home/home_navigator.dart';
import 'package:gozy/utils/common_api_controller.dart';

import '../../../../graphql/ExploreListing/__generated__/explore_list.data.gql.dart';
import '../../../../graphql/ExploreListing/__generated__/explore_list.req.gql.dart';
import '../../../graphql/currency/__generated__/currency.data.gql.dart';
import '../../../graphql/currency/__generated__/currency.req.gql.dart';

class HomeController extends BaseController {
  @override
  HomeNavigator? homeNavigator;
  Map<String, dynamic>? passingArg;
  var rxSelectedTab = ReactiveVariable("rxSelectedTab", -1);

  RxBool checkEmptyData = false.obs;
  var isSearchSelected = false.obs;
  var isExploreDataReceived = false.obs;
  var isToUpdateExplore = false.obs;

  RxString selectedStartTime = "".obs;
  RxString selectedEndTime = "".obs;

  String selectedPopularLocation = '';
  BaseController? GuestFilterController;

  GgetExploreListingsData_getPopularLocations? popularLocationsResponse;

  GgetExploreListingsData? getExploreListingsData;

  Map<String, List<dynamic>> filterItems = {};
  Map<String, int> filterItemsCount = {};
  var makeCurrentpage = 1.obs;
  Map<String, dynamic> SearchedParams = {};
  var makeType = 0;
  var rxMakeTypeValue = ReactiveVariable("rxMakeTypeValue", '');
  Color bottomNavigationBGColor = Colors.white;

  @override
  void onReady() {
    homeNavigator = HomeNavigator();
    isShowLoader = false;
    super.onReady();
  }

  void getCurrencyRateValues() {
    if (playStoreLink.isEmpty || appStoreLink.isEmpty) {
      checkNetwork(getVersionUpdate);
    } else if (currencyRates == null) {
      getCurrencyRates().then((value) async {
        checkNetwork(getHomeBannerData);
      });
    } else {
      checkNetwork(getHomeBannerData);
    }
  }

  void getHomeBannerData() {
    getHomePageBannerData().then((homebanner) {
      homeBannerData = homebanner;
      checkNetwork(getExploreListings);
    });
  }

  void getExploreListings() {
    debugPrint('getExploreListingData request --> ${DateTime.now()}');
    final params = GgetExploreListingsReq((b) => b..vars.build());
    FerryLoggerClient.makeRequest(params, this, getExploreListings, isViewLoader: false)?.then((res) async {
      print('getExploreListingData response --> ${DateTime.now()} <-> ${res.data}');
      if (res.data != null) {
        getExploreListingsData = res.data as GgetExploreListingsData;
        popularLocationsResponse = getExploreListingsData?.getPopularLocations;
        debugPrint(
            'getExploreListingData --> ${getExploreListingsData?.getRecommend?.results?.length} --- ${DateTime.now()}');
        if (!(Get.currentRoute == "/GuestFilterScreen")) {
          filterItems.clear();
        }
        isLoading.value = false;
        isExploreDataReceived.value = true;
        isExploreDataReceived.refresh();
        Get.forceAppUpdate();
      }
    });
  }

  Future<void> getVersionUpdate() async {
    versionCode = await App().getVersion();
    String appType = Platform.isAndroid ? "androidVersion" : "iosVersion";
    final params = GgetVersionReq((b) => b
      ..vars.version = versionCode
      ..vars.appType = appType
      ..vars.build());
    FerryLoggerClient.makeRequest(params, this, getVersionUpdate,
            isViewErrorMessage: false, isViewLoader: false, isToGet400Message: true)
        ?.then((res) async {
      if (res.data != null) {
        var response = res.data as GgetVersionData;
        var resultStatus = response.getApplicationVersionInfo?.status;
        playStoreLink = response.getApplicationVersionInfo?.result?.playStoreUrl ?? "";
        appStoreLink = response.getApplicationVersionInfo?.result?.appStoreUrl ?? "";
        if (resultStatus != 200) {
          if (!Get.isDialogOpen!) {
            if (appType == 'androidVersion') {
              showUpdateDialog(playStoreLink);
            } else {
              showUpdateDialog(appStoreLink);
            }
          }
        } else {
          checkNetwork(getCurrencyRateValues);
        }
      }
    });
  }
}