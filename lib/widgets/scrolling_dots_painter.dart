import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gozy/widgets/scrolling_dots_effect.dart';
import 'indicator_painter.dart';

class ScrollingDotsPainter extends BasicIndicatorPainter {
  final ScrollingDotsEffect effect;

  ScrollingDotsPainter({
    required this.effect,
    required int count,
    required double offset,
  }) : super(offset, count, effect);

  @override
  void paint(Canvas canvas, Size size) {
    final current = super.offset.floor();
    final switchPoint = (effect.maxVisibleDots / 2).floor();
    final firstVisibleDot =
    (current < switchPoint || count - 1 < effect.maxVisibleDots)
        ? 0
        : min(current - switchPoint, count - effect.maxVisibleDots);
    final lastVisibleDot =
    min(firstVisibleDot + effect.maxVisibleDots, count - 1);
    final inPreScrollRange = current < switchPoint;
    final inAfterScrollRange = current >= (count - 1) - switchPoint;
    final willStartScrolling = (current + 1) == switchPoint + 1;
    final willStopScrolling = current + 1 == (count - 1) - switchPoint;

    final dotOffset = offset - offset.toInt();
    final dotPaint = Paint()
      ..strokeWidth = effect.strokeWidth
      ..style = effect.paintStyle;

    final drawingAnchor = (inPreScrollRange || inAfterScrollRange)
        ? -(firstVisibleDot * distance)
        : -((offset - switchPoint) * distance);

    const smallDotScale = 0.66;
    final activeScale = effect.activeDotScale - 1.0;
    for (var index = firstVisibleDot; index <= lastVisibleDot; index++) {
      var color = effect.dotColor;

      var scale = 1.0;



      // 1. Determine Color using a Switch Expression
      color = switch (index) {
        _ when index == current =>
        Color.lerp(effect.activeDotColor, effect.dotColor, dotOffset)!,
        _ when index - 1 == current || (index == firstVisibleDot && offset > count - 1) =>
        Color.lerp(effect.dotColor, effect.activeDotColor, dotOffset)!,
        _ => effect.dotColor,
      };

      // 2. Determine Scale
      if (count <= effect.maxVisibleDots) {
        // Unified distance from the fractional scroll position.
        // Updates on every frame → instant, smooth graduated sizes.
        // Range [0,1): active→next lerp. Range [1,∞): graduated steps.
        final dist = (index - offset).abs();
        if (dist < 1.0) {
          // Smoothly interpolate from activeDotScale (dist=0) to 0.85 (dist=1)
          scale = effect.activeDotScale - (effect.activeDotScale - 0.85) * dist;
        } else {
          // Each step further reduces by 0.15, capped at 0.60
          final steps = dist.ceil();
          scale = max(0.60, 0.85 - (steps - 1) * 0.15);
        }
      } else {
        scale = switch (true) {
          // Case: Current Active Dot
          _ when index == current =>
          (offset > count - 1 && count > effect.maxVisibleDots)
              ? effect.activeDotScale - (smallDotScale * dotOffset)
              : effect.activeDotScale - (activeScale * dotOffset),

          // Case: First Visible Dot during Over-scroll
          _ when index == firstVisibleDot && offset > count - 1 =>
          (count <= effect.maxVisibleDots)
              ? 1.0 + (activeScale * dotOffset)
              : smallDotScale + (((1.0 - smallDotScale) + activeScale) * dotOffset),

          // Case: Next Dot becoming Active
          _ when index - 1 == current =>
          1.0 + (activeScale * dotOffset),

          // Case: First Visible Dot during normal scroll
          _ when index == firstVisibleDot => switch (true) {
            _ when willStartScrolling => (1.0 * (1.0 - dotOffset)),
            _ when inAfterScrollRange  => smallDotScale,
            _ when !inPreScrollRange  => smallDotScale * (1.0 - dotOffset),
            _                         => scale,
          },

          // Case: Second Dot transitions
          _ when index == firstVisibleDot + 1 && !(inPreScrollRange || inAfterScrollRange) =>
          1.0 - (dotOffset * (1.0 - smallDotScale)),

          // Case: Penultimate Dot
          _ when index == lastVisibleDot - 1.0 =>
          inPreScrollRange
              ? smallDotScale
              : inAfterScrollRange ? scale : smallDotScale + ((1.0 - smallDotScale) * dotOffset),

          // Case: Last Visible Dot
          _ when index == lastVisibleDot =>
          inPreScrollRange
              ? 0.0
              : willStopScrolling ? dotOffset : inAfterScrollRange ? scale : smallDotScale * dotOffset,

          // Default Case
          _ => scale,
        };
      }

      var paintColor = color;


      final scaledWidth = (effect.dotWidth * scale);
      final scaledHeight = (effect.dotHeight * scale);
      final yPos = size.height / 2;
      final xPos = effect.dotWidth / 2 + drawingAnchor + (index * distance);

      final rRect = RRect.fromLTRBR(
        xPos - scaledWidth / 2 + effect.spacing / 2,
        yPos - scaledHeight / 2,
        xPos + scaledWidth / 2 + effect.spacing / 2,
        yPos + scaledHeight / 2,
        dotRadius * scale,
      );

      canvas.drawRRect(rRect, dotPaint..color = paintColor);
      final bool isActuallyActive = index == offset.round();
      if(!isActuallyActive) {
        final borderPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = effect.inActiveStrokeColor;

        // Draw the border on top of the dot we just painted
        canvas.drawRRect(rRect, borderPaint);
      }

    }
  }


}