import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_text_styles.dart';

enum BadgeVariant { success, warning, error, info, neutral, primary }

/// A semantic color-coded badge / chip.
///
/// ```dart
/// AppBadge(label: 'Active',  variant: BadgeVariant.success)
/// AppBadge(label: 'Pending', variant: BadgeVariant.warning)
/// AppBadge(label: 'Failed',  variant: BadgeVariant.error)
/// ```
class AppBadge extends StatelessWidget {
  final String label;
  final BadgeVariant variant;
  final Widget? icon;

  const AppBadge({
    required this.label,
    this.variant = BadgeVariant.neutral,
    this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (Color bg, Color fg) = switch (variant) {
      BadgeVariant.success => (AppColors.successLight, AppColors.success),
      BadgeVariant.warning => (AppColors.warningLight, AppColors.warning),
      BadgeVariant.error => (AppColors.errorLight, AppColors.error),
      BadgeVariant.info => (AppColors.infoLight, AppColors.info),
      BadgeVariant.primary => (cs.primaryContainer, cs.primary),
      BadgeVariant.neutral => (AppColors.grey100, AppColors.grey600),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.fullBR,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            IconTheme(data: IconThemeData(color: fg, size: 12), child: icon!),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
