import 'package:stacked/stacked.dart';

/// Adds standard pagination state to any [BaseViewModel].
///
/// ```dart
/// class PostsViewModel extends BaseViewModel with PaginationMixin {
///   final List<Post> posts = [];
///
///   Future<void> init() => loadFirstPage(
///     fetcher: (page) => _postService.getPosts(page: page),
///     onSuccess: (items) => posts.addAll(items),
///   );
///
///   Future<void> loadMore() => loadNextPage(
///     fetcher: (page) => _postService.getPosts(page: page),
///     onSuccess: (items) => posts.addAll(items),
///   );
/// }
/// ```
mixin PaginationMixin on BaseViewModel {
  int _page = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  int get currentPage => _page;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  int pageSize = 20;

  /// Resets pagination state. Call before re-fetching from scratch.
  void resetPagination() {
    _page = 1;
    _hasMore = true;
    _isLoadingMore = false;
  }

  /// Loads the first page, resetting pagination state first.
  /// Sets the ViewModel as busy while loading.
  Future<void> loadFirstPage<T>({
    required Future<List<T>> Function(int page) fetcher,
    required void Function(List<T> items) onSuccess,
    void Function(String error)? onError,
  }) async {
    resetPagination();
    setBusy(true);
    notifyListeners();
    try {
      final items = await fetcher(_page);
      _hasMore = items.length >= pageSize;
      onSuccess(items);
    } catch (e) {
      final msg = e.toString();
      setError(msg);
      onError?.call(msg);
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  /// Loads the next page. No-op if [hasMore] is false or already loading.
  Future<void> loadNextPage<T>({
    required Future<List<T>> Function(int page) fetcher,
    required void Function(List<T> items) onSuccess,
    void Function(String error)? onError,
  }) async {
    if (!_hasMore || _isLoadingMore || isBusy) return;

    _isLoadingMore = true;
    notifyListeners();
    try {
      _page++;
      final items = await fetcher(_page);
      if (items.length < pageSize) _hasMore = false;
      onSuccess(items);
    } catch (e) {
      _page--; // roll back on failure
      final msg = e.toString();
      setError(msg);
      onError?.call(msg);
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}
