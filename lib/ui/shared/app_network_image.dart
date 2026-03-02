import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'shimmer_box.dart';

/// A general-purpose cached network image with a shimmer placeholder,
/// error fallback, and optional rounded corners.
///
/// ```dart
/// AppNetworkImage(
///   url: product.imageUrl,
///   width: double.infinity,
///   height: 200,
///   radius: AppRadius.card,
///   fit: BoxFit.cover,
/// )
/// ```
class AppNetworkImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double radius;
  final Widget? errorWidget;
  final Color? shimmerBaseColor;
  final Color? shimmerHighlightColor;

  const AppNetworkImage({
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.radius = 0,
    this.errorWidget,
    this.shimmerBaseColor,
    this.shimmerHighlightColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => ShimmerBox(
        width: width ?? double.infinity,
        height: height ?? 200,
        radius: radius,
      ),
      errorWidget: (_, __, ___) =>
          errorWidget ?? _defaultError(width, height, radius),
    );

    if (radius > 0) {
      image = ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: image,
      );
    }

    return image;
  }

  static Widget _defaultError(double? width, double? height, double radius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Color(0xFF9CA3AF),
          size: 32,
        ),
      ),
    );
  }
}
