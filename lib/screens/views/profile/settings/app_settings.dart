import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/app.dart';
import 'package:gozy/app_localizations.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/resources/app_layout.dart';
import 'package:gozy/screens/binding/main_binding.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/screens/views/home/home_page.dart';
import 'package:gozy/screens/views/profile/profile_navigator.dart';
import 'package:gozy/screens/views/profile/settings/app_settings_controller.dart';
import 'package:gozy/widgets/common/custom_bottomsheet/custom_draggable_bottomsheet.dart';
import 'package:gozy/widgets/common/custom_bottomsheet/custom_getx_bottomsheet.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_stateful_widget.dart';
import 'package:gozy/widgets/owner/step_item_model.dart';

import '../../../../config/client.dart';
import '../../../../resources/app_dimen.dart';
import '../../../../widgets/custom_list_item.dart';
import '../../base_controller.dart';

class AppSettings extends CustomStatefulWidget {
  const AppSettings({super.key});

  @override
  AppSettingsState createState() => AppSettingsState();
}

class AppSettingsState extends CustomStatefulWidgetState<AppSettings> with TickerProviderStateMixin {
  AppSettingsController controller = Get.find();
  String? changePassword;
  String? _languageIcon;
  String? _currencyIcon;
  String? _themeIcon;
  String _selectedCurrency = '', _selectedLanguage = '', _selectedTheme = '', _selectedType = '';
  int _isSettingUpdate = 0;
  double? _borderRadius, horizontalpadding = 0;

  static AppLayoutModel? profilelayout = appLayoutMap[AppLayout.profile];

  @override
  void initState() {
    controller.checkNetwork(controller.getCurrenciesList);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _initThemeData();
    return CustomScaffold(
        controller: controller,
        isShowAppBar: false,
        customAppBarFunction: () {
          if (_isSettingUpdate == 1) {
            Get.to(() => HomePage(),
                binding: MainBinding(isDisableClearController: true),
                arguments: {"isFromProfile": true},
                routeName: "/guestHomePage");
          } else {
            onBack();
          }
        },
        isShowBGOnLoader: false,
        loader: LottieLoaders.three_dots_loader,
        body: showBodyContent(context));
  }

  Widget showBodyContent(context) {
    print("IsPassWordshow ---> ${appPreference.type == 'email'}");
    String userlang = appPreference.preferredLanguage ?? defaultLanguage;
    String lang = App().localizationService.languageList[userlang] ?? 'English';

    AppLayoutModel? appLayoutModel = (profilelayout ?? overALLAppLayoutModel);

    String thememode = controller.appPreference.appTheme == 'auto'
        ? label_auto_theme.tr
        : controller.appPreference.appTheme == 'light'
            ? label_light_theme.tr
            : label_dark_theme.tr;
    return [
      getBackIconWidget(
        themeType: appLayoutModel!.themeType,
        backIcon: profilelayout!.backIcon,
        size: AppDimen.backIconSize,
        margin: pad(top: 15, end: 13, start: AppDimen.startMargin - 2, bottom: 13),
        onTap: () {
          if (_isSettingUpdate == 1) {
            Get.to(() => HomePage(),
                binding: MainBinding(isDisableClearController: true),
                arguments: {"isFromProfile": true},
                routeName: "/guestHomePage");
          } else {
            onBack();
          }
        },
      ),
      CustomTitleText(
        text: settings.tr,
        size: AppDimen.textSize_22,
        fontWeight: AppFont.semiBold,
      ).toPad(start: 25, bottom: 18),
      Visibility(
        visible: appPreference.type == 'email',
        child: getNavigationBar(
          title: label_change_password.tr,
          padding: appLayoutMap[AppLayout.profile]?.themeType == 3 ? pad(start: 10, end: 7, h: 7) : null,
          isResize: true,
          horizontalpadding: horizontalpadding,
          borderRadius: _borderRadius,
          leadingIcon: changePassword,
          onTap: () {
            controller.profileNavigator?.navigateScreen(
              ProfileScreen.changePassword,
              '',
            );
          },
          applayoutModel: appLayoutModel,
        ),
      ),
      getNavigationBar(
        title: label_languages.tr,
        leadingIcon: _languageIcon,
        borderRadius: _borderRadius,
        horizontalpadding: horizontalpadding,
        applayoutModel: appLayoutModel,
        trailIconColor: appColors.secondaryColor,
        trailingText: lang,
        onTap: () {
          GetXBottomSheet(
            bottomSheetWidget: getDraggableSheetWidget(
                controller: controller,
                listItems: LocalizationService.languageModelList,
                themeType: profilelayout?.themeType,
                selectedValue: appPreference.preferredLanguage,
                isShowCircleTick: true,
                borderRadius: profilelayout?.borderRadius,
                title: label_choose_language.tr,
                onItemSelected: (value) async {
                  debugPrint("showDraggableSheet selected lang: $value --- ${value.itemValue}");
                  controller.isLoading.value = true;
                  controller.checkNetwork(() async {
                  await _downloadLang(langcode: value.itemValue ?? defaultLanguage, isUpdate: false);
                    _changeUserSettings(type: label_languages.tr, selectedValue: value.itemValue);
                  });
                }),
          );
        },
      ),
      GetBuilder<AppSettingsController>(builder: (newController) {
        String currency = "${controller.getCurrencySymbol()} ${controller.appPreference.preferredCurrency}";
        return getNavigationBar(
            title: label_currency.tr,
            leadingIcon: _currencyIcon,
            isResize: true,
            horizontalpadding: horizontalpadding,
            borderRadius: _borderRadius,
            trailingText: currency,
            applayoutModel: appLayoutModel,
            isCurrencySymbolNeeded: false,
            trailIconColor: appColors.secondaryColor,
            onTap: () {
              if (controller.listOfCurrencies?.isNotEmpty ?? false) {
                _changeCurrency();
              } else {
                controller.checkNetwork(controller.getCurrenciesList);
              }
            });
      }),
      getNavigationBar(
          title: label_theme.tr,
          borderRadius: _borderRadius,
          applayoutModel: appLayoutModel,
          leadingIcon: _themeIcon,
          horizontalpadding: horizontalpadding,
          isShowItemDivider: false,
          trailingText: thememode,
          trailIconColor: appColors.secondaryColor,
          onTap: () {
            List<dynamic> themearraylist = [];
            Map<String, String> themeMap = {
              label_auto_theme: Assets.drawableSettingsThemeAuto,
              label_light_theme: Assets.drawableSettingsTheme,
              label_dark_theme: Assets.drawableSettingsThemeDark
            };

            themeMap.forEach((key, value) {
              StepItemModel stepItemModel = StepItemModel(
                  itemValue: key.getParticularLangContent().toString().toLowerCase(),
                  itemName: key.tr,
                  image: value);
              themearraylist.add(stepItemModel);
            });
            GetXBottomSheet(
              bottomSheetWidget: getDraggableSheetWidget(
                  controller: controller,
                  listItems: themearraylist,
                  isAppImage: true,
                  borderRadius: profilelayout?.borderRadius,
                  themeType: profilelayout?.themeType,
                  selectedValue: appPreference.appTheme,
                  isShowCircleTick: true,
                  title: label_choose_theme.tr,
                  onItemSelected: (value) {
                    String themeType = themeValue(type: value.itemValue);
                    controller.checkNetwork(() {
                      _changeUserSettings(type: label_theme.tr, selectedValue: themeType,themeType: value.itemValue);
                    });
                  }),
            );
          }),
    ].toColumn(crossAxisAlignment: CrossAxisAlignment.start).toResizeWidget(isDeviceFit: true);
  }
  String themeValue({required String type}) {
    switch (type) {
      case label_auto_theme:
        return "auto";

      case label_light_theme:
        return "light";

      default:
        return "dark";
    }
  }

