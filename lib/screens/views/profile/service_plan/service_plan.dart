import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/screens/views/profile/profile_controller.dart';
import 'package:gozy/widgets/common/custom_button/primary_button.dart';
import 'package:gozy/widgets/common/custom_container/custom_border_container.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/common/custom_button/custom_button.dart';
import 'package:gozy/widgets/common/custom_container/custom_container.dart';
import 'package:gozy/widgets/common/custom_text/expandable_collapse_text.dart';
import 'package:gozy/widgets/custom_text.dart';
import 'package:get/get.dart';
import '../../../../model/tab_bar_item_model.dart';
import '../../../../resources/app_dimen.dart';
import '../../../../resources/app_font.dart';
import '../../../../resources/app_layout.dart';
import '../../../../widgets/common/custom_dialog/custom_dialog.dart';
import '../../../../widgets/custom_popup_menu.dart';
import '../profile_navigator.dart';
import '../../booking/confirm_pay/confirm_pay_page_controller.dart';
import 'service_plan_controller.dart';

class ServicePlan extends StatefulWidget {
  const ServicePlan({super.key});

  @override
  State<ServicePlan> createState() => _ServicePlanState();
}

class _ServicePlanState extends State<ServicePlan> with TickerProviderStateMixin {

  ServicePlanController  controller = Get.find();
  ProfileController  profileController = Get.find();
  ScrollController servicePlanScrollController = ScrollController();
  int _previousIndex = 0;
  String showMoreIcon = Assets.theme1More;
  Color? moreIconColor = appColors.colorCommonLinkColor;
  double servicePlanCardBorderRadius = 0;
  double showMorePadding = 0;
  final List<String> _tabs = [label_renter_plans.tr,label_owner_plans.tr];

