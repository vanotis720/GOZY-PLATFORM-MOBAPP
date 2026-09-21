import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:gozy/resources/app_dimen.dart';
import 'package:gozy/resources/app_font.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common/custom_network_image/custom_profile_network_image.dart';
import 'package:gozy/widgets/common_extension_functions.dart';

class CustomUserProfileInfoText extends StatelessWidget {
  final String userImage;
  final String? userName;
  final String profileIconType;
  final String? linkText;
  final GestureTapCallback? onLinkTap;
  final FontWeight? userNameFontWeight;
  final double? linkTextFontSize;
  final Widget? placeholderWidget;
  final double? imageSize;
  final double? userNameTextSize;
  final Color? userNameTextColor;
  final Color? linkTextColor;
  final bool isCancel;
  final GestureTapCallback? onProfileTap;

  const CustomUserProfileInfoText({
    super.key,
    required this.userImage,
    required this.profileIconType,
    this.userName,
    this.linkText,
    this.onLinkTap,
    this.userNameFontWeight,
    this.linkTextFontSize,
    this.placeholderWidget,
    this.imageSize,
    this.userNameTextSize,
    this.userNameTextColor,
    this.linkTextColor,
    this.isCancel = false,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = _buildContent();

    return toOnTap(
      onTap: onProfileTap,
      child: [
      CustomProfileNetworkImage(
  
        imageUrl: userImage,
          all: imageSize ?? 60,
        placeholder: placeholderWidget, profileImageType: profileIconType,
        ),
        12.toWidth(),
        content.toStretch()
      ].toRow(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
    );
  }

  Widget _buildContent() {

    // Cancel State
    if (isCancel) {
      if (linkText == null) return const SizedBox.shrink();
      return Text(
        intl.toBeginningOfSentenceCase(linkText!),
        style: TextStyle(
          color: linkTextColor ?? appColors.textColor,
          fontSize: userNameTextSize ?? AppDimen.textSize_16,
            fontWeight: userNameFontWeight ?? AppFont.regular
        ),
      );
    }

    // Default Info State
    return [
      if (userName != null)
        Text(
          intl.toBeginningOfSentenceCase(userName!),
          style: TextStyle(
              color: userNameTextColor ?? appColors.textColor,
              fontSize: userNameTextSize ?? AppDimen.textSize_14,
              fontWeight: userNameFontWeight ?? AppFont.regular),
        ),
      if (userName != null && linkText != null) 4.toHeight(),
      if (linkText != null)
        toOnTap(
          onTap: onLinkTap,
          child: Text(
            linkText!.toUpperLowerCase(),
            style: TextStyle(
              fontSize: linkTextFontSize ?? AppDimen.textSize_12,
              color: linkTextColor ?? appColors.placeholderColor,
            ),
          ),
        ),
    ].toColumn(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }
}