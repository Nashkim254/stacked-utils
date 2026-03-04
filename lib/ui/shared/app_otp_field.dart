import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

/// A styled OTP / PIN input field built from individual single-character boxes.
///
/// Auto-advances focus on digit entry, auto-moves back on backspace, and
/// supports paste — distributing pasted digits across all boxes.
///
/// ```dart
/// AppOtpField(
///   length: 6,
///   onCompleted: (otp) => viewModel.verify(otp),
///   onChanged: (partial) => viewModel.onOtpChanged(partial),
/// )
/// ```
class AppOtpField extends StatefulWidget {
  /// Number of digit boxes. Defaults to 6.
  final int length;

  /// Called when all boxes are filled. Receives the full OTP string.
  final ValueChanged<String>? onCompleted;

  /// Called on every change with the partial OTP string assembled so far
  /// (empty boxes contribute an empty string to the join).
  final ValueChanged<String>? onChanged;

  /// When true each character is obscured (useful for PIN entry).
  final bool obscureText;

  /// Whether the field accepts input.
  final bool enabled;

  /// Validates the full assembled OTP string. Integrate with [Form].
  final String? Function(String?)? validator;

  const AppOtpField({
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.obscureText = false,
    this.enabled = true,
    this.validator,
    super.key,
  }) : assert(length > 0, 'length must be at least 1');

  @override
  State<AppOtpField> createState() => _AppOtpFieldState();
}

class _AppOtpFieldState extends State<AppOtpField> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  /// Single source of truth for all box values; drives callbacks + validator.
  late final ValueNotifier<List<String>> _values;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
    _values = ValueNotifier(List.filled(widget.length, ''));
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _values.dispose();
    super.dispose();
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  String get _assembled => _values.value.join();

  void _updateValues(int index, String digit) {
    final next = List<String>.from(_values.value);
    next[index] = digit;
    _values.value = next;
    widget.onChanged?.call(next.join());
    if (next.every((v) => v.isNotEmpty)) {
      widget.onCompleted?.call(next.join());
    }
  }

  void _focusAt(int index) {
    if (index >= 0 && index < widget.length) {
      _focusNodes[index].requestFocus();
    }
  }

  /// Distribute [text] (e.g. pasted OTP) across boxes starting at [startIndex].
  void _distributePaste(String text, int startIndex) {
    final digits = text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;

    final next = List<String>.from(_values.value);
    int boxIdx = startIndex;
    for (int i = 0; i < digits.length && boxIdx < widget.length; i++, boxIdx++) {
      next[boxIdx] = digits[i];
      _controllers[boxIdx].text = digits[i];
      _controllers[boxIdx].selection =
          TextSelection.collapsed(offset: 1);
    }
    _values.value = next;
    widget.onChanged?.call(next.join());

    // Move focus to the box after the last pasted digit (or last box).
    final nextFocus = (boxIdx < widget.length) ? boxIdx : widget.length - 1;
    _focusAt(nextFocus);

    if (next.every((v) => v.isNotEmpty)) {
      widget.onCompleted?.call(next.join());
    }
  }

  // ── per-box key handler ───────────────────────────────────────────────────

  KeyEventResult _handleKey(int index, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isNotEmpty) {
        // Clear this box.
        _controllers[index].clear();
        _updateValues(index, '');
      } else if (index > 0) {
        // Move back and clear the previous box.
        _controllers[index - 1].clear();
        _updateValues(index - 1, '');
        _focusAt(index - 1);
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  // ── box builder ───────────────────────────────────────────────────────────

  Widget _buildBox(BuildContext context, int index, bool isLight) {
    final cs = Theme.of(context).colorScheme;

    return KeyboardListener(
      focusNode: FocusNode(skipTraversal: true),
      onKeyEvent: (event) => _handleKey(index, event),
      child: SizedBox(
        width: 48,
        height: 56,
        child: TextFormField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          enabled: widget.enabled,
          obscureText: widget.obscureText,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: AppTextStyles.h3.copyWith(
            color: isLight ? AppColors.grey900 : Colors.white,
            letterSpacing: 0,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          // Use validator only on the last box so Form.validate() works.
          validator: index == widget.length - 1
              ? (_) => widget.validator?.call(_assembled)
              : null,
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            filled: true,
            fillColor: widget.enabled
                ? (isLight ? AppColors.grey50 : AppColors.grey800)
                : (isLight ? AppColors.grey100 : AppColors.grey700),
            border: OutlineInputBorder(
              borderRadius: AppRadius.inputBR,
              borderSide: BorderSide(
                color: isLight ? AppColors.grey200 : AppColors.borderDark,
              ),
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
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppRadius.inputBR,
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.inputBR,
              borderSide: BorderSide(
                color: isLight
                    ? AppColors.grey200.withOpacity(0.5)
                    : AppColors.borderDark.withOpacity(0.5),
              ),
            ),
            errorStyle: AppTextStyles.bodySm.copyWith(
              color: AppColors.error,
              // Hide per-box error text — only the assembled value error matters.
              height: 0,
              fontSize: 0,
            ),
          ),
          onChanged: (value) {
            if (value.length > 1) {
              // Handles paste that arrives through onChanged on some platforms.
              _distributePaste(value, index);
              return;
            }
            if (value.isEmpty) {
              _updateValues(index, '');
              return;
            }
            // Single digit entered — record and advance.
            _updateValues(index, value);
            if (index < widget.length - 1) {
              _focusAt(index + 1);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return ValueListenableBuilder<List<String>>(
      valueListenable: _values,
      builder: (context, values, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.length, (i) {
            return Padding(
              padding: EdgeInsets.only(
                right: i < widget.length - 1 ? AppSpacing.sm : 0,
              ),
              child: _buildBox(context, i, isLight),
            );
          }),
        );
      },
    );
  }
}
