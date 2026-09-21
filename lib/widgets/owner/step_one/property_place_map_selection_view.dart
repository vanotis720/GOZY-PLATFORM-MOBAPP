import 'dart:async';


import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/resources/app_colors.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/screens/views/owner/step_one/step_one_controller.dart';
import 'package:gozy/widgets/common/custom_container/custom_counter_container.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_text.dart';

import 'package:gozy/generated/assets.dart';
import 'package:gozy/widgets/rect_getter.dart';
import '../../show_google_map.dart';



class PropertyPlaceMapSelectionView extends GetView{
   @override
  StepOneController controller;
  GoogleMapController? googlemapController;
   RxString futureStatus = 'waiting'.obs;
   bool isbuildcalled = false;
   bool _isMapInteractionEnabled = false;
  Uint8List? memorybytes;

  PropertyPlaceMapSelectionView({super.key,
    required this.controller,
  });


  @override
  Widget build(BuildContext context) {
    debugPrint('step1rebuild PropertyPlaceMapSelectionView ');
    debugPrint('googlemapController: $googlemapController');
    isbuildcalled = true;
    _delayedFuture();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.addressLatLng != null &&
          controller.addressLatLng!.latitude != 0.0 &&
          controller.addressLatLng!.longitude != 0.0 &&
          controller.isUpdateSelectedItem.value == false &&
          !controller.isFromAddressPage) {
        controller.isLocationSelected.value = true;
      }
      _isMapInteractionEnabled = false;
      Future.delayed(const Duration(seconds: 1)).then((_) {
        _isMapInteractionEnabled = true;
      });
    });
    return  Obx(() => controller.isLoading.value ? const SizedBox.shrink() :
      [
        Obx(() {
          debugPrint('futureStatus.value: ${futureStatus.value}---$isbuildcalled--${controller.choosedIndex}');
          return [
            Obx(()=> controller.memoryImageProvider.value),

            LayoutBuilder(
              builder: (context, constraints) {
                final mapHeight = constraints.maxHeight + 25;
                return OverflowBox(
                  maxHeight: mapHeight,
                  alignment: Alignment.topCenter,
                  child: RectGetter(
                    key: controller.mapRectKey,
                    child: ClipRRect(
                      borderRadius: BorderRadiusGeometry.vertical(top: Radius.circular(overALLAppLayoutModel?.borderRadius ?? 0)),
                      child: SizedBox(
                        width: double.infinity,
                        height: mapHeight,
                        child: showGoogleMap(
                          initialLatLng: controller.addressLatLng ?? LatLng(0.0, 0.0),
                          controller: controller,
                          initialZoomLevel: 15,
                          borderRadius: overALLAppLayoutModel?.borderRadius ?? 0,
                          padding: EdgeInsets.only(bottom: 25),
                          isTopOnly: true,
                          zoomControlsEnabled: true,
                          onCameraMove: (position) {
                            if (!_isMapInteractionEnabled) return;
                            controller.isLocationSelected.value = false;
                            controller.isLocationConfirmed.value = false;
                            controller.isInitialMapLoad.value = false;
                            controller.isUpdateSelectedItem.value = false;
                            controller.addressLatLng = position.target;
                          },
                          onDown: (_) {
                            controller.apiCountryZipcode = '${controller.selectedCountrycode}_${controller.zipCodeController.Ttext}';
                            controller.hideSnackBar();
                            debugPrint("onDown called");
                          },
                          onCameraIdle: () {
                            controller.isUpdateSelectedItem.value = true;
                            if (!_isMapInteractionEnabled) return;
                            controller.isLocationSelected.value = true;
                            controller.isLocationConfirmed.value = true;
                            if(googlemapController !=null) _takeSnapshot();
                          },
                          onMapCreated: (mapController) {
                            googlemapController = mapController;
                            Future.delayed(const Duration(seconds: 1)).then((_) {
                              _isMapInteractionEnabled = true;
                            });
                              if(memorybytes ==null && googlemapController !=null){
                                Future.delayed(const Duration(milliseconds: 1500)).then((demand) {
                                  Rect? overlayrect = RectGetter.getRectFromKey(controller.mapRectKey);
                                  if(overlayrect !=null  && overlayrect != Rect.zero) {
                                    _takeSnapshot();
                                  }
                                });
                              }
                          }
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            if(isbuildcalled) Obx(()=> controller.memoryImageProvider.value),

          ].toStack(clipBehavior: Clip.none);
        }
        ),
        Obx(() => controller.isUpdateSelectedItem.value ?
        Positioned.fill(
          child: IgnorePointer(
            ignoring: true,
            child: Align(
              alignment: AlignmentDirectional.center,
              child: CustomCounterContainer(
                  width: 200,
                  height: 200,
                  color: appColors.primaryColor.withValues(alpha:0.2),
                  borderColor: appColors.primaryColor,
                  borderWidth: 2,

              ),
            ),
          ),
        ) : const SizedBox.shrink(),
        ),

        Positioned.fill(
          child: IgnorePointer(
            ignoring: true,
            child: Align(
               alignment: AlignmentDirectional.center,
                child: Assets.drawablePinLocationOnMapMarker.toSVG(colour: appColors.primaryColor, size: 50)),
          ),
        ),
        Obx(()=>
            Padding(
              padding: const EdgeInsets.only(top: 18.0, left: 24, right: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(AppDimen.appBorderRadius)),
                child: ColoredBox(
               color: controller.isLocationSelected.value ? Color(0xC914A64A) : AppColors.staticblack.withValues(alpha: 0.75),
              child: [
                controller.isLocationSelected.value ? Assets.drawableMapPageTick.toSVG() : Assets.drawablePinLocationOnMapInfo.toSVG(),
                8.toWidth(),
                CustomText(text: controller.isLocationSelected.value ? label_pin_set_on_map_success_thanks.tr : label_drag_the_pin_to_set_location.tr, size: AppDimen.textSize_12,
                color: AppColors.staticwhite,).toStretch()
              ].toRow().toPad(horizontal: 12, vertical: 15),
                        ),
                      ),
            ),
        ),
      ].toStack(clipBehavior: Clip.none)
    ).toClipTopRounded(radius: overALLThemeType == 3 ? ((overALLAppLayoutModel?.borderRadius ?? 0) + 6) : overALLAppLayoutModel?.borderRadius ?? 0).toFitToDeviceWidth(width: deviceWidth);
  }

  Future<void> _delayedFuture()  async{
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      futureStatus.value = 'waiting';
      await Future.delayed(Duration(milliseconds: 500));
      isbuildcalled = false;
      futureStatus.value = 'done';
    });

  }

  Future<void> _takeSnapshot() async {
    memorybytes = await googlemapController!.takeSnapshot();
    debugPrint('bottompadding: $bottomViewPadding --- $deviceHeight');
    controller.memoryImageProvider.value =  Image(
      image:  MemoryImage(memorybytes!),
      width: deviceWidth,
      height: deviceHeight,
      fit: BoxFit.fill,
    );

  }
 Future<bool> setValidation() async {
    if(memorybytes !=null ) {
      bool isgetListingData = await controller.setValidation();
      if (!controller.isLocationSelected.value && isgetListingData) {
        controller.hideKeyBoard();
        controller.showSnackBar(label_drag_the_pin_to_set_location.tr, isltralign: true);
      }
      debugPrint('isLocationSelected: ${controller.isLocationSelected.value} --- $isgetListingData');
      return controller.isLocationSelected.value;
    } else {
      return false;
    }
  }
}