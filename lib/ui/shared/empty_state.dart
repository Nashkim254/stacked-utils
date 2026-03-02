import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'gap.dart';

/// Generic empty-state widget shown when a list/page has no content.
///
/// ```dart
/// EmptyState(
///   icon: Icons.inbox_outlined,
///   message: 'No transactions yet',
///   subMessage: 'Your completed transactions will appear here.',
///   onRetry: viewModel.loadTransactions,
///   retryLabel: 'Refresh',
/// )
/// ```
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? subMessage;
  final VoidCallback? onRetry;
  final String retryLabel;

  const EmptyState({
    required this.icon,
    required this.message,
    this.subMessage,
    this.onRetry,
    this.retryLabel = 'Try again',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.grey300),
            const Gap(AppSpacing.md),
            Text(
              message,
              style: AppTextStyles.h3.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (subMessage != null) ...[
              const Gap(AppSpacing.xs),
              Text(
                subMessage!,
                style: AppTextStyles.body.copyWith(color: AppColors.grey400),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const Gap(AppSpacing.lg),
              OutlinedButton(
                onPressed: onRetry,
                child: Text(retryLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
