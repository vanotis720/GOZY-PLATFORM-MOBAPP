part of '../payout_preference_controller.dart';

mixin PayoutAddressDetailsMixin on ProfileController {
  List<AddressDetailsEnum> keyBoardDisableEnumList = [AddressDetailsEnum.country];
  Map<AddressDetailsEnum,TitleTextFieldModel> payoutAddressDetailsMap = {};
  var focusNodeList = <CustomFocusNode>[];
  var texteditControllerList = <CustomTextEditingController>[];

  void getAllPayoutAddressData(String selectCountry) {

    for (var element in AddressDetailsEnum.values) {
      CustomFocusNode customfocusnode = CustomFocusNode();
      focusNodeList.add(customfocusnode);
      var textController = CustomTextEditingController(text: keyBoardDisableEnumList.contains(element) ? selectCountry : "");
      texteditControllerList.add(textController);
      payoutAddressDetailsMap[element] =  TitleTextFieldModel(
      customTextEditingController: textController,
      title: element.title.tr,
       focusNode: customfocusnode,
      hintText: ''
      );
    }
    focusNodeList.toAddListener();
  }

  String getPayoutAddressFieldValue({required AddressDetailsEnum fieldEnum}) {
    return payoutAddressDetailsMap[fieldEnum]?.customTextEditingController.text.trim() ?? "";
  }

 bool validateInputFields() {
    for(var element in payoutAddressDetailsMap.entries){
      var key = element.key;
      var entry = element.value;
      if(entry.customTextEditingController.text.trim().isEmpty && key != AddressDetailsEnum.addressLineTwo) {
        showSnackBar(error_msg_empty.trParams({'field': entry.title.tr.toLowerCase()}), isltralign: true);
        return false;
      }
    }
    return true;
  }
}

enum AddressDetailsEnum {
  country(title: payout_country),
  addressLineOne(title: address_line_one),
  addressLineTwo(title: address_line_two),
  city(title: label_city),
  stateOrProvince(title: label_state_province),
  zipCodeOrPostalCode(title: label_zip_code_postal);

  final String title;
  const AddressDetailsEnum({required this.title});
}


class TitleTextFieldModel {
  String title;
  String hintText;
  CustomTextEditingController customTextEditingController;
  FocusNode focusNode;
  TitleTextFieldModel({required this.title,required this.customTextEditingController,required this.hintText,required this.focusNode});
}