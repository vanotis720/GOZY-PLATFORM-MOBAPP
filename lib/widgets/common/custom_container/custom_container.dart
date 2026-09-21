import 'package:flutter/material.dart';
import 'package:gozy/widgets/common_extension_functions.dart';

class CustomContainer extends StatelessWidget {
  CustomContainer({
    super.key,
    this.body,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.width,
    this.constraints,
    this.height,
    this.alignment,
    this.decoration
  });

  final Widget? body;
   double? width;
  double? height;
  final BoxConstraints? constraints;
  EdgeInsetsGeometry? padding;
  EdgeInsetsGeometry? margin;
  final GestureTapCallback? onTap;
  Color? color;
  AlignmentGeometry? alignment;
  Decoration? decoration;

  @override
  Widget build(BuildContext context) {

    return toOnTap(
      onTap: onTap,
      child: Container(
              padding: padding,
              margin: margin,
              width: width,
              constraints: constraints,
              height: height,
              color: color,
              alignment: alignment,
              decoration: decoration,
              child: body,
            ),
    );
  }

}