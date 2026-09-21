import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/resources/app_layout.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/screens/views/profile/profile_controller.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/common/custom_container/custom_container.dart';
import 'package:gozy/widgets/custom_text.dart';

import '../../../../model/tab_bar_item_model.dart';
import '../../../../resources/app_dimen.dart';
import '../../../../resources/app_font.dart';
import '../../../../widgets/custom_popup_menu.dart';
import '../../../../widgets/custom_textfield.dart';
import '../../../../widgets/dotted_border/dotted_border.dart';
import '../../../../widgets/rect_getter.dart';
import '../../../../widgets/theme4/custom_dash_divider.dart';
import '../profile_navigator.dart';
import 'service_plan_controller.dart';
import '../../../../widgets/common/custom_dialog/custom_dialog.dart';

class ServicePlanHistory extends StatefulWidget {
  const ServicePlanHistory({super.key});

  @override
  State<ServicePlanHistory> createState() => _ServicePlanHistoryState();
}

class _ServicePlanHistoryState extends State<ServicePlanHistory> with TickerProviderStateMixin {
  ServicePlanController controller = Get.find();
  ProfileController profileController = Get.find();
  ScrollController servicePlanHistoryScrollController = ScrollController();
  int _previousIndex = 0;
  String showMoreIcon = Assets.theme1More;
  String popupShowMoreIcon = Assets.theme1More;
  bool showMoreText = true;
  Color? moreIconColor = appColors.colorCommonLinkColor;
  double servicePlanCardBorderRadius = 0;
  double showMorePadding = 0;
  final List<String> _tabs = [label_renter_plans.tr, label_owner_plans.tr];

