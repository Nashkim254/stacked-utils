import 'package:flutter/material.dart';

/// Breakpoint-based responsive helpers.
abstract final class Responsive {
  static const double _mobileMax = 599;
  static const double _tabletMax = 1023;

  static bool isMobile(BuildContext ctx) =>
      MediaQuery.sizeOf(ctx).width <= _mobileMax;
  static bool isTablet(BuildContext ctx) =>
      MediaQuery.sizeOf(ctx).width > _mobileMax &&
      MediaQuery.sizeOf(ctx).width <= _tabletMax;
  static bool isDesktop(BuildContext ctx) =>
      MediaQuery.sizeOf(ctx).width > _tabletMax;

  /// Returns a value based on the current breakpoint.
  ///
  /// ```dart
  /// double padding = Responsive.resolve(context,
  ///   mobile: 16, tablet: 32, desktop: 64);
  /// ```
  static T resolve<T>(
    BuildContext ctx, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(ctx)) return desktop ?? tablet ?? mobile;
    if (isTablet(ctx)) return tablet ?? mobile;
    return mobile;
  }
}

/// Inline responsive builder widget.
///
/// ```dart
/// ResponsiveBuilder(
///   mobile:  MobileLayout(),
///   tablet:  TabletLayout(),
///   desktop: DesktopLayout(),
/// )
/// ```
class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveBuilder({
    required this.mobile,
    this.tablet,
    this.desktop,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Responsive.resolve(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
}
