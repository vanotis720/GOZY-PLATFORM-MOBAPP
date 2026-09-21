import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:gozy/constant.dart';
import 'package:gozy/widgets/common_extension_functions.dart';

class DynamicSizedRoundedSquareBoxPainter extends CustomPainter {

  final double borderRadius;
  final double borderWidth;
  final Color borderColor;
  final Color boxColor;
  final Color arrowColor;
  final double arrowHeight;
  final double arrowWidth;
  final double boxWidth;
  final double boxHeight;
  final TextPainter textPainter;
  final double shadowBlurRadius;
  final Offset shadowOffset;
  final Color shadowColor;
  final double arrowPosition;
  final EdgeInsets padding;

  DynamicSizedRoundedSquareBoxPainter({

    required this.borderRadius,
    required this.borderWidth,
    required this.borderColor,
    required this.boxColor,
    required this.arrowColor,
    required this.arrowHeight,
    required this.arrowWidth,
    required this.boxWidth,
    required this.boxHeight,
    required this.textPainter,
    required this.shadowBlurRadius,
    required this.shadowOffset,
    required this.shadowColor,
    required this.arrowPosition,
    this.padding = const EdgeInsets.all(5.0),
  });

  @override
  void paint(Canvas canvas, Size size) {


    // Draw the shadow
    final shadowPaint = Paint()
      ..color = shadowColor.withValues(alpha:0.2)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowBlurRadius);

    final shadowRect = Rect.fromLTWH(shadowOffset.dx, shadowOffset.dy, boxWidth, boxHeight);
    final shadowRRect = RRect.fromRectAndRadius(shadowRect, Radius.circular(borderRadius));
    canvas.drawRRect(shadowRRect, shadowPaint);

    // Draw the bottom arrow shadow
    final arrowBaseX = arrowPosition;
    final shadowArrowPath = Path()
      ..moveTo(arrowBaseX - arrowWidth / 2 + shadowOffset.dx, boxHeight + shadowOffset.dy)
      ..lineTo(arrowBaseX + arrowWidth / 2 + shadowOffset.dx, boxHeight + shadowOffset.dy)
      ..lineTo(arrowBaseX + shadowOffset.dx, boxHeight + arrowHeight + shadowOffset.dy)
      ..close();

    canvas.drawPath(shadowArrowPath, shadowPaint);

    // Draw the rounded square box
    final paint = Paint()
      ..color = boxColor
      ..style = PaintingStyle.fill;

    final rect = Rect.fromLTWH(0, 0, boxWidth, boxHeight);
    final rRect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    canvas.drawRRect(rRect, paint);

    // Draw the border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawRRect(rRect, borderPaint);

    // Draw the bottom arrow indicator
    final arrowPath = Path()
      ..moveTo(arrowBaseX - arrowWidth / 2, boxHeight-1.5)
      ..lineTo(arrowBaseX + arrowWidth / 2, boxHeight-1.5)
      ..lineTo(arrowBaseX, boxHeight + arrowHeight-1.5)

      ..close();

    final arrowPaint = Paint()
      ..color = arrowColor
      ..style = PaintingStyle.fill;

    // Draw the bottom arrow indicator
    final arrowPathFill = Path()
      ..moveTo(arrowBaseX - arrowWidth / 2, boxHeight)
      ..lineTo(arrowBaseX + arrowWidth / 2, boxHeight)
      ..lineTo(arrowBaseX, boxHeight + arrowHeight)

      ..close();

    canvas.drawPath(arrowPath, arrowPaint);
    canvas.drawPath(arrowPathFill, arrowPaint);

    // Draw the border for the bottom arrow indicator
    final arrowBorderPath = Path()
      ..moveTo(arrowBaseX - arrowWidth / 2, boxHeight)
      ..lineTo(arrowBaseX, boxHeight + arrowHeight)
      ..lineTo(arrowBaseX + arrowWidth / 2, boxHeight);

    canvas.drawPath(arrowBorderPath, borderPaint);


    // Draw the text
    final offset = Offset(
      padding.left,
      padding.top,
    );
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class CustomHostSpecialPricePainter extends StatelessWidget {
  final String text;
  final TextStyle textStyle;
  final double borderRadius;
  final double borderWidth;
  final Color borderColor;
  final Color boxColor;
  final Color arrowColor;
  final double arrowHeight;
  final double arrowWidth;
  final double shadowBlurRadius;
  final Offset shadowOffset;
  final Color shadowColor;
  final Rect itemRect;
  final EdgeInsets padding;
  double arrowPosition;

  CustomHostSpecialPricePainter({super.key,
    required this.text,
    required this.textStyle,
    this.borderRadius = 0,
    required this.borderWidth,
    required this.borderColor,
    required this.boxColor,
    required this.arrowColor,
    required this.arrowHeight,
    required this.arrowWidth,
    required this.shadowBlurRadius,
    required this.shadowOffset,
    required this.shadowColor,
    required this.itemRect,
    this.padding = const EdgeInsets.symmetric(horizontal: 12.5, vertical: 5.0),
    this.arrowPosition = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textSpan = TextSpan(text: text, style: textStyle);
        bool isRTL = intl.Bidi.isRtlLanguage(Get.locale?.languageCode);
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        );
        textPainter.layout();
        final textWidth = textPainter.width;
        final textHeight = textPainter.height;

        final double horizontalMargin = 10.0;
        final double boxWidth = textWidth + padding.left + padding.right;
        final double boxHeight = textHeight + padding.top + padding.bottom;

        double topPad = itemRect.top - boxHeight - arrowHeight;

        // Logical approach: distance from logical-start edge to the icon
        double iconEdgeOffset = isRTL ? (deviceWidth - itemRect.right) : itemRect.left;
        double idealStartOffset = iconEdgeOffset + (itemRect.width / 2) - (boxWidth / 2);

        // Clamp between margins
        double clampedStartOffset = idealStartOffset.clamp(horizontalMargin, deviceWidth - boxWidth - horizontalMargin);

        // Triangle shift: original - clamped
        double shift = idealStartOffset - clampedStartOffset;
        if (isRTL) {
          shift = -shift;
        }
        double relativeArrowPos = (boxWidth / 2 + shift) / boxWidth;
        arrowPosition = relativeArrowPos.clamp(0.15, 0.85);

        return Align(
          alignment: AlignmentDirectional.topStart,
          child: CustomPaint(
            size: Size(boxWidth, boxHeight + arrowHeight),
            painter: DynamicSizedRoundedSquareBoxPainter(
              borderRadius: borderRadius,
              borderWidth: borderWidth,
              borderColor: borderColor,
              boxColor: boxColor,
              boxWidth: boxWidth,
              boxHeight: boxHeight,
              textPainter: textPainter,
              arrowColor: arrowColor,
              arrowHeight: arrowHeight,
              arrowWidth: arrowWidth,
              shadowBlurRadius: shadowBlurRadius,
              shadowOffset: shadowOffset,
              shadowColor: shadowColor,
              arrowPosition: boxWidth*arrowPosition,
              padding: padding,
            ),
          ),
        ).toPad(top: topPad, start: clampedStartOffset);
      },
    );
  }
}