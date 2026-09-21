import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/owner/step_one/step_one_controller.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_stateful_widget.dart';
import 'package:gozy/widgets/custom_text.dart';
import 'package:gozy/widgets/owner/progressive_chip_view.dart';
import 'package:gozy/widgets/owner/step_one/property_place_map_selection_view.dart';
import 'package:gozy/generated/assets.dart';
import '../../../../widgets/owner/grid_item_selection_widget.dart';
import '../../../../widgets/owner/step_one/property_place_entry_view.dart';
import '../../../../widgets/owner/step_one/ready_to_host_view.dart';
import '../../base_controller.dart';
import '../../custom_scaffold.dart';

class StepOnePage extends CustomStatefulWidget {
  const StepOnePage({super.key});

  @override
  _StepOnePageState createState() => _StepOnePageState();
}

class _StepOnePageState extends CustomStatefulWidgetState<StepOnePage> with TickerProviderStateMixin{
  late StepOneController controller = Get.find();
  List<int> stepOnePages = [];
  Widget? _chipLayout;
  double bottomBorderRadius = 2;
  bool _isShowChiplayout = false;
  bool isloading = false;

  @override
  void initState() {
   isShowLoader = true;
   controller.argumentsmap = Get.arguments;
   controller.listId = null;
   controller.itemInfo = null;
   controller.itemInfo = controller.argumentsmap['itemInfo'];
   controller.isStepOneLoading.value = true;
   controller.getListingSettings().then((value) {
     controller.selectedType = "make";
     controller.getFilterPaginationData().then((value) {
       if(controller.itemInfo != null) {
         controller.selectedMakeType.value = int.parse((controller.itemInfo.makeId ?? 0).toString());
         controller.selectedType = "model";
         controller.getFilterPaginationData().then((value) {
           controller.initFromApi();
           controller.isStepOneLoading.value = false;
           controller.isLoading.refresh();
         });
       }else {
         controller.isStepOneLoading.value = false;
       }
     });
   });
   controller.initSearchListeners();

    _isShowChiplayout = (controller.itemInfo !=null);
    // if(controller.itemInfo !=null && (controller.itemInfo?.listingSteps ==null || controller.itemInfo?.listingSteps?.step2 == 'inactive')) {
    //   stepOnePages.add(3);
    //   controller.choosedIndex.value = 3;
    // }else{
    //   stepOnePages.add(0);
    // }
    stepOnePages.add(0);
    _addItemsToStepLayouts();
    controller.memoryImageProvider =  controller.drawGridLines().obs;

    if(_isShowChiplayout) {
      _chipLayout =  ProgressiveChipView(
        stepLayoutItems:  controller.stepone_layout_items,
        choosedIndex: controller.choosedIndex,
        StepPages: stepOnePages,
        isloading: isloading,
        selectedChipIndex: controller.selectedChipIndex,
        controller:controller
      );
    }
    super.initState();
  }


  @override
  Widget build(BuildContext context){
    return CustomScaffold(
      controller: controller,
      isShowAppBar: true,
      resizeToAvoidBottomInset: true,
      appBarBGColor:  appColors.white,
      customAppBarFunction: (){_customBackEvent();},
      backIconWidget: getBackIconWidget(
          themeType: overALLThemeType,
          onTap: (){_customBackEvent();}),
      body: SafeArea(
        child: Obx(
          () {
            return controller.isStepOneLoading.value ?
              showCenterLoading(
                controller: controller,
                loader: LottieLoaders.world_loader,
                isShowBGOnLoader: true,
              )
              : showBodyContent(context);
          }
        )
      ),
    );
  }

  Widget showBodyContent(context) {
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
    return  toPropertyCreationColumn(
      stepLayoutItems:  controller.stepone_layout_items,
      chipLayout: _chipLayout,
      containerColor: appColors.white,
      cornerRadius: BorderRadiusDirectional.only(topStart: Radius.circular(overALLAppLayoutModel?.borderRadius ?? 8), topEnd: Radius.circular(overALLAppLayoutModel?.borderRadius ?? 8)),
      topRadiusColor: appColors.white,
      borderWidth: 1,
      bottomProgressWidget: true,
      controller: controller,
      stepBasedPages: stepOnePages,
      choosedIndex: controller.choosedIndex,
      bottomBorderRadius: bottomBorderRadius,
      tickerprovider: this,
      selectedChipIndex: controller.selectedChipIndex,
        onTaponSaveExit: (){
          if (controller.choosedIndex.value != controller.stepone_layout_items.length - 1) {
            updateStep1();
          }
        }
      );
  }

