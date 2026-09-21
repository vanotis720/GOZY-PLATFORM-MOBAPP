import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/config/client.dart';
import 'package:gozy/graphql/__generated__/listing_fragment.req.gql.dart';
import 'package:gozy/graphql/booking/getReseravtion/__generated__/get_reservation.data.gql.dart';
import 'package:gozy/graphql/booking/getReseravtion/__generated__/get_reservation.req.gql.dart';
import 'package:gozy/graphql/payout_updated/__generated__/updatePayoutForReservation.data.gql.dart';
import 'package:gozy/graphql/payout_updated/__generated__/updatePayoutForReservation.req.gql.dart';
import 'package:gozy/graphql/transactionHistory/__generated__/transaction_history.req.gql.dart';
import 'package:gozy/graphql/booking/getReseravtion/__generated__/get_reservation.data.gql.dart';
import 'package:gozy/graphql/booking/getReseravtion/__generated__/get_reservation.req.gql.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/profile/profile_controller.dart';
import 'package:gozy/utils/text_editing_controller.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import '../../../../constant.dart';
import '../../../../graphql/Payout/__generated__/payout.data.gql.dart';
import '../../../../graphql/Payout/__generated__/payout.req.gql.dart';
import '../../../../graphql/__generated__/reservation_fragment.data.gql.dart';
import '../../../../graphql/__generated__/reservation_fragment.req.gql.dart';
import '../../../../graphql/manageListings/__generated__/manageListings.data.gql.dart';
import '../../../../graphql/manageListings/__generated__/manageListings.req.gql.dart';
import '../../../../graphql/transactionHistory/__generated__/transaction_history.data.gql.dart';
import '../../../../model/tab_bar_item_model.dart';

class TransactionHistoryController extends ProfileController {
  RxString paidOutAmount = "0".obs;
  int initialCount =-1;
  RxString pendingPayoutAmount = "0".obs;
  RxBool isRefreshInprogressListTab = false.obs;
  int refreshingTabIndex = -1;
  int? filteredPayoutId;
  int? filteredManageListId;
  bool isBackRefresh = false;
  RxBool isPaginationLoader = true.obs;

  bool isReceiptOpen = false;

  dynamic itemInfo;
  var tabController;
  RxInt tabBarItemsCount = 0.obs;
  var rxSelectedPayoutList = ReactiveVariable("rxSelectedPayoutList", <int>[]);
  var rxSelectedManageListingList = ReactiveVariable("rxSelectedManageListingList", <int>[]);
  RxList<dynamic> payoutList = [].obs;
  RxList<dynamic> manageList = [].obs;
  List<TabBarItemModel> tabBaritems = [];
  CustomTextEditingController searchController = CustomTextEditingController();
  bool isEnableNewScrollController = true;
  RxBool isFiltered = false.obs;
  GreservationFragmentData? reservationResult;
  String searchValue = "";
  bool _isNeedToRefresh = false;
  Map<String,dynamic> updatedPayoutParam = {};

