import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/owner/step_one/step_one_controller.dart';
import 'package:gozy/widgets/common/custom_bottomsheet/custom_getx_bottomsheet.dart';
import 'package:gozy/widgets/common/custom_textfield/custom_prefix_textfield.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_text.dart';

import '../../../config/client.dart';
import 'package:gozy/generated/assets.dart';
import '../../../resources/app_layout.dart';
import '../../../screens/views/base_controller.dart';
import '../../../screens/views/custom_scaffold.dart';
import '../../custom_textfield.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;


@immutable
class PropertyPlaceEntryView extends GetView {
  @override
  final StepOneController controller;
 final CustomFocusNode _streetFocusNode = CustomFocusNode();
 final CustomFocusNode _aptSuiteBuildingsFocusNode = CustomFocusNode();
  final CustomFocusNode _cityFocusNode = CustomFocusNode();
  final CustomFocusNode _stateFocusNode = CustomFocusNode();
  final CustomFocusNode _zipcodeFocusNode = CustomFocusNode();
  var focusNodeList = <CustomFocusNode>[];

   PropertyPlaceEntryView({super.key,
    required this.controller,
  });



  @override
  Widget build(BuildContext context) {
    focusNodeList = [_streetFocusNode,_aptSuiteBuildingsFocusNode,_cityFocusNode,_stateFocusNode,_zipcodeFocusNode];
    focusNodeList.toAddListener();
    debugPrint('step1rebuild PropertyPlaceEntryView ');
    List<Widget> listwidgets =  [
      AppDimen.startMargin.toHeight(),
      _showCountrySelectionWidget(),
      _showStreetEntryWidget(),
      _showAptSuiteBuildingsEntryWidget(),
      _showCityEntryWidget(),
      _showStateEntryWidget(),
      _showZipCodeEntryWidget(),
      (bottomViewPadding+15).toHeight(),
    ];
    return toListView(
        key:  const PageStorageKey<String>('step1placeentry'),
      itemCount: listwidgets.length,
        itemBuilder: (context, index) {
      return listwidgets[index];
    });
  }

 Widget _showStreetEntryWidget() {
  return  TitleTextField(
      title: label_steet.tr,
      controller: controller.streetController,
      borderTextfieldPadding: appLayoutMap[AppLayout.inputType]?.themeType == 4 ? EdgeInsets.zero : null,
      keyboardType: TextInputType.name,
      focusNode: _streetFocusNode,
      characterlength:  35,
      hintText: '${label_example.tr} ${label_main_street.tr}',
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.done,
    ).toPad(bottom: 16);
  }

  Widget _showAptSuiteBuildingsEntryWidget() {
    return  TitleTextField(
      title: label_apt_suite_building_optional.tr,
      borderTextfieldPadding: appLayoutMap[AppLayout.inputType]?.themeType == 4 ? EdgeInsets.zero : null,
      controller: controller.aptBuildingController,
      keyboardType: TextInputType.name,
      focusNode: _aptSuiteBuildingsFocusNode,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.done,
    ).toPad(bottom: 16);
  }

  Widget _showCityEntryWidget() {
    return  TitleTextField(
      title: label_city.tr,
      borderTextfieldPadding: appLayoutMap[AppLayout.inputType]?.themeType == 4 ? EdgeInsets.zero : null,
      controller: controller.cityController,
      keyboardType: TextInputType.name,
      characterlength:  75,
      focusNode: _cityFocusNode,
      hintText: '${label_example.tr} ${label_example_state.tr}',
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.done,
    ).toPad(bottom: 16);
  }

 Widget _showStateEntryWidget() {
   return  TitleTextField(
     title: label_state_province.tr,
     borderTextfieldPadding: appLayoutMap[AppLayout.inputType]?.themeType == 4 ? EdgeInsets.zero : null,
     controller: controller.stateProvinceController,
     keyboardType: TextInputType.name,
     focusNode: _stateFocusNode,
     characterlength:  75,
     hintText: '${label_example.tr} ${label_example_city.tr}',
     textCapitalization: TextCapitalization.sentences,
     textInputAction: TextInputAction.done,
   ).toPad(bottom: 16);
 }

