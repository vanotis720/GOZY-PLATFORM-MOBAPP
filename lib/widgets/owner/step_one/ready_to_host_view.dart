import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/owner/step_one/step_one_controller.dart';
import 'package:gozy/widgets/common/custom_bottomsheet/custom_draggable_bottomsheet.dart';
import 'package:gozy/widgets/common/custom_bottomsheet/custom_getx_bottomsheet.dart';
import 'package:gozy/widgets/common/custom_textfield/custom_prefix_textfield.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/bottom_sheet/bottom_sheet_refresh_controller.dart';

import '../list_item_selection_widget.dart';



 class ReadyToHostView extends GetView{
 @override
  final StepOneController controller;
 @override
  final Key key;
  ReadyToHostView({required this.key,
    required this.controller,
  }) : super(key: key);

  final BottomSheetController _bottomSheetController = Get.find();
  dynamic _selectedMakeModel;
  dynamic _selectedModelModel;

  @override
  Widget build(BuildContext context) {
    debugPrint('step1rebuild ReadyToHostView: $key ');
    return
      [
        Obx(() => ListItemSelectionWidget(
          controller: controller,
          isShowTitleOnBottomSheet: true,
          bottomSheetBorderRadius: overALLAppLayoutModel?.borderRadius,
          title: label_car_type.tr,
          listItems: controller.carTypes,
          selectedId:controller.selectedCarType.value,
          onItemSelected: (value){
            controller.selectedCarType.value = value.id;
          }
        )),
        _buildMakeField(),
        _buildModelField(),
        Obx(() => ListItemSelectionWidget(
          isShowTitleOnBottomSheet: true,
          bottomSheetBorderRadius: overALLAppLayoutModel?.borderRadius,
          controller: controller,
          title: label_year.tr,
          listItems: controller.year,
          selectedId:controller.selectedYear.value,
          onItemSelected: (value){
            controller.selectedYear.value = value.id;
          }
        )),
        Obx(() => ListItemSelectionWidget(
          isShowTitleOnBottomSheet: true,
          bottomSheetBorderRadius: overALLAppLayoutModel?.borderRadius,
          controller: controller,
          title:label_transmission.tr,
          listItems: controller.transmission,
          selectedId:controller.selectedTransmission.value,
          onItemSelected: (value){
            controller.selectedTransmission.value = value.id;
          }
        )),
        Obx(() => ListItemSelectionWidget(
          isShowTitleOnBottomSheet: true,
          bottomSheetBorderRadius: overALLAppLayoutModel?.borderRadius,
          controller: controller,
          title: label_odometer.tr,
          listItems: controller.odometer,
          selectedId:controller.selectedOdometerType.value,
          onItemSelected: (value){
            controller.selectedOdometerType.value = value.id;
          }
        )),
        32.toHeight(),
    ].toScroll();
  }

  Widget _buildMakeField() {
    return Obx(() {
      String makeDisplayText = label_choose_make_type.tr;
      if (controller.selectedMakeType.value != 0 && controller.makeType.isNotEmpty) {
        final matchedMake = controller.makeType.firstWhereOrNull(
          (item) => item.id == controller.selectedMakeType.value,
        );
        if (matchedMake != null) {
          String name = controller.getLocalizedItemName(matchedMake);
          makeDisplayText = name.isNotEmpty ? name : label_choose_make_type.tr;
        }
      }

      return CustomPrefixTextField(
        title: label_make.tr,
        hintText: '',
        controller: TextEditingController(text: makeDisplayText),
        enabled: false,
        maxLines: 1,
        suffixIcon: Assets.drawableFilterCalendarArrow,
        suffixIconQuarterTurns: 3,
        onTap: () {
          if(Get.isSnackbarOpen) {
            Get.closeAllSnackbars();
          }
          _onMakeTap();
        },
      ).toPad(top: AppDimen.startMargin);
    });
  }

  void _onMakeTap() {
    controller.selectedType = "make";
    var oldMakeData = controller.makeType;
    if (controller.oldMakeFilteredItems.isNotEmpty) {
      controller.makeType = controller.oldMakeFilteredItems['items'] ?? [];
      controller.makeCurrentPage.value = controller.oldMakeFilteredItems['page'] ?? 1;
      controller.makeItemsCount = controller.oldMakeFilteredItems['count'] ?? 0;
      controller.oldMakeFilteredItems.clear();
      controller.makeSearchEditController.clear();
    }

    controller.isLinearLoading.value = false;
    controller.makeSearchBarStatus.value = 0;
    _bottomSheetController.change(rxVariable: _bottomSheetController.isUpdateItemList, value: false);

    GetXBottomSheet(
      sheetCloseListener: () {
        controller.makeType = oldMakeData;
      },
      borderRadius: overALLAppLayoutModel?.borderRadius,
      bottomSheetWidget: getDraggableSheetWidget(
        controller: controller,
        title: label_choose_make_type.tr,
        getListItemsFunction: () => controller.makeType,
        currentPage: controller.makeCurrentPage,
        overALLCount: controller.makeItemsCount,
        paginationFunction: controller.getFilterPaginationData,
        isLinearLoading: controller.isLinearLoading,
        selectedModel: _selectedMakeModel,
        selectedId: controller.selectedMakeType.value != 0 ? controller.selectedMakeType.value : null,
        onItemSelected: (value) {
          controller.selectedMakeType.value = value.id;
          _selectedMakeModel = value;
          controller.selectedModelType.value = 0;
          _selectedModelModel = null;
          controller.model.clear();
          controller.modelCurrentPage.value = 1;
          controller.modelItemsCount = 0;

          // Fetch models for the newly selected make
          controller.selectedType = "model";
          controller.getFilterPaginationData();
        },
        searchEditController: controller.makeSearchEditController,
        searchBarStatus: controller.makeSearchBarStatus,
        isShowCircleTick: true,
        borderRadius: overALLAppLayoutModel?.borderRadius,
      ),
    );
  }

  Widget _buildModelField() {
    return Obx(() {
      // Find the selected model name
      String modelDisplayText = label_choose_model.tr;
      if (controller.selectedModelType.value != 0 && controller.model.isNotEmpty) {
        final matchedModel = controller.model.firstWhereOrNull(
          (item) => item.id == controller.selectedModelType.value,
        );
        if (matchedModel != null) {
          String name = controller.getLocalizedItemName(matchedModel);
          modelDisplayText = name.isNotEmpty ? name : label_choose_model.tr;
        }
      }

      return GestureDetector(
        onTap: controller.selectedMakeType.value == 0 ? () {
          controller.showSnackBar(label_please_choose_make.tr);
        } : null,
        child: AbsorbPointer(
          absorbing: controller.selectedMakeType.value == 0,
          child: CustomPrefixTextField(
            title: '${label_model.tr}',
            hintText: '',
            controller: TextEditingController(text: modelDisplayText),
            enabled: false,
            maxLines: 1,
            suffixIcon: Assets.drawableFilterCalendarArrow,
            suffixIconQuarterTurns: 3,
            onTap: () {
              if(Get.isSnackbarOpen) {
                Get.closeAllSnackbars();
              }
              _onModelTap();
            },
          ).toPad(top: AppDimen.startMargin),
        ),
      );
    });
  }

  void _onModelTap() {
    controller.selectedType = "model";
    var oldModelData = controller.model;
    // Restore old items if available
    if (controller.oldModelFilteredItems.isNotEmpty) {
      controller.model = controller.oldModelFilteredItems['items'] ?? [];
      controller.modelCurrentPage.value = controller.oldModelFilteredItems['page'] ?? 1;
      controller.modelItemsCount = controller.oldModelFilteredItems['count'] ?? 0;
      controller.oldModelFilteredItems.clear();
      controller.modelSearchEditController.clear();
    }

    controller.isLinearLoading.value = false;
    controller.modelSearchBarStatus.value = 0;
    _bottomSheetController.change(rxVariable: _bottomSheetController.isUpdateItemList, value: false);

    GetXBottomSheet(
      sheetCloseListener: () {
        controller.model = oldModelData;
      },
      borderRadius: overALLAppLayoutModel?.borderRadius,
      bottomSheetWidget: getDraggableSheetWidget(
        controller: controller,
        title: label_choose_model.tr,
        getListItemsFunction: () => controller.model,
        currentPage: controller.modelCurrentPage,
        overALLCount: controller.modelItemsCount,
        paginationFunction: controller.getFilterPaginationData,
        isLinearLoading: controller.isLinearLoading,
        selectedModel: _selectedModelModel,
        selectedId: controller.selectedModelType.value != 0 ? controller.selectedModelType.value : null,
        onItemSelected: (value) {
          controller.selectedModelType.value = value.id;
          _selectedModelModel = value;
        },
        searchEditController: controller.modelSearchEditController,
        searchBarStatus: controller.modelSearchBarStatus,
        isShowCircleTick: true,
        showNoResultFound: true,
        borderRadius: overALLAppLayoutModel?.borderRadius,
      ),
    );
  }
}