import '../errors/ss_app_error.dart';

/// Result type for domain / data operations.
sealed class SSResult<T> {
  const SSResult();

  bool get isSuccess => this is SSSuccess<T>;
  bool get isFailure => this is SSFailure<T>;

  T? get dataOrNull => switch (this) {
        SSSuccess(:final data) => data,
        SSFailure() => null,
      };

  SSAppError? get errorOrNull => switch (this) {
        SSSuccess() => null,
        SSFailure(:final error) => error,
      };

  R when<R>({
    required R Function(T data) success,
    required R Function(SSAppError error) failure,
  }) {
    return switch (this) {
      SSSuccess(:final data) => success(data),
      SSFailure(:final error) => failure(error),
    };
  }
}

final class SSSuccess<T> extends SSResult<T> {
  const SSSuccess(this.data);
  final T data;
}

final class SSFailure<T> extends SSResult<T> {
  const SSFailure(this.error);
  final SSAppError error;
}
