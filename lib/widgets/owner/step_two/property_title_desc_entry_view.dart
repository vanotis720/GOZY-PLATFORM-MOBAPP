import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/binding/property_steps_binding.dart';
import 'package:gozy/screens/views/owner/generate_with_ai_owner/generate_with_ai_listings.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/common/custom_textfield/custom_textfield_area.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_text.dart';
import 'package:gozy/widgets/common/custom_textfield/custom_prefix_textfield.dart';
import 'package:gozy/widgets/common/custom_bottomsheet/custom_getx_bottomsheet.dart';
import 'package:gozy/widgets/common/custom_bottomsheet/custom_draggable_bottomsheet.dart';
import 'package:gozy/widgets/custom_textfield.dart';

import '../../../config/client.dart';
import '../../../constant.dart';
import '../../../generated/assets.dart';
import '../../../resources/app_layout.dart';
import '../../../screens/views/base_controller.dart';
import '../../../screens/views/owner/step_two/step_two_controller.dart';
import '../step_item_model.dart';

class PropertyTitleDescriptionEntryView extends GetView<StepTwoController> {
  final StepTwoController controller;

  const PropertyTitleDescriptionEntryView({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final entries = controller.languageEntries;
      return toListView(
        shrinkWrap: true,
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          final availableLangs = controller.getAvailableLanguages(index);
          return [
            if (index == 0) ...[
              CustomText(
                text: label_step2_add_language_title.tr,
                size: AppDimen.textSize_18,
              ).toPad(top: (overALLThemeType == 3) ? 24 : 12),
              CustomText(
                text: label_step2_add_language.tr,
                color: appColors.secondaryText,
                size: AppDimen.textSize_14,
                fontWeight: AppFont.regular,
              ).toPad(top: 12),
            ],
            CustomPrefixTextField(
              title: appLayoutMap[AppLayout.inputType]?.themeType == 4
                  ? "label_language".tr
                  : '',
              controller: TextEditingController(
                  text: entry.langCode != null && entry.langCode!.isNotEmpty
                      ? allLanguages[entry.langCode!] ?? ''
                      : ''),
              hintText: label_choose_language.tr,
              enabled: false,
              suffixIconQuarterTurns: 3,
              suffixIcon: Assets.drawableFilterCalendarArrow,
              onTap: () {
                controller.hideKeyBoard();
                if(Get.isSnackbarOpen) {
                  Get.closeAllSnackbars();
                }
                GetXBottomSheet(
                    sheetCloseListener: () {
                      FocusManager.instance.primaryFocus!.unfocus();
                    },
                    bottomSheetWidget: getDraggableSheetWidget(
                      title: label_choose_language.tr,
                      onItemSelected: (value) {
                        if (value != null && value.itemValue is String) {
                          entry.langCode = value.itemValue;
                          controller.languageEntries.refresh();
                        }
                      },
                      getListItemsFunction: () {
                        return controller
                            .getAvailableLanguages(index)
                            .map((e) => StepItemModel(
                          itemName: e.value,
                          itemValue: e.key,
                        ))
                            .toList();
                      },
                      isLinearLoading: false.obs,
                      overALLCount: availableLangs.length,
                      controller: controller,
                      selectedValue: entry.langCode,
                    ));
              },
            ).toPad(bottom: 12, top: 12),
            TitleTextField(
              title: appLayoutMap[AppLayout.inputType]?.themeType == 4
                  ? label_add_title.tr
                  : '',
              controller: entry.titleController,
              borderTextfieldPadding:
              appLayoutMap[AppLayout.inputType]?.themeType == 4
                  ? EdgeInsets.zero
                  : null,
              textInputAction: TextInputAction.done,
              hintText: label_add_title.tr,
            ).toPad(bottom: 12),
            appLayoutMap[AppLayout.inputType]?.themeType == 4
                ? CustomTitleText(
              text: title_description.tr.toUpperLowerCase(),
              size: AppDimen.textSize_18,
            ).toPad(bottom: 10)
                : const SizedBox.shrink(),
            CustomTextfieldArea(
              controller: entry.descController,
              hintText: label_property_desc_hint_text.tr,
              minLines: 1,
              maxLines: 8,
              height: appLayoutMap[AppLayout.inputType]?.themeType == 4
                  ? null
                  : 135,
              decoration: appLayoutMap[AppLayout.inputType]?.themeType == 4
                  ? BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: appColors.customBorderColor, width: 0.5),
                ),
              )
                  : null,
              borderTextfieldPadding:
              appLayoutMap[AppLayout.inputType]?.themeType == 4
                  ? pad(bottom: 5)
                  : pad(w: 18, h: 10),
            ).toPad(bottom: 12),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 10,
              children: [
                if (aiTextGeneration &&
                    (aiAccessTitleDescription || ownerServicePlanAIFeatureStatus))
                  Obx(() => controller.buildGenerateWithAIView(
                    label: (entry.isWritten?.value ?? false)
                        ? label_rewrite_with_ai.tr
                        : label_generate_with_ai.tr,
                    onTap: () {
                      if (entry.langCode == null ||
                          entry.langCode!.isEmpty) {
                        controller.showSnackBar(
                            "label_please_select_language".tr);
                        return;
                      }
                      Map<String, dynamic> params = {};
                      params["location"] =
                      "${controller.itemInfo.street}, ${controller.itemInfo.city}, ${controller.itemInfo.state}, ${controller.itemInfo.country}";
                      params["carDetails"] =
                      "${controller.itemInfo.carType}, ${controller.itemInfo.make}, ${controller.itemInfo.model}, ${controller.itemInfo.year}, ${controller.itemInfo.odometer}";
                      params["carFeatures"] =
                          controller.itemInfo.carFeatures;
                      params["carType"] = controller.itemInfo.carType;
                      params["language"] = entry.langCode;
                      params["index"] = index;
                      debugPrint(
                          "Car features --> ${controller.itemInfo.carFeatures}");
                      Get.to(GenerateWithAIListings(),
                          binding: PropertyStepsBinding(),
                          arguments: params)
                          ?.then((value) {
                        if (value != null && value.isNotEmpty) {
                          int? indexValue = value["selectedIndex"];
                          if (indexValue != null && indexValue < controller.languageEntries.length) {
                            var entry = controller.languageEntries[indexValue];

                            if (value.containsKey("title")) {
                              entry.titleController.text = value["title"] ?? "";
                            }
                            if (value.containsKey("description")) {
                              entry.descController.text = value["description"] ?? "";
                            }

                            if (entry.titleController.text.isNotEmpty || entry.descController.text.isNotEmpty) {
                              entry.isWritten?.value = true;
                            } else {
                              entry.isWritten?.value = false;
                            }
                            controller.languageEntries.refresh();
                          }
                        }
                      });
                    },
                  )),
                [
                  if (entries.length == 1)
                    toOnTap(
                      onTap: controller.addLanguageEntry,
                      child: [
                        Assets.drawableCountIncrement.toSVG(
                            size: 12, colour: appColors.secondaryColor),
                        5.toWidth(),
                        CustomText(
                          text: label_add_language.tr,
                          color: appColors.secondaryColor,
                        ),
                      ].toRow(),
                    )
                  else if (index == entries.length - 1 && index < allLanguages.length - 1)
                    [
                      toOnTap(
                        onTap: () =>
                            controller.removeLanguageEntry(index),
                        child: [
                          ((overALLThemeType == 1) ? (Assets.drawableWishlistGroupDelete) : (overALLThemeType == 2) ? (Assets.theme2DeleteAccountDeleteAccount) : (overALLThemeType == 2) ? (Assets.theme3DeleteAccountDeleteAccount) : (Assets.theme4DeleteAccountDeleteAccount)).toSVG(
                              size: 12,
                              colour: appColors.secondaryColor),
                          5.toWidth(),
                          CustomText(
                            text: label_remove.tr,
                            color: appColors.secondaryColor,
                          ),
                        ].toRow(),
                      ).toPad(end: 10),
                      toOnTap(
                        onTap: controller.addLanguageEntry,
                        child: [
                          Assets.drawableCountIncrement.toSVG(
                              size: 12,
                              colour: appColors.secondaryColor),
                          5.toWidth(),
                          CustomText(
                            text: "label_add".tr,
                            color: appColors.secondaryColor,
                          ),
                        ].toRow(),
                      ),
                    ].toRow()
                  else
                    toOnTap(
                      onTap: () => controller.removeLanguageEntry(index),
                      child: [
                        ((overALLThemeType == 1) ? (Assets.drawableWishlistGroupDelete) : (overALLThemeType == 2) ? (Assets.theme2DeleteAccountDeleteAccount) : (overALLThemeType == 2) ? (Assets.theme3DeleteAccountDeleteAccount) : (Assets.theme4DeleteAccountDeleteAccount)).toSVG(
                            size: 12,
                            colour: appColors.secondaryColor),
                        5.toWidth(),
                        CustomText(
                          text: label_remove.tr,
                          color: appColors.secondaryColor,
                        ),
                      ].toRow(),
                    ),
                ].toRow(mainAxisAlignment: MainAxisAlignment.end, mainAxisSize: MainAxisSize.min),
              ],
            ).toResizeWidget(width: double.infinity),
            16.toHeight(),
            if (entries.length - 1 != index) filterDivider
          ].toColumn(crossAxisAlignment: CrossAxisAlignment.start);
        }, key: const PageStorageKey<String>('inboxlist'),
      );
    });
  }
}