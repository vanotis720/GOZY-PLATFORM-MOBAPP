import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/widgets/common/custom_bottomsheet/custom_draggable_bottomsheet.dart';
import 'package:gozy/widgets/common/custom_bottomsheet/custom_getx_bottomsheet.dart';
import 'package:gozy/widgets/common/custom_container/custom_border_container.dart';
import 'package:gozy/widgets/common/custom_container/custom_counter_container.dart';
import 'package:gozy/widgets/common/custom_network_image/custom_clip_network_image.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_list_item.dart';
import 'package:gozy/widgets/custom_text.dart';
import 'package:gozy/widgets/dotted_border/dotted_border.dart';

import '../../../resources/app_colors.dart';
import '../../../screens/views/base_controller.dart';
import '../../../screens/views/owner/step_two/step_two_controller.dart';
import '../../common/custom_container/custom_container.dart';

class PropertyPhotoUploadView extends GetView {
  @override
  StepTwoController controller;
  double imageBorderRadius = 0.0;
  String addPhotoImage = Assets.drawableGallery;
  Color addPhotoBorderColor = appColors.colorCommonLinkColor;
  Color addPhotoImageColor = appColors.colorCommonLinkColor;

  PropertyPhotoUploadView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    switch (overALLThemeType) {
      case 1:
        imageBorderRadius = 6;
        addPhotoImageColor = appColors.black;
        addPhotoBorderColor = appColors.black;
        break;
      case 2:
        imageBorderRadius = 0;
        addPhotoImage = Assets.drawableAddDocument;
        addPhotoImageColor = appColors.secondaryColor;
        addPhotoBorderColor = appColors.secondaryColor;
        break;
      case 3:
        imageBorderRadius = 30;
        addPhotoImageColor = appColors.secondaryColor;
        addPhotoBorderColor = appColors.myTripsDividerColor;
        break;
      case 4:
        imageBorderRadius = 12;
        addPhotoImageColor = appColors.black;
        addPhotoBorderColor = appColors.myTripsDividerColor;
        break;
    }

