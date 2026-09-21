import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gozy/app.dart';
import 'package:built_collection/src/list.dart';
import 'package:gozy/config/client.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/graphql/booking/getReseravtion/__generated__/get_reservation.data.gql.dart';
import 'package:gozy/graphql/booking/getReseravtion/__generated__/get_reservation.req.gql.dart';
import 'package:gozy/graphql/cancelReservation/__generated__/cancelReservations.data.gql.dart';
import 'package:gozy/graphql/cancelReservation/__generated__/cancelReservations.req.gql.dart';
import 'package:gozy/graphql/inbox/__generated__/Inbox.data.gql.dart';
import 'package:gozy/graphql/updateClaimDamage/__generated__/update_claim_damage.data.gql.dart';
import 'package:gozy/graphql/updateClaimDamage/__generated__/update_claim_damage.req.gql.dart';
import 'package:gozy/model/tab_bar_item_model.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/resources/app_layout.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/home/home_controller.dart';
import 'package:gozy/utils/common_api_controller.dart';
import 'package:gozy/utils/common_file_picker.dart';
import 'package:gozy/utils/text_editing_controller.dart';
import 'package:gozy/widgets/bottom_sheet/bottom_sheet_refresh_controller.dart';
import 'package:gozy/widgets/bottom_sheet/cancel_trip/cancel_trip_bottom_sheet.dart';
import 'package:gozy/widgets/common/custom_container/custom_counter_container.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import '../../../../graphql/Reservations/__generated__/getAllReservations.data.gql.dart';
import '../../../../graphql/Reservations/__generated__/getAllReservations.req.gql.dart';
import '../../../../graphql/__generated__/reservation_fragment.data.gql.dart';
import '../../../../graphql/__generated__/reservation_fragment.req.gql.dart';
import '../../../../widgets/bottom_sheet/customer_receipt/customer_receipt_bottom_sheet.dart';
import 'my_trip_list_navigator.dart';

class MyTripListController extends BaseController {
  MyTripListNavigator myTripListNavigator = MyTripListNavigator();

  var contactUsMessageController = CustomTextEditingController();
  var depositAmountController = CustomTextEditingController();
  var depositAmountFocusNode = CustomFocusNode();
  var claimAmountController = CustomTextEditingController();
  var claimAmountFocusNode = CustomFocusNode();
  var reasonForClaimController = CustomTextEditingController();
  var reasonForClaimFocusNode = CustomFocusNode();
  double securityDepositAmount = 0;
  AppLifecycleListener? lifecycleListener;
  RxString selectedImageOption = ''.obs;
  bool isClickEnable = true;

  RxBool isToShowPaginationLoader = true.obs;
  late TabController tabController;
  List<TabBarItemModel> tabBaritems = [];
  
  void updateTabIndex(int index) {
    try {
      if (tabController != null) {
        tabController.index = index;
      }
    } catch (e) {
      debugPrint("TabController not yet initialized: $e");
    }
  }
  int reservationId = 1;
  int idForClaimDamage = 1;
  String? bookingUserId;
  int selectedlistId = 1;
  int _threadId = 1;
  String claimStatus = "";
  int? noOfGuests;
  String _actionType = '', _startdate = '', _enddate = '';
  dynamic selectedReservationItem;
  GCancellationDataData? cancellationData;
  var cancellationMessageController = CustomTextEditingController();
  RxString updatingStatus = ''.obs;
  RxBool isFilesPicking = false.obs;
  bool isInUploadpage = false;
  int photocount = 0;
  RxList<String> uploadingPhotos = RxList<String>();
  RxList<String> uploadingNetWorkPhotos = RxList<String>();
  Future? photoUploadingFuture;
  ScrollController scrollController = ScrollController();
  List<String> removeablePhotos = [];
  Completer<bool> photoUploadCompleter = Completer<bool>();

  bool? isUserTypeChange;

  @override
  Future<void> init() {
    availableCameras().then((value) {
      cameras = value;
    });
    return super.init();
  }

  void getMyListData() {
    TabBarItemModel tabitem = tabBaritems[tabController.index];
    if (!isLoading.value) {
      tabitem.tabBarListData.clear();
      isShowLoader = false;
      tabBaritems[tabController.index] = tabitem.copyWith(
        listCurrentpage: 1,
        isTabLoading: true,
      );
      isLoading.value = true;
      checkNetwork(getMyTrips);
    }
  }
  @override
  void onReady() {
    availableCameras().then((value) {
      cameras = value;
    });
    super.onReady();
  }

