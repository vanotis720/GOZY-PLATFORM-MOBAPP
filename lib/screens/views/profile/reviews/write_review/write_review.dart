import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/resources/app_layout.dart';
import 'package:gozy/screens/views/profile/reviews/write_review/write_review_controller.dart';
import 'package:gozy/widgets/common/custom_button/primary_button.dart';
import 'package:gozy/widgets/common/custom_container/custom_border_container.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/common/custom_textfield/custom_textfield_area.dart';
import 'package:gozy/widgets/conditional_parent_widget.dart';
import 'package:gozy/widgets/common/custom_container/custom_container.dart';
import 'package:gozy/widgets/dotted_border/dotted_border.dart';
import 'package:gozy/widgets/explore_listing_item_widgets.dart';
import 'package:gozy/widgets/flutter_rating_bar.dart';
import '../../../../../constant.dart';
import '../../../../../generated/assets.dart';
import '../../../../../resources/app_dimen.dart';
import '../../../../../resources/app_font.dart';
import '../../../../../resources/app_lang.dart';
import '../../../../../widgets/common/custom_container/custom_bottom_item_shadow_container.dart';
import '../../../../../widgets/common_extension_functions.dart';
import '../../../../../widgets/custom_stateful_widget.dart';
import '../../../../../widgets/custom_text.dart';
import '../../../../../widgets/custom_textfield.dart';
import '../../../../binding/main_binding.dart';
import '../../../base_controller.dart';
import '../../../custom_scaffold.dart';
import '../../../../../widgets/show_done_view.dart';
import '../../../home/home_navigator.dart';
import '../../../home/home_page.dart';
import '../app_review_navigator.dart';
import '../app_reviews_controller.dart';

class WriteReview extends CustomStatefulWidget {
  const WriteReview({super.key});

  @override
  WriteReviewState createState() => WriteReviewState();
}

