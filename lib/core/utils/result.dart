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

  @override
  String toString() =>
      isSuccess ? 'Result.success($data)' : 'Result.failure($error)';
}
