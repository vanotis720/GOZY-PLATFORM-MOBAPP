import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:gozy/constant.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/utils/text_editing_controller.dart';

import '../../../../resources/app_lang.dart';

class GenerateWithAIListingsController extends BaseController {
  RxBool isGenerated = false.obs;
  RxString titleContent = "".obs;
  int selectedIndex = -1;
  int minPrice = -1;
  int maxPrice = -1;
  RxString descriptionContent = "".obs;
  String location = "";
  String carDetails = "";
  String carType = "";
  String language = "";
  String carFeatures = "";
  RxBool isLocationChecked = false.obs;
  RxBool isCarDetailsChecked = true.obs;
  RxBool isCarFeaturesChecked = true.obs;
  RxBool isTitleCheck = false.obs;
  RxBool isDescriptionCheck = false.obs;
  String selectedCurrency = defaultCurrency;
  CustomTextEditingController chooseTargetRenterController = CustomTextEditingController();

  Future<String> getAIMessage(
      {String tripStart = "",
      String tripEnd = "",
      String content = "",
      String reasonForRental = "",
      String hostName = "",
      String type = ""}) async {
    // Show standard full-screen Lottie loader
    isShowLoader = true;
    isLoading.value = true;

    try {
      Map<String, String> headers = {
        "auth": appPreference.accessToken ?? "",
        "Content-Type": "application/json"
      };
      Map<String, dynamic> body = {
        "carType": isCarDetailsChecked.value ? "" : carType,
        "carFeatures": isCarFeaturesChecked.value ? "" : carFeatures,
        "location": location,
        "language": language,
        "targetedGuests": chooseTargetRenterController.text,
        "platformSecretKey": securityKey
      };
      final encodedBody = jsonEncode(body);
      debugPrint("This requested data ---> ${encodedBody.toString()}");

      final response =
          await http.post(Uri.parse(getCarTitleDescription), headers: headers, body: encodedBody);
      Map<String, dynamic> result = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (result["status"] == 200 && result["response"] != null) {
          isGenerated.value = true;
          titleContent.value = result["response"]["title"] ?? "";
          descriptionContent.value = result["response"]["description"] ?? "";
          isTitleCheck.value = true;
          isDescriptionCheck.value = true;
          return "";
        } else {
          return result["errorMessage"]["error"]["message"];
        }
      } else {
        return error_msg_oops_something_went_wrong_pls_try_again.tr;
      }
    } catch (e) {
      debugPrint("getAIMessage error: $e");
      return error_msg_oops_something_went_wrong_pls_try_again.tr;
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> getBasePrice(
      {String? location,
      String? carType,
      List<String>? carFeatures,
      String? make,
      String? model,
      String? currency,
      String? year}) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "auth": appPreference.accessToken ?? ""
    };
    Map<String, dynamic> body = {
      "location": location,
      "carType": carType,
      "carFeatures": carFeatures,
      "make": make,
      "model": model,
      "year": year,
      "language": appPreference.preferredLanguage,
      "currency": currency,
      "platformSecretKey": securityKey
    };
    final encodedBody = jsonEncode(body);
    print("response:::${encodedBody}");
    final response =
        await http.post(Uri.parse(getCarSuggestedRentPrice), headers: headers, body: encodedBody);
    Map<String, dynamic> result = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (result["status"] == 200 && result["response"] != null) {
        minPrice = result["response"]["min_price"] ?? 0;
        maxPrice = result["response"]["max_price"] ?? 0;
        return "";
      } else {
        return result["errorMessage"]["error"]["message"];
      }
    } else {
      return error_msg_oops_something_went_wrong_pls_try_again.tr;
    }
  }
  void resetData() {
    isGenerated.value = false;
    titleContent.value = "";
    descriptionContent.value = "";
    carFeatures = "";
    isLocationChecked.value = false;
    isCarDetailsChecked.value = true;
    isCarFeaturesChecked.value = true;
    isTitleCheck.value = false;
    isDescriptionCheck.value = false;
    chooseTargetRenterController.text = "All";
    isLoading.value = false;
  }
}