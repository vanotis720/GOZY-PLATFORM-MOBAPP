import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/resources/app_layout.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/booking/generate_with_ai/generate_with_ai_controller.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/screens/views/home_item_detail/home_item_detail.dart';
import 'package:gozy/widgets/ai_disclaimer_view.dart';
import 'package:gozy/widgets/common/custom_bottomsheet/custom_draggable_bottomsheet.dart';
import 'package:gozy/widgets/common/custom_bottomsheet/custom_getx_bottomsheet.dart';
import 'package:gozy/widgets/common/custom_button/primary_button.dart';
import 'package:gozy/widgets/common/custom_container/custom_border_container.dart';
import 'package:gozy/widgets/common/custom_container/custom_bottom_item_shadow_container.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_textfield.dart';
import 'package:gozy/widgets/shader_ai_text_view.dart';
import 'package:gozy/widgets/shader_text.dart';
import 'package:gozy/widgets/show_done_view.dart';

class GenerateWithAI extends HomeItemDetailView {
  GenerateWithAI({super.key});

  @override
  _GenerateWithAIState createState() => _GenerateWithAIState();
}

class _GenerateWithAIState extends HomeItemDetailState {
  GenerateWithAIController generateWithAIController =
      Get.find<GenerateWithAIController>();

  int minValue = 5;

  bool singleClick = true;

  @override
  void initState() {
    generateWithAIController.startingTime = Get.arguments["startTime"];
    generateWithAIController.endingTime = Get.arguments["endTime"];
    final sDate = DateTime.fromMillisecondsSinceEpoch(
        Get.arguments["startDate"].millisecondsSinceEpoch);
    generateWithAIController.startingDate =
        DateFormat(commonDateFormat).format(sDate);
    final eDate = DateTime.fromMillisecondsSinceEpoch(
        Get.arguments["endDate"].millisecondsSinceEpoch);
    generateWithAIController.formatedStartDate =
        DateFormat(commonDateFormat).format(sDate);
    generateWithAIController.formatedEndDate =
        DateFormat(commonDateFormat).format(eDate);
    generateWithAIController.endingDate =
        DateFormat(commonDateFormat).format(eDate);
    generateWithAIController.selectedReasonController.text = reasonForBooking[0].itemValue;
    generateWithAIController.hostName = Get.arguments["hostName"] ?? "";
    generateWithAIController.type = Get.arguments["type"] ?? "";
    generateWithAIController.contentController.text =
        Get.arguments["special_apperance"] ?? "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    minValue =
        (appLayoutMap[AppLayout.inputType]?.themeType ?? 1) == 4 ? 1 : minValue;
    return CustomScaffold(
      controller: generateWithAIController,
      isShowAppBar: true,
      isShowBGOnLoader: false,
      loader: LottieLoaders.world_loader,
      resizeToAvoidBottomInset: false,
      backIconWidget: getBackIconWidget(
        themeType: overALLThemeType,
        onTap: () {
          Get.back();
        },
      ),
      body: InputDoneView(
        generateWithAIController,
        parentWidget: _showBodyContent().toPad(bottom: MediaQuery.viewInsetsOf(context).bottom)
      ),
      bottomNavigationBar: MediaQuery.viewInsetsOf(context).bottom > 0 ? const SizedBox.shrink() : _showBottomView(),
    );
  }

