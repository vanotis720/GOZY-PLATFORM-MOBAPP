import 'package:flutter/material.dart';
import 'package:gozy/widgets/indicator_effect.dart';


abstract class BasicIndicatorPainter extends IndicatorPainter {

  final int count;

  final BasicIndicatorEffect _effect;

  final Paint dotPaint;

  final Radius dotRadius;

  BasicIndicatorPainter(
      super.offset,
      this.count,
      this._effect,
      )   : dotRadius = Radius.circular(_effect.radius),
        dotPaint = Paint()
          ..color = _effect.dotColor
          ..style = _effect.paintStyle
          ..strokeWidth = _effect.strokeWidth;

  double get distance => _effect.dotWidth + _effect.spacing;

}

abstract class IndicatorPainter extends CustomPainter {
  final double offset;

  const IndicatorPainter(this.offset);

  @override
  bool shouldRepaint(IndicatorPainter oldDelegate) {
    return oldDelegate.offset != offset;
  }
}