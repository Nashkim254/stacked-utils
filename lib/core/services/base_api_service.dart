import 'package:dio/dio.dart';

import '../utils/result.dart';

/// Base class for all API services. Subclass this and inject a [Dio] instance.
///
/// ```dart
/// class AuthApiService extends BaseApiService {
///   AuthApiService(super.dio);
///
///   Future<Result<User>> login(String email, String password) =>
///       safeCall(
///         () => dio.post('/auth/login', data: {'email': email, 'password': password}),
///         (json) => User.fromJson(json),
///       );
/// }
/// ```
abstract class BaseApiService {
  final Dio dio;

  const BaseApiService(this.dio);

  /// Wraps a Dio call in a [Result], mapping success through [fromJson] and
  /// converting [DioException]s into human-readable failure messages.
  Future<Result<T>> safeCall<T>(
    Future<Response<dynamic>> Function() call,
    T Function(Map<String, dynamic> json) fromJson,
  ) async {
    try {
      final response = await call();
      final data = response.data;

      if (data is Map<String, dynamic>) {
        return Result.success(fromJson(data));
      }
      return Result.failure('Unexpected response format');
    } on DioException catch (e) {
      return Result.failure(_parseError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  /// Same as [safeCall] but for list responses.
  Future<Result<List<T>>> safeCallList<T>(
    Future<Response<dynamic>> Function() call,
    T Function(Map<String, dynamic> json) fromJson,
  ) async {
    try {
      final response = await call();
      final data = response.data;

      if (data is List) {
        return Result.success(
          data.cast<Map<String, dynamic>>().map(fromJson).toList(),
        );
      }
      return Result.failure('Expected a list response');
    } on DioException catch (e) {
      return Result.failure(_parseError(e));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  String _parseError(DioException e) {
    // Server returned a structured error body
    final data = e.response?.data;
    if (data is Map) {
      return (data['message'] ??
              data['error'] ??
              data['detail'] ??
              'Server error')
          .toString();
    }
    if (data is String && data.isNotEmpty) return data;

    // Network / timeout errors
    return switch (e.type) {
      DioExceptionType.connectionTimeout => 'Connection timed out',
      DioExceptionType.receiveTimeout => 'Server took too long to respond',
      DioExceptionType.sendTimeout => 'Request timed out while sending',
      DioExceptionType.connectionError => 'No internet connection',
      DioExceptionType.cancel => 'Request was cancelled',
      _ => 'Network error (${e.response?.statusCode ?? 'unknown'})',
    };
  }
}

/// Factory for creating a production-ready [Dio] instance.
class DioFactory {
  DioFactory._();

  static Dio create({
    required String baseUrl,
    Duration connectTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 30),
    String? authToken,
    List<Interceptor> interceptors = const [],
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      ),
    );

    dio.interceptors.addAll(interceptors);
    return dio;
  }
}

/// Interceptor that injects / refreshes a Bearer token on every request.
///
/// ```dart
/// DioFactory.create(
///   baseUrl: Env.apiUrl,
///   interceptors: [AuthInterceptor(() => _storage.get('token'))],
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

/// Interceptor that logs requests and responses in debug mode.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // ignore: avoid_print
    print('[API] ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // ignore: avoid_print
    print('[API] ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // ignore: avoid_print
    print('[API ERROR] ${err.response?.statusCode} ${err.message}');
    handler.next(err);
  }
}
