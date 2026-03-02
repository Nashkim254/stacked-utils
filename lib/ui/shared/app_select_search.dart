import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

/// A searchable select field. Typing filters [items] in real-time and shows
/// matching results in an overlay dropdown below the field. Selecting an item
/// commits the choice; tapping the clear button resets it.
///
/// All filtering is local — pass the full [items] list and the widget does the
/// rest. For server-driven search, update [items] from your ViewModel in
/// response to [onSearchChanged].
///
/// ```dart
/// AppSelectSearch<Country>(
///   label: 'Country',
///   items: countries,
///   displayLabel: (c) => c.name,
///   value: viewModel.country,
///   onSelected: viewModel.setCountry,
///   validator: (v) => v == null ? 'Select a country' : null,
/// )
/// ```
class AppSelectSearch<T> extends StatefulWidget {
  final String label;
  final String? hint;

  /// The full list of items to search through.
  final List<T> items;

  /// Converts an item to the string shown in the field and dropdown.
  final String Function(T) displayLabel;

  /// Currently selected item (for external control / form restore).
  final T? value;

  /// Called when the user selects an item. Passes `null` when cleared.
  final ValueChanged<T?> onSelected;

  /// Called on every keystroke — useful for server-driven search where you
  /// update [items] externally. Optional.
  final ValueChanged<String>? onSearchChanged;

  final String? Function(T?)? validator;
  final bool enabled;
  final Widget? prefixIcon;
  final String noResultsText;
  final double maxDropdownHeight;

  const AppSelectSearch({
    required this.label,
    required this.items,
    required this.displayLabel,
    required this.onSelected,
    this.value,
    this.hint,
    this.onSearchChanged,
    this.validator,
    this.enabled = true,
    this.prefixIcon,
    this.noResultsText = 'No results found',
    this.maxDropdownHeight = 240,
    super.key,
  });

  @override
  State<AppSelectSearch<T>> createState() => _AppSelectSearchState<T>();
}

class _AppSelectSearchState<T> extends State<AppSelectSearch<T>> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _layerLink = LayerLink();

  OverlayEntry? _overlay;
  List<T> _filtered = [];
  late final ValueNotifier<T?> _selected;

  @override
  void initState() {
    super.initState();
    _selected = ValueNotifier(widget.value);
    if (_selected.value != null) {
      _controller.text = widget.displayLabel(_selected.value as T);
    }
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(AppSelectSearch<T> old) {
    super.didUpdateWidget(old);
    // Sync when value is changed externally (e.g. form reset).
    if (widget.value != old.value && widget.value != _selected.value) {
      _selected.value = widget.value;
      _controller.text =
          _selected.value != null ? widget.displayLabel(_selected.value as T) : '';
    }
    // Re-filter if the items list changes while overlay is open.
    if (widget.items != old.items && _overlay != null) {
      _applyFilter(_controller.text);
    }
  }

  // ── Focus ──────────────────────────────────────────────────────────────────

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _applyFilter(_controller.text);
      _showOverlay();
    } else {
      // Restore the committed selection label (or blank if nothing selected).
      _controller.text = _selected.value != null
          ? widget.displayLabel(_selected.value as T)
          : '';
      _hideOverlay();
    }
  }

  // ── Filtering ──────────────────────────────────────────────────────────────

  void _applyFilter(String query) {
    final q = query.trim().toLowerCase();
    _filtered = q.isEmpty
        ? List.of(widget.items)
        : widget.items
            .where((e) => widget.displayLabel(e).toLowerCase().contains(q))
            .toList();
    _overlay?.markNeedsBuild();
  }

  void _onChanged(String value) {
    widget.onSearchChanged?.call(value);
    _applyFilter(value);
  }

  // ── Selection ──────────────────────────────────────────────────────────────

  void _select(T item) {
    _selected.value = item;
    _controller.text = widget.displayLabel(item);
    widget.onSelected(item);
    _focusNode.unfocus(); // triggers _onFocusChanged → _hideOverlay
  }

  void _clear() {
    _selected.value = null;
    _controller.clear();
    widget.onSelected(null);
    if (_focusNode.hasFocus) _applyFilter('');
  }

  // ── Overlay ────────────────────────────────────────────────────────────────

  void _showOverlay() {
    _hideOverlay();
    final box = context.findRenderObject()! as RenderBox;
    final width = box.size.width;
    _overlay = OverlayEntry(builder: (ctx) => _buildOverlay(ctx, width));
    Overlay.of(context).insert(_overlay!);
  }

  void _hideOverlay() {
    _overlay?.remove();
    _overlay?.dispose();
    _overlay = null;
  }

  Widget _buildOverlay(BuildContext ctx, double width) {
    final isLight = Theme.of(ctx).brightness == Brightness.light;

    return Stack(
      children: [
        CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(0, 4),
          child: SizedBox(
            width: width,
            child: Material(
              elevation: 8,
              shadowColor: Colors.black26,
              borderRadius: AppRadius.inputBR,
              color: isLight ? AppColors.surface : AppColors.surfaceDark,
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(maxHeight: widget.maxDropdownHeight),
                child: _filtered.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Text(
                          widget.noResultsText,
                          style: AppTextStyles.body
                              .copyWith(color: AppColors.grey400),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xs),
                        shrinkWrap: true,
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) {
                          final item = _filtered[i];
                          return InkWell(
                            onTap: () => _select(item),
                            borderRadius: AppRadius.inputBR,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm + 2,
                              ),
                              child: Text(
                                widget.displayLabel(item),
                                style: AppTextStyles.body.copyWith(
                                  color: isLight
                                      ? AppColors.grey900
                                      : Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _controller.dispose();
    _selected.dispose();
    _hideOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cs = Theme.of(context).colorScheme;

    return CompositedTransformTarget(
      link: _layerLink,
      child: TapRegion(
        onTapOutside: (_) => _focusNode.unfocus(),
        child: TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          enabled: widget.enabled,
          onChanged: _onChanged,
          // Validate against the committed _selected, not the raw text.
          validator: (_) => widget.validator?.call(_selected.value),
          style: AppTextStyles.body.copyWith(
            color: isLight ? AppColors.grey900 : Colors.white,
          ),
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint ?? 'Search…',
            labelStyle: AppTextStyles.label.copyWith(
              color: isLight ? AppColors.grey600 : AppColors.grey400,
            ),
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.grey400),
            prefixIcon: widget.prefixIcon,
            suffixIcon: ValueListenableBuilder<T?>(
              valueListenable: _selected,
              builder: (_, value, __) => value != null
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      color: AppColors.grey400,
                      onPressed: _clear,
                    )
                  : Icon(
                      Icons.search_rounded,
                      color: isLight ? AppColors.grey500 : AppColors.grey400,
                      size: 20,
                    ),
            ),
            filled: true,
            fillColor: widget.enabled
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
            errorStyle: AppTextStyles.bodySm.copyWith(color: AppColors.error),
          ),
        ),
      ),
    );
  }
}
