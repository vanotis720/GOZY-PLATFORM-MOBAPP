import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_colors.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/resources/app_layout.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/screens/views/guest/my_trips/my_trip_list_controller.dart';
import 'package:gozy/widgets/common/custom_bottomsheet/custom_draggable_bottomsheet.dart';
import 'package:gozy/widgets/common/custom_bottomsheet/custom_getx_bottomsheet.dart';
import 'package:gozy/widgets/common/custom_container/custom_border_container.dart';
import 'package:gozy/widgets/common/custom_network_image/custom_clip_network_image.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/common/custom_textfield/custom_prefix_textfield.dart';
import 'package:gozy/widgets/common/custom_textfield/custom_textfield_area.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/conditional_parent_widget.dart';
import 'package:gozy/widgets/custom_list_item.dart';
import 'package:gozy/widgets/custom_stateful_widget.dart';
import 'package:gozy/widgets/custom_text.dart';
import 'package:gozy/widgets/dotted_border/dotted_border.dart';
import 'package:gozy/widgets/show_done_view.dart';

import '../../../../widgets/common/custom_button/primary_button.dart';
import '../../../../widgets/common/custom_container/custom_bottom_item_shadow_container.dart';

class ClaimDamage extends CustomStatefulWidget {
  const ClaimDamage({super.key});

  @override
  CustomStatefulWidgetState<ClaimDamage> createState() => _ClaimDamageState();
}

class _ClaimDamageState extends CustomStatefulWidgetState<ClaimDamage> {
  MyTripListController controller = Get.find();

  String securityDepositAmount = '';
  Map<String, dynamic> arguments = {};
  double imageBorderRadius = 0.0;
  double bottomButtonRadius = 0.0;
  bool isRequested = false;
  String addPhotoImage = Assets.drawableGallery;
  Color addPhotoBorderColor = appColors.colorCommonLinkColor;
  Color addPhotoImageColor = appColors.colorCommonLinkColor;

  @override
  void initState() {
    arguments = Get.arguments;
    securityDepositAmount = arguments['securityDeposit'];
    controller.selectedImageOption.value = '';
    controller.securityDepositAmount = double.parse(securityDepositAmount);
    controller.idForClaimDamage = arguments['id'] ?? 0;
    controller.claimStatus = arguments['claimStatus'] ?? '';
    controller.uploadingPhotos.value = [];
    controller.uploadingNetWorkPhotos.clear();
    controller.removeablePhotos.clear();
    controller.photoUploadingFuture = null;
    controller.uploadProgress.value = "0";
    if (controller.claimStatus == "requested") {
      isRequested = true;
      controller.claimAmountController.text = double.parse(arguments['claimAmount'].toString()).currencyConverted(convertedCurrency: arguments['currency'] ?? defaultCurrency);
      controller.reasonForClaimController.text = arguments['claimReason'];
      controller.uploadingNetWorkPhotos(arguments['claimImages'].whereType<String>().toList() ?? []);
    }
    controller.isInUploadpage = true;
    controller.depositAmountController.text = "${controller.getCurrencySymbol()}${controller.securityDepositAmount.currencyConverted(convertedCurrency: arguments['currency'] ?? defaultCurrency)}";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    initThemeData();
    return CustomScaffold(
      controller: controller,
      isShowAppBar: true,
      isShowBGOnLoader: false,
      loader: LottieLoaders.three_dots_loader,
      resizeToAvoidBottomInset: false,
      backIconWidget: getBackIconWidget(
        backIcon: Assets.drawableSignupClose,
        iconColor: overALLThemeType == 3 ? AppColors.staticblack : null,
        themeType: overALLThemeType,
        onTap: () {
          Get.back();
        },
      ),
      body: InputDoneView(
        controller,
        parentWidget: _showBodyContent().toPad(bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? MediaQuery.of(context).viewInsets.bottom + 40 : 0)
      ),
    );
  }

  Widget _showBodyContent() {
    return [
      [..._showTitleWidget(), ..._showTextFieldView(), ..._showImageUploadView()]
          .toScroll(scrollDirection: Axis.vertical)
          .toPad(horizontal: AppDimen.startMargin)
          .toStretch(),
      if(!isRequested)...[
        _showBottomAddPaymentWidget()
      ]
    ].toColumn(mainAxisSize: MainAxisSize.min);
  }