  Widget _showBodyContent() {
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              [
                ..._showTitleViewAndTripDuration(),
                ..._showTripTimeView(),
                ..._showReasonForBookingField(),
                _buildMessageView(),
              ].toColumn(mainAxisAlignment: MainAxisAlignment.start),
              [
                const AIDisclaimerView(),
                20.toHeight(),
              ].toColumn(),
            ],
          ),
        ),
      );
    }).toPad(horizontal: AppDimen.startMargin).addScrollConfig();
  }

  List<Widget> _showTitleViewAndTripDuration() {
    return [
      [
        CustomTitleText(
            text: label_generate_message_with.tr,
            size: AppDimen.textSize_20,
            fontWeight: FontWeight.w600),
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

  List<Widget> _showTripTimeView() {
    return [
      _buildTripTimeText(
          label: "${label_trip_start.tr}:",
          content:
              "${generateWithAIController.startingDate}, ${generateWithAIController.startingTime}"),
      _buildTripTimeText(
          label: "${label_trip_end.tr}:",
          content:
              "${generateWithAIController.endingDate}, ${generateWithAIController.endingTime}"),
      15.toHeight()
    ];
  }

  List<Widget> _showReasonForBookingField() {
    return [
      TitleTextField(
        borderTextfieldPadding: appLayoutMap[AppLayout.inputType]?.themeType == 4 ? EdgeInsets.zero : null,
        title: label_reason_for_booking.tr,
        controller: generateWithAIController.selectedReasonController,
        keyboardType: TextInputType.name,
        textInputAction: TextInputAction.next,
        enabled: false,
        onTap: () {
          FocusManager.instance.primaryFocus!.unfocus();
          GetXBottomSheet(
            bottomSheetWidget: getDraggableSheetWidget(
                controller: controller,
                listItems: reasonForBooking,
                themeType: overALLThemeType,
                selectedValue:
                    generateWithAIController.selectedReasonController.text,
                isShowCircleTick: true,
                borderRadius: overALLAppLayoutModel?.borderRadius,
                onItemSelected: (value) {
                  generateWithAIController.selectedReasonController.text =
                      value.itemValue;
                }),
            sheetCloseListener: () => FocusManager.instance.primaryFocus!.unfocus()
          );
        },
        suffixIcon: Assets.drawableDownArrow,
        suffixIconSize: 8,
      ),
      AppDimen.startMargin.toHeight(),
      _buildMentionRequest()
    ];
  }

  Widget _buildMessageView() {
    return generateWithAIController
        .buildAIResponseView(content: generateWithAIController.responseMessage)
        .toPad(top: AppDimen.startMargin);
  }

  Widget _buildMentionRequest() {
    return TitleTextField(
      focusNode: generateWithAIController.controllerFocusNode,
      borderTextfieldPadding: appLayoutMap[AppLayout.inputType]?.themeType == 4 ? EdgeInsets.zero : null,
      title: label_mention_special_requests.tr,
      hintText: label_mention_special_requests_hint_text.tr,
      controller: generateWithAIController.contentController,
      contentPadding: pad(top: 12, bottom: 12),
      minLines: minValue,
      maxLines: 5,
    ).toPad(horizontal: 1);
  }

  Widget _buildTripTimeText({String label = "", String content = ""}) {
    return [
      CustomBorderContainer(
        padding: pad(a: 8),
        borderColor: appColors.myTripsDividerColor,
        color: appColors.lightYellowColor,
        borderRadius: overALLAppLayoutModel?.borderRadius,
        body: [
          CustomTitleText(
            text: label,
            fontWeight: FontWeight.w500,
            size: AppDimen.textSize_12,
          ),
          5.toWidth(),
          CustomTitleText(
              text: content,
              size: AppDimen.textSize_12,
              fontWeight: FontWeight.normal)
        ].toRow(),
      ).toPad(bottom: 15)
    ].toRow(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start);
  }

  Widget _showBottomView() {
    return Obx(
      () => CustomBottomItemShadowContainer(
        height: 100,
        color: appColors.white,
        padding: pad(w: 20, top: 25, bottom: 20),
        borderRadiusGeometry: BorderRadiusDirectional.vertical(
            top: Radius.circular(overALLAppLayoutModel?.borderRadius ?? 0),
            bottom: Radius.circular(overALLAppLayoutModel?.borderRadius ?? 0)),
        body: [
          generateWithAIController.responseMessage.value.isNotEmpty
              ? toOnTap(
                  onTap: () {
                    if (singleClick) {
                      singleClick = false;
                      generateWithAIController.isLoading.value = true;
                      generateWithAIController
                          .getAIMessage(
                              tripStart:
                                  generateWithAIController.formatedStartDate,
                              tripEnd: generateWithAIController.formatedEndDate,
                              reasonForRental: generateWithAIController
                                  .selectedReasonController.Ttext,
                              hostName: generateWithAIController.hostName,
                              type: generateWithAIController.type,
                              content: generateWithAIController
                                  .contentController.Ttext)
                          .then((_) {
                        singleClick = true;
                        generateWithAIController.isLoading.value = false;
                      });
                    }
                  },
                  child: [
                    Assets.drawableAi.toSVG(size: 24).toPad(top: 5),
                    3.toWidth(),
                    ShaderText(label: label_regenerate.tr),
                  ].toRow(mainAxisSize: MainAxisSize.min).toPad(horizontal: 4))
              : const SizedBox.shrink(),
          Spacer(),
          PrimaryButton(
                  buttonText:
                      generateWithAIController.responseMessage.value.isEmpty
                          ? label_generate_text.tr
                          : label_apply_text.tr,
                  onTap: () {
                    if (singleClick) {
                      singleClick = false;
                      if (generateWithAIController
                          .responseMessage.value.isEmpty) {
                        generateWithAIController.isLoading.value = true;
                        generateWithAIController
                            .getAIMessage(
                                tripStart:
                                    generateWithAIController.formatedStartDate,
                                tripEnd:
                                    generateWithAIController.formatedEndDate,
                                reasonForRental: generateWithAIController
                                    .selectedReasonController.Ttext,
                                hostName: generateWithAIController.hostName,
                                type: generateWithAIController.type,
                                content: generateWithAIController
                                    .contentController.Ttext)
                            .then((_) {
                          singleClick = true;
                          generateWithAIController.isLoading.value = false;
                        });
                      } else {
                        Get.back(
                            result:
                                generateWithAIController.responseMessage.value);
                      }
                    }
                  },
                  padding: pad(w: AppDimen.startMargin))
              .toResizeWidget(width: deviceWidth * 0.4),
        ].toRow(),
      ),
    );
  }
}