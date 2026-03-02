import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'gap.dart';

/// Full-page error widget with a retry action.
///
/// ```dart
/// if (viewModel.hasError)
///   ErrorView(
///     message: viewModel.modelError,
///     onRetry: viewModel.retry,
///   )
/// ```
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  const ErrorView({
    required this.message,
    this.onRetry,
    this.retryLabel = 'Retry',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: AppColors.error,
            ),
            const Gap(AppSpacing.md),
            Text(
              'Something went wrong',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const Gap(AppSpacing.xs),
            Text(
              message,
              style: AppTextStyles.body.copyWith(color: AppColors.grey500),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const Gap(AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(retryLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
