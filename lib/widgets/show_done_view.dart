import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/resources/app_colors.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common_extension_functions.dart';

import 'custom_text.dart';

class InputDoneView extends GetView {
 @override
  late BaseController controller ;
 Widget parentWidget ;
 double bottompadding;
 double toppadding;
  InputDoneView(BaseController controller, {super.key, required this.parentWidget, this.bottompadding = -1, this.toppadding = -1} ){
    this.controller = controller;
  }
  @override
  Widget build(BuildContext context) {
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    debugPrint("keyboardHeight: $keyboardHeight");
   return Stack(children: [
     parentWidget,
     Positioned(
         bottom: bottompadding == -1 ?   keyboardHeight: bottompadding,
         right: 0.0,
         left: 0.0,
         child: keyboardHeight >= 100.0
             ? _showDoneView(context)
             :  const SizedBox.shrink()),
   ]);

  }

 Widget _showDoneView(BuildContext context){
   return InkWell(
     onTap: () {
       FocusScopeNode currentFocus = FocusScope.of(context);
       if (!currentFocus.hasPrimaryFocus) {
         currentFocus.unfocus();
       }else {
         FocusManager.instance.primaryFocus!.unfocus();
       }
     },
     child: Container(
        width: double.infinity,
        color: appColors.keyboardColor,
       padding: pad(w: 24,h: 12),
       alignment: AlignmentDirectional.topEnd,
        child: CustomText(
            text:label_done.tr,
            color: AppColors.staticblack,
            fontWeight: FontWeight.bold
        ).toPad(top: 4.0),
      ),
   );
  }
}