  List<Widget> _showTitleWidget() {
    return [
      CustomTitleText(
        text: label_claim_damage.tr,
        size: AppDimen.textSize_26,
        fontWeight: AppFont.semiBold,
      ),
      20.toHeight(),
    ];
  }

  List<Widget> _showTextFieldView() {
    return [..._showClaimDamageField(), ..._showClaimAmountField(), ..._showReasonForClaimField()];
  }

  List<Widget> _showClaimDamageField() {
    return [
      CustomPrefixTextField(
        borderTextfieldPadding: EdgeInsets.zero,
        contentPadding: appLayoutMap[AppLayout.inputType]?.themeType != 4 ? pad(w: 18) : EdgeInsets.zero,
        title: label_deposit_amount.tr,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        filteringTextInputFormatter: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
        enabled: false,
        inputBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(appLayoutMap[AppLayout.inputType]?.borderRadius ?? 0),
            borderSide: BorderSide.none),
        hintText: controller.depositAmountController.text,
        filled: appLayoutMap[AppLayout.inputType]?.themeType != 4 ? true : false,
        fillColor: appLayoutMap[AppLayout.inputType]?.themeType != 4 ? appColors.viewMessageReceiverBGColor : null,
      ),
      15.toHeight()
    ];
  }

  List<Widget> _showClaimAmountField() {
    return [
      CustomPrefixTextField(
        title: label_claim_amount.tr,
        focusNode: controller.claimAmountFocusNode,
        controller: controller.claimAmountController,
        borderTextfieldPadding: EdgeInsets.zero,
        maxLines: 1,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        filteringTextInputFormatter: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d{0,10}\.?\d{0,2}')),
        ],
        enabled: !isRequested,
        prefixIconWidget: appLayoutMap[AppLayout.inputType]?.themeType != 4 ? CustomBorderContainer(
          color: appColors.black,
          borderRadiusGeometry: BorderRadiusDirectional.only(
            topStart: Radius.circular(appLayoutMap[AppLayout.inputType]?.borderRadius ?? 0),
            bottomStart: Radius.circular(appLayoutMap[AppLayout.inputType]?.borderRadius ?? 0),
          ),
          width: 48,
          height: 48,
          alignment: AlignmentDirectional.center,
          margin: pad(end: 15),
          body: CustomText(
            text: basecontroller.getCurrencySymbol(),
            color: appColors.white,
          ),
        ) : CustomText(
          text: '${basecontroller.getCurrencySymbol()} ',
          color: appColors.customTextColor,
          fontWeight: AppFont.regular,
        ).toPad(top: 1),
        hintText: label_digit_code.trParams({"field": label_claim_amount.tr.toLowerCase()}),
      ),
      15.toHeight()
    ];
  }

  List<Widget> _showReasonForClaimField() {
    return [
      CustomTitleText(
        text: label_reason_for_claim.tr,
        size: AppDimen.textSize_18,
      ).toPad(bottom: 5),
      Obx(
        () {
          changeTextFieldFocus.value;
          return CustomTextfieldArea(
            controller: controller.reasonForClaimController,
            borderTextfieldPadding: appLayoutMap[AppLayout.inputType]?.themeType != 4 ? pad(w: 18, h: 10) : EdgeInsets.zero,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: (controller.reasonForClaimFocusNode.hasFocus && !isRequested) ? appColors.black: appColors.customBorderColor,
                  width: 0.5
                ),
              ),
            ),
            readOnly: isRequested,
            focusNode: !isRequested ? controller.reasonForClaimFocusNode : null,
            minLines: appLayoutMap[AppLayout.inputType]?.themeType == 4 ? 1 : 6,
            maxLines: 6,
            hintText: error_msg_empty.trParams({"field": label_the_claim_reason_text.tr.toLowerCase()}),
          );
        }
      ),
      15.toHeight()
    ];
  }

  List<Widget> _showImageUploadView() {
    return [
      CustomText(
        text: label_upload_image.tr,
        size: AppDimen.textSize_18
      ),
      if(!isRequested)...[
        5.toHeight(),
        CustomText(
            fontWeight: AppFont.regular,
            text: label_the_claim_damage_image_content.tr,
            size: AppDimen.textSize_14,
            color: appColors.secondaryText
        ),
      ],
      _showImageGridView()
    ];
  }

  Widget _showImageGridView() {
    return Obx(() {
      debugPrint(" upload image view --> ${controller.uploadingPhotos.toString()}");
      int? count;
      if (!isRequested) {
        count = controller.uploadingPhotos.length + 1;
      } else {
        count = controller.uploadingNetWorkPhotos.length;
      }
      return [
        if (controller.isFilesPicking.value) dotCenter120HeightLoader!,
        toGridView(
          baseController: controller,
          crossAxisSpacing: AppDimen.startMargin - 5,
          mainAxisSpacing: AppDimen.startMargin,
          gridItemCount: 2,
          itemSize: 120,
          scrollController: controller.scrollController,
          padding: pad(h: 18),
          physics: ClampingScrollPhysics(),
          itemCount: count,
          itemBuilder: (BuildContext context, int index) {
            if (!isRequested) {
              // debugPrint("Im called from image view ==> ${listshowimage}");
              int photoIndex = index - 1;
              if (index == 0) {
                return toOnTap(
                  onTap: () {
                    GetXBottomSheet(
                      sheetCloseListener: () {
                        FocusManager.instance.primaryFocus!.unfocus();
                      },
                      bottomSheetWidget: getDraggableSheetWidget(
                        controller: controller,
                        widgetsList: getImagePickerOptions(
                            controller: controller,
                            selectedImageOption: controller.selectedImageOption,
                            isFrom: "claimdamage",
                            onTap: controller.pickFile),
                      ),
                    );
                  },
                  child: DottedBorderView(
                      dottedlineColor: addPhotoBorderColor,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(imageBorderRadius)),
                        child: [
                          addPhotoImage.toSVG(
                            size: 30,
                            colour: addPhotoImageColor,
                          ),
                          12.toHeight(),
                          Center(
                              child: CustomText(
                                  text: label_add_photos.tr,
                                  color: addPhotoImageColor,
                                  textAlign: TextAlign.center,
                                  size: AppDimen.textSize_16)),
                        ].toColumn(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center),
                      )).toPad(start: 1),
                );
              } else if (controller.uploadingPhotos.isNotEmpty) {
                return Obx(
                  () {
                    bool isUploaded = photoIndex < controller.uploadingNetWorkPhotos.length;
                    bool isProgressShow = photoIndex == controller.uploadingNetWorkPhotos.length;
                    return [
                    ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(imageBorderRadius)),
                        child: ConditionalParentWidget(
                            condition: isProgressShow,
                            parentBuilder: (child) {
                              return ImageFiltered(
                                imageFilter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                                child: child,
                              );
                            },
                            child: Image.file(
                              File(controller.uploadingPhotos[photoIndex]),
                              width: deviceWidth,
                              height: deviceHeight,
                              fit: BoxFit.cover,
                            ))),
                    if (isUploaded)
                      CustomBorderContainer(
                        borderColor: appColors.white,
                        onTap: () {
                          if(!isDeletingFile.value) {
                            debugPrint('Im called from networkImage --> ${controller.uploadingNetWorkPhotos.toString()}');
                            controller.deletePhoto(controller.uploadingNetWorkPhotos[photoIndex], () {
                              controller.uploadingPhotos.removeAt(photoIndex);
                              controller.uploadingNetWorkPhotos.removeAt(photoIndex);
                            });
                          }
                        },
                        padding: pad(w: 6, h: 6),
                        borderWidth: 1,
                        borderRadius: 25,
                        margin: overALLThemeType == 3 ? pad(top: 15, start: 10, end: 10) : pad(top: 10, start: 10, end: 7),
                        color: appColors.black.withValues(alpha: 0.6),
                        body: Assets.drawableSignupClose.toSVG(colour: appColors.white, size: 9),
                      ).toPositionedAlign(alignment: AlignmentDirectional.topEnd),
                    if (isProgressShow)
                      Obx(() {
                        return Center(
                          child: double.parse(controller.uploadProgress.value) <= 1.0
                              ? [
                                  TweenAnimationBuilder<double>(
                                      duration: Duration(milliseconds: 150),
                                      curve: Curves.linear,
                                      tween: Tween<double>(
                                        begin: controller.previousprogress,
                                        end: double.parse(controller.uploadProgress.value),
                                      ),
                                      builder: (context, value, _) {
                                        return CircularProgressIndicator(
                                          backgroundColor: appColors.keyboardColor,
                                          color: appColors.secondaryColor,
                                          strokeCap: StrokeCap.round,
                                          value: value,
                                        ).toResizeWidget(width: 60, height: 60);
                                      }),
                                  CustomText(
                                    text:
                                        '${(100 * double.parse(controller.uploadProgress.value)).toStringAsFixed(2)} %',
                                    color: AppColors.staticwhite,
                                    size: AppDimen.textSize_10,
                                  ).toPositionedAlign(alignment: Alignment.center)
                                ].toStack()
                              : controller.getLoader(
                                  loader: LottieLoaders.three_dots_loader.name,
                                  changed: appThemeChanged.value,
                                  color: appColors.secondaryColor),
                        );
                      })
                  ].toStack();
                  },
                );
              } else {
                return const SizedBox.shrink();
              }
            } else {
              String listshowimage = controller.uploadingNetWorkPhotos[index];
              return CustomClipNetworkImage(
                imageUrl: "$claimURL$listshowimage",
                borderRadius: BorderRadius.all(Radius.circular(imageBorderRadius)),
                placeholderWidget: showPlaceHolderWidget(),
              );
            }
          },
        )
      ].toStack();
    });
  }

  Widget _showBottomAddPaymentWidget() {
    return CustomBottomItemShadowContainer(
      borderRadiusGeometry: BorderRadius.vertical(top: Radius.circular(bottomButtonRadius)),
      padding: pad(top: 20, w: AppDimen.startMargin, bottom: 20),
      body: PrimaryButton(
        buttonText: btn_label_submit.tr,
        onTap: () {
          if (_validate()) {
            controller.claimTheDamage();
          }
        },
      ),
    );
  }

  bool _validate() {
    return controller.validateFields();
  }

  void initThemeData() {
    switch (overALLThemeType) {
      case 1:
        imageBorderRadius = 6;
        bottomButtonRadius = 20;
        addPhotoImageColor = appColors.black;
        addPhotoBorderColor = appColors.black;
        break;
      case 2:
        imageBorderRadius = 0;
        bottomButtonRadius = 0;
        addPhotoImage = Assets.drawableAddDocument;
        addPhotoImageColor = appColors.colorCommonLinkColor;
        addPhotoBorderColor = appColors.colorCommonLinkColor;
        break;
      case 3:
        imageBorderRadius = 30;
        bottomButtonRadius = 30;
        addPhotoImageColor = appColors.colorCommonLinkColor;
        addPhotoBorderColor = appColors.customBorderColor;
        break;
      case 4:
        imageBorderRadius = 12;
        bottomButtonRadius = 12;
        addPhotoImageColor = appColors.black;
        addPhotoBorderColor = appColors.placeholderColor;
        break;
    }
  }

  Widget showPlaceHolderWidget({bool isRemoveBody = false}) {
    return CustomBorderContainer(
      width: deviceWidth,
      height: deviceHeight,
      borderRadius: imageBorderRadius,
      borderWidth: 0,
      padding: pad(a: 30),
      color: appColors.popularLocationBottomShadowColor,
      body: isRemoveBody
          ? null
          : Assets.drawablePropertyListImage
              .toPng(width: 5, height: 5, fit: BoxFit.scaleDown)
              .toResizeWidget(height: 5, width: 5),
    );
  }

  @override
  void dispose() {
    controller.isInUploadpage = false;
    controller.uploadingPhotos.value = [];
    controller.uploadProgress.value = "0";
    controller.uploadingNetWorkPhotos.clear();
    controller.removeablePhotos.clear();
    controller.photoUploadingFuture = null;
    controller.claimAmountController.text = "";
    controller.reasonForClaimController.text = "";
    super.dispose();
  }
}