import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:gozy/screens/views/base_controller.dart';

class Shimmer extends StatefulWidget {
  static ShimmerState? of(BuildContext context) {
    return context.findAncestorStateOfType<ShimmerState>();
  }

  const Shimmer({
    super.key,
    this.child,
    this.controller,
  });

  final Widget? child;
  final BaseController? controller;

  @override
  ShimmerState createState() => ShimmerState();
}

class ShimmerState extends State<Shimmer> with TickerProviderStateMixin {
  late AnimationController shimmerController;
  int _activeLoads = 0;

  @override
  void initState() {
    super.initState();
    debugPrint("toShimmer called");
    createAnimation();
  }

  void createAnimation() {
    shimmerController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 900),
      lowerBound: -0.5,
      upperBound: 1.5,
    )..addStatusListener((AnimationStatus status) {
        if (status != AnimationStatus.completed) {
          return;
        }
        shimmerController.forward(from: -0.5);
      });
  }

  void registerLoading() {
    _activeLoads += 1;
    if (!shimmerController.isAnimating) {
      shimmerController.forward(from: -0.5);
    }
  }

  void unregisterLoading() {
    if (_activeLoads > 0) {
      _activeLoads -= 1;
    }
    if (_activeLoads == 0 && shimmerController.isAnimating) {
      shimmerController.stop();
    }
  }

  @override
  void dispose() {
    shimmerController.dispose();
    super.dispose();
  }

  LinearGradient get gradient => LinearGradient(
        colors: appColors.shimmerColors,
        stops: [
          max((1.0 - 0.0 - 0.5) / 2.0, 0.0),
          max((1.0 - 0.0 - 0.001) / 2.0, 0.0),
          min((1.0 + 0.0 + 0.001) / 2.0, 1.0),
          min((1.0 + 0.0 + 0.5) / 2.0, 1.0),
        ],
        begin: Alignment(-1.0, 0.0),
        end: Alignment(1.0, 0.0),
        tileMode: TileMode.clamp,
        transform:
            _SlidingGradientTransform(slidePercent: shimmerController.value),
      );

  bool get isSized =>
      (context.findRenderObject() as RenderBox?)?.hasSize ?? false;

  Size get size {
    if (isSized) {
      return (context.findRenderObject() as RenderBox).size;
    } else {
      return Size(100, 100);
    }
  }

  Offset getDescendantOffset({
    required RenderBox descendant,
    Offset offset = Offset.zero,
  }) {
    final shimmerBox = context.findRenderObject() as RenderBox;
    return descendant.localToGlobal(offset, ancestor: shimmerBox);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ?? const SizedBox();
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({
    required this.slidePercent,
  });

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

Widget ShimmerLoading(
    {Key? key,
    required bool isLoading,
    required String widgetType,
    required Widget child,
    required bool isDarkMode,
    BlendMode? darkModeblend}) {
  String keyvalue = 'shimmer_$widgetType';

  return Builder(builder: (context) {
    var shimmerstate = Shimmer.of(context);
    var shimmerController = shimmerstate?.shimmerController;

    return ShimmerLoadingWidget(
        isLoading: isLoading,
        isDarkMode: isDarkMode,
        darkModeblend: darkModeblend,
        keyvalue: keyvalue,
        shimmerController: shimmerController,
        child: child);
  });
}

class ShimmerLoadingWidget extends StatefulWidget {
  const ShimmerLoadingWidget(
      {super.key,
      required this.isLoading,
      required this.child,
      required this.isDarkMode,
      required this.keyvalue,
      this.shimmerController,
      this.darkModeblend});

  final bool isLoading;
  final bool isDarkMode;
  final Widget child;
  final String keyvalue;
  final BlendMode? darkModeblend;
  final AnimationController? shimmerController;

  @override
  State<ShimmerLoadingWidget> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoadingWidget> {
  AnimationController? shimmerController;
  Offset? offsetWithinShimmer;
  ShimmerState? shimmerState;
  bool _registered = false;
  final RxInt _shimmerTick = 0.obs;

  @override
  void initState() {
    //  WidgetsBinding.instance.addObserver(this);
    shimmerController = widget.shimmerController;
    shimmerController ??= Shimmer.of(context)?.shimmerController;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    shimmerState = Shimmer.of(context);
    if (shimmerController != null) {
      shimmerController!.removeListener(_onShimmerChange);
    }

    if (shimmerController != null) {
      shimmerController!.addListener(_onShimmerChange);
    }

    _syncLoadingRegistration();
  }

  @override
  void didUpdateWidget(covariant ShimmerLoadingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoading != widget.isLoading) {
      _syncLoadingRegistration();
    }
  }

  @override
  void dispose() {
    if (_registered) {
      shimmerState?.unregisterLoading();
      _registered = false;
    }
    shimmerController?.removeListener(_onShimmerChange);
    super.dispose();
  }

  void _syncLoadingRegistration() {
    if (widget.isLoading && !_registered) {
      shimmerState?.registerLoading();
      _registered = true;
    } else if (!widget.isLoading && _registered) {
      shimmerState?.unregisterLoading();
      _registered = false;
    }
  }

  void _onShimmerChange() {
    if (widget.isLoading && mounted) {
      _shimmerTick.value++;
      _shimmerTick.refresh();
    } else if (!widget.isLoading && mounted) {
      shimmerController?.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      _shimmerTick.value;
    if (!widget.isLoading) {
      return widget.child;
    }

    var shimmer = Shimmer.of(context);

    final shimmerSize = shimmer?.size;
    final gradient = shimmer?.gradient;

    if (context.findRenderObject() != null && shimmer != null) {
      offsetWithinShimmer = shimmer.getDescendantOffset(
        descendant: context.findRenderObject() as RenderBox,
      );
    }

    if (shimmer != null && !shimmer.isSized) {
      return const SizedBox();
    }
    Widget shadermask = ShaderMask(
      blendMode:
          //  widget.isDarkMode ?  (widget.darkModeblend ?? BlendMode.srcIn) :
          BlendMode.srcATop,
      shaderCallback: (shader) {
        return gradient!.createShader(
          Rect.fromLTWH(
            offsetWithinShimmer != null ? -offsetWithinShimmer!.dx : 0,
            offsetWithinShimmer != null ? -offsetWithinShimmer!.dy : 0,
            shimmerSize!.width,
            shimmerSize.height,
          ),
        );
      },
      child: widget.child,
    );
      return shimmer != null ? shadermask : const SizedBox.shrink();
    });
  }
}