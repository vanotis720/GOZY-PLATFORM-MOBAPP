import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher show launchUrl;

class ExpandableCollapseText extends StatefulWidget {
  const ExpandableCollapseText(
      this.text, {
        super.key,
        this.trimLines = 3,
        this.onTap,
        this.size,
        this.textAlign,
        this.fontWeight,
        this.lastTextValue,
    this.lastTextValueColor,
    this.color,
  });

  final String text;
  final String? lastTextValue;
  final int trimLines;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;

  final GestureTapCallback? onTap;
  final double? size;
  final Color? lastTextValueColor;
  final Color? color;

  @override
  ExpandableCollapseTextState createState() => ExpandableCollapseTextState();
}

class ExpandableCollapseTextState extends State<ExpandableCollapseText> {
  final RxBool _readMore = true.obs;

  @override
  Widget build(BuildContext context) {

    Widget result = Obx(() {
      TextSpan link = TextSpan(

          text: _readMore.value ? " ...${widget.lastTextValue ?? label_show_more.tr}" : " ...${widget.lastTextValue ??label_show_less.tr}",

          style: TextStyle(
              color: widget.lastTextValueColor ?? appColors.secondaryColor,
              fontSize: widget.size ?? AppDimen.textSize_14,
              fontWeight: widget.fontWeight ?? AppFont.regular,
              fontFamily: AppFont.font
          ),
          recognizer: TapGestureRecognizer()..onTap = widget.lastTextValue !=null ? null : widget.onTap ?? () {
            _readMore.value = !_readMore.value;
            _readMore.refresh();
          }
      );
      return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double maxWidth = constraints.maxWidth;
            final text = TextSpan(
                text: widget.text,
                style: TextStyle(
                    fontFamily: AppFont.font,
                    fontSize: widget.size ?? AppDimen.textSize_14,
                    fontWeight: widget.fontWeight ?? AppFont.regular
                )
            );
            TextPainter textPainter = TextPainter(
              text: link,
              textDirection: TextDirection.rtl,
              maxLines: widget.trimLines,
              ellipsis: '...',
            );
            textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
            final linkSize = textPainter.size;

            textPainter.text = text;
            textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
            final textSize = textPainter.size;
            // Get the endIndex of data
            int endIndex;
            final pos = textPainter.getPositionForOffset(Offset(
              textSize.width - linkSize.width,
              textSize.height,
            ));
            endIndex = textPainter.getOffsetBefore(pos.offset) ?? 0;
            TextSpan textSpan, normalTextSpan, urlSpan;
            List<TextSpan> listSpan = [];

            if (textPainter.didExceedMaxLines) {
              textSpan = TextSpan(
                text: _readMore.value
                    ? widget.text.substring(0, endIndex)
                    : widget.text,
                style: TextStyle(
                    color:widget.color ?? appColors.customTextColor,
                    fontFamily: AppFont.font,
                    fontSize: widget.size ?? AppDimen.textSize_14,
                    fontWeight: widget.fontWeight ?? AppFont.regular
                ),
                children: <TextSpan>[link],
              );

            } else {
              textSpan = TextSpan(
                  text: widget.text,
                  style: TextStyle(
                      fontFamily: AppFont.font,
                      color:  widget.color ?? appColors.customTextColor,
                      fontSize: widget.size ?? AppDimen.textSize_14,
                      fontWeight: widget.fontWeight ?? AppFont.regular
                  )
              );
            }

            textSpan.text!.splitMapJoin(
                urlRegExp,
                onMatch: (m) {
                  String  urlString = "${m.group(0)}";
                  debugPrint('urlString: $urlString');
                  urlSpan =  TextSpan(
                    text: urlString,
                    style: TextStyle(color: Colors.blue),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        UrlLauncher.launchUrl(Uri.parse(urlString));
                      },
                  );
                  listSpan.add(urlSpan);

                  return urlString;
                },
                onNonMatch: (n) {
                  String normalText =  n.substring(0);
                  normalTextSpan =  TextSpan(
                    text:  normalText,
                    style: TextStyle(
                        color:  widget.color ?? appColors.customTextColor,
                        fontFamily: AppFont.font,
                        fontSize: widget.size ?? AppDimen.textSize_14,
                        fontWeight: widget.fontWeight ?? AppFont.regular
                    ),
                  );
                  listSpan.add(normalTextSpan);
                  return normalText;
                }
            );

            if(textPainter.didExceedMaxLines) {
              listSpan.add(link);
            }

            return RichText(
              softWrap: true,
              overflow: TextOverflow.clip,
              textAlign:widget.textAlign ?? TextAlign.start,
              text: TextSpan(text:'', children: listSpan,),
            );
          }
      );
    }
    );
    return result;
  }
}