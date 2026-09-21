part of 'confirm_pay_page.dart';

extension ConfirmAndPayPageUI on ConfirmAndPayPageState {
  Widget _customDateTimeView({
    required String headerText,
    required String date,
    required CrossAxisAlignment crossAxisAlignment,
    TextAlign textAlign = TextAlign.start,
    Color? headerColor,
    double? headerFontSize,
    FontWeight? headerFontWeight,
    double? fontSize,
    Function? onTap,
  }) {
    return [
      CustomText(
        text: headerText,
        size: headerFontSize ?? AppDimen.textSize_16,
        fontWeight: headerFontWeight ?? AppFont.medium,
        color: headerColor,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        textAlign: textAlign,
      ),
      8.toHeight(),
      CustomText(
          text: date,
          onTap: () {
            onTap!();
          },
          size: fontSize ?? AppDimen.textSize_12,
          fontWeight: AppFont.regular,
          color: appColors.secondaryColor,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          textAlign: textAlign),
      4.toHeight(),
    ].toColumn(mainAxisSize: MainAxisSize.min, crossAxisAlignment: crossAxisAlignment);
  }

  Widget _buildTitleInfo() {
    return [
      CustomTitleText(
          text: confirmpaycontroller.pageType == 'pay'
              ? label_review_and_pay.tr
              : '${label_contact.tr} ${label_owner.tr.toLowerCase()}',
          size: AppDimen.textSize_22,
        fontWeight: AppFont.semiBold,
      ),
      20.toHeight(),
    ].toColumn();
  }

  Widget _buildListingDetailInfo() {
    dynamic itemInfo = confirmpaycontroller.itemInfo;
    String photo = imgListingMedium + itemInfo.listPhotoName;
    String placeHolderPhoto = imgListingMedium + itemInfo.listPhotoName;
    return ConditionalParentWidget(
      condition: overALLThemeType == 4,
      parentBuilder: (child) => DottedBorderView(
              borderRadius: borderRadius, dottedlineColor: appColors.colorCommonLinkColor, child: child)
          .toPad(horizontal: 5),
      child: CustomBorderContainer(
        color: listingDetailInfoBgColor,
        borderRadius: overALLThemeType != 4 ? 0 : borderRadius,
        body: toOnTap(
          onTap: () {
            if (Get.arguments.containsKey("isFromViewMessage")) {

            } else {
              HomeNavigator().navigateScreen(
                HomeScreen.itemDetail,
                param: [itemInfo, "", widget.controller.selectedDates.value, widget.controller.rxUpdatedGuestCount.value],
              );
            }
          },
          child: toListImageRow(
                  showBorderForImage: true,
                  borderRadius: borderRadius,
                  borderColor: borderColor,
                  containerBorderRadius: containerBorderRadius,
                  photo: photo,
                  width: 110,
                  height: 80,
                  id: itemInfo.id!,
                  placeholderURL: placeHolderPhoto,
                  ListItemWidgets: ConfirmPayListingHeaderWidget(
                      itemInfo: itemInfo,
                      isOrderChangeVar: true,
                      showDotForCarType: isShowDotForCarType,
                      isChipView: isChipView,
                      ratingColor: appColors.textColor,
                      sizeOfSvg: sizeOfSvg))
              .toPad(
                  horizontal: overALLThemeType == 4
                      ? AppDimen.startMargin - 5
                      : AppDimen.startMargin,
                  vertical: 20),
        ),
      ),
    );
  }

  Widget _buildCouponCodeField() {
    return Obx(
      () => [
        ..._buildCouponCodeTitleView(),
        ..._buildCouponCodeTextField(),
      ].toColumn(),
    );
  }

  List<Widget> _buildCouponCodeTitleView() {
    return [CustomText(text: label_coupon_code.tr, size: AppDimen.textSize_16), 12.toHeight()];
  }

