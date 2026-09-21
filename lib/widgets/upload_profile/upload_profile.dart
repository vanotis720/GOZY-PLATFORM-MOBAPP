import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gozy/resources/app_layout.dart';
import 'package:gozy/widgets/common/custom_bottomsheet/custom_draggable_bottomsheet.dart';
import 'package:gozy/widgets/common/custom_bottomsheet/custom_getx_bottomsheet.dart';
import 'package:gozy/widgets/common/custom_network_image/custom_profile_network_image.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_list_item.dart';
import 'package:gozy/widgets/upload_profile/upload_profile_controller.dart';

import '../../constant.dart';
import '../../screens/views/base_controller.dart';

class UploadProfile extends StatelessWidget {
  final UploadProfileController controller = Get.find();
  final String? uploadIcon;
  final int? themeType;
  UploadProfile({super.key, this.uploadIcon, this.themeType});

  @override
  Widget build(BuildContext context) {
    return _getEditProfileView();
  }

  Widget _getEditProfileView() {
    double? alignposition;
    String? dividerType;
    switch (themeType) {
      case 2:
      case 3:
        dividerType = 'line';
        break;
      case 4:
        dividerType = 'dot';
        alignposition = 8;
        break;
    }
    return Obx(() {
      final String localPath = localImagePath;
      final bool hasLocalImage =
          localPath.isNotEmpty && File(localPath).existsSync();
      final Widget? localImageWidget = hasLocalImage
          ? ClipOval(
        child: Image.file(
          File(localPath),
          width: 170,
          height: 170,
          fit: BoxFit.cover,
        ),
      )
          : null;
      return [
        CustomProfileNetworkImage(
            isRoundIcon: themeType != 4,
            isShimmerView: controller.isProfileImageLoading.value &&
                controller.profileImage.value.isEmpty &&
                controller.previousImage.value.isEmpty,
            profileImageType: localImagePath.isNotEmpty? localImagePath : appLayoutMap[themeType]?.profileIconType ?? '',
            imageUrl: localImagePath.isNotEmpty? localImagePath : controller.profileImage.value,
            placeholder: localImageWidget,
            all: 120,
            alignPosition: alignposition,
            editIcon: uploadIcon ?? overALLAppLayoutModel!.imageUploadIcon,
            indicatorColor: Colors.transparent,
            onTap: () {
              debugPrint(
                  'controller.profileImage.value: ${controller.profileImage.value}');
              if (sdkversion >= 34) {
              } else if (sdkversion > 32 || Platform.isIOS) {
                Permission.photos.request();
              } else {
                Permission.storage.request();
              }
              controller.selectedImageOption.value = "";
              GetXBottomSheet(
                bottomSheetWidget: getDraggableSheetWidget(
                  controller: controller,
                  borderRadius: appLayoutMap[AppLayout.profile]?.borderRadius,
                  widgetsList: getImagePickerOptions(
                      controller: controller,
                      isFrom: "profile",
                      dividerType: dividerType,
                      selectedImageOption: controller.selectedImageOption,
                      onTap: controller.pickFile),
                  themeType: themeType,
                ),
              );
            }),
        controller.isProfileImageLoading.value
            ? controller
                .getLoader(
                    loader: LottieLoaders.three_dots_loader.name,
                    changed: appThemeChanged.value,
                    color: appColors.secondaryColor)
                .toResizeWidget(all: 100)
                .toPositionedAlign(alignment: Alignment.center)
            : const SizedBox.shrink()
      ].toStack();
    });
  }
}