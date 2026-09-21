import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:gozy/config/client.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/graphql/FilterData/__generated__/filter_data.data.gql.dart';
import 'package:gozy/graphql/FilterData/__generated__/filter_data.req.gql.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/home/home_controller.dart';
import 'package:gozy/utils/text_editing_controller.dart';
import 'package:gozy/widgets/bottom_sheet/bottom_sheet_refresh_controller.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/owner/step_item_model.dart';

class GuestFilterController extends BaseController {
  RxInt guestCount = 0.obs;

  final instantbookNotifier = ValueNotifier<bool>(false);
  final transmissionNotifier = ValueNotifier<bool>(false);
  Map<String, dynamic> selectedFilters = {};
  var rxSelectedCarType = ReactiveVariable("rxSelectedCarType", <int>[]);
  var rxSelectedCarFeatures = ReactiveVariable("rxSelectedCarFeatures", <int>[]);
  var rxSelectedCarRules = ReactiveVariable("rxSelectedCarRules", <int>[]);
  RxList<DateTime> selectedDates = <DateTime>[].obs;
  var rxSavedDates = ReactiveVariable("rxSavedDates", <DateTime>[]);
  var rangeValues = RangeValues(0, 0).obs;
  var rxSelectedLocation = ReactiveVariable("rxSelectedLocation", '');
  HomeController guestHomeController = Get.find();
  var rxIsFiltersSelected = ReactiveVariable("rxIsFiltersSelected", false);
  var rxIsReset = ReactiveVariable("rxIsReset", false);
  double? Rangestart, Rangeend;

  List<Map<String, String>> locationList = <Map<String, String>>[];
  TextEditingController locationNameController = CustomTextEditingController();
  CustomTextEditingController searchEditController = CustomTextEditingController();
  RxInt searchBarStatus = 0.obs;
  GgetListingSettingsCommonData? getListingSettingsCommonData;
  String  searchingType = 'make';
  Map<String, dynamic> oldFilteredItems = {};
  RxBool isLinearLoading = false.obs;

  BottomSheetController bottomSheetController = Get.find();

  @override
  void onReady() {
    selectedFilters['dates'] = '';
    selectedFilters['personCapacity'] = '';
    selectedFilters['bookingType'] = '';
    selectedFilters['priceRange'] = '';
    selectedFilters['roomType'] = '';
    selectedFilters['houseType'] = '';
    selectedFilters['bedrooms'] = '';
    selectedFilters['beds'] = '';
    selectedFilters['bathrooms'] = '';
    selectedFilters['amenities'] = '';
    selectedFilters['spaces'] = '';
    selectedFilters['houseRules'] = '';

    super.onReady();
  }

  void getFilterItems() {
    final params = GgetListingSettingsCommonReq((b) => b
      ..vars.isValue = true
      ..vars.build());
    FerryLoggerClient.makeRequest(params, this, getFilterItems, isViewLoader: false)?.then((res) async {
      debugPrint('GgetListingSettingsCommonReq response --> ${DateTime.now()}');
      if (res.data != null) {
        getListingSettingsCommonData = res.data as GgetListingSettingsCommonData;
        guestHomeController.filterItems.clear();
        _getFilteredItems();
        isLoading.value = false;
        guestHomeController.isLoading.value = false;
        guestHomeController.GuestFilterController?.isLoading.value = false;
        if (rangeValues.value.end == 0) {
          clearFilters();
        }
      }
    });
  }

