import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CustomCachedNetworkImage extends StatelessWidget {
  /*

@imageUrl - The target image that is displayed. (Required)
@width - the image to have this width. (Optional)
@height - the image to have this height. (Optional)
@fit - How the image should be inscribed into the box. (Optional)
@isRoundIcon - shape change to rounded clip of image (Optional)
@placeholder - showing widget before caching the image (Optional)
@errorWidget -  showing widget when URL have issue(Optional)
@backgroundColor - backgroundColor for after loaded URL to image (Optional)
@borderRadius - when image is in rectangle shape corner radius (Optional)

 */


  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool isRoundIcon;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? backgroundColor;
  final double borderRadius;
  final Duration? fadeOutDuration;
  final Duration? fadeInDuration;
  final bool gaplessPlayback;


  const CustomCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.isRoundIcon = false,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
    this.borderRadius = 0.0,
    this.fadeOutDuration,
    this.fadeInDuration,
    this.gaplessPlayback = false,
  });

  @override
  Widget build(BuildContext context) {
    int cacheSize = 200;
    // Calculate display pixels vs physical pixels for sharp images
    final int effectiveCache = (cacheSize * MediaQuery.devicePixelRatioOf(context)).round();

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      memCacheWidth: effectiveCache,
      memCacheHeight: effectiveCache,
      // gaplessPlayback: gaplessPlayback,
      fadeOutDuration: fadeOutDuration,
      fadeInDuration: fadeInDuration ?? Duration.zero,
      // Using imageBuilder is standard for custom shapes/borders
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: isRoundIcon ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isRoundIcon ? null : BorderRadius.circular(borderRadius),
          image: DecorationImage(
            image: imageProvider,
            fit: fit,
          ),
        ),
      ),
      placeholder: (context, url) => placeholder ?? const SizedBox.shrink(),
      errorWidget: (context, url, error) =>
      errorWidget ?? placeholder ?? const Icon(Icons.broken_image),
    );
  }
}