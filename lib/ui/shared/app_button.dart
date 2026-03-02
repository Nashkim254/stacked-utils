import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_text_styles.dart';
import 'gap.dart';

enum ButtonVariant { primary, secondary, outline, ghost, danger }

enum ButtonSize { sm, md, lg }

/// Production-ready button with full variant, size, busy, and icon support.
///
/// ```dart
/// AppButton(
///   label: 'Sign In',
///   onTap: viewModel.login,
///   busy: viewModel.isBusy,
/// )
///
/// AppButton(
///   label: 'Delete',
///   variant: ButtonVariant.danger,
///   icon: Icon(Icons.delete_outline),
/// )
/// ```
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool busy;
  final bool disabled;
  final Widget? icon;
  final bool iconRight;
  final double? width;

  const AppButton({
    required this.label,
    this.onTap,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.md,
    this.busy = false,
    this.disabled = false,
    this.icon,
    this.iconRight = false,
    this.width,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDisabled = disabled || busy;

    final (Color bg, Color fg, Color border) = switch (variant) {
      ButtonVariant.primary => (cs.primary, cs.onPrimary, Colors.transparent),
      ButtonVariant.secondary => (
          cs.secondary,
          cs.onSecondary,
          Colors.transparent
        ),
      ButtonVariant.outline => (Colors.transparent, cs.primary, cs.primary),
      ButtonVariant.ghost => (
          Colors.transparent,
          cs.primary,
          Colors.transparent
        ),
      ButtonVariant.danger => (
          AppColors.error,
          AppColors.surface,
          Colors.transparent
        ),
    };

    final (double height, double fontSize, double iconSize) = switch (size) {
      ButtonSize.sm => (36.0, 13.0, 16.0),
      ButtonSize.md => (48.0, 15.0, 20.0),
      ButtonSize.lg => (56.0, 17.0, 22.0),
    };

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: Material(
        color: isDisabled ? bg.withOpacity(0.5) : bg,
        borderRadius: AppRadius.buttonBR,
        child: InkWell(
          borderRadius: AppRadius.buttonBR,
          onTap: isDisabled ? null : onTap,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isDisabled ? border.withOpacity(0.5) : border,
                width: 1.5,
              ),
              borderRadius: AppRadius.buttonBR,
            ),
            child: _buildChild(fg, fontSize, iconSize),
          ),
        ),
      ),
    );
  }

  Widget _buildChild(Color fg, double fontSize, double iconSize) {
    if (busy) {
      return Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: fg),
        ),
      );
    }

    final labelWidget = Text(
      label,
      style: AppTextStyles.label.copyWith(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: fg,
      ),
    );

    if (icon == null) return Center(child: labelWidget);

    final iconWidget = SizedBox(width: iconSize, height: iconSize, child: icon);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: iconRight
          ? [labelWidget, const Gap.h(8), iconWidget]
          : [iconWidget, const Gap.h(8), labelWidget],
    );
  }
}
