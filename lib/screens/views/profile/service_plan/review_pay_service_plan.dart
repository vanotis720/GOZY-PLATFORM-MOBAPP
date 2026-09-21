import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_colors.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/widgets/common/custom_button/primary_button.dart';
import 'package:gozy/widgets/common/custom_container/custom_bottom_item_shadow_container.dart';
import 'package:gozy/widgets/common/custom_network_image/custom_cached_network_image.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_text.dart';
import 'package:gozy/widgets/common/custom_text/expandable_collapse_text.dart';
import 'package:gozy/widgets/common/custom_painter/custom_tooltip_painter.dart';
import 'package:gozy/widgets/custom_tool_tip.dart';
import 'package:gozy/widgets/rect_getter.dart';

import 'package:gozy/constant.dart';
import 'package:gozy/widgets/common/custom_container/custom_container.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/profile/profile_navigator.dart';
import 'package:gozy/screens/views/profile/service_plan/service_plan_controller.dart';

class ReviewPayServicePlan extends StatefulWidget {
  const ReviewPayServicePlan({super.key});

  @override
  State<ReviewPayServicePlan> createState() => _ReviewPayServicePlanState();
}

class _ReviewPayServicePlanState extends State<ReviewPayServicePlan> {
  ServicePlanController controller = Get.find();
  int index = 0;
  String userType = "";
  double servicePlanCardBorderRadius = 0;
  Widget _placeholderWidget = Assets.drawableStarter.toSVG().toPad(all: 8);
  final _priceTooltipKey = RectGetter.createGlobalKey();
  final _benefitsTooltipKey = RectGetter.createGlobalKey();

  @override
  void initState() {
    hideGoogleMap = true;
    index = Get.arguments["index"];
    userType = Get.arguments["userType"];

    super.initState();
  }

  @override
  void dispose() {
    hideGoogleMap = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (overALLThemeType) {
      case 1:
        servicePlanCardBorderRadius = 6;
        break;
      case 2:
        break;
      case 3:
        servicePlanCardBorderRadius = 24;
        break;
      default:
        servicePlanCardBorderRadius = 12;
        break;
    }
    return CustomScaffold(
      controller: controller,
      isShowAppBar: true,
      backIconWidget: getBackIconWidget(
          backIcon: Assets.drawableSignupClose, themeType: overALLThemeType),
      body: showContentData(),
    );
  }

