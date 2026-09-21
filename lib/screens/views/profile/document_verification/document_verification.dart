import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/screens/views/profile/edit_profile/edit_profile_controller.dart';
import 'package:gozy/widgets/common/custom_bottomsheet/custom_bottomsheet.dart';
import 'package:gozy/widgets/common/custom_bottomsheet/custom_draggable_bottomsheet.dart';
import 'package:gozy/widgets/common/custom_bottomsheet/custom_getx_bottomsheet.dart';
import 'package:gozy/widgets/common/custom_container/custom_border_container.dart';
import 'package:gozy/widgets/common/custom_network_image/custom_clip_network_image.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_text.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../constant.dart';
import '../../../../generated/assets.dart';
import '../../../../resources/app_colors.dart';
import '../../../../resources/app_dimen.dart';
import '../../../../resources/app_font.dart';
import '../../../../resources/app_layout.dart';
import '../../../../widgets/common/custom_container/custom_container.dart';
import '../../../../widgets/custom_list_item.dart';
import '../../../../widgets/dotted_border/dotted_border.dart';
import '../../base_controller.dart';

class UploadDocumentsBottomSheet extends BaseController {
  late EditProfileController controller = Get.find();
  static int profileThemeType = appLayoutMap[AppLayout.profile]?.themeType ?? 0;
  var isDocumentClicked = false;

  @override
  init() {
    controller.isDocumentUpload = true;
    return super.init();
  }

  @override
  void dispose() {
    controller.isDocumentUpload = false;
    controller.heavyImageCount = 0;
    super.dispose();
  }

