import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/resources/app_colors.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/resources/app_layout.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/screens/views/profile/transaction_history/transaction_filter.dart';
import 'package:gozy/screens/views/profile/transaction_history/transaction_history_controller.dart';
import 'package:gozy/utils/common_api_controller.dart';
import 'package:gozy/widgets/common/custom_container/custom_border_container.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/common/custom_textfield/custom_prefix_textfield.dart';
import 'package:gozy/widgets/common/custom_container/custom_container.dart';
import 'package:gozy/widgets/custom_empty_view.dart';
import 'package:gozy/widgets/shimmer.dart';
import '../../../../constant.dart';
import '../../../../generated/assets.dart';
import '../../../../model/tab_bar_item_model.dart';
import '../../../../resources/app_dimen.dart';
import '../../../../resources/app_font.dart';
import '../../../../widgets/bottom_sheet/customer_receipt/customer_receipt_bottom_sheet.dart';
import '../../../../widgets/common_extension_functions.dart';
import '../../../../widgets/custom_stateful_widget.dart';
import '../../../../widgets/custom_text.dart';
import '../../../../widgets/custom_textfield.dart';
import '../../../../widgets/dotted_border/dotted_border.dart';
import '../../../../widgets/owner/list_item_selection_widget.dart';
import '../../../../widgets/owner/step_item_model.dart';
import '../../../../widgets/theme4/custom_dash_divider.dart';
import '../../base_controller.dart';
import '../profile_navigator.dart';

class TransactionHistory extends CustomStatefulWidget {
  const TransactionHistory({super.key});

  @override
  TransactionHistoryState createState() => TransactionHistoryState();
}

