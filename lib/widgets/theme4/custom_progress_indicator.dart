import 'package:flutter/material.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common/custom_container/custom_container.dart';

class CustomProgressIndicator extends StatelessWidget {
  final double value;
  final double previousValue;
  final double height;
  final Color backgroundColor;
  final Color progressColor;
  final double borderRadius;
  final int duration;
  const CustomProgressIndicator({super.key, 
    required this.value,
    this.height = 20,
    this.previousValue = 0,
    this.duration = 200,
    this.backgroundColor = Colors.grey,
    this.progressColor = Colors.blue,
    this.borderRadius = 10,
  });
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: duration),
          curve: Curves.linear,
          tween: Tween<double>(
            begin: (previousValue / 100),
            end: (value / 100),
          ),
          builder: (context, value, child) {
            return Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: 1,
                  child: CustomContainer(
                    height: borderRadius < 10 ? (height < 2 ? 2 : height) : borderRadius,
                    decoration: BoxDecoration(
                      color: appColors.white,
                      border: BorderDirectional(
                        top: BorderSide(color: backgroundColor, width: height),
                      ),
                      borderRadius: borderRadius > 0
                          ? BorderRadiusDirectional.only(
                              topStart: Radius.circular(borderRadius),
                              topEnd: Radius.circular(borderRadius),
                            )
                          : null,
                    ),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: value,
                  child: CustomContainer(
                    height: borderRadius < 10 ? (height < 2 ? 2 : height) : borderRadius,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: BorderDirectional(
                        top: BorderSide(width: height, color: progressColor),
                      ),
                      borderRadius: borderRadius > 0
                        ? BorderRadiusDirectional.only(
                            topStart: Radius.circular(borderRadius),
                            topEnd: Radius.circular(value >= 0.99 ? borderRadius : 0),
                          )
                        : null,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}