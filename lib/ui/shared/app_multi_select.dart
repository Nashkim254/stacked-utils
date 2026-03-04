import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

/// A styled multi-select field that opens a bottom-sheet picker with optional
/// search, checkboxes, "Select All" / "Clear" actions, and a "Done" button.
///
/// ```dart
/// AppMultiSelect<String>(
///   label: 'Countries',
///   items: const ['Nigeria', 'Ghana', 'Kenya'],
///   displayLabel: (c) => c,
///   values: viewModel.selected,
///   onChanged: viewModel.setSelected,
/// )
/// ```
class AppMultiSelect<T> extends StatefulWidget {
  /// Field label shown inside the styled input.
  final String label;

  /// Full list of selectable items.
  final List<T> items;

  /// Converts an item to a human-readable string.
  final String Function(T) displayLabel;

  /// Currently selected items (externally controlled).
  final List<T> values;

  /// Called when the user confirms their selection.
  final ValueChanged<List<T>> onChanged;

  /// Optional form validator; receives the current selection.
  final String? Function(List<T>?)? validator;

  /// Maximum number of items that may be selected simultaneously.
  /// `null` means no cap.
  final int? maxSelections;

  /// Whether the field accepts input.
  final bool enabled;

  /// Placeholder text shown when nothing is selected.
  final String hint;

  /// When true, a search field is shown inside the bottom sheet.
  final bool searchable;

  const AppMultiSelect({
    required this.label,
    required this.items,
    required this.displayLabel,
    required this.values,
    required this.onChanged,
    this.validator,
    this.maxSelections,
    this.enabled = true,
    this.hint = 'Select…',
    this.searchable = true,
    super.key,
  });

  @override
  State<AppMultiSelect<T>> createState() => _AppMultiSelectState<T>();
}

class _AppMultiSelectState<T> extends State<AppMultiSelect<T>> {
  // ── FormField integration ─────────────────────────────────────────────────

  /// We keep a [GlobalKey] so we can call [_formFieldKey.currentState!.validate()].
  final _formFieldKey = GlobalKey<FormFieldState<List<T>>>();

  // ── display helpers ───────────────────────────────────────────────────────

  String get _displayText {
    if (widget.values.isEmpty) return '';
    if (widget.values.length <= 2) {
      return widget.values.map(widget.displayLabel).join(', ');
    }
    return '${widget.values.length} selected';
  }

  // ── bottom sheet ──────────────────────────────────────────────────────────

  Future<void> _openSheet() async {
    if (!widget.enabled) return;

    final result = await showModalBottomSheet<List<T>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? AppColors.surface
          : AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (ctx) => _MultiSelectSheet<T>(
        items: widget.items,
        displayLabel: widget.displayLabel,
        initialValues: widget.values,
        maxSelections: widget.maxSelections,
        searchable: widget.searchable,
      ),
    );

    if (result != null) {
      widget.onChanged(result);
      // Re-validate the FormField after selection.
      _formFieldKey.currentState?.didChange(result);
    }
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    // final cs = Theme.of(context).colorScheme;

    final hasSelection = widget.values.isNotEmpty;

    return FormField<List<T>>(
      key: _formFieldKey,
      initialValue: widget.values,
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.disabled,
      builder: (state) {
        final hasError = state.hasError;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── tappable field ────────────────────────────────────────────
            GestureDetector(
              onTap: widget.enabled ? _openSheet : null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm + 2,
                ),
                decoration: BoxDecoration(
                  color: widget.enabled
                      ? (isLight ? AppColors.grey50 : AppColors.grey800)
                      : (isLight ? AppColors.grey100 : AppColors.grey700),
                  borderRadius: AppRadius.inputBR,
                  border: Border.all(
                    color: hasError
                        ? AppColors.error
                        : (isLight ? AppColors.grey200 : AppColors.borderDark),
                    width: hasError ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    // ── label + value column ──────────────────────────────
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Floating label
                          Text(
                            widget.label,
                            style: AppTextStyles.label.copyWith(
                              fontSize: 12,
                              color: hasError
                                  ? AppColors.error
                                  : (isLight
                                      ? AppColors.grey600
                                      : AppColors.grey400),
                            ),
                          ),
                          const SizedBox(height: 2),
                          // Value or hint
                          Text(
                            hasSelection ? _displayText : widget.hint,
                            style: AppTextStyles.body.copyWith(
                              color: hasSelection
                                  ? (isLight ? AppColors.grey900 : Colors.white)
                                  : AppColors.grey400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // ── trailing icons ────────────────────────────────────
                    if (hasSelection && widget.enabled)
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        color: AppColors.grey400,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          widget.onChanged([]);
                          state.didChange([]);
                        },
                      )
                    else
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: widget.enabled
                            ? (isLight ? AppColors.grey500 : AppColors.grey400)
                            : AppColors.grey300,
                      ),
                  ],
                ),
              ),
            ),

            // ── error text ────────────────────────────────────────────────
            if (hasError) ...[
              const SizedBox(height: AppSpacing.xs),
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.md),
                child: Text(
                  state.errorText!,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ],

            // ── hidden TextFormField for focused border cue ───────────────
            // We intentionally render the border ourselves above to support
            // the complex layout; the FormField above handles validation state.
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom-sheet body
// ─────────────────────────────────────────────────────────────────────────────

