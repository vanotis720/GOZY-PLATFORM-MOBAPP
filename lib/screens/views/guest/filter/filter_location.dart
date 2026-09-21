import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/screens/views/guest/filter/guest_filter_controller.dart';
import 'package:gozy/widgets/common/custom_textfield/custom_prefix_textfield.dart';
import 'package:gozy/widgets/common/custom_container/custom_container.dart';
import 'package:gozy/widgets/custom_list_item.dart';
import 'package:gozy/widgets/custom_stateful_widget.dart';
import 'package:gozy/widgets/custom_text.dart';
import 'package:gozy/widgets/common_extension_functions.dart';

//https://prnt.sc/Rj5pq8yjIrzM

class FilterLocationScreen extends CustomStatefulWidget {
  final GuestFilterController filterController;

  const FilterLocationScreen({super.key, required this.filterController});

  @override
  _StatefulWrapperState createState() => _StatefulWrapperState();
}

class _StatefulWrapperState extends CustomStatefulWidgetState<FilterLocationScreen> {
  Timer? _placesListFetchtimer;
  FocusNode focus = FocusNode();
  bool _isHideLocationList = false;
  var isShowCloseIcon = false.obs;

  @override
  void initState() {
    isShowLoader = false;
    if (widget.filterController.rxSelectedLocation.value.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.filterController.locationList.clear();
        widget.filterController.locationNameController.text =
            widget.filterController.rxSelectedLocation.value;
        widget.filterController.isLoading.value = true;
        Future.delayed(const Duration(milliseconds: 350)).then((value) {
          if (widget.filterController.guestHomeController.selectedPopularLocation.isNotEmpty) {
            widget.filterController.locationNameController.selection = TextSelection(
                baseOffset: 0, extentOffset: widget.filterController.rxSelectedLocation.value.length);
          }
          if (widget.filterController.locationNameController.text.isNotEmpty) {
            _fetchLocationList(widget.filterController.locationNameController.text);
          }
        });
      });
      debugPrint('selectedlocation: ${widget.filterController.rxSelectedLocation.value}');
    } else {
      Future.delayed(const Duration(milliseconds: 350)).then((value) {
        widget.filterController.isLoading.value = false;
      });
      widget.filterController.locationNameController.text = "";
    }
    widget.filterController.locationNameController.addListener(() {
      if (widget.filterController.locationNameController.text.isEmpty) {
        isShowCloseIcon.value = false;
      } else {
        isShowCloseIcon.value = true;
      }
    });
    isShowLoader = false;
    super.initState();
  }

  @override
  void dispose() {
    isShowLoader = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      backgroundColor: appColors.searchPageBgColor,
      isShowAppBar: true,
      appBarBGColor: appColors.searchPageBgColor,
      backIconWidget: getBackIconWidget(
          themeType: overALLThemeType,
          onTap: () {
            _backIconFunction();
          }),
      customAppBarFunction: () {
        _backIconFunction();
      },
      body: [
        _showLocationSearchField(),
        getLinearProgress(isShowLoad: widget.filterController.isLoading),
        18.toHeight(),
        _showLocationSearchList().toStretch()
      ].toColumn(),
      controller: widget.filterController,
    );
  }

  Widget _showLocationSearchField() {
    return CustomContainer(
      margin: pad(
        w: AppDimen.startMargin,
        top: 10,
      ),
      body: Focus(
        onFocusChange: (hasFocus) {
          if (hasFocus) {
            _isHideLocationList = false;
            widget.filterController
                .change(rxVariable: widget.filterController.isRxBottomSheetLoading, value: true);
          }
        },
        child: Obx(() {
          return CustomPrefixTextField(
            title: label_search.tr,
            focusNode: focus,
            prefixIconWidget: Assets.drawableSearch
                .toSVG(colour: appColors.textFieldInActiveIconColor)
                .toPad(end: overALLThemeType == 3 ? 4 : 8),
            hintText: '${label_destination.tr}, ${label_city.tr.toLowerCase()}, ${address.tr.toLowerCase()}',
            textSize: AppDimen.textSize_16,
            controller: widget.filterController.locationNameController,
            textInputAction: TextInputAction.done,
            hintFontWeight: FontWeight.normal,
            textCapitalization: TextCapitalization.words,
            maxLines: 1,
            suffixIconWidget: isShowCloseIcon.value
                ? toOnTap(
                    onTap: () {
                      widget.filterController.locationNameController.clear();
                      widget.filterController.locationList.clear();
                      widget.filterController.update();
                    },
                    child: Assets.drawableSignupClose.toSVG(size: 14, colour: appColors.black))
                : const SizedBox.shrink(),
            onChanged: (value) {
              if (value.isEmpty) {
                widget.filterController.change(rxVariable: widget.filterController.rxIsReset, value: false);
              } else {
                _fetchLocationList(value);
              }
            },
          );
        }),
      ),
    );
  }

  Widget _showLocationSearchList() {
    return GetBuilder<GuestFilterController>(
        init: widget.filterController,
        builder: (controller) => !controller.isLoading.value &&
                controller.locationList.isNotEmpty &&
                !_isHideLocationList &&
                controller.locationNameController.text.isNotEmpty
            ? toListView(
                itemCount: controller.locationList.length + 1,
                key: const PageStorageKey<String>('locationlist'),
                padding: pad(bottom: MediaQuery.of(context).viewInsets.bottom),
                itemBuilder: (context, index) {
                  return controller.locationList.length == index
                      ? CustomContainer(
                          alignment: AlignmentDirectional.centerStart,
                          padding: pad(start: AppDimen.startMargin),
                          body: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CustomText(
                                text: 'powered by ',
                                fontWeight: FontWeight.w300,
                                color: appColors.placeholderColor,
                              ),
                              Assets.drawablePoweredByGoogle
                                  .toPng(
                                    height: 16,
                                  )
                                  .toPad(top: 3),
                            ],
                          ).toMaterialLocalization())
                      : CustomListItem(
                          listLeadingIconPadding: 0,
                          onTap: () {
                            controller.change(
                                rxVariable: controller.rxSelectedLocation,
                                value: controller.locationList[index]['description']!);
                            controller.locationNameController.text = controller.rxSelectedLocation.value;
                            FocusManager.instance.primaryFocus?.unfocus();
                            _isHideLocationList = true;
                            controller.guestHomeController.selectedPopularLocation = '';
                            controller.guestHomeController.isSearchSelected.value = true;
                            controller.guestHomeController.isSearchSelected.refresh();
                            Get.back();
                          },
                          iconSpacing: 6,
                          dividerSpacing: 10,
                          isFilterLocPage: true,
                          text: controller.locationList[index]['description']!,
                          listLeadingIcon: Assets.drawableLocatonMarker,
                          fontWeight: FontWeight.normal,
                          textColor: appColors.customTextColor,
                          listLeadingIconColor: appColors.black,
                          listTrailingIconBGColor: appColors.black,
                        );
                })
            : !controller.isLoading.value &&
                    controller.locationNameController.text.isNotEmpty &&
                    controller.locationList.isEmpty &&
                    !_isHideLocationList
                ? Center(
                    child: CustomText(
                      text: empty_label_no_results_found.tr,
                      size: AppDimen.textSize_18,
                      color: appColors.placeholderColor,
                    ),
                  )
                : [
                    Assets.drawableSearchPage.toSVG(height: 200),
                    AppDimen.startMargin.toHeight(),
                    CustomText(
                      text: label_search_page_init_content.tr,
                      size: AppDimen.textSize_16,
                      fontWeight: AppFont.regular,
                      textAlign: TextAlign.center,
                    ),
                  ]
                    .toColumn(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center)
                    .toPad(horizontal: AppDimen.startMargin, top: Get.height * 0.1)
                    .toResizeWidget(width: Get.width));
  }

  void _fetchLocationList(String value) {
    widget.filterController.isLoading.value = true;
    if (value.isNotEmpty) {
      widget.filterController.change(rxVariable: widget.filterController.rxIsReset, value: true);
    } else {
      widget.filterController.change(rxVariable: widget.filterController.rxIsReset, value: false);
    }
    if (_placesListFetchtimer != null) {
      _placesListFetchtimer!.cancel();
    }
    _placesListFetchtimer = Timer(Duration(milliseconds: placesListFetchDurationInSec), () async {
      widget.filterController.isLoading.value = true;
      widget.filterController.update();
      await widget.filterController.searchPlaces(value);
      widget.filterController.isLoading.value = false;
      widget.filterController.change(rxVariable: widget.filterController.rxIsReset, value: false);
      widget.filterController.update();
    });
  }

  void _backIconFunction() {
    if (widget.filterController.locationNameController.text.isEmpty) {
      widget.filterController.change(rxVariable: widget.filterController.rxSelectedLocation, value: '');
      widget.filterController.guestHomeController.isSearchSelected.value =
          widget.filterController.isFilterSelected();
      widget.filterController.guestHomeController.isSearchSelected.refresh();
    } else {
      widget.filterController.locationNameController.clear();
    }
    onBack();
  }
}