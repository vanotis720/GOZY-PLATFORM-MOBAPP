import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:gozy/app.dart';
import 'package:gozy/config/client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_stateful_widget.dart';
import 'package:gozy/widgets/owner/progressive_chip_view.dart';
import 'package:gozy/widgets/show_done_view.dart';

import '../../../../widgets/common/custom_button/custom_button.dart';
import '../../../../widgets/owner/step_two/property_photo_upload_view.dart';
import '../../../../widgets/owner/step_two/property_title_desc_entry_view.dart';
import '../../base_controller.dart';
import '../../custom_scaffold.dart';
import 'step_two_controller.dart';

class StepTwoPage extends CustomStatefulWidget {
  const StepTwoPage({super.key});

  @override
  _StepTwoPageState createState() => _StepTwoPageState();
}

class _StepTwoPageState extends CustomStatefulWidgetState<StepTwoPage> with TickerProviderStateMixin {
  late StepTwoController controller = Get.find();
  double bottomBorderRadius = 2;
  List<int> StepTwoPages = [];
  Widget? _chipLayout;
  bool _isShowChiplayout = false;
  bool isloading = false;
  Widget? _cachedTheme4Body;

  @override
  void initState() {
    debugPrint("Get.translations[appPreference.preferredLanguage]: ${Get.translations[appPreference.preferredLanguage]?["label_target_renters_type"]}");
    ever(appThemeChanged, (_) {
      _cachedTheme4Body = null;
    });
    controller.itemInfo = Get.arguments['itemInfo'];
    controller.propertyTitleController.text = controller.itemInfo.title ?? '';
    controller.propertyDescController.text = controller.itemInfo.description ?? '';
    controller.coverphotoid = controller.itemInfo.coverPhoto;
    debugPrint('initstate:  controller.coverphotoid: ${controller.coverphotoid}');
    StepTwoPages.add(0);
    controller.initFromApi();
    if (controller.itemInfo.listPhotos != null && controller.itemInfo.listPhotos.isNotEmpty) {
      controller.skipbtnText.value = btn_label_next.tr;
    } else {
      controller.skipbtnText.value = btn_label_skip_for_now.tr;
    }
    _isShowChiplayout =
        (controller.itemInfo != null && controller.itemInfo?.listingSteps?.step2 == 'completed');

    controller.photocount = 0;
    controller.photoUploadCompleter.complete(true);
    debugPrint('sdkversion: $sdkversion');

    if (sdkversion >= 34) {
      debugPrint("sdkversion : $sdkversion");
    } else if (sdkversion > 32 || Platform.isIOS) {
      Permission.photos.request();
    } else {
      Permission.storage.request();
    }
    targetGuest = App().buildReasonList( reasons: targetGuest, labelsString: App().getTargetedGuestLabels() );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch(overALLThemeType) {
      case 1:
        bottomBorderRadius = 20;
        break;
      case 2:
        bottomBorderRadius = 2;
        break;
      case 3:
        bottomBorderRadius = 30;
        break;
      default:
        bottomBorderRadius = 12;
        break;
    }
    return CustomScaffold(
      controller: controller,
      isShowAppBar: true,
      resizeToAvoidBottomInset: false,
      appBarBGColor: appColors.white,
      customAppBarFunction: () {
        _customBackEvent();
      },
      backIconWidget: getBackIconWidget(
        themeType: overALLThemeType,
        onTap: () {
          _customBackEvent();
        },
      ),
      body: InputDoneView(
        controller,
        parentWidget: showBodyContent(context).toPad(bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? MediaQuery.of(context).viewInsets.bottom + 40 : 0)
      ),
    );
  }

