part of '../payout_preference_controller.dart';


mixin PayoutPaypalDetailsMixin on PayoutPaymentChooseMixin {
  List<PayoutPaypalDetailsEnum> payPalTextFieldDisableEnumList = [PayoutPaypalDetailsEnum.payPalCurrency];
  Map<PayoutPaypalDetailsEnum,TitleTextFieldModel> payoutPaypalDetailsMap = {};

  void getAllPaypalData() {
    for (var element in PayoutPaypalDetailsEnum.values) {
      payoutPaypalDetailsMap[element] =  TitleTextFieldModel(
        customTextEditingController: CustomTextEditingController(
            text: payPalTextFieldDisableEnumList.contains(element) ?
            changePaypalCurrency(paymentlist.firstWhere((element) => element?.id == 1)?.currency ?? '') :
            ""),
        focusNode: CustomFocusNode(),
        title: element.title.tr,
        hintText: element.hintText.tr
      );
    }
  }

  bool validatePayPalInputFields() {
    for(var element in payoutPaypalDetailsMap.entries){
      var key = element.key;
      var entry = element.value;
      if(entry.customTextEditingController.text.isEmpty) {
        showSnackBar(error_msg_empty.trParams({'field': entry.hintText.tr.toLowerCase()}), isltralign: true);
        return false;
      }else if(key == PayoutPaypalDetailsEnum.payPalEmail){
       bool _isValidEmail =  isValidEmail(entry.customTextEditingController.text);
       if(!_isValidEmail) {
         showSnackBar(error_msg_valid.trParams({'field':entry.hintText.tr.toLowerCase()}), isltralign: true);
         isLoading.value = false;
       }
      return _isValidEmail;
      }
    }
    return true;
  }

  void setPaypalFieldValue({required PayoutPaypalDetailsEnum fieldEnum,required String fieldValue}){
    payoutPaypalDetailsMap[fieldEnum]?.customTextEditingController.text = fieldValue;
  }

  String getPayPalFieldValue({required PayoutPaypalDetailsEnum fieldEnum}) {
    return payoutPaypalDetailsMap[fieldEnum]?.customTextEditingController.text ?? "";
  }

  String changePaypalCurrency(String value){
    debugPrint("listOfPayPalCurrencies: $listOfPayPalCurrencies --- $value");
   String selectedCurrency = listOfPayPalCurrencies?.firstWhere((element)=>element.toString().contains(value));
   listOfPayPalCurrencies?.remove(selectedCurrency);
   listOfPayPalCurrencies?.insert(0, selectedCurrency);
    return selectedCurrency;
  }

}

enum PayoutPaypalDetailsEnum{
  payPalEmail(title: label_email_address,hintText: enter_your_paypal_email),
  payPalCurrency(title: label_currency,hintText: label_currency);

  final String title;
  final String hintText;
  const PayoutPaypalDetailsEnum({required this.title,required this.hintText});
}