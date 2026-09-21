import 'package:flutter/material.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common_extension_functions.dart';

class CustomBorderAnimatedContainer extends StatelessWidget {
  /*
  purpose - border container animation which is used for radiobutton
  @duration -  The duration over which to animate the parameters of this container. (Required)
  @body - Body content of the container (Required)
  @width - width of the container (Optional)
  @height - height of the container (Optional)
  @padding - inner body adjustment within container (Optional)
  @alignment - inner body alignment within container (Optional)
  @onTap - function when click that container (Optional)
  @color - fill color of the container (Optional)
  @borderColor - underline color of the container (Optional)
  @borderRadius - the corners of this box are rounded by this container (Optional)
  @borderWidth - width of the border of this container (Optional)
  @boxShadow - shadow effect for this container (Optional)
  @isRetainFocus - during ontap function, maintain the focus on last focusing widget (Optional)

  */

  const CustomBorderAnimatedContainer({
    super.key,
    required this.duration,
    required this.body,
    this.width,
    this.height,
    this.padding,
    this.alignment,
    this.onTap,
    this.color,
    this.borderColor,
    this.borderRadius,
    this.borderWidth,
    this.boxShadow,
    this.isRetainFocus,
  });

  final Widget? body;
  final double? width;
  final double? height;
  final double? borderRadius;
  final double? borderWidth;
  final EdgeInsetsGeometry? padding;
  final List<BoxShadow>? boxShadow;
  final GestureTapCallback? onTap;
  final Color? color;
  final Duration? duration;
  final Color? borderColor;
  final bool? isRetainFocus;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    return toOnTap(
      onTap: onTap,
      isRetainFocus: isRetainFocus,
      child: AnimatedContainer(
        duration: duration!,
        padding: padding,
        width: width,
        alignment: alignment,
        height: height,
        decoration: _getDecoration(),
        child: body,
      ),
    );
  }

  BoxDecoration _getDecoration() {
    return BoxDecoration(
        color: color,
        shape: BoxShape.rectangle,
        border:
            Border.all(color: borderColor ?? color ?? appColors.customBorderColor, width: borderWidth ?? 0.5),
        borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 4.0)),
        boxShadow: boxShadow);
  }
}