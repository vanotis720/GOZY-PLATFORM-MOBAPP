import 'dart:async';

import 'package:built_collection/src/list.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gozy/config/client.dart';
import 'package:gozy/graphql/propertycreation/__generated__/propertycreation.data.gql.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/utils/common_api_controller.dart';

import '../../../../constant.dart';
import '../../../../graphql/FilterData/__generated__/filter_data.data.gql.dart';
import '../../../../graphql/FilterData/__generated__/filter_data.req.gql.dart';
import '../../../../graphql/ListingSettings/__generated__/getListingSettings.data.gql.dart';
import '../../../../graphql/ListingSettings/__generated__/getListingSettings.req.gql.dart';
import '../../../../graphql/__generated__/listing_fragment.data.gql.dart';
import '../../../../graphql/__generated__/listing_fragment.req.gql.dart';
import '../../../../graphql/propertycreation/__generated__/propertycreation.req.gql.dart';
import '../../../../resources/app_lang.dart';
import '../../../../utils/text_editing_controller.dart';
import '../../../../widgets/bottom_sheet/bottom_sheet_refresh_controller.dart';
import '../../../../widgets/owner/step_item_model.dart';
import '../../../../widgets/rect_getter.dart';

class StepOneController extends BaseController {
  bool isFromAddressPage = false;
  BottomSheetController bottomSheetController = Get.find();
  Map<String,dynamic> argumentsmap = {};
  RxBool isStepOneLoading = false.obs;
  dynamic itemInfo;
  List<Map<String, dynamic>> stepone_layout_items = [];
  RxInt choosedIndex = 0.obs;
  RxInt selectedChipIndex = 0.obs;
  RxBool isUpdateSelectedItem = false.obs;
  String selectedType = "make";
  RxBool isLocationSelected = false.obs;
  RxBool isInitialMapLoad = true.obs;
  RxBool isLocationConfirmed = false.obs;
  late Rx<Widget> memoryImageProvider;
  var mapRectKey = RectGetter.createGlobalKey();

  List<GgetListingSettingsData_getListingSettings_results_carType_listSettings?> carTypes = [];
  List makeType = [];
  List model = [];
  List<GgetListingSettingsData_getListingSettings_results_year_listSettings?> year = [];
  List<GgetListingSettingsData_getListingSettings_results_odometer_listSettings?> odometer = [];
  List transmission = [];
  List<dynamic> carFeatures = [];

  RxInt selectedCarType = 0.obs;
  RxInt selectedMakeType = 0.obs;
  RxInt selectedYear = 0.obs;
  RxInt selectedModelType = 0.obs;
  RxInt selectedOdometerType = 0.obs;
  RxInt selectedTransmission = 1.obs;

  // Pagination & search state for Make/Model bottom sheets
  RxInt makeCurrentPage = 1.obs;
  RxInt modelCurrentPage = 1.obs;
  int makeItemsCount = 0;
  int modelItemsCount = 0;
  CustomTextEditingController makeSearchEditController = CustomTextEditingController();
  CustomTextEditingController modelSearchEditController = CustomTextEditingController();
  RxInt makeSearchBarStatus = 0.obs;
  RxInt modelSearchBarStatus = 0.obs;
  RxBool isLinearLoading = false.obs;
  Map<String, dynamic> oldMakeFilteredItems = {};
  Map<String, dynamic> oldModelFilteredItems = {};
  String _makeSearchedKey = '';
  String _modelSearchedKey = '';
  Timer? _makeDebounceTimer;
  Timer? _modelDebounceTimer;

  CustomTextEditingController streetController = CustomTextEditingController();
  CustomTextEditingController aptBuildingController = CustomTextEditingController();
  CustomTextEditingController cityController = CustomTextEditingController();
  CustomTextEditingController stateProvinceController = CustomTextEditingController();
  CustomTextEditingController zipCodeController = CustomTextEditingController();
  CustomTextEditingController countryController = CustomTextEditingController();
  String? selectedCountrycode;
  CustomTextEditingController countrySearchController = CustomTextEditingController();
  LatLng? addressLatLng;
  RxList<int> selectedCarFeatures = RxList<int>();
  GgetListingSettingsData? listingSettingData;
  GgetStep1ListingDetailsData? getListingData;