  @override
  void initState() {
    controller.servicePlanHistoryCurrentPage = 1;
    controller.servicePlanHistoryTabController = TabController(length: _tabs.length, vsync: this);
    controller.tabBaritems = List<TabBarItemModel>.generate(_tabs.length, (index) {
      PageStorageKey pagekey = PageStorageKey('${_tabs[index]}: ${Random().nextInt(10000)}');
      TabBarItemModel tabbarmodal = (
        pageStorageKey: pagekey,
        totalCount: 1,
        tabBarListData: [],
        tabliistScrollController: ScrollController(),
        listCurrentpage: 1.obs,
        isTabLoading: true,
        type: _tabs[index],
        nonFilterTabBarListData: []
      );
      return tabbarmodal;
    });

    controller.servicePlanHistoryTabController.addListener(() {
      if (controller.servicePlanHistoryTabController.index != _previousIndex) {
        FocusScope.of(context).unfocus();
        if (servicePlanHistoryScrollController.hasClients) {
          servicePlanHistoryScrollController.jumpTo(0);
        }
        controller.servicePlanHistoryCurrentPage = 1;
        controller.servicePlanHistoryTotalCount = 0;
        controller.searchController.clear();
        isShowLoader = false;
        controller.isServicePlanHistoryLoading.value = true;

        var currentTabItem = controller.tabBaritems[controller.servicePlanHistoryTabController.index];
        controller.tabBaritems[controller.servicePlanHistoryTabController.index] = currentTabItem.copyWith(
          isTabLoading: true,
        );
        controller.getServicePlanHistory();
        _previousIndex = controller.servicePlanHistoryTabController.index;
      }
    });
    servicePlanHistoryScrollController.addListener(() {
      if (servicePlanHistoryScrollController.position.pixels ==
          servicePlanHistoryScrollController.position.maxScrollExtent) {
        if (!(controller.servicePlanHistoryList.length == controller.servicePlanHistoryTotalCount)) {
          controller.servicePlanHistoryCurrentPage++;
          controller.getServicePlanHistory();
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getServicePlanHistory();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch (overALLThemeType) {
      case 1:
        showMoreIcon = Assets.theme1More;
        popupShowMoreIcon = Assets.theme1More;
        servicePlanCardBorderRadius = 6;
        showMorePadding = 12;
        moreIconColor = appColors.colorCommonLinkColor;
        break;
      case 2:
        showMoreIcon = Assets.theme2More;
        popupShowMoreIcon = Assets.theme2More;
        showMorePadding = 12;
        moreIconColor = appColors.colorCommonLinkColor;
        break;
      case 3:
        servicePlanCardBorderRadius = 24;
        showMoreText = false;
        showMoreIcon = Assets.theme3More;
        popupShowMoreIcon = Assets.theme3More;
        moreIconColor = null;
        showMorePadding = 7;
        break;
      default:
        servicePlanCardBorderRadius = 12;
        showMorePadding = 10;
        moreIconColor = appColors.colorCommonLinkColor;
        showMoreIcon = Assets.theme4More;
        popupShowMoreIcon = Assets.drawableViewdetailShareMore;
        break;
    }

    return CustomScaffold(
      customAppBarFunction: () {
        profileController.isShowMoreOnServicePlan = true;
        Get.back();
      },
      controller: basecontroller,
      isShowAppBar: true,
      backIconWidget: getBackIconWidget(
          onTap: () {
            profileController.isShowMoreOnServicePlan = true;
            Get.back();
          },
          iconColor: appColors.black),
      body: showBodyContentWidget(),
      action: profileController.isShowMoreOnServicePlan
          ? overALLThemeType == 3
            ? CustomContainer(
              height: 40,
              width: 40,
              onTap: () {
                CustomPopupMenu(
                    borderRadius: overALLThemeType == 3 ? 12 : null,
                    controller: controller,
                    isShowDashDivider: false,
                    PopupMenuItems: [
                      {
                        "text": label_service_plan.tr,
                        "ontap": () {
                          profileController.isShowMoreOnServicePlan = false;
                          controller.profileNavigator?.navigateScreen(ProfileScreen.servicePlan);
                        }
                      }
                    ],
                    offset: Offset(5, 70));
              },
              padding: pad(a: showMorePadding),
              decoration: BoxDecoration(
                color: appColors.myTripsBGColor,
                shape: BoxShape.circle,
                border: Border.all(
                color: appColors.myTripsBGColor, width: 1)
              ),
              body: popupShowMoreIcon.toSVG(),
            ).toPad(end: AppDimen.startMargin) :
            CustomContainer(
              height: 40,
              width: 40,
              onTap: () {
                CustomPopupMenu(
                    borderRadius: overALLThemeType == 3 ? 12 : null,
                    controller: controller,
                    isShowDashDivider: false,
                    PopupMenuItems: [
                      {
                        "text": label_service_plan.tr,
                        "ontap": () {
                          profileController.isShowMoreOnServicePlan = false;
                          controller.profileNavigator?.navigateScreen(ProfileScreen.servicePlan);
                        }
                      }
                    ],
                    offset: Offset(5, 70));
              },
              padding: pad(a: showMorePadding),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: appColors.myTripsDividerColor, width: 1)),
              body: popupShowMoreIcon.toSVG(colour: moreIconColor),
            ).toPad(end: AppDimen.startMargin)
          : 0.toHeight(),
    );
  }

  GetBuilder<ServicePlanController> showBodyContentWidget() {
    return GetBuilder<ServicePlanController>(builder: (newController) {
      return [
        CustomText(
          text: label_service_plan_history.tr,
          size: AppDimen.textSize_26,
          fontWeight: AppFont.bold,
        ).toPad(horizontal: AppDimen.startMargin, bottom: 10),
        toTabBarView(
          tabs: _tabs,
          tabBarWidgets: List<Widget>.generate(
              controller.tabBaritems.length,
              (index) => Obx(() => showTabBarWidgets(
                      isLoading: controller.isServicePlanHistoryLoading.value ||
                          (index != controller.servicePlanHistoryTabController.index),
                      index: index)
                  .toShimmer(controller: controller))),
          tabController: controller.servicePlanHistoryTabController,
        ).toStretch(),
      ].toColumn();
    });
  }

  Widget showTabBarWidgets({required bool isLoading, required int index}) {
    return [
      showSearchBar(),
      (((!isLoading && controller.servicePlanHistoryList.isEmpty)
          ? LayoutBuilder(builder: (context, constraints) {
              return [
                Center(child: showEmptyView(index: index)).toResizeWidget(height: constraints.maxHeight)
              ].toScroll(physics: const AlwaysScrollableScrollPhysics()).toRefresh(onRefresh: controller.onRefresh);
            })
          : Obx(() => [
                toListView(
                    controller: servicePlanHistoryScrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    key: const PageStorageKey<String>('servicePlanHistoryList'),
                    itemCount: isLoading ? 3 : controller.servicePlanHistoryList.length,
                    itemBuilder: (context, index) {
                      return showServicePlanCard(isLoading: isLoading, index: index);
                    }),
                controller.isPaginationLoading.value
                    ? Positioned(
                        bottom: bottomViewPadding,
                        child: controller
                            .getLoader(
                                loader: LottieLoaders.three_dots_loader.name,
                                changed: appThemeChanged.value,
                                color: appColors.secondaryColor)
                            .toResizeWidget(all: 120))
                    : 0.toHeight()
              ].toStack(alignment: Alignment.center)
      )
      ).toRefresh(onRefresh: controller.onRefresh))
          .toStretch()
    ].toColumn();
  }

  Widget showEmptyView({required int index}) {
    String image = Assets.drawableServicePlanNoData ;
    String titleText =  "no_plan_history_available".tr ;
    String descText =  manual_plan_renewal_required.tr ;
    String linkText =  "view_available_plans".tr;

    return [
      image.toSVG(imageAlignment: Alignment.center),
      10.toHeight(),
      CustomText(
        textAlign: TextAlign.center,
        text: titleText,
        size: AppDimen.textSize_22,
        fontWeight: AppFont.semiBold,
      ),
      10.toHeight(),
      CustomText(
        textAlign: TextAlign.center,
        text: descText,
        size: AppDimen.textSize_16,
        fontWeight: AppFont.regular,
      ),
      10.toHeight(),
      CustomText(
        onTap: () {
          profileController.isShowMoreOnServicePlan = false;
          controller.profileNavigator?.navigateScreen(ProfileScreen.servicePlan);
        },
        text: linkText,
        size: AppDimen.textSize_16,
        fontWeight: AppFont.regular,
        color: appColors.secondaryColor,
      ),
    ].toColumn(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center).toPad(horizontal: AppDimen.startMargin);
  }

  Widget showSearchBar() {
    Widget searchField = <Widget>[
      if (overALLThemeType == 2) ...[
        Assets.drawableSearch.toSVG(colour: appColors.secondaryColor, size: 16),
        6.toWidth()
      ] else if (overALLThemeType == 3) ...[
      ] else ...[
        Assets.drawableSearch.toSVG(size: 16),
        6.toWidth()
      ],
      Expanded(
        child: CustomTextField(
          textInputAction: TextInputAction.done,
          controller: controller.searchController,
          hintText: "label_search_plans".tr,
          onChanged: (value) => controller.onSearchChanged(value),
          textSize: AppDimen.textSize_16,
          hintTextColor: appColors.textFieldInActiveIconColor,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    ].toRow().toPad(horizontal: overALLThemeType == 4 ? 0 : 16, vertical: overALLThemeType == 4 ? 0 : 12);

    Widget searchBar;
    if (overALLThemeType == 4) {
      searchBar = [
        searchField,
        6.toHeight(),
        filterDivider,
      ].toColumn();
    } else {
      searchBar = CustomContainer(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(servicePlanCardBorderRadius),
          color: appColors.white,
          border: Border.all(color: appColors.filterDividerColor, width: 1),
        ),
        body: searchField,
      );
    }

    return searchBar.toPad(horizontal: AppDimen.startMargin, bottom: 5, top: 20);
  }

  Widget showServicePlanCard({required bool isLoading, required int index}) {
    Widget cardContent = CustomContainer(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(servicePlanCardBorderRadius),
          color: overALLThemeType == 1 ? appColors.myTripsBGColor : appColors.white,
          border: overALLThemeType != 4
              ? Border.all(color: appColors.filterDividerColor, width: 1)
              : null,
        ),
        body: [
          getRowItem(
              title: isLoading ? 20.toGenerateEmptyString() : label_plan.tr,
              value: isLoading
                  ? 30.toGenerateEmptyString()
                  : "${controller.servicePlanHistoryList[index]?.servicePlanName}",
              isLoading: isLoading,
              valueColor: appColors.secondaryColor,
              isShowDivider: true,
              isShowMore: true,
              isPlanRow: true,
              index: index),
          getRowItem(
              title: isLoading ? 20.toGenerateEmptyString() : label_price.tr,
              value: isLoading
                  ? 30.toGenerateEmptyString()
                  : "${controller.getCurrencySymbol()}${double.parse(controller.servicePlanHistoryList[index]?.price?.currencyConverted(convertedCurrency: controller.servicePlanHistoryList[index]?.currency ?? defaultCurrency) ?? "0").toFormattedString()}",
              isLoading: isLoading,
              isShowDivider: true),
          getRowItem(
              title: isLoading ? 20.toGenerateEmptyString() : label_receipt_title_duration.tr,
              value: isLoading
                  ? 30.toGenerateEmptyString()
                  : "${controller.servicePlanHistoryList[index]?.duration} ${label_month.tr}",
              isLoading: isLoading,
              isShowDivider: true),
          getRowItem(
              title: isLoading ? 20.toGenerateEmptyString() : label_payout_status.tr,
              value: isLoading
                  ? 30.toGenerateEmptyString()
                  : controller.servicePlanHistoryList[index]?.servicePlanStatus?.toUpperLowerCase(),
              isLoading: isLoading,
              valueColor: isLoading
                  ? null
                  : controller.servicePlanHistoryList[index]?.servicePlanStatus == "active"
                      ? appColors.discountAmountColor
                      : controller.servicePlanHistoryList[index]?.servicePlanStatus == "cancelled"
                          ? appColors.errorRed
                          : null,
              isShowDivider: true),
          getRowItem(
              title: isLoading ? 20.toGenerateEmptyString() : label_calendar_start_date.tr,
              value: isLoading
                  ? 30.toGenerateEmptyString()
                  : getDateFormat(
                          dateFormat: commonDateFormat,
                          milliSec: controller.servicePlanHistoryList[index]?.startDate ?? "")
                      .$1
                      .toString(),
              isLoading: isLoading,
              isShowDivider: true),
          getRowItem(
              title: isLoading ? 20.toGenerateEmptyString() : label_calendar_end_date.tr,
              value: isLoading
                  ? 30.toGenerateEmptyString()
                  : getDateFormat(
                          dateFormat: commonDateFormat,
                          milliSec: controller.servicePlanHistoryList[index]?.endDate ?? "")
                      .$1
                      .toString(),
              isLoading: isLoading,
              isShowDivider: true),
          [
            CustomText(
              text: "${label_payout_details.tr}:",
              size: AppDimen.textSize_14,
              isShimmerView: isLoading,
              fontWeight: AppFont.medium,
            ),
             [
                getBenefitsWidget(
                    isLoading: isLoading,
                    description: isLoading
                        ? 20.toGenerateEmptyString()
                        : "${(controller.servicePlanHistoryList[index]?.serviceFee?.toInt() ?? "")}% ${label_service_fee.tr}"),
                (!isLoading && (controller.servicePlanHistoryList[index]?.serviceAIFeature ?? false))
                    ? getBenefitsWidget(isLoading: isLoading, description: label_ai_features.tr)
                    : 0.toHeight(),
              ].toScroll(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
              ),
          ].toColumn(crossAxisAlignment: CrossAxisAlignment.start).toPad(vertical: 12, horizontal: 10)
        ].toColumn());

    if (overALLThemeType == 4) {
      return DottedBorderView(
              dottedlineColor: appColors.filterDividerColor,
              borderRadius: servicePlanCardBorderRadius,
              topPadding: 2,
              bottomPadding: 2,
              leftPadding: 2,
              rightPadding: 2,
              child: cardContent)
          .toPad(horizontal: AppDimen.startMargin, top: 18);
    }

    return cardContent.toPad(horizontal: AppDimen.startMargin, top: 18);
  }

  Widget getRowItem(
      {String? title,
      String? value,
      required bool isLoading,
      bool? isShowDivider,
      Color? valueColor,
      bool? isShowMore,
      bool isPlanRow = false,
      int? index}) {
    var overlayIconKey = RectGetter.createGlobalKey();
    print(servicePlanCardBorderRadius);
    return [
      [
        [
          CustomText(
            text: title ?? " ",
            isShimmerView: isLoading,
            fontWeight: AppFont.medium,
            size: AppDimen.textSize_14,
          ),
          5.toWidth(),
          isPlanRow && !isLoading
              ? [
                  CustomContainer(
                    height: 24,
                    width: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(overALLThemeType == 4 ? 8 : overALLThemeType == 2 ? 0 : overALLThemeType == 1 ? 2 : 12),
                      color: appColors.starterPlanCircleColor,
                    ),
                    body: ClipRRect(
                      borderRadius: BorderRadius.circular(overALLThemeType == 4 ? 8 : overALLThemeType == 2 ? 0 : overALLThemeType == 1 ? 2 : 12),
                      child: CachedNetworkImage(
                        height: 24,
                        width: 24,
                        fit: BoxFit.cover,
                        imageUrl: servicePlanImagePathSmall + (controller.servicePlanHistoryList[index!]?.servicePlanData?.mediaImage ?? ""),
                        placeholder: (context, url) => Assets.drawableStarter.toSVG().toPad(all: 5),
                        errorWidget: (context, url, error) => Assets.drawableStarter.toSVG().toPad(all: 5),
                      ),
                    ),
                  ),
                  4.toWidth(),
                  CustomText(
                    text: value ?? "",
                    isShimmerView: isLoading,
                    fontWeight: AppFont.regular,
                    color: valueColor,
                    size: AppDimen.textSize_14,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ).toStretch(),
                ].toRow(mainAxisSize: MainAxisSize.min).toStretch()
              : CustomText(
                  text: value ?? "",
                  isShimmerView: isLoading,
                  fontWeight: AppFont.regular,
                  color: valueColor,
                  size: AppDimen.textSize_14,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ).toStretch(),
        ].toRow(mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.min).toStretch(),
        ((isShowMore ?? false) && !isLoading)
            ? RectGetter(
                key: overlayIconKey,
                child: toOnTap(
                    onTapUp: (details) {
                      isClaimMenuAdded = false;
                      Rect? overlayrect = RectGetter.getRectFromKey(overlayIconKey);
                      CustomPopupMenu(
                          borderRadius: overALLThemeType == 3 ? 12 : null,
                          controller: controller,
                          PopupMenuItems: ((index != null && index < controller.servicePlanHistoryList.length) &&
                                  controller.servicePlanHistoryList[index]?.servicePlanStatus == "active")
                              ? [
                                  {
                                    "text": label_cancel.tr,
                                    "ontap": () {
                                      showAlertDialog(
                                          title: "label_cancel_plan".tr.toUpperLowerCase(),
                                          okButtonContent: label_confirm.tr,
                                          cancelButtonContent: "label_close".tr.toUpperLowerCase(),
                                          content: [
                                            CustomText(text: "cancel_plan_heading".tr, fontWeight: AppFont.regular, size: AppDimen.textSize_14,),
                                            10.toHeight(),
                                            RichText(
                                                text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                          text: "${"label_plan_name".tr}: ",
                                                          style: TextStyle(
                                                              fontFamily: AppFont.font,
                                                              fontWeight: AppFont.semiBold,
                                                              fontSize: AppDimen.textSize_14,
                                                              color: appColors.customTextColor
                                                          )
                                                      ),
                                                      TextSpan(
                                                          text: controller.servicePlanHistoryList[index]?.servicePlanName,
                                                          style: TextStyle(
                                                              fontFamily: AppFont.font,
                                                              fontWeight: AppFont.regular,
                                                              fontSize: AppDimen.textSize_14,
                                                              color: appColors.customTextColor
                                                          )
                                                      ),
                                                    ]
                                                )
                                            ),
                                            10.toHeight(),
                                            CustomText(text: "cancel_plan_desc".tr, fontWeight: AppFont.regular, size: AppDimen.textSize_14,),
                                            10.toHeight(),
                                            CustomText(text: '${"what_happens_next".tr}:', fontWeight: AppFont.semiBold, size: AppDimen.textSize_14,),
                                            5.toHeight(),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                CustomText(text: "• "),
                                                Expanded(
                                                  child: CustomText(
                                                    text: "what_will_happen_1".tr,
                                                    fontWeight: AppFont.regular,
                                                    size: AppDimen.textSize_14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            5.toHeight(),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                CustomText(text: "• "),
                                                Expanded(
                                                  child: CustomText(
                                                    text: "what_will_happen_2".tr,
                                                    fontWeight: AppFont.regular,
                                                    size: AppDimen.textSize_14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            5.toHeight(),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                CustomText(text: "• "),
                                                Expanded(
                                                  child: CustomText(
                                                    text: "what_will_happen_3".tr,
                                                    fontWeight: AppFont.regular,
                                                    size: AppDimen.textSize_14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ].toColumn(),
                                          onOkPressed: () {
                                            Get.back();
                                            controller
                                                .cancelPurchasePlan(id: controller.servicePlanHistoryList[index]?.id)
                                                .then((value) {
                                              controller.servicePlanHistoryCurrentPage = 1;
                                              controller.getServicePlanHistory();
                                            });
                                          },
                                          appLayout: AppLayout.themeType,
                                      );
                                    }
                                  },
                                  {
                                    "text": label_receipt.tr,
                                    "ontap": () {
                                      controller.profileNavigator?.navigateScreen(ProfileScreen.receipt, {
                                        "id": index != null ? controller.servicePlanHistoryList[index]?.id : 0
                                      });
                                    }
                                  }
                                ]
                              : [
                                  {
                                    "text": label_receipt.tr,
                                    "ontap": () {
                                      controller.profileNavigator?.navigateScreen(ProfileScreen.receipt, {
                                        "id": index != null ? controller.servicePlanHistoryList[index]?.id : 0
                                      });
                                    }
                                  }
                                ],
                          offset: Offset(overlayrect?.left ?? details.globalPosition.dx,
                              (overlayrect?.top ?? details.globalPosition.dy) + 6));
                    },
                    child: [
                      showMoreIcon.toSVG(colour: showMoreText ? appColors.secondaryColor : null),
                      if(overALLThemeType!=3)
                      4.toWidth(),
                      if(overALLThemeType!=3)
                      CustomText(
                        text: label_share_listing_more.tr,
                        fontWeight: AppFont.regular,
                        size: AppDimen.textSize_14,
                        color: appColors.secondaryColor,
                      ),
                    ].toRow()),
              ).toPad(start: 10)
            : const SizedBox.shrink()
      ]
          .toRow(mainAxisAlignment: MainAxisAlignment.spaceBetween)
          .toPad(horizontal: 12, vertical: 12)
          .toShimmer(controller: controller),
      (isShowDivider ?? false)
          ? (overALLThemeType == 4
              ? fullWidthDashDivider()
              : filterDivider)
          : const SizedBox.shrink()
    ].toColumn();
  }

  Widget getBenefitsWidget({required String description, required bool isLoading}) {
    return [
      if (!isLoading) ...[Assets.drawableRightArrow.toSVG(colour: appColors.black, size: 10), 5.toWidth()],
      CustomText(
        text: isLoading ? 30.toGenerateEmptyString() : description,
        size: AppDimen.textSize_14,
        isShimmerView: isLoading,
        fontWeight: AppFont.regular,
      )
    ].toRow(mainAxisAlignment: MainAxisAlignment.start).toPad(top: 10);
  }
}