  Widget showContentData() {
    return [
      [
        CustomText(
          text: label_review_and_pay.tr,
          size: AppDimen.textSize_22,
          fontWeight: AppFont.bold,
        ).toPad(horizontal: overALLThemeType == 4 ? AppDimen.startMargin : 0),
        15.toHeight().toPad(horizontal: overALLThemeType == 4 ? AppDimen.startMargin : 0),
        [
          CustomContainer(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(servicePlanCardBorderRadius),
                color: appColors.starterPlanCircleColor,
              ),
              body: CustomCachedNetworkImage(
                imageUrl: (servicePlanImagePathSmall + (controller.servicePlanList[index]?.mediaImage ?? "")),
                fit: BoxFit.cover,
                borderRadius: servicePlanCardBorderRadius,
                height: 32,
                width: 32,
                placeholder: _placeholderWidget,
              )),
          10.toWidth(),
          CustomText(
            text: controller.servicePlanList[index]?.planName ?? "",
            size: AppDimen.textSize_20,
            fontWeight: AppFont.medium,
            overflow: TextOverflow.ellipsis,
          ).toStretch(),
          10.toWidth(),
          CustomContainer(
            padding: pad(h: 2, w: 8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(servicePlanCardBorderRadius),
                border: Border.all(color: appColors.customBorderColor),
                color: appColors.reviewPayBgColor),
            body: CustomText(
              text: userType,
              size: AppDimen.textSize_14,
              color: AppColors.staticblack,
              fontWeight: AppFont.medium,
            ),
          )
        ].toRow(mainAxisAlignment: MainAxisAlignment.start).toPad(horizontal: overALLThemeType == 4 ? AppDimen.startMargin : 0),
        filterDivider.toPad(top: 20, bottom: 10),
        [
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
          ),
          _getToolTipWidget(
            toolTipContent: label_service_plan_price_tooltip_content.tr,
            globalKey: _priceTooltipKey,
            toolTipColor: appColors.secondaryColor,
          ).toPad(start: 2),
        ].toRow(mainAxisAlignment: MainAxisAlignment.start).toPad(horizontal: overALLThemeType == 4 ? AppDimen.startMargin : 0),
        5.toHeight(),
        ExpandableCollapseText(
          controller.servicePlanList[index]?.description ?? "",
          trimLines: 4,
          size: AppDimen.textSize_14,
          fontWeight: AppFont.regular,
        ).toPad(horizontal: overALLThemeType == 4 ? AppDimen.startMargin : 0),
        12.toHeight(),
        if (overALLThemeType == 2) filterDivider.toPad(bottom: 8,top: 5),
        CustomContainer(
          width: Get.width,
          padding: pad(a: 10),
          decoration: overALLThemeType == 2
              ? null
              : BoxDecoration(
                  color: overALLThemeType == 4 || overALLThemeType == 1
                      ? null
                      : appColors.myTripsBGColor,
                  borderRadius:
                      BorderRadius.circular(servicePlanCardBorderRadius),
                  border: Border.all(color: appColors.commonDividerColor),
                ),
          body: [
            [
              CustomText(
                text: label_receipt_title_duration.tr,
                size: AppDimen.textSize_14,
                fontWeight: AppFont.regular,
              ),
              CustomText(
                text: "${(controller.servicePlanList[index]?.duration ?? "")} Month",
                size: AppDimen.textSize_14,
                fontWeight: AppFont.regular,
              )
            ].toRow(mainAxisAlignment: MainAxisAlignment.spaceBetween),
            10.toHeight(),
            [
              CustomText(
                text: label_calendar_start_date.tr,
                size: AppDimen.textSize_14,
                fontWeight: AppFont.regular,
              ),
              CustomText(
                text: getDateFormat(
                        dateFormat: commonDateFormat,
                        milliSec: controller.servicePlanList[index]?.servicePlanStartDate ?? "")
                    .$1
                    .toString(),
                size: AppDimen.textSize_14,
                fontWeight: AppFont.regular,
              )
            ].toRow(mainAxisAlignment: MainAxisAlignment.spaceBetween),
            10.toHeight(),
            [
              CustomText(
                text: label_calendar_end_date.tr,
                size: AppDimen.textSize_14,
                fontWeight: AppFont.regular,
              ),
              CustomText(
                text: getDateFormat(
                        dateFormat: commonDateFormat,
                        milliSec: controller.servicePlanList[index]?.servicePlanEndDate ?? "")
                    .$1
                    .toString(),
                size: AppDimen.textSize_14,
                fontWeight: AppFont.regular,
              )
            ].toRow(mainAxisAlignment: MainAxisAlignment.spaceBetween),
          ].toColumn(),
        ).toPad(horizontal: overALLThemeType == 4 ? AppDimen.startMargin : 0),
        filterDivider.toPad(top: overALLThemeType == 2 ? 10 : 20, bottom: 10),
        [
          CustomText(
            text: label_benefits.tr,
            size: AppDimen.textSize_18,
            fontWeight: AppFont.bold,
          ),
          _getToolTipWidget(
            toolTipContent: (controller.servicePlanList[index]?.aiFeaturesStatus ?? false)
                ? label_service_plan_ai_benefits_tooltip_content.tr
                : label_service_plan_benefits_tooltip_content.tr,
            globalKey: _benefitsTooltipKey,
            toolTipColor: appColors.secondaryColor,
          ).toPad(start: 2),
        ].toRow(mainAxisAlignment: MainAxisAlignment.start).toPad(
            horizontal: overALLThemeType == 4 ? AppDimen.startMargin : 0),
        5.toHeight().toPad(horizontal: overALLThemeType == 4 ? AppDimen.startMargin : 0),
        CustomContainer(
          width: Get.width,
          padding: pad(w: 10, h: 10),
          decoration: overALLThemeType == 2
              ? null
              :  BoxDecoration(
            color: overALLThemeType == 4 || overALLThemeType == 1
                ? null
                : appColors.myTripsBGColor,
            borderRadius: BorderRadius.circular(servicePlanCardBorderRadius),
            border: Border.all(color: appColors.commonDividerColor),
          ),
          body: ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              getBenefitsWidget(
                  description:
                      "${(controller.servicePlanList[index]?.serviceFee?.toInt() ?? "")}% ${label_service_fee.tr}"),
              (controller.servicePlanList[index]?.aiFeaturesStatus ?? false)
                  ? getBenefitsWidget(description: label_ai_features.tr).toPad(top: 10)
                  : 0.toHeight(),
            ],
          ),
        ).toPad(horizontal: overALLThemeType == 4 ? AppDimen.startMargin : 0),
        filterDivider.toPad(top: overALLThemeType == 2 ? 10 : 20, bottom: 10),
        [
          CustomText(
            text: label_doesnt_auto_renew_content.tr,
            size: AppDimen.textSize_18,
            fontWeight: AppFont.bold,
          ),
          5.toHeight(),
          CustomText(
            text: label_service_plan_description.tr,
            size: AppDimen.textSize_14,
            fontWeight: AppFont.regular,
          ),
        ].toColumn().toPad(horizontal: overALLThemeType == 4 ? AppDimen.startMargin : 0),
        AppDimen.startMargin.toHeight().toPad(horizontal: overALLThemeType == 4 ? AppDimen.startMargin : 0)
      ].toScroll().toPad(horizontal: overALLThemeType == 4 ? 0 : AppDimen.startMargin).toStretch(),
      CustomBottomItemShadowContainer(
          borderRadiusGeometry: BorderRadiusDirectional.vertical(
              top: Radius.circular(AppDimen.appBorderRadius),
              bottom: Radius.circular(AppDimen.appBorderRadius)),
          body: PrimaryButton(
            buttonText: btn_label_add_payment.tr,
            onTap: () {
              controller.profileNavigator?.navigateScreen(ProfileScreen.paymentType,
                  {"isFrom": "servicePlan", "itemInfo": controller.servicePlanList[index], "userType": userType});
            },
          ).toPad(all: 20))
    ].toColumn();
  }

  Widget getBenefitsWidget({required String description, bool? isLoading}) {
    return [
      if (!(isLoading ?? false)) ...[Assets.drawableBenefits.toSVG(), 5.toWidth()],
      CustomText(
        text: (isLoading ?? false) ? 30.toGenerateEmptyString() : description,
        size: AppDimen.textSize_14,
        isShimmerView: isLoading ?? false,
        fontWeight: AppFont.regular,
      ),
    ].toRow(mainAxisAlignment: MainAxisAlignment.start);
  }

  Widget _getToolTipWidget(
      {required String toolTipContent,
      required GlobalKey<RectGetterState> globalKey,
      required Color toolTipColor}) {
    CustomTooltipPainter customShapePointer = CustomTooltipPainter(
        isItemSelected: true,
        contentBGColor: appColors.tooltipBGColor,
        textColor: appColors.white,
        content: toolTipContent);

    return getToolTipWidget(
      customShapePointer: customShapePointer,
      startMargin: 0,
      controller: controller,
      globalKey: globalKey,
      overlayWidget: Assets.drawableConfirmPaySplPriceTooltip
          .toSVG(size: 13, fit: BoxFit.scaleDown, colour: toolTipColor),
      overlayColorForWidget: AppColors.staticwhite,
    );
  }
}