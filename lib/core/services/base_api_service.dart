import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../utils/result.dart';

// ── Paginated response wrapper ─────────────────────────────────────────────────

/// Holds a single page of results plus the pagination metadata returned by the
/// server.
///
/// Matches the common `{ "data": [...], "meta": { "total": 100, ... } }` shape.
/// The keys are configurable via [BaseApiService.safeCallPaginated].
class PagedResult<T> {
  final List<T> data;
  final int total;
  final int page;
  final int perPage;
  final int lastPage;

  const PagedResult({
    required this.data,
    required this.total,
    required this.page,
    required this.perPage,
    required this.lastPage,
  });

  bool get hasNextPage => page < lastPage;
  bool get isFirstPage => page == 1;
  bool get isLastPage => page >= lastPage;

  /// Returns a new [PagedResult] with the data list transformed by [transform].
  PagedResult<R> mapData<R>(R Function(T) transform) => PagedResult(
        data: data.map(transform).toList(),
        total: total,
        page: page,
        perPage: perPage,
        lastPage: lastPage,
      );

  @override
  String toString() =>
      'PagedResult(page: $page/$lastPage, total: $total, count: ${data.length})';
}

// ── Base service ───────────────────────────────────────────────────────────────

/// Base class for all API services. Subclass this and inject a [Dio] instance.
///
/// All methods return [Result<T>] — ViewModels never need to catch raw
/// exceptions.
///
/// ```dart
/// class AuthService extends BaseApiService {
///   AuthService(super.dio);
///
///   Future<Result<User>> login(String email, String password) =>
///       safeCall(
///         () => dio.post('/auth/login', data: {'email': email, 'password': password}),
///         User.fromJson,
///       );
///
///   Future<Result<void>> logout() =>
///       safeCallVoid(() => dio.post('/auth/logout'));
/// }
/// ```
abstract class BaseApiService {
  final Dio dio;

  const BaseApiService(this.dio);

  // ── Single object ────────────────────────────────────────────────────────────

