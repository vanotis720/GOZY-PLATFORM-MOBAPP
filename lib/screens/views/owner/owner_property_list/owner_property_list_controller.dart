import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/config/client.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/graphql/manageListings/__generated__/manageListings.data.gql.dart';
import 'package:gozy/graphql/manageListings/__generated__/manageListings.req.gql.dart';
import 'package:gozy/graphql/propertycreation/__generated__/propertycreation.req.gql.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/owner/owner_property_list/owner_property_list_navigator.dart';
import 'package:gozy/utils/common_api_controller.dart';
import 'package:gozy/utils/late_init.dart';
import 'package:gozy/widgets/common_extension_functions.dart';

import '../../../../graphql/ListDetail/__generated__/ListingDetails.data.gql.dart';
import '../../../../graphql/ListDetail/__generated__/ListingDetails.req.gql.dart';
import '../../../../graphql/__generated__/listing_fragment.data.gql.dart';
import '../../../../graphql/__generated__/listing_fragment.req.gql.dart';
import '../../../../model/tab_bar_item_model.dart';
import '../../../../resources/app_lang.dart';

class OwnerPropertyListController extends BaseController {
  OwnerPropertyListNavigator ownerPropertyListNavigator = OwnerPropertyListNavigator();
  Late<TabController> latetabController = Late();
  var tabController;
  List<TabBarItemModel> tabBarItems = [];
  int selectedlistid = 1;
  bool _isNeedToRefresh = false, isToRefreshlisting = true;
  int refreshingTabIndex = -1;
  String updateStatus = 'publish';
  int initialCount = -1;

  var stepFinalarguments = Rx<dynamic>(Get.arguments);
  RxBool isPaginationLoader = true.obs;
  RxBool isRefreshInprogressListTab = false.obs;
  RxInt tabBarItemsCount = 0.obs;
  List<GManageListingsData_ManageListings_results?> completedLists = [];
  int inprogressTabIndex = 0;
  bool isEnableNewScrollController = true;

  void getManageListings([bool isClear = false]) {
    int currentTabIndex = tabController.index;
    TabBarItemModel currentTabItem = tabBarItems[currentTabIndex];
    isShowLoader = false;

    final params = GManageListingsReq((b) => b
      ..vars.requestType = ListType.values[tabController.index].name
      ..vars.currentPage = currentTabItem.listCurrentpage.value
      ..vars.build());

    FerryLoggerClient.makeRequest(params, this, getManageListings, isViewLoader: false)?.then((res) {
      GManageListingsData manageListings = res.data as GManageListingsData;

      ScrollController? scrollcontroller = currentTabItem.tabliistScrollController;
      debugPrint(" old scroll --- isEnableNewScrollController: $isEnableNewScrollController");
      List<dynamic> listData = [];
      if (currentTabItem.listCurrentpage.value != 1) {
        listData = currentTabItem.tabBarListData;
        debugPrint(" old scroll: $scrollcontroller");
      } else {
        if (isEnableNewScrollController) {
          scrollcontroller = ScrollController(initialScrollOffset: 0.0);

          Future.delayed(const Duration(milliseconds: 350)).then((value) {
            if (tabBarItems[currentTabIndex].tabliistScrollController.hasClients &&
                tabBarItems[currentTabIndex].tabliistScrollController.positions.length == 1) {
              tabBarItems[currentTabIndex].tabliistScrollController.jumpTo(0);
            }
          });
        } else {
          if (scrollcontroller.hasClients && scrollcontroller.positions.length == 1) {
            var position = scrollcontroller.position;
            scrollcontroller = ScrollController(initialScrollOffset: position.pixels);
          }
        }
        debugPrint(" newly scroll: $scrollcontroller --- $isEnableNewScrollController --");
        if (tabController.index == refreshingTabIndex) {
          refreshingTabIndex = -1;
        }
      }

      listData.addAll(manageListings.ManageListings?.results?.toList() ?? []);
      tabBarItems[currentTabIndex] = currentTabItem.copyWith(
          totalCount: manageListings.ManageListings?.count ?? 0,
          pageStorageKey: currentTabItem.listCurrentpage.value == 1 && !isEnableNewScrollController
              ? PageStorageKey('${tabBarItems[currentTabIndex].type}: ${Random().nextInt(10000)}')
              : null,
          isTabLoading: false,
          tabliistScrollController: scrollcontroller,
          tabBarListData: listData);

      isEnableNewScrollController = true;
      debugPrint('indexIsChanging: api  $currentTabIndex --- ${tabController.index}');
      if (currentTabIndex == tabController.index) {
        isLoading.value = false;
      } else {
        isLoading.refresh();
      }

      if (_isNeedToRefresh) {
        _isNeedToRefresh = false;
        Get.forceAppUpdate();
      } else {
        update();
      }
    });
  }

