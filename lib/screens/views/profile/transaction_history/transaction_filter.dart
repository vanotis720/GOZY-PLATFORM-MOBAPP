import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/screens/views/profile/transaction_history/transaction_history_controller.dart';
import 'package:gozy/widgets/common/custom_button/primary_button.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_stateful_widget.dart';
import 'package:gozy/widgets/custom_text.dart';

import '../../../../constant.dart';
import '../../../../resources/app_dimen.dart';
import '../../../../resources/app_lang.dart';
import '../../../../widgets/checkbox_group.dart';
import '../../../../widgets/common/custom_container/custom_bottom_item_shadow_container.dart';
import '../../base_controller.dart';

class TransactionFilter extends CustomStatefulWidget {
  const TransactionFilter({super.key});

  @override
  _TransactionFilterStatefulWrapperState createState() => _TransactionFilterStatefulWrapperState();
}

class _TransactionFilterStatefulWrapperState extends CustomStatefulWidgetState<TransactionFilter> {
  final controller = Get.find<TransactionHistoryController>();
  @override
  void initState() {
    debugPrint("get.arguments: ${Get.arguments} --- ${controller.manageList.isEmpty} --- ${controller.payoutList.isEmpty}");
    if(controller.manageList.isEmpty || controller.payoutList.isEmpty) {
      isShowLoader = true;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.isLoading.value = Get.arguments['isloading'];
      if(Get.arguments?['PayoutId'] !=null){
        List<int> listids = [];
        listids.add(Get.arguments?['PayoutId']);
        controller.change(rxVariable:controller.rxSelectedPayoutList,value: listids);
      }
      if(Get.arguments?['ListId'] !=null) {
        List<int> listids = [];
        listids.add(Get.arguments?['ListId']);
        controller.change(rxVariable: controller.rxSelectedManageListingList, value: listids);
      }
      if (controller.rxSelectedPayoutList.value.isEmpty) {
        controller.change(rxVariable: controller.rxSelectedPayoutList, value: [0]);
      }
      if(controller.rxSelectedManageListingList.value.isEmpty) {
        controller.change(rxVariable: controller.rxSelectedManageListingList, value: [0]);
      }
    });


    debugPrint(" controller.rxSelectedManageListingList ${ controller.rxSelectedManageListingList.value}");
    controller.isBackRefresh = false;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      isShowAppBar: true,
      backIconWidget: getBackIconWidget(themeType: overALLThemeType, backIcon: Assets.drawableSignupClose),
      controller: controller,
      customAppBarFunction: () {
        Get.back();
      },
      action: CustomText(
        text: label_clear_all.tr,
        size: AppDimen.textSize_16,
        color: appColors.secondaryColor,
        onTap: () {
          controller.change(rxVariable: controller.rxSelectedPayoutList, value: [0]);
          controller.change(rxVariable: controller.rxSelectedManageListingList, value: [0]);
        },
      ).toPad(end: AppDimen.startMargin),
      body: [
        Obx(() {
          controller.isLoading.value;
          controller.payoutList;
          controller.manageList;
          controller.paidOutAmount.value;
          controller.pendingPayoutAmount.value;
        return Expanded(child: _showFilterItems().toPad(horizontal: AppDimen.startMargin));
    }),
        _showBottomFilterButtons(),
      ].toColumn(mainAxisSize: MainAxisSize.max),
    );
  }

  Widget _showcheckBoxFilter(
      {required String HeaderText,
      required List<Map<String, dynamic>>? labels,
      required ReactiveVariable onSelected}) {
    debugPrint("_showcheckBoxFilter:  ${onSelected.value}");
    return [
      CustomTitleText(
        text: HeaderText,
        size: AppDimen.textSize_18,
        fontWeight: AppFont.medium,
      ),
      ListingsFeaturesGroup(
        isShowNetworkIcon: false,
        labels: labels,
        onSelected: onSelected,
        controller: controller,
        isRemoveShowLessAndMore: labels!.length > 4 ? false : true,
        showLessFilterItemCount: 4,
        isSingleCheck: true,
        checkListItemColor: appColors.customTextColor,
        borderRadius: 10,
      ),
    ].toColumn();
  }

  Widget showListItemFilter(
      {required String intialvalue,
      required String HeaderText,
      required List<dynamic> FilterList,
      required ReactiveVariable onSelectedList}) {
    Map<String, dynamic> manageListItem = {};
    List<Map<String, dynamic>> filterListingList = [];
    filterListingList.add({"id": 0, "itemName": intialvalue});
    if (FilterList.isNotEmpty) {
      FilterList.forEach((value) {
        manageListItem = {
          "id": value?.id ?? 0,
          "itemName": (HeaderText == label_filter_payout_methods.tr)
              ? (value.last4Digits != null ? "${"*" * 6}${value.last4Digits}" : value.payEmail ?? "")
              : value?.title ?? ""
        };
        filterListingList.add(manageListItem);
      });
    }
    return _showcheckBoxFilter(
      HeaderText: HeaderText,
      labels: filterListingList,
      onSelected: onSelectedList,
    );
  }

  Widget _showFilterItems() {
    List<Widget> _filterwidgets = [
      showListItemFilter(
          intialvalue: label_filder_payout_initial_value.tr,
          HeaderText: label_filter_payout_methods.tr,
          FilterList: controller.payoutList,
          onSelectedList: controller.rxSelectedPayoutList),
      showListItemFilter(
          intialvalue: label_filder_listing_initial_value.tr,
          HeaderText: label_filter_cars.tr,
          FilterList: controller.manageList,
          onSelectedList: controller.rxSelectedManageListingList).toPad(bottom: 10)
    ];
    return toListScroll(WidgetList: _filterwidgets, isFromItinerary: (overALLThemeType == 4 || overALLThemeType == 3) ? true : false,dividerSpace: 15);
  }

  Widget _showBottomFilterButtons() {
    return CustomBottomItemShadowContainer(
      height: 90,
      padding: pad(w: 20, top: 25, bottom: 20),
      body: PrimaryButton(
        buttonText: label_view_results.tr,
        onTap: () {
          int payoutId = controller.rxSelectedPayoutList.value.isEmpty ? 0 : controller.rxSelectedPayoutList.value.first;
          int listId = controller.rxSelectedManageListingList.value.isEmpty ? 0 : controller.rxSelectedManageListingList.value.first;
          if (payoutId != 0 || listId != 0) {
            controller.isFiltered.value = true;
            Get.back(result: {"PayoutId": payoutId, "ListId": listId });
          } else {
            Get.back( result:{"PayoutId": 0, "ListId": 0});
          }
        },
      ),
    );
  }
}