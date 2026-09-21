import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/resources/app_colors.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/custom_scaffold.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/common/custom_container/custom_container.dart';

import 'common/custom_dialog/custom_dialog.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  var isOpenCamera = false.obs;
  var isFlash = false.obs;
  bool isRedirectedToSettings = false;
  Future<void>? _initializeControllerFuture;
  RxInt selectedCamera = 0.obs;
  Map<String, dynamic>? passingArguments;


  @override
  void initState() {
    passingArguments = Get.arguments;
    WidgetsBinding.instance.addObserver(this);
    requestCameraPermission();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.resumed &&  isRedirectedToSettings) {
      isRedirectedToSettings = false;
      Permission.camera.status.then((status){
        cameraPermission(status.name);
      });

    }
    super.didChangeAppLifecycleState(state);
  }

  void cameraPermission(String permissionStatus) {
    if (permissionStatus == "granted") {
      initializeCamera(selectedCamera.value);
      isOpenCamera.value = true;
    } else {
      isOpenCamera.value = false;
    }
  }

  Future<void> initializeCamera(int cameraIndex) async {
    debugPrint('initializeCamera index: $cameraIndex');
    if (cameraIndex == 1) {
      isFlash.value = false;
    }
      cameraController = CameraController(
          cameras[cameraIndex], ResolutionPreset.medium,
          enableAudio: false);
      _initializeControllerFuture = cameraController?.initialize();
    cameraController!.setFlashMode(FlashMode.off);
  }

  @override
  void dispose() {
    if(Platform.isIOS) {
      cameraController?.pausePreview();
    }
    if(Platform.isAndroid){
      cameraController?.dispose();
      cameraController = null;
    }
    isOpenCamera.close();
    isFlash.close();
    selectedCamera.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: appColors.appBGColor,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black,
          body: _getBody(),
        ),
      ),
    );
  }


  Widget _getBody() {
    return [
      _getCameraPreviewWidget(),
      _getNavigation(),
      Align(
        alignment: Alignment.bottomCenter,
        child: _getCameraPreviewBottomWidgets(),
      )
    ].toStack();
  }

  Widget _getCameraPreviewWidget() {
    var a= please_enable_the_permission.trParams({'field' :settings.tr.toLowerCase()}).toUpperLowerCase();

    print('test9${a.split('\n\n')[0]}');
    return Obx(
      () => isOpenCamera.value
          ? FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                debugPrint('camerasnapshot: ${snapshot.connectionState}');
                if (snapshot.connectionState == ConnectionState.done) {
                  var scale = MediaQuery.of(context).size.aspectRatio * cameraController!.value.aspectRatio;
                  if (scale < 1) scale = 1 / scale;
                  
                  return SizedBox(
                    height: deviceHeight,
                    width: double.infinity,
                    child: ClipRect(
                      child: Transform.scale(
                        scale: scale,
                        alignment: Alignment.center,
                        child: Center(
                          child: CameraPreview(cameraController!),
                        ),
                      ),
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            )
          :  Center(
            child: showSearchableSpanWidget(
                primaryColor: Colors.white,

                fontSize: AppDimen.textSize_14,
                primary: please_enable_the_permission.trParams({'field' :settings.tr.toLowerCase()}).toUpperLowerCase(),
                search: settings.tr.toLowerCase(),
                highlightColor: AppColors.linkColor,
                searchTextNavigation: () => cameraPermissionDialog(context)
                  ),
          ),
    );
  }

  Widget _getNavigation() {
    return getBackIconWidget(
       themeType: overALLThemeType, margin: pad(a: 20),
        size: AppDimen.backIconSize,
        iconBGColor: Colors.black, iconColor: Colors.white, borderColor: Colors.black);
  }

  Widget _getCameraPreviewBottomWidgets() {
    return [
      toOnTap(
        onTap: () {
          debugPrint("cameras.length: ${cameras.length}");
          if (cameras.length > 1) {
            selectedCamera.value = selectedCamera.value == 0 ? 1 : 0;
            initializeCamera(selectedCamera.value);
            isOpenCamera.refresh();
          } else {
            passingArguments!["controller"].showSnackBar(no_secondary_camera_found.tr, isltralign: true);
          }
        },
        child: const Icon(Icons.switch_camera_rounded, color: Colors.white),
      ),
      CustomContainer(
        height: 60,
        width: 60,
        onTap: () async {
          await _initializeControllerFuture;
          var xFile = await cameraController!.takePicture();
          if(cameraController!.description.lensDirection == CameraLensDirection.front){
            final flippedFile = await flipImageHorizontally(File(xFile.path));
            xFile = XFile(flippedFile.path);
          }
          cameraController!.setFlashMode(FlashMode.off);
          if (xFile.path.isNotEmpty) {
            localImagePath = "";
            onBack();
            await basecontroller.cropFile(xFile.path)?.then((result) async{
              if(result!=null){
                if(passingArguments!["isFrom"] == "profile"){
                  localImagePath = xFile.path;
                  passingArguments!["controller"].isProfileImageLoading.value = true;
                  var profileImage = await basecontroller.uploadImage(
                      uploadUrl: uploadPhoto,
                      file: File(result??''),
                      isFromProfile: true);
                  if(profileImage != null) {
                    passingArguments!["controller"].profileImage.value = profileImage;
                    passingArguments!["controller"].isProfileImageLoading.value = false;
                  }
                }
                else {
                  if (passingArguments!["controller"].isInUploadpage) {
                    passingArguments!["controller"].uploadingPhotos.add(result);
                    passingArguments!["controller"].photoUploadingFuture = passingArguments!["controller"].UploadSelectedFiles();
                  }
                }
              }
            });
          }
        },
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
      ),
      Obx(() =>
        selectedCamera.value == 0
          ? Obx(() => toOnTap(
              onTap: () {
                isFlash.value = !isFlash.value;
                if (isFlash.value) {
                  cameraController!.setFlashMode(FlashMode.torch);
                } else {
                  cameraController!.setFlashMode(FlashMode.off);
                }
              },
              child: !isFlash.value
                  ? const Icon(Icons.flash_off, color: Colors.white)
                  : const Icon(Icons.flash_on, color: Colors.white,),
            )
          )
          : SizedBox(height: 60, width: 25,)
      )
    ].toRow(mainAxisAlignment: MainAxisAlignment.spaceBetween).toPad(horizontal: 24).toResizeWidget(height: Platform.isAndroid ? deviceHeight * 0.15 : deviceHeight * 0.15, color: AppColors.staticblack);
  }

  void cameraPermissionDialog(BuildContext context) {
     showAlertDialog(

      contentText: label_please_grant_the_permission.trParams({'field' :upload_your_profile_photo.tr.toLowerCase()}),
      onOkPressed: (){
        isRedirectedToSettings = true;
        openAppSettings().then((value){
          debugPrint("openAppSettings: ${value}");
        });
        Get.back();
      },
      cancelButtonContent :label_cancel.tr,
      okButtonContent: settings.tr);
  }
  Future<void> requestCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      Permission.camera.request().then((permissionStatus) {
        cameraPermission(permissionStatus.name);
      });
      return;
    }
    if (status.isDenied) {
      Permission.camera.request().then((permissionStatus) {
        cameraPermission(permissionStatus.name);
      });
      return;
    }
  }

  Future<File> flipImageHorizontally(File file) async {
    final bytes = await file.readAsBytes();
    img.Image? original = img.decodeImage(bytes);
    if (original == null) return file;

    img.Image flipped = img.flipHorizontal(original);

    final flippedBytes = img.encodeJpg(flipped);
    final flippedFile = await file.writeAsBytes(flippedBytes, flush: true);
    return flippedFile;
  }

}