import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:intl/intl.dart' as intl;
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_text.dart';



class AppToast {
  static AppToast instance = AppToast._internal();
  factory AppToast() => instance;
  AppToast._internal();
  bool _isShowing = false;
  OverlayEntry? _overlayEntry;
  Timer? _timer;

  void show({String message = "", double seconds = 2, Widget? overlayWidget}) {
    _timer?.cancel();
    if (_isShowing) {
      _overlayEntry?.remove();
      _isShowing = false;
    }

    _overlayEntry = OverlayEntry(builder: (context) {
      return Directionality(
        textDirection: intl.Bidi.isRtlLanguage(Get.locale?.languageCode) ? TextDirection.rtl : TextDirection.ltr,
        child: overlayWidget != null
            ? Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () => dismiss(),
            child: [
              overlayWidget,
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: dismiss,
                  child: const SizedBox.expand(),
                ),
              ),
            ].toStack(),
          ),
        )
            : IgnorePointer(
          child: Material(
            color: Colors.transparent,
            child: SafeArea(
              child: Align(
                alignment: AlignmentDirectional.bottomCenter,
                child: Container(
                  padding: pad(a: 10),
                  margin: pad(w: 10, bottom: 30),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: appColors.white,
                      boxShadow: getBoxShadow()),
                  child: [
                    Assets.drawableGuestTrips.toSVG(size: 20, colour: appColors.black).toPad(end: 10),
                    CustomText(
                      text: message,
                      size: AppDimen.textSize_14,
                    ).toStretch(isExpanded: false),
                  ].toRow(mainAxisSize: MainAxisSize.min),
                ),
              ),
            ),
          ),
        ),
      );
    });

    final overlay = Get.key.currentState?.overlay;

    if (overlay != null) {
      overlay.insert(_overlayEntry!);
      _isShowing = true;

      _timer = Timer(Duration(milliseconds: (seconds * 1000).toInt()), () {
        dismiss();
      });
    } else {
      debugPrint("Error: Could not find Overlay via Get.key");
    }
  }

  void dismiss() {
    if (_isShowing) {
      _overlayEntry?.remove();
      _isShowing = false;
      _timer?.cancel();
    }
  }
}