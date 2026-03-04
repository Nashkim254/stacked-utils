import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'app_button.dart';
import 'gap.dart';

/// A consistently-styled dialog widget with [show], [confirm], and [alert]
/// static helpers.
///
/// ```dart
/// // Simple informational dialog
/// await AppDialog.show(context, title: 'Notice', content: 'Your session expires soon.');
///
/// // Confirm dialog — returns true when the user confirms
/// final confirmed = await AppDialog.confirm(
///   context,
///   title: 'Delete item?',
///   content: 'This action cannot be undone.',
///   destructive: true,
/// );
/// if (confirmed) viewModel.delete();
///
/// // Alert dialog
/// await AppDialog.alert(context, title: 'Error', content: error.message);
/// ```
class AppDialog extends StatelessWidget {
  /// Optional dialog title.
  final String? title;

  /// Optional body text (used when [body] is null).
  final String? content;

  /// Custom body widget — replaces [content] text when provided.
  final Widget? body;

  /// Action buttons shown at the bottom.  When null a single "Close" button
  /// is rendered automatically.
  final List<Widget>? actions;

  /// Whether tapping the barrier dismisses the dialog.
  final bool barrierDismissible;

  const AppDialog({
    this.title,
    this.content,
    this.body,
    this.actions,
    this.barrierDismissible = true,
    super.key,
  });

  // ── Static helpers ──────────────────────────────────────────────────────────

  /// Shows a generic informational dialog.
  static Future<void> show(
    BuildContext context, {
    String? title,
    String? content,
    Widget? body,
    List<Widget>? actions,
    bool barrierDismissible = true,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => AppDialog(
        title: title,
        content: content,
        body: body,
        actions: actions,
        barrierDismissible: barrierDismissible,
      ),
    );
  }

  /// Shows a confirm/cancel dialog.  Returns [true] if the user presses the
  /// confirm button; [false] otherwise (including barrier dismiss).
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    String? content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AppDialog(
        title: title,
        content: content,
        actions: [
          AppButton(
            label: cancelText,
            variant: ButtonVariant.outline,
            onTap: () => Navigator.of(ctx).pop(false),
          ),
          AppButton(
            label: confirmText,
            variant: destructive ? ButtonVariant.danger : ButtonVariant.primary,
            onTap: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Shows an alert/error dialog with a single dismiss button.
  static Future<void> alert(
    BuildContext context, {
    required String title,
    String? content,
    String buttonText = 'OK',
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AppDialog(
        title: title,
        content: content,
        actions: [
          AppButton(
            label: buttonText,
            onTap: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    // final cs = Theme.of(context).colorScheme;

    final dialogBg = isLight ? AppColors.surface : AppColors.surfaceDark;
    final borderColor = isLight ? AppColors.border : AppColors.borderDark;

    return Dialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgBR,
        side: BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Title ──────────────────────────────────────────────────
            if (title != null) ...[
              Text(
                title!,
                style: AppTextStyles.h3.copyWith(
                  color: isLight ? AppColors.grey900 : Colors.white,
                ),
              ),
              const Gap.v(AppSpacing.sm),
            ],

            // ── Body / Content ─────────────────────────────────────────
            if (body != null)
              body!
            else if (content != null)
              Text(
                content!,
                style: AppTextStyles.body.copyWith(
                  color: isLight ? AppColors.grey600 : AppColors.grey400,
                ),
              ),

            const Gap.v(AppSpacing.lg),

            // ── Actions ────────────────────────────────────────────────
            if (actions != null && actions!.isNotEmpty)
              _buildActions(actions!)
            else
              AppButton(
                label: 'Close',
                variant: ButtonVariant.outline,
                onTap: () => Navigator.of(context).pop(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(List<Widget> actions) {
    if (actions.length == 1) {
      return actions.first;
    }

    // Two or more actions: lay them out in a row with equal flex.
    return Row(
      children: [
        for (int i = 0; i < actions.length; i++) ...[
          if (i > 0) const Gap.h(AppSpacing.sm),
          Expanded(child: actions[i]),
        ],
      ],
    );
  }
}