  void _changeUserSettings({required String type, required String selectedValue, String? themeType}) {
    _selectedType = type;
    final currencyLabel = label_currency.tr;
    final languageLabel = label_languages.tr;
    final themeLabel = label_theme.tr;

    switch (_selectedType) {
      case var type when type == currencyLabel:
        _selectedCurrency = selectedValue;
        controller.fieldName = 'preferredCurrency';
        controller.fieldValue = _selectedCurrency;

      case var type when type == languageLabel:
        _selectedLanguage = selectedValue;
        controller.fieldName = 'preferredLanguage';
        controller.fieldValue = _selectedLanguage;

      case var type when type == themeLabel:
        _selectedTheme = selectedValue;
        appThemeChanged.value = true;
        controller.appPreference.appTheme = _selectedTheme;
        controller.fieldName = 'appTheme';
        controller.fieldValue = _selectedTheme;
        didChangePlatformBrightness();
    }
    debugPrint("Get.isBottomSheetOpen: ${Get.isBottomSheetOpen}");

    _isSettingUpdate = 1;
    controller.checkNetwork(controller.userUpdate);
  }

  void _changeCurrency() {
    GetXBottomSheet(
      bottomSheetWidget: getDraggableSheetWidget(
          controller: controller,
          listItems: controller.listOfCurrencies,
          borderRadius: profilelayout?.borderRadius,
          themeType: profilelayout?.themeType,
          selectedValue: appPreference.preferredCurrency,
          isShowCircleTick: true,
          title: label_choose_currency.tr,
          onItemSelected: (value) {
            debugPrint("showDraggableSheet selected currency: $value --- ${value.itemValue}");
            controller.checkNetwork(() {
              _changeUserSettings(type: label_currency.tr, selectedValue: value.itemValue);
            });
          }),
    );
  }

  _downloadLang({required String langcode, required bool isUpdate}) async {
    controller.isLangDownloading.value = "";
    bool isNetconnected = await controller.isNetworkConnected();
    if (isNetconnected) {
      await LocalizationService.readJson(language: langcode, isUpdate: isUpdate);
      Get.forceAppUpdate();
    }
    controller.isLangDownloading.value = "";
  }

  void _initThemeData() {
    _languageIcon = Assets.drawableSettingsLanguages;
    _themeIcon = Assets.drawableSettingsTheme;
    switch (profilelayout?.themeType) {
      case 1:
        changePassword = Assets.drawableSettingsChangePassword;
        _currencyIcon = Assets.drawableSettingsCurrency;
        _borderRadius = 12;
      case 2:
        changePassword = Assets.settingsiconTheme2Password;
        _languageIcon = Assets.settingsiconTheme2Language;
        _currencyIcon = Assets.settingsiconTheme2Currency;
      case 3:
        _languageIcon = null;
        _themeIcon = null;
      case 4:
        horizontalpadding = null;
        changePassword = Assets.settingsiconTheme4Password;
        _currencyIcon = Assets.settingsiconTheme4Currency;
    }
  }
}