  Widget showBodyContent(context) {
    _addItemsToStepLayouts();

    if (_isShowChiplayout) {
      _chipLayout = ProgressiveChipView(
        stepLayoutItems: controller.steptwo_layout_items,
        StepPages: StepTwoPages,
        isloading: isloading,
        choosedIndex: controller.choosedIndex,
        selectedChipIndex: controller.selectedChipIndex,
        controller: controller
      );
    }

    _cachedTheme4Body ??= toPropertyCreationColumn(
      stepLayoutItems: controller.steptwo_layout_items,
      chipLayout: _chipLayout,
      controller: controller,
      cornerRadius: BorderRadiusDirectional.only(topStart: Radius.circular(overALLAppLayoutModel?.borderRadius ?? 8), topEnd: Radius.circular(overALLAppLayoutModel?.borderRadius ?? 8)),
      containerColor: appColors.white,
      borderWidth: 1,
      topRadiusColor: appColors.white,
      stepBasedPages: StepTwoPages,
      choosedIndex: controller.choosedIndex,
      bottomProgressWidget: true,
      tickerprovider: this,
      bottomBorderRadius: bottomBorderRadius,
      selectedChipIndex: controller.selectedChipIndex,
      onTaponSaveExit: () {
        if (!isloading) {
          isloading = true;
          controller.validateStep2Info();
          Future.delayed(Duration(milliseconds: StepBtnclickInterval)).then((value) {
            isloading = false;
          });
        }
      }
    );

    return _cachedTheme4Body!;
  }

  void _addItemsToStepLayouts() {
    controller.steptwo_layout_items.clear();

    PropertyPhotoUploadView propertyPhotoUploadView = PropertyPhotoUploadView(controller: controller);
    Map<String, dynamic> propertyPhotouploadtMap = {};
    propertyPhotouploadtMap['title'] = label_have_a_look_car.tr;
    propertyPhotouploadtMap['widget'] = propertyPhotoUploadView;
    propertyPhotouploadtMap['chipicon'] = Assets.drawableStepTwoChipPhoto;
    propertyPhotouploadtMap['chiptitle'] = label_photos.tr;
    propertyPhotouploadtMap['nextbtn'] = _getNextBtnWidget();
    propertyPhotouploadtMap['onnext'] = () {
      controller.uploadingPhotos.clear();
      return true;
    };
    controller.steptwo_layout_items.add(propertyPhotouploadtMap);

    PropertyTitleDescriptionEntryView propertyTitleDescEntryView = PropertyTitleDescriptionEntryView(
      controller: controller,
    );
    Map<String, dynamic> propertyTitleDescEntryMap = {};
    propertyTitleDescEntryMap['title'] = label_lets_get_a_name.tr;
    propertyTitleDescEntryMap['widget'] = propertyTitleDescEntryView;
    propertyTitleDescEntryMap['chipicon'] = Assets.drawableStepTwoChipTitleDesc;
    propertyTitleDescEntryMap['chiptitle'] = label_name_and_description.tr;
    propertyTitleDescEntryMap['onnext'] = () {
      controller.validateStep2Info();
    };
    controller.steptwo_layout_items.add(propertyTitleDescEntryMap);
  }

  void _customBackEvent() {
    if (!isloading) {
      isloading = true;
      if (StepTwoPages.isNotEmpty) {
        StepTwoPages.removeLast();
      }

      FocusManager.instance.primaryFocus?.unfocus();
      if (StepTwoPages.isEmpty) {
        if (!Get.isSnackbarOpen) {
          clearandbackpress();
        } else {
          Get.back();
          Future.delayed(Duration(milliseconds: 100), () {
            _customBackEvent();
          });
        }
      } else {
        controller.choosedIndex.value = StepTwoPages[StepTwoPages.length - 1];
        controller.isLoading.refresh();
      }
      debugPrint('backpress uploadingPhotos: --${controller.uploadingPhotos}');
      controller.customMultipartRequest?.close();
      controller.uploadingPhotos.clear();
      Future.delayed(Duration(milliseconds: StepBtnclickInterval)).then((value) {
        isloading = false;
      });
    }
  }

  Widget _getNextBtnWidget() {
    return Obx(() => CancelButton(
        isExpand: false,
        verticalPadding: 10,
        fillcolor: controller.isLoading.value ? appColors.primaryColor.withAlpha(50) : appColors.primaryColor,
        color: controller.isLoading.value ? appColors.primaryColor.withAlpha(5) : appColors.primaryColor,
        buttonText: controller.skipbtnText.value,
        textColor: appColors.buttonTextColor));
  }

  void clearandbackpress() {
    controller.coverphotoid = null;
    controller.uploadingPhotos.clear();
    controller.isInUploadpage = false;
    Get.back();
  }

  @override
  void dispose() {
    if (cameraController != null) {
      cameraController?.dispose();
      cameraController = null;
    }
    controller.choosedIndex.value = 0;
    controller.selectedChipIndex.value = 0;
    _cachedTheme4Body = null;
    super.dispose();
  }
}