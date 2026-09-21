import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/screens/views/owner/generate_with_ai_owner/generate_with_ai_listings_controller.dart';
import 'package:gozy/widgets/ai_disclaimer_view.dart';
import 'package:gozy/widgets/checkbox_group.dart';
import 'package:gozy/widgets/common/custom_bottomsheet/custom_draggable_bottomsheet.dart';
import 'package:gozy/widgets/common/custom_bottomsheet/custom_getx_bottomsheet.dart';
import 'package:gozy/widgets/common/custom_button/primary_button.dart';
import 'package:gozy/widgets/common/custom_container/custom_bottom_item_shadow_container.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_stateful_widget.dart';
import 'package:gozy/widgets/custom_text.dart';
import 'package:gozy/widgets/custom_textfield.dart';
import 'package:gozy/widgets/shader_ai_text_view.dart';
import 'package:gozy/widgets/shader_text.dart';


class GenerateWithAIListings extends CustomStatefulWidget {
  GenerateWithAIListings({super.key});

  @override
  _GenerateWithAIState createState() => _GenerateWithAIState();
}

class _GenerateWithAIState extends CustomStatefulWidgetState {
  GenerateWithAIListingsController controller = Get.find<GenerateWithAIListingsController>();
  bool isCarFeatureShow = false;

