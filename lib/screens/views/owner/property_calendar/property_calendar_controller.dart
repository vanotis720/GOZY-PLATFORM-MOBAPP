import 'package:built_collection/src/list.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:gozy/config/client.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/graphql/ListDetail/__generated__/ListingDetails.data.gql.dart';
import 'package:gozy/graphql/ListDetail/__generated__/ListingDetails.req.gql.dart';
import 'package:gozy/graphql/__generated__/listing_fragment.data.gql.dart';
import 'package:gozy/graphql/manageListings/__generated__/manageListings.data.gql.dart';
import 'package:gozy/graphql/manageListings/__generated__/manageListings.req.gql.dart';
import 'package:gozy/graphql/manageListings/__generated__/manageListings.var.gql.dart';
import 'package:gozy/resources/app_colors.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/home/home_controller.dart';
import 'package:gozy/utils/text_editing_controller.dart';
import 'package:gozy/widgets/common_extension_functions.dart';

import '../../../../graphql/__generated__/listing_fragment.req.gql.dart';

class PropertyCalendarController extends BaseController {
  dynamic selectedItemInfo;
  RxList<DateTime> selectedDates = <DateTime>[].obs;
  Map<String, List<dynamic>> listingDayStatusMap = {};
  Map<DateTime, String> blockedDatesMap = {};
  Map<DateTime, List<String>> specialPriceDatesMap = {};
  Map<DateTime, List<dynamic>> bookedDatesMap = {};
  ScrollController calendarListingScrollController = ScrollController();
  RxBool isDateBlock = false.obs;
  CustomTextEditingController specialPriceEditController = CustomTextEditingController();
  bool isvisibleSpecialpriceBottomsheet = false;

  RxString CalendarTitle = ''.obs;
  RxInt calendarListCurrentpage = 1.obs;
  List<GManageListingsData_ManageListings_results?> completedLists = [];
  int completedListingsCount = 0;
  HomeController controller = HomeController();

  void getCompletedListings() {
    final params = GManageListingsReq((b) => b
      ..vars.requestType = 'completed'
      ..vars.currentPage = calendarListCurrentpage.value
      ..vars.build());

    FerryLoggerClient.makeRequest(params, this, getCompletedListings)?.then((res) {
      print("currentDate------>-$params");
      GManageListingsData manageListings = res.data as GManageListingsData;
      completedListingsCount = manageListings.ManageListings?.count ?? 0;
      if (calendarListCurrentpage.value != 1) {
        completedLists.addAll(manageListings.ManageListings?.results?.toList() ?? []);
      } else {
        completedLists = manageListings.ManageListings?.results?.toList() ?? [];
      }

      if (completedListingsCount == 0) {
        CalendarTitle.value = tabbar_calendar.tr;
      }

      isLoading.value = false;
    });
  }

  void createListingdayStatusMap() {
    listingDayStatusMap.clear();
    double width = (deviceWidth / 3);
    listingDayStatusMap[label_host_calendar_booked.tr] = [appColors.calenderBookedColor, width - 35];
    listingDayStatusMap[label_host_calendar_not_available.tr] = [appColors.errorRed, width - 10];
    listingDayStatusMap[label_host_calendar_available.tr] = [AppColors.staticwhite, width - 10];
    listingDayStatusMap[label_host_calendar_special_price_long_press_to_see.tr] = [
      appColors.discountAmountColor
    ];
  }