  int? listId;
  String apiCountryZipcode = '';


  void initSearchListeners() {
    makeSearchEditController.addListener(() {
      String searchText = makeSearchEditController.Ttext;
      debugPrint("makeSearchEditController: $searchText --- ${oldMakeFilteredItems.length}");

      if (searchText.isEmpty) {
        if (oldMakeFilteredItems.isNotEmpty) {
          makeType = oldMakeFilteredItems['items'] ?? [];
          makeCurrentPage.value = oldMakeFilteredItems['page'] ?? 1;
          makeItemsCount = oldMakeFilteredItems['count'] ?? 0;
          oldMakeFilteredItems.clear();
          bottomSheetController.change(rxVariable: bottomSheetController.isUpdateItemList, value: false);
        }
      } else {
        if (_makeSearchedKey != searchText) {
          if (oldMakeFilteredItems.isEmpty) {
            oldMakeFilteredItems['items'] = List.from(makeType);
            oldMakeFilteredItems['page'] = makeCurrentPage.value;
            oldMakeFilteredItems['count'] = makeItemsCount;
          }

          makeType = [];
          makeItemsCount = 0;
          bottomSheetController.change(rxVariable: bottomSheetController.isUpdateItemList, value: true);
          isLinearLoading.value = true;

          if (_makeDebounceTimer?.isActive ?? false) _makeDebounceTimer?.cancel();
          _makeDebounceTimer = Timer(Duration(milliseconds: searchDebounce), () {
            selectedType = 'make';
            makeCurrentPage.value = 1;
            checkNetwork(getFilterPaginationData);
            _makeSearchedKey = searchText;
          });
        }
      }
    });

    modelSearchEditController.addListener(() {
      String searchText = modelSearchEditController.Ttext;
      debugPrint("modelSearchEditController: $searchText --- ${oldModelFilteredItems.length}");

      if (searchText.isEmpty) {
        if (oldModelFilteredItems.isNotEmpty) {
          model = oldModelFilteredItems['items'] ?? [];
          modelCurrentPage.value = oldModelFilteredItems['page'] ?? 1;
          modelItemsCount = oldModelFilteredItems['count'] ?? 0;
          oldModelFilteredItems.clear();
          bottomSheetController.change(rxVariable: bottomSheetController.isUpdateItemList, value: false);
        }
      } else {
        if (_modelSearchedKey != searchText) {
          if (oldModelFilteredItems.isEmpty) {
            oldModelFilteredItems['items'] = List.from(model);
            oldModelFilteredItems['page'] = modelCurrentPage.value;
            oldModelFilteredItems['count'] = modelItemsCount;
          }

          model = [];
          modelItemsCount = 0;
          bottomSheetController.change(rxVariable: bottomSheetController.isUpdateItemList, value: true);
          isLinearLoading.value = true;

          if (_modelDebounceTimer?.isActive ?? false) _modelDebounceTimer?.cancel();
          _modelDebounceTimer = Timer(Duration(milliseconds: searchDebounce), () {
            selectedType = 'model';
            modelCurrentPage.value = 1;
            checkNetwork(getFilterPaginationData);
            _modelSearchedKey = searchText;
          });
        }
      }
    });
  }

  void getCountriesList() {
    if (countriesData == null) {
      getCountries().then((value) {
        checkNetwork(getListingSettings);
      });
    } else {
      getListingSettings();
    }
  }