class TransactionHistoryState
    extends CustomStatefulWidgetState<TransactionHistory>
    with TickerProviderStateMixin {
  TransactionHistoryController controller = Get.find();
  int _previousIndex = 0;
  Timer? debounce;
  final List<String> _tabs = [
    tab_completed.tr,
    tab_future.tr,
    tab_gross_earnings.tr
  ];
  bool isLoadManageListings = false;
  bool isLinearloaderEnable = false;
  double? borderRadius;
  bool? isDottedBorder;
  Color? itemListingBGColor;

  @override
  void initState() {
    isShowLoader = false;
    controller.tabController = TabController(length: _tabs.length, vsync: this);
    controller.tabBaritems =
        List<TabBarItemModel>.generate(_tabs.length, (index) {
      PageStorageKey pagekey =
          PageStorageKey('${_tabs[index]}: ${Random().nextInt(10000)}');
      TabBarItemModel tabbarmodal = (
        pageStorageKey: pagekey,
        totalCount: 1,
        tabBarListData: [],
        tabliistScrollController: ScrollController(),
        listCurrentpage: 1.obs,
        isTabLoading: true,
        type: _tabs[index],
        nonFilterTabBarListData: [],
      );
      return tabbarmodal;
    });

    controller.tabController.addListener(() {
      if (!controller.tabController.indexIsChanging &&
          controller.tabController.index != _previousIndex) {
        clearFilter();
        TabBarItemModel previoustabitems =
            controller.tabBaritems[_previousIndex];
        List<dynamic> list =
            controller.initialCount > previoustabitems.tabBarListData.length
                ? []
                : previoustabitems.tabBarListData;
        int currentPage =
            controller.initialCount > previoustabitems.tabBarListData.length
                ? 1
                : previoustabitems.listCurrentpage.value;
        if (controller.tabBaritems[controller.tabController.index]
                .listCurrentpage.value !=
            0) {
          controller.initialCount = -1;
        }
        controller.tabBaritems[_previousIndex] = previoustabitems.copyWith(
            isTabLoading: true,
            tabBarListData: list,
            listCurrentpage: currentPage);
        var currentTabItem =
            controller.tabBaritems[controller.tabController.index];
        if (controller.refreshingTabIndex == controller.tabController.index &&
            currentTabItem.tabliistScrollController.hasClients) {
          controller.clearListData();
          controller.tabBaritems[controller.tabController.index]
              .tabliistScrollController
              .jumpTo(0);
        }
        isShowLoader = false;
        controller.isLoading.value = false;
        debugPrint("initstate: isloadingvalue ${controller.payoutList.isNotEmpty}");
        _previousIndex = controller.tabController.index;
        controller.isRefreshInprogressListTab.value = true;

        if (currentTabItem.tabBarListData.isEmpty ||
            controller.refreshingTabIndex == controller.tabController.index ||
            currentTabItem.tabliistScrollController.positions.length > 1) {
          controller.tabBaritems[controller.tabController.index] =
              currentTabItem.copyWith(isTabLoading: true, listCurrentpage: 1);
          controller.isLoading.value = true;
          controller.searchValue = "";
          controller.checkNetwork(controller.getTransactionHistory);
        } else {
          controller.tabBaritems[controller.tabController.index] =
              currentTabItem.copyWith(
                  isTabLoading: true,
                  tabBarListData: currentTabItem.nonFilterTabBarListData);
          controller.checkNetwork(controller.getTransactionHistory);
          controller.isLoading.refresh();
        }
      }
    });
    controller.filteredManageListId = 0;
    controller.filteredPayoutId = 0;
    loadAllData();
    ever(controller.tabBarItemsCount, (value) {
      if (isLoadManageListings) {
        controller.isEnableNewScrollController = false;
        getFirstPageListData();
      }
    });
    ever(controller.isRefreshInprogressListTab, (value) {
      if (value) {
        controller.initialCount = -1;
        controller.isRefreshInprogressListTab.value = false;
      }
    });
    isShowLoader = false;
    super.initState();
  }

  loadAllData() async {
    controller.isLoading.value = true;

    bool isConnected = await controller.isNetworkConnected();
    if (isConnected) {
      await Future.wait([
        if (currencyRates == null) controller.getCurrencyRates(),
        controller.getTransactionHistory(),
        controller.getPayouts(),
        controller.getMangeListing(),
      ]);
    }
    debugPrint("loadAllData: isloadingvalue ${controller.payoutList.isNotEmpty} ");
    controller.isLoading.value = false;
  }

  @override
  void dispose() {
    controller.filteredManageListId = null;
    controller.tabBaritems.forEach((item) {
      item.tabliistScrollController.dispose();
    });
    controller.tabBaritems.clear();
    debounce?.cancel();
    clearFilter();
    super.dispose();
  }

  clearFilter() {
    controller.filteredPayoutId = 0;
    controller.filteredManageListId = 0;
    controller.rxSelectedManageListingList.value.clear();
    controller.rxSelectedPayoutList.value.clear();
    controller.searchValue = "";
    controller.searchController.clear();
    controller.isFiltered.value = false;
    controller.isLoading.value = true;
  }

  @override
  Widget build(BuildContext context) {
    switch (overALLThemeType) {
      case 1:
        borderRadius = 6;
        isDottedBorder = false;
        itemListingBGColor = appColors.myTripsBGColor;
        break;
      case 2:
        borderRadius = 0;
        isDottedBorder = false;
        break;
      case 3:
        borderRadius = 24;
        isDottedBorder = false;
        break;
      default:
        borderRadius = 12;
        isDottedBorder = true;
        break;
    }
    return CustomScaffold(
      isEnableLoadingOff: false,
      backIconWidget: getBackIconWidget(themeType: overALLThemeType),
      controller: controller,
      isShowAppBar: true,
      backgroundColor: appColors.white,
      loader: LottieLoaders.three_dots_loader,
      isShowBGOnLoader: false,
      body: showBodyContentWidget(),
    );
  }

  showBodyContentWidget() {
    return GetBuilder<TransactionHistoryController>(builder: (newController) {
      return [
        CustomTitleText(
                text: transaction_history.tr, size: AppDimen.textSize_22)
            .toPad(start: AppDimen.startMargin, bottom: 18),
        toTabBarView(
                tabs: _tabs,
                tabBarWidgets: List<Widget>.generate(
                    _tabs.length, (index) => _showTripListWidget(index)),
                tabController: controller.tabController)
            .toStretch()
      ].toColumn();
    });
  }

  _showTripListWidget(int index) {
    return Obx(() {
      TabBarItemModel tabItem = controller.tabBaritems[index];
      debugPrint("tab loading: ${tabItem.tabBarListData.isEmpty}");
      return toReviewList(
              reviewListScrollController: tabItem.tabliistScrollController,
              reviewList: tabItem.tabBarListData,
              reviewsCount: tabItem.totalCount,
              onApiFunction: getTransactionListings,
              isShowPaginationAtFirst: !controller.isEnableNewScrollController,
              swipeToRefreshIntialFunction: () {
                controller.initialCount = -1;
                TabBarItemModel tabItem =
                    controller.tabBaritems[controller.tabController.index];
                controller.tabBaritems[controller.tabController.index] =
                    tabItem.copyWith(isTabLoading: true);
                isShowLoader = false;
              },
              controller: controller,
              currentPage: tabItem.listCurrentpage,
              isDisableLoader: true,
              isPaginationLoader: tabItem.listCurrentpage.value != 1
                  ? controller.isPaginationLoader
                  : false.obs,
              isEnableListener: false,
              emptyWidget: showEmptyView(
                tabBarIndex: index,
                item: tabItem,
                isShimmerView: (tabItem.isTabLoading),
              ),
              isShowEmpty: () {
                return (tabItem.tabBarListData.isEmpty &&
                    index == controller.tabController.index &&
                    !tabItem.isTabLoading);
              },
              toShowPaginationLoader: true,
              listView: transactionCardList(
                  tabBarIndex: index,
                  isShimmerLoading: (tabItem.tabBarListData.isEmpty
                      ? true
                      : tabItem.isTabLoading),
                  tabItem: tabItem))
          .toShimmer(controller: controller);
    });
  }

  Widget transactionCardList({
    required int tabBarIndex,
    required TabBarItemModel tabItem,
    required bool isShimmerLoading,
  }) {
    List<dynamic>? propertyList = tabItem.tabBarListData;
    ScrollController scrollController = tabItem.tabliistScrollController;
    PageStorageKey storekey = tabItem.pageStorageKey;
    int itemCount = isShimmerLoading
        ? 5
        : propertyList.length > 0
            ? propertyList.length
            : 0;
    String date = "";
    String reservationDate = "";
    String? transactionType;
    String reservationTransactionType = "";
    String amount = "";
    String reservationAmount = "";
    String paidOut = "";
    String reservationPaidOut = "";
    String details = "";
    String reservationDetails = "";
    String guestName = "";
    String reservationGuestName = "";
    String reservationConfirmationCode = "";
    String reservationListTitle = "";
    String listTitle = "";
    int reservationId = 0;
    int listId = 0;
    int reservationListId = 0;
    int payoutId = 0;
    if ((controller.initialCount == -1 ||
            controller.initialCount < itemCount) &&
        !isShimmerLoading &&
        propertyList.length > 0) {
      controller.initialCount = itemCount;
    }
    if (!isShimmerLoading && propertyList.length > 0) {
      isLoadManageListings = controller.initialCount !=
              controller
                  .tabBaritems[controller.tabController.index].totalCount &&
          itemCount <= 5;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.tabBarItemsCount.value = itemCount;
      });
    }
    return [
      CustomBorderContainer(
        color: appColors.white,
        borderRadius: AppDimen.appBorderRadius,
        padding: pad(a: 13),
        body: transactionHistoryTopSection(
            item: tabItem,
            onTapFilter: () {
              debugPrint("isloadingvalue: ${controller.isLoading.value}");
              if (!controller.isLoading.value)
                navigateToFilterPage(tabItem);
            },
            tabBarIndex: tabBarIndex,
            isShimmerView: isShimmerLoading),
      ),
      const SizedBox(height: 5),
      Expanded(
          child: ShimmerLoading(
        isLoading: isShimmerLoading,
        child: toListView(
            key: storekey,
            controller: scrollController,
            itemCount: itemCount,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, value) {
              dynamic item;
              if (!isShimmerLoading) {
                item = propertyList[value];
              }
              if (item != null) {
                if (item?.hostTransaction != null) {
                  date = getDateFormat(
                          dateFormat: dobformat,
                          milliSec: item?.hostTransaction?.createdAt ?? "")
                      .$1
                      .replaceAll(' ', '');
                  if (tabBarIndex == 0) {
                    transactionType = pay_out.tr;
                    reservationTransactionType = label_reservation.tr;
                    if (item?.cancellationDetails != null) {
                      reservationAmount =
                          "${double.parse(item?.cancellationDetails.payoutToHost.toStringAsFixed(2)).currencyConverted(convertedCurrency: defaultCurrency).toNumberFormat(symbol: controller.getCurrencySymbol())}";
                    } else {
                      reservationAmount =
                          "${double.parse((item?.total - item?.hostServiceFee).toStringAsFixed(2)).currencyConverted(convertedCurrency: defaultCurrency).toNumberFormat(symbol: controller.getCurrencySymbol())}";
                    }
                    reservationPaidOut = "-";
                    reservationDate = getDateFormat(
                            dateFormat: dobformat,
                            milliSec: item?.createdAt ?? "")
                        .$1
                        .replaceAll(' ', '');
                    reservationDetails =
                        "${getDateFormat(dateFormat: transactionFromat, milliSec: item?.checkIn ?? "").$1} - ${getDateFormat(dateFormat: transactionFromat, milliSec: item?.checkOut ?? "").$1}";
                    reservationGuestName =
                        "${item?.guestData?.firstName ?? ""}";
                    reservationConfirmationCode =
                        "${item?.confirmationCode ?? 0}";
                    reservationListId = item?.listId ?? 0;
                    reservationListTitle = "${item?.listTitle ?? ""}";
                  }
                  reservationListId = item?.listId ?? 0;
                  amount = "-";
                  reservationId = item?.id ?? 0;
                  paidOut =
                      "${double.parse(item?.hostTransaction?.amount.toStringAsFixed(2)).currencyConverted(convertedCurrency: item?.hostTransaction?.currency ?? defaultCurrency).toNumberFormat(symbol: controller.getCurrencySymbol())}";
                  guestName = label_transfer_to.tr;
                  if (tabBarIndex == 2) {
                    guestName = "";
                    confirmationCode = "${item?.confirmationCode ?? 0}";
                    if (item?.cancellationDetails != null) {
                      amount =
                          "${double.parse(item?.cancellationDetails.payoutToHost.toStringAsFixed(2)).currencyConverted(convertedCurrency: item?.currency ?? defaultCurrency).toNumberFormat(symbol: controller.getCurrencySymbol())}";
                    } else {
                      amount =
                          "${double.parse(item?.completedTotal?.totalAmount.toStringAsFixed(2)).currencyConverted(convertedCurrency: item?.completedTotal?.currency ?? defaultCurrency).toNumberFormat(symbol: controller.getCurrencySymbol())}";
                    }
                    details =
                        "${getDateFormat(dateFormat: transactionFromat, milliSec: item?.checkIn ?? "").$1} - ${getDateFormat(dateFormat: transactionFromat, milliSec: item?.checkOut ?? "").$1}";
                  } else {
                    details = item?.hostTransaction?.payoutEmail ?? "";
                    confirmationCode = "";
                  }
                } else {
                  if (tabBarIndex == 1) {
                    date = getFutureDateFormat(
                            Dateformat: dobformat,
                            milliSec: item?.checkOut ?? "")
                        .$1
                        .replaceAll(' ', '');
                    payoutId = item?.payoutId != null ? item.payoutId : 0;
                  } else {
                    date = getDateFormat(
                            dateFormat: dobformat,
                            milliSec: item?.createdAt ?? "")
                        .$1;
                  }
                  listTitle = item?.listTitle ?? "";
                  listId = item?.listId ?? 0;
                  reservationId = item?.id ?? 0;
                  debugPrint(
                      "item?.cancellationDetails: ${item?.cancellationDetails}");
                  if (item?.cancellationDetails != null) {
                    amount =
                        "${double.parse(item?.cancellationDetails.payoutToHost.toStringAsFixed(2)).currencyConverted(convertedCurrency: item?.cancellationDetails?.currency ?? defaultCurrency).toNumberFormat(symbol: controller.getCurrencySymbol())}";
                  } else {
                    if (tabBarIndex == 1)
                      amount =
                          "${double.parse((item?.futureTransactionTotal?.totalAmount).toStringAsFixed(2)).currencyConverted(convertedCurrency: item?.futureTransactionTotal?.currency ?? defaultCurrency).toNumberFormat(symbol: controller.getCurrencySymbol())}";
                    else
                      amount =
                          "${double.parse(item?.completedTotal?.totalAmount.toStringAsFixed(2)).currencyConverted(convertedCurrency: item?.completedTotal?.currency ?? defaultCurrency).toNumberFormat(symbol: controller.getCurrencySymbol())}";
                  }

                  paidOut = "-";
                  guestName = "${item?.guestData?.firstName ?? ""}";
                  details =
                      "${getDateFormat(dateFormat: transactionFromat, milliSec: item?.checkIn ?? "").$1} - ${getDateFormat(dateFormat: transactionFromat, milliSec: item?.checkOut ?? "").$1}";
                  debugPrint("amountfuture: ${amount} -- ${details}");
                  confirmationCode = "${item?.confirmationCode ?? 0}";
                }
              }

              return [
                (isDottedBorder ?? false)
                    ? DottedBorderView(
                        borderRadius: borderRadius,
                        child: CustomContainer(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                                color: itemListingBGColor ?? appColors.white,
                                borderRadius:
                                    BorderRadius.circular(borderRadius ?? 0)),
                            body: [
                              listedItem(
                                  title:
                                      "${label_date_single.tr.toUpperLowerCase()}:",
                                  details: date,
                                  isDes: false,
                                  isPayout: false,
                                  isShimmerView: isShimmerLoading,
                                  reservationId: reservationId,
                                  isDashedDivider: true),
                              listedItem(
                                  title: "${label_type.tr}:",
                                  details:
                                      transactionType ?? label_reservation.tr,
                                  isDes: false,
                                  isPayout: false,
                                  isShimmerView: isShimmerLoading,
                                  reservationId: reservationId,
                                  isDashedDivider: true),
                              if (tabBarIndex != 2)
                                listedItem(
                                    title: "${label_amount.tr}:",
                                    details: amount,
                                    isDes: false,
                                    isPayout: false,
                                    isShimmerView: isShimmerLoading,
                                    textColors: amount != "-"
                                        ? appColors.discountAmountColor
                                        : null,
                                    reservationId: reservationId,
                                    isDashedDivider: true),
                              if (tabBarIndex == 2)
                                listedItem(
                                    title: "${tab_gross_earnings.tr}:",
                                    details: amount,
                                    isDes: false,
                                    isPayout: false,
                                    isShimmerView: isShimmerLoading,
                                    reservationId: reservationId,
                                    textColors: appColors.discountAmountColor,
                                    isDashedDivider: true),
                              if (tabBarIndex == 0 && !isShimmerLoading)
                                listedItem(
                                    title: "${paid_out.tr}:",
                                    details: paidOut,
                                    isDes: false,
                                    isPayout: false,
                                    isShimmerView: isShimmerLoading,
                                    reservationId: reservationId,
                                    isDashedDivider: true),
                              if (tabBarIndex == 1 && !isShimmerLoading)
                                listedItem(
                                    title: "${label_pay_to.tr}:",
                                    details: "",
                                    isDes: false,
                                    isPayout: true,
                                    isShimmerView: isShimmerLoading,
                                    payoutId: payoutId.obs,
                                    reservationId: reservationId,
                                    cardIndex: value,
                                    isDashedDivider: true),
                              listedItem(
                                  title: "${label_payout_details.tr}:",
                                  details: details,
                                  isDes: true,
                                  isPayout: false,
                                  isShimmerView: isShimmerLoading,
                                  conformationCode: confirmationCode,
                                  listingName:
                                      tabBarIndex == 2 ? "" : listTitle,
                                  guestName: tabBarIndex == 2 ? "" : guestName,
                                  listId:
                                      listId == 0 ? reservationListId : listId,
                                  tabBarIndex: tabBarIndex,
                                  reservationId: reservationId,
                                  isDashedDivider: true)
                            ].toColumn(
                                mainAxisAlignment: MainAxisAlignment.start)),
                      ).toPad(start: 24, end: 24, bottom: 12, top: 12)
                    : CustomContainer(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                                boxShadow: getBoxShadow(),
                                border: Border.all(
                                    color: appColors.myTripsDividerColor),
                                color: itemListingBGColor ?? appColors.white,
                                borderRadius:
                                    BorderRadius.circular(borderRadius ?? 0)),
                            body: [
                              listedItem(
                                  title:
                                      "${label_date_single.tr.toUpperLowerCase()}:",
                                  details: date,
                                  isDes: false,
                                  isPayout: false,
                                  isShimmerView: isShimmerLoading,
                                  reservationId: reservationId),
                              listedItem(
                                  title: "${label_type.tr}:",
                                  details:
                                      transactionType ?? label_reservation.tr,
                                  isDes: false,
                                  isPayout: false,
                                  isShimmerView: isShimmerLoading,
                                  reservationId: reservationId),
                              if (tabBarIndex != 2)
                                listedItem(
                                    title: "${label_amount.tr}:",
                                    details: amount,
                                    isDes: false,
                                    isPayout: false,
                                    isShimmerView: isShimmerLoading,
                                    textColors: amount != "-"
                                        ? appColors.discountAmountColor
                                        : null,
                                    reservationId: reservationId),
                              if (tabBarIndex == 2)
                                listedItem(
                                    title: "${tab_gross_earnings.tr}:",
                                    details: amount,
                                    isDes: false,
                                    isPayout: false,
                                    isShimmerView: isShimmerLoading,
                                    reservationId: reservationId,
                                    textColors: appColors.discountAmountColor),
                              if (tabBarIndex == 0 && !isShimmerLoading)
                                listedItem(
                                    title: "${paid_out.tr}:",
                                    details: paidOut,
                                    isDes: false,
                                    isPayout: false,
                                    isShimmerView: isShimmerLoading,
                                    reservationId: reservationId),
                              if (tabBarIndex == 1 && !isShimmerLoading)
                                listedItem(
                                    title: "${label_pay_to.tr}:",
                                    details: "",
                                    isDes: false,
                                    isPayout: true,
                                    isShimmerView: isShimmerLoading,
                                    payoutId: payoutId.obs,
                                    reservationId: reservationId,
                                    cardIndex: value),
                              listedItem(
                                  title: "${label_payout_details.tr}:",
                                  details: details,
                                  isDes: true,
                                  isPayout: false,
                                  isShimmerView: isShimmerLoading,
                                  conformationCode: confirmationCode,
                                  listingName: (tabBarIndex == 2 ||
                                          transactionType ==
                                              pay_out.tr)
                                      ? ""
                                      : listTitle,
                                  guestName: (tabBarIndex == 1 ||
                                          transactionType ==
                                              pay_out.tr)
                                      ? guestName
                                      : "",
                                  listId:
                                      listId == 0 ? reservationListId : listId,
                                  tabBarIndex: tabBarIndex,
                                  reservationId: reservationId)
                            ].toColumn(
                                mainAxisAlignment: MainAxisAlignment.start))
                        .toPad(start: 24, end: 24, bottom: 24),
                tabBarIndex == 0 && item?.hostTransaction != null
                    ? (isDottedBorder ?? false)
                        ? DottedBorderView(
                            borderRadius: borderRadius,
                            child: CustomContainer(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                    color:
                                        itemListingBGColor ?? appColors.white,
                                    borderRadius: BorderRadius.circular(
                                        borderRadius ?? 0)),
                                body: [
                                  listedItem(
                                      title:
                                          "${label_date_single.tr.toUpperLowerCase()}:",
                                      details: reservationDate,
                                      isDes: false,
                                      isPayout: false,
                                      isShimmerView: isShimmerLoading,
                                      reservationId: reservationId,
                                      isDashedDivider: true),
                                  listedItem(
                                      title: "${label_type.tr}:",
                                      details: reservationTransactionType,
                                      isDes: false,
                                      isPayout: false,
                                      isShimmerView: isShimmerLoading,
                                      reservationId: reservationId,
                                      isDashedDivider: true),
                                  listedItem(
                                      title: "${label_amount.tr}:",
                                      details: reservationAmount,
                                      isDes: false,
                                      isPayout: false,
                                      isShimmerView: isShimmerLoading,
                                      textColors: reservationAmount != "-"
                                          ? appColors.discountAmountColor
                                          : null,
                                      reservationId: reservationId,
                                      isDashedDivider: true),
                                  if (tabBarIndex == 0 && !isShimmerLoading)
                                    listedItem(
                                        title: "${paid_out.tr}:",
                                        details: reservationPaidOut,
                                        isDes: false,
                                        isPayout: false,
                                        isShimmerView: isShimmerLoading,
                                        reservationId: reservationId,
                                        isDashedDivider: true),
                                  listedItem(
                                      title: "${label_payout_details.tr}:",
                                      details: reservationDetails,
                                      isDes: true,
                                      isPayout: false,
                                      isShimmerView: isShimmerLoading,
                                      conformationCode:
                                          reservationConfirmationCode,
                                      listingName: reservationListTitle,
                                      guestName: reservationGuestName,
                                      listId: reservationListId,
                                      tabBarIndex: tabBarIndex,
                                      reservationId: reservationId,
                                      isDashedDivider: true)
                                ].toColumn(
                                    mainAxisAlignment:
                                        MainAxisAlignment.start)),
                          ).toPad(start: 24, end: 24, bottom: 24)
                        : CustomContainer(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                    boxShadow: getBoxShadow(),
                                    border: Border.all(
                                        color: appColors.myTripsDividerColor),
                                    color:
                                        itemListingBGColor ?? appColors.white,
                                    borderRadius: BorderRadius.circular(
                                        borderRadius ?? 0)),
                                body: [
                                  listedItem(
                                      title:
                                          "${label_date_single.tr.toUpperLowerCase()}:",
                                      details: reservationDate,
                                      isDes: false,
                                      isPayout: false,
                                      isShimmerView: isShimmerLoading,
                                      reservationId: reservationId),
                                  listedItem(
                                      title: "${label_type.tr}:",
                                      details: reservationTransactionType,
                                      isDes: false,
                                      isPayout: false,
                                      isShimmerView: isShimmerLoading,
                                      reservationId: reservationId),
                                  listedItem(
                                      title: "${label_amount.tr}:",
                                      details: reservationAmount,
                                      isDes: false,
                                      isPayout: false,
                                      isShimmerView: isShimmerLoading,
                                      textColors: reservationAmount != "-"
                                          ? appColors.discountAmountColor
                                          : null,
                                      reservationId: reservationId),
                                  if (tabBarIndex == 0 && !isShimmerLoading)
                                    listedItem(
                                        title: "${paid_out.tr}:",
                                        details: reservationPaidOut,
                                        isDes: false,
                                        isPayout: false,
                                        isShimmerView: isShimmerLoading,
                                        reservationId: reservationId),
                                  listedItem(
                                      title: "${label_payout_details.tr}:",
                                      details: reservationDetails,
                                      isDes: true,
                                      isPayout: false,
                                      isShimmerView: isShimmerLoading,
                                      conformationCode:
                                          reservationConfirmationCode,
                                      listingName: reservationTransactionType
                                                  .toLowerCase() ==
                                              "payout"
                                          ? null
                                          : reservationListTitle,
                                      guestName: reservationTransactionType
                                                  .toLowerCase() ==
                                              "payout"
                                          ? null
                                          : reservationGuestName,
                                      listId: reservationListId,
                                      tabBarIndex: tabBarIndex,
                                      reservationId: reservationId)
                                ].toColumn(
                                    mainAxisAlignment: MainAxisAlignment.start))
                            .toPad(start: 24, end: 24, bottom: 24)
                    : const SizedBox.shrink(),
              ].toColumn();
            }),
        widgetType: 'transactionHistory',
        isDarkMode: controller.isDarkMode(),
        darkModeblend: BlendMode.dstIn,
      ))
    ].toColumn();
  }

  Widget listedItem(
      {required String title,
      required String details,
      required bool isDes,
      required bool isPayout,
      required bool isShimmerView,
      RxInt? payoutId,
      Color? textColors,
      String? guestName,
      String? listingName,
      String? conformationCode,
      required int reservationId,
      int? listId,
      int? tabBarIndex,
      int? cardIndex,
      bool? isDashedDivider}) {
    return [
      [
        if (!isShimmerView)
          CustomText(
            isShimmerView: isShimmerView,
            text: isShimmerView ? 85.toGenerateEmptyString() : title,
            color: appColors.black,
            size: AppDimen.textSize_14,
            fontWeight: AppFont.medium,
          ),
        if (isShimmerView)
          Expanded(
              child: CustomText(
                  text: 85.toGenerateEmptyString(),
                  isShimmerView: isShimmerView)),
        const SizedBox(
          width: 5,
        ),
        if (!isDes && !isShimmerView)
          CustomText(
            isShimmerView: isShimmerView,
            text: isShimmerView ? "" : details,
            color: details == "-"
                ? appColors.customTextColor
                : textColors ?? appColors.customTextColor,
            size: AppDimen.textSize_14,
            fontWeight: AppFont.regular,
          ),
        if (isPayout && !isShimmerView)
          showDropDown(payoutId!.value, reservationId)
      ]
          .toRow(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center)
          .toPad(top: 10, bottom: isDes ? 5 : 10, horizontal: 13),
      if (isDes)
        [
          if (!isShimmerView && guestName!.isNotEmpty)
            CustomText(
              overflow: TextOverflow.ellipsis,
              text: guestName,
              color: appColors.customTextColor,
              size: AppDimen.textSize_14,
              fontWeight: AppFont.regular,
            ).toPad(bottom: 6),
          if (!isShimmerView && listingName!.isNotEmpty)
            CustomText(
              overflow: TextOverflow.ellipsis,
              text: listingName,
              color:
                  listId != 0 ? AppColors.linkColor : appColors.customTextColor,
              size: AppDimen.textSize_14,
              fontWeight: AppFont.regular,
              maxLines: 2,
              onTap: () {
                if (listId != 0) {
                  controller.getItemInfo(listId: listId ?? 0);
                  controller.itemInfo != null
                      ? controller.profileNavigator?.navigateScreen(
                          ProfileScreen.propertyDetail,
                          [controller.itemInfo, 'transactionhistory'])
                      : controller.profileNavigator
                          ?.navigateScreen(ProfileScreen.notFound);
                }
              },
            ).toPad(bottom: 6),
          CustomText(
            overflow: TextOverflow.ellipsis,
            isShimmerView: isShimmerView,
            text: isShimmerView ? 50.toGenerateEmptyString() : details,
            color: appColors.customTextColor,
            size: AppDimen.textSize_14,
            fontWeight: AppFont.regular,
          ).toPad(bottom: 6),
          if (!isShimmerView && conformationCode!.isNotEmpty)
            CustomText(
              overflow: TextOverflow.ellipsis,
              text: conformationCode,
              color:
                  listId != 0 ? AppColors.linkColor : appColors.customTextColor,
              size: AppDimen.textSize_14,
              fontWeight: AppFont.regular,
              onTap: () async {
                if (controller.isReceiptOpen) return;
                controller.isReceiptOpen = true;
                if (listId != 0 && reservationId != 0) {
                  controller.isLoading.value = true;
                  controller.reservationResult = await controller
                      .getReservationInfo(reservationId: reservationId);
                  controller.isLoading.value = false;
                  String discountLabel = await controller.getMultilangContent(
                      content:
                          controller.reservationResult?.discountType ?? '');
                  debugPrint(
                      "controller.reservationResult: ${controller.reservationResult}");
                  CustomerReceiptBottomSheet(
                      receiptItem: controller.reservationResult!,
                      controller: controller,
                      discountLabel: discountLabel,
                      isFromTransaction: true);
                }
                // }
                controller.isReceiptOpen = false;
              },
            ).toPad(bottom: 6)
        ]
            .toColumn()
            .toPad(bottom: 4, top: isShimmerView ? 10 : 0, horizontal: 13),
      if (!isDes && !isShimmerView)
        (isDashedDivider ?? false)
            ? CustomDashDivider(
                height: 1,
                width: deviceWidth,
                dashWidth: 5,
                isCircle: false,
                color: appColors.filterDividerColor,
              )
            : filterDivider,
    ].toColumn();
  }

  Widget showDropDown(int payoutId, int reservationId) {
    List<StepItemModel> payoutList = [];
    payoutList.add(StepItemModel(id: 0, itemName: label_default.tr));
    if (controller.payoutList.isNotEmpty) {
      controller.payoutList.forEach((value) {
        StepItemModel stepItemModel = StepItemModel(
          id: value.id ?? 0,
          itemName: value.last4Digits != null
              ? "${"*" * 6}${value.last4Digits.toString()}"
              : value.payEmail.toString(),
        );
        payoutList.add(stepItemModel);
      });
    }

    return ListItemSelectionWidget(
      svgColor: appColors.primaryColor,
      textColor: appColors.primaryColor,
      borderColor: appColors.primaryColor,
      toShowTextField: false,
      fieldPadding: 5,
      arrowSVGSize: 12,
      title: label_pay_to.tr,
      isShowCloseIcon: false,
      topMargin: 0,
      controller: controller,
      listItems: payoutList,
      selectedId: payoutId,
      onItemSelected: (selected) {
        controller.updatedPayoutParam = {
          "reservationId": reservationId,
          "payoutId": selected.id
        };
        controller.checkNetwork(controller.updatePayoutMethod);
      },
      textOverFlow: TextOverflow.ellipsis,
    );
  }

  Widget transactionHistoryTopSection(
      {required TabBarItemModel item,
      GestureTapCallback? onTapFilter,
      int? tabBarIndex,
      required bool isShimmerView,
      dynamic amount}) {
    return [
      if (tabBarIndex != 2)
        ShimmerLoading(
          isLoading: isShimmerView,
          widgetType: 'transactionHistory',
          isDarkMode: controller.isDarkMode(),
          darkModeblend: BlendMode.dstIn,
          child: [
            tabBarIndex == 0
                ? Assets.drawablePayoutTick.toSVG(size: 20).toPad(end: 8)
                : Assets.drawablePayoutPending.toSVG(size: 20).toPad(end: 8),
            CustomText(
              isShimmerView: isShimmerView,
              text: isShimmerView
                  ? 30.toGenerateEmptyString()
                  : tabBarIndex == 0
                      ? "${paid_out.tr}:"
                      : tabBarIndex == 2
                          ? ""
                          : "${pending_payouts.tr}:",
              textStyle: TextStyle(
                  fontFamily: AppFont.font,
                  fontWeight: AppFont.medium,
                  color: appColors.textColor,
                  fontSize: AppDimen.textSize_14),
            ),
            CustomText(
              text: isShimmerView
                  ? ""
                  : tabBarIndex == 0
                      ? " ${double.tryParse(controller.paidOutAmount.value.toString()).toNumberFormat(symbol: controller.getCurrencySymbol())}"
                      : tabBarIndex == 2
                          ? ""
                          : " ${double.tryParse(controller.pendingPayoutAmount.value.toString()).toNumberFormat(symbol: controller.getCurrencySymbol())}",
              textStyle: TextStyle(
                  fontFamily: AppFont.font,
                  fontWeight: AppFont.medium,
                  color: appColors.textColor,
                  fontSize: AppDimen.textSize_14),
            )
          ]
              .toRow(mainAxisAlignment: MainAxisAlignment.start)
              .toPad(bottom: 18, top: 10),
        ),
      searchField(
        onTapFilter: onTapFilter ?? () {},
        isShimmerView: isShimmerView,
        onSubmitted: (value) {
          if (value.isEmpty) {
            controller.isLoading.value = true;
            controller.searchValue = value;
            controller.tabBaritems[controller.tabController.index]
                .listCurrentpage.value = 1;
            controller.checkNetwork(controller.getTransactionHistory);
          }
        },
        onChanged: (value) {
          if (controller.searchController.text.isNotEmpty) {
            isLinearloaderEnable = true;
            debugPrint("topsection: isloadingvalue ${controller.payoutList.isNotEmpty}");
            controller.isLoading.value = false;
            controller.isLoading.refresh();
            if (debounce?.isActive ?? false) debounce?.cancel();
            debounce = Timer(const Duration(milliseconds: 1500), () {
              controller.searchValue = controller.searchController.text.trim();
              controller.tabBaritems[controller.tabController.index]
                  .listCurrentpage.value = 1;
              isLinearloaderEnable = false;
              controller.checkNetwork(controller.getTransactionHistory);
            });
          } else {
            controller.searchValue = value;
            controller.tabBaritems[controller.tabController.index]
                .listCurrentpage.value = 1;
            controller.checkNetwork(controller.getTransactionHistory);
          }
        },
      ),
      Obx(() => controller.isLoading.value != null && isLinearloaderEnable
          ? LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              valueColor:
                  AlwaysStoppedAnimation<Color>(appColors.secondaryColor),
              minHeight: 2,
              borderRadius: BorderRadius.circular(40),
            )
          : const SizedBox.shrink())
    ].toColumn().toPad(start: 10, end: 10);
  }

  showEmptyView(
      {required int tabBarIndex,
      required TabBarItemModel item,
      required bool isShimmerView}) {
    return [
      CustomBorderContainer(
        color: appColors.white,
        borderRadius: AppDimen.appBorderRadius,
        padding: pad(a: 13),
        body: transactionHistoryTopSection(
            item: item,
            onTapFilter: () {
              debugPrint("isloadingvalue: ${controller.isLoading.value}");
              if (!controller.isLoading.value) navigateToFilterPage(item);
            },
            tabBarIndex: tabBarIndex,
            isShimmerView: isShimmerView),
      ),
      CustomEmptyView(
        emptyImageWidget: Assets.drawableTransactionEmptyView.toSVG(),
        emptyTitle: label_transaction_empty_title.tr,
        height: deviceHeight - 320,
        emptyDescription: label_transaction_empty_content.tr,
      )
    ].toColumn();
  }

  (String, DateTime) getFutureDateFormat({
    required String Dateformat,
    required dynamic milliSec,
  }) {
    return DateTime.fromMillisecondsSinceEpoch(int.parse(
            milliSec.toString().isNotEmpty
                ? milliSec.toString()
                : (DateTime.now().millisecondsSinceEpoch).toString()))
        .add(Duration(days: 1))
        .convert_MDY(format: Dateformat);
  }

  getTransactionListings() {
    if (controller.initialCount != -1 &&
            controller.initialCount !=
                controller.tabBaritems[controller.tabController.index]
                    .tabBarListData.length ||
        controller.tabBaritems[controller.tabController.index].listCurrentpage
                .value ==
            1) {
      var scrollcontroller = controller
          .tabBaritems[controller.tabController.index].tabliistScrollController;
      if (scrollcontroller.positions.length == 1 &&
          scrollcontroller.offset > 5.0) {
        controller.isEnableNewScrollController = false;
      }
      getFirstPageListData();
    } else {
      controller.getTransactionHistory();
    }
  }

  getFirstPageListData() {
    controller.initialCount = -1;
    TabBarItemModel tabItem =
        controller.tabBaritems[controller.tabController.index];
    controller.tabBaritems[controller.tabController.index] =
        tabItem.copyWith(listCurrentpage: 1);
    isShowLoader = false;
    controller.isLoading.value = true;
    controller.checkNetwork(controller.getTransactionHistory);
  }

  Widget searchField(
      {required GestureTapCallback onTapFilter,
      required bool isShimmerView,
      required ValueChanged<String> onChanged,
      required ValueChanged<String> onSubmitted}) {
    final widgetBuilder = switch (overALLThemeType) {
      4 => Theme4SearchField,
      3 => Theme3SearchField,
      2 => Theme2SearchField,
      _ => Theme1SearchField,
    };

    return widgetBuilder(
      onTapFilter: onTapFilter,
      isShimmerView: isShimmerView,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
    );
  }

  Widget Theme1SearchField(
      {required GestureTapCallback onTapFilter,
      required bool isShimmerView,
      required ValueChanged<String> onChanged,
      required ValueChanged<String> onSubmitted}) {
    Widget iconWidget = Assets.drawableExploreFilter.toSVG(
        size: 18, colour: appColors.black, colourBlendMode: BlendMode.srcIn);
    return [
      CustomPrefixTextField(
        applayout: AppLayout.themeType,
        borderWidth: 1,
        onSubmitted: onSubmitted,
        prefixIconWidget: Assets.drawableSearch.toSVG(size: 15).toPad(end: 5),
        maxLines: 1,
        isReadOnly: isShimmerView && controller.searchController.text.isEmpty,
        hintText: hite_transaction_search.tr,
        textSize: AppDimen.textSize_16,
        controller: controller.searchController,
        textInputAction: TextInputAction.done,
        hintFontWeight: FontWeight.normal,
        textCapitalization: TextCapitalization.words,
        onChanged: onChanged,
      ).toStretch(),
      CustomBorderContainer(
        borderRadius: overALLAppLayoutModel?.borderRadius,
        borderColor: controller.isFiltered.value
            ? appColors.secondaryColor
            : appColors.filterDividerColor,
        padding: pad(w: 14, h: 15),
        borderWidth: 1,
        margin: pad(start: 5),
        color: controller.isFiltered.value
            ? appColors.theme4AppBarBg
            : appColors.white,
        onTap: isShimmerView ? () {} : onTapFilter,
        body: controller.isFiltered.value
            ? filterSelectionWidget(iconWidget: iconWidget)
            : iconWidget,
      )
    ].toRow();
  }

  Widget Theme2SearchField(
      {required GestureTapCallback onTapFilter,
      required bool isShimmerView,
      required ValueChanged<String> onChanged,
      required ValueChanged<String> onSubmitted}) {
    Widget iconWidget =
        Assets.theme2ExploreFilter.toSVG(size: 15, colour: appColors.black);
    return CustomPrefixTextField(
      applayout: AppLayout.themeType,
      borderWidth: 1,
      borderTextfieldPadding: pad(start: 18),
      onSubmitted: onSubmitted,
      prefixIconWidget: Assets.drawableSearch
          .toSVG(size: 15, colour: appColors.colorCommonLinkColor)
          .toPad(end: 5),
      suffixIconWidget: CustomContainer(
        width: 48,
        height: 48,
        color: controller.isFiltered.value
            ? appColors.theme4AppBarBg
            : appColors.myTripsBGColor,
        alignment: AlignmentDirectional.center,
        onTap: onTapFilter,
        body: controller.isFiltered.value
            ? filterSelectionWidget(iconWidget: iconWidget)
            : iconWidget,
      ),
      maxLines: 1,
      isReadOnly: isShimmerView && controller.searchController.text.isEmpty,
      hintText: hite_transaction_search.tr,
      hintTextColor: appColors.customTextColor,
      textSize: AppDimen.textSize_16,
      controller: controller.searchController,
      textInputAction: TextInputAction.done,
      hintFontWeight: FontWeight.normal,
      textCapitalization: TextCapitalization.words,
      onChanged: onChanged,
    );
  }

  Widget Theme3SearchField(
      {required GestureTapCallback onTapFilter,
      required bool isShimmerView,
      required ValueChanged<String> onChanged,
      required ValueChanged<String> onSubmitted}) {
    Widget iconWidget = Assets.drawableTheme3Filter.toSVG(
        fit: BoxFit.scaleDown,
        size: 20,
        colour: appColors.black,
        colourBlendMode: BlendMode.srcIn);
    return [
      TitleTextField(
        applayout: AppLayout.themeType,
        borderWidth: 1,
        onSubmitted: onSubmitted,
        maxLines: 1,
        isReadOnly: isShimmerView && controller.searchController.text.isEmpty,
        hintText: hite_transaction_search.tr,
        hintTextColor: appColors.customTextColor,
        controller: controller.searchController,
        textInputAction: TextInputAction.done,
        textCapitalization: TextCapitalization.words,
        onChanged: onChanged,
      ).toStretch(),
      CustomBorderContainer(
        borderRadius: overALLAppLayoutModel?.borderRadius ?? 14,
        borderColor: controller.isFiltered.value
            ? appColors.secondaryColor
            : appColors.filterDividerColor,
        borderWidth: 1,
        shape: BoxShape.circle,
        padding: pad(a: 12),
        color: controller.isFiltered.value
            ? appColors.theme4AppBarBg
            : appColors.white,
        onTap: isShimmerView ? () {} : onTapFilter,
        body: controller.isFiltered.value
            ? filterSelectionWidget(iconWidget: iconWidget)
            : iconWidget,
      )
    ].toRow();
  }

  Widget Theme4SearchField(
      {required GestureTapCallback onTapFilter,
      required bool isShimmerView,
      required ValueChanged<String> onChanged,
      required ValueChanged<String> onSubmitted}) {
    Widget iconWidget = Assets.drawableTheme3Filter.toSVG(
        fit: BoxFit.scaleDown,
        size: 20,
        onTap: onTapFilter,
        colour: controller.isFiltered.value
            ? appColors.colorCommonLinkColor
            : appColors.black,
        colourBlendMode: BlendMode.srcIn);
    return CustomPrefixTextField(
      applayout: AppLayout.themeType,
      borderWidth: 1,
      onSubmitted: onSubmitted,
      prefixIconWidget: Assets.drawableSearch.toSVG(size: 15).toPad(end: 5),
      suffixIconWidget: controller.isFiltered.value
          ? filterSelectionWidget(iconWidget: iconWidget)
          : iconWidget,
      maxLines: 1,
      isReadOnly: isShimmerView && controller.searchController.text.isEmpty,
      hintText: hite_transaction_search.tr,
      textSize: AppDimen.textSize_16,
      controller: controller.searchController,
      textInputAction: TextInputAction.done,
      hintFontWeight: FontWeight.normal,
      textCapitalization: TextCapitalization.words,
      onChanged: onChanged,
    );
  }

  Widget filterSelectionWidget({required Widget iconWidget}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        iconWidget,
        PositionedDirectional(
            top: (overALLThemeType == 2)
                ? -8
                : overALLThemeType == 3 || overALLThemeType == 4
                    ? -4
                    : -6,
            end: (overALLThemeType == 3 || overALLThemeType == 4) ? -1 : -8,
            child: CustomContainer(
              height: 7,
              width: 7,
              decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(width: 1, color: Colors.white)),
            ))
      ],
    );
  }

  void navigateToFilterPage(TabBarItemModel tabItem) {
    FocusManager.instance.primaryFocus!.unfocus();
    debugPrint(
        "backresult :before  --- ${controller.filteredPayoutId} --- ${controller.filteredManageListId}");
    Get.to(() => TransactionFilter(), arguments: {
      "PayoutId": controller.filteredPayoutId,
      "ListId": controller.filteredManageListId,
      'isloading': controller.isLoading.value
    })?.then((result) {
      debugPrint(
          "backresult :2  ${result} --- ${controller.filteredPayoutId} --- ${controller.filteredManageListId}");
      if (result != null && result.toString().isNotEmpty) {
        if (controller.filteredPayoutId == result["PayoutId"] &&
            controller.filteredManageListId == result["ListId"]) return;
        if (result["PayoutId"] != 0) {
          controller.filteredPayoutId = result["PayoutId"];
        } else {
          controller.filteredPayoutId = null;
        }
        if (result["ListId"] != 0) {
          controller.filteredManageListId = result["ListId"];
        } else {
          controller.filteredManageListId = null;
        }
        controller.isFiltered.value =
            result["PayoutId"] != 0 || result["ListId"] != 0;
        controller.isLoading.value = true;
        tabItem.tabBarListData.clear();
        tabItem.copyWith(
            listCurrentpage: 1,
          tabBarListData: []
        );
        controller.checkNetwork(controller.getTransactionHistory);
      }
    });
  }
}