  Map<DateTime, List<String>> getBlockedDates({required dynamic blockedDates}) {
    blockedDatesMap.clear();
    specialPriceDatesMap.clear();
    bookedDatesMap.clear();
    blockedDates?.forEach((element) {
      DateTime blockeddateOrigin = DateTime.fromMillisecondsSinceEpoch(int.parse(element?.blockedDates), isUtc: true);
      DateTime blockeddate = DateTime(blockeddateOrigin.year, blockeddateOrigin.month, blockeddateOrigin.day);
      final reservationId = element?.reservationId;
      final status = element?.calendarStatus;
      if (reservationId != null) {
        bookedDatesMap[blockeddate] = [reservationId];
        debugPrint('blockeddate123: $blockeddate --- ${bookedDatesMap[blockeddate]}');
      } else {
        switch (status) {
          case 'blocked':
            blockedDatesMap[blockeddate] = 'full';

          case 'available':
            final rawPrice = element?.isSpecialPrice?.toString() ?? '0';
            final convertedPrice = double.parse(rawPrice).currencyConverted(
              convertedCurrency: selectedItemInfo.listingData!.currency,
            );
            specialPriceDatesMap[blockeddate] = ['full', convertedPrice];

          default:
            break;
        }
      }
    });
    return specialPriceDatesMap;
  }

  String getSelectedDate() {
    debugPrint('selectedDates: $selectedDates');
    if (selectedDates.isNotEmpty &&
        (selectedDates.length == 1 || selectedDates.first == selectedDates.last)) {
      return _getMultilangDateText(selectedDates.first);
    } else if (selectedDates.isNotEmpty) {
      return "${_getMultilangDateText(selectedDates.first)} - ${_getMultilangDateText(selectedDates.last)}";
    } else {
      return '';
    }
  }

  String _getMultilangDateText(DateTime date) {
    String updatedDateText = '';
    String formatedtext = date.convert_MDY(format: checkAvailabilityCalenderFormat).$1;
    updatedDateText = formatedtext.split(' ')[0].toLowerCase().tr;
    updatedDateText = formatedtext.replaceAll(formatedtext.split(' ')[0], updatedDateText);
    return updatedDateText;
  }