  void initFromApi() {
    if (itemInfo != null) {
      final matchedCarType = carTypes.firstWhere(
        (car) => car?.itemName == itemInfo.carType, orElse: () => null
      );
      final matchedMakeType = makeType.firstWhere(
        (make) => make?.itemName == itemInfo.make, orElse: () => StepItemModel()

      );
      final matchedModel = model.firstWhere(
        (mod) => mod?.itemName == itemInfo.model, orElse: () => StepItemModel()
      );
      final matchedYear = year.firstWhere(
        (yearList) => yearList?.itemName == itemInfo.year, orElse: () => null
      );
      final matchedOdometer = odometer.firstWhere(
        (odo) => odo?.itemName == itemInfo.odometer, orElse: () => null
      );
      final matchedTransmission = transmission.firstWhere(
        (tran) {
          return tran?.id.toString() == itemInfo.transmission.toString();
        },
      );
      selectedCarType.value = matchedCarType != null ? matchedCarType.id ?? 0 : (carTypes.first?.id ?? 0);
      selectedMakeType.value = matchedMakeType?.id ?? 0;
      selectedModelType.value = matchedModel?.id ?? 0;
      selectedYear.value = matchedYear?.id ?? 0;
      selectedTransmission.value = matchedTransmission?.id ?? 1;
      selectedOdometerType.value = matchedOdometer?.id ?? 0;
      countryController.text = itemInfo.country ?? "";
      streetController.text = itemInfo.street ?? "";
      cityController.text = itemInfo.city ?? "";
      stateProvinceController.text = itemInfo.state ?? "";
      zipCodeController.text = itemInfo.zipcode ?? "";
      aptBuildingController.text = itemInfo.buildingName ?? "";
      isLocationSelected.value = true;
      isLocationConfirmed.value = true;
      addressLatLng = LatLng(itemInfo.lat ?? 0.0, itemInfo.lng ?? 0.0);
      for (int i = 0; i < itemInfo.carFeatures.length; i++) {
        selectedCarFeatures.add(itemInfo.carFeatures[i].id);
      }
    } else {
      selectedCarType.value = carTypes.first?.id ?? 0;
      selectedMakeType.value = makeType.first?.id ?? 0;
      selectedModelType.value = model.first?.id ?? 0;
      selectedYear.value = year.first?.id ?? 0;
      selectedTransmission.value = 1;
      selectedOdometerType.value = odometer.first?.id ?? 0;
      countryController.text = "";
      streetController.text = "";
      cityController.text = "";
      stateProvinceController.text = "";
      zipCodeController.text = "";
      aptBuildingController.text = "";
      addressLatLng = LatLng(0.0, 0.0);
      selectedCarFeatures.clear();
    }
  }

  Future<void> getListingSettings() async {
    isLoading.value = true;

    final params = GgetListingSettingsReq((b) => b..vars.build());

    final res = await FerryLoggerClient.makeRequest(
      params,
      this,
      getListingSettings,
    );

    if (res == null) {
      isLoading.value = false;
      return;
    }

    listingSettingData = res.data as GgetListingSettingsData;

    if (listingSettingData?.getListingSettings?.results != null) {
      transmission = [
        Transmission(id: 2, itemName: label_manual.tr),
        Transmission(id: 1, itemName: label_automatic.tr),
      ];

      selectedTransmission.value = 1;

      carTypes = listingSettingData?.getListingSettings?.results?.carType?.listSettings?.toList() ?? [];
      selectedCarType.value = carTypes.isNotEmpty ? carTypes.first?.id ?? 0 : 0;

      year = listingSettingData?.getListingSettings?.results?.year?.listSettings?.toList() ?? [];
      selectedYear.value = year.isNotEmpty ? year.first?.id ?? 0 : 0;

      carFeatures = listingSettingData?.getListingSettings?.results?.carFeatures?.listSettings?.toList() ?? [];

      odometer = listingSettingData?.getListingSettings?.results?.odometer?.listSettings?.toList() ?? [];
      selectedOdometerType.value = odometer.isNotEmpty ? odometer.first?.id ?? 0 : 0;

      if (listId != null) {
        getListingDetails();
      }
    }

    isLoading.value = false;
  }

