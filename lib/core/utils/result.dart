/// A discriminated union that holds either a success value [T] or an error
/// message. Use this as the return type of every service / repository method
/// so ViewModels never need to catch raw exceptions.
class Result<T> {
  final T? data;
  final String? error;

  bool get isSuccess => error == null;
  bool get isFailure => error != null;

  const Result.success(this.data) : error = null;
  const Result.failure(this.error) : data = null;

  /// Run [onSuccess] or [onFailure] depending on the outcome.
  R when<R>({
    required R Function(T? data) onSuccess,
    required R Function(String error) onFailure,
  }) {
    if (isSuccess) return onSuccess(data);
    return onFailure(error!);
  }

  /// Transform the data value without changing the error path.
  Result<R> map<R>(R Function(T? data) transform) {
    if (isSuccess) return Result.success(transform(data));
    return Result.failure(error!);
  }

  /// Transform the error message without changing the success path.
  Result<T> mapError(String Function(String error) transform) {
    if (isFailure) return Result.failure(transform(error!));
    return this;
  }

  /// Returns [data] if successful, otherwise `null`.
  T? getOrNull() => isSuccess ? data : null;

  /// Returns [data] if successful, otherwise [fallback].
  T getOrElse(T fallback) => (isSuccess && data != null) ? data as T : fallback;

  /// Returns [data] if successful, otherwise throws a [StateError].
  T getOrThrow() {
    if (isSuccess && data != null) return data as T;
    throw StateError(error ?? 'Result has no data');
  }

  /// Functional fold — an alias for [when] with positional callbacks.
  R fold<R>(R Function(T? data) onSuccess, R Function(String error) onFailure) =>
      when(onSuccess: onSuccess, onFailure: onFailure);

  /// Chains two [Result]-returning operations. If this is a failure,
  /// the failure propagates and [next] is never called.
  Future<Result<R>> andThen<R>(Future<Result<R>> Function(T? data) next) async {
    if (isFailure) return Result.failure(error!);
    return next(data);
  }

  @override
  String toString() =>
      isSuccess ? 'Result.success($data)' : 'Result.failure($error)';
}
