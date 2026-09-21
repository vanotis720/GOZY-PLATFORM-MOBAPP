import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/graphql/__generated__/listing_fragment.data.gql.dart';
import 'package:gozy/resources/app_colors.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/resources/app_layout.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/screens/views/owner/property_calendar/property_calendar_controller.dart';
import 'package:gozy/widgets/calendar/calendar.dart';
import 'package:gozy/widgets/checkbox_group.dart';
import 'package:gozy/widgets/common/custom_bottomsheet/custom_bottomsheet.dart';
import 'package:gozy/widgets/common/custom_bottomsheet/custom_draggable_bottomsheet.dart';
import 'package:gozy/widgets/common/custom_bottomsheet/custom_getx_bottomsheet.dart';
import 'package:gozy/widgets/common/custom_button/primary_button.dart';
import 'package:gozy/widgets/common/custom_container/custom_border_container.dart';
import 'package:gozy/widgets/common/custom_container/custom_counter_container.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/common/custom_textfield/custom_prefix_textfield.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/conditional_parent_widget.dart';
import 'package:gozy/widgets/common/custom_button/custom_button.dart';
import 'package:gozy/widgets/common/custom_container/custom_container.dart';
import 'package:gozy/widgets/custom_text.dart';
import 'package:gozy/widgets/dotted_border/dotted_border.dart';
import 'package:gozy/widgets/explore_listing_item_widgets.dart';

import '../../../../config/client.dart';
import '../../../../widgets/common/custom_container/custom_bottom_item_shadow_container.dart';
import '../../../../widgets/custom_empty_view.dart';
import '../owner_property_list/owner_property_list.dart';

class PropertyCalendarPage extends OwnerPropertyListPage {
  const PropertyCalendarPage({super.key});

  @override
  PropertyCalendarPageState createState() => PropertyCalendarPageState();
}

class PropertyCalendarPageState extends OwnerPropertyListPageState {
  PropertyCalendarController calendarController = Get.find();
  late SimpleVerticalCalendar simplecalendar;
  final Duration _duration = const Duration(milliseconds: 150);
  double? borderRadius;
  double? bottomButtonBorderRadius;
  double? editIconBorderRadius;
  double? containerBorderRadius;
  Color? borderColor;
  Color listingDetailInfoBgColor = appColors.theme4AppBarBg;
  bool isChipView = false;
  bool isShowDotForCarType = true;
  bool? isPaddedDividerNeed;
  double? sizeOfSvg;
  String editIcon = "";
  bool? showCarTypeIcon = false;
  bool? showTransmissionIcon = false;
  double colorRadius = 0.0;
  Color?selectedCarBGColor;

