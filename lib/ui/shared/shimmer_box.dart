import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/app_radius.dart';

/// A shimmering placeholder box for skeleton loading screens.
///
/// ```dart
/// ShimmerBox(width: double.infinity, height: 56)
/// ShimmerBox(width: 80, height: 80, radius: AppRadius.full) // avatar
/// ```
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerBox({
    required this.width,
    required this.height,
    this.radius = AppRadius.sm,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2A2A3E) : const Color(0xFFE0E0E0),
      highlightColor:
          isDark ? const Color(0xFF3A3A4E) : const Color(0xFFF5F5F5),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// Wraps any widget with a shimmer effect while [loading] is true.
///
/// ```dart
/// myWidget.withShimmer(viewModel.isBusy)
/// ```
extension ShimmerWidgetX on Widget {
  Widget withShimmer(bool loading) =>
      loading ? ShimmerWrapper(child: this) : this;
}

/// A [Shimmer] wrapper that uses the app's light/dark-aware colors.
class ShimmerWrapper extends StatelessWidget {
  final Widget child;

  const ShimmerWrapper({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2A2A3E) : const Color(0xFFE0E0E0),
      highlightColor:
          isDark ? const Color(0xFF3A3A4E) : const Color(0xFFF5F5F5),
      child: child,
    );
  }
}
