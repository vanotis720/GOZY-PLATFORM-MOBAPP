import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common/custom_container/custom_border_container.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_text.dart';

class PaymentTypeSelectionView extends GetView{
String paymentTypeIcon;
String paymentTypeTitle;
bool ispaymentTypeSelected;

PaymentTypeSelectionView({super.key,
    required this.paymentTypeIcon,
    required this.paymentTypeTitle,
    required this.ispaymentTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return [
      paymentTypeIcon.toSVG(size: 30),
      15.toWidth(),
      CustomText(
        text: paymentTypeTitle,
        size: AppDimen.textSize_16,
        fontWeight: AppFont.regular,
      ).toStretch(),
      5.toWidth(),
      CustomBorderContainer(
        width: 25,
        height: 25,
        borderWidth: 1,
        borderRadius: 60,
        alignment: AlignmentDirectional.center,
        color: ispaymentTypeSelected ? appColors.secondaryColor : null,
        body: ispaymentTypeSelected
            ? Assets.drawableViewdetailReportTick.toSVG(size: 10,)
            : null,
      ).toPad(end: 10)
    ].toRow();
  }






}