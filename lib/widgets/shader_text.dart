import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/resources/app_colors.dart';
import 'package:gozy/resources/app_dimen.dart';

class ShaderText extends GetView{

  final String label;
  final double fontSize;

  ShaderText({required this.label, this.fontSize = AppDimen.textSize_16});
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          colors: AppColors.regenerateTextColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      child: Text(
        label,
        style: TextStyle(
          fontSize: AppDimen.textSize_16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }

}