  void _getFilteredItems() {
    guestHomeController.filterItems['dates'] = [];
    if (getListingSettingsCommonData?.getSearchSettings != null &&
        getListingSettingsCommonData?.getSearchSettings?.results != null &&
        getListingSettingsCommonData?.getSearchSettings?.status == 200) {
      List<Map<String, dynamic>> searchitems = [];
      Map<String, dynamic> searchsettingsmap = {};
      searchsettingsmap['id'] = 7685;
      searchsettingsmap['priceRangeCurrency'] =
          getListingSettingsCommonData?.getSearchSettings?.results?.priceRangeCurrency;
      searchsettingsmap['startValue'] = getListingSettingsCommonData?.getSearchSettings?.results?.minPrice;
      searchsettingsmap['endValue'] = getListingSettingsCommonData?.getSearchSettings?.results?.maxPrice;
      searchitems.add(searchsettingsmap);
      guestHomeController.filterItems['priceRange'] = searchitems;
    }
    getListingSettingsCommonData?.getListingSettingsCommon?.results!.forEach((item) {
      if (item?.isEnable == '1' && item?.typeName == 'make') {
        List<StepItemModel> makelist = [];
        item?.listSettings?.forEach((listsetting) {
          StepItemModel stepItemModel = StepItemModel(
            id: listsetting?.id,
            itemName: listsetting?.itemName,
            dynamicItemName: listsetting?.dynamicItemName,
          );
          makelist.add(stepItemModel);
        });
        guestHomeController.filterItems[item!.typeName!] = makelist;
      } else if (item?.isEnable == '1') {
        guestHomeController.filterItems[item!.typeName!] = item.listSettings?.toList() ?? [];
      }
      guestHomeController.filterItemsCount[item!.typeName!] = item.count ?? 1;
    });
  }

  void setvalues() {
    if (!guestHomeController.isSearchSelected.value ||
        (guestHomeController.filterItems.isEmpty || rangeValues.value.end <= 0.0)) {
      guestHomeController.isLoading.stream.listen((event) {
        Future.delayed(const Duration(milliseconds: 100)).then((value) {
          change(rxVariable: rxSelectedLocation, value: guestHomeController.selectedPopularLocation);
          bool isfilterEmpty = guestHomeController.filterItems.isEmpty;
          if (guestHomeController.filterItems.isNotEmpty) {
            guestHomeController.filterItems = guestHomeController.filterItems;
          }
          if (isfilterEmpty) {
            clearFilters();
          }
        });
      });
      if (guestHomeController.filterItems.isNotEmpty) {
        guestHomeController.filterItems = guestHomeController.filterItems;
        clearFilters();
      }
    }
  }

  void clearFilters() {
    if (guestHomeController.filterItems.isNotEmpty) {
      Rangestart = double.parse(
          double.parse(guestHomeController.filterItems['priceRange']![0]['startValue'].toString())
              .currencyConverted(
                  convertedCurrency:
                      guestHomeController.filterItems['priceRange']![0]['priceRangeCurrency'].toString()));
      Rangeend = double.parse(
          double.parse(guestHomeController.filterItems['priceRange']![0]['endValue'].toString())
              .currencyConverted(
                  convertedCurrency:
                      guestHomeController.filterItems['priceRange']![0]['priceRangeCurrency'].toString()));
      rangeValues.value = RangeValues(Rangestart!, Rangeend!);
    }
    guestCount.value = 1;
    instantbookNotifier.value = false;
    transmissionNotifier.value = false;
    rxSelectedCarType.value.clear();
    rxSelectedCarFeatures.value.clear();
    rxSelectedCarRules.value.clear();
    selectedDates.clear();
    rxSavedDates.value.clear();
    guestHomeController.change(rxVariable: guestHomeController.rxMakeTypeValue, value: '');
    guestHomeController.makeType = 0;
    isLoading.refresh();
  }

  bool isFilterSelected() {
    change(
        rxVariable: rxIsFiltersSelected,
        value: Rangestart != null &&
            (rangeValues.value != RangeValues(Rangestart!, Rangeend!) ||
                guestCount.value != 1 ||
                instantbookNotifier.value != false ||
                transmissionNotifier.value != false ||
                rxSelectedCarType.value.isNotEmpty ||
                rxSelectedCarFeatures.value.isNotEmpty ||
                rxSelectedCarRules.value.isNotEmpty ||
                guestHomeController.makeType != 0 ||
                rxSavedDates.value.isNotEmpty));
    return rxIsFiltersSelected.value;
  }