  Future<void> getMyTrips() async {
    if (currencyRates == null) {
      await getCurrencyRates();
    }
    int currentTabindex = tabController.index;
    TabBarItemModel currentTabItem = tabBaritems[currentTabindex];
    final params = GgetAllReservationReq((b) => b
      ..vars.dateFilter = currentTabindex == 1 ? 'previous' : 'upcoming'
      ..vars.userType = appPreference.isOwner! ? 'owner' : 'renter'
      ..vars.currentPage = currentTabItem.listCurrentpage.value
      ..vars.build());
    FerryLoggerClient.makeRequest(params, this, getMyTrips,
            isViewLoader: false, isToGet400Message: true)
        ?.then((res) {
      GgetAllReservationData allReservationData =
          res.data as GgetAllReservationData;
      List<dynamic>? ListData = currentTabItem.tabBarListData;
      ListData.addAll(
          allReservationData.getAllReservation?.result?.toList() ?? []);

      tabBaritems[currentTabindex] = currentTabItem.copyWith(
          totalCount: allReservationData.getAllReservation?.count ?? 0,
          isTabLoading: false,
          tabBarListData: ListData);

      if (currentTabindex == tabController.index) {
        isLoading.value = false;
      } else {
        isLoading.refresh();
      }
    });
  }

  bool validateCredentials() {
    Map<String, bool> results = {
      label_error_msg_please_enter_the_message.tr:
          contactUsMessageController.Ttext.toString().isEmpty,
    };
    bool validate = results.isValidate(controller: this, isShowOnToast: true);
    return validate;
  }

  void sendContactSupport() {
    final params = GcontactSupportReq((b) => b
      ..vars.reservationId = reservationId
      ..vars.userType = appPreference.isOwner! ? 'owner' : 'renter'
      ..vars.message = contactUsMessageController.Ttext
      ..vars.listId = selectedlistId
      ..vars.build());

    FerryLoggerClient.makeRequest(params, this, sendContactSupport,
            isViewLoader: true)
        ?.then((res) {
      isLoading.value = false;
      isToShowPaginationLoader.value = true;
      isShowLoader = false;
      showToast(your_message_sent_successfully_we_will_contact_you_soon.tr);
      Future.delayed(const Duration(milliseconds: 750)).then((value) {
        Get.back();
        isClickEnable = true;
      });
    });
  }

  void getCancellationData() {
    final params = GCancellationDataReq((b) => b
      ..vars.reservationId = reservationId
      ..vars.userType = (appPreference.isOwner! ? 'owner' : 'renter')
      ..vars.currency = appPreference.preferredCurrency
      ..vars.build());
    print("getCancellationData: ${params}");

    FerryLoggerClient.makeRequest(
      params,
      this,
      getCancellationData,
      isBottomSheetOpen: true,
      isToGet400Message: true,
    )?.then((res) {
      cancellationData = res.data as GCancellationDataData;

      if (cancellationData?.cancelReservationData?.status != 200) {
        Get.until((route) {
          return route.settings.name == '/guestHomePage';
        });
      }
      BottomSheetController controller = Get.find();
      controller.refresh();
      change(rxVariable: isRxBottomSheetLoading, value: false);
    });
  }

  void sendHostReservationStatus() {
    isShowLoader = true;
    final params = GReservationStatusReq((b) => b
      ..vars.reservationId = reservationId == 1 ? null : reservationId
      ..vars.threadId = _threadId
      ..vars.actionType = _actionType
      ..vars.content = null
      ..vars.type = _actionType
      ..vars.startDate = _startdate
      ..vars.endDate = _enddate
      ..vars.personCapacity = noOfGuests
      ..vars.build());
    print("ReservationStatus--> $params");

    FerryLoggerClient.makeRequest(params, this, sendHostReservationStatus,
            isViewLoader: true,
            isToGet400Message: true,
            isViewErrorMessage: false)
        ?.then((res) {
      isLoading.value = false;
      isShowLoader = false;
      HomeController homeController = Get.find();
      homeController.isLoading.value = false;
      showToast(_actionType == 'declined'
          ? label_reservation_has_been_declined.tr
          : label_reservation_has_been_approved.tr);
      updatingStatus.value = _actionType;
      if (_actionType == 'declined' && selectedReservationItem != null) {
        _updateCurrentPastTrips();
      }
      updateReservationStatusFragment(
          reservationId: reservationId, reservationStatus: _actionType);
    });
  }

