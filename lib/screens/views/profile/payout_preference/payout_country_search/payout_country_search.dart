import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/resources/app_layout.dart';
import 'package:gozy/screens/views/profile/payout_preference/payout_preference_navigator.dart';
import 'package:gozy/utils/common_api_controller.dart';
import 'package:gozy/widgets/common/custom_textfield/custom_prefix_textfield.dart';

import '../../../../../constant.dart';
import '../../../../../generated/assets.dart';
import '../../../../../resources/app_dimen.dart';
import '../../../../../resources/app_lang.dart';
import '../../../../../utils/text_editing_controller.dart';
import '../../../../../widgets/common_extension_functions.dart';
import '../../../../../widgets/custom_stateful_widget.dart';
import '../../../../../widgets/custom_text.dart';
import '../../../base_controller.dart';
import '../../../custom_scaffold.dart';
import '../payout_preference_controller.dart';

class PayoutCountrySearch extends CustomStatefulWidget {
  const PayoutCountrySearch({super.key});

  @override
  PayoutCountrySearchState createState() => PayoutCountrySearchState();
}

class PayoutCountrySearchState
    extends CustomStatefulWidgetState<PayoutCountrySearch>
    with TickerProviderStateMixin {
  PayoutPreferenceController controller = Get.find();
  static AppLayoutModel? profile = appLayoutMap[AppLayout.profile];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (countriesData == null) {
        controller.isLoading.value = true;
        controller.getCountries().then((value) {
          controller.getCountyList();
          controller.isLoading.value = false;
        });
      }else{
        controller.getCountyList();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.countrySearchController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        controller: controller,
        isShowAppBar: false,
        backgroundColor: appColors.white,
        isShowBGOnLoader: false,
        loader: LottieLoaders.three_dots_loader,
        backIconWidget:
            getBackIconWidget(iconBGColor: appColors.explore_search_icon_bg),
        body: showBodyContent(context));
  }

  Widget showBodyContent(context) {
    return Obx(() {
      debugPrint('controller.countrySearchController: ${controller.isUpdateSelectedItem.value}');
      List<Widget> countryListWidget = [];
      for (final (index, item) in controller.countriesList.indexed) {
        if ((((controller.countrySearchController.Ttext.isNotEmpty &&
                    item.countryName.toString().toNormalizeSpaces().toLowerCase().contains(
                                controller.countrySearchController.Ttext.toNormalizeSpaces()
                            .toLowerCase())) ||
                controller.countrySearchController.Ttext.isEmpty) &&
            item.isEnable)) {
          Widget widget = toOnTap(
            onTap: () async {
              controller.setCountryData(item);
              onBack();
              changeAddressFieldCountryName(item);
              controller.payoutPreferenceNavigator?.navigateScreen(PayoutPreferenceScreen.payoutAddressDetails);
            },
            child: [
              [
              CustomText(text: item.countryName,
                color: controller.countryController.text == item.countryName
                    ? appColors.secondaryColor
                    : appColors.customTextColor,).toStretch(),
              if(controller.countryController.text == item.countryName)
                Assets.drawableViewdetailReportTick.toSVG(
                    size: 10, colour: appColors.secondaryColor),
              ].toRow(),
              if (index < (controller.countriesList.length ?? 1) - 1)
                filterDivider.toPad(vertical: 15)
            ].toColumn(),
          );
          countryListWidget.add(widget);
        }
      }

      return [
        Align(
            alignment: AlignmentDirectional.centerStart,
            child: getBackIconWidget(
                backIcon: Assets.drawableSignupClose,
                clickableSize: 50,
                themeType: overALLThemeType,
                margin: EdgeInsets.zero)),
        20.toHeight(),
        _showCountrySearchEntryWidget(),
        if (countryListWidget.isNotEmpty)
          countryListWidget.toScroll(padding: pad(bottom: 20)).toStretch()
        else if(controller.isLoading.value == true)
          const SizedBox.shrink()
        else
          Center(child: CustomText(text: empty_label_no_results_found.tr))
              .toStretch()
      ].toColumn().toPad(horizontal: AppDimen.startMargin);
    });
  }

   void changeAddressFieldCountryName(selectedItem) {
    controller.payoutAddressDetailsMap[AddressDetailsEnum.country] = TitleTextFieldModel(
        customTextEditingController: CustomTextEditingController(text: selectedItem.countryName),
        title: AddressDetailsEnum.country.title.tr,
        focusNode: FocusNode(),
        hintText: ''
    );
    Get.forceAppUpdate();
  }

  Widget _showCountrySearchEntryWidget() {
    return CustomPrefixTextField(
            controller: controller.countrySearchController,
            keyboardType: TextInputType.name,
            characterlength: 25,
            prefixIcon: Assets.drawableSearch,
            hintText: '${label_search_for.tr} ${label_country_region.tr}',
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onChanged: (string) {
              controller.isUpdateSelectedItem.value =
                  !controller.isUpdateSelectedItem.value;
            },
            )
        .toPad(bottom: 16);
  }
}