  Future<void> getTransactionHistory() async{
    final point = StackTrace.current.toString().split('\n')[1];
    print('getLink --getTransactionHistory --- test9 $point');
    isShowLoader = true;
    FocusManager.instance.primaryFocus!.unfocus();
    int currentTabIndex = tabController.index;
    TabBarItemModel currentItem = tabBaritems[currentTabIndex];
    final params = GgetTransactionHistoryReq((b)=>
    b ..vars.currentPage = currentItem.listCurrentpage.value
      ..vars.convertCurrency = appPreference.preferredCurrency
      ..vars.payoutId = filteredPayoutId
      ..vars.listId = filteredManageListId
      ..vars.searchKey = searchValue
      ..vars.mode = tabController.index == 0? "completed": tabController.index == 2? "grossEarnings": "future"
      ..vars.build()
    );

   var res =  await FerryLoggerClient.makeRequest(params, this, getTransactionHistory,isViewLoader: false,isToGet400Message: true,isAutoCloseLoader: false);
      GgetTransactionHistoryData payOutHistory = res?.data as GgetTransactionHistoryData;
      if(payOutHistory.getTransactionHistory!.reservationData!.isEmpty){
        isLoading.value = false;
      }
    debugPrint("apires 1 response: isloadingvalue ${isLoading.value}");
      ScrollController scrollcontroller = currentItem.tabliistScrollController;
      List<dynamic> listData =  [];
      if(currentItem.listCurrentpage.value != 1){
        listData = currentItem.tabBarListData;
      }
      else{
        if(scrollcontroller.hasClients) {
          Future.delayed(Duration(milliseconds: 100)).then((value){
            if(tabBaritems[currentTabIndex].tabliistScrollController.hasClients) {
              tabBaritems[currentTabIndex].tabliistScrollController.jumpTo(0);
            }
          });
        }
        if(tabController.index == refreshingTabIndex){
          refreshingTabIndex = -1;
        }
      }

      if ( tabController.index == 0) {
        paidOutAmount.value = (
            double.tryParse(
                payOutHistory.getTransactionHistory?.paidOut?.toString() ?? ''
            ) ?? 0.0
        ).toStringAsFixed(2);
      }
      else if(tabController.index == 1){
        pendingPayoutAmount.value =
            (
                double.tryParse(
                    payOutHistory.getTransactionHistory?.pendingPayouts?.toString() ?? ''
                ) ?? 0.0
            ).toStringAsFixed(2);

      }
      listData.addAll(payOutHistory.getTransactionHistory?.reservationData?.toList()??[]);
      tabBaritems[currentTabIndex] = currentItem.copyWith(
          totalCount: payOutHistory.getTransactionHistory?.count??0,
          pageStorageKey: currentItem.listCurrentpage.value ==1 && !isEnableNewScrollController ? PageStorageKey('${tabBaritems[currentTabIndex].type}: ${Random().nextInt(10000)}') : null,
          isTabLoading: false,
          tabliistScrollController: scrollcontroller,
          tabBarListData: listData,
          nonFilterTabBarListData: !isFiltered.value && searchController.text.isEmpty ? listData : currentItem.nonFilterTabBarListData
      );

      isEnableNewScrollController = true;
      if(currentTabIndex == tabController.index){
        debugPrint("payoutList: isloadingvalue ${payoutList.isNotEmpty} --- ${manageList.isNotEmpty}");
        if(payoutList.isNotEmpty &&  manageList.isNotEmpty) {
          isLoading.value = false;
        }
      }else{
        isLoading.refresh();
      }

      if(_isNeedToRefresh){
        _isNeedToRefresh = false;
        Get.forceAppUpdate();
      }else{
        update();
      }
  }
  Future<GgetPayoutsData?> getPayouts() async { // 1. Change to Future
    isLoading.value = true;
    final params = GgetPayoutsReq((b) => b..vars.build());

    final res = await FerryLoggerClient.makeRequest(
        params, this, getPayouts, isBottomSheetOpen: false, isViewLoader: false
    );
    isLoading.value = true;
    GgetPayoutsData? getPayoutsResponse = res?.data as GgetPayoutsData?;
    final results = getPayoutsResponse?.getPayouts?.results?.toList() ?? [];

    if (results.isNotEmpty) {
      payoutList.addAll(results);
    }
    debugPrint("getPayouts: isloadingvalue ${payoutList.isNotEmpty} --- ${manageList.isNotEmpty}");
   // isLoading.value = false;

    return getPayoutsResponse;
  }
  clearListData() {
    debugPrint('listcurrentpage set: 2 : ${tabController.index}');
    tabBaritems[tabController.index] =  tabBaritems[tabController.index].copyWith(
        totalCount: 0,
        listCurrentpage: 1,
        isTabLoading: false,
        tabBarListData: [],
        nonFilterTabBarListData: []
    );

  }
  Future<void> getMangeListing() async {
    final params = GManageListingsReq((b) =>
    b..vars.requestType = 'completed'
      ..build());
    var res  = await FerryLoggerClient.makeRequest(
         params, this, getMangeListing, isBottomSheetOpen: false,isViewLoader: false);

    GManageListingsData? getMangeListingResponse = res?.data as GManageListingsData?;
    if(getMangeListingResponse?.ManageListings?.results !=null &&  getMangeListingResponse!.ManageListings!.results!.isNotEmpty){
      manageList.addAll(getMangeListingResponse.ManageListings?.results?.toList()??[]);
    }
    isLoading.value = false;
    debugPrint("apires 3 response: isloadingvalue ${isLoading.value}");
  }

