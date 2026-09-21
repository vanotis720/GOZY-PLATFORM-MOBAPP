import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/screens/views/guest/filter/guest_filter_controller.dart';
import 'package:gozy/screens/views/guest/searched/searched_listings_controller.dart';
import 'package:gozy/screens/views/home/home_controller.dart';
import 'package:gozy/widgets/checkbox_group.dart';
import 'package:gozy/widgets/common/custom_bottomsheet/custom_draggable_bottomsheet.dart';
import 'package:gozy/widgets/common/custom_bottomsheet/custom_getx_bottomsheet.dart';
import 'package:gozy/widgets/common/custom_button/bottom_shadow_button.dart';
import 'package:gozy/widgets/common/custom_container/custom_border_container.dart';
import 'package:gozy/widgets/common/custom_container/custom_underline_container.dart';
import 'package:gozy/widgets/common/custom_text/custom_header_with_label_text.dart';
import 'package:gozy/widgets/common/custom_text/custom_rangefilter_text.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_range_slider_shape.dart';
import 'package:gozy/widgets/custom_stateful_widget.dart';
import 'package:gozy/widgets/custom_switch.dart';
import 'package:gozy/widgets/custom_text.dart';

import '../../../../resources/app_font.dart';
import 'filter_calendar.dart';

class GuestFilterScreen extends CustomStatefulWidget {
  final HomeController controller;

  const GuestFilterScreen({key, required this.controller}) : super(key: key);

  @override
  GuestFilterScreenState createState() => GuestFilterScreenState();
}

class GuestFilterScreenState extends CustomStatefulWidgetState<GuestFilterScreen> {
  late GuestFilterController filterController = widget.controller.GuestFilterController != null
      ? widget.controller.GuestFilterController as GuestFilterController
      : Get.find<GuestFilterController>();
  final List<Widget> _filterwidgets = [];
  Thumb selectedthumb = Thumb.start;
  double thumbValue = 0.0;
  bool showDivider = false;
  Color makeTypeAppBar = appColors.white;
  Color calBgColor = appColors.white;
  Color? calendarBorderColor;

  Timer? _debounceTimer;
  String _searchedkey = '';
  String _calenderIcon = '';
  double _calenderBorderRadius = 0.0;
  double _dividerPadding = 0.0;
  dynamic _selectedMakeModel;

