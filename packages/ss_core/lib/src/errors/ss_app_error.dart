/// Typed application / network errors for SSFluxKit.
sealed class SSAppError implements Exception {
  const SSAppError(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'SSAppError: $message';
}

final class SSNetworkError extends SSAppError {
  const SSNetworkError(super.message, {super.cause, this.statusCode});

  final int? statusCode;
}

final class SSUnauthorizedError extends SSAppError {
  const SSUnauthorizedError([super.message = '未授权，请登录']);
}

final class SSNotFoundError extends SSAppError {
  const SSNotFoundError([super.message = '资源不存在']);
}

final class SSValidationError extends SSAppError {
  const SSValidationError(super.message);
}

final class SSUnknownError extends SSAppError {
  const SSUnknownError([super.message = '未知错误', Object? cause])
      : super(cause: cause);
}
