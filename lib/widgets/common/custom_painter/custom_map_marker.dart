import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart' as intl;
import 'package:gozy/constant.dart';
import 'package:gozy/resources/app_colors.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/widgets/common_extension_functions.dart';

// https://gist.github.com/itsJoKr/ce5ec57bd6dedf74d1737c1f39481913?permalink_comment_id=3797446#gistcomment-3797446
//https://www.youtube.com/watch?v=nIV9_FXSiYw
class Place {
  final String id, title,price, vicinity;
  final LatLng position;

  Place(
      {required this.id,
        required this.title,
        required this.price,
        required this.position,
        this.vicinity = ''});

  static Place fromJson(Map<String, dynamic> json) {
    final coords = List<double>.from(json['position']);

    return Place(
      id: json['id'],
      title: json['title'],
      price: json['price'],
      vicinity: json['vicinity'] ?? '',
      position: LatLng(coords[0], coords[1]),
    );
  }
}


class CustomMapMarker extends CustomPainter {
  late Place place;

  late RxInt selectedId;
  late bool isChange;
  late bool isDisableStroke;
  late bool _isItemSelected;
  String? content;
  late double fontSize ;
  late TextPainter textPainter;
  late Offset textPainteroffset ;
  late EdgeInsets padding;
  Color? contentBGColor;
  Color? textColor;
  double triangleoffset = 0;
  double rectoffset = 0;
  double borderRadius = 4;
  int lineLength = 4;

  CustomMapMarker(
      {Place? place,
        RxInt? selectedId,
        bool? isChange,
        this.content,
        this.lineLength = 30,
        bool? isItemSelected,
        this.contentBGColor,
        this.textColor,
        bool? isDisableStroke,
        double? fontSize,
        double? borderRadius,
        EdgeInsets? padding}) {
    if(isDisableStroke ==null) {
      this.isDisableStroke = false;
    } else {
      this.isDisableStroke = isDisableStroke;
    }
    if(place !=null) {
      this.place = place;
    }

    if(selectedId !=null) {
      this.selectedId = selectedId;
    }
    this.isChange = isChange ?? false;

    if(borderRadius !=null) {
      print("overALLAppLayoutModel?.borderRadius${overALLThemeType}");
      this.borderRadius = (overALLThemeType == 3) ? 45 : overALLAppLayoutModel?.borderRadius ?? borderRadius;
    }

    if(fontSize !=null){
      this.fontSize = fontSize;
    }
    else if(isItemSelected!=null && isItemSelected) {
      this.fontSize = 15;
    }else{
      this.fontSize= Platform.isAndroid ? 40 :30;
    }

    _isItemSelected = selectedId !=null && place !=null ? ( selectedId.value == int.parse(place.id)  && isChange!) : (isItemSelected ?? true);
    TextSpan textSpan = TextSpan(
      children: TextSpan(text: content ??
          this.place.price.toNumberFormat(symbol:selectedCurrencySymbol),
          style: TextStyle(
              fontSize: this.fontSize,
              fontFamily: AppFont.font,
              color: _isItemSelected ?textColor ?? AppColors.staticwhite : AppColors.staticblack)).toCurrencyTextSpan(symbol: selectedCurrencySymbol),
    );
    textPainter = TextPainter(
        text: content !=null ?
        TextSpan(text: content!, style: TextStyle(
            fontSize: this.fontSize,
            fontFamily: AppFont.font,
            color: _isItemSelected ?textColor ?? AppColors.staticwhite : AppColors.staticblack)) : textSpan,
        textDirection: intl.Bidi.isRtlLanguage(Get.locale?.languageCode) ? TextDirection.rtl : TextDirection.ltr,
        textAlign: TextAlign.center,
        maxLines: 9
    );
    final view = View.of(Get.context!);
    final maxBubbleWidth = MediaQueryData.fromView(view).size.width * 0.75;
    textPainter.layout(
        maxWidth: maxBubbleWidth
    );
    this.padding = padding ?? (content == null ? const EdgeInsets.symmetric(horizontal: 30, vertical: 20) : const EdgeInsets.all(5));
    textPainteroffset = Offset(this.padding.left + this.padding.right, this.padding.top + this.padding.bottom);

  }

  @override
  void paint(Canvas canvas, Size size) {

    final Paint paint = Paint()
      ..color = _isItemSelected ? contentBGColor ?? AppColors.linkColor : AppColors.staticwhite
      ..style = PaintingStyle.fill;

    final Paint strokepaint = Paint()
      ..color = _isItemSelected ? contentBGColor ?? AppColors.linkColor : Colors.grey.shade300
      ..strokeWidth =
      content !=null ? 4 : 5
      ..style = PaintingStyle.stroke;


    final double triangleH = content !=null ? 5 : 20;
    final double triangleW = content !=null ? 10 : 30;
    final double triangleWByTwo = triangleW/2;

    double width = textPainter.width+textPainteroffset.dx;
    final double height = textPainter.height+textPainteroffset.dy;
    rectoffset = content !=null ? 0 : 2.5;
    double start = 1.5;

    Rect rect = Rect.fromLTWH(start,start, width, height);
    RRect rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    Rect normalrect = Rect.fromLTWH(rectoffset, rectoffset, width- rectoffset, height- rectoffset);
    RRect normalrrect = RRect.fromRectAndRadius(normalrect, Radius.circular(borderRadius));
    double trianglestartpoint =( width / 2)+triangleoffset;


    final Path trianglePath = Path()
      ..moveTo(trianglestartpoint - triangleWByTwo, height)
      ..lineTo(trianglestartpoint, triangleH + height)
      ..lineTo(trianglestartpoint + triangleWByTwo, height)
      ..close();

    if(!isDisableStroke) {
      canvas.drawPath(trianglePath, strokepaint);
    }
    if(!isDisableStroke) {
      canvas.drawRRect(rrect, strokepaint);
    }
    canvas.drawRRect(normalrrect, paint);
    canvas.drawPath(Path()
      ..moveTo(trianglestartpoint - triangleWByTwo, height-1)
      ..lineTo(trianglestartpoint, triangleH + height)
      ..lineTo(trianglestartpoint + triangleWByTwo, height)
      ..close(), paint);

    textPainter.paint(
      canvas,
      Offset(padding.left, padding.top),
    );

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  void setTriangleOffset(double startoffset) {
    triangleoffset = startoffset;
  }

  void setStartOffset(double offset) {
    rectoffset = offset;
  }
}