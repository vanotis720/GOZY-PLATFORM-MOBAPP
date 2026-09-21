import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/screens/binding/property_steps_binding.dart';
import 'package:gozy/screens/views/home_item_detail/home_item_detail.dart';
import 'package:gozy/screens/views/owner/let_start/let_start_page.dart';
import 'package:gozy/screens/views/owner/step_one/step_one_page.dart';
import 'package:gozy/screens/views/owner/step_two/step_two_page.dart';

import '../step_final/step_final_page.dart';
import '../step_three/step_three_page.dart';

enum OwnerPropertyListScreen {
  letStart,
  propertyDetail,
  stepOne,
  stepTwo,
  stepThree,
  stepFinal,
}

class OwnerPropertyListNavigator {
  void navigateScreen(OwnerPropertyListScreen screen, {dynamic param}) {
    switch (screen) {
      case OwnerPropertyListScreen.letStart:
        Get.to(() =>  LetStartScreen(),arguments: param,binding: PropertyStepsBinding())?.then((value){
          if(value !=null && value['refresh']){

            param['refresh'](value);
            if(value['iteminfo'] !=null) {
              Future.delayed(const Duration(milliseconds: 350)).then((demand) {
                value['updateManagelist'] = param['updateManagelist'];
                value['removedeletedlisting'] = param['removedeletedlisting'];
                debugPrint("LetStartScreenparam: $value");
                navigateScreen(OwnerPropertyListScreen.stepFinal, param: value);
              });
            }
          }
        });
      case OwnerPropertyListScreen.propertyDetail:
        Get.to(() => HomeItemDetailView(), arguments: param,);
        case OwnerPropertyListScreen.stepFinal:
        Get.to(() => StepFinalScreen(), arguments: param,binding: PropertyStepsBinding())?.then((result){
          debugPrint("StepFinalScreenparam: $result ---${param['refreshlistings']}");

          if(result !=null && result != 'refresh' && result) {
            if(param['refreshlistings'] !=null) {
              param['refreshlistings']();
            }
          }
         else if(result!=null && result['removedeletedlisting'] !=null && result['removedeletedlisting']){
            param['removedeletedlisting']();
          }

        });
         case OwnerPropertyListScreen.stepOne:
        Get.to(() => StepOnePage(), arguments: param,binding: PropertyStepsBinding())?.then((value){
          if(value!=null && value.isNotEmpty && value['type'] == 'refresh'){
            param['refresh'](value['id']);
          }else if(value!=null && value.isNotEmpty && value['removedeletedlisting'] !=null && value['removedeletedlisting']){
            if(param['removedeletedlisting'] !=null) {
              param['removedeletedlisting']();
            }
          }
        });
      case OwnerPropertyListScreen.stepTwo:
        Get.to(() => StepTwoPage(), arguments: param,binding: PropertyStepsBinding())?.then((value){
          if(value!=null && value.isNotEmpty && value['removedeletedlisting']){
            param['removedeletedlisting']();
          }
        });
      case OwnerPropertyListScreen.stepThree:
        Get.to(() => StepThreePage(), arguments: param,binding: PropertyStepsBinding())?.then((value){
         debugPrint('StepThreePage value: $value --- $param');
         if(value!=null && value.isNotEmpty && value == 'refresh' &&  param['refresh'] !=null){
           param['refresh']();
         }
         else if(value!=null && value.isNotEmpty && value['removedeletedlisting']){
            param['removedeletedlisting']();
          }else   if(value!=null && value.isNotEmpty && value['refresh']){
            param['refresh']();
          }
        });
    }
  }
}