import 'dart:io';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gozy/app.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/utils/common_file_picker.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import '../../../../constant.dart';
import '../../screens/views/base_controller.dart';

class UploadProfileController extends BaseController {
  RxString profileImage = ''.obs;
  RxString previousImage = ''.obs;
  RxString selectedImageOption = ''.obs;
  RxBool isProfileImageLoading = false.obs;
  @override
  onReady() {
    profileImage.value = appPreference.profileImage ?? "";
    previousImage.value = appPreference.profileImage ?? "";
    availableCameras().then((value) {
      cameras = value;
    });
    super.onReady();
  }

  void pickFile([bool? isFromCamera]) async {
    onBack();
    callbackFunction();
  }

  void callbackFunction() async {
    bool isNetConnected = await isNetworkConnected();
    isShowLoader = true;
    if (isNetConnected) {
      CommonFilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        compressionQuality: compressImageQuality,
        onFileLoading: (status) {
          debugPrint("pick files: $status");
        },
      ).then((result) async {
        if (result != null) {
          localImagePath = "";
          isLoading(true);
          await cropFile(result.paths[0] ?? '')?.then((result) async {
            localImagePath = result ?? "";
            isLoading(false);
            isShowLoader = false;
            if (isNetConnected && result != null) {
              isProfileImageLoading.value = true;
              var profileImage = await uploadImage(
                  uploadUrl: uploadPhoto,
                  file: File(result),
                  isFromProfile: true);
              if (profileImage != null) {
                isLoading(false);
                isShowLoader = false;
                previousImage.value = this.profileImage.value;
                this.profileImage.value = profileImage;
                isProfileImageLoading.value = false;
              }
            }
          });
        }
      });
    }
  }
}