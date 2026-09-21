import 'package:flutter/material.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common_extension_functions.dart';

class CustomCounterContainer extends StatelessWidget {
  /*
  purpose - border circle container without animation
  @body - Body content of the container (Required)
  @duration - The duration over which to animate the parameters of this container. (Required)
  @width - width of the container (Optional)
  @height - height of the container (Optional)
  @padding - inner body adjustment within container (Optional)
  @margin - outer body adjustment for container (Optional)
  @onTap - function when click that container (Optional)
  @color - fill color of the container (Optional)
  @borderColor -  color for  border the circular container (Optional)
  @borderWidth - width of the border of this container (Optional)
  @boxShadow - shadow effect for this container (Optional)
  @alignment - inner body alignment within container (Optional)
  */

  const CustomCounterContainer({
    super.key,
    this.body,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.borderColor,
    this.borderWidth,
    this.boxShadow,
    this.alignment,
  });

  final Widget? body;
  final double? width;
  final double? height;
  final double? borderWidth;
  final EdgeInsetsGeometry? padding;
  final List<BoxShadow>? boxShadow;
  final EdgeInsetsGeometry? margin;
  final GestureTapCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    return toOnTap(
        onTap: onTap,
        child: Container(
          padding: padding,
          margin: margin,
          width: width,
          height: height,
          alignment: alignment,
          decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor ?? appColors.appBGColor, width: borderWidth ?? 2),
              boxShadow: boxShadow),
          child: body,
        ));
  }
}