  @override
  void initState() {
    controller.resetData();
    initFunction();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      controller: controller,
      isShowAppBar: true,
      isShowBGOnLoader: true,
      isDisableLoader: false,
      loader: LottieLoaders.world_loader,
      resizeToAvoidBottomInset: true,
      backIconWidget: getBackIconWidget(
        themeType: overALLThemeType,
        backIcon: Assets.drawableSignupClose,
        onTap: () {
          Get.back();
        },
      ),
      body: _showBodyContent(),
      bottomNavigationBar: _showBottomView(),
    );
  }

  Widget _showBodyContent() {
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: [
            [
              ..._showTitleViewAndTripDuration(),
              ..._showTargetRenterAndSelect(),
              ..._showGeneratedContentView(),
            ].toColumn(),
            [
              const AIDisclaimerView(),
              20.toHeight(),
            ].toColumn()
          ].toColumn(mainAxisAlignment: MainAxisAlignment.spaceBetween),
        ),
      );
    }).toPad(horizontal: AppDimen.startMargin).addScrollConfig();
  }

  List<Widget> _showTitleViewAndTripDuration() {
    return [
      [
        CustomTitleText(
            text:
                "${"label_create".tr} ${"label_title".tr.toLowerCase()} & ${"title_description".tr} ${"label_with_text".tr}",
            size: AppDimen.textSize_20,
          fontWeight: AppFont.semiBold,
        ),
        5.toWidth(),
        AiPillCard(),
      ]
          .toRow(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start)
          .toPad(bottom: AppDimen.startMargin)
    ];
  }

  List<Widget> _showGeneratedContentView() {
    return [
      Obx(() => (controller.isGenerated.value
          ? controller.buildAIResponseWithCheckBox(
              title: controller.titleContent,
              description: controller.descriptionContent,
              descriptionCheck: controller.isDescriptionCheck,
              titleCheck: controller.isTitleCheck,
            )
          : const SizedBox.shrink())),
    ];
  }

  List<Widget> _showTargetRenterAndSelect() {
    return [_buildChooseTargetRenterView(), _buildCheckBoxView()];
  }

  Widget _buildChooseTargetRenterView() {
    return TitleTextField(
      title: "label_choose_target_renters".tr,
      enabled: false,
      controller: controller.chooseTargetRenterController,
      onTap: () {
        GetXBottomSheet(
            bottomSheetWidget: getDraggableSheetWidget(
          controller: controller,
          listItems: targetGuest,
          themeType: overALLThemeType,
          selectedValue: controller.chooseTargetRenterController.text,
          isShowCircleTick: true,
          borderRadius: overALLAppLayoutModel?.borderRadius,
          onItemSelected: (value) {
            controller.chooseTargetRenterController.text = value.itemValue;
          },
        ));
      },
      suffixIcon: Assets.drawableDownArrow,
      suffixIconSize: 8,
    );
  }

  Widget _buildCheckBoxView() {
    return [
      15.toHeight(),
      CustomText(
        text: "label_payout_payment_select".tr,
        size: AppDimen.textSize_16,
        fontWeight: AppFont.medium,
      ),
      15.toHeight(),
      _checkBoxAndContent(
          titleLabel: "${"label_location".tr} ",
          contents: controller.location,
          isCheck: controller.isLocationChecked,
          isCheckNeeded: false),
      10.toHeight(),
      if (isCarFeatureShow) ...[
        _checkBoxAndContent(
            titleLabel: "${"label_car_features".tr} ",
            contents: controller.carFeatures,
            isCheck: controller.isCarFeaturesChecked),],
      10.toHeight(),
      _checkBoxAndContent(
          titleLabel: "${"label_car_details".tr} ",
          contents: controller.carDetails,
          isCheck: controller.isCarDetailsChecked),
        15.toHeight(),
    ].toColumn();
  }

  Widget _checkBoxAndContent(
      {String titleLabel = "", String contents = "", RxBool? isCheck, bool isCheckNeeded = true}) {
    return Obx(
      () => toOnTap(
        onTap: !isCheckNeeded
            ? () {}
            : () {
          isCheck?.value = !(isCheck!.value);
        },
        child: [
            CustomCheckBox(
                ischeckCondition: isCheck?.value ?? false,
                borderColor: appColors.myTripsDividerColor,
                isNeedEndPadding: false,
                isNeedTopMargin: false,
                boxshape: BoxShape.rectangle,
                staticCheckColor: !isCheckNeeded ? appColors.listShareBGShadowColor : null),
          10.toWidth(),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "$titleLabel: ",
                    style: TextStyle(
                      fontWeight: AppFont.semiBold,
                      color: appColors.textColor,
                      fontSize: AppDimen.textSize_14,
                      fontFamily: AppFont.font,
                    ),
                  ),
                  TextSpan(
                    text: contents,
                    style: TextStyle(
                      fontWeight: AppFont.regular,
                      color: appColors.textColor,
                      fontSize: AppDimen.textSize_14,
                      fontFamily: AppFont.font,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ].toRow(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start),
      ),
    );
  }

  Widget _showBottomView() {
    return Obx(() => CustomBottomItemShadowContainer(
          height: 100,
          color: appColors.white,
          padding: pad(w: 20, top: 25, bottom: 20),
          borderRadiusGeometry: BorderRadiusDirectional.vertical(
              top: Radius.circular(overALLAppLayoutModel?.borderRadius ?? 0),
              bottom: Radius.circular(overALLAppLayoutModel?.borderRadius ?? 0)),
          body: [
            controller.isGenerated.value
                ? toOnTap(
                    onTap: () {
                      if (!controller.isLoading.value) {
                        controller.getAIMessage().then((val) {
                          if (val.isNotEmpty) controller.showToast(val);
                        });
                      }
                    },
                    child: [
                      Assets.drawableAi.toSVG(size: 24).toPad(top: 5),
                      3.toWidth(),
                      ShaderText(label: label_regenerate.tr),
                    ].toRow(),
                  )
                : const SizedBox.shrink(),
            const Spacer(),
            PrimaryButton(
                    buttonText: controller.isGenerated.value ? label_apply_text.tr : label_generate_text.tr,
                    onTap: () {
                      if (!controller.isGenerated.value) {
                        if (!controller.isLoading.value) {
                          controller.getAIMessage().then((val) {
                            if (val.isNotEmpty) controller.showToast(val);
                          });
                        }
                      } else {
                        if (!controller.isLoading.value) {
                          controller.isLoading.value = true;
                          Future.delayed(const Duration(milliseconds: 600)).then((value) {
                            controller.isLoading.value = false;
                            if(controller.isTitleCheck.value || controller.isDescriptionCheck.value) {
                              Map<String, dynamic> result = {};
                              result["selectedIndex"] = controller.selectedIndex;
                              if (controller.isTitleCheck.value) {
                                result["title"] = controller.titleContent.value;
                              }
                              if (controller.isDescriptionCheck.value) {
                                result["description"] = controller.descriptionContent.value;
                              }
                              Get.back(result: result);
                            } else {
                              controller.showSnackBar("Kindly select any one of the section");
                            }
                          });
                        }
                      }
                    },
                    padding: pad(w: AppDimen.startMargin))
                .toResizeWidget(width: deviceWidth * 0.4)
          ].toRow(),
        ));
  }

  void initFunction() {
    controller.chooseTargetRenterController.text = targetGuest[0].itemValue;
    controller.location = Get.arguments['location'] ?? "";
    controller.carDetails = Get.arguments['carDetails'] ?? "";
    controller.carType = Get.arguments['carType'] ?? "";
    controller.language = Get.arguments['language'] ?? "";
    controller.selectedIndex = Get.arguments['index'] ?? -1;
    controller.carFeatures = "";
    if (Get.arguments['carFeatures'] != null && Get.arguments['carFeatures'].isNotEmpty) {
      isCarFeatureShow = true;
      for (int i = 0; i < Get.arguments['carFeatures'].length; i++) {
        if (i < Get.arguments['carFeatures'].length - 1) {
          controller.carFeatures += "${Get.arguments['carFeatures'][i].itemName}, ";
        } else {
          controller.carFeatures += "${Get.arguments['carFeatures'][i].itemName}";
        }
      }
    } else {
      isCarFeatureShow = false;
    }
  }
}