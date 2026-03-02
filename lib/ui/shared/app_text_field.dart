import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A styled form text field that wraps [TextFormField] and eliminates
/// repetitive decoration boilerplate.
///
/// ```dart
/// AppTextField(
///   label: 'Email',
///   hint: 'you@example.com',
///   controller: _emailCtrl,
///   keyboardType: TextInputType.emailAddress,
///   validator: Validators.email,
/// )
/// ```
class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscure;
  final bool showClearButton;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final Widget? prefix;
  final Widget? suffix;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final bool readOnly;
  final int maxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool enabled;
  final String? initialValue;

  const AppTextField({
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.obscure = false,
    this.showClearButton = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.prefix,
    this.suffix,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.inputFormatters,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    this.initialValue,
    super.key,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  // Controls obscureText + the visibility icon. The whole TextFormField must
  // rebuild when this changes (obscureText / maxLines are top-level params),
  // so we wrap the field in a ValueListenableBuilder instead of setState.
  late final ValueNotifier<bool> _obscured;

  // Controls only the clear-button suffix icon. Scoped to a
  // ValueListenableBuilder inside the decoration — the TextFormField itself
  // never rebuilds just because the user typed a character.
  late final ValueNotifier<bool> _hasText;

  @override
  void initState() {
    super.initState();
    _obscured = ValueNotifier(widget.obscure);
    _hasText = ValueNotifier(
      (widget.controller?.text.isNotEmpty ?? false) ||
          (widget.initialValue?.isNotEmpty ?? false),
    );
    widget.controller?.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    _hasText.value = widget.controller!.text.isNotEmpty;
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChanged);
    _obscured.dispose();
    _hasText.dispose();
    super.dispose();
  }

  // Suffix icon for the password visibility toggle — lives inside the
  // ValueListenableBuilder<bool> that wraps the whole field, so `obscured`
  // is already the current value.
  Widget _visibilityIcon(bool obscured) => IconButton(
        icon: Icon(
          obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        ),
        onPressed: () => _obscured.value = !_obscured.value,
      );

  // Suffix icon for the clear button — only this tiny subtree rebuilds when
  // the user starts / stops typing.
  Widget _clearButtonIcon() => ValueListenableBuilder<bool>(
        valueListenable: _hasText,
        builder: (_, hasText, __) {
          if (hasText && widget.controller != null) {
            return IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () {
                widget.controller!.clear();
                widget.onChanged?.call('');
              },
            );
          }
          return widget.suffixIcon ?? const SizedBox.shrink();
        },
      );

  @override
  Widget build(BuildContext context) {
    // Wrap in ValueListenableBuilder so obscureText / maxLines stay in sync
    // without setState. Only rebuilds when the visibility toggle is tapped.
    return ValueListenableBuilder<bool>(
      valueListenable: _obscured,
      builder: (context, obscured, _) {
        return TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          validator: widget.validator,
          obscureText: obscured,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          maxLines: obscured ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          onChanged: (v) {
            if (widget.showClearButton) _hasText.value = v.isNotEmpty;
            widget.onChanged?.call(v);
          },
          onEditingComplete: widget.onEditingComplete,
          onFieldSubmitted: widget.onSubmitted,
          inputFormatters: widget.inputFormatters,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            prefix: widget.prefix,
            suffix: widget.suffix,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.obscure
                ? _visibilityIcon(obscured)
                : widget.showClearButton
                    ? _clearButtonIcon()
                    : widget.suffixIcon,
            counterText: widget.maxLength != null ? null : '',
          ),
        );
      },
    );
  }
}
