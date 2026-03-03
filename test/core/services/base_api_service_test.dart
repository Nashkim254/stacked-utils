import 'package:app_kit/app_kit.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Concrete subclass used in all tests ───────────────────────────────────────

class _TestService extends BaseApiService {
  _TestService(super.dio);
}

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Builds a Dio instance whose adapter always returns [statusCode] + [data].
Dio _mockDio(int statusCode, dynamic data) {
  final dio = Dio(BaseOptions(baseUrl: 'https://test.example'));
  dio.httpClientAdapter = _MockAdapter(statusCode, data);
  return dio;
}

class _MockAdapter implements HttpClientAdapter {
  final int statusCode;
  final dynamic data;
  _MockAdapter(this.statusCode, this.data);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (statusCode == 0) throw Exception('No internet');
    return ResponseBody.fromString(
      data is String ? data : data.toString(),
      statusCode,
      headers: {'content-type': ['application/json']},
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Builds a Dio whose adapter throws a [DioException] of [type].
Dio _mockDioWithException(DioExceptionType type) {
  final dio = Dio(BaseOptions(baseUrl: 'https://test.example'));
  dio.httpClientAdapter = _ThrowingAdapter(type);
  return dio;
}

class _ThrowingAdapter implements HttpClientAdapter {
  final DioExceptionType type;
  _ThrowingAdapter(this.type);

  @override
  Future<ResponseBody> fetch(RequestOptions options, _, __) async {
    throw DioException(requestOptions: options, type: type);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  // ── safeCall ──────────────────────────────────────────────────────────────────

  group('safeCall', () {
    test('returns success when response is a JSON object', () async {
      final svc = _TestService(
        _mockDio(200, '{"id":1,"name":"Alice"}'),
      );

      final result = await svc.safeCall(
        () => svc.dio.get('/users/1'),
        (json) => json['name'] as String,
      );

      expect(result.isSuccess, isTrue);
      expect(result.getOrNull(), 'Alice');
    });

    test('unwraps nested data key when unwrapDataKey is provided', () async {
      final svc = _TestService(
        _mockDio(200, '{"data":{"id":1,"name":"Alice"}}'),
      );

      final result = await svc.safeCall(
        () => svc.dio.get('/users/1'),
        (json) => json['name'] as String,
        unwrapDataKey: 'data',
      );

      expect(result.getOrNull(), 'Alice');
    });

    test('returns failure for non-map response', () async {
      final svc = _TestService(_mockDio(200, '"just a string"'));

      final result = await svc.safeCall(
        () => svc.dio.get('/'),
        (json) => json,
      );

      expect(result.isFailure, isTrue);
    });

    test('returns failure with parsed message on 4xx', () async {
      final svc = _TestService(
        _mockDio(404, '{"message":"User not found"}'),
      );

      final result = await svc.safeCall(
        () => svc.dio.get('/users/99'),
        (json) => json,
      );

      expect(result.isFailure, isTrue);
      expect(result.error, contains('not found'));
    });

    test('returns failure on connection timeout', () async {
      final svc = _TestService(
        _mockDioWithException(DioExceptionType.connectionTimeout),
      );

      final result = await svc.safeCall(
        () => svc.dio.get('/'),
        (json) => json,
      );

      expect(result.error, 'Connection timed out');
    });

    test('returns failure on receive timeout', () async {
      final svc = _TestService(
        _mockDioWithException(DioExceptionType.receiveTimeout),
      );
      final result = await svc.safeCall(() => svc.dio.get('/'), (j) => j);
      expect(result.error, 'Server took too long to respond');
    });

    test('returns failure on connection error', () async {
      final svc = _TestService(
        _mockDioWithException(DioExceptionType.connectionError),
      );
      final result = await svc.safeCall(() => svc.dio.get('/'), (j) => j);
      expect(result.error, 'No internet connection');
    });
  });

  // ── safeCallList ──────────────────────────────────────────────────────────────

  group('safeCallList', () {
    test('returns success for a JSON array', () async {
      final svc = _TestService(
        _mockDio(200, '[{"name":"A"},{"name":"B"}]'),
      );

      final result = await svc.safeCallList(
        () => svc.dio.get('/users'),
        (json) => json['name'] as String,
      );

      expect(result.getOrNull(), ['A', 'B']);
    });

    test('unwraps nested data key when unwrapDataKey is provided', () async {
      final svc = _TestService(
        _mockDio(200, '{"data":[{"name":"A"}]}'),
      );

      final result = await svc.safeCallList(
        () => svc.dio.get('/users'),
        (json) => json['name'] as String,
        unwrapDataKey: 'data',
      );

      expect(result.getOrNull(), ['A']);
    });

    test('returns failure when body is not a list', () async {
      final svc = _TestService(_mockDio(200, '{"name":"A"}'));

      final result = await svc.safeCallList(
        () => svc.dio.get('/users'),
        (json) => json,
      );

      expect(result.isFailure, isTrue);
      expect(result.error, contains('list'));
    });
  });

  // ── safeCallVoid ──────────────────────────────────────────────────────────────

  group('safeCallVoid', () {
    test('returns success on 204 no-content', () async {
      final svc = _TestService(_mockDio(204, ''));

      final result = await svc.safeCallVoid(() => svc.dio.delete('/users/1'));

      expect(result.isSuccess, isTrue);
    });

    test('returns success on 200 with body (body is ignored)', () async {
      final svc = _TestService(_mockDio(200, '{"ok":true}'));

      final result = await svc.safeCallVoid(() => svc.dio.post('/logout'));

      expect(result.isSuccess, isTrue);
    });

    test('returns failure on 4xx', () async {
      final svc = _TestService(_mockDio(403, '{"message":"Forbidden"}'));

      final result = await svc.safeCallVoid(() => svc.dio.delete('/admin/1'));

      expect(result.isFailure, isTrue);
      expect(result.error, 'Forbidden');
    });
  });

  // ── safeCallPaginated ─────────────────────────────────────────────────────────

  group('safeCallPaginated', () {
    test('parses standard paginated response', () async {
      final svc = _TestService(_mockDio(200, '''
        {
          "data": [{"name":"A"},{"name":"B"}],
          "meta": {"total": 50, "current_page": 2, "per_page": 10, "last_page": 5}
        }
      '''));

      final result = await svc.safeCallPaginated(
        () => svc.dio.get('/users'),
        (json) => json['name'] as String,
      );

      final page = result.getOrNull()!;
      expect(page.data, ['A', 'B']);
      expect(page.total, 50);
      expect(page.page, 2);
      expect(page.perPage, 10);
      expect(page.lastPage, 5);
      expect(page.hasNextPage, isTrue);
      expect(page.isFirstPage, isFalse);
      expect(page.isLastPage, isFalse);
    });

    test('hasNextPage is false on the last page', () async {
      final svc = _TestService(_mockDio(200, '''
        {"data":[],"meta":{"total":5,"current_page":1,"per_page":10,"last_page":1}}
      '''));

      final result = await svc.safeCallPaginated(
        () => svc.dio.get('/users'),
        (json) => json,
      );

      expect(result.getOrNull()!.hasNextPage, isFalse);
      expect(result.getOrNull()!.isLastPage, isTrue);
    });

    test('supports custom dataKey and metaKey', () async {
      final svc = _TestService(_mockDio(200, '''
        {"items":[{"name":"A"}],"pagination":{"total":1,"page":1,"per_page":20,"last_page":1}}
      '''));

      final result = await svc.safeCallPaginated(
        () => svc.dio.get('/users'),
        (json) => json['name'] as String,
        dataKey: 'items',
        metaKey: 'pagination',
      );

      expect(result.getOrNull()!.data, ['A']);
    });

    test('infers lastPage from total and perPage when missing', () async {
      final svc = _TestService(_mockDio(200, '''
        {"data":[{"name":"A"}],"meta":{"total":100,"per_page":20}}
      '''));

      final result = await svc.safeCallPaginated(
        () => svc.dio.get('/users'),
        (json) => json,
      );

      expect(result.getOrNull()!.lastPage, 5);
    });

    test('returns failure when body is not a map', () async {
      final svc = _TestService(_mockDio(200, '[1,2,3]'));

      final result = await svc.safeCallPaginated(
        () => svc.dio.get('/users'),
        (json) => json,
      );

      expect(result.isFailure, isTrue);
    });

    test('returns failure when data key is not a list', () async {
      final svc = _TestService(_mockDio(200, '{"data":"oops","meta":{}}'));

      final result = await svc.safeCallPaginated(
        () => svc.dio.get('/users'),
        (json) => json,
      );

      expect(result.isFailure, isTrue);
    });
  });

  // ── parseError ────────────────────────────────────────────────────────────────

  group('parseError (HTTP status messages)', () {
    Future<Result<dynamic>> _get(int status, String body) {
      final svc = _TestService(_mockDio(status, body));
      return svc.safeCall(() => svc.dio.get('/'), (j) => j);
    }

    test('401 returns Unauthorised when no body message', () async {
      final r = await _get(401, '{}');
      expect(r.error, 'Unauthorised');
    });

    test('403 returns permission message', () async {
      final r = await _get(403, '{}');
      expect(r.error, contains('permission'));
    });

    test('404 returns resource not found', () async {
      final r = await _get(404, '{}');
      expect(r.error, contains('not found'));
    });

    test('422 returns validation failed', () async {
      final r = await _get(422, '{}');
      expect(r.error, contains('Validation'));
    });

    test('429 returns rate-limit message', () async {
      final r = await _get(429, '{}');
      expect(r.error, contains('Too many'));
    });

    test('500 returns server error', () async {
      final r = await _get(500, '{}');
      expect(r.error, contains('server error'));
    });

    test('body message takes precedence over status code message', () async {
      final r = await _get(400, '{"message":"Email already taken"}');
      expect(r.error, 'Email already taken');
    });

    test('error field is used when message is absent', () async {
      final r = await _get(400, '{"error":"invalid_grant"}');
      expect(r.error, 'invalid_grant');
    });

    test('array errors field is joined', () async {
      final r = await _get(422, '{"errors":["Name required","Email invalid"]}');
      expect(r.error, contains('Name required'));
      expect(r.error, contains('Email invalid'));
    });
  });

  // ── parseError overridable ────────────────────────────────────────────────────

  group('parseError is overridable', () {
    test('subclass can provide custom error extraction', () async {
      final svc = _CustomErrorService(
        _mockDio(400, '{"errors":[{"field":"email","message":"Invalid email"}]}'),
      );

      final result = await svc.safeCall(() => svc.dio.get('/'), (j) => j);
      expect(result.error, 'email: Invalid email');
    });
  });

  // ── PagedResult helpers ───────────────────────────────────────────────────────

  group('PagedResult', () {
    const page = PagedResult(
      data: ['A', 'B'],
      total: 10,
      page: 1,
      perPage: 2,
      lastPage: 5,
    );

    test('mapData transforms each item', () {
      final mapped = page.mapData((s) => s.toLowerCase());
      expect(mapped.data, ['a', 'b']);
      expect(mapped.total, 10);
    });

    test('isFirstPage true on page 1', () => expect(page.isFirstPage, isTrue));
    test('isLastPage false when not on last page',
        () => expect(page.isLastPage, isFalse));
    test('hasNextPage true when not on last page',
        () => expect(page.hasNextPage, isTrue));
  });
}

// ── Custom error service used in override test ────────────────────────────────

class _CustomErrorService extends BaseApiService {
  _CustomErrorService(super.dio);

  @override
  String parseError(DioException e) {
    final errors = e.response?.data?['errors'] as List?;
    if (errors != null && errors.isNotEmpty) {
      return errors
          .map((e) => '${e['field']}: ${e['message']}')
          .join(', ');
    }
    return super.parseError(e);
  }
}
