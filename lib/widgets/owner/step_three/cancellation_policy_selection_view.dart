import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/owner/step_three/step_three_controller.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/owner/list_item_selection_widget.dart';

class CancellationPolicySelectionView extends GetView {
  @override
  StepThreeController controller;

  CancellationPolicySelectionView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return [
      ListItemSelectionWidget(
          controller: controller,
          title:
              '${label_when_can_guests_check_in.tr}${label_question_symbol.tr}',
          listItems: controller.checkInTimeList,
          selectedValue: controller.selectedCheckInTime.value,
          onItemSelected: (value) {
            controller.selectedCheckOutTime = null;
            controller.selectedCheckInTime.value = value.itemValue;
          }),
      Obx(() {
        List<dynamic> templist = [];
        if (controller.selectedCheckInTime.value != 'Flexible') {
          controller.checkOutTimeList?.forEach((element) {
            if (element?.itemValue == 'Flexible') {
              templist.add(element);
            }
            if (element?.itemValue != 'Flexible' &&
                int.parse(element?.itemValue ?? '0') >
                    int.parse(controller.selectedCheckInTime.value ?? '0')) {
              templist.add(element);
            }
          });
        }
        debugPrint(
            'templist: $templist--${controller.selectedCheckInTime.value}');
        return ListItemSelectionWidget(
            controller: controller,
            listItems:
                templist.isNotEmpty ? templist : controller.checkOutTimeList,
            selectedValue: controller.selectedCheckOutTime,
            onItemSelected: (value) {
              controller.selectedCheckOutTime = value.itemValue;
            });
      }),
      Obx(
        () => ListItemSelectionWidget(
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
      })
    ].toScroll();
  }
}