  @override
  void initState() {
    controller.servicePlanCurrentPage = 1;
    controller.servicePlanTabController  = TabController(length: _tabs.length, vsync: this);
    controller.tabBaritems =  List<TabBarItemModel>.generate(_tabs.length, (index){
      PageStorageKey pagekey = PageStorageKey('${_tabs[index]}: ${Random().nextInt(10000)}');
      TabBarItemModel tabbarmodal = (
      pageStorageKey: pagekey,
      totalCount: 1,
      tabBarListData: [],
      tabliistScrollController: ScrollController(),
      listCurrentpage:  1.obs,
      isTabLoading: true,
      type: _tabs[index],
      nonFilterTabBarListData: []
      );
      return  tabbarmodal;
    });



    controller.servicePlanTabController.addListener(() {
      if (controller.servicePlanTabController.index != _previousIndex) {
        if(servicePlanScrollController.hasClients) {
          servicePlanScrollController.jumpTo(0);
        }
        controller.servicePlanCurrentPage = 1;
        controller.servicePlanTotalCount = 0;
        isShowLoader = false;
        controller.isServicePlanLoading.value= true;
        var currentTabItem = controller.tabBaritems[controller.servicePlanTabController.index];

        if(currentTabItem.tabBarListData.isEmpty) {
          controller.tabBaritems[controller.servicePlanTabController.index]  =  currentTabItem.copyWith(isTabLoading: true,);
          controller.getServicePlans(index: controller.servicePlanTabController.index);
        }else{
          controller.tabBaritems[controller.servicePlanTabController.index] =currentTabItem.copyWith(isTabLoading: false,);
          controller.isServicePlanLoading.refresh();
        }
        _previousIndex = controller.servicePlanTabController.index;
      }
    });
    servicePlanScrollController.addListener(() {
      if (servicePlanScrollController.position.pixels == servicePlanScrollController.position.maxScrollExtent) {
        if(!(controller.servicePlanList.length == controller.servicePlanTotalCount)) {
          controller.servicePlanCurrentPage++;
          controller.getServicePlans(index: controller.servicePlanTabController.index);
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.isServicePlanLoading.value = true;
      controller.getServicePlans(index: controller.servicePlanTabController.index);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch(overALLThemeType) {
      case 1:
        showMoreIcon = Assets.theme1More;
        servicePlanCardBorderRadius = 6;
        showMorePadding = 12;
        moreIconColor = appColors.colorCommonLinkColor;
        break;
      case 2:
        showMoreIcon = Assets.theme2More;
        showMorePadding = 12;
        moreIconColor = appColors.colorCommonLinkColor;
        break;
      case 3:
        servicePlanCardBorderRadius = 24;
        showMoreIcon = Assets.theme3More;
        moreIconColor = null;
        showMorePadding = 7;
        break;
      default:
        servicePlanCardBorderRadius = 12;
        showMorePadding = 10;
        showMoreIcon = Assets.drawableViewdetailShareMore;
        moreIconColor = appColors.colorCommonLinkColor;
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
        themeType: overALLThemeType,
          onTap: () {
            profileController.isShowMoreOnServicePlan = true;
            Get.back();
          },
      ),
      body: showBodyContentWidget(),
      action: profileController.isShowMoreOnServicePlan
          ? overALLThemeType == 3
              ? CustomContainer(
                  height: 40,
                  width: 40,
                  onTap: () {
                    CustomPopupMenu(
                        controller: controller,
                        isShowDashDivider: false,
                        PopupMenuItems: [
                          {
                            "text": label_service_plan_history.tr,
                            "ontap": () {
                              profileController.isShowMoreOnServicePlan = false;
                              controller.profileNavigator?.navigateScreen(
                                  ProfileScreen.servicePlanHistory);
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
                          color: appColors.myTripsBGColor, width: 1)),
                  body: showMoreIcon.toSVG(),
                ).toPad(end: AppDimen.startMargin)
              : CustomContainer(
                  height: 40,
                  width: 40,
                  onTap: () {
                    CustomPopupMenu(
                        controller: controller,
                        isShowDashDivider: false,
                        PopupMenuItems: [
                          {
                            "text": label_service_plan_history.tr,
                            "ontap": () {
                              profileController.isShowMoreOnServicePlan = false;
                              controller.profileNavigator?.navigateScreen(
                                  ProfileScreen.servicePlanHistory);
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
                  body: showMoreIcon.toSVG(colour: moreIconColor),
                ).toPad(end: AppDimen.startMargin)
          : 0.toHeight(),
    );
  }

  GetBuilder<ServicePlanController> showBodyContentWidget() {
    return GetBuilder<ServicePlanController>(
        builder: (newController) {
          return [
            CustomText(
              text: label_service_plan.tr,
              size: AppDimen.textSize_26,
              fontWeight: AppFont.bold,
            ).toPad(horizontal: AppDimen.startMargin, bottom: 10),
        toTabBarView(
          tabs: _tabs,
          tabBarWidgets: List<Widget>.generate(
              controller.tabBaritems.length,
              (index) => Obx(() => showTabBarWidgets(
                      isLoading: controller.isServicePlanLoading.value ||
                          (index != controller.servicePlanTabController.index),
                      index: index)
                  .toShimmer(controller: controller))),
          tabController: controller.servicePlanTabController,
          isDynamicWidth: true,
        ).toStretch()
      ].toColumn();
        }
    );
  }

  Widget showTabBarWidgets({required bool isLoading, required int index}) {
    return (!isLoading && controller.servicePlanList.isEmpty)
        ? showEmptyView()
        : Obx(() => [
              toListView(
                  controller: servicePlanScrollController,
                  key: const PageStorageKey<String>('servicePlanList'),
                  itemCount: isLoading ? 3 : controller.servicePlanList.length,
                  itemBuilder: (context, index) {
                    return showServicePlanCard(
                        isLoading: isLoading, index: index);
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
            ].toStack(alignment: Alignment.center));
  }

  Widget showEmptyView() {
    return [
      Assets.drawableServicePlanEmpty.toSVG(),
      10.toHeight(),
      CustomText(
        text: label_no_active_plans.tr,
        size: AppDimen.textSize_22,
        fontWeight: AppFont.semiBold,
      ),
      10.toHeight(),
      CustomText(
        textAlign: TextAlign.center,
        text: label_no_active_plans_desc.tr,
        size: AppDimen.textSize_16,
        fontWeight: AppFont.regular,
      ),
      10.toHeight(),
      CustomText(
        onTap: () {
          profileController.profileNavigator
              ?.navigateScreen(ProfileScreen.staticPage, "5");
        },
        text: label_reach_out_to_us.tr,
        size: AppDimen.textSize_16,
        fontWeight: AppFont.regular,
        color: appColors.secondaryColor,
      ),
      50.toHeight()
    ]
        .toColumn(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center)
        .toPad(horizontal: AppDimen.startMargin);
  }

  Widget showServicePlanCard({required bool isLoading, required int index}) {
    return CustomContainer(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(servicePlanCardBorderRadius),
          color: appColors.myTripsBGColor,
        ),
        body: [
          CustomContainer(
            padding: pad(a: 18),
            width: Get.width,
            decoration: BoxDecoration(
                  border: Border.all(
                      color: appColors.commonDividerColor,
                      width: controller.isDarkMode() ? 0.3 : 1),
                  borderRadius: BorderRadius.circular(servicePlanCardBorderRadius),
              color: appColors.white,
            ),
            body: [
              [
                [
                  if(!isLoading) ...[
                    CustomContainer(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(servicePlanCardBorderRadius),
                        color: appColors.starterPlanCircleColor,
                      ),
                      body: ClipRRect(
                        borderRadius: BorderRadius.circular(servicePlanCardBorderRadius),
                        child: CachedNetworkImage(
                          height: 32,
                          width: 32,
                          fit: BoxFit.cover,
                          imageUrl: servicePlanImagePathSmall + (controller.servicePlanList[index]?.mediaImage ?? ""),
                          placeholder: (context, url) => Assets.drawableStarter.toSVG().toPad(all: 8),
                          errorWidget: (context, url, error) => Assets.drawableStarter.toSVG().toPad(all: 8),
                        ),
                      ),
                    ),
                    10.toWidth(),
                  ],
                  CustomText(
                    text: isLoading ? 20.toGenerateEmptyString() : (controller.servicePlanList[index]?.planName ?? ""),
                    size: AppDimen.textSize_20,
                    isShimmerView: isLoading,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: AppFont.medium,
                  ).toStretch(),
                ].toRow(mainAxisAlignment: MainAxisAlignment.start).toStretch(),
                (!isLoading && (controller.servicePlanList[index]?.purchaseStatus ?? false)) ? CustomBorderContainer(
                  padding: pad(h: 5, w: 10),
                  borderRadius: 100,
                  borderWidth: 1,
                  borderColor: appColors.discountAmountColor,
                  body: CustomText(
                    text: label_active.tr,
                    size: AppDimen.textSize_14,
                    fontWeight: AppFont.medium,
                  ),
                ) : 0.toHeight()
              ].toRow(mainAxisAlignment: MainAxisAlignment.spaceBetween),
              10.toHeight(),
              [
                if(!isLoading) ...[
                  CustomText(
                    text: "${controller.getCurrencySymbol()} ${double.parse(controller.servicePlanList[index]?.price?.currencyConverted(convertedCurrency: controller.servicePlanList[index]?.currency ?? defaultCurrency) ?? "0").toFormattedString()}",
                    size: AppDimen.textSize_24,
                    fontWeight: AppFont.semiBold,
                  ),
                  5.toWidth(),
                  CustomText(
                    text: "/ ${(controller.servicePlanList[index]?.duration ?? "")} Month",
                    size: AppDimen.textSize_16,
                    fontWeight: AppFont.regular,
                    color: appColors.placeholderColor,
                  )
                ]
                else...[
                  CustomText(
                    text: 30.toGenerateEmptyString(),
                    size: AppDimen.textSize_16,
                    isShimmerView: isLoading,
                    fontWeight: AppFont.regular,
                    color: appColors.placeholderColor,
                  )
                ]
              ].toRow(mainAxisAlignment: MainAxisAlignment.start),
              10.toHeight(),
              isLoading
                  ? CustomText(
                      text: 40.toGenerateEmptyString(),
                      size: AppDimen.textSize_14,
                      fontWeight: AppFont.regular,
                      isShimmerView: true,
                    )
                  : ExpandableCollapseText(
                      controller.servicePlanList[index]?.description ?? "",
                      trimLines: 4,
                      size: AppDimen.textSize_14,
                      fontWeight: AppFont.regular,
                    ),
              18.toHeight(),
              (!isLoading && (controller.servicePlanList[index]?.purchaseStatus ?? false)) ?
              CancelButton(
                onTap: () {
                  showAlertDialog(
                    content: Obx(
                      () {
                        appThemeChanged.value;
                        return [
                          CustomText(text: "cancel_plan_heading".tr, fontWeight: AppFont.regular, size: AppDimen.textSize_14,),
                          10.toHeight(),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "${"label_plan_name".tr} ",
                                  style: TextStyle(
                                    fontFamily: AppFont.font,
                                    fontWeight: AppFont.semiBold,
                                    fontSize: AppDimen.textSize_14,
                                    color: appColors.customTextColor
                                  )
                                ),
                                TextSpan(
                                  text: controller.servicePlanList[index]?.planName,
                                  style: TextStyle(
                                    fontFamily: AppFont.font,
                                    fontWeight: AppFont.regular,
                                    fontSize: AppDimen.textSize_14,
                                    color: appColors.customTextColor
                                  )
                                ),
                              ]
                            ),
                          ),
                          10.toHeight(),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "${"label_price".tr} ",
                                  style: TextStyle(
                                    fontFamily: AppFont.font,
                                    fontWeight: AppFont.semiBold,
                                    fontSize: AppDimen.textSize_14,
                                    color: appColors.customTextColor
                                  )
                                ),
                                TextSpan(
                                  text: "${controller.getCurrencySymbol()}${double.parse(controller.servicePlanList[index]?.price?.currencyConverted(convertedCurrency: controller.servicePlanList[index]?.currency ?? defaultCurrency) ?? "0").toFormattedString()}/Month",
                                  style: TextStyle(
                                    fontFamily: AppFont.font,
                                    fontWeight: AppFont.regular,
                                    fontSize: AppDimen.textSize_14,
                                    color: appColors.customTextColor
                                  )
                                ),
                              ]
                            ),
                          ),
                          10.toHeight(),
                          CustomText(text: "cancel_plan_desc".tr, fontWeight: AppFont.regular, size: AppDimen.textSize_14,),
                          10.toHeight(),
                          CustomText(text: '${"what_happens_next".tr}', fontWeight: AppFont.semiBold, size: AppDimen.textSize_14,),
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
                        ].toColumn();
                      }
                    ),
                    onOkPressed: () {
                      Get.back();
                      controller.cancelPurchasePlan(id: controller.servicePlanList[index]?.PurchaseData?.id).then((value) {
                        controller.servicePlanCurrentPage = 1;
                        controller.getServicePlans(index: controller.servicePlanTabController.index);
                      });
                    },
                    okButtonContent: label_confirm.tr,
                    cancelButtonContent: "label_close".tr.toUpperLowerCase(),
                    title: "label_cancel_plan".tr.toUpperLowerCase(),
                    appLayout: AppLayout.themeType,
                  );
                },
                color: appColors.primaryColor,
                height: 50,
                buttonText: label_cancel.tr.toUpperLowerCase()
              ): !isLoading ? PrimaryButton(
                onTap: () {
                  bool hasActivePlan = controller.servicePlanList.any((plan) => plan?.purchaseStatus == true);
                  if (hasActivePlan) {
                    showAlertDialog(
                      title: "change_plan".tr,
                      content: [
                        CustomText(
                          text: "confirm_switch_plan".tr,
                          fontWeight: AppFont.medium,
                          size: AppDimen.textSize_16,
                        ),
                        10.toHeight(),
                        CustomText(
                          text: "plan_switch_warning".tr,
                          fontWeight: AppFont.regular,
                          size: AppDimen.textSize_14,
                        ),
                        10.toHeight(),
                        CustomText(
                          text: 'what_happens_next'.tr,
                          fontWeight: AppFont.semiBold,
                          size: AppDimen.textSize_14,
                        ),
                        5.toHeight(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(text: "• "),
                            Expanded(
                              child: CustomText(
                                text: "immediate_change".tr,
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
                                text: "new_plan_starts".tr,
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
                                text: "one_time_payment".tr,
                                fontWeight: AppFont.regular,
                                size: AppDimen.textSize_14,
                              ),
                            ),
                          ],
                        ),
                      ].toColumn(),
                      onOkPressed: () {
                        Get.back();
                        if (Get.isRegistered<ConfirmAndPayPageController>()) {
                          ConfirmAndPayPageController confirmAndPayPageController = Get.find();
                          confirmAndPayPageController.clearBookingData();
                        }
                        controller.profileNavigator?.navigateScreen(ProfileScreen.reviewPayServicePlan, {
                          "index": index,
                          "userType": controller.servicePlanTabController.index == 0 ? label_renter_title_word.tr : label_owner.tr
                        })?.then((_) {
                          controller.servicePlanCurrentPage = 1;
                          controller.getServicePlans(index: controller.servicePlanTabController.index);
                        });
                      },
                      okButtonContent: "label_next".tr,
                      cancelButtonContent: label_cancel.tr,
                      appLayout: AppLayout.themeType,
                    );
                  } else {
                    controller.profileNavigator?.navigateScreen(ProfileScreen.reviewPayServicePlan, {
                      "index": index,
                      "userType": controller.servicePlanTabController.index == 0 ? label_renter_title_word.tr : label_owner.tr
                    });
                  }
                },
                shadowOpacity: 0.0,
                buttonText: label_select_plan.tr,
              ) : 0.toHeight()
            ].toColumn(crossAxisAlignment: CrossAxisAlignment.start),
          ),
          [
            CustomText(
              text: '${label_benefits.tr}:',
              size: AppDimen.textSize_18,
              isShimmerView: isLoading,
              fontWeight: AppFont.medium,
            ),
            ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                getBenefitsWidget(isLoading: isLoading, description: isLoading ? 20.toGenerateEmptyString() : "${(controller.servicePlanList[index]?.serviceFee?.toInt() ?? "")}% ${label_service_fee.tr}"),
                (!isLoading && (controller.servicePlanList[index]?.aiFeaturesStatus ?? false)) ? getBenefitsWidget(isLoading: isLoading, description: label_ai_features.tr) : 0.toHeight(),
              ],
            )
          ].toColumn().toPad(all: 18)
        ].toColumn()
    ).toPad(horizontal: AppDimen.startMargin, top: 18);
  }

  Widget getBenefitsWidget({required String description, required bool isLoading}) {
    return [
      if(!isLoading) ...[
        Assets.drawableBenefits.toSVG(),
        5.toWidth()
      ],
      CustomText(
        text: isLoading ? 30.toGenerateEmptyString() : description,
        size: AppDimen.textSize_14,
        isShimmerView: isLoading,
        fontWeight: AppFont.regular,
      )
    ].toRow(mainAxisAlignment: MainAxisAlignment.start).toPad(top: 10);
  }
}