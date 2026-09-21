part of '../payout_preference_controller.dart';

mixin PayoutCountrySearchMixin on ProfileController {
  CustomTextEditingController countrySearchController = CustomTextEditingController();
  CustomTextEditingController countryController = CustomTextEditingController();
  RxBool isUpdateSelectedItem = false.obs;
  String selectedCountryCode = '';
  List<dynamic> countriesList = [];

  void getCountyList(){
    countriesList = List.from(countriesData?.getCountries?.results?.asList() ?? []);
    countriesData!.getCountries!.results!.asList().forEach((element) {
      if(element!.countryName == countryController.text){
        countriesList.remove(element);
        countriesList.insert(0, element);
      }
    });
    isUpdateSelectedItem.refresh();
  }

  void setCountryData(var item) {
    countryController.text = item.countryName;
    selectedCountryCode = item.countryCode;
  }
}