class WriteReviewState extends CustomStatefulWidgetState<WriteReview>
    with TickerProviderStateMixin {
  WriteReviewController controller = Get.find();
  bool? isFrom;
  String? isFromPage;
  double? borderRadius;
  double? containerBorderRadius;
  Color? borderColor;
  double? borderWidth;
  Color? listingDetailInfoBgColor;
  bool isChipView = false;
  bool isShowDotForCarType = true;
  bool isFieldUnderLined = false;
  double? sizeOfSvg;
  String ratingIcon = "";
  FocusNode reviewFocusNode = FocusNode();

  @override
  void initState() {
    Map<String,dynamic> arguments = Get.arguments;
    controller.itemInfo = arguments['itemInfo'];
    controller.page = arguments['page'];
    isFrom = arguments['isFrom'] == "aboutYou" ;
    isFromPage = arguments['isFrom'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    initThemeData();
    return CustomScaffold(
      controller: controller,
      isShowAppBar: true,
      customAppBarFunction: () {
        if(isFromPage == "splash") {
          Get.offAll(() => HomePage(),
            binding: MainBinding(isDisableClearController: true),
            arguments: {'selectedTab': 0},
            routeName: "/guestHomePage"
          );
        } else {
          if(isFrom?? false){
            navigateToReview(ReviewAboutYouEnum.past);
          }else{
            navigateToReview(ReviewByYouEnum.upcoming);
          }
        }
      },
      isShowBGOnLoader: false,
      loader: LottieLoaders.three_dots_loader,
      backIconWidget:
      getBackIconWidget(
          themeType: overALLThemeType,
        onTap: (){
          if(isFromPage == "splash") {
            Get.offAll(() => HomePage(),
                binding: MainBinding(isDisableClearController: true),
                arguments: {'selectedTab': 0},
                routeName: "/guestHomePage"
            );
          } else {
            if(isFrom?? false){
              navigateToReview(ReviewAboutYouEnum.past);
            }else{
              navigateToReview(ReviewByYouEnum.upcoming);
            }
          }
        }
       ),
      resizeToAvoidBottomInset: false,
      body: InputDoneView(
        controller,
        parentWidget: CustomContainer(
          body: controller.itemInfo?.getPendingUserReview?.result?.listData != null
              ? showBodyContent()
              : show404Widget(),
        ).toPad(bottom: MediaQuery.of(context).viewInsets.bottom),
      ),
    );
  }

  Widget show404Widget(){
    return [
      CustomText(text: label_write_review_empty.tr,alignment: Alignment.center,
      size:AppDimen.textSize_26,
      color: appColors.textColor,
      fontWeight: AppFont.semiBold,),
      CustomText(text: label_write_review_error_content.tr,textAlign: TextAlign.center,
        size:AppDimen.textSize_16,
        color: appColors.textColor,
        fontWeight: AppFont.medium,),
      CustomText(text: label_write_review_error_code.tr,alignment: Alignment.center,
        size:AppDimen.textSize_12,
        color: appColors.textfieldHintColor,
        fontWeight: AppFont.medium,),
    ].toColumn(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center
    ).toPad(horizontal: AppDimen.startMargin).toResizeWidget(isDeviceFit: true);
  }
  Widget showBodyContent() {
    return [
      CustomTitleText(text: label_write_a_review.tr, size: AppDimen.textSize_22).toPad(horizontal: AppDimen.startMargin),
      20.toHeight(),
      _showReviewDetails(),
      _showNextButton(),
    ].toColumn();
  }

  Widget _showReviewDetails(){
    List<Widget> listItemWidgets = <Widget>[];
    listItemWidgets.add(_buildReviewDetailsInfo().toPad(horizontal: 2));
    listItemWidgets.add(_buildTextFieldView().toPad(horizontal: AppDimen.startMargin));
    List<Widget> listItemWidgetsWithDivider = ListItemsWithDivider(
      WidgetList: listItemWidgets,
      space: AppDimen.startMargin,
      horizontalPad: overALLThemeType == 1 || overALLThemeType == 2 || overALLThemeType == 4
          ? AppDimen.startMargin
          : null,
      isPadForDivider: false,
    );
    listItemWidgetsWithDivider.insert(1,_buildRatingBarView().toPad(horizontal: AppDimen.startMargin));
    return [
      for(Widget item in listItemWidgetsWithDivider) item
    ].toScroll().toStretch(isExpanded: true);
  }

  Widget _showNextButton() {
    return CustomBottomItemShadowContainer(
      height: 100,
      color: appColors.white,
      padding: pad(w: 20, top: 25, bottom: 20),
      borderRadiusGeometry: BorderRadiusDirectional.vertical(
          top: Radius.circular(overALLAppLayoutModel?.borderRadius ?? 0),
          bottom: Radius.circular(overALLAppLayoutModel?.borderRadius ?? 0)),
      body: Obx(() => PrimaryButton(
        buttonText: btn_label_submit.tr,
        onTap: controller.isLoading.value ? null : () {
          if (controller.isLoading.value) return;
          if(controller.validateInput()) {
            controller.isLoading.value = true;
            isShowLoader = true;
            controller.checkNetwork(() {
              controller.writeUserReview((value) {
                print("is From Valuesss:::${isFrom}");
                if(isFromPage == "splash") {
                  Get.offAll(() => HomePage(),
                      binding: MainBinding(isDisableClearController: true),
                      arguments: {'selectedTab': 0},
                      routeName: "/guestHomePage"
                  );
                } else {
                  if(isFrom?? false){
                    navigateToReview(ReviewAboutYouEnum.upcoming);
                  } else{
                    navigateToReview(ReviewByYouEnum.past);
                  }
                }
                });
            });
          }
        },
      )),
    );
  }

  Widget _buildReviewDetailsInfo() {
     String photo = imgListingMedium + (controller.itemInfo?.getPendingUserReview?.result?.listData?.listPhotoName ?? '').toString();
    return
      toOnTap(
        onTap: (){
          HomeNavigator().navigateScreen(
            HomeScreen.itemDetail,
            param: [controller.itemInfo?.getPendingUserReview?.result?.listData, ""],
          );
        },
        child: ConditionalParentWidget(
          condition: overALLThemeType == 4,
          parentBuilder: (child) =>
              DottedBorderView(
                  borderRadius: overALLAppLayoutModel?.borderRadius,
                  dottedlineColor: appColors.colorCommonLinkColor,
                  child: child),
          child: CustomBorderContainer(
              color: listingDetailInfoBgColor,
              borderRadius: overALLThemeType  != 4 ? 0 : overALLAppLayoutModel?.borderRadius,
              body: toListImageRow(
                  showBorderForImage: true,
                  borderRadius: borderRadius,
                  borderColor: borderColor,
                  borderWidth: borderWidth,
                  containerBorderRadius: containerBorderRadius,
                  photo: photo,
                  id: controller.itemInfo?.getPendingUserReview?.result?.id ?? 0,
                  placeholderURL: imgListingSmall+(controller.itemInfo?.getPendingUserReview?.result?.listData?.listPhotoName ?? ''),
                  ListItemWidgets: ConfirmPayListingHeaderWidget(itemInfo: controller.itemInfo?.getPendingUserReview?.result?.listData, ratingColor: appColors.textColor, isOrderChangeVar: true, listTitle:controller.itemInfo?.getPendingUserReview?.result?.listData?.title, isChipView: isChipView, showDotForCarType: isShowDotForCarType, sizeOfSvg: sizeOfSvg, ratingIcon: ratingIcon)
          ).toPad(horizontal: overALLThemeType  != 4 ? AppDimen.startMargin : 20, vertical: 20),
        )),
      );
  }

  Widget _buildRatingBarView() {
    return [
      18.toHeight(),
      CustomTitleText(
          text: label_over_all_rating.tr,
        size: AppDimen.textSize_18,
          fontWeight: AppFont.semiBold,
      ),
      12.toHeight(),
      RatingBar.builder(
        direction: Axis.horizontal,
        itemCount: 5,
        initialRating: controller.ratingCount,
        itemBuilder: (context, index) {
          if (overALLThemeType == 2) {
            return Assets.theme2StarGoldIcon.toSVG();
          }
          return ratingIcon.toSVG(colour: overALLThemeType == 3 ? appColors.black : null);
        },
        itemSize: 25,
        itemPadding: controller.isRTL() ? const EdgeInsets.only(left: 8) : const EdgeInsets.only(right: 8),
        unratedColor: overALLThemeType == 2 ? appColors.ratingDimColor : overALLThemeType == 3 ? appColors.customBorderColor : appColors.ratingBarDefaultColor,
        allowHalfRating: false,
        ignoreGestures: false,
        onRatingUpdate: (double value) {
          controller.ratingCount = value;
        },
      ),
    ].toColumn();
  }

  Widget _buildTextFieldView(){
    return [
      isFieldUnderLined ?
      TitleTextField(
        focusNode: reviewFocusNode,
        title: label_exp_placeholder.tr,
        hintText: label_how_was_experience_renter.tr,
        controller: controller.ratingDescriptionController,
        borderTextfieldPadding: pad(top: 10),
        keyboardType: TextInputType.multiline,
        maxLines: 6,
      ) : [
        CustomTitleText(
          text: label_exp_placeholder.tr,
          size: AppDimen.textSize_18,
          fontWeight: AppFont.medium,
        ).toPad(bottom: 8),
        CustomTextfieldArea(
          focusNode: reviewFocusNode,
          hintText: label_how_was_experience_renter.tr,
          controller: controller.ratingDescriptionController,
          minLines: 6,
          borderTextfieldPadding: pad(w:18,h: 10),
          maxLines: 6,
        ),
      ].toColumn()
          .toPad(bottom: 9),
      CustomText(
        text: label_review_will_be_on_public.tr,
        size: AppDimen.textSize_16,
        fontWeight: AppFont.regular,
        color: appColors.secondaryText,
      ).toPad(top: (overALLThemeType == 4) ? 18 : 9),
    ].toColumn().toPad(bottom: 25);
  }


  void initThemeData(){
    listingDetailInfoBgColor = appColors.theme4AppBarBg;
    isChipView = false;
    isShowDotForCarType = true;
    sizeOfSvg = null;
    isFieldUnderLined = appLayoutMap[AppLayout.inputType]?.themeType == 4;
    ratingIcon = overALLAppLayoutModel?.ratingIcon ?? "";
    switch(overALLThemeType){
      case 1:
        borderRadius = 6;
        containerBorderRadius = 6;
        borderColor = appColors.colorCommonLinkColor;
        borderWidth = 1.3;
        break;
      case 2:
        borderRadius = 0;
        containerBorderRadius = 0;
        borderColor = appColors.black;
        break;
      case 3:
        borderRadius = 12;
        containerBorderRadius = 18;
        borderColor = appColors.black;
        listingDetailInfoBgColor = appColors.myTripsBGColor;
        break;
      default:
        borderRadius = 12;
        containerBorderRadius = 18;
        borderColor = appColors.colorCommonLinkColor;
        isShowDotForCarType = false;
        isChipView = true;
        sizeOfSvg = 14;
        break;
    }
  }

  void navigateToReview(Enum reviewEnum){
    controller.isLoading.value = false;
    isShowLoader = false;
    controller.appReviewsNavigator?.navigateScreen(AppReviewsScreen.reviews, {"page": reviewEnum});
  }
}