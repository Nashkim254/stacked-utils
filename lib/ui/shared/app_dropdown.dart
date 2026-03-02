import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_text_styles.dart';

/// A styled dropdown / select field that matches [AppTextField] visually
/// and integrates with [Form] validation.
///
/// ```dart
/// AppDropdown<String>(
///   label: 'Country',
///   value: viewModel.country,
///   items: const ['Nigeria', 'Ghana', 'Kenya']
///       .map((c) => DropdownMenuItem(value: c, child: Text(c)))
///       .toList(),
///   onChanged: (v) => viewModel.setCountry(v),
///   validator: (v) => v == null ? 'Please select a country' : null,
/// )
/// ```
class AppDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final String? hint;
  final bool enabled;
  final Widget? prefixIcon;

  const AppDropdown({
    required this.label,
    required this.items,
    this.value,
    this.onChanged,
    this.validator,
    this.hint,
    this.enabled = true,
    this.prefixIcon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cs = Theme.of(context).colorScheme;

    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      style: AppTextStyles.body.copyWith(
        color: isLight ? AppColors.grey900 : Colors.white,
      ),
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: isLight ? AppColors.grey500 : AppColors.grey400,
      ),
      dropdownColor: isLight ? AppColors.surface : AppColors.surfaceDark,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: AppTextStyles.label.copyWith(
          color: isLight ? AppColors.grey600 : AppColors.grey400,
        ),
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.grey400),
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: enabled
            ? (isLight ? AppColors.grey50 : AppColors.grey800)
            : (isLight ? AppColors.grey100 : AppColors.grey700),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: AppRadius.inputBR,
          borderSide: const BorderSide(color: AppColors.grey200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBR,
          borderSide: BorderSide(
            color: isLight ? AppColors.grey200 : AppColors.borderDark,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBR,
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBR,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBR,
          borderSide: BorderSide(
            color: isLight
                ? AppColors.grey200.withOpacity(0.5)
                : AppColors.borderDark.withOpacity(0.5),
          ),
        ),
        errorStyle: AppTextStyles.bodySm.copyWith(color: AppColors.error),
      ),
    );
  }
}
