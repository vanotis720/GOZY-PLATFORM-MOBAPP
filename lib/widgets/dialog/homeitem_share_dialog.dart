import 'dart:async' show Timer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/resources/app_colors.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/resources/app_lang.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common/custom_container/custom_border_container.dart';
import 'package:gozy/widgets/common/custom_network_image/custom_clip_network_image.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/custom_text.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeItemShareDialog extends StatelessWidget {
  final String? imageUrl;
  final int? itemId;
  final String? listTitle;
  final String? address;
  final double? borderRadius;
  final double? insideImageBorderRadius;
  final BaseController? controller;
  bool _isUrlLaunched = true;
  Color? IconBGColor;
  Color? BottomSectionBGColor;
  Color? TopSectionBGColor;
  bool? isBottomSectionRounded;
  bool? isShowDivider;
  double _imageHeightWidth = 165;

  HomeItemShareDialog(
      {super.key,
      this.imageUrl,
      this.insideImageBorderRadius,
      required this.itemId,
      required this.controller,
      required this.listTitle,
      required this.address,
      this.TopSectionBGColor,
      this.BottomSectionBGColor,
      this.IconBGColor,
      this.borderRadius,
      this.isShowDivider,
      this.isBottomSectionRounded});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius ?? 0.0)),
      insetPadding: EdgeInsets.zero,
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(),
    );
  }

  Widget dialogContent() {
    return [
      [
        CustomBorderContainer(
          margin: pad(w: AppDimen.startMargin),
          borderRadius: borderRadius,
          color: TopSectionBGColor ?? appColors.white,
          body: <Widget>[
            [
              CustomClipNetworkImage(
                imageUrl: imageUrl!,
                width: deviceWidth,
                height: _imageHeightWidth,
                borderRadius: BorderRadius.all(Radius.circular(
                    (borderRadius! > 25.0 ? borderRadius! - 10 : borderRadius) ?? AppDimen.appBorderRadius)),
              ),
              10.toHeight(),
              CustomText(
                text: label_share_title_content.tr,
                fontWeight: AppFont.medium,
                size: AppDimen.textSize_18,
              ),
              5.toHeight(),
              CustomText(
                text: "${label_checkout.tr} ${listTitle!},",
                fontWeight: AppFont.regular,
                size: AppDimen.textSize_16,
              ),
              CustomText(text: address!, fontWeight: AppFont.regular, size: AppDimen.textSize_14),
            ].toColumn().toPad(all: 16),
            if (isShowDivider ?? false) filterDivider,
            CustomBorderContainer(
              borderRadiusGeometry: BorderRadiusDirectional.only(
                bottomStart: Radius.circular(borderRadius ?? 0),
                bottomEnd: Radius.circular(borderRadius ?? 0),
                topStart: Radius.circular(
                    isBottomSectionRounded != null && isBottomSectionRounded! ? borderRadius ?? 0 : 0.1),
                topEnd: Radius.circular(
                    isBottomSectionRounded != null && isBottomSectionRounded! ? borderRadius ?? 0 : 0.1),
              ),
              color: BottomSectionBGColor ?? appColors.myTripsBGColor,
              body: [
                [
                  _shareOptionsView(
                      svgAsset: Assets.drawableFb,
                      circleColor: IconBGColor ?? AppColors.staticwhite,
                      onTap: () async {
                        if (_isUrlLaunched) {
                          _isUrlLaunched = false;
                          Uri fbURL = Uri.parse(
                              'https://www.facebook.com/sharer.php?u=+${shareUrl + itemId.toString()}');
                          if (await canLaunchUrl(fbURL)) {
                            launchUrl(fbURL);
                            Timer(Duration(milliseconds: 750), () {
                              _isUrlLaunched = true;
                            });
                          }
                        }
                      },
                      height: 45, isPad: true),
                  _shareOptionsView(
                      svgAsset: Assets.drawableXTwitter,
                      circleColor: IconBGColor ?? AppColors.staticwhite,
                      onTap: () async {
                        if (_isUrlLaunched) {
                          _isUrlLaunched = false;
                          final twitterUrl = Uri.parse(
                              'https://twitter.com/intent/tweet?text=$listTitle&url=${Uri.encodeComponent(shareUrl + itemId.toString())}');
                          if (await canLaunchUrl(twitterUrl)) {
                            launchUrl(twitterUrl);
                            Timer(Duration(milliseconds: 750), () {
                              _isUrlLaunched = true;
                            });
                          }
                        }
                      },
                      height: 45, isPad: false),
                  _shareOptionsView(
                      svgAsset: Assets.drawableEmail,
                      circleColor: IconBGColor ?? AppColors.staticwhite,
                      onTap: () async {
                        Uri URL = Uri(
                          scheme: 'mailto',
                          path: '',
                          query:
                              'subject=${email_content1.tr} $APP_NAME!&body=${email_content.trParams({"field":APP_NAME})} $shareUrl$itemId'
                        );
                        if (_isUrlLaunched) {
                          _isUrlLaunched = false;
                          if (await canLaunchUrl(URL)) {
                            launchUrl(URL).then((value) {
                              Timer(Duration(milliseconds: 750), () {
                                _isUrlLaunched = true;
                              });
                            });
                          }
                        }
                      },
                      height: 45, isPad: false),
                  _shareOptionsView(
                      svgAsset: Assets.drawableCopy,
                      circleColor: IconBGColor ?? AppColors.staticwhite,
                      onTap: () async {
                        Clipboard.setData(ClipboardData(
                                text: "$shareUrl${generateRegex(listTitle.toString())}-$itemId"))
                            .then((_) {
                          controller?.showToast(copied_to_clipboard.tr);
                        });
                      },
                      height: 45, isPad: false),
                ].toRow(mainAxisAlignment: MainAxisAlignment.spaceEvenly).toPad(all: 18),
                toOnTap(
                  onTap: () {
                    Uri uri = Uri.parse(shareUrl + itemId.toString());
                    final params = ShareParams(uri: uri);
                    SharePlus.instance.share(params);
                  },
                  child: CustomText(
                          text: label_share_listing_more.tr,
                          color: AppColors.linkColor,
                          size: AppDimen.textSize_14)
                      .toPad(top: 5, bottom: 15),
                )
              ].toColumn(crossAxisAlignment: CrossAxisAlignment.center),
            )
          ].toColumn(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start),
        ),
      ]
          .toColumn(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center)
          .toPad(vertical: 13.0, horizontal: 8.0),
      PositionedDirectional(
        top: borderRadius! > 25.0 ? 2.5 : 2,
        end: borderRadius! > 25.0 ? 14 : 10,
        child: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Align(
            alignment: AlignmentDirectional.topEnd,
            child: Assets.drawableSignupClose
                .toSVG(colour: appColors.black, size: 14)
                .toCircle(
                    margin: 15,
                    padding: 9,
                    isBorderNeed: true,
                    borderColor: appColors.myTripsBGColor,
                    color: appColors.white)
                .toResizeWidget(),
          ),
        ),
      ),
    ].toStack().toResizeWidget(width: deviceWidth);
  }

  Widget _shareOptionsView(
      {String? svgAsset, Color? circleColor, Function? onTap, double? height, double? width, required bool isPad}) {
    return toOnTap(
        onTap: () => onTap!(),
        child: svgAsset!
            .toSVG()
            .toPad(all: isPad ? 0 : 2)
            .toCircle(color: circleColor ?? appColors.white, margin: 0)
            .toResizeWidget(height: height, width: width));
  }

  String generateRegex(String string) {
    string = string.trim();
    string = string.toLowerCase();
    string = string.replaceAll(' ', '-');
    string = string.replaceAll(',', '-');
    string = string.replaceAll('/', '-');
    string = string.replaceAll('#', '-');
    string = string.replaceAll('%', '-');
    return string;
  }
}