  void claimTheDamage() {
    isShowLoader = true;
    final params = GupdateClaimReq((b) => b
      ..vars.claimAmount = double.parse(claimAmountController.Ttext)
      ..vars.claimReason = reasonForClaimController.Ttext
      ..vars.claimImages = ListBuilder(uploadingNetWorkPhotos.value)
      ..vars.reservationId = idForClaimDamage
      ..vars.currency = appPreference.preferredCurrency
      ..vars.build());

    FerryLoggerClient.makeRequest(params, this, claimTheDamage,
            isViewLoader: true)
        ?.then((res) {
      final result = res.data as GupdateClaimData;
      if (result.updateClaim?.status == 200) {
        Get.back();
        Future.delayed(
          Duration(milliseconds: 600), () {
            getMyListData();
          }
        );
      } else {
        showToast(result.updateClaim?.errorMessage ?? "Something went wrong");
      }
    });
  }

  (Color, String)? getReservationStatusColor(
      {required String reservationstatus}) {
    bool isViewmessagepage = Get.currentRoute == '/ViewMessagePage';
    Color statusColor = appColors.textfieldBorderColor;
    String status = reservationstatus.toLowerCase();

    switch (status) {
      case 'approved' || 'instantbooking' || 'intantbooking' || "Approved":
        statusColor = appColors.approvedStatusColor;
        status = (isViewmessagepage &&
                (status == 'instantbooking' || status == 'intantbooking'))
            ? label_booking_status_confirmed.tr
            : label_booking_status_approved.tr;
        break;
      case 'completed':
        statusColor = appColors.completedStatusColor;
        status = tab_completed.tr;
        break;

      case 'cancelledbyhost':
        statusColor = appColors.cancelledStatusColor;
        status = label_booking_status_cancelled_by_host.tr;
        break;

      case 'cancelledbyguest':
        statusColor = appColors.cancelledStatusColor;
        status = label_booking_status_cancelled_by_guest.tr;

      case 'cancelled':
        statusColor = appColors.hostCalendarNotavailableColor;
        status = label_booking_status_cancelled.tr;
        break;

      case 'declined':
        statusColor = appColors.declinedStatusColor;
        status = label_booking_status_pre_declined.tr;
        break;

      case var s when s.contains('cancelled'):
        statusColor = appColors.hostCalendarNotavailableColor;
        status = label_booking_status_pre_declined.tr;
        break;

      case 'pending':
        statusColor = appColors.pendingStatusColor;
        status = label_booking_status_pending.tr;
        break;

      case 'expired':
        statusColor = appColors.expiredStatusColor;
        status = label_booking_status_expired.tr;
        break;

      case 'inquiry':
        statusColor = appColors.inquiryStatusColor;
        status = label_booking_status_inquiry.tr;
        break;

      case 'requesttobook':
        statusColor = appColors.requestToBookStatusColor;
        status = label_request_to_book.tr;
        break;

      case 'preapproved':
        statusColor = appColors.approvedStatusColor;
        status = label_booking_status_pre_approved.tr;
        break;

      case 'confirmed':
        statusColor = appColors.confirmedStatusColor;
        status = label_booking_status_confirmed.tr;
        break;

      case 'message':
        statusColor = appColors.messageStatusColor;
        status = '';
        break;

      case 'reflection':
        statusColor = appColors.reflectionStatusColor;
        status = "Reflection";

      case 'claimrequested':
        statusColor = appColors.claimStatusColor;
        status = label_security_deposit_claimed_by_owner.tr;

      case 'claimrefunded':
        statusColor = appColors.claimStatusColor;
        status = label_security_deposit_refunded.tr;

      default:
        statusColor = appColors.textfieldBorderColor;
    }

    return (statusColor, status);
  }

