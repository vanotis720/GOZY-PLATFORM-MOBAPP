import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common/custom_text/custom_title_text.dart';
import 'package:gozy/widgets/common_extension_functions.dart';
import 'package:gozy/widgets/common/custom_container/custom_container.dart';
import 'package:gozy/widgets/custom_text.dart';

class CustomEmptyView extends GetView {
  final String buttonText;
  final String? buttonImage;
  final String imagePath;
  final Widget? emptyImageWidget;
  final String emptyDescription;
  final String emptyTitle;
  final FontWeight? emptyTitleFontWeight;
  final FontWeight? descriptionTitleFontWeight;
  final double? emptyTitleFontSize;
  final double? descriptionTitleFontSize;
  final bool? isLoading;
  final bool? isFlexibleText;
  final bool isPrimaryButton;
  final double? height;
  final GestureTapCallback? onTap;

  const CustomEmptyView({
    super.key,
    this.buttonImage,
    this.buttonText = "",
    this.imagePath = "",
    this.emptyImageWidget,
    this.emptyDescription = "",
    this.emptyTitle = "",
    this.isLoading = false,
    this.height,
    this.isFlexibleText = false,
    this.isPrimaryButton = false,
    this.onTap,
    this.emptyTitleFontWeight,
    this.descriptionTitleFontWeight,
    this.emptyTitleFontSize,
    this.descriptionTitleFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      width: deviceWidth,
      height: height ?? (deviceHeight - 220),
      alignment: AlignmentDirectional.center,
      padding: pad(w: AppDimen.startMargin, h: AppDimen.backIconInnerPad),
      body: [
        (emptyImageWidget ?? imagePath.toSVG()).toPad(
          bottom: 24,
        ),
        if (emptyTitle.isNotEmpty)
          CustomTitleText(
            text: emptyTitle,
            size: emptyTitleFontSize ?? AppDimen.textSize_22,
            fontWeight: emptyTitleFontWeight ?? AppFont.semiBold,
            textAlign: TextAlign.center,
          ).toPad(bottom: 15),
        CustomText(
          text: emptyDescription,
          textAlign: TextAlign.center,
          size: descriptionTitleFontSize?? AppDimen.textSize_16,
          fontWeight: descriptionTitleFontWeight ?? AppFont.regular,
        ).toPad(bottom: 12),
        if (buttonText.isNotEmpty)...[
          <Widget>[
            (buttonImage != null && (buttonImage?.isNotEmpty ?? false)) ? buttonImage!.toSVG(size: 12, colour: appColors.secondaryColor) : const SizedBox.shrink(),
            CustomContainer(
              onTap: onTap,
              padding: pad(w: (buttonImage != null && (buttonImage?.isNotEmpty ?? false)) ? 4 : 0),
              body: CustomText(
                text: buttonText,
                textAlign: TextAlign.center,
                color: appColors.secondaryColor,
              )
            )
          ].toRow().toPad(bottom: 20)
        ],
      ].toColumn(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max).toScroll(),
    );
  }
}