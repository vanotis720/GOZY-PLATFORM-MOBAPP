import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/resources/app_colors.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_text.dart';

import '../../../../generated/assets.dart';
import '../../../../graphql/getPurchaseServicePlan/__generated__/getPurchaseServicePlan.data.gql.dart';
import '../../../../widgets/common/custom_container/custom_container.dart';
import '../../custom_scaffold.dart';
import 'service_plan_controller.dart';

class Receipt extends StatefulWidget {
  const Receipt({super.key});

  @override
  State<Receipt> createState() => _ReceiptState();
}

class _ReceiptState extends State<Receipt> {
  ServicePlanController controller = Get.find();
  double servicePlanCardBorderRadius = 0;
  GgetPurchaseServicePlanData_getPurchaseServicePlan_result? get getPurchaseServicePlanData =>
      controller.purchaseServicePlanData.value;
  var isLoading=false.obs;

  @override
  void initState() {
    isShowLoader = true;
    controller.purchasePlanId = Get.arguments["id"];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isLoading.value = true;
      if (controller.purchasePlanId != 0) {
        controller.createPurchasePlan().then((value) {
          print('test9${controller.isLoading.value}');
            isLoading.value = false;
            controller.isLoading.value=false;
        });
      } else {
        Get.back();
      }
    });
    super.initState();
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
        isShowAppBar: true,
        backIconWidget: getBackIconWidget(iconColor: appColors.black),
        controller: controller,
        isShowBGOnLoader: true,
        loader: LottieLoaders.three_dots_loader,
        body: Obx(() => isLoading.value
            ? Stack(children: [
                const SizedBox.shrink(),
                  showCenterLoading(
                    controller: controller,
                    loader: LottieLoaders.three_dots_loader,
                  ),
              ])
            : showBodyContent().toPad(horizontal: AppDimen.startMargin)));
  }

  Widget showBodyContent() {
    return [
      [
        CustomText(
          text: "${sheet_title_customer_receipt.tr}:",
          fontWeight: AppFont.bold,
          size: AppDimen.textSize_22,
        ),
        CustomText(
          text: " #${getPurchaseServicePlanData?.id ?? ""}",
          fontWeight: AppFont.bold,
          size: AppDimen.textSize_22,
        )
      ].toRow(mainAxisAlignment: MainAxisAlignment.start),
      6.toHeight(),
      CustomText(
        text:
            getDateFormat(dateFormat: servicePlanDateFormat, milliSec: getPurchaseServicePlanData?.startDate)
                .$1,
        fontWeight: AppFont.regular,
        size: AppDimen.textSize_14,
      ),
      filterDivider.toPad(vertical: 15),
      [
        CustomText(
          text: label_purchased_by.tr,
          fontWeight: AppFont.medium,
          size: AppDimen.textSize_18,
        ),
        Container(
          padding: pad(w: 12, h: 4),
          decoration: BoxDecoration(
              color: appColors.reviewPayBgColor,
              borderRadius: BorderRadius.circular(servicePlanCardBorderRadius),
              border: Border.all(color: appColors.customBorderColor)),
          child: CustomText(
            text: getPurchaseServicePlanData?.userType == "renter"
                ? label_renter_title_word.tr
                : label_owner.tr,
            fontWeight: AppFont.medium,
            size: AppDimen.textSize_14,
            color: AppColors.staticblack,
          ),
        )
      ].toRow(mainAxisAlignment: MainAxisAlignment.spaceBetween),
      6.toHeight(),
      CustomText(
        text: getPurchaseServicePlanData?.PurchaserData?.firstName ?? "",
        fontWeight: AppFont.regular,
        size: AppDimen.textSize_14,
      ),
      filterDivider.toPad(vertical: 15),
      CustomText(
        text: getPurchaseServicePlanData?.servicePlanName ?? "",
        fontWeight: AppFont.medium,
        size: AppDimen.textSize_18,
      ),
      6.toHeight(),
      CustomText(
        text: getPurchaseServicePlanData?.serviceDescription ?? "",
        fontWeight: AppFont.regular,
        size: AppDimen.textSize_14,
      ),
      filterDivider.toPad(vertical: 15),
      CustomText(
        text: label_benefits.tr,
        size: AppDimen.textSize_18,
        fontWeight: AppFont.medium,
      ),
      5.toHeight(),
      ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: [
          getBenefitsWidget(
              description: "${(getPurchaseServicePlanData?.serviceFee?.toInt() ?? "")}% ${label_service_fee.tr}"),
          (getPurchaseServicePlanData?.serviceAIFeature ?? false)
              ? getBenefitsWidget(description: label_ai_features.tr)
              : 0.toHeight(),
          10.toHeight()
        ],
      ),
      filterDivider.toPad(bottom: 15),
      CustomText(
        text: billing.tr,
        size: AppDimen.textSize_18,
        fontWeight: AppFont.medium,
      ),
      12.toHeight(),
      CustomContainer(
        width: deviceWidth,
        padding: pad(
            w: (overALLThemeType == 3)
                ? 12
                : (overALLThemeType == 2)
                    ? 0
                    : 10,
            h: (overALLThemeType == 3)
                ? 12
                : (overALLThemeType == 2)
                    ? 0
                    : 10),
        decoration: overALLThemeType == 2 ? null : BoxDecoration(
          color: (overALLThemeType == 3) ? appColors.myTripsBGColor : appColors.white,
          borderRadius: BorderRadius.circular(servicePlanCardBorderRadius),
          border: Border.all(color: appColors.customBorderColor),
        ),
        body: ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [
            [
              CustomText(
                text: label_price.tr,
                size: AppDimen.textSize_14,
                fontWeight: AppFont.regular,
              ),
              CustomText(
                text:
                    "${controller.getCurrencySymbol()}${double.parse(getPurchaseServicePlanData?.price?.currencyConverted(convertedCurrency: getPurchaseServicePlanData?.currency ?? defaultCurrency) ?? "0").toFormattedString()}",
                size: AppDimen.textSize_14,
                fontWeight: AppFont.regular,
              )
            ].toRow(mainAxisAlignment: MainAxisAlignment.spaceBetween).toPad(bottom: 10),
            [
              CustomText(
                text: label_receipt_title_duration.tr,
                size: AppDimen.textSize_14,
                fontWeight: AppFont.regular,
              ),
              CustomText(
                text: "${getPurchaseServicePlanData?.duration ?? ""} ${label_month.tr}",
                size: AppDimen.textSize_14,
                fontWeight: AppFont.regular,
              )
            ].toRow(mainAxisAlignment: MainAxisAlignment.spaceBetween).toPad(bottom: 10),
            [
              CustomText(
                text: label_calendar_start_date.tr,
                size: AppDimen.textSize_14,
                fontWeight: AppFont.regular,
              ),
              CustomText(
                text: getDateFormat(
                        dateFormat: commonDateFormat, milliSec: getPurchaseServicePlanData?.startDate ?? "")
                    .$1,
                size: AppDimen.textSize_14,
                fontWeight: AppFont.regular,
              )
            ].toRow(mainAxisAlignment: MainAxisAlignment.spaceBetween).toPad(bottom: 10),
            [
              CustomText(
                text: label_calendar_end_date.tr,
                size: AppDimen.textSize_14,
                fontWeight: AppFont.regular,
              ),
              CustomText(
                text: getDateFormat(
                        dateFormat: commonDateFormat, milliSec: getPurchaseServicePlanData?.endDate ?? "")
                    .$1,
                size: AppDimen.textSize_14,
                fontWeight: AppFont.regular,
              )
            ].toRow(mainAxisAlignment: MainAxisAlignment.spaceBetween)
          ],
        ),
      ),
      filterDivider.toPad(vertical: 15),
      CustomText(
        text: label_payment.tr,
        size: AppDimen.textSize_18,
        fontWeight: AppFont.medium,
      ),
      12.toHeight(),
      CustomText(
        text: label_paid.tr,
        size: AppDimen.textSize_14,
        fontWeight: AppFont.regular,
      ),
      6.toHeight(),
      [
        CustomText(
          text: getDateFormat(
                  dateFormat: servicePlanDateFormat, milliSec: getPurchaseServicePlanData?.startDate)
              .$1,
          size: AppDimen.textSize_14,
          fontWeight: AppFont.regular,
        ),
        CustomText(
          text:
              "${controller.getCurrencySymbol()}${double.parse(getPurchaseServicePlanData?.price?.currencyConverted(convertedCurrency: getPurchaseServicePlanData?.currency ?? defaultCurrency) ?? "0").toFormattedString()}",
          size: AppDimen.textSize_14,
          fontWeight: AppFont.regular,
        )
      ].toRow(mainAxisAlignment: MainAxisAlignment.spaceBetween),
      filterDivider.toPad(vertical: 15),
      CustomText(
        text: label_doesnt_auto_renew_content.tr,
        size: AppDimen.textSize_18,
        fontWeight: AppFont.medium,
      ),
      12.toHeight(),
      CustomText(
        text: label_service_plan_description.tr,
        size: AppDimen.textSize_14,
        fontWeight: AppFont.regular,
      ),
    12.toHeight(),
  ].toColumn().toScroll();
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
    ].toRow(mainAxisAlignment: MainAxisAlignment.start).toPad(top: 10);
  }
}