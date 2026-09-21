import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:gozy/app.dart';
import 'package:gozy/config/client.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/graphql/__generated__/reservation_fragment.data.gql.dart';
import 'package:gozy/graphql/inbox/__generated__/Inbox.data.gql.dart';
import 'package:gozy/resources/app_colors.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/binding/main_binding.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/screens/views/guest/view_message/view_message_controller.dart';
import 'package:gozy/screens/views/home/home_controller.dart';
import 'package:gozy/screens/views/home/home_page.dart';
import 'package:gozy/utils/common_api_controller.dart';
import 'package:gozy/widgets/bottom_sheet/host_and_reviews_info/host_review_bottom_sheet.dart';
import 'package:gozy/widgets/common/custom_bottomsheet/custom_bottomsheet.dart';
import 'package:gozy/widgets/common/custom_container/custom_border_animated_container.dart';
import 'package:gozy/widgets/common/custom_container/custom_border_container.dart';
import 'package:gozy/widgets/common/custom_container/custom_counter_animated_container.dart';
import 'package:gozy/widgets/common/custom_network_image/custom_profile_network_image.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/conditional_parent_widget.dart';
import 'package:gozy/widgets/common/custom_button/custom_button.dart';
import 'package:gozy/widgets/common/custom_container/custom_container.dart';
import 'package:gozy/widgets/custom_stateful_widget.dart';
import 'package:gozy/widgets/custom_text.dart';
import 'package:gozy/widgets/custom_textfield.dart';
import 'package:gozy/widgets/shimmer.dart';
import 'package:gozy/widgets/show_done_view.dart';

import '../../../../widgets/report_user_view.dart';
import 'bottomsheet_controller.dart';

class ViewMessagePage extends CustomStatefulWidget {
  const ViewMessagePage({super.key});

  @override
  ViewMessagePageState createState() => ViewMessagePageState();
}

class ViewMessagePageState extends CustomStatefulWidgetState<ViewMessagePage> with TickerProviderStateMixin {
  late ViewMessageController controller = Get.find();

  ReportBottomSheetController reportBottomSheetController = Get.find<ReportBottomSheetController>();

  Timer? approveTimer;
  String sendIcon = "";
  bool isBorderContainer = false;
  String isFrom = "";
  double buttonBorderRadius = 0;
  double textFieldBorderRadius = 0;
  double? buttonTopPadding;
  double? borderRadiusSendIcBox;
  Color statusBgColor = appColors.appBGColor;
  Color? svgIconColor;
  bool isTimerExpired = false;
  bool isArrowNeeded = false;
  bool? isRoundIcon;
  Widget? sentIconWidget;

  @override
  void initState() {
    super.initState();
    controller.sentMessageController.clear();
    controller.threaditem = Get.arguments['threadItem'];
    var isFrom = Get.arguments['isFrom'];
    if (isFrom != null) this.isFrom = isFrom;
    controller.isUserTypeChange = Get.arguments['isUserTypeChange'];
    debugPrint("threadidviewmes: ${Get.arguments['threadId']} --- ${Get.arguments['message']}");
    controller.threadid = (Get.arguments['threadId'] is int)
        ? Get.arguments['threadId']
        : int.parse(Get.arguments['threadId'] ?? '0');

    controller.viewMessageCurrentpage.value = 1;
    if (controller.threadid == 0) {
      controller.threadid = int.parse(controller.threaditem?.threadItem?.threadId.toString() ?? '0');
    }

    controller.lifecycleListener = controller.registerLifeCycleListener(onResume: () {
      debugPrint("isSocketConnected.value : ${isSocketConnected.value} --- ${Get.currentRoute}");
      if (isSocketConnected.value != 1 && Get.currentRoute == '/ViewMessagePage') {
        controller.checkNetwork(controller.getThreads);
      }
    });

    controller.updatedThreadId.stream.listen((event) {
      debugPrint(' controller.updatedThreadId: $event');
      controller.threadid = event;
      getMessages();
    });
    getMessages();
    App().viewMessageSocketListener(appPreference.userID ?? '');
    controller.updatingStatus.listen((value) {
      debugPrint("updatingStatus value : $value---- ${controller.cancellationMessageController.Ttext}");
      if (controller.updatingStatus.value != '') {
        if (Get.isBottomSheetOpen ?? false) {
          Get.back();
        }
        String tempMessage = controller.cancellationMessageController.Ttext;
        controller.updateSentMessageThreads(
          messageType: controller.updatingStatus.value,
          message: tempMessage
        );

        controller.cancellationMessageController.clear();
        controller.updatingStatus.value = '';
      }
    });
    debugPrint("bottomviewpadding: $bottomViewPadding");
  }