  @override
  void initState() {
    filterController.guestHomeController = widget.controller;
    filterController.setvalues();
    if (widget.controller.selectedPopularLocation.isNotEmpty) {
      filterController.change(
          rxVariable: filterController.rxSelectedLocation, value: widget.controller.selectedPopularLocation);
    }

    filterController.searchEditController.addListener(() {
      String searchText = filterController.searchEditController.Ttext;
      debugPrint(
          "filterController.searchEditController: $searchText --- ${filterController.oldFilteredItems.length}");

      if (searchText.isEmpty) {
        if (filterController.oldFilteredItems.isNotEmpty) {
          filterController.guestHomeController.filterItems[filterController.searchingType] =
              filterController.oldFilteredItems[filterController.searchingType];
          filterController.guestHomeController.makeCurrentpage.value =
              filterController.oldFilteredItems['${filterController.searchingType}_page'] ?? 1;
          filterController.guestHomeController.filterItemsCount[filterController.searchingType] =
              filterController.oldFilteredItems['${filterController.searchingType}_count'] ?? 0;
          filterController.oldFilteredItems.clear();
          bottomSheetController.change(rxVariable: bottomSheetController.isUpdateItemList, value: false);
        }
      } else {
        if (_searchedkey != searchText) {
          if (filterController.oldFilteredItems.isEmpty) {
            filterController.oldFilteredItems[filterController.searchingType] = List.from(
                filterController.guestHomeController.filterItems[filterController.searchingType] ?? []);
            filterController.oldFilteredItems['${filterController.searchingType}_page'] =
                filterController.guestHomeController.makeCurrentpage.value;
            filterController.oldFilteredItems['${filterController.searchingType}_count'] =
                filterController.guestHomeController.filterItemsCount[filterController.searchingType];
          }

          filterController.guestHomeController.filterItems[filterController.searchingType] = [];
          filterController.guestHomeController.filterItemsCount[filterController.searchingType] = 0;
          bottomSheetController.change(rxVariable: bottomSheetController.isUpdateItemList, value: true);
          filterController.isLinearLoading.value = true;

          if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
          _debounceTimer = Timer(Duration(milliseconds: searchDebounce), () {
            filterController.guestHomeController.makeCurrentpage.value = 1;
            filterController.checkNetwork(filterController.getFilterPaginationData);
            _searchedkey = searchText;
          });
        }
      }
    });

    if (filterController.guestHomeController.filterItems.isEmpty) {
      filterController.isLoading.value = true;
      filterController.checkNetwork(filterController.getFilterItems);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _initFilterTheme();
    return CustomScaffold(
      controller: filterController,
      crossAxisAlignment: CrossAxisAlignment.center,
      isShowAppBar: true,
      backIconWidget: getBackIconWidget(
              backIcon: Assets.drawableSignupClose,
              clickableSize: 50,
              themeType: overALLThemeType,
              margin: EdgeInsets.zero)
          .toPad(horizontal: AppDimen.startMargin),
      action: CustomText(
        text: label_clear_all.tr,
        size: AppDimen.textSize_14,
        fontWeight: AppFont.regular,
        color: appColors.secondaryColor,
        onTap: () {
          if (!filterController.isTapEnabled.value) return;
          filterController.clearFilters();
        },
      ).toPad(horizontal: AppDimen.startMargin),
      customAppBarFunction: () {
        if (!filterController.isTapEnabled.value) return;
        filterController.isTapEnabled.value = false;
        if (!widget.controller.isSearchSelected.value && filterController.isFilterSelected()) {
          filterController.clearFilters();
          filterController.guestHomeController.filterItems.clear();
        }
        late SearchedListingsController searchedListingsController = Get.find();
        searchedListingsController.setRecentSearchQuries();
        Get.back();
        filterController.isTapEnabled.value = true;
      },
      body: Obx(() => AbsorbPointer(
            absorbing: !filterController.isTapEnabled.value,
            child: [
              Expanded(
                child: !filterController.isLoading.value && widget.controller.filterItems.isNotEmpty
                    ? _showFilterItems()
                    : dotCenter120HeightLoader!,
              ),
              _showBottomFilterButtons(),
            ].toColumn(mainAxisSize: MainAxisSize.max),
          )),
    );
  }

  Widget _showFilterItems() {
    _filterwidgets.clear();
    _filterwidgets.add(_showDateFilter().toPad(horizontal: AppDimen.startMargin));
    _filterwidgets.add(_showSwitchBasedFilter(
            notifier: filterController.instantbookNotifier, HeaderText: label_instant_book.tr)
        .toPad(horizontal: AppDimen.startMargin));
    _filterwidgets.add(_showSwitchBasedFilter(
            notifier: filterController.transmissionNotifier,
            HeaderText: '${label_automatic.tr} ${label_transmission.tr.toLowerCase()}')
        .toPad(horizontal: AppDimen.startMargin));
    _filterwidgets.add(_showpriceRangeFilter().toPad(horizontal: AppDimen.startMargin));
    _filterwidgets.add(_showMakeTypeFilter().toPad(horizontal: AppDimen.startMargin));
    _filterwidgets.add(_showCarTypesFilter().toPad(horizontal: AppDimen.startMargin, bottom: 10));
    _filterwidgets.add(_showCarFeaturesFilter().toPad(horizontal: AppDimen.startMargin, bottom: 10));
    _filterwidgets.add(_showCarRulesFilter().toPad(horizontal: AppDimen.startMargin, bottom: 18));

    return toListScroll(
        WidgetList: _filterwidgets, isRemoveDivider: true, removingIndex: 0, horizontalPad: _dividerPadding, noSpaceIndices: {4, 5});
  }

  Widget _showBottomFilterButtons() {
    debugPrint("MediaQuery.bottom: 2  $bottomViewPadding ");
    return IntrinsicHeight(
      child: BottomShadowButton(
        buttonPadding: pad(a: 20),
        buttonText: label_view_results.tr,
        borderRadiusGeometry: BorderRadiusDirectional.only(
            topStart: Radius.circular(overALLAppLayoutModel?.borderRadius ?? 0),
            topEnd: Radius.circular(overALLAppLayoutModel?.borderRadius ?? 0)),
        onTap: () {
          if (!filterController.isTapEnabled.value) return;
          filterController.isTapEnabled.value = false;
          widget.controller.isSearchSelected.value =
              filterController.isFilterSelected() || filterController.rxSelectedLocation.value.isNotEmpty;
          widget.controller.isSearchSelected.refresh();
          widget.controller.GuestFilterController = filterController;
          debugPrint("Get.arguments: ${Get.arguments}");
          if (Get.arguments != null && Get.arguments['isFrom'] != null && Get.arguments['isFrom'] == 'Map') {
            Get.back();
          }
          Get.back(result: widget.controller);
          filterController.isTapEnabled.value = true;
        },
      ).toFitToDeviceWidth(),
    );
  }

  Widget _showDateFilter() {
    return CustomBorderContainer(
      color: calBgColor,
      borderRadius: _calenderBorderRadius,
      margin: pad(bottom: 20),
      borderWidth: 1,
      borderColor: calendarBorderColor,
      height: AppDimen.button_height,
      onTap: () {
        if (!filterController.isTapEnabled.value) return;
        filterController.isTapEnabled.value = false;
        filterController.selectedDates.value = List<DateTime>.from(filterController.rxSavedDates.value);
        Get.to(
          () => FilterCalendar(
            controller: widget.controller,
            selectedDates: filterController.selectedDates,
            selectedStartTime: widget.controller.selectedStartTime,
            selectedEndTime: widget.controller.selectedEndTime,
            savedDates: filterController.rxSavedDates,
            initialDateTime: DateTime.now(),
          ),
          transition: Transition.downToUp,
        )?.then((value) {
          filterController.isTapEnabled.value = true;
        });
      },
      padding: pad(end: 15, start: 20),
      body: [
        (_calenderIcon).toSVG(colour: appColors.black),
        6.toWidth(),
        GetBuilder(
            id: filterController.rxSavedDates.id,
            init: filterController,
            builder: (context) => CustomText(
                  text: filterController.rxSavedDates.value.isEmpty
                      ? label_select_dates.tr
                      : getFilterSelectedDate(),
                  overflow: TextOverflow.ellipsis,
                  size: AppDimen.textSize_18,
                  fontWeight: AppFont.medium,
            ).toStretch(isExpanded: false)),
      ].toRow(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center),
    );
  }

  Widget _showSwitchBasedFilter({required ValueNotifier<bool> notifier, required String HeaderText}) {
    return [
      CustomHeaderWithLabelText(headerText: HeaderText, headerFontSize: AppDimen.textSize_18,),
      AdvancedSwitch(
        height: 26,
        width: 42,
        controller: notifier,
        borderRadius: BorderRadius.circular(30),
      ),
    ].toRow(mainAxisAlignment: MainAxisAlignment.spaceBetween);
  }

  Widget _showpriceRangeFilter() {
    return Obx(() {
      debugPrint(
          "rqangemin: ${double.parse(filterController.Rangestart!.toInt().toString())} ---${double.parse(filterController.Rangeend!.toInt().toString())}---${filterController.rangeValues.value}");
      String currsymbol = filterController.getCurrencySymbol();
      print("selected Curreny sy,bol${currsymbol}");
      customRangeThumbSelector(
        TextDirection textDirection,
        RangeValues values,
        double tapValue,
        Size thumbSize,
        Size trackSize,
        double dx,
      ) {
        final double start = (tapValue - values.start).abs();
        final double end = (tapValue - values.end).abs();

        switch ((start, end)) {
          case (var s, var e) when s < e:
            selectedthumb = Thumb.start;

          case (var s, var e) when s > e:
            selectedthumb = Thumb.end;

          case (var s, var e) when s == e:
            if (thumbValue != start) {
              selectedthumb = tapValue < values.start ? Thumb.start : Thumb.end;
              thumbValue = start;
            } else {
              selectedthumb = (selectedthumb == Thumb.start) ? Thumb.end : Thumb.start;
            }

          default:
            selectedthumb = Thumb.start;
        }
        if (filterController.rangeValues.value.start == filterController.rangeValues.value.end &&
            thumbValue == filterController.rangeValues.value.start) {
          if (selectedthumb == Thumb.start) {
            selectedthumb = Thumb.end;
          } else {
            if (selectedthumb == Thumb.end) {
              selectedthumb = Thumb.start;
            }
          }
          thumbValue = filterController.rangeValues.value.start;
        }
        return selectedthumb;
      }

      return [
        CustomRangefilterText(
            labelFirst: filterController.rangeValues.value.start
                .toInt()
                .toNumberFormat(symbol: currsymbol, canConvertDouble: false),
            labelSecond: filterController.rangeValues.value.end
                .toInt()
                .toNumberFormat(symbol: currsymbol, canConvertDouble: false),
            headerText: label_price_range.tr,
            headerTextFontSize: AppDimen.textSize_18,
            headerTextFontWeight: AppFont.medium,
            symbol: widget.controller.getCurrencySymbol()),
        SliderTheme(
          data: SliderThemeData(
              thumbSelector: customRangeThumbSelector,
              minThumbSeparation: 0.5,
              trackHeight: 2,
              activeTrackColor: overALLThemeType == 1
                  ? appColors.black
                  : overALLThemeType == 2
                      ? appColors.secondaryColor
                      : overALLThemeType == 3
                          ? appColors.black
                          : overALLThemeType == 4
                              ? appColors.secondaryColor
                              : null,
              inactiveTrackColor: appColors.commonDividerColor,
              overlayShape: SliderComponentShape.noOverlay,
              thumbColor: appColors.white,
              rangeThumbShape: CustomRangeShape()),
          child: SizedBox(
            height: 40,
            child: GestureDetector(
              onHorizontalDragStart: (_) {},
              child: RangeSlider(
                values: RangeValues(double.parse(filterController.rangeValues.value.start.toInt().toString()),
                    double.parse(filterController.rangeValues.value.end.toInt().toString())),
                onChanged: (RangeValues values) {
                  if (values.start <= values.end) {
                    filterController.rangeValues.value = values;
                  }
                },
                min: double.parse(filterController.Rangestart!.toInt().toString()),
                max: double.parse(filterController.Rangeend!.toInt().toString()),
              ),
            ),
          ).toPad(top: 10),
        ),
      ].toColumn(mainAxisSize: MainAxisSize.min);
    });
  }

  Widget _showMakeTypeFilter() {
    return [
      CustomTitleText(
        text: '${label_make.tr} ${label_type.tr}',
        size: AppDimen.textSize_18,
      ),
      15.toHeight(),
      (overALLThemeType == 4)
          ? CustomUnderlineContainer(height: 48, width: deviceWidth, body: showMakeTypeFilterRow())
          : CustomBorderContainer(
              borderRadius: overALLAppLayoutModel?.borderRadius,
              height: 48,
              width: deviceWidth,
              body: showMakeTypeFilterRow())
    ].toColumn();
  }

  Widget showMakeTypeFilterRow() {
    return toOnTap(
      onTap: () {
        if (!filterController.isTapEnabled.value) return;
        filterController.isTapEnabled.value = false;
        if (filterController.oldFilteredItems.isNotEmpty) {
          filterController.guestHomeController.filterItems[filterController.searchingType] =
              filterController.oldFilteredItems[filterController.searchingType];
          filterController.guestHomeController.makeCurrentpage.value =
              filterController.oldFilteredItems['${filterController.searchingType}_page'];
          filterController.guestHomeController.filterItemsCount[filterController.searchingType] =
              filterController.oldFilteredItems['${filterController.searchingType}_count'];
          debugPrint(
              "filterController.oldFilteredItemslength: ${widget.controller.filterItems[filterController.searchingType]} --- ${filterController.oldFilteredItems['${filterController.searchingType}_count']}");
          filterController.oldFilteredItems.clear();
          filterController.searchEditController.clear();
        }
        filterController.isLinearLoading.value = false;
        filterController.searchBarStatus.value = 0;
        bottomSheetController.change(rxVariable: bottomSheetController.isUpdateItemList, value: false);
        GetXBottomSheet(
            sheetCloseListener: () => filterController.isTapEnabled.value = true,
            borderRadius: overALLAppLayoutModel?.borderRadius,
            bottomSheetWidget: getDraggableSheetWidget(
              toHideDivider: !showDivider,
              borderRadius: overALLAppLayoutModel?.borderRadius,
              controller: filterController,
              currentPage: filterController.guestHomeController.makeCurrentpage,
              isLinearLoading: filterController.isLinearLoading,
              selectedModel: _selectedMakeModel,
              title: label_choose_make_type.tr,
              getListItemsFunction: () {
                debugPrint("makeitemcount: ${widget.controller.filterItems['make']?.length}");
                return widget.controller.filterItems['make'];
              },
              overALLCount: widget.controller.filterItemsCount['make'],
              paginationFunction: filterController.getFilterPaginationData,
              selectedId: widget.controller.makeType != 0 ? widget.controller.makeType : null,
              selectedValue: widget.controller.rxMakeTypeValue.value.isNotEmpty
                  ? widget.controller.rxMakeTypeValue.value
                  : null,
              onItemSelected: (value) {
                widget.controller.makeType = value.id;
                widget.controller
                    .change(rxVariable: widget.controller.rxMakeTypeValue, value: value.itemName);
                _selectedMakeModel = value;
              },
              searchEditController: filterController.searchEditController,
              searchBarStatus: filterController.searchBarStatus,
              isShowCircleTick: true,
            ));
      },
      child: [
        GetBuilder(
          id: widget.controller.rxMakeTypeValue.id,
          init: widget.controller,
          builder: (context) => CustomText(
                  text: (widget.controller.rxMakeTypeValue.value != '')
                      ? widget.controller.rxMakeTypeValue.value
                      : label_choose_make_type.tr,
                  overflow: TextOverflow.ellipsis)
              .toStretch(),
        ),
        Assets.drawableDownArrow.toSVG(colour: appColors.black)
      ]
          .toRow(mainAxisAlignment: MainAxisAlignment.spaceBetween)
          .toPad(horizontal: overALLThemeType != 4 ? AppDimen.textSize_18 : 0.0),
    );
  }

  Widget _showCarTypesFilter() {
    return _showcheckBoxFilter(
      HeaderText: label_car_type.tr,
      labels: widget.controller.filterItems['carType'],
      onSelected: filterController.rxSelectedCarType,
      isShowNetworkIcon: false,
    );
  }

  Widget _showCarFeaturesFilter() {
    return _showcheckBoxFilter(
      HeaderText: label_car_features.tr,
      labels: widget.controller.filterItems['carFeatures'],
      onSelected: filterController.rxSelectedCarFeatures,
      isShowNetworkIcon: false,
    );
  }

  Widget _showCarRulesFilter() {
    return _showcheckBoxFilter(
      HeaderText: label_car_rules.tr,
      labels: widget.controller.filterItems['carRules'],
      onSelected: filterController.rxSelectedCarRules,
      isShowNetworkIcon: false,
    );
  }

  Widget _showcheckBoxFilter(
      {required String HeaderText,
      required List<dynamic>? labels,
      required ReactiveVariable onSelected,
      bool? isShowNetworkIcon}) {
    return [
      CustomTitleText(
        text: HeaderText,
        size: AppDimen.textSize_18,
        fontWeight: AppFont.medium,
      ),
      12.toHeight(),
      ListingsFeaturesGroup(
        bottomSpacing: 8,
        labels: labels,
        onSelected: onSelected,
        isShowNetworkIcon: isShowNetworkIcon,
        showLessFilterItemCount: 4,
        isTopPadNeeded: false,
        isFromFilter: true,
        controller: widget.controller,
        checkListItemColor: appColors.customTextColor,
      )
    ].toColumn();
  }

  String getFilterSelectedDate() {
    return "${_getMultilangDateText(filterController.rxSavedDates.value.first)} - ${_getMultilangDateText(filterController.rxSavedDates.value.last)}";
  }

  void _initFilterTheme() {
    _calenderIcon = overALLAppLayoutModel!.calendarIcon;
    _calenderBorderRadius = overALLAppLayoutModel!.borderRadius;
    _dividerPadding = AppDimen.startMargin;
    switch (overALLThemeType) {
      case 1:
        calBgColor = appColors.myTripsBGColor;
        showDivider = false;
        makeTypeAppBar = appColors.white;
      case 2:
        calBgColor = appColors.theme4AppBarBg;
        showDivider = true;
        makeTypeAppBar = appColors.white;
      case 3:
        calBgColor = appColors.myTripsBGColor;
        showDivider = true;
        makeTypeAppBar = appColors.myTripsBGColor;
        calendarBorderColor = appColors.myTripsDividerColor;
      case 4:
        calBgColor = appColors.theme4AppBarBg;
        showDivider = true;
        calendarBorderColor = appColors.colorCommonLinkColor;
        makeTypeAppBar = appColors.theme4AppBarBg;
        _calenderIcon = Assets.theme3Calender;
        _calenderBorderRadius = 30;
        _dividerPadding = 0.0;
    }
  }

  String _getMultilangDateText(DateTime date) {
    String updatedDateText = '';
    String formatedtext = date.convert_MDY(format: filterselectedDateformat).$1;
    updatedDateText = formatedtext.split(' ')[0].toLowerCase().tr;
    updatedDateText = formatedtext.replaceAll(formatedtext.split(' ')[0], updatedDateText);
    return updatedDateText;
  }
}