  void deleteListing() {
    final params = GRemoveListingReq((b) => b
      ..vars.listId = selectedlistid
      ..vars.build());
    FerryLoggerClient.makeRequest(params, this, deleteListing)?.then((res) {
      isPaginationLoader.value = false;
      isLoading.value = false;
      removeListing();
      update();
    });
  }

  void managePublishStatus() {
    isPaginationLoader.value = false;
    GviewListingDetailsFragmentReq fragmentReq =
        GviewListingDetailsFragmentReq((b) => b..idFields = {'id': selectedlistid});
    final data = FerryLoggerClient.client?.cache.readFragment(fragmentReq);
    bool ispublished = data?.isPublished ?? false;
    if ((ispublished && updateStatus != 'publish') || (!ispublished && updateStatus == 'publish')) {
      final params = GmanagePublishStatusReq((b) => b
        ..vars.listId = selectedlistid
        ..vars.action = updateStatus
        ..vars.build());
      FerryLoggerClient.makeRequest(
        params,
        this,
        managePublishStatus,
      )?.then((res) {
        FerryLoggerClient.client?.cache
            .writeFragment(fragmentReq, data?.rebuild((b) => b..isPublished = updateStatus == 'publish'));
        isPaginationLoader.value = false;
        isLoading.value = false;
        if (updateStatus == 'publish') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showToast("label_your_car_is_published".tr);
          });
          refreshingTabIndex = 0;
        } else {
          refreshingTabIndex = 2;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showToast("label_your_cars_unpublished".tr);
          });
        }
        isToRefreshlisting = !isToRefreshlisting;
        if (Get.currentRoute == '/guestHomePage') {
          removeListing();
        } else {
          update();
        }
      });
    }
  }

  void getDefaultSettingsData() {
    isShowLoader = false;
    isLoading.value = true;
    if(currencyRates ==null){
      getCurrencyRates().then((value){
        isShowLoader = false;
        isLoading.value = true;
        checkNetwork(getManageListings);
      });
    }else {
      isShowLoader = false;
      isLoading.value = true;
      checkNetwork(getManageListings);
    }
  }

  void getUpdatedPropertyInfo() {
    final params = GviewListingDetailsReq((b) => b
      ..vars.listId = selectedlistid
      ..vars.build());
    FerryLoggerClient.makeRequest(params, this, getUpdatedPropertyInfo)?.then((res) {
      GviewListingDetailsData viewListingInfo = res.data as GviewListingDetailsData;
      var itemInfo = getItemInfo();
      Map<String, dynamic> itemInfoMap = viewListingInfo.viewListing!.results?.toJson() ?? {};
      FerryLoggerClient.client?.cache.writeFragment(itemInfo.$2, itemInfo.$1?.rebuild((b) => itemInfoMap));
      debugPrint('stepFinalarguments.value: ${stepFinalarguments.value}');
      isLoading.value = false;
      Get.forceAppUpdate();
    });
  }

  void clearListData() {
    debugPrint('listcurrentpage set: 2 : ${tabController.index}');
    tabBarItems[tabController.index] = tabBarItems[tabController.index]
        .copyWith(totalCount: 0, listCurrentpage: 1, isTabLoading: false, tabBarListData: []);
  }

  (GviewListingDetailsFragmentData?, GviewListingDetailsFragmentReq) getItemInfo() {
    GviewListingDetailsFragmentReq fragmentReq =
        GviewListingDetailsFragmentReq((b) => b..idFields = {'id': selectedlistid});
    return (FerryLoggerClient.client?.cache.readFragment(fragmentReq), fragmentReq);
  }

  void moveToLetsStartPage({Function? whyHostFunction}) {
    debugPrint('controller.tabController:  2 $tabController --- $hashCode');
    ownerPropertyListNavigator.navigateScreen(OwnerPropertyListScreen.letStart, param: {
      'refresh': (Map value) {
        debugPrint('letsstart---refresh: $value');
        compute(setCurrentListing, value);
      },
      'whyhostfunction': whyHostFunction,
      'updateManagelist': (id) {
        updateInprogressListings(id);
      },
      'removedeletedlisting': () {
        tabController.index = 0;
        isShowLoader = false;
        checkNetwork(getManageListings);
      },
    });
  }

  void setCurrentListing(Map value) {
    tabController.index = 1;
    selectedlistid = value['iteminfo'].id;
    _isNeedToRefresh = false;
    isShowLoader = false;
    checkNetwork(getManageListings);
  }

  void updateInprogressListings(id) {
    debugPrint(
        'updateInprogressListings: ${tabBarItems[tabController.index].tabBarListData.isEmpty} --- ${tabController.index}');
    if (tabBarItems[inprogressTabIndex].tabBarListData.isEmpty) {
      tabBarItems[inprogressTabIndex] =
          tabBarItems[inprogressTabIndex].copyWith(listCurrentpage: 1, isTabLoading: true);
      isShowLoader = false;
      isLoading.value = true;
      isRefreshInprogressListTab.value = true;
      debugPrint('getManageListings called 3');
      checkNetwork(getManageListings);
    } else {
      selectedlistid = id;
      addNewListings();
    }
  }

  void addNewListings() {
    GviewListingDetailsFragmentData? viewlistdata = getItemInfo().$1;
    List<dynamic> tabbaritemsdata = tabBarItems[inprogressTabIndex].tabBarListData;
    tabbaritemsdata.insert(0, viewlistdata);
    debugPrint('listcurrentpage set: 1 : ${tabController.index}');

    tabBarItems[inprogressTabIndex] = tabBarItems[inprogressTabIndex].copyWith(
      totalCount: tabBarItems[inprogressTabIndex].totalCount + 1,
      listCurrentpage: 1,
      tabBarListData: tabbaritemsdata,
    );
    isRefreshInprogressListTab.value = true;
    isLoading.refresh();
  }

  int removeListing() {
    List<dynamic> listdata = tabBarItems[tabController.index].tabBarListData;
    listdata.removeWhere((item) => item.id == selectedlistid);

    isEnableNewScrollController = true;
    if (tabBarItems[tabController.index].tabliistScrollController.hasClients) {
      tabBarItems[tabController.index].tabliistScrollController.jumpTo(0.0);
    }
    tabBarItems[tabController.index] = tabBarItems[tabController.index].copyWith(
      tabBarListData: [],
      listCurrentpage: 1,
      isTabLoading: true,
    );
    isRefreshInprogressListTab.value = true;
    isLoading.value = true;
    getManageListings();

    return selectedlistid;
  }
}

enum ListType {
  inProgress,
  completed;

  static String getMultiLanguageString(ListType listType) {
    return switch (listType) {
      ListType.inProgress => tab_inprogress.tr,
      ListType.completed => tab_completed.tr,
    };
  }
}