  void getMessages() {
    controller.viewMessageList?.clear();
    controller.viewMessageCurrentpage.value = 1;
    isShowLoader = false;
    print("isLoading.value true 1");
    controller.isLoading.value = true;
    controller.checkNetwork(controller.getThreads);
  }

  void initThemeData() {
    switch (overALLThemeType) {
      case 1:
        sendIcon = Assets.drawableTheme1Send;
        buttonBorderRadius = 8;
        isArrowNeeded = true;
        isBorderContainer = true;
        sentIconWidget = _createSentIconTheme14ContainerWidget(RTLQuarterTurns: 2);
        break;
      case 2:
        sendIcon = Assets.drawableTheme2and4Send;
        buttonTopPadding = 0;
        svgIconColor = appColors.colorCommonLinkColor;
        sentIconWidget = _createSentIconTheme2ContainerWidget();
        break;
      case 3:
        sendIcon = Assets.drawableTheme3Send;
        buttonBorderRadius = 30;
        textFieldBorderRadius = 50;
        sentIconWidget = _createSentIconTheme3ContainerWidget();
        break;
      default:
        sendIcon = Assets.drawableTheme2and4Send;
        buttonBorderRadius = 16;
        textFieldBorderRadius = 15;
        borderRadiusSendIcBox = 15;
        isRoundIcon = true;
        sentIconWidget = _createSentIconTheme14ContainerWidget(RTLQuarterTurns: 3,size: 45);
    }
  }

  Widget _createSentIconTheme14ContainerWidget({int? RTLQuarterTurns,double? size}) {
    return GetBuilder(
        init: controller,
        id: controller.isRxBottomSheetLoading.id,
        builder: (context) {
          return CustomBorderAnimatedContainer(
            color: svgIconColor == null && controller.messagelength.value != 0
                ? appColors.secondaryColor
                : appColors.secondaryColor.withAlpha(60),
            borderWidth: 0,
            duration: const Duration(milliseconds: 250),
            height: size ?? 50,
            borderRadius: borderRadiusSendIcBox,
            width:  size ?? 50,
            isRetainFocus: true,
            padding: pad(a: 10),
            borderColor: appColors.stepChipSelectionColor,
            body: _createSentIcon(RTLQuarterTurns: RTLQuarterTurns),
            boxShadow: getBoxShadow(shadowColor: appColors.stepChipSelectionColor),
            onTap: () async {
              _sendMessage();
            },
          );
        });
  }

  Widget _createSentIconTheme2ContainerWidget() {
    return GetBuilder(
        init: controller,
        id: controller.isRxBottomSheetLoading.id,
        builder: (context) {
          return toOnTap(
            isRetainFocus: true,
            onTap: () async {
              _sendMessage();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 30,
              width: 30,
              padding: pad(end: controller.isRTL() ? 0 : 5, start: controller.isRTL() ? 5 : 0),
              child: _createSentIcon(RTLQuarterTurns: 3),
            ),
          );
        });
  }

  Widget _createSentIconTheme3ContainerWidget() {
    return GetBuilder(
        init: controller,
        id: controller.isRxBottomSheetLoading.id,
        builder: (context) {
          return CustomCounterAnimatedContainer(
            color: svgIconColor == null && controller.messagelength.value != 0
                ? appColors.secondaryColor
                : appColors.secondaryColor.withAlpha(60),
            duration: const Duration(milliseconds: 250),
            height: 45,
            width: 45,
            isRetainFocus: true,
            padding: pad(a: 10),
            body: _createSentIcon(RTLQuarterTurns: 3),
            boxShadow: getBoxShadow(shadowColor: appColors.stepChipSelectionColor),
            onTap: () async {
              _sendMessage();
            },
          );
        });
  }

  Widget? _createSentIcon({int? RTLQuarterTurns}) {
    return controller.isRxBottomSheetLoading.value
        ? controller.getLoader(
            loader: LottieLoaders.three_dots_loader.name,
            color: AppColors.staticwhite,
            changed: appThemeChanged.value)
        : sendIcon.toSVG(colour: svgIconColor, height: 32, width: 32,  quarterTurns: controller.isRTL() ?( RTLQuarterTurns ?? 2) : 0);
  }