  void _addItemsToStepLayouts() {
    controller.stepone_layout_items.clear();

    Map<String, dynamic> readyToHostMap = {};
    readyToHostMap['title'] = "label_what_kind_of_car".tr;
    readyToHostMap['widget'] =  ReadyToHostView(controller: controller,key: const ValueKey('readyToHost'),);
    readyToHostMap['chipicon'] = Assets.viewcarsViewcarCartype;
    readyToHostMap['chipPadding'] = 6.0;
    readyToHostMap['chiptitle'] = label_car_type.tr;
    readyToHostMap['isRetainFocus'] = true;
    readyToHostMap['mainvalidation'] = controller.setValidation;
    readyToHostMap['onnext'] = controller.setValidation;
    controller.stepone_layout_items.add(readyToHostMap);

    PropertyPlaceEntryView propertyPlaceEntryView =  PropertyPlaceEntryView(controller: controller,key: const ValueKey('placeEntry'),);
    Map<String,dynamic> placeLocatedMap = {};
    placeLocatedMap['title'] = '${label_where_your_place_located.tr}${label_question_symbol.tr}';
    placeLocatedMap['widget'] = propertyPlaceEntryView;
    placeLocatedMap['chipicon'] = Assets.drawableFilterLocation;
    placeLocatedMap['chiptitle'] = label_location.tr;
    placeLocatedMap['onnext'] =  propertyPlaceEntryView.setValidation;
    placeLocatedMap['mainvalidation'] =  propertyPlaceEntryView.setValidation;
    controller.stepone_layout_items.add(placeLocatedMap);

    PropertyPlaceMapSelectionView propertyPlaceMapSelectionView = PropertyPlaceMapSelectionView(controller: controller,key: const ValueKey('placeMap'),);
    Map<String,dynamic> propertyPlacePinOnMap = {};
    propertyPlacePinOnMap['title'] = '${label_is_thepin_in_the_right_spot.tr}${label_question_symbol.tr}';
    propertyPlacePinOnMap['widget'] = propertyPlaceMapSelectionView;
    propertyPlacePinOnMap['chipicon'] = Assets.drawableStepOneChipMap;
    propertyPlacePinOnMap['chiptitle'] = btn_search_in_map.tr;
    propertyPlacePinOnMap['onnext'] =   propertyPlaceMapSelectionView.setValidation;
    controller.stepone_layout_items.add(propertyPlacePinOnMap);

    Map<String,dynamic> sharedspacesMap = {};
    sharedspacesMap['title'] = what_features_does_car_offer.tr;
    sharedspacesMap['widget'] = _showCarFeaturesGridWidget();
    sharedspacesMap['chipicon'] = Assets.drawableStepOneChipSharedSpaces;
    sharedspacesMap['chiptitle'] = label_car_features.tr;
    sharedspacesMap['onnext'] =  (){
       return updateStep1();
    };
    controller.stepone_layout_items.add(sharedspacesMap);

  }


  bool createlist(){
    controller.isLoading.value = true;
    debugPrint("createlist called");
    controller.checkNetwork(controller.createListingStepOne);
    return false;
  }
  void _customBackEvent() async{
    if(!isloading) {
      isloading = true;
      FocusManager.instance.primaryFocus?.unfocus();

      if (stepOnePages.isNotEmpty) {
        stepOnePages.removeLast();
        debugPrint("stepOnePages: ${stepOnePages.length}");
        if (stepOnePages.isEmpty) {
          if (!Get.isSnackbarOpen) {
            Get.back(
                result: controller.itemInfo == null && controller.listId != null
                    ? {'type': 'refresh', 'id': controller.listId}
                    : '');
          } else {
            Get.back();
            Future.delayed(Duration(milliseconds: 300), () {
              Get.back(result: controller.itemInfo == null &&
                  controller.listId != null ? {
                'type': 'refresh',
                'id': controller.listId
              } : '');
            });
          }
        } else {
          controller.choosedIndex.value = stepOnePages[stepOnePages.length - 1];
          controller.isLoading.refresh();
        }
      } else {
        Get.back(
            result: controller.itemInfo == null && controller.listId != null ? {
              'type': 'refresh',
              'id': controller.listId
            } : '');
      }
      Future.delayed( Duration(milliseconds: StepBtnclickInterval)).then((value) {
        isloading = false;
      });
    }
  }

  Widget _showCarFeaturesGridWidget() {
    return  [
      AppDimen.startMargin.toHeight(),
      CustomText(text: label_car_features.tr),
      Obx(() =>
        controller.isLoading.value ? const SizedBox.shrink():
        GridItemSelectionWidget(
          controller: controller,
          listItems: controller.carFeatures,
          selectedIdList: controller.selectedCarFeatures,
          key: ValueKey('step1_8'),
        ).toStretch()
      )
    ].toColumn();
  }

  Future<bool> updateStep1() async {
    if(!isloading) {
      isloading = true;
      Future.delayed( Duration(milliseconds: StepBtnclickInterval)).then((value) {
        isloading = false;
      });
    } else {
      return true;
    }

    if(_isShowChiplayout) {
      List<Future<bool>> futuresFunctions = [];
      bool isFinish = true;
      Completer<bool> validationCompleter = Completer<bool>();
      for (int index = 0; index <
          controller.stepone_layout_items.length; index++) {
        var element = controller.stepone_layout_items[index];
        if (element['mainvalidation'] != null) {
          isFinish = await element['mainvalidation']();
          futuresFunctions.add(Future.value(isFinish));
          if (!isFinish) {
            debugPrint("_validationCompleter: ${controller.choosedIndex.value}---$index");
            stepOnePages.clear();
            for(int i=0; i<=index; i++){
              stepOnePages.add(i);
            }

            if (controller.selectedChipIndex.value != index) {
              controller.selectedChipIndex.value = index;
            } else {
              controller.selectedChipIndex.refresh();
            }

            controller.choosedIndex.value = index;

            break;
          }
        }
      }
      Future.wait(futuresFunctions).then((value) {
        if (isFinish) controller.checkNetwork(createlist);
        validationCompleter.complete(isFinish);
      });

      return validationCompleter.future;
    }else{
      createlist();
      return true;
    }


  }

  @override
  void dispose() {

    controller.choosedIndex.value = 0;
    controller.selectedChipIndex.value =0;
    super.dispose();
  }
}