import 'package:flutter/material.dart';
import 'package:gozy/constant.dart';
import 'package:gozy/generated/assets.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common/custom_container/custom_wishlist_container.dart';
import 'package:gozy/widgets/common/custom_network_image/custom_cached_network_image.dart';
import 'package:gozy/widgets/common_extension_functions.dart';

class CustomProfileNetworkImage extends StatelessWidget {

  /*

@imageUrl - The target image that is displayed. (Required)
@all - the image to have this width & height. (Optional)
@isShimmerView - check api is loading or not (Optional)
@isRoundIcon - showing widget before caching the image (Optional)
@onTap - function when click that profile image (Optional)
@indicatorColor - border color of the surronding for profile image (Optional)
@shimmerColor - when api is loading, apply the shimmer loading color to  profile image (Optional)
@editIcon - theme mode based edit icon (Optional)
@alignPosition - positional param the edit icon within the stack (Optional)
@placeholder - showing widget before caching the image (Optional)
 */

  final String? imageUrl;
  final double? all;
  final bool isShimmerView;
  final bool? isRoundIcon;
  final VoidCallback? onTap;
  final double? paddingForNewCircle;
  final Color? indicatorColor;
  final Color? shimmerColor;
  final String editIcon;
  final String profileImageType;
  final double? alignPosition;
  final Widget? placeholder;

  const CustomProfileNetworkImage({
    super.key,
   required this.imageUrl,
    this.all,
    this.isShimmerView = false,
    this.isRoundIcon,
    this.paddingForNewCircle,
    this.onTap,
    required this.profileImageType,
    this.indicatorColor,
    this.shimmerColor,
    this.editIcon = "",
    this.alignPosition,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final double size = all ?? 50.0;
    final bool isCircular = isRoundIcon ?? (profileImageType != 'rect');

    // 1. Handle Shimmer State immediately
    if (isShimmerView) {
      return _buildShimmer(size, isCircular);
    }

    // 2. Build the Core Image Logic
    Widget picture = _buildImageLogic(size, isCircular);

    // 3. Handle Wrappers (Edit Icon, Taps, and Counter Container)
    if (editIcon.isNotEmpty) {
      picture = Stack(
        clipBehavior: Clip.none,
        children: [
          picture,
          _buildEditIcon(),
        ],
      );
    }

    if (onTap != null) {
      picture = GestureDetector(onTap: onTap, child: picture);
    }

    // 4. Special 'newcircle' Theme handling
    if (profileImageType.contains('newcircle')) {
      return _buildNewCircleWrapper(picture, size);
    }

    return picture;
  }

  Widget _buildImageLogic(double size, bool isCircular) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return placeholder ?? _buildPlaceholder(size, isCircular);
    }

    final String fullUrl = profileImagePath + imageUrl!;
    final String smallUrl = profileSmallImagePath + imageUrl!;

    return CustomCachedNetworkImage(
      imageUrl: fullUrl,
      width: size,
      height: size,
      isRoundIcon: isCircular,
      borderRadius: 10,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      fadeOutDuration: Duration.zero,
      fadeInDuration: Duration.zero,
      placeholder: placeholder ?? CustomCachedNetworkImage(
        imageUrl: smallUrl,
        width: size,
        height: size,
        isRoundIcon: isCircular,
        borderRadius: 10,
        fit: BoxFit.cover,
        placeholder: _buildPlaceholder(size, isCircular),
      ),
      errorWidget: placeholder ?? _buildPlaceholder(size, isCircular),
    );
  }

  Widget _buildPlaceholder(double size, bool isCircular) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircular ? null : BorderRadius.circular(10),
        color: appColors.primaryColor.withAlpha((255.0 * 0.1).round()),
      ),
      child: ClipRRect(
        borderRadius: isCircular ? BorderRadius.circular(size) : BorderRadius.circular(10),
        child: Assets.drawablePlaceholderProfile.toSVG(fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildEditIcon() {
    return PositionedDirectional(
      bottom: alignPosition ?? 0,
      end: alignPosition ?? 0,
      child: CustomWishlistContainer(
        width: 34,
        height: 34,
        onTap: onTap,
        color: appColors.black,
        body: editIcon.toSVG(colour: appColors.white,fit: BoxFit.none),
      ),
    );
  }

  Widget _buildNewCircleWrapper(Widget child, double size) {
    final Color borderCol = indicatorColor ??
        (profileImageType == 'newcirclesecondary' ? appColors.secondaryColor : appColors.primaryColor);

    return Container(
      height: size,
      width: size,
      padding: EdgeInsets.all(paddingForNewCircle ?? 2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderCol, width: 2),
      ),
      child: child,
    );
  }

  Widget _buildShimmer(double size, bool isCircular) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: shimmerColor ?? appColors.shimmerplaceholderColor,
        shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircular ? null : BorderRadius.circular(10),
      ),
    );
  }
}