  void _sendMessage() async {
    if (!controller.isRxBottomSheetLoading.value && controller.messagelength.value != 0) {
      controller.change(rxVariable: controller.isRxBottomSheetLoading, value: true);
      controller.messageType = 'message';
      controller.checkNetwork(controller.sentMessage);
      if (!await controller.isNetworkConnected(isshowToast: false)) {
        controller.change(rxVariable: controller.isRxBottomSheetLoading, value: false);
        controller.checkNetwork(controller.getThreads);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    initThemeData();

    return  CustomScaffold(
        controller: controller,
        isShowAppBar: true,
        action: Assets.drawableViewdetailReport.toSVG(colour: appColors.secondaryColor, size: 18).toCircle(
            padding: 9,
            margin: 15,
            onTap: () {
              _reportTheUser();
            }),
        isShowBGOnLoader: true,
        resizeToAvoidBottomInset: false,
        customAppBarFunction: () {
          backFunction();
        },
        backIconWidget: getBackIconWidget(
            themeType: overALLThemeType,
            onTap: () {
              backFunction();
            }),
        body: InputDoneView(
          controller,
          parentWidget:
        showBodyContentWidget().toPad(bottom: MediaQuery.of(context).viewInsets.bottom>0 ? MediaQuery.of(context).viewInsets.bottom+40 : 0 ),
      )
         ,
    );
  }

  void backFunction(){

    if (controller.isUserTypeChange ?? false) {
      appPreference.isOwner = !appPreference.isOwner!;
      controller.updateMessageRead();
    }
    if (isFrom == "" || Get.previousRoute.isNotEmpty) {
      Get.back();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          HomeController homeController = Get.find();
          if(Get.previousRoute == '/guestHomePage' && homeController.rxSelectedTab.value ==3) {
            isSocketConnected.value = 5;
          }
        });
    } else {
      Get.to(HomePage(), binding: MainBinding(), routeName: "/guestHomePage");
    }
  }

  GetBuilder<ViewMessageController> showBodyContentWidget() {
    return GetBuilder<ViewMessageController>(
        builder: (newController) => Obx(() {
              bool isshimmerloading = (controller.isLoading.value &&
                  (controller.viewMessageList == null || controller.viewMessageList!.isEmpty));
              return [
                if (!isshimmerloading && MediaQuery.of(context).viewInsets.bottom<=0) _getStatusTopWidget(),
                toReviewList(
                  reviewListScrollController: controller.viewMessageScrollController,
                  reviewList: controller.viewMessageList,
                  reviewsCount: controller.viewMessageListCount,
                  onApiFunction: controller.getThreads,
                  controller: controller,
                  currentPage: controller.viewMessageCurrentpage,
                  isDisableLoader: true,
                  isEnableListener: true,
                  isEnableSwipeToRefresh: false,
                  isPaginationLoaderAtBottom: false,
                  emptyWidget: const SizedBox.shrink(),
                  isShowEmpty: () {
                    return (controller.viewMessageList!.isEmpty && !controller.isLoading.value);
                  },
                  listView: _showListView(isshimmerloading),
                ).toShimmer(controller: controller).toStretch(),
                _getSentMessageBoxWidget().toPad(top: buttonTopPadding ?? 25,bottom: 15,horizontal: AppDimen.startMargin),
              ].toColumn();
            }),
    );
  }

  Widget _showListView(bool isshimmerloading) {
    int itemCount = controller.viewMessageList != null && controller.viewMessageList!.isNotEmpty
        ? controller.viewMessageList!.length
        : controller.isLoading.value
            ? 10
            : 0;


    return ShimmerLoading(
        widgetType: 'viewMessage',
        isLoading: isshimmerloading,
        isDarkMode: controller.isDarkMode(),
        darkModeblend: BlendMode.dstIn,
        child: toListView(
            itemCount: itemCount,
            controller: controller.viewMessageScrollController,
            key: const PageStorageKey<String>('viewmessagelist'),
            physics: ClampingScrollPhysics(),
            reverse: !isshimmerloading,
            padding: pad( top: 20,),
            itemBuilder: (context, index) {
              GgetThreadsData_getThreads_results_threadItems? item;
              if (controller.viewMessageList != null &&
                  controller.viewMessageList!.isNotEmpty &&
                  controller.viewMessageList!.length == itemCount) {
                item = controller.viewMessageList![index];
              }

              bool isStatus = item != null && item.type != null && item.type != 'message';
              bool isStatusAbove = false;
              if (itemCount > index + 1 && (controller.viewMessageList?.isNotEmpty ?? false)) {
                var itemAbove = controller.viewMessageList![index + 1];
                var statusType = ["message", "inquiry", "requestToBook", "intantBooking", "cancelledByHost", "cancelledByGuest"];
                isStatusAbove = itemAbove != null && itemAbove.type != null && !statusType.contains(itemAbove.type);
                if(itemAbove != null && itemAbove.type != null && itemAbove.type == "approved" && itemAbove.content != null) {
                  isStatusAbove = false;
                }
              }

              return [
                if (isStatus)
                  _getBookingStatusWidget(item!, !isStatusAbove, index ).toPad(horizontal: overALLThemeType ==4 ? 0 :AppDimen.startMargin),
                if ((item != null &&
                        item.sentBy == controller.appPreference.userID &&
                        item.content != null &&
                        item.content!.isNotEmpty) ||
                    isshimmerloading)
                  _getReceiverWidget(item, isshimmerloading, isRoundIcon) .toPad(horizontal: AppDimen.startMargin),
                if ((item != null &&
                        item.sentBy != controller.appPreference.userID &&
                        item.content != null &&
                        item.content!.isNotEmpty) ||
                    isshimmerloading)
                  _getSenterWidget(item, isshimmerloading, isRoundIcon) .toPad(horizontal: AppDimen.startMargin),
              ].toColumn();
            }));
  }