  List<Map<String, dynamic>> getReservationmenulist(
      {required String reservationstatus, dynamic reservationItem}) {
    debugPrint("getReservationmenulist--> $reservationItem");

    List<Map<String, dynamic>> reservationmenulist = [];

    Map<String, dynamic> viewLocationItem = {};
    viewLocationItem['icon'] = Assets.drawableTripsMenuItenary
        .toSVG(colour: appColors.black, size: 16);
    viewLocationItem['text'] = "label_trip_menu_view_location".tr;
    viewLocationItem['ontap'] = () {
      openMap(reservationItem?.listData.lat, reservationItem?.listData.lng);
    };
    viewLocationItem['order'] = 1;

    Map<String, dynamic> itenaryitem = {};
    itenaryitem['icon'] = Assets.drawableTripsMenuItenary
        .toSVG(colour: appColors.black, size: 16);
    itenaryitem['text'] = label_trip_menu_view_itenary.tr;
    itenaryitem['ontap'] = () {
      myTripListNavigator
          .navigateScreen(MyTripListScreen.reservationDetail, param: {
        'itemInfo': reservationItem?.listData,
        'reservationId': reservationItem?.id,
        'page': 'triplist'
      });
    };
    itenaryitem['order'] = 2;

    Map<String, dynamic> receiptitem = {};
    receiptitem['icon'] = Assets.drawableTripsMenuReceipt
        .toSVG(colour: appColors.black, size: 18);
    receiptitem['text'] = label_view_receipt.tr;
    receiptitem['ontap'] = () async {
      String? discountlabel;
      if (reservationItem?.discountType != null &&
          reservationItem!.discountType!.toString().isNotEmpty) {
        discountlabel = await getMultilangContent(
            content: reservationItem?.discountType ?? '');
      }
      CustomerReceiptBottomSheet(
          receiptItem: reservationItem,
          controller: this,
          discountLabel: discountlabel);
    };
    receiptitem['order'] = 3;

    Map<String, dynamic> approveitem = {};
    approveitem['icon'] = CustomCounterContainer(
      borderColor: appColors.black,
      borderWidth: 1,
      padding: pad(a: 2.6),
      body: Assets.drawableInstantBookTick.toSVG(
        size: 10,
        colour: appColors.black,
      ),
    );
    approveitem['text'] = label_trip_menu_accept.tr;
    approveitem['ontap'] = () {
      selectedReservationItem = reservationItem;
      reservationId = reservationItem?.id ?? 1;
      noOfGuests = reservationItem?.guests ?? 1;
      _actionType = 'approved';
      _threadId = reservationItem?.threadData?.threadId ?? 1;
      _startdate = getDateFormat(
              dateFormat: reservationDateformat,
              milliSec: reservationItem?.checkIn)
          .$1;
      _enddate = getDateFormat(
              dateFormat: reservationDateformat,
              milliSec: reservationItem?.checkOut)
          .$1;
      checkNetwork(sendHostReservationStatus);
    };
    approveitem['order'] = 4;

    Map<String, dynamic> declineitem = {};
    declineitem['icon'] = CustomCounterContainer(
      borderColor: appColors.black,
      borderWidth: 1,
      padding: pad(a: 1),
      body: Assets.drawableTripsMenuDecline.toSVG(
        size: 12,
        colour: appColors.black,
      ),
    );
    declineitem['text'] = label_trip_menu_decline.tr;
    declineitem['ontap'] = () {
      selectedReservationItem = reservationItem;
      reservationId = reservationItem?.id ?? 1;
      noOfGuests = reservationItem?.guests ?? 1;
      _actionType = 'declined';
      _threadId = reservationItem?.threadData?.threadId ?? 1;
      _startdate = getDateFormat(
              dateFormat: reservationDateformat,
              milliSec: reservationItem?.checkIn)
          .$1;
      _enddate = getDateFormat(
              dateFormat: reservationDateformat,
              milliSec: reservationItem?.checkOut)
          .$1;

      checkNetwork(sendHostReservationStatus);
    };
    declineitem['order'] = 5;

    Map<String, dynamic> messageitem = {};
    messageitem['icon'] = Assets.drawableGuestInbox.toSVG(
      colour: appColors.black,
      size: 15,
    );
    messageitem['text'] = getMessageTitle();
    messageitem['ontap'] = () {
      myTripListNavigator.navigateScreen(MyTripListScreen.viewMessage,
          param: {'threadId': reservationItem.threadData.threadId.toString()});
    };
    messageitem['order'] = 6;

    Map<String, dynamic> claimDamageItem = {};
    claimDamageItem['text'] =
        getClaimDamageTitle(status: reservationItem.claimStatus ?? "");
    claimDamageItem['ontap'] = () {
      final params = {
        "securityDeposit": reservationItem.securityDeposit.toString(),
        "claimStatus": reservationItem.claimStatus.toString(),
        "id": reservationItem.id,
        "currency": reservationItem.currency
      };
      if (reservationItem.claimStatus == "requested") {
        params['claimAmount'] = reservationItem.claimAmount;
        params['claimReason'] = reservationItem.claimReason;
        params['claimImages'] = reservationItem.claimImages;
      }
      reservationItem.claimStatus == "approved"
          ? myTripListNavigator.navigateScreen(MyTripListScreen.claimDetails,
              param: {"reservationItem": reservationItem})
          : myTripListNavigator.navigateScreen(MyTripListScreen.claimDamage,
              param: params);
    };
    claimDamageItem['order'] = 7;

    Map<String, dynamic> cancelitem = {};
    cancelitem['icon'] = CustomCounterContainer(
      borderColor: appColors.black,
      borderWidth: 1,
      padding: pad(a: 3),
      body: Assets.drawableSignupClose.toSVG(
        size: 9,
        colour: appColors.black,
      ),
    );
    cancelitem['text'] = label_cancel.tr;
    cancelitem['ontap'] = () {
      showCancellationSheet(reservationItem);
    };
    cancelitem['order'] = 8;

    final String status = reservationstatus.toLowerCase();
    final bool isOwner = appPreference.isOwner ?? false;
    final int index = tabController.index;
    final bool canCancel = reservationItem?.isCancelEnabled ?? true;

// 2. Use a Switch Expression for high-performance mapping
    reservationmenulist.clear();

    switch ((index, isOwner, status)) {
      // Guest - Active
      case (0, false, var s) when s != 'pending':
        reservationmenulist
            .addAll([viewLocationItem, itenaryitem, receiptitem]);
        if (canCancel) reservationmenulist.add(cancelitem);

      // Guest - Pending
      case (0, false, 'pending'):
        reservationmenulist.addAll([viewLocationItem, receiptitem]);

      // Guest - History
      case (1, false, _):
        reservationmenulist.addAll([receiptitem]);

      // Owner - Pending
      case (0, true, 'pending'):
        reservationmenulist.addAll([approveitem, declineitem]);

      // Owner - Active
      case (0, true, _):
        reservationmenulist.addAll([receiptitem]);
        if (canCancel) reservationmenulist.add(cancelitem);

      // Owner - History
      case (1, true, var s):
        reservationmenulist.add(receiptitem);

        bool claimVisibility = false;

        // Step 1: Check time-based visibility (matches Android logic)
        (bool, bool) isAddClaim = _handleOwnerClaims(s, reservationItem);
        if (isAddClaim.$1 && isAddClaim.$2) {
          claimVisibility = true;
        }

        // Step 2: fullyRefunded always hides the claim item
        final claimStatus = reservationItem.claimStatus;
        if (claimStatus == "fullyRefunded") {
          claimVisibility = false;
        }

        // Step 3: requested or approved always shows the claim item
        if (claimStatus == "requested" || claimStatus == "approved") {
          claimVisibility = true;
        }

        if (claimVisibility && !isClaimMenuAdded) {
          isClaimMenuAdded = true;
          reservationmenulist.add(claimDamageItem);
        }

      default:
        break;
    }
    reservationmenulist.add(messageitem);
    reservationmenulist
        .sort((a, b) => (a['order'] as int).compareTo(b['order'] as int));
    return reservationmenulist;
  }