  UploadDocumentsBottomSheet() {
    double borderRadius = 0;
    String? documentIcon;
    Color? documentColor;
    Color? borderColor;
    controller.isInUploadpage = true;
    showCustomBottomSheet(
      sheetCloseListener: () {
        controller.getProfile();
      },
      contentWidget: CustomContainer(
        body: GetBuilder(
            init: controller,
            id: controller.rxIsFilesPicking.id,
            builder: (context) {
              switch (profileThemeType) {
                case 1:
                  borderRadius = 6;
                  documentIcon = Assets.drawableGallery;
                  documentColor = appColors.black;
                  borderColor = appColors.filterDividerColor;
                  break;
                case 2:
                  borderRadius = 0;
                  documentIcon = Assets.drawableAddDocument;
                  documentColor = appColors.secondaryColor;
                  borderColor = appColors.secondaryColor;
                  break;
                case 3:
                  borderRadius = 30;
                  documentIcon = Assets.drawableGallery;
                  documentColor = appColors.secondaryColor;
                  borderColor = appColors.filterDividerColor;
                  break;
                case 4:
                  borderRadius = 12;
                  documentIcon = Assets.drawableGallery;
                  documentColor = appColors.black;
                  borderColor = appColors.filterDividerColor;
                  break;
              }
              return Obx(() {
                int count = controller.getImages.length + controller.uploadingPhotos.length + 1;
                debugPrint("CustomContainer: $count");
                return [
                  if (controller.rxIsFilesPicking.value) dotCenter120HeightLoader!,
                  [
                    15.toHeight(),
                    CustomText(
                      text: document_verify_info_content.tr.replaceAll("\n", ""),
                      size: AppDimen.textSize_16,
                      fontWeight: AppFont.regular,
                    ),
                    15.toHeight(),
                    toGridView(
                        baseController: controller,
                        crossAxisSpacing: AppDimen.startMargin - 5,
                        mainAxisSpacing: AppDimen.startMargin,
                        gridItemCount: 2,
                        itemSize: 120,
                        scrollController: controller.scrollController,
                        padding: pad(bottom: 25,top: 10),
                        itemCount: count,
                        itemBuilder: (BuildContext context, int index) {
                          if (index == 0) {
                            return toOnTap(
                              onTap: () {
                                controller.selectedImageOption.value = "";
                                GetXBottomSheet(
                                  bottomSheetWidget: getDraggableSheetWidget(
                                    controller: controller,
                                    widgetsList: getImagePickerOptions(
                                        controller: controller,
                                        selectedImageOption: controller.selectedImageOption,
                                        isFrom: "documentVerification",
                                        onTap: controller.pickDocumentFile),
                                  ),
                                );
                              },
                              child: DottedBorder(
                                  borderType: BorderType.RRect,
                                  color: borderColor,
                                  dashPattern: [4, 4],
                                  strokeWidth: 1,
                                  strokeCap: StrokeCap.round,
                                  radius: Radius.circular(borderRadius),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                                    child: [
                                      (documentIcon ?? '')
                                          .toSVG(size: 30, colour: documentColor)
                                          .toPad(bottom: 10),
                                      Center(
                                          child: CustomText(
                                              text: "${label_add.tr} ${(label_document.tr).toLowerCase()}",
                                              textAlign: TextAlign.center,
                                              fontWeight: AppFont.regular,
                                              color: documentColor,
                                              size: AppDimen.textSize_16)),
                                      10.toHeight(),
                                    ].toColumn(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center),
                                  )).toPad(start: 1),
                            );
                          } else {
                            Widget? uploadingfileWidget;
                            int? listshowimageid;
                            bool isProgressShow = false;
                            String? listshowimage;
                            if (controller.getImages.length > (index - 1)) {
                              listshowimage = controller.getImages[index - 1].fileName;
                              listshowimageid = controller.getImages[index - 1].id;
                            } else if (controller.uploadingPhotos.isNotEmpty) {
                              int uploadingindex = index - controller.getImages.length - 1;
                              uploadingfileWidget =
                                  getuploadingWidget(controller.uploadingPhotos[uploadingindex]);
                              isProgressShow = uploadingindex == 0;
                            }
                            return [
                              listshowimage != null
                                  ? listshowimage.contains('pdf')
                                      ? toOnTap(
                                          onTap: () async {
                                            if (!isDocumentClicked) {
                                              isDocumentClicked = true;
                                              Future.delayed(Duration(seconds: 1), () {
                                                isDocumentClicked = false;
                                              });
                                              controller.pdfURl = "$documentImages$listshowimage";
                                              if (await canLaunchUrl(Uri.parse(controller.pdfURl))) {
                                                launchUrl(
                                                  Uri.parse(controller.pdfURl),
                                                  mode: LaunchMode.inAppBrowserView,
                                                );
                                              }
                                            }
                                          },
                                          child: CustomBorderContainer(
                                            width: deviceWidth,
                                            height: deviceHeight,
                                            borderWidth: 0,
                                            borderRadius: borderRadius,
                                            padding: pad(a: 30),
                                            color: appColors.popularLocationBottomShadowColor.withAlpha(20),
                                            body: Assets.drawablePdf.toSVG(),
                                          ))
                                      : CustomClipNetworkImage(
                                          imageUrl: (documentImages + listshowimage),
                                          placeholderURL: documentImages + listshowimage,
                                          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                                          placeholderWidget: controller.uploadingplaceholder[listshowimage] ??
                                              showPlaceHolderWidget(),
                                        )
                                  : uploadingfileWidget ?? showPlaceHolderWidget(),
                              if (listshowimage != null)
                                CustomBorderContainer(
                                  onTap: () {
                                    if (!controller.isRxBottomSheetLoading.value) {
                                      controller.documentName = listshowimage ?? "";
                                      controller.change(
                                          rxVariable: controller.isRxBottomSheetLoading, value: true);
                                      controller.checkNetwork(controller.removeListPhotos);
                                    }
                                  },
                                  height: 23,
                                  width: 23,
                                  color: AppColors.staticblack,
                                  borderColor: AppColors.staticwhite,
                                  padding: pad(w: 6, h: 6),
                                  borderWidth: 0,
                                  margin: const EdgeInsetsDirectional.only(top: 10, end: 10),
                                  borderRadius: 100,
                                  body: Assets.drawableSignupClose
                                      .toSVG(colour: AppColors.staticwhite, size: 8),
                                ).toPositionedAlign(alignment: AlignmentDirectional.topEnd),
                              if (isProgressShow)
                                Obx(() {
                                  debugPrint(
                                      'controller.uploadProgress.value: ${controller.uploadProgress.value}');
                                  return Center(
                                    child: double.parse(controller.uploadProgress.value) <= 1.0
                                        ? [
                                            TweenAnimationBuilder<double>(
                                                duration: const Duration(milliseconds: 150),
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
                                }),
                            ].toStack();
                          }
                        }).toScroll().toPad(bottom: 10).toStretch(),
                  ].toColumn(),
                  GetBuilder(
                    init: controller,
                    id: controller.isRxBottomSheetLoading.id,
                    builder: (context) {
                      if (controller.isRxBottomSheetLoading.value) {
                        return Container(color: Colors.transparent, child: dotCenter120HeightLoader!);
                      } else {
                        return 0.toHeight();
                      }
                    },
                  ),
                ].toStack();
              });
            }),
      ).toPad(horizontal: AppDimen.startMargin),
      title: label_document_verification.tr,
      backButtonWidget: getBackIconWidget(backIcon: Assets.drawableSignupClose, themeType: profileThemeType),
    );
  }

  Widget showPlaceHolderWidget({bool isRemoveBody = false}) {
    return CustomBorderContainer(
      width: deviceWidth,
      height: deviceHeight,
      borderRadius: 16,
      borderWidth: 0,
      padding: pad(a: 30),
      color: appColors.shimmerplaceholderColor,
      body: isRemoveBody
          ? null
          : Assets.drawablePropertyListImage
              .toPng(width: 5, height: 5, fit: BoxFit.scaleDown)
              .toResizeWidget(height: 5, width: 5),
    );
  }
}