import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/config/client.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/graphql/__generated__/reservation_fragment.data.gql.dart';
import 'package:gozy/resources/app_colors.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_layout.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/screens/views/guest/my_trips/my_trip_list_controller.dart';
import 'package:gozy/widgets/bottom_sheet/host_and_reviews_info/host_review_bottom_sheet.dart';
import 'package:gozy/widgets/cancellation_policy_view.dart';
import 'package:gozy/widgets/common/custom_bottomsheet/custom_bottomsheet.dart';
import 'package:gozy/widgets/common/custom_container/custom_border_container.dart';
import 'package:gozy/widgets/common/custom_container/custom_bottom_item_shadow_container.dart';
import 'package:gozy/widgets/common/custom_network_image/custom_profile_network_image.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/common/custom_textfield/custom_textfield_area.dart';
import 'package:gozy/widgets/conditional_parent_widget.dart';
import 'package:gozy/widgets/common/custom_button/custom_button.dart';
import 'package:gozy/widgets/custom_text.dart';
import 'package:gozy/widgets/custom_textfield.dart';
import 'package:gozy/widgets/dotted_border/dotted_border.dart';
import 'package:gozy/widgets/explore_listing_item_widgets.dart';
import 'package:gozy/widgets/show_done_view.dart';

import '../../../constant.dart';
import '../../../resources/app_lang.dart';
import '../../../screens/views/home_item_detail/home_item_detail.dart';
import '../../common_extension_functions.dart';
import '../bottom_sheet_refresh_controller.dart';

class CancelTripBottomSheet {
  late MyTripListController _controller;
  double? borderRadius;
  double? sizeOfSvg;
  bool isInputThemeFour = false;
  bool isChipView = false;
  bool isShowDotForCarType = true;
  Color? listingDetailInfoBgColor = appColors.theme4AppBarBg;
  double? containerBorderRadius;
  Color? borderColor;
  Color? missEarnContainerColor;
  Color? missEarnContainerBorderColor;
  Color? nonFundContainerBorderColor;
  FocusNode messagefocusNode = FocusNode();

  CancelTripBottomSheet(
      {required dynamic receiptItem,
      required MyTripListController controller,
      Function? sheetCloseListener}) {
    _controller = controller;
    showCustomBottomSheet(
      contentWidget: GetBuilder<BottomSheetController>(
        builder: (newController) {
          listingDetailInfoBgColor = appColors.theme4AppBarBg;
          return GetBuilder(
            init: _controller,
            id: controller.isRxBottomSheetLoading.id,
            builder: (context) {
              return controller.isRxBottomSheetLoading.value
                  ? Center(
                      child: _controller.getLoader(
                              loader: LottieLoaders.three_dots_loader.name,
                              changed: appThemeChanged.value,
                              color: appColors.secondaryColor)
                          .toResizeWidget(all: 120))
                  : (_controller.cancellationData?.cancelReservationData?.results?.listId != null)
                      ? InputDoneView(_controller,
                              bottompadding: 0,
                              toppadding: 20,
                              parentWidget: [
                                CustomTitleText(
                                  text: "${label_cancel.tr} ${_controller.appPreference.isOwner! ? label_reservation.tr.toLowerCase() : label_trip_single.tr.toLowerCase()}",
                                  size: AppDimen.textSize_22,
                                  fontWeight: AppFont.semiBold,
                                ).toPad(horizontal: 24),
                                15.toHeight(),
                                getCancelTripBottomSheet(receiptItem: receiptItem, controller: controller)
                                    .toScroll()
                                    .toPad(bottom: 5),
                                _buildKeepAndCancelTripButton(receiptItem: receiptItem),
                              ].toScroll())
                          .toFitToDeviceWidth()
                      : 0.toHeight();
            },
          );
        },
      ),
      backButtonWidget: getBackIconWidget(
        backIcon: overALLAppLayoutModel!.backIcon,
      ),
      titleFontSize: AppDimen.textSize_20,
      sheetCloseListener: sheetCloseListener,
    );
  }

