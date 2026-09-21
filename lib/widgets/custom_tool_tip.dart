import 'package:flutter/cupertino.dart';
import 'package:gozy/resources/app_colors.dart';
import 'package:gozy/widgets/common/custom_container/custom_wishlist_container.dart';
import 'package:gozy/widgets/common/custom_painter/custom_tooltip_painter.dart';
import 'package:gozy/widgets/rect_getter.dart';

import '../constant.dart';
import '../generated/assets.dart';
import '../screens/views/base_controller.dart';
import 'app_toast.dart';
import 'common_extension_functions.dart';

Widget getToolTipWidget(
    {required CustomTooltipPainter customShapePointer,
    required BaseController controller,
    required GlobalKey<RectGetterState> globalKey,
    Widget? overlayWidget,
      double? startMargin,
      String pagetype = '',
    Color? overlayColorForWidget}) {
  return CustomWishlistContainer(
    width: 17,
    height: 17,
    margin: pad(start: startMargin ?? 5),
    onTap: () {
      Rect? overlayRect = RectGetter.getRectFromKey(globalKey);
      bool isRTL = controller.isRTL();
      double overallWidth = customShapePointer.textPainter.width + customShapePointer.textPainteroffset.dx;
      
      // iconEdgeOffset = distance from logical-start edge to the icon.
      double iconEdgeOffset = isRTL
          ? (deviceWidth - overlayRect!.right)
          : overlayRect!.left;
      double iconWidth = overlayRect.width;

      // idealStartOffset centers the bubble over the icon.
      double idealStartOffset = iconEdgeOffset + (iconWidth / 2) - (overallWidth / 2);

      // Clamp the bubble within screen margins (10px from each edge).
      double clampedStartOffset = idealStartOffset.clamp(10, deviceWidth - overallWidth - 10);

      // Center the triangle pointer exactly above the icon.
      // The offset is the difference between where the bubble "wants" to be and where it is clamped.
      double triangleOffset = idealStartOffset - clampedStartOffset;
      if (isRTL) {
        triangleOffset = -triangleOffset;
      }
      customShapePointer.setTriangleOffset(triangleOffset);

      debugPrint("tooltip_debug: overallWidth: $overallWidth, iconEdgeOffset: $iconEdgeOffset, ideal: $idealStartOffset, clamped: $clampedStartOffset, triangleOffset: $triangleOffset");

      AppToast().show(
          overlayWidget: Align(
            alignment: AlignmentDirectional.topStart,
            child: CustomPaint(
              painter: customShapePointer,
              size: Size(overallWidth, customShapePointer.textPainter.height + customShapePointer.padding.vertical + 5),
            ),
          ).toPad(
              top:  overlayRect.top - customShapePointer.textPainter.height - customShapePointer.padding.vertical - 5,
              start: clampedStartOffset,
              end: 10));
    },
    color: overlayColorForWidget,
    body: RectGetter(
        key: globalKey,
        child: overlayWidget ??
            Assets.drawableConfirmPaySplPriceTooltip.toSVG(
                colour: AppColors.staticwhite,
                size: 13,
                fit: BoxFit.scaleDown)),
  );
}