import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/widgets/common/custom_bottomsheet/custom_draggable_bottomsheet.dart';
import 'package:gozy/widgets/common/custom_bottomsheet/custom_getx_bottomsheet.dart';
import 'package:gozy/widgets/common/custom_container/custom_border_container.dart';
import 'package:gozy/widgets/common/custom_textfield/custom_prefix_textfield.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/common/custom_container/custom_container.dart';
import 'package:gozy/widgets/custom_text.dart';

import '../../../resources/app_font.dart';
import '../../../screens/views/base_controller.dart';
import '../../resources/app_dimen.dart';
import '../../utils/text_editing_controller.dart';

class ListItemSelectionWidget extends GetView {
  @override
  BaseController controller;
  String? title;
  String? hintText;
  List<dynamic>? listItems;
  CustomTextEditingController textEditingController = CustomTextEditingController();

  ValueChanged<dynamic>? onItemSelected;
  int? selectedId;
  double? topMargin;
  String? selectedValue;
  bool isShowTitleOnBottomSheet;
  double? bottomSheetBorderRadius;
  List<Widget>? WidgetsList;
  String? editingcontrollerText;

  bool? toShowIcon;
  bool? toShowTextField;
  double? fieldPadding;
  double? arrowSVGSize;
  TextOverflow? textOverFlow;
  Color? borderColor;
  Color? textColor;
  Color? svgColor;
  bool? isShowCloseIcon;
  RxInt? searchBarStatus;
  GestureTapCallback? searchonSuffixTap;
  CustomTextEditingController? searchEditController;

  ListItemSelectionWidget({
    required this.controller,
    this.title,
    this.hintText,
    this.listItems,
    this.topMargin,
    this.WidgetsList,
    this.isShowTitleOnBottomSheet = false,
    this.bottomSheetBorderRadius,
    this.editingcontrollerText,
    this.selectedId,
    this.selectedValue,
    this.toShowIcon,
    this.toShowTextField,
    this.onItemSelected,
    this.fieldPadding,
    this.textOverFlow,
    this.arrowSVGSize,
    this.borderColor,
    this.textColor,
    this.svgColor,
    this.isShowCloseIcon,
    this.searchBarStatus,
    this.searchonSuffixTap,
  }) : super(key: ValueKey(title));

  @override
  Widget build(BuildContext context) {
    debugPrint("selectedValue--> $selectedValue");
    toShowTextField ??= true;

    if (listItems == null) {
      listItems = [];
    } else if (selectedId == null &&
        selectedValue == null &&
        listItems!.isNotEmpty) {
      textEditingController.text =
          controller.getLocalizedItemName(listItems![0]);
    } else if ((selectedId != null || selectedValue != null) &&
        listItems!.isNotEmpty) {
      int currentIndex = 0;
      if (selectedId != null) {
        print("ListItems--> $listItems");
        currentIndex =
            listItems!.indexWhere((item) => item.id == selectedId) != -1
                ? listItems!.indexWhere((item) => item.id == selectedId)
                : 0;
      } else if (selectedValue != null) {
        debugPrint("selecteditemname: ${listItems![currentIndex].itemName}");
        currentIndex = listItems!
                    .indexWhere((item) => item.itemValue == selectedValue) !=
                -1
            ? listItems!.indexWhere((item) => item.itemValue == selectedValue)
            : 0;
      }
      textEditingController.text =
          controller.getLocalizedItemName(listItems![currentIndex]);
      debugPrint("selecteditemname: ${listItems![currentIndex].itemName}");
    }
    print("ListItemstoShowTextField--> $toShowTextField");
    if (editingcontrollerText != null)
      textEditingController.text = editingcontrollerText!;
    return toShowTextField!
        ? CustomPrefixTextField(
            title: title,
            hintText: hintText ?? '',
            controller: textEditingController,
            enabled: false,
            maxLines: 1,
            suffixIcon: Assets.drawableFilterCalendarArrow,
            suffixIconQuarterTurns: 3,
            onTap: () {
              if (Get.isSnackbarOpen) {
                Get.closeAllSnackbars();
              }
              FocusManager.instance.primaryFocus!.unfocus();
              GetXBottomSheet(
                  bottomSheetWidget: getDraggableSheetWidget(
                    controller: controller,
                    title: isShowTitleOnBottomSheet ? title : null,
                    listItems: listItems,
                    widgetsList: WidgetsList,
                    selectedId: selectedId,
                    selectedValue: selectedValue,
                    toShowIcon: toShowIcon,
                    onItemSelected: onItemSelected,
                    textEditingController: textEditingController,
                    borderRadius: bottomSheetBorderRadius,
                  ),
                  sheetCloseListener: () {
                    FocusManager.instance.primaryFocus!.unfocus();
                  });
            },
          ).toPad(top: topMargin ?? AppDimen.startMargin)
        : CustomBorderContainer(
            padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 12, vertical: 6),
            borderColor: borderColor,
            onTap: () {
              print("SelectedId3-> $selectedId <-> SelectedValue-> $title");
              if (Get.isSnackbarOpen) {
                Get.closeAllSnackbars();
              }
              FocusManager.instance.primaryFocus!.unfocus();
              GetXBottomSheet(
                  bottomSheetWidget: getDraggableSheetWidget(
                      controller: controller,
                      listItems: listItems,
                      title: title,
                      widgetsList: WidgetsList,
                      selectedId: selectedId,
                      selectedValue: selectedValue,
                      toShowIcon: toShowIcon,
                      onItemSelected: onItemSelected,
                      textEditingController: textEditingController,
                      isShowCloseIcon: isShowCloseIcon,
                      searchBarStatus: searchBarStatus,
                      searchEditController: searchEditController),
                  sheetCloseListener: () {
                    FocusManager.instance.primaryFocus!.unfocus();
                  });
            },
            body: [
              CustomContainer(
                constraints:
                    BoxConstraints(minWidth: 50, maxWidth: Get.width / 2),
                body: CustomText(
                  text: textEditingController.text,
                  overflow: TextOverflow.visible,
                  color: textColor,
                  size: AppDimen.textSize_14,
                  fontWeight: AppFont.regular,
                ),
              ),
              Assets.drawableFilterCalendarArrow
                  .toSVG(colour: svgColor, quarterTurns: 3, size: arrowSVGSize)
                  .toPad(start: 5, end: 5)
            ].toRow());
  }
}