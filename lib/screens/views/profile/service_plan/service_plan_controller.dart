import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/graphql/cancelPurchasePlan/__generated__/cancelPurchasePlan.data.gql.dart';
import 'package:gozy/graphql/cancelPurchasePlan/__generated__/cancelPurchasePlan.req.gql.dart';
import 'package:gozy/graphql/getAllPurchaseServicePlan/__generated__/getAllPurchaseServicePlan.data.gql.dart';
import 'package:gozy/graphql/getAllPurchaseServicePlan/__generated__/getAllPurchaseServicePlan.req.gql.dart';
import 'package:gozy/graphql/getPurchaseServicePlan/__generated__/getPurchaseServicePlan.data.gql.dart';
import 'package:gozy/graphql/getPurchaseServicePlan/__generated__/getPurchaseServicePlan.req.gql.dart';
import 'package:gozy/graphql/servicePlan/__generated__/servicePlan.data.gql.dart';
import 'package:gozy/graphql/servicePlan/__generated__/servicePlan.req.gql.dart';
import 'package:gozy/screens/views/profile/profile_controller.dart';

import 'package:gozy/resources/app_lang.dart';
import '../../../../config/client.dart';
import '../../../../constant.dart';
import '../../../../model/tab_bar_item_model.dart';
import '../../../../utils/common_api_controller.dart';

class ServicePlanController extends ProfileController {
  late TabController servicePlanHistoryTabController;
  late TabController servicePlanTabController;
  int servicePlanCurrentPage = 1;
  int servicePlanHistoryCurrentPage = 1;
  int purchasePlanId = 0;
  RxBool isPaginationLoading = false.obs;
  int servicePlanTotalCount = 1;
  RxBool isServicePlanLoading = false.obs;
  RxBool isServicePlanHistoryLoading = false.obs;
  int servicePlanHistoryTotalCount = 1;
  List<TabBarItemModel> tabBaritems = [];
  RxList<GgetAllUserServicePlanData_getAllUserServicePlan_results?> servicePlanList =
      <GgetAllUserServicePlanData_getAllUserServicePlan_results?>[].obs;
  RxList<GgetAllPurchaseServicePlanData_getAllPurchaseServicePlan_results?> servicePlanHistoryList =
      <GgetAllPurchaseServicePlanData_getAllPurchaseServicePlan_results?>[].obs;
  Rxn<GgetPurchaseServicePlanData_getPurchaseServicePlan_result?> purchaseServicePlanData =
      Rxn<GgetPurchaseServicePlanData_getPurchaseServicePlan_result?>();
  TextEditingController searchController = TextEditingController();
  Timer? searchTimer;

  void onSearchChanged(String value) {
    if (searchTimer?.isActive ?? false) searchTimer?.cancel();
    searchTimer = Timer(const Duration(milliseconds: 500), () {
      servicePlanHistoryCurrentPage = 1;
      getServicePlanHistory();
    });
  }

  Future<void> onRefresh() async {
    servicePlanHistoryCurrentPage = 1;
    await getServicePlanHistory();
  }

  Future<GgetPurchaseServicePlanData> createPurchasePlan() {
    isLoading.value = true;
    Completer<GgetPurchaseServicePlanData> getPurchaseServicePlanData =
        Completer<GgetPurchaseServicePlanData>();

    GgetPurchaseServicePlanReq createPurchasePlanParams = GgetPurchaseServicePlanReq((b) {
      b
        ..vars.id = purchasePlanId
        ..build();
    });

    debugPrint("createPurchasePlan: params: $createPurchasePlanParams");
    FerryLoggerClient.makeRequest(
            createPurchasePlanParams, this, createPurchasePlan,
            isToGet400Message: true, isAutoCloseLoader: false)
        ?.then((res) async {
      GgetPurchaseServicePlanData createPurchasePlanData = res.data as GgetPurchaseServicePlanData;
      debugPrint("createPurchasePlan: $createPurchasePlanData");
      purchaseServicePlanData.value = createPurchasePlanData.getPurchaseServicePlan?.result;
      getPurchaseServicePlanData.complete(createPurchasePlanData);
    });
    return getPurchaseServicePlanData.future;
  }