  Future<void> getFilterPaginationData() async {
    final RxInt currentPage = selectedType == 'make' ? makeCurrentPage : modelCurrentPage;
    final CustomTextEditingController searchController =
    selectedType == 'make' ? makeSearchEditController : modelSearchEditController;

    final String currentSearchText = searchController.Ttext;
    final int currentItemsCount = selectedType == 'make' ? makeItemsCount : modelItemsCount;
    final List currentList = selectedType == 'make' ? makeType : model;

    // Stop pagination if we've already loaded all items
    if (currentPage.value > 1 && currentList.length >= currentItemsCount) {
      isLinearLoading.value = false;
      return;
    }

    final params = GgetListSettingsItemNameReq((b) => b
      ..vars.currentPage = currentPage.value
      ..vars.typeName = selectedType
      ..vars.searchList = currentSearchText
      ..vars.makeId = selectedType == "model" ? selectedMakeType.value : null
      ..vars.build());

    final res = await FerryLoggerClient.makeRequest(
      params,
      this,
      getFilterPaginationData,
      isToGet400Message: true,
      isViewErrorMessage: false,
    );

    if (res == null) return;

    debugPrint('getFilterPaginationData response --> ${DateTime.now()}');

    // Handle case where search text changed before response arrived
    if (currentSearchText != searchController.Ttext) return;

    if (res.data != null) {
      GgetListSettingsItemNameData data = res.data as GgetListSettingsItemNameData;

      if (data.getListSettingsItemName?.status == 400) {
        isLinearLoading.value = false;

        if (currentPage.value == 1) {
          if (selectedType == 'make') {
            makeType = [];
            makeItemsCount = 0;
          } else {
            model = [];
            modelItemsCount = 0;
          }
        }

        bottomSheetController.change(
            rxVariable: bottomSheetController.isUpdateItemList, value: true);
        return;
      }

      List<StepItemModel> itemlist = [];

      data.getListSettingsItemName?.results?.forEach((listsetting) {
        itemlist.add(
          StepItemModel(
            id: listsetting?.id,
            itemName: listsetting?.itemName,
            dynamicItemName: listsetting?.toJson()['dynamicItemName'],
          ),
        );
      });

      if (selectedType == 'make') {
        if (currentPage.value != 1) {
          makeType.addAll(itemlist);
        } else {
          makeType = itemlist;
        }

        makeItemsCount = data.getListSettingsItemName?.count ?? 0;
      } else {
        if (currentPage.value != 1) {
          model.addAll(itemlist);
        } else {
          model = itemlist;
        }

        modelItemsCount = data.getListSettingsItemName?.count ?? 0;
      }

      isLoading.value = false;
    } else {
      if (currentPage.value == 1) {
        if (selectedType == 'make') {
          makeType = [];
          makeItemsCount = 0;
        } else {
          model = [];
          modelItemsCount = 0;
        }
      }
    }

    bottomSheetController.change(
        rxVariable: bottomSheetController.isUpdateItemList, value: true);

    isLinearLoading.value = false;
  }

  void getListingDetails() {
    final params = GgetStep1ListingDetailsReq(
      (b) => b
        ..vars.listId = itemInfo != null ? itemInfo.id : listId
        ..vars.preview = true
        ..vars.build(),
    );
    FerryLoggerClient.makeRequest(params, this, getListingDetails)?.then((res) {
      getListingData = res.data as GgetStep1ListingDetailsData;
      if (getListingData?.getListingDetails?.results != null) {
        selectedTransmission.value =
            int.parse(getListingData?.getListingDetails?.results?.transmission ?? "1");
        getListingData?.getListingDetails?.results?.settingsData?.forEach((element) {
          parseData(element);
        });
        isLoading.value = false;
      } else {
        isLoading.value = false;
      }
    });
  }

  void parseData(GgetStep1ListingDetailsData_getListingDetails_results_settingsData? element) {
    switch (element?.listsettings?.settingsType?.typeName) {
      case "carType":
        selectedCarType.value = element?.listsettings?.id ?? 0;
        break;
      case "model":
        selectedModelType.value = element?.listsettings?.id ?? 0;
        break;
      case "year":
        selectedYear.value = element?.listsettings?.id ?? 0;
        break;
      case "make":
        selectedMakeType.value = element?.listsettings?.id ?? 0;
        break;
      case "odometer":
        selectedOdometerType.value = element?.listsettings?.id ?? 0;
        break;
    }
  }

