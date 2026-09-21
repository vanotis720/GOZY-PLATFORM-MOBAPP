import 'package:flutter/material.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common_extension_functions.dart';

class CustomBorderContainer extends StatelessWidget {
  /*
purpose - apply the border to the container
  @body - Body content of the container (Required)
  @width - width of the container (Optional)
  @height - height of the container (Optional)
  @padding - inner body adjustment within container (Optional)
  @margin - outer body adjustment for container (Optional)
  @alignment - inner body alignment within container (Optional)
  @onTap - function when click that container (Optional)
  @color - fill color of the container (Optional)
  @borderColor - underline color of the container (Optional)
  @shape - shape of the container - default is in rectangle (Optional)
  @borderRadius - the corners of this box are rounded by this container (Optional)
  @borderWidth - width of the border of this container (Optional)
  @boxShadow - shadow effect for this container (Optional)
  @borderRadiusGeometry - particular without apply overall corner radius custom applied for this container (Optional)

  */
  const CustomBorderContainer({
    super.key,
    this.body,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.alignment,
    this.onTap,
    this.color,
    this.borderColor,
    this.shape,
    this.borderRadius,
    this.borderRadiusGeometry,
    this.borderWidth,
    this.boxShadow,
  });

  final Widget? body;
  final double? width;
  final double? height;
  final double? borderRadius;
  final BorderRadiusGeometry? borderRadiusGeometry;
  final double? borderWidth;
  final EdgeInsetsGeometry? padding;
  final List<BoxShadow>? boxShadow;
  final EdgeInsetsGeometry? margin;
  final GestureTapCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final BoxShape? shape;
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
        decoration: _getDecoration(),
        child: body,
      ),
    );
  }

  BoxDecoration _getDecoration() {
    return BoxDecoration(
        color: color,
        shape: shape ?? BoxShape.rectangle,
        border:
            Border.all(color: borderColor ?? color ?? appColors.customBorderColor, width: borderWidth ?? 0.5),
        borderRadius: shape == BoxShape.circle
            ? null
            : borderRadiusGeometry ?? BorderRadius.all(Radius.circular(borderRadius ?? 4.0)),
        boxShadow: boxShadow);
  }
}