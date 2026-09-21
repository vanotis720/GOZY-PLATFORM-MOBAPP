import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common/custom_bottomsheet/custom_bottomsheet.dart';
import 'package:gozy/widgets/common/custom_textfield/custom_prefix_textfield.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_list_item.dart';
import 'package:gozy/widgets/custom_text.dart';

import '../../screens/views/custom_scaffold.dart';

class CountrySelectionBottomSheet {
  final BaseController controller;
  final List countries;
  final dynamic selectedValue; // Can be country name, code or dial code
  final Function(dynamic item) onSelect;
  final TextEditingController searchController;
  final RxBool updateTrigger;
  final String? title;
  final bool isDialCode;

  CountrySelectionBottomSheet({
    required this.controller,
    required this.countries,
    required this.onSelect,
    required this.searchController,
    required this.updateTrigger,
    this.selectedValue,
    this.title,
    this.isDialCode = false,
  }) {
    showCustomBottomSheet(
      isSelectCountry: true,
      sheetCloseListener: () {
        searchController.clear();
        updateTrigger.refresh();
      },
      contentWidget: _showCountrySelectionListWidget(),
    );
  }

  Obx _showCountrySelectionListWidget() {
    return Obx(() {
      updateTrigger.value;
      List<Widget> countryListWidget = [];
      
      var filteredCountries = countries.where((item) {
        String name = _getItemName(item);
        bool matchesSearch = (searchController.text.isNotEmpty &&
                name.toLowerCase().toNormalizeSpaces().contains(
                    searchController.text.toLowerCase().toNormalizeSpaces())) ||
            searchController.text.isEmpty;
        return matchesSearch;
      }).toList();

      // Sort: Selected item first, then alphabetical
      filteredCountries.sort((a, b) {
        bool isASelected = _isItemSelected(a);
        bool isBSelected = _isItemSelected(b);

        if (isASelected && !isBSelected) {
          return -1;
        } else if (!isASelected && isBSelected) {
          return 1;
        } else {
          return _getItemName(a).compareTo(_getItemName(b));
        }
      });

      for (final (index, item) in filteredCountries.indexed) {
        bool isSelected = _isItemSelected(item);
        Widget widget = toOnTap(
          onTap: () async {
            onSelect(item);
            onBack();
          },
          child: CustomListItem(
            horizontalpadding: 0,
            text: _getItemName(item),
            textColor: isSelected ? appColors.colorCommonLinkColor : null,
            fontWeight: AppFont.regular,
            size: AppDimen.textSize_16,
            trailingWidget: isSelected
                ? Assets.drawableInstantBookTick.toSVG(colour: Colors.white, size: 8).toCircle(color: appColors.secondaryColor, padding: 5, margin: 0)
                : null,
            isSoftWrap: true,
            isImageDividerVisible: index < (filteredCountries.length) - 1,
            isImageAsset: _getItemFlag(item),
          ),
        );
        countryListWidget.add(widget);
      }

      return [
        20.toHeight(),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: getBackIconWidget(
              backIcon: Assets.drawableSignupClose,
              clickableSize: 50,
              margin: EdgeInsets.zero,
              borderWidth: 0),
        ),
        20.toHeight(),
        _showCountrySearchEntryWidget(),
        if (countryListWidget.isNotEmpty)
          countryListWidget.toScroll(padding: pad(bottom: 20)).toStretch()
        else
          Center(child: CustomText(text: empty_label_no_results_found.tr)).toStretch()
      ].toColumn().toPad(horizontal: AppDimen.startMargin);
    });
  }

  Widget _showCountrySearchEntryWidget() {
    return CustomPrefixTextField(
      controller: searchController,
      keyboardType: TextInputType.name,
      title: title ?? select_country.tr,
      characterlength: 25,
      prefixIcon: Assets.drawableSearch,
      hintText: '${label_search_for.tr} ${label_country_region.tr}',
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.done,
      onChanged: (string) {
        updateTrigger.value = !updateTrigger.value;
      },
    ).toPad(bottom: 16);
  }

  String _getItemName(dynamic item) {
    try {
      return item.name ?? item.countryName ?? "";
    } catch (e) {
      return "";
    }
  }

  String? _getItemFlag(dynamic item) {
    try {
      return item.flagUri;
    } catch (e) {
      return null;
    }
  }

  bool _isItemSelected(dynamic item) {
    if (selectedValue == null) return false;
    try {
      if (isDialCode) {
        return item.dialCode == selectedValue;
      }
      return (item.name ?? item.countryName) == selectedValue ||
             (item.code ?? item.countryCode) == selectedValue;
    } catch (e) {
      return false;
    }
  }
}