 Widget _showZipCodeEntryWidget() {
   return  TitleTextField(
     title: label_zip_code.tr,
     borderTextfieldPadding: appLayoutMap[AppLayout.inputType]?.themeType == 4 ? EdgeInsets.zero : null,
     controller: controller.zipCodeController,
     keyboardType: TextInputType.name,
     focusNode: _zipcodeFocusNode,
     characterlength:  25,
     hintText: zipCodeHint,
     textCapitalization: TextCapitalization.sentences,
     textInputAction: TextInputAction.done,
   ).toPad(bottom: 16);
 }

 Widget _showCountrySelectionWidget() {
    return  TitleTextField(
        title: label_country_region.tr,
        borderTextfieldPadding: appLayoutMap[AppLayout.inputType]?.themeType == 4 ? EdgeInsets.zero : null,
        controller: controller.countryController,
        keyboardType: TextInputType.name,
        enabled: false,
        characterlength:  75,
        textCapitalization: TextCapitalization.sentences,
        suffixIcon:  Assets.drawableFilterCalendarArrow,
        suffixIconQuarterTurns: 3,
        textInputAction: TextInputAction.next,
        onTap: (){
          controller.countrySearchController.clear();
          FocusManager.instance.primaryFocus!.unfocus();
          GetXBottomSheet(
            bottomSheetWidget: _showCountrySelectionListWidget(),
          );
        },
        onSubmitted: (value){}
    ).toPad(bottom: 16);
  }

  Obx _showCountrySelectionListWidget() {
List<dynamic> countrieslist = List.from(countriesData!.getCountries!.results!.asList());
countriesData!.getCountries!.results!.asList().forEach((element) {

  if(element!.countryName == controller.countryController.text){
    countrieslist.remove(element);
    countrieslist.insert(0, element);
  }
});

return Obx(() {
  debugPrint('controller.countrySearchController: ${controller.isUpdateSelectedItem.value}');
  List<Widget> countryListWidget = [];
  for (final (index, item) in countrieslist.indexed) {
   if( (((controller.countrySearchController.Ttext.isNotEmpty &&
       normalizeSpaces(item.countryName).toLowerCase().contains(normalizeSpaces(controller.countrySearchController.Ttext).toLowerCase())) || controller.countrySearchController.Ttext.isEmpty)  &&  item.isEnable )) {
     Widget widget = toOnTap(
       onTap: () {
         controller.countryController.text = item.countryName;
         controller.selectedCountrycode = item.countryCode;
         Get.back();
       },
       child: [
         [
           CustomText(text: item.countryName,
             color: controller.countryController.text == item.countryName
                 ? appColors.secondaryColor
                 : appColors.customTextColor,).toStretch(),
           if(controller.countryController.text == item.countryName)
             Assets.drawableTickIcon.toSVG(
                 size: 20)
         ].toRow(),
         if(index < (countrieslist.length ?? 1) - 1)
           filterDivider.toPad(vertical: 15)
       ].toColumn(),
     );
     countryListWidget.add(widget);
   }
  }

  debugPrint('countryListWidget: ${countryListWidget.length}');
  return [
    Align(
      alignment: AlignmentDirectional.centerEnd,
        child: getBackIconWidget(backIcon: Assets.drawableSignupClose,clickableSize: 50,margin: EdgeInsets.zero)),

    20.toHeight(),
    _showCountrySearchEntryWidget(),
    if(countryListWidget.isNotEmpty)
    countryListWidget.toScroll(padding: pad(bottom: 20 + bottomViewPadding)).toStretch()
    else
      Center(child: CustomText(text: empty_label_no_results_found.tr)).toStretch()


  ].toColumn().toPad(horizontal: AppDimen.startMargin, top: topViewPadding + 10).toResizeWidget(color: appColors.white);
});
  }

 Widget _showCountrySearchEntryWidget(){

    return  CustomPrefixTextField(
        controller: controller.countrySearchController,
        keyboardType: TextInputType.name,
        characterlength:  25,
        prefixIcon: Assets.drawableSearch,
        hintText: '${label_search_for.tr} ${label_country_region.tr}',
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.done,
        onChanged: (string){
          controller.isUpdateSelectedItem.value = !controller.isUpdateSelectedItem.value;
        },
        onSubmitted: (value){

        }
    ).toPad(bottom: 16);
  }