    controller.isInUploadpage = true;
    bool isIdExist = false;
    if (controller.itemInfo.listPhotos != null) {
      controller.itemInfo.listPhotos.forEach((element) {
        if (!isIdExist) {
          isIdExist = (element.id == controller.itemInfo.coverPhoto);
        }
      });
    }
    debugPrint("isIdExist: $isIdExist");
    return [
      AppDimen.startMargin.toHeight(),
      CustomText(
        text: label_upload_car_photos.tr,
        size: AppDimen.textSize_18,
        fontWeight: FontWeight.w600,
      ),
      Obx(() {
        debugPrint(
            'controller.isLoadingabc.value: ${controller.uploadingPhotos}---${controller.isFilesPicking.value}--${controller.uploadingplaceholder}---${controller.coverphotoid}');
        controller.itemInfo = controller.getItemInfo().$1 ?? controller.itemInfo;
        int? count = int.parse((controller.uploadingPhotos.length +
            (controller.itemInfo.listPhotos?.length ?? 0) +
            1).toString());
        return [
          if (controller.isFilesPicking.value) dotCenter120HeightLoader!,
          toGridView(
            baseController: controller,
            crossAxisSpacing: AppDimen.startMargin - 5,
            mainAxisSpacing: AppDimen.startMargin,
            gridItemCount: 2,
            itemSize: 120,
            scrollController: controller.scrollController,
            padding: pad(h: 25),
            physics: ClampingScrollPhysics(),
            itemCount: count ?? 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return toOnTap(
                  onTap: () {
                    GetXBottomSheet(
                        bottomSheetWidget: getDraggableSheetWidget(
                      controller: controller,
                      widgetsList: getImagePickerOptions(
                          controller: controller,
                          selectedImageOption: controller.selectedImageOption,
                          isFrom: "step2",
                          onTap: controller.pickFile),
                        ),
                    );
                  },
                  child: DottedBorderView(
                      dottedlineColor: addPhotoBorderColor,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(
                            Radius.circular(imageBorderRadius)),
                        child: [
                          addPhotoImage.toSVG(
                            size: 30,
                            colour: addPhotoImageColor,
                          ),
                          8.toHeight(),
                          Center(
                            child: CustomText(
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              text: label_add_photos.tr,
                              color: addPhotoImageColor,
                              textAlign: TextAlign.center,
                              fontWeight: AppFont.medium,
                              size: AppDimen.textSize_16
                            )
                          ),
                        ].toColumn(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center).toPad(horizontal: 10),
                      ),
                  ),
                );
              } else {
                String? listshowimage, coverimage;
                int? listshowimageid;
                Widget? uploadingfileWidget;
                bool isProgressShow = false;
                if ((controller.itemInfo.listPhotos?.length ?? 0) > (index - 1)) {
                  listshowimage =
                      controller.itemInfo.listPhotos[index - 1].name;
                  listshowimageid =
                      controller.itemInfo.listPhotos[index - 1].id;
                  coverimage = (controller.coverphotoid != null &&
                          controller.coverphotoid == listshowimageid)
                      ? listshowimage
                      : null;
                  if (!isIdExist) {
                    coverimage = controller.itemInfo.listPhotos[0].name;
                    controller.coverphotoid =
                        controller.itemInfo.listPhotos[0].id;
                    controller.updateInitialCoverPhotoOnFragment(
                        controller.coverphotoid, coverimage);
                    isIdExist = true;
                  } else if (coverimage == null &&
                      controller.coverphotoid == null &&
                      controller.itemInfo.listPhotos.length > 0 &&
                      controller.itemInfo.listPhotoName != null) {
                    coverimage = controller.itemInfo.listPhotoName;
                    controller.coverphotoid = controller.itemInfo.coverPhoto;
                  }
                } else if (controller.uploadingPhotos.isNotEmpty) {
                  int uploadingindex = int.parse((index -
                      (controller.itemInfo.listPhotos?.length ?? 0) -
                      1).toString());
                  uploadingfileWidget = getuploadingWidget(
                      controller.uploadingPhotos[uploadingindex]);
                  isProgressShow = uploadingindex == 0;
                }

                return [
                  listshowimage != null
                      ? CustomClipNetworkImage(
                      imageUrl: (imgListingMedium + listshowimage),
                          borderRadius:  BorderRadius.all(Radius.circular(imageBorderRadius)),
                          cacheKey: 'step2_photo',
                          placeholderURL: imgListingSmall + listshowimage,
                          placeholderWidget:
                              controller.uploadingplaceholder[listshowimage] ??
                                  showPlaceHolderWidget(),
                        )
                      : uploadingfileWidget ?? showPlaceHolderWidget(),
                  if (listshowimage != null)
                    [
                      CustomContainer(
                        body: stepTwoImageOverlayWidget(
                          borderColor: appColors.white,
                          onTap: () {
                            controller.coverphotoid = listshowimageid;
                            controller.uploadingPhotos.refresh();
                          },
                          color: coverimage == listshowimage
                              ? appColors.white
                              : appColors.black,
                          body: [
                            coverimage == listshowimage
                                ? Assets.drawableViewdetailReportTick
                                    .toSVG(size: 6, colour: appColors.black)
                                    .toPad(end: 3)
                                : Container(
                                    height: 10,
                                    width: 10,
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: appColors.white),
                                        shape: BoxShape.circle),
                                  ).toPad(end: 3),
                            CustomText(
                              text: label_step_two_cover_photo.tr,
                              color: coverimage == listshowimage
                                  ? appColors.black
                                  : appColors.white,
                              size: AppDimen.textSize_10,
                              maxLines: 1,
                              fontWeight: AppFont.regular,
                            )
                          ].toRow(mainAxisSize: MainAxisSize.min),
                        ),
                      ),
                      Spacer(),
                      CustomCounterContainer(
                        margin: pad(end: overALLThemeType == 3 ? 10 : 6, top: 8),
                        height: 20,
                        width: 20,
                        onTap: () {
                          debugPrint(
                              'controller.removingPhotoList: ${controller.removingPhotoList}');
                          if (controller.removingPhotoList.isEmpty) {
                            controller.removingPhotoList.add(listshowimage!);
                            isShowLoader = false;
                            controller.isLoading.value = true;
                            controller
                                .isNetworkConnected()
                                .then((isnetConnected) {
                              if (isnetConnected) {
                                controller.removeListPhotos();
                              } else {
                                controller.removingPhotoList.clear();
                                controller.isLoading.value = false;
                              }
                            });
                          }
                        },
                        color: AppColors.staticblack.withAlpha(80),
                        body: Assets.drawableSignupClose.toSVG(colour: AppColors.staticwhite).toPad(all: 5),
                        borderWidth: 1,
                        borderColor: AppColors.staticwhite,
                      )
                    ].toRow().toPositionedAlign(
                        alignment: AlignmentDirectional.topStart),
                  if (isProgressShow)
                    Obx(() {
                      debugPrint(
                          'controller.uploadProgress.value: ${controller.uploadProgress.value}');
                      return Center(
                        child: double.parse(controller.uploadProgress.value) <=
                                1.0
                            ? [
                                TweenAnimationBuilder<double>(
                                    duration: Duration(milliseconds: 150),
                                    curve: Curves.linear,
                                    tween: Tween<double>(
                                      begin: controller.previousprogress,
                                      end: double.parse(
                                          controller.uploadProgress.value),
                                    ),
                                    builder: (context, value, _) {
                                      return CircularProgressIndicator(
                                        backgroundColor:
                                            appColors.keyboardColor,
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
                  else if (controller.isLoading.value &&
                      ((controller.removingPhotoList.isNotEmpty &&
                              controller.removingPhotoList
                                  .contains(listshowimage)) ||
                          uploadingfileWidget != null))
                    controller
                        .getLoader(
                            loader: LottieLoaders.three_dots_loader.name,
                            changed: appThemeChanged.value,
                            color: appColors.secondaryColor)
                        .toPositionedAlign(alignment: Alignment.center),
                ].toStack();
              }
            },
          )
        ].toStack().toStretch();
      })
    ].toColumn(crossAxisAlignment: CrossAxisAlignment.start);
  }

  Widget showPlaceHolderWidget({bool isRemoveBody = false}) {
    return CustomBorderContainer(
      width: deviceWidth,
      height: deviceHeight,
      borderRadius: 16,
      borderWidth: 0,
      padding: pad(a: 30),
      color: appColors.popularLocationBottomShadowColor,
      body: isRemoveBody
          ? null
          : Assets.drawablePropertyListImage
              .toPng( height: 5, width: 5, fit: BoxFit.scaleDown)
              .toResizeWidget(height: 5, width: 5),
    );
  }

  Widget stepTwoImageOverlayWidget(
      {GestureTapCallback? onTap,
      required Widget body,
      AlignmentGeometry? alignment,
      Color? color,
      Color? borderColor,
      double? startMargin,
      double? endMargin}) {
    return CustomBorderContainer(
      onTap: onTap,
      color: color,
      borderColor: borderColor,
      margin: pad(top: 10, start: 10, end: endMargin ?? 0),
      padding: pad(w: 5, h: 5),
      borderWidth: 1,
      borderRadius: 25,
      body: body,
    );
  }
}