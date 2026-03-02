import 'package:flutter/material.dart';

import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';

/// A consistent card widget built from design tokens.
///
/// ```dart
/// AppCard(
///   onTap: () => viewModel.openDetail(item),
///   child: ListTile(title: Text(item.name)),
/// )
/// ```
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final Color? color;
  final double elevation;
  final bool showBorder;

  const AppCard({
    required this.child,
    this.onTap,
    this.padding,
    this.radius = AppRadius.card,
    this.color,
    this.elevation = 0,
    this.showBorder = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final borderRadius = BorderRadius.circular(radius);

    return Material(
      color: color ?? cs.surface,
      elevation: elevation,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: showBorder
                ? Border.all(color: cs.outline.withOpacity(0.5))
                : null,
            borderRadius: borderRadius,
          ),
          padding: padding ?? const EdgeInsets.all(AppSpacing.md),
          child: child,
        ),
      ),
    );
  }
}
