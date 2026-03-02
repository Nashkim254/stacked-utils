import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

/// A divider with an optional centered label — useful for separating sections
/// or showing "OR" between form options.
///
/// ```dart
/// AppDivider()                       // plain divider
/// AppDivider(label: 'or')            // labeled
/// AppDivider(label: 'Filters', labelLeft: true)
/// ```
class AppDivider extends StatelessWidget {
  final String? label;
  final bool labelLeft;
  final Color? color;
  final double thickness;
  final double verticalSpacing;

  const AppDivider({
    this.label,
    this.labelLeft = false,
    this.color,
    this.thickness = 1,
    this.verticalSpacing = AppSpacing.md,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final lineColor = color ?? AppColors.grey200;
    final line = Expanded(
      child: Divider(color: lineColor, thickness: thickness, height: 1),
    );

    if (label == null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: verticalSpacing),
        child: Divider(color: lineColor, thickness: thickness),
      );
    }

    final labelWidget = Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Text(
        label!,
        style: AppTextStyles.caption.copyWith(color: AppColors.grey400),
      ),
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalSpacing),
      child: Row(
        children: labelLeft ? [labelWidget, line] : [line, labelWidget, line],
      ),
    );
  }
}