  Widget getCancelTripBottomSheet(
      {required GreservationFragmentData receiptItem, required BaseController controller}) {
    if (appLayoutMap[AppLayout.inputType]?.themeType == 4) {
      isInputThemeFour = true;
    }
    switch (overALLThemeType) {
      case 1:
        borderRadius = 6;
        containerBorderRadius = 6;
        borderColor = appColors.colorCommonLinkColor;
        missEarnContainerBorderColor = appColors.errorRed;
        missEarnContainerColor = appColors.cancelTripNonRefundableBGColor;
        nonFundContainerBorderColor = appColors.refundGreenBorderColor;
        break;
      case 2:
        borderRadius = 0;
        containerBorderRadius = 0;
        borderColor = appColors.black;
        missEarnContainerBorderColor = appColors.errorRed;
        missEarnContainerColor = Colors.transparent;
        nonFundContainerBorderColor = appColors.refundGreenBorderColor;
        break;
      case 3:
        borderRadius = 12;
        containerBorderRadius = 18;
        borderColor = appColors.black;
        listingDetailInfoBgColor = appColors.myTripsBGColor;
        missEarnContainerColor = appColors.cancelTripNonRefundableBGColor;
        nonFundContainerBorderColor = Colors.transparent;
        break;
      default:
        borderRadius = 12;
        containerBorderRadius = 18;
        borderColor = appColors.colorCommonLinkColor;
        missEarnContainerBorderColor = appColors.errorRed;
        missEarnContainerColor = appColors.cancelTripNonRefundableBGColor;
        nonFundContainerBorderColor = appColors.refundGreenBorderColor;
        isShowDotForCarType = false;
        sizeOfSvg = 14;
        isChipView = true;
        break;
    }
    Widget cancellationWidget = _buildCancellationPolicyInfo(receiptItem: receiptItem);
    List<Widget> ListItemWidgets = [];
    ListItemWidgets.add(_userTravelInfoWidget(receiptItem: receiptItem)
        .toPad(horizontal: AppDimen.startMargin, vertical: 20));
    ListItemWidgets.add(
        _userRideInfoWidget(receiptItem: receiptItem).toPad(horizontal: AppDimen.startMargin, vertical: 20));
    ListItemWidgets.add(
        _HostInfoWidget(receiptItem: receiptItem).toPad(horizontal: AppDimen.startMargin, vertical: 20));
    ListItemWidgets.add(
        _cancelAmountWidget(receiptItem: receiptItem).toPad(horizontal: AppDimen.startMargin, vertical: overALLThemeType == 4 ? 0 : 20));
    ListItemWidgets.add(cancellationWidget.toPad(horizontal: AppDimen.startMargin, vertical: 20));
    List<Widget> ListItemWidgetsWithDivider =
        ListItemsWithDivider(WidgetList: ListItemWidgets, space: 0, horizontalPad: AppDimen.startMargin, isPadForDivider: overALLThemeType == 4, noDividerIndices: {overALLThemeType == 4 ? 2 : -1});
    ListItemWidgetsWithDivider.insert(0, _buildListingDetailInfo(receiptItem: receiptItem));
    return ListItemWidgetsWithDivider.toColumn();
  }

