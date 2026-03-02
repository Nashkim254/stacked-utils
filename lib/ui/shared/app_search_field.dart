import 'package:flutter/material.dart';

import '../../core/utils/debouncer.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_text_styles.dart';

/// A search input with built-in debounce, clear button, and optional
/// loading indicator. No boilerplate needed in the calling widget.
///
/// ```dart
/// AppSearchField(
///   hint: 'Search products…',
///   onChanged: viewModel.search,      // called after debounce
///   onCleared: viewModel.clearSearch,
/// )
/// ```
class AppSearchField extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final VoidCallback? onCleared;
  final String hint;
  final Duration debounceDuration;
  final bool isLoading;
  final TextEditingController? controller;
  final bool autofocus;

  const AppSearchField({
    this.onChanged,
    this.onCleared,
    this.hint = 'Search…',
    this.debounceDuration = const Duration(milliseconds: 500),
    this.isLoading = false,
    this.controller,
    this.autofocus = false,
    super.key,
  });

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late final TextEditingController _ctrl;
  late final Debouncer _debounce;
  bool _hasText = false;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _ctrl = widget.controller ?? TextEditingController();
    _debounce = Debouncer(delay: widget.debounceDuration);
    _ctrl.addListener(_onChanged);
  }

  void _onChanged() {
    final hasText = _ctrl.text.isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
    _debounce(() => widget.onChanged?.call(_ctrl.text));
  }

  void _clear() {
    _ctrl.clear();
    _debounce.cancel();
    widget.onChanged?.call('');
    widget.onCleared?.call();
  }

  @override
  void dispose() {
    _debounce.dispose();
    _ctrl.removeListener(_onChanged);
    if (_ownsController) _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: _ctrl,
      autofocus: widget.autofocus,
      textInputAction: TextInputAction.search,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.grey400),
        filled: true,
        fillColor: isDark ? AppColors.grey800 : AppColors.grey100,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: AppRadius.fullBR,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.fullBR,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.fullBR,
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1.5,
          ),
        ),
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.grey400),
        suffixIcon: widget.isLoading
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : _hasText
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    color: AppColors.grey400,
                    onPressed: _clear,
                  )
                : null,
      ),
    );
  }
}
