import 'package:flutter/material.dart' hide showBottomSheet;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/widgets/bottom_sheet/add_phone_number/add_phone_controller.dart';
import 'package:gozy/widgets/bottom_sheet/country_selection_bottom_sheet.dart';
import 'package:gozy/widgets/common/custom_bottomsheet/custom_bottomsheet.dart';
import 'package:gozy/widgets/common/custom_button/primary_button.dart';
import 'package:gozy/widgets/common/custom_container/custom_border_container.dart';
import 'package:gozy/widgets/common/custom_container/custom_bottom_item_shadow_container.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/common/custom_textfield/custom_prefix_textfield.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/common/custom_container/custom_container.dart';
import 'package:gozy/widgets/custom_text.dart';

import '../../../resources/app_layout.dart';

class AddPhoneNumberBottomSheet extends BaseController {
  final AddPhoneController _controller = Get.find();

  AddPhoneNumberBottomSheet() {
    if (elementsItemVal.isEmpty) {
      countryInitFun();
    }
    if (appPreference.phoneNumber != null && appPreference.phoneNumber!.isNotEmpty) {
      _controller.phoneNumberController.text = appPreference.phoneNumber!;
      _controller.selectedCountryCode = appPreference.countryCode;
      if (_controller.selectedCountryCode != null && _controller.selectedCountryCode!.isNotEmpty) {
        var item = elementsItemVal.firstWhere((p0) => p0?.dialCode == appPreference.countryCode);
        _controller.initFlag = item.flagUri;
        _controller.countryName = item.code;
      }
    }
    showCustomBottomSheet(
      backButtonWidget: getBackIconWidget(
        themeType: appLayoutMap[AppLayout.profile]?.themeType,
      ),
      contentWidget: CustomContainer(
        body: [
          [
            CustomTitleText(
              text: "${label_add.tr} ${label_phone_number.tr.toLowerCase()}",
              size: AppDimen.textSize_18,
            ),
            12.toHeight(),
            CustomText(
              text: label_add_phone_content.trParams({'field': APP_NAME}),
              size: AppDimen.textSize_14,
              fontWeight: AppFont.regular,
            ),
            20.toHeight(),
            _showPhoneNumber(),
          ].toColumn().toPad(horizontal: AppDimen.startMargin),
          Spacer(),
          CustomBottomItemShadowContainer(
            padding: pad(w: AppDimen.startMargin, h: AppDimen.startMargin + 5),
            body: PrimaryButton(
              buttonText: btn_label_next.tr,
              onTap: () {
                bool isvalidate = _controller.validateCredentials("phone");
                if (isvalidate) {
                  checkNetwork(_controller.addPhoneNumber);
                }
              },
            ),
          )
        ].toColumn(mainAxisAlignment: MainAxisAlignment.start),
      ),
    );
  }

  Widget _showPhoneNumber() {
    return Obx(() {
      _controller.isUpdateSelectedItem.value;
      return CustomPrefixTextField(
        focusNode: FocusNode(),
        borderTextfieldPadding: EdgeInsetsDirectional.zero,
        title: label_phone_number.tr,
        controller: _controller.phoneNumberController,
        textInputAction: TextInputAction.done,
        hintText: label_phone_number.tr,
        hintTextColor: appColors.textfieldHintColor,
        keyboardType: TextInputType.number,
        characterlength: 15,
        filteringTextInputFormatter: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        prefixIconWidget: _getPrefixIcon(
            dialCode: _controller.selectedCountryCode ?? defaultDialCode,
            onTap: () {
              CountrySelectionBottomSheet(
                controller: _controller,
                countries: elementsItemVal,
                selectedValue: _controller.countryName,
                searchController: _controller.countrySearchController,
                updateTrigger: _controller.isUpdateSelectedItem,
                onSelect: (item) {
                  _controller.selectedCountryCode = item.dialCode;
                  _controller.initFlag = item.flagUri;
                  _controller.countryName = item.code;
                },
              );
            }).toResizeWidget(height: 50).toPad(end: 15),
      );
    });
  }

  Widget _getPrefixIcon({required String dialCode, required GestureTapCallback onTap}) {
    int? themeType = appLayoutMap[AppLayout.inputType]?.themeType;
    double borderRadius = appLayoutMap[AppLayout.inputType]?.borderRadius ?? 0;
    return themeType != 4
        ? CustomBorderContainer(
            color: appColors.black,
            borderRadiusGeometry: BorderRadiusDirectional.only(
              topStart: Radius.circular(borderRadius),
              bottomStart: Radius.circular(borderRadius),
            ),
            onTap: onTap,
            body: prefixIconLayout(dialCode),
          )
        : toOnTap(
            onTap: onTap,
            child: prefixIconLayout(dialCode),
          );
  }

  Widget prefixIconLayout(dialCode) {
    return [
      [
        4.toWidth(),
        CustomText(
          text: dialCode,
          size: AppDimen.textSize_14,
          fontWeight: AppFont.regular,
          color:
              appLayoutMap[AppLayout.inputType]?.themeType == 4 ? appColors.customTextColor : appColors.white,
        ),
        5.toWidth(),
        Assets.drawableDownArrow.toSVG(
            colour: appLayoutMap[AppLayout.inputType]?.themeType == 4
                ? appColors.customTextColor
                : appColors.white),
        5.toWidth(),
        appLayoutMap[AppLayout.inputType]?.themeType == 4
            ? Container(color: appColors.customTextColor, width: 1, height: 20).toPad(start: 6)
            : const SizedBox.shrink()
      ].toRow(
        mainAxisAlignment: MainAxisAlignment.start,
      )
    ]
        .toColumn(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center)
        .toPad(horizontal: 10);
  }
}