  void createListingStepOne() {
    final params = GcreateListingReq((b) => b
      ..vars.listId = itemInfo != null ? itemInfo.id : listId
      ..vars.carType = selectedCarType.value.toString()
      ..vars.make = selectedMakeType.value.toString()
      ..vars.model = selectedModelType.value.toString()
      ..vars.year = selectedYear.value.toString()
      ..vars.carFeatures = ListBuilder<int?>(selectedCarFeatures)
      ..vars.transmission = (selectedTransmission.value != 1 ? 0 : 1).toString()
      ..vars.odometer = selectedOdometerType.value.toString()
      ..vars.country = selectedCountrycode
      ..vars.street = streetController.Ttext
      ..vars.buildingName = aptBuildingController.Ttext
      ..vars.city = cityController.Ttext
      ..vars.state = stateProvinceController.Ttext
      ..vars.zipcode = zipCodeController.Ttext
      ..vars.lat = addressLatLng?.latitude
      ..vars.lng = addressLatLng?.longitude
      ..vars.isMapTouched = choosedIndex.value == stepone_layout_items.length - 1 || itemInfo != null
      ..vars.build());
    FerryLoggerClient.makeRequest(params, this, createListingStepOne,
            isViewLoader: true, isToGet400Message: true, isViewErrorMessage: false, isAutoCloseLoader: false)
        ?.then((res) {
      GcreateListingData listdata = res.data as GcreateListingData;
      if (listdata.createListing?.status == 200) {
        bool isUpdateSteps = (listId == null || choosedIndex.value == stepone_layout_items.length - 1);
        listId = res.data.createListing?.id;
        if (itemInfo != null) {
          if (itemInfo.listingSteps == null ||
              (itemInfo.listingSteps.step1 == 'active' &&
                  choosedIndex.value == stepone_layout_items.length - 1)) {
            checkNetwork(manageListingSteps);
          } else {
            rebuildStepOneData();
            Get.forceAppUpdate();
            Get.back();
          }
        } else {
          if (isUpdateSteps) {
            checkNetwork(manageListingSteps);
          } else {
            isLoading.value = false;
          }
        }
      } else {
        showSnackBar(label_empty_listing.tr, isltralign: true);
        Get.back(result: {'removedeletedlisting': true});
      }
    });
  }

  void manageListingSteps() {
    final params = GmanageListingStepsReq((b) => b
      ..vars.listId = listId.toString()
      ..vars.currentStep = 1
      ..vars.build());
    FerryLoggerClient.makeRequest(params, this, manageListingSteps, isViewLoader: true, isAutoCloseLoader: false)?.then((res) {
      bool isDataBuilding = false;

      rebuildStepOneData(manageStepsData: res.data);
      isDataBuilding = choosedIndex.value == stepone_layout_items.length - 1;

      if (choosedIndex.value == stepone_layout_items.length - 1) {
        Future.delayed(const Duration(milliseconds: 200)).then((value) {
          isLoading.value = false;
          Get.back(result: {'type': 'refresh', 'id': listId});
        });
      }

      if (!isDataBuilding) {
        isLoading.value = false;
      }
    });
  }

  (GviewListingDetailsFragmentData?, GviewListingDetailsFragmentReq) getItemInfo({required int id}) {
    GviewListingDetailsFragmentReq fragmentReq =
        GviewListingDetailsFragmentReq((b) => b..idFields = {'id': listId});
    return (FerryLoggerClient.client?.cache.readFragment(fragmentReq), fragmentReq);
  }

  @override
  onPaused() {
    if (stepone_layout_items.isNotEmpty &&
        stepone_layout_items[choosedIndex.value]['chiptitle'] == btn_search_in_map.tr) {
      isLoading.value = true;
    }
    super.onPaused();
  }

