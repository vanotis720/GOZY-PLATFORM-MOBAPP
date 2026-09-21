import 'package:flutter/material.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common_extension_functions.dart';

class CustomBottomItemShadowContainer extends StatelessWidget {
  /*
purpose - container which is not affect the bottom notch area
  @body - Body content of the container (Required)
  @width - width of the container (Optional)
  @height - height of the container (Optional)
  @padding - inner body adjustment within container (Optional)
  @alignment - inner body alignment within container (Optional)
  @onTap - function when click that container (Optional)
  @color - fill color of the container (Optional)
  @decoration - ustom decoration of this container (Optional)
  @borderRadiusGeometry - particular without apply overall corner radius custom applied for this container (Optional)

  */
  const CustomBottomItemShadowContainer(
      {super.key,
      required this.body,
      this.width,
      this.height,
      this.padding,
      this.alignment,
      this.onTap,
      this.color,
      this.decoration,
      this.borderRadiusGeometry});

  final Widget? body;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  final GestureTapCallback? onTap;
  final Color? color;
  final AlignmentGeometry? alignment;
  final Decoration? decoration;
  final BorderRadiusGeometry? borderRadiusGeometry;

  @override
  Widget build(BuildContext context) {
    return toOnTap(
      onTap: onTap,
      child: Container(
        padding: padding,
        width: width,
        height: height,
        alignment: alignment,
        decoration: decoration ??
            BoxDecoration(
                borderRadius: borderRadiusGeometry, color: appColors.white, boxShadow: getBottomBoxShadows()),
        child: body,
      ),
    );
  }
}