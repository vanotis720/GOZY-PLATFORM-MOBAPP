import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/profile/payout_preference/payout_preference_navigator.dart';
import 'package:gozy/widgets/common/custom_button/bottom_shadow_button.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/common/custom_textfield/custom_prefix_textfield.dart';

import '../../../../../constant.dart';
import '../../../../../resources/app_lang.dart';
import '../../../../../resources/app_layout.dart';
import '../../../../../utils/text_editing_controller.dart';
import '../../../../../widgets/common_extension_functions.dart';
import '../../../../../widgets/custom_stateful_widget.dart';
import '../../../custom_scaffold.dart';
import '../payout_preference_controller.dart';

class PayoutAddressDetails extends CustomStatefulWidget {
  const PayoutAddressDetails({super.key});

  @override
  PayoutAddressDetailsState createState() => PayoutAddressDetailsState();
}

class PayoutAddressDetailsState extends CustomStatefulWidgetState<PayoutAddressDetails> with TickerProviderStateMixin {
  PayoutPreferenceController controller = Get.find();
  static AppLayoutModel? profile = appLayoutMap[AppLayout.profile];
  double? nextButtonBorderRadius;

  @override
  void initState() {
    controller.getAllPayoutAddressData(controller.countryController.text);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch(profile?.themeType) {
      case 3:
        nextButtonBorderRadius = 30;
        break;
      default:
        nextButtonBorderRadius = profile?.borderRadius;
        break;
    }
    return  CustomScaffold(
      controller: controller,
      isShowAppBar: true,
      customAppBarFunction: (){
        controller.countryController.clear();
        onBack();
      },
      backIconWidget: getBackIconWidget(onTap:() {
        controller.countryController.clear();
        onBack();
      },  themeType: overALLThemeType,),
      resizeToAvoidBottomInset: true,
      body: showBodyContent(),
    );
  }

  Widget showBodyContent() {
    return [
      CustomTitleText(text: address.tr, size: AppDimen.textSize_22, fontWeight: AppFont.semiBold,).toPad(horizontal: AppDimen.startMargin, bottom: 10),
      _showAllTextField().toScroll(padding: pad(w:AppDimen.startMargin)).toStretch(),
      _showNextButton(),
    ].toColumn();
  }

 List<Widget> _showAllTextField() {
    List<Widget> children = [];
    children.add(15.toHeight());

    controller.payoutAddressDetailsMap.entries.toList().asMap().forEach((index, entry) {
      children.add(
        _showTextFieldWidget(
          onTap: () => controller.payoutPreferenceNavigator?.navigateScreen(PayoutPreferenceScreen.payoutCountrySearch),
          addressDetailsEnum: entry.key,
          suffixIcon: entry.key.title == "payout_country" ? Assets.drawableDownArrow : null,
          focusNode: entry.value.focusNode,
          customTextEditingController: entry.value.customTextEditingController,
          hintText: entry.value.title,
          index: index
        )
      );
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
        if(controller.validateInputFields()){
          FocusManager.instance.primaryFocus!.unfocus();
          controller.payoutPreferenceNavigator?.navigateScreen(PayoutPreferenceScreen.payoutPaymentChoose);
        }
      },
    );
  }

  Widget _showTextFieldWidget({required CustomTextEditingController customTextEditingController,required String hintText,required AddressDetailsEnum addressDetailsEnum,FocusNode? focusNode,required int index,VoidCallback? onTap, String? suffixIcon}) {
    return CustomPrefixTextField(
      title: hintText,
      onTap: controller.keyBoardDisableEnumList.contains(addressDetailsEnum) ? onTap : null,
      controller: customTextEditingController,
      enabled: !controller.keyBoardDisableEnumList.contains(addressDetailsEnum),
      keyboardType: TextInputType.text,
      suffixIconWidget: suffixIcon?.toSVG(size: 8, colour: appColors.black),
      hintText: hintText,
      maxLines: 1,
      minLines: 1,
      focusNode: focusNode,
      textCapitalization: TextCapitalization.sentences,
      textInputAction:  controller.payoutAddressDetailsMap.keys.last == addressDetailsEnum? TextInputAction.done : TextInputAction.next,
      onSubmitted: (v){
          FocusScope.of(context).requestFocus(controller.payoutAddressDetailsMap.entries.toList()[index + 1].value.focusNode);
      },
    ).toPad(bottom: 16);
  }
}