  String normalizeSpaces(String input) {
    return input.replaceAll(RegExp(r'\s+'), ' ');
  }

  Future<bool> setValidation() async {
    String value = '';
    Map<String,bool> results =  {
      error_msg_empty.trParams({'field':label_country_region.tr.toLowerCase()}) :  controller.countryController.Ttext.isEmpty,
      error_msg_empty.trParams({'field':label_steet.tr.toLowerCase()}) :  controller.streetController.Ttext.isEmpty,
      error_msg_empty.trParams({'field':label_city.tr.toLowerCase()}) :  controller.cityController.Ttext.isEmpty ,
      error_msg_empty.trParams({'field':label_state_province.tr.toLowerCase()}) :  controller.stateProvinceController.Ttext.isEmpty ,
      error_msg_empty.trParams({'field':label_zip_code.tr.toLowerCase()}) :  controller.zipCodeController.Ttext.isEmpty ,
    };
    bool validate = results.isValidate(controller: controller);
    debugPrint("ismoveto next: $validate---${controller.apiCountryZipcode} ----${controller.cityController.Ttext}");
    if(validate) {
      controller.isFromAddressPage = true;
      if(controller.apiCountryZipcode == '${controller.selectedCountrycode}_${controller.zipCodeController.Ttext}'){
        value = 'success';
      }
      else {
        value = await getLatLngFromAddress();
      }
      if (value == 'error') {
        controller.showSnackBar(error_msg_zipcode_country_not_relevant.tr, isltralign: true);
      }
      else if (value == 'success') {
        if(controller.itemInfo ==null) {
          controller.isLoading.value = true;
          controller.checkNetwork(controller.createListingStepOne);
        }
      }else if (value.isNotEmpty) {
        controller.showSnackBar(value, isltralign: true);
      }
    }
    return validate && value == 'success';
  }

  Future<String> getLatLngFromAddress() async {
    controller.isLoading.value = true;

    dynamic json;

    String address ='${controller.streetController.Ttext}, ${controller.cityController.Ttext}, ${controller.stateProvinceController.Ttext}, ${controller.zipCodeController.Ttext}';
    String countrypostal = address.replaceAll(', ', '_').toLowerCase();
    bool isNewPostalCode = !appPreference.bookingPostalCodeAddresses.containsKey(countrypostal);
    String autoCompleteUrl = "$GRAPHQL_DOMAIN/get_geocode_data";
    var headers={
      "Content-Type":"application/json"
    };
    var input={
      "address":address,
      "platformSecretKey": securityKey
    };
    var response = await http.post(Uri.parse(autoCompleteUrl), headers: headers, body: convert.jsonEncode(input));
    json = convert.jsonDecode(response.body);
    debugPrint("autoCompleteUrl: $autoCompleteUrl");

    if(json["status"] == 200) {
      controller.isLoading.value = false;
      if (json["response"]['status'] == 'OK') {
        debugPrint("prediction list: ${json["response"]['results']}");
        controller.addressLatLng = LatLng(json["response"]['results'][0]['geometry']['location']['lat'], json["response"]['results'][0]['geometry']['location']['lng']);
        if(isNewPostalCode) {
          Map<String, dynamic> map = appPreference.bookingPostalCodeAddresses;
          map[countrypostal] = json;
          appPreference.bookingPostalCodeAddresses = map;
        }
        return 'success';
      }
      else if (json["response"]['status'] == 'ZERO_RESULTS') {
        if(isNewPostalCode) {
          Map<String, dynamic> map = appPreference.bookingPostalCodeAddresses;
          map[countrypostal] = json;
          appPreference.bookingPostalCodeAddresses = map;
        }
        return 'error';
      }else if(json["response"]['status'] == 'OVER_QUERY_LIMIT'){
        debugPrint("prediction list: ${json["response"]['error_message']}");
       return json["response"]['error_message'];
      }else{
        return json["response"]['error_message'];
      }
    } else{
      controller.isLoading.value = false;
      return json.containsKey("errorMessage") ? json["errorMessage"] : '';
    }
  }

  bool getFocusStatus() {
    return focusNodeList.toFocus(textControllerList: [controller.streetController, controller.aptBuildingController,controller.cityController,controller.stateProvinceController,controller.zipCodeController]);
  }
}