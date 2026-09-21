import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_list_item.dart';

import '../../../generated/assets.dart';
import '../../../screens/views/base_controller.dart';
import '../common/custom_container/custom_border_container.dart';
import '../../resources/app_dimen.dart';

class GridItemSelectionWidget extends GetView {
  @override
  BaseController controller;
  String? title;
  List<dynamic> listItems;
  RxList<int> selectedIdList;
  final int _increasingCount = 20;
  final RxInt _currentCount = 0.obs;
  ScrollController scrollController = ScrollController();

  GridItemSelectionWidget({
    super.key,
    required this.controller,
    required this.listItems,
    required this.selectedIdList,
  });

  bool _isListenerAdded = false;

  @override
  Widget build(BuildContext context) {
    _currentCount.value = listItems.length;
    if (!_isListenerAdded) {
      _isListenerAdded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 1),
            curve: Curves.ease,
          );
        }
        scrollController.addListener(() {
          if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent) {
            if ((_currentCount.value + _increasingCount) < listItems.length) {
              _currentCount.value = _currentCount.value + _increasingCount;
            } else if ((_currentCount.value) != listItems.length)
              _currentCount.value = _currentCount.value +
                  (listItems.length - _currentCount.value);
          }
        });
      });
    }

    return ListView.builder(
        itemCount: _currentCount.value,
        itemBuilder: (context, index) {
          dynamic item = listItems[index];
          return Obx(() {
            bool isSelected = selectedIdList.contains(item.id);
            return toOnTap(
              onTap: () {
                if (isSelected) {
                  selectedIdList.remove(item.id);
                } else {
                  selectedIdList.add(item.id);
                }

                selectedIdList.refresh();
                debugPrint('selectedIdList: $selectedIdList');
              },
              child: CustomCheckBoxListItem(
                topPadding: 2,
                checkBox: CustomBorderContainer(
                  width: 22,
                  height: 22,
                  borderRadius: 4,
                  borderWidth: 1,
                  borderColor: isSelected
                      ? appColors.secondaryColor
                      : appColors.customBorderColor,
                  color: isSelected
                      ? appColors.secondaryColor
                      : Colors.transparent,
                  padding: pad(a: 4),
                  body: isSelected
                      ? Assets.drawableViewdetailReportTick
                          .toSVG(colour: Colors.white)
                      : null,
                ).toPad(end: 10),
                itemPropertyText: controller.getLocalizedItemName(item),
                fontSize: AppDimen.textSize_14,
              ),
            );
          }).toPad(top: 18);
        });
  }
}

class AnimatedVectorShape extends StatefulWidget {
  final bool isAnimating;
  final Widget child;
  final borderColor;

  const AnimatedVectorShape(
      {super.key,
      required this.isAnimating,
      required this.child,
      required this.borderColor});

  @override
  _AnimatedVectorShapeState createState() => _AnimatedVectorShapeState();
}

class _AnimatedVectorShapeState extends State<AnimatedVectorShape>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _trimAnimation;

  @override
  void initState() {
    super.initState();
    debugPrint('widget.isAnimating: ${widget.isAnimating}');
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 750),
    );
    _trimAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    ));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isAnimating) {
        _controller.forward(from: 1);
      }
    });
  }

  @override
  void didUpdateWidget(covariant AnimatedVectorShape oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _trimAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: VectorPainter(_trimAnimation.value, widget.borderColor),
          child: widget.child,
        );
      },
    );
  }
}

class VectorPainter extends CustomPainter {
  final double trimEnd;
  final Color borderColor;

  VectorPainter(this.trimEnd, this.borderColor);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    double radius = 8.0;
    double firstpoint = 16.0;
    double secondwidthpoint = size.width - radius;
    double secondheightpoint = size.height - radius;
    double width = size.width;
    double height = size.height;

    Path path1 = Path();
    path1.moveTo(0, radius);
    path1.arcToPoint(Offset(radius, 0), radius: Radius.circular(radius));
    path1.lineTo(firstpoint, 0);
    path1.lineTo(secondwidthpoint, 0);
    path1.arcToPoint(Offset(width, radius), radius: Radius.circular(radius));
    path1.lineTo(width, firstpoint);
    path1.lineTo(width, secondheightpoint);
    path1.lineTo(width, height - radius);

    Path path2 = Path();
    path2.moveTo(0, radius);
    path2.lineTo(0, firstpoint);
    path2.lineTo(0, secondheightpoint);
    path2.arcToPoint(Offset(radius, height),
        radius: Radius.circular(radius), clockwise: false);
    path2.lineTo(firstpoint, height);
    path2.lineTo(secondwidthpoint, height);
    path2.arcToPoint(Offset(width, height - radius),
        radius: Radius.circular(radius), clockwise: false);

    var pathMetric1 = path1.computeMetrics().first;
    var pathMetric2 = path2.computeMetrics().first;

    Path trimmedPath1 =
        pathMetric1.extractPath(0, pathMetric1.length * trimEnd);
    Path trimmedPath2 =
        pathMetric2.extractPath(0, pathMetric2.length * trimEnd);

    canvas.drawPath(trimmedPath1, paint);
    canvas.drawPath(trimmedPath2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}