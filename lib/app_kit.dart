/// app_kit — A repository of production-ready utilities, widgets, theming,
/// and Stacked base classes for Flutter teams.
library app_kit;

// ── Core — Utils ─────────────────────────────────────────────────────────────
export 'core/utils/result.dart';
export 'core/utils/validators.dart';
export 'core/utils/debouncer.dart';

// ── Core — Extensions ────────────────────────────────────────────────────────
export 'core/extensions/viewmodel_extensions.dart';
export 'core/extensions/locator_helper.dart';
export 'core/extensions/string_extensions.dart';
export 'core/extensions/datetime_extensions.dart';
export 'core/extensions/num_extensions.dart';
export 'core/extensions/list_extensions.dart';
export 'core/extensions/color_extensions.dart';

// ── Core — Mixins ────────────────────────────────────────────────────────────
export 'core/mixins/common_viewmodel_mixin.dart';
export 'core/mixins/pagination_mixin.dart';
export 'core/mixins/form_mixin.dart';
export 'core/mixins/infinite_scroll_mixin.dart';

// ── Core — Services ──────────────────────────────────────────────────────────
export 'core/services/base_api_service.dart';
export 'core/services/storage_service.dart';
export 'core/services/secure_storage_service.dart';
export 'core/services/connectivity_service.dart';

// ── UI — Constants ───────────────────────────────────────────────────────────
export 'ui/constants/app_colors.dart';
export 'ui/constants/app_spacing.dart';
export 'ui/constants/app_radius.dart';
export 'ui/constants/app_text_styles.dart';

// ── UI — Theme ───────────────────────────────────────────────────────────────
export 'ui/theme/app_theme.dart';

// ── UI — Utils / Extensions ──────────────────────────────────────────────────
export 'ui/utils/context_extensions.dart';
export 'ui/utils/widget_extensions.dart';
export 'ui/utils/text_style_extensions.dart';
export 'ui/utils/responsive.dart';

// ── UI — Shared Widgets ──────────────────────────────────────────────────────
export 'ui/shared/gap.dart';
export 'ui/shared/show_if.dart';
export 'ui/shared/busy_overlay.dart';
export 'ui/shared/empty_state.dart';
export 'ui/shared/error_view.dart';
export 'ui/shared/shimmer_box.dart';
export 'ui/shared/app_text_field.dart';
export 'ui/shared/app_button.dart';
export 'ui/shared/app_icon_button.dart';
export 'ui/shared/app_card.dart';
export 'ui/shared/app_badge.dart';
export 'ui/shared/app_avatar.dart';
export 'ui/shared/app_divider.dart';
export 'ui/shared/app_bottom_sheet.dart';
export 'ui/shared/status_chip.dart';
export 'ui/shared/app_search_field.dart';
export 'ui/shared/app_list_tile.dart';
export 'ui/shared/app_network_image.dart';
export 'ui/shared/app_dropdown.dart';
export 'ui/shared/app_select_search.dart';
export 'ui/shared/app_otp_field.dart';
export 'ui/shared/app_multi_select.dart';
export 'ui/shared/app_expandable.dart';
export 'ui/shared/app_chip_group.dart';
export 'ui/shared/app_read_more_text.dart';
export 'ui/shared/app_dialog.dart';
