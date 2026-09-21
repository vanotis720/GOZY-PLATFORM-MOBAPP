import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/widgets/common/custom_bottomsheet/custom_draggable_bottomsheet.dart';
import 'package:gozy/widgets/common/custom_bottomsheet/custom_getx_bottomsheet.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/common/custom_textfield/custom_prefix_textfield.dart';
import 'package:gozy/widgets/owner/step_item_model.dart';

import '../../../../../constant.dart';
import '../../../../../generated/assets.dart';
import '../../../../../resources/app_lang.dart';
import '../../../../../resources/app_layout.dart';
import '../../../../../utils/text_editing_controller.dart';
import '../../../../../widgets/common/custom_button/bottom_shadow_button.dart';
import '../../../../../widgets/common_extension_functions.dart';
import '../../../../../widgets/custom_stateful_widget.dart';
import '../../../base_controller.dart';
import '../../../custom_scaffold.dart';
import '../payout_preference_controller.dart';

class PayoutAccountDetails extends CustomStatefulWidget {
  const PayoutAccountDetails({super.key});

  @override
  PayoutAccountDetailsState createState() => PayoutAccountDetailsState();
}

class PayoutAccountDetailsState extends CustomStatefulWidgetState<PayoutAccountDetails>
    with TickerProviderStateMixin {
  PayoutPreferenceController controller = Get.find();
  static AppLayoutModel? profileLayout = appLayoutMap[AppLayout.profile];
  double? nextButtonBorderRadius;

  @override
  void initState() {
    controller.selectedAccountType = label_payout_type_individual;
    controller.getAllPayoutAccountData(controller.selectedAccountType);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch (profileLayout?.themeType) {
      case 3:
        nextButtonBorderRadius = 30;
        break;
      default:
        nextButtonBorderRadius = profileLayout?.borderRadius;
        break;
    }
    return CustomScaffold(
      controller: controller,
      isShowAppBar: true,
      backIconWidget: getBackIconWidget(
        themeType: overALLThemeType,
      ),
      resizeToAvoidBottomInset: true,
      body: Obx(() => controller.accountTypeList.isNotEmpty ? [
        showBodyContent(),
        controller.isNextButtonLoading.value ? showCenterLoading(
          controller: controller,
          loader: LottieLoaders.world_loader,
          isShowBGOnLoader: true,
        ) : const SizedBox.shrink()
      ].toStack() : const SizedBox.shrink()),
    );
  }

  Widget showBodyContent() {
    return [
      CustomTitleText(
        text: label_payout_account_details.tr,
        size: AppDimen.textSize_22,
        fontWeight: AppFont.semiBold,
      ).toPad(horizontal: AppDimen.startMargin, bottom: 10),
      _showAllTextField().toScroll(padding: pad(w: AppDimen.startMargin)).toStretch(),
      _showNextButton(),
    ].toColumn();
  }

  List<Widget> _showAllTextField() {
    List<Widget> children = [];
    children.add(15.toHeight());
    controller.payoutAccountDetailsMap.entries.toList().asMap().forEach((index, entry) {
      children.add(_showTextFieldWidget(
          index: index,
          focusNode: entry.value.focusNode,
          payoutAccountDetailsEnum: entry.key,
          customTextEditingController: entry.value.customTextEditingController,
          hintText: entry.value.title));
    });
    return children;
  }

  Widget _showNextButton() {
    return BottomShadowButton(
      buttonPadding: pad(a: 20),
      borderRadiusGeometry: BorderRadiusDirectional.only(
          topStart: Radius.circular(nextButtonBorderRadius ?? 0),
          topEnd: Radius.circular(nextButtonBorderRadius ?? 0)),
      buttonText : btn_label_next.tr,
      onTap: () async{
        if (controller.validatePayoutAccountFields()) {
          FocusManager.instance.primaryFocus!.unfocus();
          controller.checkNetwork(() {
            controller.initAddPayout(2);
          });
        }
      },
    );
  }

  Widget _showTextFieldWidget(
      {required CustomTextEditingController customTextEditingController,
      required String hintText,
      required PayoutAccountDetailsEnum payoutAccountDetailsEnum,
      required FocusNode focusNode,
      required int index}) {
    bool isDisableField = !controller.payoutAccountDetailsDisableEnumList.contains(payoutAccountDetailsEnum);
    return [
      CustomPrefixTextField(
        title: hintText,
        onTap: () {
          _changeAccountType();
        },
        suffixIcon: isDisableField ? null : Assets.drawableFilterCalendarArrow,
        suffixIconQuarterTurns: isDisableField ? null : 3,
        controller: customTextEditingController,
        enabled: isDisableField,
        keyboardType: TextInputType.text,
        focusNode: focusNode,
        hintText: hintText,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: controller.payoutAccountDetailsMap.keys.last == payoutAccountDetailsEnum
            ? TextInputAction.done
            : TextInputAction.next,
        onSubmitted: (value) {
          controller.payoutAccountDetailsMap.entries.toList()[index + 1].value.focusNode.nextFocus();
          FocusScope.of(context)
              .requestFocus(controller.payoutAccountDetailsMap.entries.toList()[index + 1].value.focusNode);
        },
      ).toPad(bottom: 16),
    ].toColumn(mainAxisSize: MainAxisSize.min);
  }

  void _changeAccountType() {
    List<dynamic> accountTypeArrayList = [];
    for (var key in controller.accountTypeList) {
      debugPrint("itemName--> ${key}");
      StepItemModel stepItemModel = StepItemModel(
        itemValue: key,
        itemName: key.tr,
      );
      accountTypeArrayList.add(stepItemModel);
    }

    GetXBottomSheet(
      bottomSheetWidget: getDraggableSheetWidget(
        controller: controller,
        listItems: accountTypeArrayList,
        selectedValue: controller.selectedAccountType,
        borderRadius: profileLayout?.borderRadius,
        themeType: profileLayout?.themeType,
        onItemSelected: (value) {
          controller.selectedAccountType = value.itemValue;
          controller.getAllPayoutAccountData(controller.selectedAccountType);
        }
      ),
    );
  }

  @override
  void dispose() {
    for (var element in controller.payoutAccountDetailsMap.values) {
      element.focusNode.dispose();
    }
    super.dispose();
  }
}