  Widget _getBookingStatusWidget(
      GgetThreadsData_getThreads_results_threadItems item, bool showTopDivider, int index) {
    debugPrint("abcviewmes _getBookingStatusWidget: ${item.type} --- $showTopDivider --- ${index}");
    (Color, String)? bookingStatusAndColor =
        controller.getReservationStatusColor(reservationstatus: item.type! );
    return bookingStatusAndColor != null
        ? [
            if (showTopDivider)
              [
                10.toHeight(),
                filterDivider,
                10.toHeight(),
              ].toColumn(),
      ConstrainedBox(
        constraints: BoxConstraints(maxWidth: deviceWidth - 50),
        child: Align(
          alignment: AlignmentDirectional.center,
          child: [
            15.toHeight().toCircle(color: bookingStatusAndColor.$1, padding: 5, margin: 5),
            Flexible(
              fit: FlexFit.loose,
              child: CustomText(
                text: bookingStatusAndColor.$2,
                size: AppDimen.textSize_14,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                isSoftWrap: false,
                textAlign: TextAlign.center,
              ),
            ),
          ].toRow(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ),
      ),
            6.toHeight(),
            CustomText(
              text: '${getDateFormat(dateFormat: commonDateFormat, milliSec: item.startDate).$1} ● ${getDateFormat(dateFormat: commonDateFormat, milliSec: item.endDate).$1}',
              color: appColors.placeholderColor,
              size: AppDimen.textSize_10,
              fontWeight: AppFont.regular,
            ),
            [
              10.toHeight(),
              filterDivider,
              10.toHeight(),
            ].toColumn(),
          ].toColumn(crossAxisAlignment: CrossAxisAlignment.center)
        : const SizedBox.shrink();
  }

  Widget _getReceiverWidget(
      GgetThreadsData_getThreads_results_threadItems? item, bool isshimmerloading, bool? isRoundIcon) {
    String? createdAt;
    if (item != null) {
      debugPrint("abcviewmes _getReceiverWidget: ${item.createdAt}");
      createdAt = getDateFormat(dateFormat: commonDateFormat, milliSec: item.createdAt).$1;
    }
    return [
      CustomContainer(
        width: deviceWidth - 80,
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage(
            controller.isRTL() ? Assets.drawableViewMessageReceiverBg : Assets.drawableViewMessageSenterBg,
          ),
          alignment: AlignmentDirectional.topEnd,
          fit: BoxFit.fitWidth,
          colorFilter: ColorFilter.mode(appColors.viewMessageSenterBGColor, BlendMode.srcIn),
        )),
        body: CustomBorderContainer(
          padding: pad(w: 15),
          margin: pad(end: 23),
          borderRadius: AppDimen.appBorderRadius / 2,
          color: appColors.viewMessageSenterBGColor,
          width: deviceWidth,
          body: [
            10.toHeight(),
            CustomText(
              text: isshimmerloading ? 20.toGenerateEmptyString() : (item?.content ?? '').trim() ?? '',
              fontWeight: FontWeight.normal,
              size: AppDimen.textSize_14,
            ),
            10.toHeight(),
            CustomText(
              text: isshimmerloading ? 20.toGenerateEmptyString() : createdAt ?? '',
              fontWeight: FontWeight.normal,
              size: AppDimen.textSize_12,
              color: appColors.placeholderColor.withValues(alpha: 0.7),
            ),
            10.toHeight(),
          ].toColumn(),
        ),
      ),
      15.toWidth(),
      CustomProfileNetworkImage(
          imageUrl: (controller.senterProfile?.picture ?? ''),
          all: 50,
          profileImageType: overALLAppLayoutModel?.profileIconType ?? '',
          isShimmerView: isshimmerloading,
          shimmerColor: appColors.viewMessageSenterBGColor,
          isRoundIcon: isRoundIcon,
          onTap: () {
            HostReviewBottomSheet().showHostInfo(
                hostItem: controller.senterProfile,
                profileId: controller.senterProfile?.profileId,
                title: label_title_user_profile.tr,
                isHost: false);
          }).toPad(start: deviceWidth - 97),
    ].toStack().toPad(vertical: 10);
  }

  Widget _getSenterWidget(
      GgetThreadsData_getThreads_results_threadItems? item, bool isshimmerloading, bool? isRoundIcon) {
    String? createdAt;
    if (item != null) {
      createdAt = getDateFormat(dateFormat: commonDateFormat, milliSec: item.createdAt).$1;
    }
    return [
      CustomContainer(
          width: deviceWidth,
          margin: pad(start: 30),
          decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage(controller.isRTL()
                ? Assets.drawableViewMessageSenterBg
                : Assets.drawableViewMessageReceiverBg),
            alignment: AlignmentDirectional.topStart,
            fit: BoxFit.fitWidth,
            colorFilter: ColorFilter.mode(appColors.viewMessageReceiverBGColor, BlendMode.srcIn),
          )),
          body:
           CustomBorderContainer(
              padding: pad(start: 10, end: 10),
              margin: pad(
                start: 22,
              ),
              borderRadius: AppDimen.appBorderRadius / 2,
              color: appColors.viewMessageReceiverBGColor,
              width: deviceWidth,
              body: [
                10.toHeight(),
                CustomText(
                  text: isshimmerloading ? 20.toGenerateEmptyString() : (item?.content ?? '').trim() ?? '',
                  fontWeight: FontWeight.normal,
                  size: AppDimen.textSize_14,
                ),
                10.toHeight(),
                CustomText(
                    text: isshimmerloading ? 20.toGenerateEmptyString() : createdAt ?? '',
                    fontWeight: FontWeight.normal,
                    size: AppDimen.textSize_12,
                    color: appColors.placeholderColor.withValues(alpha: 0.7)),
                10.toHeight(),
              ].toColumn())).toPad(start: 4),
           CustomProfileNetworkImage(
          imageUrl: (controller.receiverProfile?.picture ?? ''),
          all: 50,
          profileImageType: overALLAppLayoutModel?.profileIconType ?? '',
          isShimmerView: isshimmerloading,
          shimmerColor: appColors.viewMessageReceiverBGColor,
          isRoundIcon: isRoundIcon,
          onTap: () {
            HostReviewBottomSheet().showHostInfo(
                hostItem: controller.receiverProfile,
                profileId: controller.receiverProfile?.profileId,
                isHost: false);
          }),
    ].toStack().toPad(vertical: 10);
  }

  Widget _getSentMessageBoxWidget() {
    return [
      if (overALLThemeType == 2) ...[
        filterDivider.toFitToDeviceWidth().toResizeWidget(height: 1),
        10.toHeight(),
      ],
      ConditionalParentWidget(
        condition: overALLThemeType == 3 || overALLThemeType == 4,
        parentBuilder: (child) => CustomBorderContainer(
            borderRadius: textFieldBorderRadius,
            height: 55,
            width: deviceWidth,
            borderWidth: 1,
            padding: pad(w: 5),
            borderColor: (controller.messageFocusNode.hasFocus ?? false) ? appColors.black : (appColors.filterDividerColor.withAlpha(100)),
            body: child),
        child: IntrinsicHeight(
          child: [
            (isBorderContainer
                    ? CustomBorderContainer(
                        borderColor: appColors.filterDividerColor,
                        borderWidth: 1,
                        padding: EdgeInsetsDirectional.only(top: 2, bottom: 2, end: 2, start: 10),
                        body: _messageTextField(),
                      )
                    : CustomContainer(
                        padding: EdgeInsetsDirectional.only(top: 2, bottom: 2, end: 2, start: 10),
                        body: _messageTextField(),
                      ))
                .toStretch(),
            5.toWidth(),
            sentIconWidget ?? 0.toHeight(),
          ].toRow(),
        ),
      ),
    ].toColumn();
  }

  Widget _getStatusTopWidget() {
    String status = (controller.threadItemForType?.type ?? '').toLowerCase();
    debugPrint('_getStatusTopWidget: $status');
    Widget? buttonWidget, timerWidget;
    String title = '', desc = '';
    switch (status) {
      case 'cancelledbyhost' || 'cancelledbyguest':
        statusBgColor = appColors.viewMessageOrangeColor;
        title = label_view_msg_booking_is_cancelled.tr.replaceAll('.', '');
        desc = '${label_your.tr} ${label_view_msg_booking_is_cancelled.tr.toLowerCase()}';
        break;

      case 'expired':
        statusBgColor = appColors.viewMessageOrangeColor;
        if (appPreference.isOwner ?? false) {
          title = label_view_msg_host_expired_title.tr;
          desc = label_view_msg_host_expired_desc
              .trParams({'field': controller?.receiverProfile?.firstName ?? ''});
        } else {
          title = label_booking_expired.tr;
          desc = "${label_your.tr} ${label_booking_expired.tr.toLowerCase()}";
        }
        break;
      case 'completed':
        statusBgColor = appColors.viewMessageGreenColor;
        title = label_view_msg_trip_is_completed
            .trParams({
              'field': (appPreference.isOwner ?? false)
                  ? label_reservation.tr.toLowerCase()
                  : label_trip_single.tr.toLowerCase()
            })
            .toUpperLowerCase()
            .replaceAll('.', '');
        desc = (appPreference.isOwner ?? false)
            ? label_view_msg_reservation_of_your_listing_completed.tr
            : '${label_your.tr} ${label_view_msg_trip_is_completed.trParams({
                    'field': label_trip_single.tr.toLowerCase()
                  }).toLowerCase()}';
        break;
      case 'declined':
        statusBgColor = appColors.viewMessageOrangeColor;
        title = label_view_msg_request_declined.tr.replaceAll('.', '');
        desc = label_decline_content.tr;
        break;
      case 'requesttobook':
        statusBgColor = appColors.viewMessageGreenColor;
        if (appPreference.isOwner ?? false) {
          if (isTimerExpired) {
            title = label_view_msg_host_inquiry_request_expired.tr;
          } else {
            title = label_view_msg_host_request_to_book_title
                .trParams({'field': controller.receiverProfile?.firstName ?? ''});
            desc = label_view_msg_host_inquiry_description
                .trParams({'field': controller.receiverProfile?.firstName ?? ''});
            if (approveTimer != null) approveTimer?.cancel();
            _setTime();
            timerWidget = getTimerWidget(timerContent: label_view_msg_host_inquiry_timer_desc_content);
            buttonWidget = [
              messageButton(
                buttonText: label_trip_menu_accept.tr,
                onTap: () {
                  controller.updatingStatus.value = '';
                  controller.updateReservationStatusFromViewMsg(
                      updatingStatus: 'approved', threadItemFortype: controller.threadItemForType);
                },
              ),
              15.toWidth(),
              messageButton(
                buttonText: label_trip_menu_decline.tr,
                isPrimaryButton: false,
                onTap: () {
                  controller.updatingStatus.value = '';
                  controller.updateReservationStatusFromViewMsg(
                      updatingStatus: 'declined', threadItemFortype: controller.threadItemForType);
                },
              ),
            ].toRow(mainAxisAlignment: MainAxisAlignment.start);
          }
        } else {
          title = label_view_msg_request_book_title
              .trParams({'field': controller?.receiverProfile?.firstName ?? ''});
          desc =
              '${label_view_msg_most_owner_respondwithin_hours.trParams({'field': respondHours.toString()})}';
        }
        break;
      case 'preapprove' ||  'preapproved':
        if (appPreference.isOwner ?? false) {
          statusBgColor = appColors.viewMessageOrangeColor;
          title = label_view_msg_host_request_approved.tr;
          desc = label_view_msg_host_request_preapproved_content.trParams({'field': respondHours.toString()});
        } else {

          if (approveTimer != null) approveTimer?.cancel();
          _setTime();
          if (isTimerExpired) {
            statusBgColor = appColors.viewMessageOrangeColor;
            title = label_view_msg_guest_preapprove_book_expired.tr;
            desc = label_view_msg_guest_preapprove_book_expired_desc.tr;
            buttonWidget = messageButton(
              buttonText: label_view_msg_guest_preapprove_book_expired_button.tr,
              onTap: () {
                controller.moveToListDetailPage();
              },
            );
          } else {
            statusBgColor = appColors.viewMessageOrangeColor;
            title = label_view_msg_guest_preapprove_book_title
                .trParams({'field': controller.receiverProfile?.firstName ?? ''});
            timerWidget = getTimerWidget(timerContent: label_view_msg_guest_preapprove_book_desc);
            buttonWidget = messageButton(
              buttonText: label_book.tr,
              onTap: () {
                debugPrint("contorller: ${controller.viewMessageList?.last?.startTime} ---- ${controller.viewMessageList?.last?.endTime}");
                controller.checkNetwork(controller.checkUserInfoValidation);
              },
            );
          }
        }
        break;
      case 'inquiry':
        statusBgColor = appColors.viewMessageOrangeColor;
        if (appPreference.isOwner ?? false) {
          if (approveTimer != null) approveTimer?.cancel();
          _setTime();

          if (!isTimerExpired) {
            title = label_view_msg_host_inquiry_title
                .trParams({'field': controller.receiverProfile?.displayName ?? ''});
            desc = label_view_msg_host_inquiry_description
                .trParams({'field': controller.receiverProfile?.displayName ?? ''});
            debugPrint("controller.messageType: ${controller.messageType}");
            timerWidget = getTimerWidget(timerContent: label_view_msg_host_inquiry_timer_desc_content);
            buttonWidget = messageButton(
              buttonText: label_view_msg_host_preapprove_button.tr,
              onTap: () {
                debugPrint("approveTimer: ${approveTimer} --- ${controller.isLoading.value}");
                if (approveTimer != null) approveTimer?.cancel();
                if (!controller.isLoading.value) {
                  controller.reservationId = controller.threadItemForType?.reservationId ?? 1;
                  controller.messageType = 'preApproved';
                  isShowLoader = true;
                  print("isLoading.value true 2");
                  controller.isLoading.value = true;
                  controller.checkNetwork(controller.sentMessage);
                  Future.delayed(const Duration(milliseconds: 1500)).then((value) {
                    if (approveTimer != null) approveTimer?.cancel();
                  });
                }
              },
            );
          } else {
            title = label_view_msg_host_inquiry_request_expired.tr;
          }
        } else {
          title = label_view_msg_host_inquiry_guest_title
              .trParams({'field': controller.receiverProfile?.firstName ?? ''});
          desc = label_inquery_guest_content.tr;
          buttonWidget = messageButton(
            buttonText: label_request_to_book.tr,
            onTap: () {
              controller.moveToListDetailPage();
            },
          );
        }
        break;
      case 'intantbooking' || 'approved':
        statusBgColor = appColors.viewMessageGreenColor;
        if (status == "approved") {
          title = (status == 'approved' && !appPreference.isOwner!)
              ? label_view_msg_guest_approved_title
                  .trParams({'field': controller?.senterProfile?.firstName ?? ''})
              : label_view_msg_booking_is_confimed.tr;
          desc = '${label_view_msg_booking_confirmed_description.trParams({
                'field': (appPreference.isOwner ?? false)
                    ? label_renter_title_word.tr.toLowerCase()
                    : label_owner.tr.toLowerCase()
              })}';
        } else {
          title = !appPreference.isOwner!
              ? label_view_msg_guest_approved_content
                  .trParams({'field': controller?.senterProfile?.firstName ?? ''})
              : label_view_msg_booking_is_confimed.tr;
          desc = '${label_view_msg_booking_confirmed_description.trParams({
                'field': (appPreference.isOwner ?? false)
                    ? label_renter_title_word.tr.toLowerCase()
                    : label_owner.tr.toLowerCase()
              })}';
        }
        buttonWidget = messageButton(
          buttonText:
              '${label_cancel.tr} ${(!appPreference.isOwner!) ? label_trip_single.tr.toLowerCase() : label_reservation.tr.toLowerCase()}',
          onTap: () async {
            FocusManager.instance.primaryFocus!.unfocus();
            isShowLoader = true;

            controller.isLoading.value = true;
            if (currencyRates == null) {
              await controller.getCurrencyRates();
            }
            controller.reservationId = controller.threadItemForType?.reservationId ?? 1;

            GreservationFragmentData? fragmentData =
                controller.getReservationInfo(reservationId: controller.reservationId).$1;
            if (fragmentData != null) {
              controller.showCancellationSheet(fragmentData, sheetCloseListener: () {
                isShowLoader = false;
              });
              return;
            }
    print("isLoading.value true 3: ${ controller.viewMessageList?.last?.reservationId} --- ${controller.threadItemForType?.reservationId}");
            if(controller.reservationId ==1){
              controller.checkNetwork(controller.getThreadReservationId);
            } else {
              controller.checkNetwork(controller.getReservation);
            }
          },
        );
        break;
    }

    return title.isNotEmpty || desc.isNotEmpty
        ? CustomContainer(
            color: statusBgColor,
            width: deviceWidth,
            padding: pad(w: AppDimen.startMargin, h: 20),
            body: [
              CustomText(text: title),
              10.toHeight(),
              if (desc.isNotEmpty)
                CustomText(
                  text: desc,
                  size: AppDimen.textSize_12,
                  color: appColors.placeholderColor,
                  fontWeight: FontWeight.normal,
                ),
              if (timerWidget != null) timerWidget.toPad(top: 10),
              if (buttonWidget != null) buttonWidget.toPad(top: 15),
            ].toColumn(),
          )
        : const SizedBox.shrink();
  }

  Widget getTimerWidget({required String timerContent}) {
    final point = StackTrace.current.toString().split('\n')[1];
    print('getTimerWidget --- test9 $point');
    approveTimer?.cancel();
    approveTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _setTime();
    });
    return [
      Assets.drawableViewMsgTimerIcon.toSVG(colour: appColors.black).toPad(top: 3),
      5.toWidth(),
      GetBuilder<ViewMessageController>(
        id: 'timeleft',
        builder: (newController) => CustomText(
          text: timerContent.trParams({'field': controller.timeleft}),
          size: AppDimen.textSize_12,
          color: appColors.placeholderColor,
          fontWeight: FontWeight.normal,
        ),
      ).toStretch(),
    ].toRow(crossAxisAlignment: CrossAxisAlignment.start);
  }

  @override
  void dispose() {
    super.dispose();
    contactHostBookingType = '';
    controller.lifecycleListener?.dispose();
    approveTimer?.cancel();
  }

  void _setTime() {
    int timediff =
        DateTime.now().millisecondsSinceEpoch - int.parse(controller.threadItemForType?.createdAt ?? '0');
    timediff = (respondHours * 60 * 60 * 1000) - timediff - 1000;
    if (timediff > 0) {
      controller.timeleft = Duration(milliseconds: timediff).convertToReadableDuration();
      controller.update(['timeleft']);
    } else {
      isTimerExpired = true;
      if (approveTimer != null && approveTimer!.isActive) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.update();
        });
        approveTimer?.cancel();
      }
    }
  }

  Widget messageButton({String? buttonText, GestureTapCallback? onTap, bool isPrimaryButton = true}) {
    return CancelButton(
      buttonText: '$buttonText',
      isExpand: false,
      isPrimaryButton: isPrimaryButton,
      fillcolor: isPrimaryButton ? appColors.primaryColor : appColors.white,
      color: appColors.primaryColor,
      isResizeText: true,
      isArrowNeeded: isArrowNeeded,
      borderRadius: buttonBorderRadius,
      horizontalPadding: 15,
      verticalPadding: 7,
      textSize: AppDimen.textSize_14,
      onTap: onTap,
    );
  }

  void _reportTheUser() {
    showCustomBottomSheet(
      backButtonWidget: getBackIconWidget(
        themeType: overALLThemeType,
        backIcon: overALLAppLayoutModel!.backIcon,
      ),
      contentWidget: ReportUserView(
          controller: reportBottomSheetController,
          selectedReportReason: reportBottomSheetController.selectedReportingReason,
          ReportReasonList: reportReasons,
          onTap: () {
            if (reportBottomSheetController.selectedReportingReason.value != -1) {
              reportBottomSheetController.selectedProfileid = controller.receiverProfile?.profileId;
              debugPrint("profileid: ${reportBottomSheetController.selectedProfileid}");
              controller.checkNetwork(reportBottomSheetController.reportUser);
            } else {
              controller.showToast(error_msg_not_select_option.tr);
            }
          }),
      titleFontSize: AppDimen.textSize_18,
      sheetCloseListener: () {
        FocusManager.instance.primaryFocus?.unfocus();
      }
    );
  }

  Widget? _messageTextField() {
    return CustomTextField(
      hintText: label_type_something.tr,
      controller: controller.sentMessageController,
      keyboardType: TextInputType.multiline,
      focusNode:  controller.messageFocusNode,
      enableSuggestions: true,
      hintFontWeight: FontWeight.normal,
      onChanged: (value) {
        controller.sentMessageText = controller.sentMessageController.Ttext;
        controller.messagelength.value = controller.sentMessageController.Ttext.length;
        controller.change(rxVariable: controller.isRxBottomSheetLoading, value: false);
        debugPrint('controller.messagelength.value: ${controller.messagelength.value}');
      },
    );
  }
}