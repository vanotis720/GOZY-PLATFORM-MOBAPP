import 'package:flutter/material.dart';
import 'package:gozy/constant.dart';


import 'package:gozy/screens/views/base_controller.dart';

class CustomRangeShape extends RangeSliderThumbShape {
  static const double _thumbSize = 1.0;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete){
    return Size.fromRadius(_thumbSize);
  }


  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
         bool isDiscrete = false,
        bool isEnabled = false,
        bool isOnTop = false,
        TextDirection textDirection = TextDirection.ltr,
        required SliderThemeData sliderTheme,
        Thumb thumb =Thumb.start,
        bool isPressed = false,
      }){
    final Canvas canvas = context.canvas;
    _getRangeSliderTheme(canvas, center);
  }

  void _getRangeSliderTheme(Canvas canvas, Offset center){
    switch(overALLThemeType){
      case 1:
        final Paint outerPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6;
        canvas.drawCircle(center, 9, outerPaint);
        final Paint middlePaint = Paint()
          ..color = Colors.grey
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5;
        canvas.drawCircle(center, 12, middlePaint);
        final Paint fillPaint = Paint()
          ..color = Colors.black
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, 8, fillPaint);
        break;
      case 2:
        final Paint outerPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;
        canvas.drawCircle(center, 10, outerPaint);
        final Paint fillPaint = Paint()
          ..color = appColors.colorCommonLinkColor
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, 10, fillPaint);
        break;
      case 3:
        final Paint outerPaint = Paint()
          ..color = appColors.black.withValues(alpha: 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7;
        canvas.drawCircle(center, 9, outerPaint);
        final Paint fillPaint = Paint()
          ..color = appColors.black
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, 6, fillPaint);
        break;
      case 4:
        final Paint middlePaint = Paint()
          ..color = appColors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;
        canvas.drawCircle(center, 7, middlePaint);

        final Paint outerPaint = Paint()
          ..color = appColors.colorCommonLinkColor.withValues(alpha: 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5;
        canvas.drawCircle(center, 11, outerPaint);

        final Paint fillPaint = Paint()
          ..color = appColors.colorCommonLinkColor
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, 7, fillPaint);
        break;
      default:
        final Paint outerPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6;
        canvas.drawCircle(center, 9, outerPaint);
        final Paint middlePaint = Paint()
          ..color = Colors.grey
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5;
        canvas.drawCircle(center, 12, middlePaint);
        final Paint fillPaint = Paint()
          ..color = Colors.black
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, 8, fillPaint);
        break;
    }
  }
}
Path _rightShape(double size, Offset thumbCenter, {bool invert = false}) {
  final Path thumbPath = Path();
  final double halfSize = size / 1.5;
  final double sign = invert ? -1.0 : 1.0;
  thumbPath.moveTo(thumbCenter.dx + halfSize * sign, thumbCenter.dy);
  thumbPath.lineTo(thumbCenter.dx - halfSize * sign, thumbCenter.dy - size);
  thumbPath.lineTo(thumbCenter.dx - halfSize * sign, thumbCenter.dy + size);
  thumbPath.close();
  return thumbPath;
}