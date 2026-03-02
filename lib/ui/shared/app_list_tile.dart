import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

/// A consistent list tile that replaces [ListTile] boilerplate.
/// Supports leading widget, title, subtitle, trailing widget, chevron,
/// and an optional bottom divider.
///
/// ```dart
/// AppListTile(
///   title: 'Notifications',
///   leading: Icon(Icons.notifications_outlined),
///   showChevron: true,
///   onTap: viewModel.openNotifications,
/// )
///
/// AppListTile(
///   title: 'John Doe',
///   subtitle: 'john@example.com',
///   leading: AppAvatar(name: 'John Doe', size: 40),
///   trailing: StatusChip.active(),
/// )
/// ```
class AppListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;
  final bool showDivider;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const AppListTile({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.showChevron = false,
    this.showDivider = false,
    this.padding,
    this.backgroundColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    final tile = InkWell(
      onTap: onTap,
      child: Container(
        color: backgroundColor,
        padding: padding ??
            const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 4,
            ),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.sm),
              trailing!,
            ],
            if (showChevron) ...[
              const SizedBox(width: AppSpacing.xs),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: isLight ? AppColors.grey400 : AppColors.grey600,
              ),
            ],
          ],
        ),
      ),
    );

    if (showDivider) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          tile,
          Divider(
            height: 1,
            thickness: 1,
            indent: leading != null ? AppSpacing.md + 40 + AppSpacing.md : AppSpacing.md,
            color: isLight ? AppColors.grey200 : AppColors.borderDark,
          ),
        ],
      );
    }

    return tile;
  }
}
