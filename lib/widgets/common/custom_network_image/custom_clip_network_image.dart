import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gozy/screens/views/base_controller.dart';
import 'package:gozy/widgets/common/custom_network_image/custom_cached_network_image.dart';
import 'package:gozy/widgets/common_extension_functions.dart';



class CustomClipNetworkImage extends StatelessWidget {

  /*

@imageUrl - url image to load from web (Required)
 @width -  allocation width of the image  (Optional)
 @height - allocation height of the image (Optional)
@foregroundDecoration - background style when loading the url  (Optional)
@isShimmerView - condition for enable the shimmer loading the URL (Optional)
@isImageZoom - to add the InteractiveViewer widget(optional)
@transformationController - image processing controller (optional)
@placeholderURL - load small size url before load the original imageUrl (optional)
@shimmerColor - when load the data to show the color (optional)
@cacheKey - reference key used to store the image widget (optional)
@borderRadius - when image is in rectangle shape corner radius (Optional)
@baseController - controller need to pass the image processing info that reactiveVariable (Optional)

 */
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxDecoration? foregroundDecoration;
  final bool isShimmerView;
  final ReactiveVariable? isImageZoom;
  final TransformationController? transformationController;
  final String? placeholderURL;
  final Widget? placeholderWidget;
  final Color? shimmerColor;
  final String? cacheKey;
  final BorderRadiusGeometry? borderRadius;
  final BaseController? baseController;

  const CustomClipNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.foregroundDecoration,
    this.isShimmerView = false,
    this.isImageZoom,
    this.transformationController,
    this.placeholderURL,
    this.placeholderWidget,
    this.shimmerColor,
    this.cacheKey,
    this.borderRadius,
    this.baseController,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty || isShimmerView) {
      return _buildShimmerOrEmpty();
    }

    // Wrap in RepaintBoundary to prevent image re-painting during parent animations
    return RepaintBoundary(
      child: Container(
        width: width,
        height: height,
        decoration: foregroundDecoration ?? _buildDefaultDecoration(),
        child: _buildHeroWrapper(_buildZoomWrapper(_buildImageStack())),
      ),
    );
  }

  // Optimized Decoration: Uses memCacheHeight/Width to save RAM
  BoxDecoration _buildDefaultDecoration() {
    final hasPlaceholder = placeholderURL?.isNotEmpty ?? false;
    return BoxDecoration(
      borderRadius: borderRadius,
      color: transformationController != null
          ? Colors.black
          : appColors.famousLocationBGColor,
      image: hasPlaceholder
          ? DecorationImage(
        image: CachedNetworkImageProvider(
          placeholderURL!,
          maxWidth: 200,
          maxHeight: 200,
        ),
        fit: BoxFit.cover,
      )
          : null,
    );
  }

  Widget _buildImageStack() {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CustomCachedNetworkImage(
        imageUrl:imageUrl,
        fit: BoxFit.cover,
        placeholder: placeholderWidget,
      ).toResizeWidget(height: 120, width: 170),
    );
  }

  Widget _buildZoomWrapper(Widget child) {
    if (transformationController == null) return child;
    return GestureDetector(
      onDoubleTap: () => isImageZoom !=null ?_handleDoubleTap() : null,
      child: InteractiveViewer(
        transformationController: transformationController,
        minScale: 1.0,
        maxScale: 4.0,
        onInteractionEnd: (_) =>  isImageZoom !=null ? _updateZoomState() : null,
        child: child,
      ),
    );
  }

  void _handleDoubleTap() {
    final isZoomed = isImageZoom?.value ?? false;
    transformationController!.value = isZoomed ? Matrix4.identity() : (Matrix4.identity()..scale(3.0));
    baseController?.change(rxVariable: isImageZoom!, value: !isZoomed);
  }

  void _updateZoomState() {
    final scale = transformationController!.value.getMaxScaleOnAxis();
    baseController?.change(rxVariable: isImageZoom!, value: scale > 1.0);
  }

  Widget _buildHeroWrapper(Widget child) {
    // if (!isEnableHero) return child;
    // return Hero(tag: 'listDetailimage + $listingId + $listingType', child: child);
    return child;
  }

  Widget _buildShimmerOrEmpty() {
    return Container(
      width: width,
      height: height,
      decoration: foregroundDecoration ?? BoxDecoration(
        color: shimmerColor ?? appColors.popularLocationtopShimmerColor,
        borderRadius: borderRadius,
      ),
    );
  }
}