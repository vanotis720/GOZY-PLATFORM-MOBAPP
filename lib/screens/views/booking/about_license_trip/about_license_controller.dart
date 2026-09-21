import 'dart:async';

import 'package:get/get.dart';
import 'package:gozy/config/client.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/graphql/getCountries/__generated__/getcountries.data.gql.dart';
import 'package:gozy/graphql/getCountries/__generated__/getcountries.req.gql.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common_extension_functions.dart';

import '../../../../utils/text_editing_controller.dart';

class AboutLicenseController extends BaseController{

  CustomTextEditingController licenceNumberController = CustomTextEditingController();
  CustomTextEditingController firstNameController = CustomTextEditingController();
  CustomTextEditingController lastNameController = CustomTextEditingController();
  CustomTextEditingController dobController = CustomTextEditingController();
  CustomTextEditingController countryController = CustomTextEditingController();
  CustomTextEditingController countrySearchController = CustomTextEditingController();
  CustomTextEditingController aboutTripTextController = CustomTextEditingController();
  List<GgetCountriesData_getCountries_results?> countries = [];
  String selectedCountryCode = "";
  RxBool isUpdateSelectedItem = false.obs;
  DateTime? initialDobDate;

  Future<GgetCountriesData> getCountries(){
    Completer<GgetCountriesData> currencyrateCompleter = Completer<GgetCountriesData>();
    try{
      final params = GgetCountriesReq((b) => b
        ..vars.build());
      FerryLoggerClient.makeRequest(params,this, getCountries, isViewLoader: isShowLoader, isStartLoader: false)?.then((res) {
        countriesData = res.data as GgetCountriesData;
        currencyrateCompleter.complete(countriesData);
      });
    }catch(e){
      print("error data ---> ${e.toString()}");
    }
    return currencyrateCompleter.future;
  }

  bool fieldValidator({String isFrom = ""}){
    Map<String, bool> result = {};
    switch(isFrom) {
      case "about_license":
        result = {
          error_msg_empty.trParams({"field" : label_licence_no.tr.toLowerCase()}) : licenceNumberController.text.isEmpty,
          error_msg_empty.trParams({"field" : label_first_name.tr.toLowerCase()}) : firstNameController.text.isEmpty,
          error_msg_empty.trParams({"field" : label_last_name.tr.toLowerCase()}) : lastNameController.text.isEmpty,
          error_msg_empty.trParams({"field" : label_birthday.tr.toLowerCase()}) : dobController.text.isEmpty,
          label_please_select_country.tr : countryController.text.isEmpty,
        };
        break;
      default:
        result = {
          error_msg_empty.trParams({"field" : label_message.tr.toLowerCase()}) : aboutTripTextController.text.isEmpty,
        };
        break;
    }
    bool isValidate = result.isValidate(controller: this);
    return isValidate;
  }

  bool isProfilePhotoUploaded(){
    return (appPreference.profileImage ?? '').isNotEmpty;
  }


}