class _MultiSelectSheet<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) displayLabel;
  final List<T> initialValues;
  final int? maxSelections;
  final bool searchable;

  const _MultiSelectSheet({
    required this.items,
    required this.displayLabel,
    required this.initialValues,
    this.maxSelections,
    this.searchable = true,
    super.key,
  });

  @override
  State<_MultiSelectSheet<T>> createState() => _MultiSelectSheetState<T>();
}

class _MultiSelectSheetState<T> extends State<_MultiSelectSheet<T>> {
  /// Working copy of selected items — independent from the parent until Done.
  late final ValueNotifier<List<T>> _selected;

  /// Controls the search query filter.
  late final ValueNotifier<String> _query;

  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _selected = ValueNotifier(List<T>.from(widget.initialValues));
    _query = ValueNotifier('');
    _searchCtrl = TextEditingController();
    _searchCtrl.addListener(
      () => _query.value = _searchCtrl.text.trim().toLowerCase(),
    );
  }

  @override
  void dispose() {
    _selected.dispose();
    _query.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── filtered items ────────────────────────────────────────────────────────

  List<T> _filtered(String query) {
    if (query.isEmpty) return widget.items;
    return widget.items
        .where(
            (item) => widget.displayLabel(item).toLowerCase().contains(query))
        .toList();
  }

  // ── selection helpers ─────────────────────────────────────────────────────

  bool _isSelected(T item, List<T> current) => current.contains(item);

  void _toggle(T item, List<T> current) {
    final next = List<T>.from(current);
    if (next.contains(item)) {
      next.remove(item);
    } else {
      if (widget.maxSelections != null &&
          next.length >= widget.maxSelections!) {
        return; // cap reached — silently ignore
      }
      next.add(item);
    }
    _selected.value = next;
  }

  void _selectAll(List<T> filtered, List<T> current) {
    final next = List<T>.from(current);
    for (final item in filtered) {
      if (!next.contains(item)) {
        if (widget.maxSelections != null &&
            next.length >= widget.maxSelections!) {
          break;
        }
        next.add(item);
      }
    }
    _selected.value = next;
  }

  void _clearAll(List<T> filtered, List<T> current) {
    final next = List<T>.from(current)
      ..removeWhere((item) => filtered.contains(item));
    _selected.value = next;
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cs = Theme.of(context).colorScheme;
    final textColor = isLight ? AppColors.grey900 : Colors.white;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── drag handle ───────────────────────────────────────────────
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: AppRadius.fullBR,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── header row ────────────────────────────────────────────────
            ValueListenableBuilder<List<T>>(
              valueListenable: _selected,
              builder: (context, selected, _) {
                return ValueListenableBuilder<String>(
                  valueListenable: _query,
                  builder: (context, query, _) {
                    final filtered = _filtered(query);
                    final allFilteredSelected =
                        filtered.every((item) => selected.contains(item));

                    return Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Select items',
                              style:
                                  AppTextStyles.h3.copyWith(color: textColor),
                            ),
                          ),
                          TextButton(
                            onPressed: allFilteredSelected
                                ? () => _clearAll(filtered, selected)
                                : () => _selectAll(filtered, selected),
                            style: TextButton.styleFrom(
                              foregroundColor: cs.primary,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm),
                              visualDensity: VisualDensity.compact,
                            ),
                            child: Text(
                              allFilteredSelected ? 'Clear' : 'Select All',
                              style: AppTextStyles.label
                                  .copyWith(color: cs.primary),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),

            // ── search field ──────────────────────────────────────────────
            if (widget.searchable) ...[
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: TextField(
                  controller: _searchCtrl,
                  autofocus: false,
                  style: AppTextStyles.body.copyWith(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Search…',
                    hintStyle:
                        AppTextStyles.body.copyWith(color: AppColors.grey400),
                    filled: true,
                    fillColor: isLight ? AppColors.grey100 : AppColors.grey800,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
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
                      borderSide: BorderSide(color: cs.primary, width: 1.5),
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.grey400,
                    ),
                    suffixIcon: ValueListenableBuilder<String>(
                      valueListenable: _query,
                      builder: (_, q, __) => q.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              color: AppColors.grey400,
                              onPressed: () {
                                _searchCtrl.clear();
                              },
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.sm),

            // ── item list ─────────────────────────────────────────────────
            Flexible(
              child: ValueListenableBuilder<String>(
                valueListenable: _query,
                builder: (context, query, _) {
                  final filtered = _filtered(query);

                  if (filtered.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Center(
                        child: Text(
                          'No results found',
                          style: AppTextStyles.body
                              .copyWith(color: AppColors.grey400),
                        ),
                      ),
                    );
                  }

                  return ValueListenableBuilder<List<T>>(
                    valueListenable: _selected,
                    builder: (context, selected, _) {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final isChecked = _isSelected(item, selected);
                          final atCap = widget.maxSelections != null &&
                              selected.length >= widget.maxSelections! &&
                              !isChecked;

                          return CheckboxListTile(
                            value: isChecked,
                            onChanged:
                                atCap ? null : (_) => _toggle(item, selected),
                            title: Text(
                              widget.displayLabel(item),
                              style: AppTextStyles.body.copyWith(
                                color: atCap ? AppColors.grey400 : textColor,
                              ),
                            ),
                            activeColor: cs.primary,
                            checkColor: cs.onPrimary,
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),

            // ── Done button ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: ValueListenableBuilder<List<T>>(
                valueListenable: _selected,
                builder: (context, selected, _) {
                  return SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(selected),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.buttonBR,
                        ),
                        elevation: 0,
                        textStyle: AppTextStyles.label.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: Text(
                        selected.isEmpty ? 'Done' : 'Done (${selected.length})',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
