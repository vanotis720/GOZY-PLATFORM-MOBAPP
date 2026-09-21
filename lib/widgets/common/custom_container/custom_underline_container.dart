import 'package:flutter/material.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common_extension_functions.dart';

class CustomUnderlineContainer extends StatelessWidget {
  /*
  @body - Body content of the container (Optional)
  @width - width of the container (Optional)
  @height - height of the container (Optional)
  @borderColor - underline color of the container (Optional)
  @onTap - function when click that container (Optional)
  @padding - inner body adjustment within container (Optional)
  */

  const CustomUnderlineContainer({
    super.key,
    this.body,
    this.width,
    this.height,
    this.padding,
    this.borderColor,
    this.onTap,
  });

  final Widget? body;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final GestureTapCallback? onTap;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return toOnTap(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: borderColor ?? appColors.customBorderColor, width: 0.5),
          ),
        ),
        child: body,
      ),
    );
  }
}