  Future<GcancelPurchasePlanData> cancelPurchasePlan({required int? id}) {
    Completer<GcancelPurchasePlanData> gCancelPurchasePlanData = Completer<GcancelPurchasePlanData>();
    GcancelPurchasePlanReq gCancelPurchasePlanReq = GcancelPurchasePlanReq((b) {
      b
        ..vars.id = id
        ..build();
    });

    debugPrint("gCancelPurchasePlanDataResult: params: $gCancelPurchasePlanReq");
    FerryLoggerClient.makeRequest(gCancelPurchasePlanReq, this, getServicePlanHistory,
            isToGet400Message: true, isViewErrorMessage: false)
        ?.then((res) async {
      GcancelPurchasePlanData gCancelPurchasePlanDataResult = res.data as GcancelPurchasePlanData;
      debugPrint("gCancelPurchasePlanDataResult: $gCancelPurchasePlanDataResult");
      showSnackBar(label_service_plan_cancelled_success.tr);
      gCancelPurchasePlanData.complete(gCancelPurchasePlanDataResult);
    });
    return gCancelPurchasePlanData.future;
  }

  Future<GgetAllPurchaseServicePlanData> getServicePlanHistory() {

    if (servicePlanHistoryCurrentPage == 1) {
      servicePlanHistoryList.clear();
      isServicePlanHistoryLoading.value = true;
    } else {
      isPaginationLoading.value = true;
    }
    showErrorMsg = false;
    Completer<GgetAllPurchaseServicePlanData> getAllPurchaseServicePlanData =
        Completer<GgetAllPurchaseServicePlanData>();

    int currentIndex = servicePlanHistoryTabController.index;

    GgetAllPurchaseServicePlanReq getAllPurchaseServicePlanReq = GgetAllPurchaseServicePlanReq((b) {
      b
        ..vars.userType = currentIndex == 0 ? "renter" : "owner"
        ..vars.currentPage = servicePlanHistoryCurrentPage
        ..vars.searchKey = searchController.text
        ..build();
    });

    debugPrint("getAllPurchaseServicePlan: params: $getAllPurchaseServicePlanReq");
    FerryLoggerClient.makeRequest(getAllPurchaseServicePlanReq, this, getServicePlanHistory,
            isToGet400Message: true,
            isViewErrorMessage: false,
            isAutoCloseLoader: false,
            isStartLoader: servicePlanHistoryCurrentPage == 1)
        ?.then((res) async {
      if (servicePlanHistoryTabController.index != currentIndex) {
        showErrorMsg = false;
        if (res.data != null) {
          getAllPurchaseServicePlanData.complete(res.data as GgetAllPurchaseServicePlanData);
        }
        isPaginationLoading.value = false;
        isServicePlanHistoryLoading.value = false;
        isLoading.value = false;
        return;
      }
      showErrorMsg = false;
      GgetAllPurchaseServicePlanData getAllPurchaseServicePlan = res.data as GgetAllPurchaseServicePlanData;
      servicePlanHistoryTotalCount = getAllPurchaseServicePlan.getAllPurchaseServicePlan?.count ?? 0;
      if (servicePlanHistoryCurrentPage == 1) {
        servicePlanHistoryList.assignAll(getAllPurchaseServicePlan.getAllPurchaseServicePlan?.results ?? []);
      } else {
        servicePlanHistoryList.addAll(getAllPurchaseServicePlan.getAllPurchaseServicePlan?.results ?? []);
      }
      isPaginationLoading.value = false;
      isServicePlanHistoryLoading.value = false;
      isLoading.value = false;
      debugPrint("getAllPurchaseServicePlan: $getAllPurchaseServicePlan");
      isServicePlanHistoryLoading.refresh();
      isLoading.refresh();
      servicePlanHistoryList.refresh();
      getAllPurchaseServicePlanData.complete(getAllPurchaseServicePlan);
    });
    return getAllPurchaseServicePlanData.future;
  }

  void getServicePlans({int? index}) {
    int currentIndex = index ?? servicePlanTabController.index;
    if (servicePlanCurrentPage == 1) {
      servicePlanList.clear();
      isServicePlanLoading.value = true;
    } else {
      isPaginationLoading.value = true;
    }
    final params = GgetAllUserServicePlanReq((b) => b
      ..vars.userType = currentIndex == 0 ? "renter" : "owner"
      ..vars.currentPage = servicePlanCurrentPage
      ..vars.searchKey = ""
      ..build());
    FerryLoggerClient.makeRequest(params, this, getServicePlans,
            isStartLoader: servicePlanCurrentPage == 1,
            isAutoCloseLoader: false)
        ?.then((res) async {
          if(servicePlanCurrentPage == 1) {
            refreshProfileData();
          }
      if (servicePlanTabController.index != currentIndex) return;

      servicePlanList.addAll(res.data.getAllUserServicePlan.results.toList());
      servicePlanTotalCount = res.data.getAllUserServicePlan.count;
      isLoading.value = false;
      isServicePlanLoading.value = false;
      isPaginationLoading.value = false;
      isServicePlanLoading.refresh();
      isPaginationLoading.refresh();
      isLoading.refresh();
    });
  }
}