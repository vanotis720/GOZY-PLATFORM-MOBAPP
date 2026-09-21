import 'package:flutter/material.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_colors.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common_extension_functions.dart';

class AiPillCard extends StatelessWidget {
  const AiPillCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 28,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(1.0), // 1px border width
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppColors.generateWithAIBorderColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: appColors.lightYellowColor,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: AppColors.regenerateTextColors,
                ).createShader(bounds),
                child: Assets.drawableAi.toSVG(
                  size: 20,
                ).toPad(top: 4),
              ),
              2.toWidth(),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: AppColors.regenerateTextColors,
                ).createShader(bounds),
                child: Text(
                  "AI",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: AppDimen.textSize_16,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}