   void getFilterPaginationData(){
     final String currentSearchText = searchEditController.Ttext;

     // Stop pagination if we've already loaded all items
     if (guestHomeController.makeCurrentpage.value > 1 &&
         (guestHomeController.filterItems[searchingType]?.length ?? 0) >= (guestHomeController.filterItemsCount[searchingType] ?? 0)) {
       isLinearLoading.value = false;
       return;
     }

     final params = GgetListSettingsItemNameReq((b) => b
       ..vars.currentPage = guestHomeController.makeCurrentpage.value
       ..vars.typeName = searchingType
       ..vars.searchList = currentSearchText
       ..vars.build());

     FerryLoggerClient.makeRequest(
       params,
       this,
       getFilterPaginationData,
       isToGet400Message: true,
       isViewErrorMessage: false // Suppress "No record found" toaster during scrolling
     )?.then((res) async {
       debugPrint('getFilterPaginationData response --> ${DateTime.now()}');
       
       // Handle case where search text changed before response arrived
       if (currentSearchText != searchEditController.Ttext) return;

       List<StepItemModel> itemlist = [];
       if (res.data != null) {
         GgetListSettingsItemNameData  getListSettingsItemNameData = res.data as GgetListSettingsItemNameData;
         if(getListSettingsItemNameData?.getListSettingsItemName?.status == 400){
           isLinearLoading.value = false;
           // Don't clear existing data on pagination error (Case: "No record found" for next page)
           if (guestHomeController.makeCurrentpage.value == 1) {
              guestHomeController.filterItems[searchingType] = [];
              guestHomeController.filterItemsCount[searchingType] = 0;
           }
           guestHomeController.showSnackBar(getListSettingsItemNameData?.getListSettingsItemName?.errorMessage,
               isltralign: true);
           bottomSheetController.change(rxVariable: bottomSheetController.isUpdateItemList, value: true);
           return;
         }
         if(searchingType =='make') {
           getListSettingsItemNameData.getListSettingsItemName?.results?.forEach((listsetting){
             StepItemModel stepItemModel = StepItemModel(
               id: listsetting?.id,
               itemName:listsetting?.itemName,
               dynamicItemName: (listsetting as dynamic).dynamicItemName,
             );
             itemlist.add(stepItemModel);
           });
           if(guestHomeController.makeCurrentpage.value !=1) {
             guestHomeController.filterItems[searchingType]?.addAll(itemlist);
           } else {
             guestHomeController.filterItems[searchingType] = itemlist;
           }
           isLoading.value = false;
         }
         guestHomeController.filterItemsCount[searchingType] =getListSettingsItemNameData.getListSettingsItemName?.count ?? 0;
       } else {
         if (guestHomeController.makeCurrentpage.value == 1) {
            guestHomeController.filterItems[searchingType] = [];
            guestHomeController.filterItemsCount[searchingType] = 0;
         }
       }

      bottomSheetController.change(rxVariable: bottomSheetController.isUpdateItemList, value: true);
      isLinearLoading.value = false;
      debugPrint(" isLinearLoading.value: ${isLinearLoading.value}");
    });
  }

  Future<void> searchPlaces(String value) async {
    if (value == locationNameController.text.toString()) {
      dynamic json;

      String autoCompleteUrl = "$GRAPHQL_DOMAIN/get_auto_complete_data";
      var headers = {"Content-Type": "application/json"};
      var input = {"input": value, "platformSecretKey": securityKey};
      debugPrint("autoCompleteUrl: $autoCompleteUrl $value");

      var response =
          await http.post(Uri.parse(autoCompleteUrl), headers: headers, body: convert.jsonEncode(input));
      json = convert.jsonDecode(response.body);

      if (json != null && value == locationNameController.text.toString()) {
        locationList.clear();
        if (json["status"] == 200 &&
            json["response"].isNotEmpty &&
            json["response"]['suggestions'].isNotEmpty) {
          for (var item in json["response"]['suggestions']) {
            Map<String, String> locationItem = {};
            locationItem['description'] = item['placePrediction']['text']['text'];
            locationItem['place_id'] = item['placePrediction']['placeId'];
            locationList.add(locationItem);
          }
        } else if (json["status"] == 400 && json['errorMessage'] != null) {
          debugPrint("json: $json");
          showToast(json['errorMessage']["error"]["message"]);
        }
      }
    }
  }

  @override
  void onResumed() {
    debugPrint("onResumed guestfilter");
    selectedDates.refresh();
    isLoading.value = false;
    super.onResumed();
  }
}