  /// Executes [call] and maps the response body through [fromJson].
  ///
  /// Handles `{ "data": { ... } }` envelope automatically when
  /// [unwrapDataKey] is provided.
  Future<Result<T>> safeCall<T>(
    Future<Response<dynamic>> Function() call,
    T Function(Map<String, dynamic> json) fromJson, {
    String? unwrapDataKey,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await call();
      final body = _unwrap(response.data, unwrapDataKey);
      if (body is Map<String, dynamic>) {
        return Result.success(fromJson(body));
      }
      return Result.failure('Unexpected response format');
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) return Result.failure('Request cancelled');
      return Result.failure(parseError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  // ── List ─────────────────────────────────────────────────────────────────────

  /// Executes [call] and maps the response body through [fromJson] for each
  /// item.
  ///
  /// Handles `{ "data": [ ... ] }` envelope automatically when
  /// [unwrapDataKey] is provided.
  Future<Result<List<T>>> safeCallList<T>(
    Future<Response<dynamic>> Function() call,
    T Function(Map<String, dynamic> json) fromJson, {
    String? unwrapDataKey,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await call();
      final body = _unwrap(response.data, unwrapDataKey);
      if (body is List) {
        return Result.success(
          body.cast<Map<String, dynamic>>().map(fromJson).toList(),
        );
      }
      return Result.failure('Expected a list response');
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) return Result.failure('Request cancelled');
      return Result.failure(parseError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  // ── Void (no body) ───────────────────────────────────────────────────────────

  /// Executes [call] and returns [Result.success(null)] for any 2xx response,
  /// including `204 No Content`.
  ///
  /// Use for DELETE, or POST/PUT endpoints that return no body.
  Future<Result<void>> safeCallVoid(
    Future<Response<dynamic>> Function() call, {
    CancelToken? cancelToken,
  }) async {
    try {
      await call();
      return const Result.success(null);
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) return Result.failure('Request cancelled');
      return Result.failure(parseError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  // ── Paginated ─────────────────────────────────────────────────────────────────

  /// Executes [call] and maps a paginated response.
  ///
  /// Expects `{ "[dataKey]": [...], "[metaKey]": { "total": n, ... } }`.
  ///
  /// Supported meta field names (checked in order):
  /// - `total` — total record count
  /// - `current_page` / `page` — current page number
  /// - `per_page` / `limit` — records per page
  /// - `last_page` / `total_pages` / `pages` — last page number
  Future<Result<PagedResult<T>>> safeCallPaginated<T>(
    Future<Response<dynamic>> Function() call,
    T Function(Map<String, dynamic> json) fromJson, {
    String dataKey = 'data',
    String metaKey = 'meta',
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await call();
      final body = response.data;

      if (body is! Map<String, dynamic>) {
        return Result.failure('Expected a map response for paginated call');
      }

      final rawItems = body[dataKey];
      if (rawItems is! List) {
        return Result.failure('Expected "$dataKey" to be a list');
      }

      final meta = (body[metaKey] as Map<String, dynamic>?) ?? {};
      final items = rawItems.cast<Map<String, dynamic>>().map(fromJson).toList();

      final total = _metaInt(meta, ['total', 'count']) ?? items.length;
      final page = _metaInt(meta, ['current_page', 'page']) ?? 1;
      final perPage = _metaInt(meta, ['per_page', 'limit']) ?? items.length;
      final lastPage =
          _metaInt(meta, ['last_page', 'total_pages', 'pages']) ??
              (perPage > 0 ? (total / perPage).ceil() : 1);

      return Result.success(PagedResult(
        data: items,
        total: total,
        page: page,
        perPage: perPage,
        lastPage: lastPage,
      ));
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) return Result.failure('Request cancelled');
      return Result.failure(parseError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  // ── Upload ────────────────────────────────────────────────────────────────────

  /// Executes [call] (expected to contain [FormData]) and maps the response
  /// body through [fromJson].
  ///
  /// Use [onSendProgress] to drive a progress indicator.
  ///
  /// ```dart
  /// safeUpload(
  ///   () => dio.post(
  ///     '/upload',
  ///     data: FormData.fromMap({'file': await MultipartFile.fromFile(path)}),
  ///     onSendProgress: (sent, total) => viewModel.setProgress(sent / total),
  ///   ),
  ///   UploadResponse.fromJson,
  /// );
  /// ```
  Future<Result<T>> safeUpload<T>(
    Future<Response<dynamic>> Function() call,
    T Function(Map<String, dynamic> json) fromJson, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await call();
      final body = response.data;
      if (body is Map<String, dynamic>) {
        return Result.success(fromJson(body));
      }
      return Result.failure('Unexpected upload response format');
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) return Result.failure('Request cancelled');
      return Result.failure(parseError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  // ── Error parsing ─────────────────────────────────────────────────────────────

  /// Override this to handle your API's custom error shape.
  ///
  /// ```dart
  /// @override
  /// String parseError(DioException e) {
  ///   final errors = e.response?.data?['errors'] as List?;
  ///   if (errors != null) return errors.map((e) => e['message']).join(', ');
  ///   return super.parseError(e);
  /// }
  /// ```
  @protected
  String parseError(DioException e) {
    final data = e.response?.data;

    // Structured error body — try common field names
    if (data is Map) {
      final msg = data['message'] ??
          data['error'] ??
          data['detail'] ??
          data['msg'];
      if (msg != null) return msg.toString();

      // Array of validation errors: { errors: ["field is required", ...] }
      final errors = data['errors'];
      if (errors is List && errors.isNotEmpty) {
        return errors
            .map((e) => e is Map ? (e['message'] ?? e.toString()) : e.toString())
            .join(', ');
      }
    }

    if (data is String && data.isNotEmpty) return data;

    // HTTP status fallback
    final status = e.response?.statusCode;
    if (status != null) {
      final statusMsg = _httpStatusMessage(status);
      if (statusMsg != null) return statusMsg;
    }

    // Network / timeout errors
    return switch (e.type) {
      DioExceptionType.connectionTimeout => 'Connection timed out',
      DioExceptionType.receiveTimeout    => 'Server took too long to respond',
      DioExceptionType.sendTimeout       => 'Request timed out while sending',
      DioExceptionType.connectionError   => 'No internet connection',
      DioExceptionType.cancel            => 'Request was cancelled',
      _                                  => 'Network error (${status ?? 'unknown'})',
    };
  }

  // ── Private helpers ───────────────────────────────────────────────────────────

  dynamic _unwrap(dynamic data, String? key) =>
      (key != null && data is Map<String, dynamic>) ? data[key] : data;

  int? _metaInt(Map<String, dynamic> meta, List<String> keys) {
    for (final key in keys) {
      final val = meta[key];
      if (val != null) return (val as num).toInt();
    }
    return null;
  }

  String? _httpStatusMessage(int status) => switch (status) {
        400 => 'Bad request',
        401 => 'Unauthorised',
        403 => 'You do not have permission to perform this action',
        404 => 'The requested resource was not found',
        408 => 'Request timeout',
        409 => 'Conflict — the request could not be completed',
        422 => 'Validation failed',
        429 => 'Too many requests — please try again later',
        500 => 'Internal server error',
        502 => 'Bad gateway',
        503 => 'Service unavailable — please try again later',
        504 => 'Gateway timeout',
        _   => null,
      };
}

// ── DioFactory ─────────────────────────────────────────────────────────────────

/// Factory for creating a production-ready [Dio] instance.
class DioFactory {
  DioFactory._();

  /// Creates a configured [Dio] instance.
  ///
  /// Pass [interceptors] to add authentication, retry, caching, etc.
  /// [addLogging] defaults to [kDebugMode].
  static Dio create({
    required String baseUrl,
    Duration connectTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 30),
    Duration sendTimeout    = const Duration(seconds: 60),
    String? authToken,
    List<Interceptor> interceptors = const [],
    bool? addLogging,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      ),
    );

    dio.interceptors.addAll(interceptors);
    if (addLogging ?? kDebugMode) dio.interceptors.add(LoggingInterceptor());
    return dio;
  }
}

// ── AuthInterceptor ────────────────────────────────────────────────────────────

/// Injects a fresh Bearer token on every request by calling [tokenProvider].
///
/// Use this for standard per-request token injection. For automatic 401 →
/// refresh → retry behaviour, use [TokenRefreshInterceptor] instead.
///
/// ```dart
/// DioFactory.create(
///   baseUrl: Env.apiUrl,
///   interceptors: [AuthInterceptor(() => storage.get('token'))],
/// );
/// ```
class AuthInterceptor extends Interceptor {
  final Future<String?> Function() _tokenProvider;

  const AuthInterceptor(this._tokenProvider);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenProvider();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

// ── TokenRefreshInterceptor ────────────────────────────────────────────────────

/// Handles 401 responses by refreshing the access token and retrying the
/// original request — transparently, without the caller knowing.
///
/// Uses [QueuedInterceptorsWrapper] so that if multiple requests fail with 401
/// simultaneously, only **one** refresh is triggered and all queued requests
/// are retried with the new token once it arrives.
///
/// ```dart
/// DioFactory.create(
///   baseUrl: Env.apiUrl,
///   interceptors: [
///     AuthInterceptor(() => storage.get('token')),
///     TokenRefreshInterceptor(
///       dio: dio,
///       tokenRefresher: () async {
///         final res = await refreshDio.post('/auth/refresh');
///         final newToken = res.data['access_token'] as String;
///         await storage.set('token', newToken);
///         return newToken;
///       },
///       onRefreshFailed: () {
///         // Token is truly expired — send user to login
///         locator<NavigationService>().clearStackAndShow(Routes.loginView);
///       },
///     ),
///   ],
/// );
/// ```
class TokenRefreshInterceptor extends QueuedInterceptorsWrapper {
  final Dio _dio;
  final Future<String?> Function() _tokenRefresher;
  final void Function()? _onRefreshFailed;

  TokenRefreshInterceptor({
    required Dio dio,
    required Future<String?> Function() tokenRefresher,
    void Function()? onRefreshFailed,
  })  : _dio = dio,
        _tokenRefresher = tokenRefresher,
        _onRefreshFailed = onRefreshFailed;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Prevent infinite loops: if this request is already a retry, give up.
    if (err.requestOptions.extra['_isRetry'] == true) {
      _onRefreshFailed?.call();
      return handler.next(err);
    }

    try {
      final newToken = await _tokenRefresher();

      if (newToken == null) {
        _onRefreshFailed?.call();
        return handler.next(err);
      }

      // Retry the original request with the refreshed token.
      final retryOptions = err.requestOptions
        ..headers['Authorization'] = 'Bearer $newToken'
        ..extra['_isRetry'] = true;

      final response = await _dio.fetch(retryOptions);
      return handler.resolve(response);
    } catch (_) {
      _onRefreshFailed?.call();
      return handler.next(err);
    }
  }
}

// ── RetryInterceptor ───────────────────────────────────────────────────────────

/// Automatically retries failed requests on transient errors using exponential
/// backoff.
///
/// Retries on:
/// - Connection/receive/send timeouts
/// - `connectionError` (network dropped mid-flight)
/// - 5xx server errors (except 501 Not Implemented)
///
/// Does **not** retry 4xx client errors — those indicate a problem with the
/// request itself.
///
/// ```dart
/// DioFactory.create(
///   baseUrl: Env.apiUrl,
///   interceptors: [RetryInterceptor(dio: dio)],
/// );
/// ```
class RetryInterceptor extends Interceptor {
  final Dio _dio;
  final int maxRetries;
  final Duration initialDelay;

  RetryInterceptor({
    required Dio dio,
    this.maxRetries = 3,
    this.initialDelay = const Duration(seconds: 1),
  }) : _dio = dio;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final attempt = (err.requestOptions.extra['_retryCount'] as int?) ?? 0;

    if (!_shouldRetry(err) || attempt >= maxRetries) {
      return handler.next(err);
    }

    final delay = initialDelay * (1 << attempt); // 1s, 2s, 4s, …
    await Future.delayed(delay);

    err.requestOptions.extra['_retryCount'] = attempt + 1;

    try {
      final response = await _dio.fetch(err.requestOptions);
      return handler.resolve(response);
    } on DioException catch (retryErr) {
      return handler.next(retryErr);
    }
  }

  bool _shouldRetry(DioException e) {
    final status = e.response?.statusCode;
    if (status != null) {
      // Retry 5xx except 501 (Not Implemented — a code bug, not transient)
      return status >= 500 && status != 501;
    }
    return switch (e.type) {
      DioExceptionType.connectionTimeout => true,
      DioExceptionType.receiveTimeout    => true,
      DioExceptionType.sendTimeout       => true,
      DioExceptionType.connectionError   => true,
      _                                  => false,
    };
  }
}

// ── LoggingInterceptor ─────────────────────────────────────────────────────────

/// Logs requests, responses, and errors. Only active in debug builds by
/// default — controlled via [DioFactory.create]'s [addLogging] parameter.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('[API →] ${options.method} ${options.uri}');
    if (options.data != null) {
      debugPrint('[API →] body: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
      '[API ←] ${response.statusCode} ${response.requestOptions.uri}',
    );
    if (response.data != null) {
      debugPrint('[API ←] body: ${response.data}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      '[API ✕] ${err.response?.statusCode ?? err.type.name} '
      '${err.requestOptions.uri} — ${err.message}',
    );
    if (err.response?.data != null) {
      debugPrint('[API ✕] body: ${err.response?.data}');
    }
    handler.next(err);
  }
}
