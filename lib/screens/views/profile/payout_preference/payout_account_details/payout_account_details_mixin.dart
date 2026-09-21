part of '../payout_preference_controller.dart';

mixin PayoutAccountDetailsMixin on PayoutCountrySearchMixin {
  List<PayoutAccountDetailsEnum> payoutAccountDetailsDisableEnumList = [PayoutAccountDetailsEnum.accountType];
  RxList<String> accountTypeList = RxList<String>([label_payout_company,label_payout_type_individual]);
String selectedAccountType  = label_payout_type_individual;
  Map<PayoutAccountDetailsEnum,TitleTextFieldModel> payoutAccountDetailsMap = {};


  void getAllPayoutAccountData(String selectedAccountType) {
    payoutAccountDetailsMap.clear();
    bool isSkip = false;
    for(var element in PayoutAccountDetailsEnum.values){
      if(element.disableEnum.disableCountryList.contains(selectedCountryCode)){
        isSkip = true;
        continue;
      }
      CustomFocusNode customfocusnode = CustomFocusNode();
      var textController = CustomTextEditingController(text: payoutAccountDetailsDisableEnumList.contains(element) ? selectedAccountType.tr : "");
      payoutAccountDetailsMap[element] =  TitleTextFieldModel(
          customTextEditingController: textController,
          title: element.title.tr,
          hintText: '',
          focusNode: customfocusnode,
      );
      if(!isSkip){
        hideDefaultFieldCountryBased();
      }
      hideFieldOnAccountTypeCountryBased(selectedAccountType);
    }
    accountTypeList.refresh();
  }

  bool validatePayoutAccountFields() {
    for(var entry in payoutAccountDetailsMap.entries){
      var enums = entry.key;
      var element = entry.value;
      if(element.customTextEditingController.text.trim().isEmpty) {
        showSnackBar(error_msg_empty.trParams({'field': element.title.tr.toLowerCase()}));
        return false;
      }else if(enums == PayoutAccountDetailsEnum.confirmAccountNumber && !europeCountriesList.contains(selectedCountryCode)){
        bool isValid = getPayoutAccountFieldValue(fieldEnum: PayoutAccountDetailsEnum.accountNumber) == getPayoutAccountFieldValue(fieldEnum: PayoutAccountDetailsEnum.confirmAccountNumber);
        if(!isValid) {
          showSnackBar(label_error_mismatch.trParams({'fieldOne': element.title.tr.toLowerCase(),'fieldTwo': PayoutAccountDetailsEnum.accountNumber.title.tr.toLowerCase()}));
        }
        return isValid;
      }else if(enums == PayoutAccountDetailsEnum.confirmIBANNumber && europeCountriesList.contains(selectedCountryCode)){
        bool isValid = getPayoutAccountFieldValue(fieldEnum: PayoutAccountDetailsEnum.iBANNumber) == getPayoutAccountFieldValue(fieldEnum: PayoutAccountDetailsEnum.confirmIBANNumber);
        if(!isValid) {
          showSnackBar(label_error_mismatch.trParams({'fieldOne': element.title.tr.toLowerCase(),'fieldTwo': PayoutAccountDetailsEnum.iBANNumber.title.tr.toLowerCase()}));
        }
        return isValid;
      }
    }
    return true;
  }

  bool _validateMatch(PayoutAccountDetailsEnum otherField, entry) {
    final bool isValid = getPayoutAccountFieldValue(fieldEnum: otherField) ==
        getPayoutAccountFieldValue(fieldEnum: entry.key);
    if (!isValid) {
      showSnackBar(label_error_mismatch.trParams({
        'fieldOne': entry.value.title.tr.toLowerCase(),
        'fieldTwo': otherField.title.tr.toLowerCase()
      }));
    }
    return isValid;
  }


  String getPayoutAccountFieldValue({required PayoutAccountDetailsEnum fieldEnum}) {
    return payoutAccountDetailsMap[fieldEnum]?.customTextEditingController.text.trim() ?? "";
  }

   void hideDefaultFieldCountryBased() {
    payoutAccountDetailsMap.remove(PayoutAccountDetailsEnum.sortNumber);
    payoutAccountDetailsMap.remove(PayoutAccountDetailsEnum.iBANNumber);
    payoutAccountDetailsMap.remove(PayoutAccountDetailsEnum.confirmIBANNumber);
  }

  void hideFieldOnAccountTypeCountryBased(String selectedAccountType) {
    if(selectedAccountType == label_payout_type_individual){
      payoutAccountDetailsMap.remove(PayoutAccountDetailsEnum.companyName);
    }else{
      payoutAccountDetailsMap.remove(PayoutAccountDetailsEnum.firstName);
      payoutAccountDetailsMap.remove(PayoutAccountDetailsEnum.lastName);
    }
  }
}

enum PayoutAccountDetailsEnum {
  accountType(title: label_payout_account_type,disableEnum: CountryBasedEnum.allCountries),
  firstName(title: label_first_name,disableEnum: CountryBasedEnum.allCountries),
  lastName(title: label_last_name,disableEnum: CountryBasedEnum.allCountries),
  companyName(title: label_payout_company_name,disableEnum: CountryBasedEnum.allCountries),
  routingNumber(title: label_payout_routing_number,disableEnum:CountryBasedEnum.routingNumberDisableCountries),
  sortNumber(title: label_sort_number,disableEnum:CountryBasedEnum.sortNumberDisableCountries),
  accountNumber(title: label_payout_account_number,disableEnum: CountryBasedEnum.accountNumberDisableCountries),
  confirmAccountNumber(title: label_payout_confirm_account_number,disableEnum: CountryBasedEnum.accountNumberDisableCountries),
  iBANNumber(title: label_payout_iban_number,disableEnum: CountryBasedEnum.europeCountries),
  confirmIBANNumber(title: label_payout_confirm_iban_number,disableEnum: CountryBasedEnum.europeCountries);

  final String title;
  final CountryBasedEnum disableEnum;
  const PayoutAccountDetailsEnum({required this.title,required this.disableEnum});
}



enum CountryBasedEnum {
  europeCountries(disableCountryList: ['US','MX',...sortNumberList]),
  routingNumberDisableCountries(disableCountryList: ['MX',...europeCountriesList,...sortNumberList]),
  sortNumberDisableCountries(disableCountryList: ['MX',...europeCountriesList]),
  accountNumberDisableCountries(disableCountryList: europeCountriesList),
  allCountries(disableCountryList: []);
  final List disableCountryList;
  const CountryBasedEnum({required this.disableCountryList});
}



const List europeCountriesList = [
  'AT', 'BE', 'BG', 'CY', 'CZ', 'DK', 'EE',
  'FI', 'FR', 'DE', 'GR', 'HU', 'IE', 'IT',
  'LV', 'LT', 'LU', 'MT', 'NL', 'NO', 'PL',
  'PT', 'RO', 'SK', 'SI', 'ES', 'SE', 'CH',
  'CR', 'AE'
];

const List sortNumberList = ['GB'];