  @override
  void initState() {
    calendarController.CalendarTitle.value = '';
    calendarController.completedLists = super.controller.completedLists;
    if (calendarController.completedLists.isEmpty) {
      calendarController.isLoading.value = true;
      calendarController.checkNetwork(calendarController.getCompletedListings);
    }
    ever(calendarController.CalendarTitle, (value) {
      debugPrint('calendarController.completedListscount: ${calendarController.completedLists.length}');
      super.controller.completedLists = calendarController.completedLists;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch (overALLThemeType) {
      case 1:
        colorRadius = 4;
        break;
      case 2:
        colorRadius = 0;
        break;
      case 3:
        colorRadius = 7;
        break;
      default:
        colorRadius = 6;
        break;
    }
    initThemeData();
    calendarController.createListingdayStatusMap();
    return Obx(() {
      if (calendarController.completedLists.isNotEmpty && calendarController.selectedItemInfo == null) {
        calendarController.selectedItemInfo = (calendarController.completedLists[0]);
        calendarController.CalendarTitle.value = '';
      }

      if (calendarController.selectedItemInfo != null) {
        GviewListingDetailsFragmentData? data = calendarController.getItemInfo().$1;
        if (data?.listingSteps?.step1 == 'completed' &&
            data?.listingSteps?.step2 == 'completed' &&
            data?.listingSteps?.step3 == 'completed' &&
            data?.listPhotoName != null &&
            data!.listPhotoName.toString().isNotEmpty) {
          calendarController.selectedItemInfo = data;
        }
      }

      return CustomScaffold(
          controller: calendarController,
          isShowAppBar: calendarController.CalendarTitle.value.isNotEmpty,
          title: calendarController.CalendarTitle.value,
          backIcon: null,
          body: !calendarController.isLoading.value ||
                  (Get.isDialogOpen ?? false) ||
                  (Get.isBottomSheetOpen ?? false)
              ? showBodyContentWidget()
              : Center(child: dotCenter120HeightLoader!));
    });
  }

  @override
  Widget showBodyContentWidget() {
    if (calendarController.selectedItemInfo != null) {
      calendarController.getBlockedDates(blockedDates: calendarController.selectedItemInfo.blockedDates);
    }
    simplecalendar = SimpleVerticalCalendar(
        numOfMonth: (12 * 5),
        selectedDates: calendarController.selectedDates,
        baseController: calendarController,
        dayTextColor: appColors.black,
        isPaddedDividerNeed: isPaddedDividerNeed,
        blockedHalf: 'secondHalf',
        bookedDates: calendarController.bookedDatesMap,
        blockedDates: calendarController.blockedDatesMap,
        specialPriceDates: calendarController.specialPriceDatesMap,
        initialDateTime:
            DateTime.now(),
        calendarType: 'host');
    String photo = imgListingMedium + (calendarController.selectedItemInfo?.listPhotoName ?? '');
    int _index = 0;
    return calendarController.completedLists.isNotEmpty || (Get.isDialogOpen ?? false)
        ? [
            ConditionalParentWidget(
                condition: overALLThemeType == 4,
                parentBuilder: (child) => DottedBorderView(
                    borderRadius: overALLAppLayoutModel?.borderRadius,
                    dottedlineColor: appColors.colorCommonLinkColor,
                    child: child).toPad(horizontal:2),
                child: CustomBorderContainer(
                  color: listingDetailInfoBgColor,
                  borderRadius: overALLThemeType != 4 ? 0 : overALLAppLayoutModel?.borderRadius,
                  body: toListImageRow(
                      showBorderForImage: true,
                      borderWidth:1.5,
                      width: 105,
                      height: 68,
                      borderRadius: borderRadius,
                      borderColor: borderColor,
                      containerBorderRadius: containerBorderRadius,
                      photo: photo,
                      id: calendarController.selectedItemInfo.id ?? 0,
                      placeholderURL:
                          imgListingSmall + (calendarController.selectedItemInfo.listPhotoName ?? ''),
                      ListItemWidgets: ConfirmPayListingHeaderWidget(
                          itemInfo: calendarController.selectedItemInfo,
                          ratingColor: appColors.textColor,
                          isOrderChangeVar: true,
                          isChipView: isChipView,
                          showDotForCarType: isShowDotForCarType,
                          sizeOfSvg: sizeOfSvg,
                          isShowMoreCar: true,
                          showMoreCarOnTap: () {
                            GetXBottomSheet(
                              bottomSheetWidget: getDraggableSheetWidget(
                                  themeType: overALLThemeType,
                                  borderRadius: overALLAppLayoutModel?.borderRadius,
                                  selectedValue: appPreference.appTheme,
                                  isWidgetListScrollable: true,
                                  title: label_choose_cars.tr,
                                  controller: controller,
                                  widgetsList: [
                                    _getCompletedReviewListWidget()
                                  ]),
                            );
                          }),
                  ).toPad(horizontal: AppDimen.startMargin, vertical: 10),
                ),
            ),
            20.toHeight(),
            Wrap(
              spacing: 2.0,
              runSpacing: 15.0,
              children: calendarController.listingDayStatusMap.entries.map((entry) {
                final currentIndex = _index++;
                final bool hasBorder = currentIndex == 2;
                var textsize = _textSize(entry.key, const TextStyle(fontSize: 11));
                return [
                  CustomBorderContainer(
                    color: entry.value.first,
                    height: 15,
                    width: 15,
                    borderWidth: 1,
                    borderColor: hasBorder? appColors.commonDividerColor : Colors.transparent,
                    borderRadius: colorRadius,
                  ),
                  6.toWidth(),
                  CustomText(
                    text: entry.key,
                    size: 12,
                  ).toStretch(isExpanded: false),
                ].toRow(mainAxisAlignment: MainAxisAlignment.start).toResizeWidget(
                      width: entry.value.length > 1
                          ? entry.value.last
                          : textsize.width + ((12 * textsize.width) / 10),
                    );
              }).toList(),
            ).toPad(start: AppDimen.startMargin),
            20.toHeight(),
            isPaddedDividerNeed != null && isPaddedDividerNeed!
                ? filterDivider.toPad(horizontal: AppDimen.startMargin)
                : filterDivider,
            [
              simplecalendar.toRefresh(onRefresh: () async {
                super.controller.completedLists.clear();
                calendarController.calendarListCurrentpage.value = 1;
                calendarController.checkNetwork(calendarController.getCompletedListings);
              }),
              Obx(() => (calendarController.selectedDates.isNotEmpty)
                  ? CancelButton(
                          buttonText: label_edit.tr,
                          color: appColors.secondaryColor,
                          fillcolor: appColors.secondaryColor,
                          textColor: Colors.white,
                          verticalPadding: 8,
                          borderRadius: editIconBorderRadius,
                          isExpand: false,
                          mapIcon: editIcon,
                          onTap: () {
                            calendarController.isvisibleSpecialpriceBottomsheet = true;
                            calendarController.isDateBlock.value = false;
                            calendarController.specialPriceEditController.clear();
                            showCustomBottomSheet(
                              backButtonWidget: getBackIconWidget(
                                themeType: overALLThemeType,
                                  backIcon: Assets.drawableSignupClose),
                              contentWidget: GetBuilder(
                                  init: calendarController,
                                  id: calendarController.isRxBottomSheetLoading.id,
                                  builder: (context) {
                                    return calendarController.isRxBottomSheetLoading.value
                                        ? dotCenter120HeightLoader!
                                        : _getAvailabilityChangeWidget().toRefreshSheet();
                                  }),
                              title: label_availability.tr,
                            );
                          })
                      .toPad(bottom: 30.0, end: 20)
                      .toPositionedAlign(alignment: AlignmentDirectional.bottomEnd)
                  : const SizedBox.shrink()),
            ].toStack().toStretch(),
          ].toColumn()
        : Center(
            child: showEmptyCalendarWidget(),
          )
            .toResizeWidget(
              height: deviceHeight - 200,
            )
            .toScroll(physics: const AlwaysScrollableScrollPhysics())
            .toRefresh(onRefresh: () async {
            calendarController.isLoading.value = true;
            calendarController.checkNetwork(calendarController.getCompletedListings);
          });
  }

  Widget showEmptyCalendarWidget() {
    return CustomEmptyView(
      emptyImageWidget: Assets.drawableEmptyCalendar.toSVG(),
      emptyTitle: "${label_no.tr} ${tabbar_calendar.tr.toLowerCase()}!",
      emptyDescription: label_calendar_empty_content.tr,
    );
  }

  Size _textSize(String text, TextStyle style) {
    final TextPainter textPainter =
        TextPainter(text: TextSpan(text: text, style: style), maxLines: 1, textDirection: TextDirection.ltr)
          ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  Widget _buildListingDetailInfo(dynamic itemInfo, List<Widget> listwidget, {String? type}) {
    if (itemInfo != null) {
      String photo = imgListingMedium + (itemInfo!.listPhotoName!);
      return [
        [
          toListImageRow(
            clipBehavior:Clip.none,
            borderWidth:1.5,
            showBorderForImage: true,
            containerBorderRadius: containerBorderRadius,
            borderRadius: borderRadius,
            borderColor: itemInfo.id == calendarController.selectedItemInfo.id
                ? borderColor
                : appColors.myTripsDividerColor,
            bgColor: itemInfo.id == calendarController.selectedItemInfo.id ? selectedCarBGColor: Colors.transparent,
            photo: photo,
            width: 105,
            height: 68,
            id: itemInfo.id,
            placeholderURL: imgListingSmall + (itemInfo!.listPhotoName!),
            ListItemWidgets: listwidget,
            selectedIconWidget: type == 'custom_dialog' ? selectedIconWidget(itemInfo.id) : null,
          ),
        ].toStack().toStretch(),
        if (type != 'custom_dialog')
          Assets.drawableFilterCalendarArrow.toSVG(quarterTurns: 1, colour: appColors.black, size: 15).toPad(top: 5, start: 5),
      ].toRow(crossAxisAlignment: CrossAxisAlignment.start).toPad(
        horizontal: type != 'custom_dialog' ? AppDimen.startMargin : 0,
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget selectedIconWidget(int id) {
    return id == calendarController.selectedItemInfo.id
        ? CustomCounterContainer(
            color: appColors.secondaryColor,
            borderColor: appColors.secondaryColor,
            width: 20,
            height: 20,
            padding: pad(a: 3),
            borderWidth: 1.5,
            body: Assets.drawableViewdetailReportTick.toSVG(
              colour: AppColors.staticwhite,
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _getCompletedReviewListWidget() {
    return  _getCompletedListWidget();
  }

  Widget _getCompletedListWidget() {
    return List.generate(
          calendarController.completedLists.length,
          (index) {
            return Obx(
              () {
                appThemeChanged.value;
                return [
                  15.toHeight(),
                  toOnTap(
                      onTap: () {
                        calendarController.selectedItemInfo = calendarController.completedLists[index];
                        calendarController.isLoading.refresh();
                        calendarController.selectedDates.clear();
                        calendarController.selectedDates.refresh();
                        Get.back();
                      },
                      child: _getItemWidget(
                          itemInfo: calendarController.completedLists[index],
                          type: 'custom_dialog',
                          isOpenDialog: false)).toPad(horizontal: AppDimen.startMargin),
                  10.toHeight(),
                  if(overALLThemeType !=1)
                  filterDivider.toFitToDeviceWidth().toResizeWidget(height: 1)
                ].toColumn();
              }
            );
          },
        )
            .toColumn();
  }

  Widget _getItemWidget({required dynamic itemInfo, String? type, bool? isOpenDialog}) {
    return _buildListingDetailInfo(type: type, itemInfo, [
        if(overALLThemeType != 4)
      [
        (showCarTypeIcon ?? false)
            ? (appLayoutMap[AppLayout.themeType]
                    ?.carFeatureIcons[LayoutCarIcons.cartype]
                    ?.toSVG(colour: appColors.customTextColor, size: 12) ??
                0.toHeight())
            : 0.toHeight(),
        (showCarTypeIcon ?? false) ? 5.toWidth() : 0.toHeight(),
        Flexible(
          fit: FlexFit.loose,
          child: CustomText(
            text: itemInfo?.carType ?? '',
            maxLines: 1,
            fontWeight: AppFont.regular,
            size: AppDimen.textSize_12,
            overflow: TextOverflow.ellipsis,
            color: appColors.customTextColor,
          ),
        ),
        5.toWidth(),
        Container(
          height: 5,
          width: 5,
          decoration: BoxDecoration(color: appColors.black, shape: BoxShape.circle),
        ).toPad(top: 2),
        5.toWidth(),
        (showTransmissionIcon ?? false)
            ? (appLayoutMap[AppLayout.themeType]
                    ?.carFeatureIcons[LayoutCarIcons.transmission]
                    ?.toSVG(colour: appColors.black, size: sizeOfSvg) ??
                0.toHeight())
            : 0.toHeight(),
        (showTransmissionIcon ?? false) ? 5.toWidth() : 0.toHeight(),
        CustomText(
          text: itemInfo?.transmission == "1" ? label_automatic.tr : label_manual.tr,
          maxLines: 3,
          fontWeight: AppFont.regular,
          size: AppDimen.textSize_12,
          overflow: TextOverflow.ellipsis,
          color: appColors.customTextColor,
        ),
      ].toRow(mainAxisAlignment: MainAxisAlignment.start),
      if(overALLThemeType == 4)
        [
          Flexible(
          fit: FlexFit.loose,
          child:  IntrinsicWidth(
            child: CustomContainer(
              constraints: BoxConstraints(maxWidth: Get.width*0.3),
              decoration: BoxDecoration(
                  color: listingDetailInfoBgColor,
                  borderRadius: BorderRadius.circular(30)
              ),
              padding: pad(start:8,end: 12, h: 5),
              body: [
                (showCarTypeIcon ?? false)
                    ? (appLayoutMap[AppLayout.themeType]
                    ?.carFeatureIcons[LayoutCarIcons.cartype]
                    ?.toSVG(colour: appColors.black, size: 12) ??
                    0.toHeight())
                    : 0.toHeight(),
                (showCarTypeIcon ?? false) ? 5.toWidth() : 0.toHeight(),
                Flexible(
                  child: CustomText(
                    text: itemInfo?.carType ?? '',
                    maxLines: 1,
                    fontWeight: AppFont.regular,
                    size: AppDimen.textSize_12,
                    overflow: TextOverflow.ellipsis,
                    color: appColors.customTextColor,
                  ),
                ),
              ].toRow(mainAxisAlignment: MainAxisAlignment.start),
            ),
          ),
        ),
          3.toWidth(),
          Flexible(
              fit: FlexFit.loose,
              child: IntrinsicWidth(
                child: CustomContainer(
                  constraints: BoxConstraints(maxWidth: Get.width*0.3),
                  decoration: BoxDecoration(
                      color: listingDetailInfoBgColor,
                      borderRadius: BorderRadius.circular(30)
                  ),
                  padding: pad(start:8,end: 12, h: 5),
                  body: [
                    (showTransmissionIcon ?? false)
                        ? (appLayoutMap[AppLayout.themeType]
                        ?.carFeatureIcons[LayoutCarIcons.transmission]
                        ?.toSVG(colour: appColors.black, size: sizeOfSvg) ??
                        0.toHeight())
                        : 0.toHeight(),
                    (showTransmissionIcon ?? false) ? 3.toWidth() : 0.toHeight(),
                    Flexible(
                      child: CustomText(
                        text: itemInfo?.transmission == "1" ? label_automatic.tr : label_manual.tr,
                        maxLines: 1,
                        fontWeight: AppFont.regular,
                        size: AppDimen.textSize_12,
                        overflow: TextOverflow.ellipsis,
                        color: appColors.customTextColor,
                      ),
                    ),
                  ].toRow(mainAxisAlignment: MainAxisAlignment.start),
                ),
              ))].toRow(mainAxisAlignment: MainAxisAlignment.start),
      5.toHeight(),
      CustomText(
        text: itemInfo?.title ?? '',
        maxLines: 2,
        fontWeight: AppFont.regular,
        size: AppDimen.textSize_16,
        color: appColors.customTextColor,
        overflow: TextOverflow.ellipsis,
      ),
    ]);
  }

  Widget _getAvailabilityChangeWidget() {
    double borderRadius = 0;
    bool isBorderNeeded = false;
    bool isCheckBoxComesFront = false;
    bool showContainerColor = false;
    switch (overALLThemeType) {
      case 1:
        borderRadius = 6;
        isBorderNeeded = true;
        isCheckBoxComesFront = false;
        showContainerColor = true;
        break;
      case 2:
        borderRadius = 0;
        isBorderNeeded = true;
        isCheckBoxComesFront = false;
        break;
      case 3:
        borderRadius = 18;
        isBorderNeeded = true;
        isCheckBoxComesFront = true;
        showContainerColor = true;
        break;
      default:
        isCheckBoxComesFront = true;
        break;
    }

    String symbol = calendarController.getCurrencySymbol(
        currency: (calendarController.selectedItemInfo?.listingData?.currency ?? defaultCurrency));
    debugPrint("_isvisibleSpecialpriceBottomsheet: ${calendarController.isvisibleSpecialpriceBottomsheet}");
    return [
      [
        15.toHeight(),
        [
          Assets.theme1Calendar.toSVG(colour: appColors.black).toPad(top: 1),
          8.toWidth(),
          Obx(() => CustomTitleText(
                text: calendarController.getSelectedDate(),
                size: AppDimen.textSize_16,
                maxLines: 2,
              ).toStretch(isExpanded: false)),
          15.toWidth(),
        ].toRow(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start),
        12.toHeight(),
        CustomContainer(
          decoration: isBorderNeeded
              ? BoxDecoration(
                  color: showContainerColor ? appColors.myTripsBGColor : null,
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(color: appColors.myTripsDividerColor))
              : null,
          body: [
            Obx(
              () => toOnTap(
                onTap: () {
                  if (calendarController.isDateBlock.value) {
                    calendarController.isDateBlock.value = !calendarController.isDateBlock.value;
                  }
                },
                child: [
                  if (isCheckBoxComesFront) ...[
                    CustomCheckBox(ischeckCondition: calendarController.isDateBlock.value,isNeedEndPadding: false, boxshape: BoxShape.circle,borderColor: appColors.myTripsDividerColor,unselectCheckBoxColor: overALLThemeType == 1 || overALLThemeType == 3 ? appColors.myTripsBGColor : null).toPad(bottom: 4,end: 5),
                    CustomText(
                      text: checkbox_label_make_available.tr,
                      size: AppDimen.textSize_16,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ).toStretch(),
                  ] else ...[
                    CustomText(
                      text: checkbox_label_make_available.tr,
                      size: AppDimen.textSize_16,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ).toStretch(),
                    Spacer(),
                    CustomCheckBox(ischeckCondition: calendarController.isDateBlock.value, boxshape: BoxShape.circle,borderColor: appColors.myTripsDividerColor,unselectCheckBoxColor: overALLThemeType == 1 || overALLThemeType == 3 ? appColors.myTripsBGColor : null).toPad(bottom: 4),
                  ]
                ]
                    .toRow(mainAxisAlignment: MainAxisAlignment.start)
                    .toPad(start: isBorderNeeded ? 18 : 0 , end: isBorderNeeded ? 8 : 0 ),
              ),
            ),
            15.toHeight(),
            filterDivider,
            15.toHeight(),
            Obx(
              () => toOnTap(
                onTap: () {
                  if (!calendarController.isDateBlock.value) {
                    calendarController.isDateBlock.value = !calendarController.isDateBlock.value;
                  }
                },
                child: [
                  if (isCheckBoxComesFront) ...[
                    CustomCheckBox(ischeckCondition: !calendarController.isDateBlock.value,isNeedEndPadding: false, boxshape: BoxShape.circle,borderColor: appColors.myTripsDividerColor,unselectCheckBoxColor: overALLThemeType == 1 || overALLThemeType == 3 ? appColors.myTripsBGColor : null).toPad(bottom: 4,end: 5),
                    CustomText(
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        text:
                            '${checkbox_label_block_selected.tr} ${calendarController.selectedDates.isNotEmpty ? label_date_single.trPlural(label_date_plural, calendarController.selectedDates.first == calendarController.selectedDates.last ? 1 : 2) : ''}'),
                  ] else ...[
                    CustomText(
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        text:
                            '${checkbox_label_block_selected.tr} ${calendarController.selectedDates.isNotEmpty ? label_date_single.trPlural(label_date_plural, calendarController.selectedDates.first == calendarController.selectedDates.last ? 1 : 2) : ''}'),
                    Spacer(),
                    CustomCheckBox(ischeckCondition: !calendarController.isDateBlock.value, boxshape: BoxShape.circle,borderColor: appColors.myTripsDividerColor,unselectCheckBoxColor: overALLThemeType == 1 || overALLThemeType == 3 ? appColors.myTripsBGColor : null).toPad(bottom: 4),
                  ]
                ]
                    .toRow(mainAxisAlignment: MainAxisAlignment.start)
                    .toPad(start: isBorderNeeded ? 18 : 0 , end: isBorderNeeded ? 8 : 0 ),
              ),
            ),
          ].toColumn().toPad(vertical: isBorderNeeded ? 15 : 0),
        ),
        18.toHeight(),
        Obx(
          () => AnimatedContainer(
              duration: _duration,
              height: !calendarController.isDateBlock.value ? 85 : 0,
              child: AnimatedOpacity(
                  opacity: !calendarController.isDateBlock.value ? 1.0 : 0.0,
                  duration: _duration,
                  child: CustomPrefixTextField(
                    focusNode: FocusNode(),
                    title: label_host_calendar_add_special_price.tr,
                    hintText: '20 /${label_day.tr}',
                    hintTextColor: appColors.textFieldInActiveIconColor,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    characterlength: 5,
                    filteringTextInputFormatter: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                    ],
                    controller: calendarController.specialPriceEditController,
                    prefixIconWidget: CustomText(
                      color: appColors.textFieldInActiveIconColor,
                      symbol: symbol,
                      text: '$symbol ',
                    ),
                  ),
              ),
          ),
        ),
      ].toScroll().toPad(horizontal: AppDimen.startMargin).toStretch(),
      if (calendarController.isvisibleSpecialpriceBottomsheet) _showSaveBtnWidget(),
    ]
        .toColumn(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.max)
        .toResizeWidget(width: deviceWidth, height: deviceHeight);
  }

  Widget _showSaveBtnWidget() {
    return CustomBottomItemShadowContainer(
      height: 100,
      color: appColors.white,
      padding: pad(w: 20, top: 25, bottom: 25),
      borderRadiusGeometry: BorderRadiusDirectional.vertical(
          top: Radius.circular(overALLAppLayoutModel?.borderRadius ?? 0),
          bottom: Radius.circular(overALLAppLayoutModel?.borderRadius ?? 0)),
      body: PrimaryButton(
        buttonText: btn_label_save.tr,
        onTap: () {
          if (!calendarController.isDateBlock.value &&
              (calendarController.specialPriceEditController.Ttext.isNotEmpty &&
                  (double.tryParse(calendarController.specialPriceEditController.Ttext) == 0 || calendarController.specialPriceEditController.Ttext.trim() == "."))) {
            calendarController.showToast(error_msg_special_price_should_be_greater_than_zero.tr);
            return;
          }
          if (!calendarController.isLoading.value) {
            calendarController.change(
                rxVariable: calendarController.isRxBottomSheetLoading,
                value: true);
            calendarController
                .checkNetwork(calendarController.updateBlockedSpecialDates);
          }
        },
      ),
    );
  }

  void initThemeData() {
    switch (overALLThemeType) {
      case 1:
        borderRadius = 6;
        editIconBorderRadius = 6;
        containerBorderRadius = 6;
        bottomButtonBorderRadius = 20;
        borderColor = appColors.colorCommonLinkColor;
        editIcon = Assets.theme1WishlistEdit;
        isPaddedDividerNeed = true;
        showCarTypeIcon = true;
        selectedCarBGColor = appColors.theme4AppBarBg;
        listingDetailInfoBgColor = appColors.theme4AppBarBg;
        break;
      case 2:
        borderRadius = 0;
        editIconBorderRadius = 0;
        containerBorderRadius = 0;
        bottomButtonBorderRadius = 0;
        editIcon = Assets.theme2WishlistEdit;
        listingDetailInfoBgColor = appColors.theme4AppBarBg;
        borderColor = appColors.black;
        selectedCarBGColor = appColors.theme4AppBarBg;
        break;
      case 3:
        borderRadius = 12;
        containerBorderRadius = 18;
        bottomButtonBorderRadius = 30;
        editIconBorderRadius = 30;
        borderColor = appColors.black;
        editIcon = Assets.theme3WishlistEdit;
        listingDetailInfoBgColor = appColors.myTripsBGColor;
        isPaddedDividerNeed = false;
        showCarTypeIcon = true;
        showTransmissionIcon = true;
        selectedCarBGColor = appColors.theme3LoginArrowBackColor;
        break;
      default:
        borderRadius = 12;
        containerBorderRadius = 18;
        bottomButtonBorderRadius = 12;
        editIconBorderRadius = 12;
        listingDetailInfoBgColor = appColors.theme4AppBarBg;
        borderColor = appColors.colorCommonLinkColor;
        isShowDotForCarType = false;
        isChipView = true;
        editIcon = Assets.theme4WishlistEdit;
        isPaddedDividerNeed = false;
        sizeOfSvg = 14;
        showCarTypeIcon = true;
        showTransmissionIcon = true;
        selectedCarBGColor = appColors.theme4AppBarBg;
        break;
    }
  }

  @override
  void dispose() {
    calendarController.selectedDates.clear();
    super.dispose();
  }
}