  Widget _buildCancellationPolicyInfo() {
    dynamic cancellation = confirmpaycontroller.itemInfo?.listingData?.cancellation;
    return [
      CustomTitleText(
        text: label_cancellation_policy.tr,
        size: AppDimen.textSize_16,
      ),
      Spacer(),
      CustomText(
        text: cancellation.policyName,
        color: appColors.secondaryColor,
        size: AppDimen.textSize_16,
        fontWeight: FontWeight.w400,
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          showCustomBottomSheet(
            backButtonWidget: getBackIconWidget(
                themeType: overALLThemeType,
                backIcon: Assets.drawableSignupClose),
            contentWidget: GetBuilder<BottomSheetController>(
                builder: (newController) =>
                    CancellationPolicyView(cancellation: cancellation, controller: widget.controller)),
            title: label_cancellation_policy.tr,
          );
        },
      ),
      Assets.drawableRightArrow.toSVG(colour: appColors.secondaryColor, size: 10).toPad(start: 5)
    ].toRow();
  }

  void _setStartAndEndTime(String value, String from) {
    switch (from) {
      case "start":
        confirmpaycontroller.rxSelectedStartTime.value = value;
        confirmpaycontroller.change(
            rxVariable: confirmpaycontroller.rxSelectedDates,
            value: confirmpaycontroller.rxSelectedDates.value);
        if (confirmpaycontroller.pageType == 'pay') {
          widget.controller.checkNetwork(widget.controller.getBillingCalculation);
        }
        break;
      case "end":
        confirmpaycontroller.rxSelectedEndTime.value = value;
        confirmpaycontroller.change(
            rxVariable: confirmpaycontroller.rxSelectedDates,
            value: confirmpaycontroller.rxSelectedDates.value);
        if (confirmpaycontroller.pageType == 'pay') {
          widget.controller.checkNetwork(widget.controller.getBillingCalculation);
        }
        break;
    }
  }

  void _setSelectedDates(List<DateTime> value) {
    debugPrint(
        "_setSelectedDates: $value ---${confirmpaycontroller.rxSelectedDates.value}---${confirmpaycontroller.contactHostDates}");
    if (!_isBackpress &&
        value.isNotEmpty &&
        confirmpaycontroller.contactHostDates.isNotEmpty &&
        (value.first != confirmpaycontroller.contactHostDates.first ||
            value.last != confirmpaycontroller.contactHostDates.last)) {
      confirmpaycontroller.change(
          rxVariable: confirmpaycontroller.rxSelectedDates, value: List<DateTime>.from(value));
    } else if (confirmpaycontroller.pageType == 'pay' && value.isNotEmpty) {
      confirmpaycontroller.change(
          rxVariable: confirmpaycontroller.rxSelectedDates, value: List<DateTime>.from(value));
      if (confirmpaycontroller.rxSelectedStartTime.value.isNotEmpty &&
          confirmpaycontroller.rxSelectedEndTime.value.isNotEmpty) {
        widget.controller.checkNetwork(widget.controller.getBillingCalculation);
      }
    } else if (value.isNotEmpty && confirmpaycontroller.contactHostDates.isEmpty) {
      confirmpaycontroller.change(
          rxVariable: confirmpaycontroller.rxSelectedDates, value: List<DateTime>.from(value));
    }
  }

  Widget checkinDateEditInfo() {
    return GetBuilder(
        id: confirmpaycontroller.rxSelectedDates.id,
        init: confirmpaycontroller,
        builder: (context) {
          DateTime startDate = DateTime.now();
          DateTime endDate = DateTime.now();
          if (confirmpaycontroller.rxSelectedDates.value.isNotEmpty) {
            startDate = confirmpaycontroller.rxSelectedDates.value.first;
            endDate = confirmpaycontroller.rxSelectedDates.value.last;
          }
          String startTime = confirmpaycontroller.rxSelectedStartTime.value.isNotEmpty
              ? confirmpaycontroller.rxSelectedStartTime.value
              : "";
          String endTime = confirmpaycontroller.rxSelectedEndTime.value.isNotEmpty
              ? confirmpaycontroller.rxSelectedEndTime.value
              : "";

          if (confirmpaycontroller.rxSelectedDates.value.isNotEmpty) {
            return basecontroller.reservationDateInfo(
                checkinDate: startDate.millisecondsSinceEpoch.toString(),
                checkoutDate: endDate.millisecondsSinceEpoch.toString(),
                isFrom: "review_pay",
                checkinTime: startTime,
                checkoutTime: endTime,
                headerFontWeight: AppFont.regular,
                headerColor: appColors.customTextColor,
                dateColor: appColors.secondaryColor,
                timeColor: appColors.secondaryColor,
                headerFontSize: AppDimen.textSize_14,
                fontSize: AppDimen.textSize_16,
            onTap: (){
             if (!Get.arguments.containsKey("isFromViewMessage") || !Get.arguments["isFromViewMessage"]) {
               FocusManager.instance.primaryFocus?.unfocus();
               _openCalendarFromConfirmPay();
             }
            });
          } else {
            return _emptyDateView(
                headerColor: appColors.black,
                headerFontSize: AppDimen.textSize_14,
                fontSize: AppDimen.textSize_16);
          }
        });
  }

  Widget _buildBillingRequestInfo() {
    return [
      checkinDateEditInfo(),
    ].toColumn().toPad(top: 20);
  }

  void _intiThemeData() {
    listingDetailInfoBgColor = appColors.theme4AppBarBg;
    borderColor = appColors.colorCommonLinkColor;
    borderRadius = 12;
    containerBorderRadius = 18;
    isShowDotForCarType = true;
    sizeOfSvg = 18;
    isChipView = false;
    showBillingBorder = true;
    showBillingColor = false;
    billingBorderRadius = 12;
    isPaddedContent = true;
    minLine = 6;

    if (appLayoutMap[AppLayout.inputType]?.themeType == 4) {
      minLine = 1;
    }
    switch (overALLThemeType) {
      case 1:
        borderRadius = 6;
        containerBorderRadius = 6;
        borderColor = appColors.colorCommonLinkColor;
        showBillingBorder = true;
        showBillingColor = false;
        billingBorderRadius = 6;
        isPaddedContent = true;
        break;
      case 2:
        borderRadius = 0;
        containerBorderRadius = 0;
        borderColor = appColors.black;
        showBillingBorder = false;
        showBillingColor = false;
        isPaddedContent = false;
        break;
      case 3:
        borderRadius = 12;
        containerBorderRadius = 18;
        borderColor = appColors.black;
        listingDetailInfoBgColor = appColors.myTripsBGColor;
        showBillingBorder = true;
        showBillingColor = true;
        billingBorderRadius = 18;
        break;
      default:
        borderRadius = 12;
        containerBorderRadius = 18;
        borderColor = appColors.colorCommonLinkColor;
        isShowDotForCarType = false;
        sizeOfSvg = 14;
        isChipView = true;
        showBillingBorder = true;
        showBillingColor = false;
        billingBorderRadius = 12;
        isPaddedContent = true;
        break;
    }
  }
}