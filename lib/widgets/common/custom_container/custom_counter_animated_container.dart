import 'package:flutter/material.dart';
import 'package:gozy/widgets/common_extension_functions.dart';

class CustomCounterAnimatedContainer extends StatelessWidget {
  /*
  purpose - without border circle container based animation
  @body - Body content of the container (Required)
  @duration - The duration over which to animate the parameters of this container. (Required)
  @width - width of the container (Optional)
  @height - height of the container (Optional)
  @padding - inner body adjustment within container (Optional)
  @onTap - function when click that container (Optional)
  @color - fill color of the container (Optional)
  @borderColor -  color for  border the circular container (Optional)
  @isRetainFocus - during ontap function, maintain the focus on last focusing widget (Optional)
  @borderWidth - width of the border of this container (Optional)
  @boxShadow - shadow effect for this container (Optional)

  */
  const CustomCounterAnimatedContainer({
    super.key,
    required this.body,
    required this.duration,
    this.width,
    this.height,
    this.padding,
    this.onTap,
    this.color,
    this.isRetainFocus,
    this.boxShadow,
  });

  final Widget? body;
  final double? width;
  final double? height;
  final bool? isRetainFocus;
  final EdgeInsetsGeometry? padding;
  final List<BoxShadow>? boxShadow;
  final GestureTapCallback? onTap;
  final Color? color;
  final Duration? duration;

  @override
  Widget build(BuildContext context) {
    return toOnTap(
        onTap: onTap,
        isRetainFocus: isRetainFocus,
        child: AnimatedContainer(
          duration: duration!,
          padding: padding,
          width: width,
          height: height,
          decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: boxShadow),
          child: body,
        ));
  }
}