  (bool, bool) _handleOwnerClaims(String status, dynamic reservationItem) {
    dynamic timestamp;

    if (status == 'completed') {
      // Android: if reservationState == "completed" -> use checkOut
      timestamp = reservationItem.checkOut;
    } else if (status == 'cancelled') {
      // Android: if reservationState == "cancelled" -> claimStatus == "pending" && cancellationStatus == true
      final isPendingClaim = (reservationItem.claimStatus ?? '') == 'pending';
      final isCancellationStatus = reservationItem.cancellationStatus ?? false;
      if (isPendingClaim && isCancellationStatus) {
        timestamp = reservationItem.cancellationDetails?.createdAt;
      }
    }

    if (timestamp != null) {
      final date =
          DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp.toString()));
      final isWithin24Hours = DateTime.now().difference(date).inHours < 24;
      final hasDeposit = (double.tryParse(
                  reservationItem.securityDeposit?.toString() ?? '0') ??
              0) !=
          0;
      return (isWithin24Hours, hasDeposit);
    }
    return (false, false);
  }

  void updateReservationStatusFragment(
      {required int reservationId, required String reservationStatus}) {
    (GreservationFragmentData?, GreservationFragmentReq) info =
        getReservationInfo(reservationId: reservationId);
    if (info.$1 != null) {
      FerryLoggerClient.client?.cache.writeFragment(info.$2,
          info.$1?.rebuild((builder) {
        builder.reservationState = reservationStatus;
        builder.isCancelEnabled = reservationStatus == "approved";
      }));
      isLoading.refresh();
    } else {
      getMyListData();
    }
  }

  void updateClaimStatusFragment(
      {required int reservationId, required String claimStatus}) {
    (GreservationFragmentData?, GreservationFragmentReq) info =
        getReservationInfo(reservationId: reservationId);
    if (info.$1 != null) {
      FerryLoggerClient.client?.cache.writeFragment(info.$2,
          info.$1?.rebuild((builder) {
        builder.claimStatus = claimStatus;
      }));
      isLoading.refresh();
    } else {
      getMyListData();
    }
  }

  void checkValidation({FocusNode? messagefocusNode}) {
    final message = cancellationMessageController.text.trim();

    Map<String, bool> results = {
      label_error_msg_please_enter_the_message.tr: message.isEmpty,
    };

    bool validate = results.isValidate(
      controller: this,
      isShowOnToast: true,
    );

    Future.delayed(const Duration(milliseconds: 1000)).then((value) {
      messagefocusNode?.requestFocus();
    });

    if (validate) {
      checkNetwork(cancelTrip);
    }
  }

  void cancelTrip() {
    final params = GCancelReservationReq((b) => b
      ..vars.reservationId = reservationId
      ..vars.cancellationPolicy =
          cancellationData?.cancelReservationData?.results?.cancellationPolicy
      ..vars.refundToGuest =
          cancellationData?.cancelReservationData?.results?.refundToGuest
      ..vars.payoutToHost =
          cancellationData?.cancelReservationData?.results?.payoutToHost
      ..vars.guestServiceFee =
          cancellationData?.cancelReservationData?.results?.guestServiceFee
      ..vars.hostServiceFee =
          cancellationData?.cancelReservationData?.results?.hostServiceFee
      ..vars.total = cancellationData?.cancelReservationData?.results?.total
      ..vars.currency =
          cancellationData?.cancelReservationData?.results?.currency
      ..vars.threadId =
          cancellationData?.cancelReservationData?.results?.threadId
      ..vars.cancelledBy =
          cancellationData?.cancelReservationData?.results?.cancelledBy
      ..vars.message = cancellationMessageController.text.toString()
      ..vars.checkIn = cancellationData?.cancelReservationData?.results?.checkIn
      ..vars.checkOut =
          cancellationData?.cancelReservationData?.results?.checkOut
      ..vars.guests = cancellationData?.cancelReservationData?.results?.guests
      ..vars.startTime =
          cancellationData?.cancelReservationData?.results?.startTime
      ..vars.endTime = cancellationData?.cancelReservationData?.results?.endTime
      ..vars.build());

    FerryLoggerClient.makeRequest(params, this, cancelTrip,
            isBottomSheetOpen: true)
        ?.then((res) {
      dynamic selecteditem;
      if (tabBaritems.isNotEmpty) {
        List<dynamic> currentlistdata = tabBaritems[0].tabBarListData;
        for (var item in currentlistdata) {
          if (item.id == selectedReservationItem.id &&
              item.listId == selectedReservationItem.listId) {
            selecteditem = item;
          }
        }
      }

      if (selecteditem != null) {
        _updateCurrentPastTrips(selectedTripItem: selecteditem);
      }
      HomeController homeController = Get.find();
      homeController.isLoading.value = false;
      updateReservationStatusFragment(
          reservationId: reservationId, reservationStatus: 'Cancelled');
      updatingStatus.value =
          appPreference.isOwner! ? 'cancelledByHost' : 'cancelledByGuest';
      change(rxVariable: isRxBottomSheetLoading, value: false);
      debugPrint("canceltrip:currentRoute: ${Get.currentRoute}");
      if(Get.currentRoute != '/ViewMessagePage')
      Get.back();
    });
  }

  void showCancellationSheet(dynamic reservationItem,
      {Function? sheetCloseListener}) {
    cancellationMessageController.clear();
    isNetworkConnected().then((isNetConnected) {
      if (isNetConnected) {
        selectedReservationItem = reservationItem;
        reservationId = reservationItem?.id ?? 1;
        change(rxVariable: isRxBottomSheetLoading, value: true);
        getCancellationData();
        isLoading.value = false;
        CancelTripBottomSheet(
            receiptItem: reservationItem,
            controller: this,
            sheetCloseListener: sheetCloseListener);
      }
    });
  }

  void getReservation({int? reservationIdVar}) {
    final params = GgetReservationReq((b) => b
      ..vars.reservationId = reservationIdVar ?? reservationId
      ..vars.convertCurrency = appPreference.preferredCurrency
      ..vars.build());
    debugPrint("reservationIdVar: ${reservationIdVar} --- ${reservationId}");
    FerryLoggerClient.makeRequest(params, this, getReservation,
            isViewLoader: true)
        ?.then((res) {
      isLoading.value = false;
      GgetReservationData getReservationData = res.data as GgetReservationData;
      GreservationFragmentData? fragmentData =
          getReservationInfo(reservationId: reservationId).$1;
      showCancellationSheet(fragmentData, sheetCloseListener: () {
        isShowLoader = false;
      });
    });
  }

  void updateReservationStatusFromViewMsg(
      {required String updatingStatus,
      GgetThreadsData_getThreads_results_threadItemForType? threadItemFortype,
      bool isFromNotification = false,
      String? messageContent}) {
    print("updateReservationStatusFromViewMsg: ${isFromNotification} -- ${messageContent}");
    if (!isFromNotification) {
      reservationId = threadItemFortype?.reservationId ?? 1;
    }
    noOfGuests = threadItemFortype?.personCapacity ?? 1;
    _actionType = updatingStatus;
    reservationId = threadItemFortype?.reservationId ?? 1;
    _threadId = threadItemFortype?.threadId ?? 1;
    _startdate = getDateFormat(
            dateFormat: reservationDateformat,
            milliSec: threadItemFortype?.startDate)
        .$1;
    _enddate = getDateFormat(
            dateFormat: reservationDateformat,
            milliSec: threadItemFortype?.endDate)
        .$1;
    if (isFromNotification) {
      isLoading.value = false;
      isShowLoader = false;
      if (messageContent != null)
        cancellationMessageController.text = messageContent;

      this.updatingStatus.value = _actionType;
      debugPrint("updatingStatus.value: ${this.updatingStatus.value}");
      if ((_actionType == 'declined' || _actionType.contains('cancelled')) &&
          selectedReservationItem != null) {
        _updateCurrentPastTrips();
      }
    } else {
      checkNetwork(sendHostReservationStatus);
    }
  }

  void _updateCurrentPastTrips({dynamic selectedTripItem}) {
    if (tabBaritems.isNotEmpty) {
      List<dynamic> currentlistdata = tabBaritems[0].tabBarListData;
      List<dynamic> previouslistdata = tabBaritems[1].tabBarListData;
      currentlistdata.remove(selectedTripItem ?? selectedReservationItem);
      tabBaritems[0] = tabBaritems[0].copyWith(tabBarListData: currentlistdata);

      if (previouslistdata.isNotEmpty) {
        previouslistdata.insert(0, selectedTripItem ?? selectedReservationItem);
        tabBaritems[1] =
            tabBaritems[1].copyWith(tabBarListData: [], isTabLoading: true);
      }
    }
  }

  void pickFile([bool? isFromCamera]) async {
    onBack();
    if (!isFilesPicking.value) {
      callBackFunction();
    }
  }

  void callBackFunction() async {
    bool isNetconnected = await isNetworkConnected();
    isShowLoader = false;
    if (isNetconnected) {
      CommonFilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        compressionQuality: compressImageQuality,
        onFileLoading: (status) {
          isFilesPicking.value = (status == FilePickerStatus.picking);
          debugPrint("pick files: ${status}");
        },
      ).then((result) async {
        isFilesPicking.value = false;
        bool isnetConnected = await isNetworkConnected();
        if (isnetConnected) {
          List<PlatformFile> files = [];
          if (result != null) {
            Get.closeCurrentSnackbar();
            for (var pickfile in result.files) {
              files.add(pickfile);
            }
            files.sort((a, b) {
              return b.size.compareTo(a.size);
            });

            for (var xfile in files) {
              if (isInUploadpage) {
                uploadingPhotos.add(xfile.path ?? "");
                if (files.last == xfile && isInUploadpage) {
                  if (photoUploadingFuture != null) {
                    Future.wait([photoUploadingFuture!]).then((value) {
                      photoUploadingFuture = UploadSelectedFiles();
                    });
                  } else {
                    photoUploadingFuture = UploadSelectedFiles();
                  }
                }
              }
            }
          }
        }
      });
    }
  }

  Future<void> UploadSelectedFiles() async {
    List<String> filepaths = List.from(uploadingPhotos.value);
    removeablePhotos.forEach((element) {
      filepaths.remove(element);
    });
    if (filepaths.isNotEmpty) {
      File compressedfile;
      for (int i = 0; i < filepaths.length; i++) {
        String pickfile = filepaths[i];
        if (!isInUploadpage || removeablePhotos.contains(removeablePhotos)) {
          return;
        }

        if (scrollController.hasClients)
          scrollController.movetoposition(toBottom: true);
        compressedfile = File(pickfile);
        bool isnetConnected = await isNetworkConnected(isshowToast: false);
        if (isnetConnected) {
          if (removeablePhotos.isNotEmpty) {
            photoUploadCompleter = Completer();
          }

          Get.closeCurrentSnackbar();

          removeablePhotos = addItem(removeablePhotos, compressedfile.path);
          var uploadedfile = await uploadImage(
              file: compressedfile,
              uploadUrl: uploadClaimDamage,
              uploadingImages: uploadingPhotos);

          if (uploadedfile.isNotEmpty && uploadedfile != 'network') {
            Map<String, dynamic> uploadingmap =
                uploadedfile as Map<String, dynamic>;
            uploadingNetWorkPhotos.add(uploadingmap['filename'].toString());
          } else if (uploadedfile == 'network') {
            checkNetwork(UploadSelectedFiles);
          } else if (uploadedfile == '') {
            Get.back(result: {'removedeletedlisting': true});
          }
        } else {
          checkNetwork(UploadSelectedFiles);
        }
      }
    }
  }

  Future<XFile?> compressImage(String filePath) async {
    var filepathlist = filePath.split('.');
    String extension = 'png';
    if (filepathlist.last == 'png' ||
        filepathlist.last == 'jpeg' ||
        filepathlist.last == 'jpg') {
      extension = filepathlist.last;
    }
    var dir = Directory.systemTemp;
    var targetPath = dir.absolute.path +
        "/temp_${DateTime.now().millisecondsSinceEpoch}_${photocount}.${extension}";
    photocount++;
    final compressedImage = await FlutterImageCompress.compressAndGetFile(
        filePath, targetPath,
        minWidth: 700,
        minHeight: 700,
        quality: compressImageQuality,
        format: extension == 'png' ? CompressFormat.png : CompressFormat.jpeg);

    return compressedImage;
  }

  List<T> addItem<T>(List<T> list, T item) {
    List<T> listing = list.toSet().toList();
    listing.add(item);
    return listing;
  }

  String getClaimDamageTitle({required String status}) {
    switch (status) {
      case "requested":
        return label_requested_for_claim.tr;
      case "approved":
        return label_claim_details.tr;
      default:
        return label_claim_damage.tr;
    }
  }

  bool validateFields() {
    final firstEmptyField = switch (true) {
      _ when depositAmountController.Ttext.isEmpty => label_deposit_amount,
      _ when claimAmountController.Ttext.isEmpty => label_claim_amount,
      _ when reasonForClaimController.Ttext.isEmpty => label_reason_for_claim,
      _ => null,
    };

    double? claimAmount = double.tryParse(claimAmountController.Ttext);

    if (firstEmptyField != null) {
      showToast(error_msg_empty
          .trParams({"field": firstEmptyField.tr.toLowerCase()}));
      return false;
    }

    if(claimAmount != null) {
      if(claimAmount > securityDepositAmount) {
        showToast("claim_amount_greater".tr);
        return false;
      }
    } else {
      showToast("label_valid_claim_amount".tr);
      return false;
    }

    if (uploadingNetWorkPhotos.isEmpty) {
      showToast("label_please_upload_the_claim_image".tr);
      return false;
    }
    return true;
  }
}