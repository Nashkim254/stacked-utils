import 'package:flutter/material.dart';

import '../constants/app_radius.dart';

/// Consistent icon button with a fixed tap target, optional background,
/// and border. Avoids [IconButton]'s inconsistent padding behavior.
///
/// ```dart
/// AppIconButton(
///   icon: Icon(Icons.notifications_outlined),
///   onTap: viewModel.openNotifications,
/// )
///
/// AppIconButton(
///   icon: Icon(Icons.add),
///   onTap: viewModel.create,
///   outlined: true,
///   size: 40,
/// )
/// ```
class AppIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double size;
  final double iconSize;
  final bool outlined;
  final double radius;
  final String? tooltip;

  const AppIconButton({
    required this.icon,
    this.onTap,
    this.backgroundColor,
    this.foregroundColor,
    this.size = 44,
    this.iconSize = 22,
    this.outlined = false,
    this.radius = AppRadius.sm,
    this.tooltip,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = backgroundColor ?? Colors.transparent;
    final fg = foregroundColor ?? cs.onSurface;
    final borderRadius = BorderRadius.circular(radius);

    Widget button = SizedBox(
      width: size,
      height: size,
      child: Material(
        color: bg,
        borderRadius: borderRadius,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: Container(
            decoration: outlined
                ? BoxDecoration(
                    border: Border.all(color: cs.outline),
                    borderRadius: borderRadius,
                  )
                : null,
            child: Center(
              child: IconTheme(
                data: IconThemeData(color: fg, size: iconSize),
                child: icon,
              ),
            ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