  updatePayoutMethod() {
    final params = GupdatePayoutForReservationReq((b) =>
    b ..vars.payoutId = updatedPayoutParam['payoutId']
      ..vars.reservationId = updatedPayoutParam['reservationId']);
    FerryLoggerClient.makeRequest(
        params, this, updatePayoutMethod,isViewLoader: true)?.then((res) async {
      debugPrint("updatePayoutMethod: isloadingvalue ${payoutList.isNotEmpty} --- ${manageList.isNotEmpty}");
      isLoading.value = false;
      changePayoutIdOnReservation(reservationId: updatedPayoutParam['reservationId'], payoutId: updatedPayoutParam['payoutId']);
      GupdatePayoutForReservationData? getUpdatePayout = res.data as GupdatePayoutForReservationData;
      if(getUpdatePayout.updatePayoutForReservation?.errorMessage != null) {
        showToast(getUpdatePayout.updatePayoutForReservation?.errorMessage ?? "");
      }
    });
  }

  getItemInfo({required int listId}){
    GviewListingDetailsFragmentReq fragmentReq = GviewListingDetailsFragmentReq((b) => b..idFields = {'id': listId});
    itemInfo = FerryLoggerClient.client?.cache.readFragment(fragmentReq);
  }
  changePayoutIdOnReservation({required int reservationId, required int payoutId}) async {
    for (int i = 0; i < tabBaritems.length; i++) {
      var list = List<dynamic>.from(tabBaritems[i].tabBarListData);
      int index = list.indexWhere((element) => element?.id == reservationId);
      if (index != -1) {
        list[index] = list[index].rebuild((b) => b..payoutId = payoutId);
        tabBaritems[i] = tabBaritems[i].copyWith(tabBarListData: list);
      }
    }
    update();

    GreservationFragmentReq fragmentReq = GreservationFragmentReq((b) => b..idFields = {'id': reservationId});
    var reservationData = FerryLoggerClient.client?.cache.readFragment(fragmentReq);
    if(reservationData != null){
      FerryLoggerClient.client?.cache.writeFragment(
        fragmentReq,
        reservationData.rebuild((b) =>
        b
          ..payoutId = payoutId
        ),
      );
    } else {
      var reservationDataFromNetwork = await getReservationInfo(reservationId: reservationId);
      FerryLoggerClient.client?.cache.writeFragment(
        fragmentReq,
        reservationDataFromNetwork?.rebuild((b) =>
        b
          ..payoutId = payoutId
        ),
      );
    }
    Get.forceAppUpdate();
  }

  Future<GreservationFragmentData?> getReservationInfo({required int reservationId}) async {
    final params = GgetReservationReq((b) => b
      ..vars.reservationId = reservationId
      ..vars.convertCurrency = appPreference.preferredCurrency);

    final res = await FerryLoggerClient.makeRequest(params, this, () => getReservationInfo(reservationId: reservationId), isViewLoader: false);
    GgetReservationData? data = res?.data as GgetReservationData?;
    if (data?.getReservation?.results != null) {
      return GreservationFragmentData.fromJson(data!.getReservation!.results!.toJson());
    }
    return null;
  }
}