import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/owner/step_three/step_three_controller.dart';
import 'package:gozy/widgets/common/custom_container/custom_border_container.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/common/custom_container/custom_container.dart';
import 'package:gozy/widgets/custom_text.dart';

import '../../../resources/app_layout.dart';
import '../../../screens/views/base_controller.dart';
import '../list_item_selection_widget.dart';

class BookingWindowSelectionView extends GetView {
  @override
  StepThreeController controller;

  BookingWindowSelectionView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return [
      Obx(() {
        return ListItemSelectionWidget(
          controller: controller,
          title: label_availability_window.tr,
          listItems: controller.availabilityWindowList,
          selectedValue: controller.selectedAvailabilityWindow.value,
          onItemSelected: (value) {
            controller.selectedAvailabilityWindow.value = value.itemValue;
          },
          bottomSheetBorderRadius: overALLAppLayoutModel?.borderRadius,
        );
      }),
      AppDimen.startMargin.toHeight(),
      CustomText(
        text: label_trip_length.tr,
        size: AppDimen.textSize_18,
        fontWeight: AppFont.medium,
      ),
      (overALLThemeType == 4 ? 12 : 20).toHeight(),
      incrementDecrementWidget(
        textPlural: controller.minTextPlural,
        text: controller.minText,
        startValue: controller.allowedStartMinNights,
        endValue: controller.allowedEndMinNights,
        initialValue: controller.selectedMinNights,
      ),
      if (overALLThemeType == 4) filterDivider,
      10.toHeight(),
      incrementDecrementWidget(
        textPlural: controller.maxTextPlural,
        text: controller.maxText,
        startValue: controller.allowedStartMaxNights,
        endValue: controller.allowedEndMaxNights,
        initialValue: controller.selectedMaxNights,
      ),
      if (overALLThemeType == 4) filterDivider,
      Obx(
        () => ListItemSelectionWidget(
            bottomSheetBorderRadius: overALLAppLayoutModel?.borderRadius,
            controller: controller,
            title: label_cancellation_policy.tr,
            listItems: controller.cancellationPolicyList,
            selectedId: controller.selectedCancellationPolicy.value,
            onItemSelected: (value) {
              controller.selectedCancellationPolicy.value = value.id;
            }),
      ),
      15.toHeight(),
      Obx(() {
        debugPrint('check: ${controller.selectedCancellationPolicy.value}');
        var item = controller.cancellationPolicyList?.firstWhere(
            (finditem) =>
                finditem?.id == controller.selectedCancellationPolicy.value,
            orElse: () => null);
        return (item?.itemValue ?? '').toString().toExplanationTip();
      }),
      25.toHeight(),
    ].toScroll();
  }

  Widget incrementDecrementWidget(
      {required String text,
      String? textPlural,
      required int startValue,
      required int endValue,
      required RxInt initialValue}) {
    if (overALLThemeType == 4) {
      return [
        Obx(() => CustomText(
              text: "${initialValue.value} ${initialValue.value <= 1 ? text : (textPlural ?? text)}",
              size: AppDimen.textSize_16,
            )),
        [
          toOnTap(
              onTap: () {
                if (initialValue.value > startValue) {
                  initialValue.value--;
                }
              },
              child: CustomContainer(
                  height: 50,
                  width: 45,
                  body: Assets.drawableCountDecrement
                      .toSVG(colour: appColors.black)
                      .toPad(vertical: 7, horizontal: 13))),
          VerticalDivider(
              width: 1,
              color: appColors.filterDividerColor,
              indent: 10,
              endIndent: 10),
          toOnTap(
              onTap: () {
                if (initialValue.value < endValue) {
                  initialValue.value++;
                }
              },
              child: CustomContainer(
                  height: 30,
                  width: 50,
                  body: Assets.drawableCountIncrement
                      .toSVG(colour: appColors.black)
                      .toPad(all: 7))),
        ].toRow().toResizeWidget(height: 45)
      ]
          .toRow(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          )
          .toPad(vertical: 2);
    }
    return CustomBorderContainer(
      height: 50,
      padding: const EdgeInsetsDirectional.only(start: 18),
      borderRadius: appLayoutMap[AppLayout.inputType]?.borderRadius,
      body: [
        Obx(() => CustomText(
              text: "${initialValue.value} ${(initialValue.value <= 1) ? text : (textPlural ?? text)}",
              size: AppDimen.textSize_16,
            )),
        [
          VerticalDivider(width: 1.2, color: appColors.customBorderColor),
          toOnTap(
              onTap: () {
                if (initialValue.value > startValue) {
                  initialValue.value--;
                }
              },
              child: CustomContainer(
                  height: 30,
                  width: 50,
                  body: Assets.drawableCountDecrement
                      .toSVG(colour: appColors.black)
                      .toPad(vertical: 7, horizontal: 15))),
          VerticalDivider(width: 1.2, color: appColors.customBorderColor),
          toOnTap(
              onTap: () {
                if (initialValue.value < endValue) {
                  initialValue.value++;
                }
              },
              child: CustomContainer(
                  height: 30,
                  width: 50,
                  body: Assets.drawableCountIncrement
                      .toSVG(colour: appColors.black)
                      .toPad(all: 7))),
        ].toRow().toResizeWidget(height: 50)
      ].toRow(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      ),
    );
  }

  bool setValidation() {
    Map<String, bool> results = {
      error_msg_min_nights_higher_than_max_nights.tr:
          controller.selectedMinNights.value >
              controller.selectedMaxNights.value,
    };
    return results.isValidate(controller: controller);
  }
}