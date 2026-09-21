import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_layout.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_stateful_widget.dart';
import 'package:gozy/widgets/custom_textfield.dart';

import '../resources/app_lang.dart';

class AnimSearchBar extends CustomStatefulWidget {
  final double? width;
  final double height;
  final TextEditingController textController;
  String? hintText;
  final int themeType;
  final int animationDurationInMilli;
  RxInt? searchBarStatus;

  AnimSearchBar({
    super.key,
    this.width,
    required this.textController,
    required this.themeType,
    this.searchBarStatus,
    this.hintText,
    this.height = 45,
    this.animationDurationInMilli = 375,
  });

  @override
  _AnimSearchBarState createState() => _AnimSearchBarState();
}

class _AnimSearchBarState extends CustomStatefulWidgetState<AnimSearchBar> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  RxInt reactiveToggle = 0.obs;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    if (widget.hintText?.isEmpty??true) {
      widget.hintText = label_search.tr;
    }
    reactiveToggle.value = widget.searchBarStatus?.value ?? 0;
    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.animationDurationInMilli),
    );
    if (reactiveToggle.value == 1) {
      _animController.value = 1.0;
    }

    // Sync external status to internal status
    if (widget.searchBarStatus != null) {
      ever(widget.searchBarStatus!, (int val) {
        if (val != reactiveToggle.value) {
          _updateToggle(val);
        }
      });
    }
  }

  void _updateToggle(int val) {
    if (_isAnimating) return;
    if (val == 1) {
      reactiveToggle.value = 1;
      _animController.forward();
    } else {
      reactiveToggle.value = 0;
      _animController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<BoxShadow>? boxshadow;
    Color? iconBGColor, borderColor, iconColor;
    double? borderWidth, searchHeight = 35;

    switch (widget.themeType) {
      case 1:
      case 2:
        iconBGColor = Colors.transparent;
        borderColor = appColors.myTripsDividerColor;
        borderWidth = 1.5;
        iconColor = getBackIconColor();
        break;

      case 3:
        borderColor = appColors.white;
        iconBGColor = appColors.white;
        iconColor = appColors.black;

        break;

      case 4:
        borderColor = appColors.white;
        iconBGColor = appColors.white;
        boxshadow = kElevationToShadow[2];
        iconColor = getBackIconColor();
        break;
    }

    return Obx(
      () => GestureDetector(
        onTap: () {
          if (reactiveToggle.value == 1 && !_isAnimating && !_animController.isAnimating) {
            _performAnim();
          }
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: widget.animationDurationInMilli),
          height: (reactiveToggle.value == 0) ? searchHeight : widget.height,
          width: (reactiveToggle.value == 0) ? searchHeight : (widget.width ?? deviceWidth),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: iconBGColor,
            border: Border.all(color: borderColor ?? Colors.transparent, width: borderWidth ?? 0.01),
            borderRadius: BorderRadius.all(Radius.circular(widget.height)),
            boxShadow: boxshadow,
          ),
          alignment: AlignmentDirectional.centerStart,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                alignment: AlignmentDirectional.centerStart,
                children: [
                  // Close Icon
                  AnimatedPositionedDirectional(
                    duration: Duration(milliseconds: widget.animationDurationInMilli),
                    end: 0,
                    top: 0,
                    bottom: 0,
                    curve: Curves.easeOut,
                    child: AnimatedOpacity(
                      opacity: (reactiveToggle.value == 0) ? 0.0 : 1.0,
                      duration: Duration(milliseconds: 200),
                      child: Container(
                        height: widget.height - 10,
                        padding: pad(end: 15, start: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        alignment: Alignment.center,
                        child: AnimatedBuilder(
                          builder: (context, widget) {
                            return Transform.rotate(
                              angle: _animController.value * 2.0 * pi,
                              child: widget,
                            );
                          },
                          animation: _animController,
                          child: Assets.drawableSignupClose.toSVG(
                              colour: appColors.black,
                              size: 16,
                              onTap: () {
                                if (_isAnimating || _animController.isAnimating) return;
                                if (widget.textController.text.isEmpty) {
                                  _performAnim();
                                } else {
                                  widget.textController.clear();
                                  bottomSheetController.change(rxVariable: bottomSheetController.isUpdateItemList, value: true);
                                  FocusManager.instance.primaryFocus?.unfocus();
                                }
                              }),
                        ),
                      ),
                    ),
                  ),
                  // Text Field
                  AnimatedPositionedDirectional(
                    duration: Duration(milliseconds: widget.animationDurationInMilli),
                    start: (reactiveToggle.value == 0) ? 20.0 : 40.0,
                    end: (reactiveToggle.value == 0) ? constraints.maxWidth : 40.0,
                    top: 0,
                    bottom: 0,
                    curve: Curves.easeOut,
                    child: AnimatedOpacity(
                      opacity: (reactiveToggle.value == 0) ? 0.0 : 1.0,
                      duration: Duration(milliseconds: 200),
                      child: Center(
                        child: CustomTextField(
                          hintText: widget.hintText??label_search.tr,
                          hintTextColor: appColors.textColor,
                          controller: widget.textController,
                          enableSuggestions: true,
                          maxLines: 1,
                          isReadOnly: reactiveToggle.value == 0,
                          contentPadding: pad(bottom: 6),
                          textInputAction: TextInputAction.search,
                          hintFontWeight: FontWeight.normal,
                          onChanged: (value) {
                            debugPrint("animsearchbarvalue: $value");
                          },
                          onSubmitted: (value) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                        ),
                      ),
                    ),
                  ),
                  // Search / back icon
                  PositionedDirectional(
                    start: reactiveToggle.value == 1 ? 10 : 0,
                    top: 0,
                    bottom: 0,
                    width: reactiveToggle.value == 0 ? constraints.maxWidth : 30,
                    child: Center(
                      child: Assets.drawableSearchbarSearch
                          .toSVG(
                          colour: iconColor,
                          size: 14,
                          onTap: () {
                            if (_isAnimating || _animController.isAnimating) return;
                            _performAnim();
                          }),
                    ),
                  ),
                ],
              );
            }
          ),
        ),
      ),
    );
  }

  void _performAnim() {
    _isAnimating = true;
    if (reactiveToggle.value == 0) {
      reactiveToggle.value = 1;
      widget.searchBarStatus?.value = 1;
      _animController.forward();
    } else {
      widget.textController.clear();
      reactiveToggle.value = 0;
      widget.searchBarStatus?.value = 0;
      FocusManager.instance.primaryFocus?.unfocus();
      _animController.reverse();
    }
    Future.delayed(Duration(milliseconds: widget.animationDurationInMilli)).then((_) {
      if (mounted) {
        _isAnimating = false;
      }
    });
  }
}