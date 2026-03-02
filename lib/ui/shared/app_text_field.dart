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
  late bool _obscured;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscure;
    _hasText = (widget.controller?.text.isNotEmpty ?? false) ||
        (widget.initialValue?.isNotEmpty ?? false);
    widget.controller?.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    final hasText = widget.controller!.text.isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChanged);
    super.dispose();
  }

  Widget? get _suffixIcon {
    // Password field: visibility toggle takes priority
    if (widget.obscure) {
      return IconButton(
        icon: Icon(
          _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        ),
        onPressed: () => setState(() => _obscured = !_obscured),
      );
    }
    // Clear button when enabled and field has text
    if (widget.showClearButton && _hasText && widget.controller != null) {
      return IconButton(
        icon: const Icon(Icons.close_rounded),
        onPressed: () {
          widget.controller!.clear();
          widget.onChanged?.call('');
        },
      );
    }
    return widget.suffixIcon;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      initialValue: widget.initialValue,
      validator: widget.validator,
      obscureText: _obscured,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      maxLines: _obscured ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      onChanged: (v) {
        if (widget.showClearButton) {
          setState(() => _hasText = v.isNotEmpty);
        }
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
        suffixIcon: _suffixIcon,
        counterText: widget.maxLength != null ? null : '',
      ),
    );
  }
}
