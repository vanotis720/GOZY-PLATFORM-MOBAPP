import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gozy/widgets/indicator_painter.dart';
import 'package:gozy/widgets/scrolling_dots_painter.dart';
import 'indicator_effect.dart';

class ScrollingDotsEffect extends BasicIndicatorEffect {

  final double activeStrokeWidth;

  final double activeDotScale;

  final int maxVisibleDots;

  final bool fixedCenter;
  final Color? inactiveDotBorderColor;

  const ScrollingDotsEffect({
    this.activeStrokeWidth = 1.5,
    this.activeDotScale = 1.3,
    this.maxVisibleDots = 5,
    this.fixedCenter = false,
    double offset = 16.0,
    super.dotWidth = 16.0,
    super.dotHeight = 16.0,
    super.spacing = 8.0,
    super.radius = 16,
    super.dotColor = Colors.white,
    super.inActiveStrokeColor = Colors.grey,
    super.activeDotColor = Colors.indigo,
    this.inactiveDotBorderColor = Colors.black,
    super.strokeWidth = 10.0,
    super.paintStyle = PaintingStyle.fill,
  })  : assert(activeDotScale >= 0.0);

  @override
  Size calculateSize(int count) {
    var width = (dotWidth + spacing) * (min(count, maxVisibleDots));
    if (fixedCenter && count <= maxVisibleDots) {
      width = ((count * 2) - 1) * (dotWidth + spacing);
    }
    return Size(width, dotHeight * activeDotScale);
  }

  @override
  int hitTestDots(double dx, int count, double current) {
    final switchPoint = (maxVisibleDots / 2).floor();
    if (fixedCenter) {
      return super.hitTestDots(dx, count, current) -
          switchPoint +
          current.floor();
    } else {
      final firstVisibleDot =
      (current < switchPoint || count - 1 < maxVisibleDots)
          ? 0
          : min(current - switchPoint, count - maxVisibleDots).floor();
      final lastVisibleDot =
      min(firstVisibleDot + maxVisibleDots, count - 1).floor();
      var offset = 0.0;
      for (var index = firstVisibleDot; index <= lastVisibleDot; index++) {
        if (dx <= (offset += dotWidth + spacing)) {
          return index;
        }
      }
    }
    return -1;
  }

  @override
  BasicIndicatorPainter buildPainter(int count, double offset) {
    return ScrollingDotsPainter(
      count: count,
      offset: offset,
      effect: this,
    );
  }
}