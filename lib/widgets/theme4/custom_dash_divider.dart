import 'package:flutter/material.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common_extension_functions.dart';

class CustomDashDivider extends StatelessWidget {
  const CustomDashDivider({super.key, this.dashHeight = 2,this.dashWidth = 2,  this.width = 50,this.height = 50, this.color, this.isCircle = true, this.isPaddingNotNeeded = false});
  final double dashHeight;
  final double dashWidth;
  final double width;
  final double height;
  final Color? color;
  final bool? isCircle;
  final bool? isPaddingNotNeeded;

  @override
  Widget build(BuildContext context) {
    final dashCount = (width / (2 * dashWidth)).floor();
    return List.generate(dashCount, (_) {
      return DecoratedBox(
        decoration: BoxDecoration(color: color ?? appColors.black,shape: (isCircle ?? true) ? BoxShape.circle : BoxShape.rectangle),
      ).toResizeWidget(
        width: dashWidth,
        height: dashHeight,
      );
    }).toRow(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    ).toResizeWidget(
      width: width,
      height:height,
    ).toPad(top: !isPaddingNotNeeded! ? 4 : 0);
  }
}

Widget fullWidthDashDivider({double? width, Color? dashColor}){
  return  CustomDashDivider(width: width ?? deviceWidth,color: dashColor ?? appColors.filterDividerColor,height: 2,dashWidth:4,isCircle:false,dashHeight: 1, isPaddingNotNeeded: true,);
}