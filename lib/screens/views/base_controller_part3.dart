part of 'base_controller.dart';

extension BaseControllerPart3 on BaseController {
  void changeLanguage() {
    String languageCode = appPreference.preferredLanguage ?? defaultLanguage;
    if (appPreference.preferredLanguage == null && LocalizationService.languageModelList.isNotEmpty) {
      bool isLanguageExist = LocalizationService.languageModelList
          .any((element) => element.itemValue == defaultLanguage);
      if (!isLanguageExist) {
        languageCode = LocalizationService.languageModelList.first.itemValue ?? defaultLanguage;
      }
    }

    appPreference.preferredLanguage ??= languageCode;

    LocalizationService.changeLocale(languageCode: languageCode);
  }

  Future<void> openMap(double lat,double lng) async{
    Uri uri;
    if(Platform.isAndroid) {
      uri = Uri.parse("geo:$lat,$lng?q=$lat,$lng");
    }else if(Platform.isIOS){
      uri = Uri.parse("maps://?q=$lat,$lng&ll=$lat,$lng");
    }else{
      uri = Uri.parse("https://www.google.com/maps?q=$lat,$lng");
    }
    if(!await launchUrl(uri,mode: LaunchMode.externalApplication)){
      throw 'Could not launch map';
    }
  }

  bool isDarkMode() {
    return (appPreference.appTheme == 'auto' && Get.isPlatformDarkMode) ||
        appPreference.appTheme == 'dark';
  }