  Widget _buildListingDetailInfo({required GreservationFragmentData receiptItem}) {
    String listphoto = receiptItem.listData?.listPhotoName ?? '';
    return toOnTap(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        Get.to(() => HomeItemDetailView(), arguments: [receiptItem.listData, "cancel_trip"],)?.then((val) {
          FocusManager.instance.primaryFocus?.unfocus();
        });
      },
      child: ConditionalParentWidget(
        condition: overALLThemeType == 4,
        parentBuilder: (child) => DottedBorderView(
            borderRadius: borderRadius, dottedlineColor: appColors.colorCommonLinkColor, child: child).toPad(horizontal: 6),
        child: CustomBorderContainer(
          color: listingDetailInfoBgColor,
          borderRadius: overALLThemeType != 4 ? 0 : borderRadius,
          body: toListImageRow(
                  showBorderForImage: true,
                  borderRadius: borderRadius,
                  borderColor: borderColor,
                  containerBorderRadius: containerBorderRadius,
                  photo: imgListingMedium + listphoto,
                  id: receiptItem.listData!.id!,
                  placeholderURL: imgListingSmall + listphoto,
                  ListItemWidgets: ConfirmPayListingHeaderWidget(
                      itemInfo: receiptItem.listData,
                      listTitle: receiptItem.listTitle,
                      isOrderChangeVar: true,
                      showDotForCarType: isShowDotForCarType,
                      isChipView: isChipView,
                      ratingColor: appColors.textColor,
                      sizeOfSvg: sizeOfSvg)
          )
              .toPad(horizontal: AppDimen.startMargin - (overALLThemeType == 4 ? 6 : 0), vertical: 20),
        ),
      ),
    );
  }

  Widget _userTravelInfoWidget({GreservationFragmentData? receiptItem}) {
    return [
      _userstayingForWidget(receiptItem: receiptItem),
    ].toColumn();
  }

  Widget _userRideInfoWidget({GreservationFragmentData? receiptItem}) {
    return [
      _userTravellingWithWidget(receiptItem: receiptItem),
    ].toColumn();
  }

  Widget _userstayingForWidget({GreservationFragmentData? receiptItem}) {
    return basecontroller.reservationDateInfo(
        checkinDate: receiptItem?.checkIn ?? '',
        checkoutDate: receiptItem?.checkOut ?? '',
        dateColor: appColors.customTextColor,
        timeColor: appColors.customTextColor,
        checkinTime: receiptItem?.startTime.toString() ?? '',
        checkoutTime: receiptItem?.endTime.toString() ?? '',
        headerFontSize: AppDimen.textSize_14,
        fontSize: AppDimen.textSize_16,
        fontWeight: AppFont.medium, isFromCancelTrip: true);
  }

  Widget _userTravellingWithWidget({GreservationFragmentData? receiptItem}) {
    var startsIn = _controller.cancellationData?.cancelReservationData?.results?.startedIn ?? 0;
    bool isLessThanZero = false;
    String starts = "";
    if (startsIn < 0) {
      starts =
          "${startsIn.abs()} ${label_day.trPlural(dayPlural.tr, startsIn.abs())} ${label_cancel_trip_started_days_ago.tr}";
      isLessThanZero = true;
    }
    var ridingFor = _controller.cancellationData?.cancelReservationData?.results?.rentingFor ?? 0;
    return IntrinsicHeight(
      child: [
        Expanded(
          child: _customDateTimeView(
            headerText: label_starts_in.tr,
            date: isLessThanZero ? starts : "$startsIn ${label_day.trPlural(dayPlural.tr, startsIn)}",
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ),
        Align(
        alignment: Alignment.center,
         child: SizedBox(width: 15,).toPad(end: 26)),
        Expanded(
          child: _customDateTimeView(
            headerText: label_riding_for.tr,
            date: "${ridingFor.round()} ${label_day.trPlural(dayPlural.tr, ridingFor.round())}",
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ),
      ].toRow(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start),
    );
  }

  Widget _customDateTimeView(
      {CrossAxisAlignment? crossAxisAlignment, String headerText = "", String date = ""}) {
    return [
      CustomText(
        text: headerText,
        size: AppDimen.textSize_18,
        fontWeight: AppFont.medium,
      ),
      6.toHeight(),
      CustomText(
        text: date,
        size: AppDimen.textSize_14,
        fontWeight: AppFont.regular,
      ),
      4.toHeight(),
    ].toColumn(mainAxisSize: MainAxisSize.min, crossAxisAlignment: crossAxisAlignment);
  }

  Widget _HostInfoWidget({GreservationFragmentData? receiptItem}) {
    String user = _controller.appPreference.isOwner! ? label_guest.tr : label_host.tr;
    String? profilepic = _controller.appPreference.isOwner!
        ? _controller.cancellationData?.cancelReservationData?.results?.guestProfilePicture
        : _controller.cancellationData?.cancelReservationData?.results?.hostProfilePicture;
    String? username = _controller.appPreference.isOwner!
        ? _controller.cancellationData?.cancelReservationData?.results?.guestName
        : _controller.cancellationData?.cancelReservationData?.results?.hostName;
    dynamic userItem = _controller.appPreference.isOwner!
        ? receiptItem?.guestData
        : _controller.cancellationData?.cancelReservationData?.results?.listData?.user;
    int? profileId = _controller.appPreference.isOwner!
        ? receiptItem?.guestData?.profileId
        : receiptItem?.hostData?.profileId;
    return [
      CustomTitleText(
        text: label_tell_me_why_cancel.trParams({'field': _controller.appPreference.isOwner! ? label_renter_title_word.tr.toLowerCase() : label_owner.tr.toLowerCase()}),
        size: AppDimen.textSize_18,
      ),
      20.toHeight(),
      appPreference.isOwner!
          ? toOnTap(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              HostReviewBottomSheet().showHostInfo(
                  hostItem: userItem, profileId: profileId, isHost: !appPreference.isOwner!);
            },
            child: HostReviewBottomSheet().ProfileInfoWidget(
                user: user,
                profilepic: profilepic,
                username: username,
                userItem: userItem,
                profileId: profileId,
                linkTextColor: overALLThemeType == 1 ? appColors.secondaryColor : appColors.customTextColor,
                isCancel: true,
                listid: _controller.cancellationData?.cancelReservationData?.results?.listId,
                starRating:
                    _controller.cancellationData?.cancelReservationData?.results?.listData?.reviewsStarRating,
                reviewCount:
                    _controller.cancellationData?.cancelReservationData?.results?.listData?.reviewsCount,
              ),
          )
          : toOnTap(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              HostReviewBottomSheet().showHostInfo(
                  hostItem: userItem, profileId: profileId, isHost: !appPreference.isOwner!);
            },
            child: [
                CustomProfileNetworkImage(
                    profileImageType: overALLAppLayoutModel?.profileIconType ?? '',
                    imageUrl: profilepic.toString(),
                    all: 60),
                12.toWidth(),
                [
                  RichText(
                    text: TextSpan(
                      children: getTextSpans(
                        primaryText: '${label_owned_by.tr} ${username!}',
                        highlightColor: overALLThemeType == 1 ? appColors.secondaryColor : appColors.customTextColor,
                        searchTextWithLinks: <String, GestureTapCallback>{
                          username: () {
                            HostReviewBottomSheet().showHostInfo(
                                hostItem: userItem, profileId: profileId, isHost: !appPreference.isOwner!);
                          }
                        },
                        fontSize: AppDimen.textSize_18,
                        fontWeight: AppFont.medium,
                        primaryTextFontWeight: AppFont.medium
                      ),
                      style: TextStyle(
                          fontFamily: AppFont.font, color: appColors.black, fontSize: AppDimen.textSize_17),
                    ),
                  ),
                  4.toHeight(),
                  CustomText(
                      text:
                          "${label_joined_in.tr} ${getDateFormat(dateFormat: userProfileCreateFormat, milliSec: _controller.cancellationData?.cancelReservationData?.results?.guestCreatedAt).$1}",
                      fontWeight: AppFont.regular,
                      size: AppDimen.textSize_16),
                ].toColumn(mainAxisAlignment: MainAxisAlignment.center).toStretch(),
              ].toRow(mainAxisAlignment: MainAxisAlignment.start),
          ),
      20.toHeight(),
      isInputThemeFour
          ? TitleTextField(
              hintText: "${enter_your.tr} ${label_reason_to_cancel_reson.tr}",
              controller: _controller.cancellationMessageController,
              focusNode: messagefocusNode,
              borderTextfieldPadding: pad(top: 10),
              keyboardType: TextInputType.multiline,
              maxLines: 6,
            )
          : CustomTextfieldArea(
              hintText: "${enter_your.tr} ${label_reason_to_cancel_reson.tr}",
              controller: _controller.cancellationMessageController,
              minLines: 6,
              focusNode: messagefocusNode,
              borderTextfieldPadding: pad(w: 18, h: 10),
              maxLines: 6,
            ),
      12.toHeight(),
      CustomText(
        text: label_will_be_cancelled_immediately.trParams({
          'field':
              '${label_this_word_only.tr} ${_controller.appPreference.isOwner! ? label_reservation.tr.toLowerCase() : label_trip_single.tr.toLowerCase()}'
        }),
        size: AppDimen.textSize_14,
        fontWeight: AppFont.regular,
      )
    ].toColumn();
  }

  Widget _cancelAmountWidget({required GreservationFragmentData receiptItem}) {
    double? nonrefundableamount = 0, refundamount, isSpecialPriceAverage;
    String? username = _controller.appPreference.isOwner!
        ? _controller.cancellationData?.cancelReservationData?.results?.guestName
        : _controller.cancellationData?.cancelReservationData?.results?.hostName;
    int? refundDays, totalNights;
    if (_controller.cancellationData != null &&
        _controller.cancellationData?.cancelReservationData?.results?.nonRefundableDayPrice != null) {
      nonrefundableamount =
          _controller.cancellationData?.cancelReservationData?.results?.nonRefundableDayPrice!;
    }
    if (_controller.cancellationData != null &&
        _controller.cancellationData?.cancelReservationData?.results?.refundToGuest != null &&
        !_controller.appPreference.isOwner!) {
      refundamount = _controller.cancellationData?.cancelReservationData?.results?.refundToGuest!;
    }
    if (_controller.cancellationData != null &&
        _controller.cancellationData?.cancelReservationData?.results?.total != null) {
      isSpecialPriceAverage = _controller.cancellationData?.cancelReservationData?.results?.total!;
    }
    if (_controller.cancellationData != null &&
        _controller.cancellationData?.cancelReservationData?.results?.payoutToHost != null &&
        _controller.appPreference.isOwner!) {
      refundamount = _controller.cancellationData?.cancelReservationData?.results?.payoutToHost!;
    }

    return [
      if (nonrefundableamount != null && nonrefundableamount > 0.0)
        _getAmountWidget(
          containerColor: missEarnContainerColor!,
          icon: Assets.drawableCancelTripNonRefund,
          title: !_controller.appPreference.isOwner! ? label_non_refundable.tr : label_missed_earnings.tr,
          titleTextColor: overALLThemeType == 2 ? appColors.black : AppColors.staticblack,
          borderColor: missEarnContainerBorderColor,
          amount: nonrefundableamount,
          bottomWidget: (_controller.appPreference.isOwner! &&
                  refundDays != null &&
                  refundDays > 0 &&
                  nonrefundableamount > 0)
              ? CustomText(
                  symbol: _controller.getCurrencySymbol(),
                  text:
                      '${(isSpecialPriceAverage ?? nonrefundableamount).toNumberFormat(symbol: _controller.getCurrencySymbol())} X $refundDays ${label_day.trPlural(dayPlural.tr, refundDays)}',
                  size: AppDimen.textSize_16,
                  color: overALLThemeType == 2 ? appColors.black.withValues(alpha: 0.6) : AppColors.staticblack.withValues(alpha: 0.6),
                  fontWeight: FontWeight.normal,
                )
              : null,
          currency: receiptItem.currency,
          textDecoration: TextDecoration.lineThrough,
          strikeColor: appColors.errorRed,
        ),
      if (refundamount != null && refundamount > 0)
        [
          _getAmountWidget(
              containerColor: overALLThemeType == 2 ? Colors.transparent : appColors.cancelTripRefundableBGColor,
              icon: Assets.drawableCancelTripRefund,
              title: !_controller.appPreference.isOwner! ? label_refundable.tr : label_earnings.tr,
              titleTextColor: overALLThemeType == 2 ? appColors.black : AppColors.staticblack,
              borderColor: nonFundContainerBorderColor,
              amount: refundamount,
              bottomWidget: (_controller.appPreference.isOwner! &&
                  totalNights != null &&
                  totalNights > 0 &&
                  refundamount > 0)
                  ? CustomText(
                symbol: _controller.getCurrencySymbol(),
                text:
                '${(isSpecialPriceAverage ?? nonrefundableamount)?.toNumberFormat(symbol: _controller.getCurrencySymbol())} X $totalNights ${label_day.trPlural(dayPlural.tr, totalNights)}',
                size: AppDimen.textSize_16,
                color: overALLThemeType == 2 ? appColors.black.withValues(alpha: 0.6) : AppColors.staticblack.withValues(alpha: 0.6),
                fontWeight: FontWeight.normal,
              )
                  : null,
              currency: receiptItem.currency
          ).toPad(top: 10),
          12.toHeight(),
          CustomText(
            text: label_you_will_be_refunded_with_the_above_cost.tr,
            size: AppDimen.textSize_14,
            fontWeight: AppFont.regular,
          )
        ].toColumn(),
      if (appPreference.isOwner!) ...[
        CustomText(
                text:
                    "${(receiptItem.isSpecialPriceAverage ?? receiptItem.basePrice)?.currencyConverted(convertedCurrency: receiptItem.currency ?? defaultCurrency).toNumberFormat(symbol: _controller.getCurrencySymbol())} X ${receiptItem.days} ${label_day.trPlural(dayPlural.tr, receiptItem.days)}",
                size: AppDimen.textSize_14, fontWeight: AppFont.regular)
            .toPad(top: 14),
        CustomText(text: label_refund_content.trParams({"field": "$username"}), size: AppDimen.textSize_14, fontWeight: AppFont.regular)
            .toPad(top: 10),
      ],
      overALLThemeType == 4 ? 20.toHeight() : 0.toHeight()
    ].toColumn();
  }

  Widget _getAmountWidget(
      {required Color containerColor,
      String? icon,
      String? title,
      double? amount,
      String? currency,
      TextDecoration? textDecoration,
      Color? strikeColor,
      Color? titleTextColor,
      Color? borderColor,
      Widget? bottomWidget}) {
    return CustomBorderContainer(
        borderRadius: overALLAppLayoutModel?.borderRadius,
        padding: pad(w: 15, h: 18),
        borderWidth: 0,
        borderColor: borderColor,
        color: containerColor,
        body: [
          [
            if (icon != null) icon.toSVG().toPad(end: 10),
            if (title != null) CustomText(text: title, color: titleTextColor, size: AppDimen.textSize_14, fontWeight: AppFont.medium).toStretch(),
            CustomText(
              symbol: _controller.getCurrencySymbol(),
              text: '${amount?.toNumberFormat(symbol: _controller.getCurrencySymbol())}',
              size: AppDimen.textSize_14,
              textDecoration: textDecoration,
              decorationColor: strikeColor,
              color: titleTextColor,
            ),
          ].toRow(),
          if (bottomWidget != null) bottomWidget.toPad(top: 15)
        ].toColumn());
  }

  Widget _buildCancellationPolicyInfo({required GreservationFragmentData receiptItem}) {
    dynamic cancellation = receiptItem.cancellation;
    var policyName = cancellation.policyName;
    String title = '${cancellation.policyContent}';
    Widget spanWidget = showSearchableSpanWidget(
        primary: title,
        search: cancellation.policyName,
        fontSize: AppDimen.textSize_14,
        searchTextNavigation: () {});
    Widget policyWidget = toOnTap(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          showCustomBottomSheet(
            backButtonWidget: getBackIconWidget(
              backIcon: overALLAppLayoutModel!.backIcon,
            ),
            contentWidget: GetBuilder<BottomSheetController>(
                builder: (newController) => CancellationPolicyView(
                      controller: _controller,
                      cancellation: cancellation,
                    )),
            sheetCloseListener: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            title: label_cancellation_policy.tr,
          );
        },
        child: [
          CustomTitleText(
            text: label_cancellation_policy.tr,
            size: AppDimen.textSize_18,
            fontWeight: AppFont.medium,
          ),
          Spacer(),
          [
            CustomText(
              text: policyName,
              color: appColors.secondaryColor,
              size: AppDimen.textSize_16,
              fontWeight: AppFont.regular,
            ),
            Assets.viewcarsLeftArrow
                .toSVG(colour: appColors.secondaryColor, isReverseRotation: true, size: 12)
                .toPad(start: 5),
          ].toRow()
        ].toRow());
    return [
      policyWidget,
      15.toHeight(),
      spanWidget,
    ].toColumn();
  }

  Widget _buildKeepAndCancelTripButton({required GreservationFragmentData receiptItem}) {
    return CustomBottomItemShadowContainer(
      padding: pad(bottom: 24),
      color: appColors.white,
      body: [
        20.toHeight(),
        CustomText(
          text:
              '${label_keep.tr} ${label_your.tr.toLowerCase()} ${_controller.appPreference.isOwner! ? label_reservation.tr.toLowerCase() : label_trip_single.tr.toLowerCase()}',
          color: appColors.secondaryColor,
          onTap: () {
            Get.back();
          },
        ),
        15.toHeight(),
        PrimaryColorButton(
            text:
                '${label_cancel.tr} ${label_your.tr.toLowerCase()} ${_controller.appPreference.isOwner! ? label_reservation.tr.toLowerCase() : label_trip_single.tr.toLowerCase()}',
            onTap: () {
              _controller.checkValidation(messagefocusNode: messagefocusNode);
            }).toPad(horizontal: AppDimen.startMargin),
      ].toColumn(crossAxisAlignment: CrossAxisAlignment.center, mainAxisSize: MainAxisSize.min),
    );
  }
}