  @override
  onResumed() {
    if (stepone_layout_items.isNotEmpty &&
        stepone_layout_items[choosedIndex.value]['chiptitle'] == btn_search_in_map.tr) {
      isLoading.value = false;
    }
    super.onResumed();
  }

  Future<bool> setValidation() async {
    if(selectedMakeType.value == 0) {
      showSnackBar("label_please_choose_make".tr);
      return Future.value(false);
    }
    if(selectedModelType.value == 0) {
      showSnackBar("label_please_choose_model".tr);
      return Future.value(false);
    }
    if (listingSettingData != null) {
      return Future.value(true);
    } else {
      checkNetwork(getCountriesList);
      return Future.value(false);
    }
  }

  void rebuildStepOneData({GmanageListingStepsData? manageStepsData}) {
    (GviewListingDetailsFragmentData?, GviewListingDetailsFragmentReq) datareq = getItemInfo(id: listId!);

    GviewListingDetailsFragmentDataBuilder dataBuilder =
        datareq.$1 != null ? datareq.$1!.toBuilder() : GviewListingDetailsFragmentDataBuilder();

    GviewListingDetailsFragmentData_listingStepsBuilder? listingstepsBuilder;
    if (manageStepsData != null) {
      listingstepsBuilder = GviewListingDetailsFragmentData_listingStepsBuilder();
      listingstepsBuilder.step1 = manageStepsData.manageListingSteps?.results?.step1;
      listingstepsBuilder.step2 = manageStepsData.manageListingSteps?.results?.step2;
      listingstepsBuilder.step3 = manageStepsData.manageListingSteps?.results?.step3;
    }

    dataBuilder
      ..id = listId
      ..carType = _getItemNameById(carTypes, selectedCarType.value) ?? selectedCarType.value.toString()
      ..make = _getItemNameById(makeType, selectedMakeType.value) ?? selectedMakeType.value.toString()
      ..makeId = selectedMakeType.value.toString()
      ..model = _getItemNameById(model, selectedModelType.value) ?? selectedModelType.value.toString()
      ..year = _getItemNameById(year, selectedYear.value) ?? selectedYear.value.toString()
      ..transmission = selectedTransmission.value.toString()
      ..odometer = _getItemNameById(odometer, selectedOdometerType.value) ?? selectedOdometerType.value.toString()
      ..carFeatures = ListBuilder(selectedCarFeatures.map((id) => GviewListingDetailsFragmentData_carFeatures((b) => b
        ..id = id
        ..itemName = _getItemNameById(carFeatures, id) ?? id.toString()
      )))
      ..street = streetController.Ttext
      ..city = cityController.Ttext
      ..state = stateProvinceController.Ttext
      ..country = countryController.text
      ..zipcode = zipCodeController.Ttext
      ..lat = addressLatLng?.latitude
      ..lng = addressLatLng?.longitude
      ..listPhotos = (datareq.$1?.listPhotos?.toBuilder() ?? ListBuilder<GviewListingDetailsFragmentData_listPhotos?>())
      ..isPublished = datareq.$1?.isPublished ?? false
      ..lastUpdatedAt = DateTime.now().millisecondsSinceEpoch.toString();

    print("dataBuilder--> $dataBuilder");
    if (manageStepsData != null) {
      dataBuilder
        ..listingSteps.update((liststep) => liststep
          ..step1 = manageStepsData.manageListingSteps?.results?.step1
          ..step2 = manageStepsData.manageListingSteps?.results?.step2
          ..step3 = manageStepsData.manageListingSteps?.results?.step3);
    }
    FerryLoggerClient.client?.cache.writeFragment(datareq.$2, dataBuilder.build());
  }

  String? _getItemNameById(List list, int id) {
    for (var item in list) {
      if (item == null) continue;
      if (item is StepItemModel && item.id == id) return item.itemName;
      if (item.id == id) return item.itemName;
    }
    return null;
  }
}

class Transmission {
  final int id;
  final String itemName;

  Transmission({
    required this.id,
    required this.itemName,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemName': itemName,
    };
  }
}