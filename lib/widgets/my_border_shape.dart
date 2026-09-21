import 'package:flutter/material.dart';

@immutable
class CustomBorderShape extends ShapeBorder {
  CustomBorderShape();

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  double holeSize = 55;

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    print(rect.height);
    return Path.combine(
      PathOperation.difference,
      Path()
        ..addRRect(
            RRect.fromRectAndRadius(rect, Radius.circular(0)))
        ..close(),
      Path()
        ..addOval(Rect.fromCenter(
            center: rect.center.translate(0, -rect.height / 2),
            height: holeSize,
            width: holeSize))
        ..close(),
    );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;

  @override
  Path getInnerPath(Rect rect, {TextDirection?textDirection}) {
    throw UnimplementedError();
  }
}