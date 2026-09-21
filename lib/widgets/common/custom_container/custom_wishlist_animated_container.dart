import 'package:flutter/material.dart';

class CustomWishlistAnimatedContainer extends StatelessWidget {
  /*

  @body - Body content of the container (Optional)
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

  const CustomWishlistAnimatedContainer({
    super.key,
    this.body,
    required this.duration,
    this.width,
    this.height,
    this.color,
  });

  final Widget? body;
  final double? width;
  final double? height;
  final Color? color;
  final Duration? duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration!,
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        shape: BoxShape.circle,
      ),
      child: body,
    );
  }
}