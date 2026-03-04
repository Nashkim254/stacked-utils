import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

/// Mix into a [BaseViewModel] alongside [PaginationMixin] to get automatic
/// infinite-scroll detection.
///
/// ```dart
/// class PostsViewModel extends BaseViewModel
///     with InfiniteScrollMixin, PaginationMixin {
///   @override
///   void onEndReached() {
///     if (!hasMore || isBusy) return;
///     loadNextPage(fetchPage);
///   }
/// }
/// ```
/// Attach [scrollController] to the scrollable widget.
mixin InfiniteScrollMixin on BaseViewModel {
  late final ScrollController scrollController =
      ScrollController()..addListener(_onScroll);

  /// Distance from the bottom of the scrollable (in logical pixels) at which
  /// [onEndReached] fires.
  double scrollThreshold = 200.0;

  bool _endReachedScheduled = false;

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final position = scrollController.position;
    final distanceFromBottom =
        position.maxScrollExtent - position.pixels;
    if (distanceFromBottom <= scrollThreshold &&
        !isBusy &&
        !_endReachedScheduled) {
      _endReachedScheduled = true;
      onEndReached();
    }
  }

  /// Override to load the next page of data.
  void onEndReached();

  /// Resets the end-reached guard so [onEndReached] can fire again.
  /// Call this after a page load completes (success or error).
  void resetScrollState() {
    _endReachedScheduled = false;
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
