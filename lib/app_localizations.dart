import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/pref/app_preference.dart';
import 'package:gozy/widgets/owner/step_item_model.dart';

import 'app.dart';
import 'config/client.dart';
import 'constant.dart';

class LocalizationService extends Translations {
  static List<StepItemModel> languageModelList = [];
  static String? currentLanguageName;
  final Map<String, String> languageList = {};

  @override
  Map<String, Map<String, String>> get keys => {};

  LocalizationService() {
    _downloadAssets();
  }

  Future _downloadAssets() async {
    Get.clearTranslations();
    var keys = await readJson(language: appPreference.preferredLanguage ?? defaultLanguage, isUpdate: true);
    Get.addTranslations(keys);
  }

  static Future<Map<String, Map<String, String>>> readJson(
      {required String language, bool isUpdate = false}) async {
    debugPrint("languageModelList--> ${languageModelList}");
    if(languageModelList.isEmpty) return {};
    StepItemModel stepItemModel = languageModelList.singleWhere((element) {
      return element.itemValue == language;
    });
    File file = await App()
        .getDownloadedFile(url: stepItemModel.itemReference ?? "", isUpdate: isUpdate, lang: language);
    String filecontent = await file.readAsString();
    final keys = Map<String, Map<String, String>>();
    Map<String, String> langmap = Map.castFrom(json.decode(filecontent));
    keys.addAll({language: langmap});
    Get.addTranslations(keys);
    return keys;
  }

  static changeLocale({required String languageCode}) {
    debugPrint("changeLocale: ${languageCode}--${appPreference.preferredLanguage}");
    setUserLangToLangList();
    Get.updateLocale(Locale(languageCode, ''));
    App().getTargetedGuestLabels();
    App().getReasonBooking();
  }

  static setUserLangToLangList() {
    if (LocalizationService.languageModelList.isNotEmpty) {
      AppPreference appPreference = Get.find();
      if (LocalizationService.languageModelList.first.itemValue != appPreference.preferredLanguage) {
        StepItemModel? selectedItem;
        LocalizationService.languageModelList.forEach((itemModel) {
          if (itemModel.itemValue == appPreference.preferredLanguage) {
            selectedItem = itemModel;
          }
        });
        if (selectedItem != null) {
          LocalizationService.languageModelList.remove(selectedItem!);
          LocalizationService.languageModelList.insert(0, selectedItem!);
          currentLanguageName = selectedItem!.itemName;
        }
      }
    }
  }
}

class FallbackLocalizationDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) async => DefaultMaterialLocalizations();

  @override
  bool shouldReload(_) => false;
}