  void showUpdateDialog(String url) {
    showAlertDialog(
        content:
        GetBuilder<BottomSheetController>(
          builder: (newController) =>Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                14.toHeight(),
                Assets.drawableSwitchHost.toPng(
                  width: 84,
                  height: 84,
                  fit: BoxFit.cover),
                8.toHeight(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(
                      text:  label_forceUpdate_title.tr,
                      color: appColors.customTextColor,
                      size: AppDimen.textSize_16,
                      fontWeight: AppFont.semiBold,
                    ),
                    Assets.drawableConfetti.toSVG(
                      width: 15,
                      height: 15,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
                9.toHeight(),
                CustomText(
                  textAlign: TextAlign.center,
                  text:
                  label_forceUpdate_desc.tr,
                  size: AppDimen.textSize_16,
                  color: appColors.placeholderColor,
                  fontWeight: AppFont.regular,
                ),
                18.toHeight(),
                filterDivider,
                18.toHeight(),
                CustomText(
                  color: appColors.secondaryColor,
                  text: label_forceUpdate_updateNow.tr,
                  size: AppDimen.textSize_14,
                  fontWeight: AppFont.medium,
                  onTap: () {
                    launchUrl(Uri.parse(url));
                  },
                )
              ],
            ),
          ),
        ));
  }

  void clearLoginSession({HomeScreen? screen, isDisableNavigation = false}) {
    debugPrint("queryvaluemap.value: screen $screen --- ${Get.currentRoute} -- $isDisableNavigation");
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
    AuthBinding().deleteGetXController();
    localImagePath = "";
    renterServicePlanAIFeatureStatus = false;
    ownerServicePlanAIFeatureStatus = false;
    BaseController.socketIO.clearListeners();
    if (Get.currentRoute != '/ForgetPassword' && Get.currentRoute != '/Login') {
      clearExploreData();
      showUserLogout();
    }
    isLoading.value = false;
    if (!isDisableNavigation) {
      if (screen == HomeScreen.splash) {
        Get.offAll(() => Splash(), routeName: '/');
      } else {
        Get.offAll(() => HomePage(),);
        HomeController homeController = Get.find();
        homeController.change(rxVariable: homeController.rxSelectedTab, value: 0);
        Future.delayed(const Duration(milliseconds: 400)).then((value) {
          Get.to(() => Login(), binding: AuthBinding());
        });
      }
    }

    basecontroller.change(rxVariable: rxguestUnreadCount, value: 0);
    basecontroller.change(rxVariable: rxhostUnreadCount, value: 0);
  }

  (GviewListingShortFragmentData?, GviewListingShortFragmentReq) getShortListingFragmentData(
      {required id}) {
    GviewListingShortFragmentReq viewlistshortFragmentReq = GviewListingShortFragmentReq(
            (b) => b..idFields = {'id': id});
    return (FerryLoggerClient.client?.cache.readFragment(
        viewlistshortFragmentReq), viewlistshortFragmentReq);
  }

  (GviewListingDetailsFragmentData?, GviewListingDetailsFragmentReq) getListDetailFragmentData(
      {required id}) {
    GviewListingDetailsFragmentReq viewlistdetailFragmentReq = GviewListingDetailsFragmentReq(
            (b) => b..idFields = {'id': id});
    return (FerryLoggerClient.client?.cache.readFragment(
        viewlistdetailFragmentReq), viewlistdetailFragmentReq);
  }

  (GreservationFragmentData?, GreservationFragmentReq) getReservationInfo(
      {required int reservationId}) {
    GreservationFragmentReq fragmentReq = GreservationFragmentReq((
        b) => b..idFields = {'id': reservationId});
    var data = FerryLoggerClient.client?.cache.readFragment(fragmentReq);

    if (data != null && data.reservationState == null) {
      data = null;
    }

    return (data, fragmentReq);
  }


  void clearExploreData() {
    HomeController controller = Get.find();
    controller.popularLocationsResponse = null;
    controller.getExploreListingsData = null;
    controller.isSearchSelected.value = false;
    controller.SearchedParams.clear();
    controller.selectedPopularLocation = '';
    if (Get.isRegistered<SearchedListingsController>()) {
      Get.find<SearchedListingsController>().clear();
    }
    if (controller.rxSelectedTab.value != 0) {
      controller.change(rxVariable: controller.rxSelectedTab, value: 0);
    } else {
      controller.change(rxVariable: controller.rxSelectedTab,
          value: controller.rxSelectedTab.value);
    }
    debugPrint(
        "controller.selectedTab.value:  23: ${controller.rxSelectedTab.value}");
  }
  Widget buildGenerateWithAIView({Function()? onTap, label}) {
    return GradientBorderContainer(
        onTap: onTap,
        child: [
          Assets.drawableAi.toSVG(size: 24).toPad(top: 4),
          3.toWidth(),
          CustomText(text: label, fontWeight: AppFont.medium, size: AppDimen.textSize_14,),
        ].toRow(mainAxisSize: MainAxisSize.min).toPad(horizontal: 4)
    );
  }

  Widget buildAIResponseView({RxString? content}){
    return Obx(() => (content?.value ?? "").isNotEmpty ?
    ClipRRect(
        borderRadius: BorderRadiusDirectional.circular(overALLAppLayoutModel?.borderRadius ?? 0),
        child: CustomContainer(
          decoration: BoxDecoration(
            borderRadius: BorderRadiusDirectional.circular(overALLAppLayoutModel?.borderRadius ?? 0),
            boxShadow: [
              BoxShadow(
                color: appColors.shadowColor,
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 5),
              )
            ],
          ),
      body: GradientBorderContainer(
        color:appColors.white,
        borderRadiusForInSideView: BorderRadiusDirectional.circular(overALLAppLayoutModel?.borderRadius ?? 0),
        borderRadiusForLinear: BorderRadiusDirectional.circular(overALLAppLayoutModel?.borderRadius ?? 0),
        onTap: (){},
        child: [
          [
            CustomText(text: label_message.tr, size: AppDimen.textSize_16, fontWeight: FontWeight.w600,),
            5.toWidth(),
            toOnTap(
                child: Assets.drawableCopyLink.toSVG(colour: appColors.tertiaryColor),
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: content?.value ?? ""));
                  showSnackBar(label_copied_to_text.tr);
                }
            )
          ].toRow(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center),
          5.toHeight(),
          CustomText(text: content?.value ?? "", size: AppDimen.textSize_14, fontWeight: AppFont.regular,)
        ].toColumn().toPad(all: 12),
      ).toPad(all: overALLThemeType == 3 ? 8 : 10),
    )) : const SizedBox.shrink());
  }

  Widget buildAIResponseWithCheckBox({RxString? title, RxString? description, RxBool? titleCheck, RxBool? descriptionCheck, bool isShimmerView = false}){
    //0xFFFFFBF7
    return Obx(() =>
    isShimmerView || ((title?.value ?? "").isNotEmpty && (description?.value ?? "").isNotEmpty) ? ClipRRect(
      borderRadius: BorderRadiusDirectional.circular(overALLAppLayoutModel?.borderRadius ?? 0),
      child: CustomContainer(
          decoration: BoxDecoration(
            borderRadius: BorderRadiusDirectional.circular(overALLAppLayoutModel?.borderRadius ?? 0),
            boxShadow: [
              BoxShadow(
                color: appColors.shadowColor,
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 5),
              )
            ],
          ),
          body: GradientBorderContainer(
            margin: overALLThemeType == 3 ? pad(w: 8, h: 8) : pad(w: 10, h: 10),
            color:appColors.white,
            borderRadiusForInSideView: BorderRadiusDirectional.circular(overALLAppLayoutModel?.borderRadius ?? 0),
            borderRadiusForLinear: BorderRadiusDirectional.circular(overALLAppLayoutModel?.borderRadius ?? 0),
            onTap: (){},
          child: [
            [
              if (isShimmerView)
                  Container(width: 20, height: 20, decoration: BoxDecoration(color: appColors.shimmerplaceholderColor, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(4)))
              else
                  toOnTap(onTap: () => titleCheck?.value = !titleCheck.value, child: CustomCheckBox(ischeckCondition: !(titleCheck?.value ?? false), isNeedEndPadding: false, isNeedTopMargin: false, borderColor: appColors.myTripsDividerColor, boxshape: BoxShape.rectangle)),
              5.toWidth(),
              CustomText(text: label_title.tr, fontWeight: AppFont.semiBold, size: AppDimen.textSize_16, isShimmerView: isShimmerView),
              5.toWidth(),
              if (!isShimmerView)
              toOnTap(
                child: Assets.drawableCopyLink.toSVG(colour: appColors.tertiaryColor),
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: title?.value ?? ""));
                  if(Platform.isIOS) {
                    showSnackBar(label_copied_to_text.tr);
                  }
                }
              )
            ].toRow(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center),
            5.toHeight(),
            CustomText(text: isShimmerView ? 50.toGenerateEmptyString() : title?.value ?? "", size: AppDimen.textSize_14, fontWeight: FontWeight.w400, isShimmerView: isShimmerView),
            10.toHeight(),
            [
              if (isShimmerView)
                  Container(width: 20, height: 20, decoration: BoxDecoration(color: appColors.shimmerplaceholderColor, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(4)))
              else
                  toOnTap(onTap: () => descriptionCheck?.value = !descriptionCheck.value, child: CustomCheckBox(ischeckCondition: !(descriptionCheck?.value ?? false), isNeedEndPadding: false, isNeedTopMargin: false, borderColor: appColors.myTripsDividerColor, boxshape: BoxShape.rectangle)),
              5.toWidth(),
              CustomText(text: title_description.tr.toUpperLowerCase(), fontWeight: AppFont.semiBold, size: AppDimen.textSize_16, isShimmerView: isShimmerView),
              5.toWidth(),
              if (!isShimmerView)
              toOnTap(
                child: Assets.drawableCopyLink.toSVG(colour: appColors.tertiaryColor),
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: description?.value ?? ""));
                  if(Platform.isIOS) {
                    showSnackBar(label_copied_to_text.tr);
                  }
                }
              )
            ].toRow(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center),
            5.toHeight(),
            CustomText(text: isShimmerView ? 100.toGenerateEmptyString() : description?.value ?? "", size: AppDimen.textSize_14, fontWeight: FontWeight.w400, isShimmerView: isShimmerView)
          ].toColumn().toPad(all: 10),
          ),
      ),
    ) : const SizedBox.shrink());
  }
}