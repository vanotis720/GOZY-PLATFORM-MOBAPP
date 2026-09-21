import 'package:flutter/material.dart';
import 'package:gozy/widgets/common_extension_functions.dart';

class CustomWishlistContainer extends StatelessWidget {

  /*

  @body - Body content of the container (Optional)
  @width - width of the container (Optional)
  @height - height of the container (Optional)
  @padding - inner body adjustment within container (Optional)
  @margin - outer body adjustment for container (Optional)
  @onTap - function when click that container (Optional)
  @color - fill color of the container (Optional)

  */
  const CustomWishlistContainer({
    super.key,
    this.body,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.alignment,
  });

  final Widget? body;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final GestureTapCallback? onTap;
  final Color? color;
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
          color: color ?? Colors.white,
          shape: BoxShape.circle,
        ),
        child: body,
      ),
    );
  }
}