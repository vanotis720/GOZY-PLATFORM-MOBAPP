import 'package:flutter/material.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/resources/app_colors.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common/custom_container/custom_container.dart';

class GradientBorderContainer extends StatelessWidget {
  final Widget child;
  final double borderWidth;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BorderRadiusGeometry? borderRadiusForLinear;
  final BorderRadiusGeometry? borderRadiusForInSideView;
  final Function()? onTap;

  const GradientBorderContainer({
    Key? key,
    required this.child,
    required this.onTap,
    this.borderWidth = 1,
    this.color,
    this.margin,
    this.borderRadiusForLinear,
    this.borderRadiusForInSideView,
    this.borderRadius = 50.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      margin: margin,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.generateWithAIBorderColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: borderRadiusForLinear ?? BorderRadiusDirectional.only(topStart: Radius.circular(borderRadius), topEnd: Radius.circular(borderRadius), bottomEnd: Radius.circular(borderRadius), bottomStart: Radius.circular(aiContainerBottomRadius)),
      ),
      body: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.all(1),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            color: color ?? appColors.lightYellowColor,
            borderRadius: borderRadiusForInSideView ?? BorderRadiusDirectional.only(topStart: Radius.circular(borderRadius - borderWidth), topEnd: Radius.circular(borderRadius - borderWidth), bottomEnd: Radius.circular(borderRadius - borderWidth), bottomStart: Radius.circular(aiContainerBottomRadius)),
          ),
          child: child,
        ),
      ),
    );
  }
}