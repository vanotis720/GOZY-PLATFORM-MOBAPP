import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/screens/views/owner/step_one/step_one_controller.dart';
import 'package:gozy/screens/views/owner/step_three/step_three_controller.dart';
import 'package:gozy/widgets/common/custom_container/custom_counter_container.dart';
import 'package:gozy/widgets/common_extension_functions.dart';

import '../../../constant.dart';
import '../../../screens/views/base_controller.dart';
import '../../resources/app_dimen.dart';
import '../common/custom_button/custom_button.dart';
import '../rect_getter.dart';

class ProgressiveChipView extends GetView {
  List<Map<String, dynamic>> stepLayoutItems;
  RxInt choosedIndex;
  RxInt selectedChipIndex;
  int tempIndex = 0;
  List<int> StepPages;
  @override
  BaseController controller;
  bool isloading;
  ScrollController scrollController = ScrollController();
  final _keys = {};

  ProgressiveChipView({
    super.key,
    required this.stepLayoutItems,
    required this.choosedIndex,
    required this.controller,
    required this.StepPages,
    required this.isloading,
    required this.selectedChipIndex,
  });

  @override
  Widget build(BuildContext context) {
    Color? boxFillColor;
    Color? boxUnselectedFillColor;
    Color? iconBorderColor;
    Color? iconUnselectedBorderColor;
    Color? iconBgColor;
    Color? iconUnselectedBgColor;
    Color? borderColor;
    Color? borderUnselectedColor;
    switch (overALLThemeType) {
      case 1:
        boxFillColor = appColors.stepChipSelectionColor;
        boxUnselectedFillColor = Colors.transparent;
        iconBorderColor = Colors.transparent;
        iconUnselectedBorderColor = appColors.myTripsDividerColor;
        iconBgColor = appColors.white;
        iconUnselectedBgColor = appColors.myTripsBGColor;
        borderColor = appColors.black;
        borderUnselectedColor = appColors.black;
        break;
      case 2:
        boxFillColor = appColors.stepChipSelectionColor;
        boxUnselectedFillColor = Colors.transparent;
        iconBorderColor = Colors.transparent;
        iconUnselectedBorderColor = appColors.secondaryColor;
        iconBgColor = appColors.white;
        iconUnselectedBgColor = appColors.myTripsBGColor;
        borderColor = appColors.secondaryColor;
        borderUnselectedColor = appColors.secondaryColor;
        break;
      case 3:
        boxFillColor = appColors.stepChipSelectionColor;
        boxUnselectedFillColor = appColors.myTripsBGColor;
        iconBorderColor = appColors.secondaryColor;
        iconUnselectedBorderColor = appColors.myTripsDividerColor;
        iconBgColor = appColors.white;
        iconUnselectedBgColor = appColors.white;
        borderColor = appColors.myTripsDividerColor;
        borderUnselectedColor = appColors.myTripsDividerColor;
        break;
      default:
        boxFillColor = appColors.stepChipSelectionColor;
        boxUnselectedFillColor = Colors.transparent;
        iconBorderColor = appColors.secondaryColor;
        iconUnselectedBorderColor = appColors.secondaryColor;
        iconBgColor = appColors.stepChipSelectionColor;
        iconUnselectedBgColor = appColors.stepChipSelectionColor;
        borderColor = appColors.secondaryColor;
        borderUnselectedColor = appColors.myTripsDividerColor;
        break;
    }
    List<Widget> listWidgets = List.generate(stepLayoutItems.length, (index) {
      return stepLayoutItems[index]['chipicon'] != null
          ? Obx(() {
              _keys[index] = RectGetter.createGlobalKey();
              if (tempIndex != choosedIndex.value) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToOffset();
                });
              }
              tempIndex = choosedIndex.value;

        return  RectGetter(
          key: _keys[index],
          child: CancelButton(
            borderRadius: 100,
              buttonText: stepLayoutItems[index]['chiptitle'],
              trailingWidget: Card(
                elevation: 0,
                  margin: pad(start: 3,),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(80),
                  ),
                  child: CustomCounterContainer(
                      color: choosedIndex.value == index ? iconBgColor : iconUnselectedBgColor,
                      borderWidth: 1,
                      height: 37,
                      width: 37,
                      borderColor: choosedIndex.value == index ? iconBorderColor : iconUnselectedBorderColor,
                      body: stepLayoutItems[index]['chipicon'].toString().toSVG(
                          colour: appColors.black,
                          fit: BoxFit.scaleDown,
                          height: 35,
                          width: 35).toPad(all: stepLayoutItems[index]['chipPadding']),

                  )).toPad(end:5),

              onTap: ()async{
                if(!isloading && choosedIndex.value != index) {
                  isloading = true;
                  bool isnetconnect = await controller.isNetworkConnected();
                  if(isnetconnect) {
                    if(controller is StepThreeController) {
                      if( (controller as StepThreeController).listingSettingData ==null) {
                        (controller as StepThreeController).getCurrenciesList();
                      } else {
                        selectChip(index: index);
                      }
                    }else if(controller is StepOneController) {
                      if( (controller as StepOneController).listingSettingData ==null) {
                        (controller as StepOneController).getCountriesList();
                      } else {
                        selectChip(index: index);
                      }
                    }else{
                      selectChip(index: index);
                    }
                  }
                  Future.delayed( Duration(milliseconds: StepBtnclickInterval)).then((value) {
                    isloading = false;
                  });

                }
              },
              color: choosedIndex.value == index ? borderColor : borderUnselectedColor,
              textColor: appColors.black,
              fillcolor: choosedIndex.value == index ? boxFillColor : boxUnselectedFillColor,
              horizontalPadding: 2,
              textSize: AppDimen.textSize_14,
              isExpand: false ,
              dotWidget: 10.toWidth()
          ).toPad(end: 10,),
        );
      }) : 0.toHeight();
    });
    return listWidgets
        .toScroll(
            scrollDirection: Axis.horizontal,
            padding: pad(w: AppDimen.startMargin),
            scrollController: scrollController)
        .toResizeWidget(height: 40)
        .toPad(bottom: 10);
  }

  void getChildOffset(
      {required GlobalKey childKey, required BuildContext context}) {
    if (childKey.currentContext != null) {
      final RenderBox childRenderBox =
          childKey.currentContext!.findRenderObject() as RenderBox;
      final RenderBox scrollRenderBox = context.findRenderObject() as RenderBox;
      final Offset childOffset =
          childRenderBox.localToGlobal(Offset.zero, ancestor: scrollRenderBox);
      print('Child offset: ${childOffset.dx}');
    }
  }

  void _setScrolloffset({required double offset}) {
    scrollController.animateTo(
      offset,
      duration: Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToOffset() {
    if (_keys[choosedIndex.value] != null) {
      Rect? rect = RectGetter.getRectFromKey(_keys[choosedIndex.value]);

      double left = rect?.left ?? 0.0;
      double right = rect?.right ?? 0.0;

      if (rect == null) {
        _setScrolloffset(
            offset: scrollController.offset == 0.0
                ? scrollController.position.maxScrollExtent
                : 0);
        Future.delayed(const Duration(milliseconds: 200)).then((value) {
          _scrollToOffset();
        });
      } else if (left <= 0)
        _setScrolloffset(
            offset: scrollController.offset +
                (left - AppDimen.startMargin) +
                (controller.isRTL() ? deviceWidth : 0));
      else if (right >= deviceWidth)
        _setScrolloffset(
            offset: scrollController.offset +
                ((right - deviceWidth) +
                    AppDimen.startMargin -
                    (controller.isRTL() ? deviceWidth : 0)));
    }
  }

  void selectChip({required int index}) {
    StepPages.clear();
    for (int i = 0; i < index; i++) {
      StepPages.add(i);
    }
    if (selectedChipIndex.value != index) {
      selectedChipIndex.value = index;
    } else {
      selectedChipIndex.refresh();
    }
  }
}