  void updateBlockedSpecialDates() {
    List<String> dateList = [];
    List<int> dateTimeList = [];

    DateTime currentDate = selectedDates.first;
    debugPrint('millisec: ${currentDate.millisecondsSinceEpoch}--${specialPriceEditController.Ttext}');
    while (currentDate.isBefore(selectedDates.last) || currentDate.isAtSameMomentAs(selectedDates.last)) {
      dateList.add(currentDate.toString());
      dateTimeList.add(DateTime.utc(currentDate.year, currentDate.month, currentDate.day).millisecondsSinceEpoch);
      currentDate = currentDate.add(Duration(days: 1));
    }

    GUpdateSpecialPriceVarsBuilder builder = GUpdateSpecialPriceVarsBuilder();
    builder.listId = selectedItemInfo.id;
    builder.blockedDates = ListBuilder<String>(dateList);
    builder.calendarStatus = isDateBlock.value ? 'blocked' : 'available';
    if (!isDateBlock.value) {
      builder.isSpecialPrice =
      specialPriceEditController.Ttext.isNotEmpty ? double.parse(specialPriceEditController.Ttext) : null;
    }

    var params = GUpdateSpecialPriceReq((b) => b.vars = builder);

    FerryLoggerClient.makeRequest(params, this, updateBlockedSpecialDates, isBottomSheetOpen: true)
        ?.then((res) {
      change(rxVariable: isRxBottomSheetLoading, value: false);
      var datareq = getItemInfo();
      List<GviewListingDetailsFragmentData_blockedDates?>? blockeddateslist =
      datareq.$1?.blockedDates?.toList();
      List<GviewListingDetailsFragmentData_blockedDates?>? updateddateslist = [];
      List<String> existingdatetimes = [];

      blockeddateslist?.forEach((blackeddate) {
        GviewListingDetailsFragmentData_blockedDatesBuilder? datesbuilder = blackeddate?.toBuilder();
        DateTime blockdate =
        DateTime.fromMillisecondsSinceEpoch(int.parse((blackeddate?.blockedDates) ?? '0'), isUtc: true);
        existingdatetimes.add(blockdate.toString().split(' ')[0]);
        bool isadded = false;
        for (final (index, element) in dateTimeList.indexed) {
          DateTime fordate = DateTime.fromMillisecondsSinceEpoch(int.parse(element.toString()), isUtc: true);

          if (blockdate.toString().split(' ')[0] == fordate.toString().split(' ')[0]) {
            if (blackeddate?.reservationId == null) {

              if (!isDateBlock.value && specialPriceEditController.Ttext.isEmpty) {
                isadded = true;
                break;
              }

              datesbuilder?.calendarStatus = isDateBlock.value ? 'blocked' : 'available';
              if (!isDateBlock.value) {
                datesbuilder?.isSpecialPrice = specialPriceEditController.Ttext.isNotEmpty
                    ? double.parse(specialPriceEditController.Ttext)
                    : null;
              }
              updateddateslist.add(datesbuilder?.build());
              isadded = true;
              break;
            } else if (blackeddate?.reservationId != null && !isDateBlock.value) {
              if (blackeddate?.blockedDates == updateddateslist.last?.blockedDates) {
                datesbuilder?.reservationId = updateddateslist.last?.reservationId;
                updateddateslist.removeLast();
                if (existingdatetimes.contains(blockdate.toString().split(' ')[0])) {
                  existingdatetimes.remove(blockdate.toString().split(' ')[0]);
                }
                updateddateslist.add(datesbuilder?.build());
                return;
              }
            }
          }
        }
        if (!isadded) {
          updateddateslist.add(datesbuilder?.build());
        }
      });
      for (final (index, datetime) in dateTimeList.indexed) {
        String dateString = DateTime.fromMillisecondsSinceEpoch(datetime, isUtc: true).toString().split(' ')[0];
        if (!existingdatetimes.contains(dateString)) {
          GviewListingDetailsFragmentData_blockedDatesBuilder? datesbuilder =
          GviewListingDetailsFragmentData_blockedDatesBuilder();
          datesbuilder.blockedDates = datetime.toString();
          if (!isDateBlock.value && specialPriceEditController.Ttext.isEmpty) {
            break;
          }
          datesbuilder.calendarStatus = isDateBlock.value ? 'blocked' : 'available';
          if (!isDateBlock.value) {
            datesbuilder.isSpecialPrice = specialPriceEditController.Ttext.isNotEmpty
                ? double.parse(specialPriceEditController.Ttext)
                : null;
          }

          updateddateslist.add(datesbuilder.build());
        } else {
          debugPrint("else: $existingdatetimes ---$dateString");
        }
      }

      debugPrint('makeavailable: 3  $updateddateslist');
      var rebuiltInfo = datareq.$1?.rebuild((b) => b..blockedDates = ListBuilder(updateddateslist));
      FerryLoggerClient.client?.cache.writeFragment(datareq.$2, rebuiltInfo);
      isvisibleSpecialpriceBottomsheet = false;
      selectedItemInfo = rebuiltInfo;
      selectedDates.clear();
      isLoading.value = false;
      selectedDates.refresh();
      Get.forceAppUpdate();
      Get.back();
    });
  }

  (GviewListingDetailsFragmentData?, GviewListingDetailsFragmentReq) getItemInfo() {
    GviewListingDetailsFragmentReq fragmentReq =
        GviewListingDetailsFragmentReq((b) => b..idFields = {'id': selectedItemInfo.id});
    return (FerryLoggerClient.client?.cache.readFragment(fragmentReq), fragmentReq);
  }

  void getUpdatedPropertyInfo() {
    final params = GviewListingDetailsReq((b) => b
      ..vars.listId = selectedItemInfo.id
      ..vars.build());
    FerryLoggerClient.makeRequest(params, this, getUpdatedPropertyInfo)?.then((res) {
      GviewListingDetailsData viewListingInfo = res.data as GviewListingDetailsData;
      var itemInfo = getItemInfo();
      Map<String, dynamic> itemInfoMap = viewListingInfo.viewListing!.results?.toJson() ?? {};
      FerryLoggerClient.client?.cache.writeFragment(itemInfo.$2, itemInfo.$1?.rebuild((b) => itemInfoMap));
      Get.forceAppUpdate();
      controller.isLoading.value = false;
      isLoading.value = false;
    });
  }
}