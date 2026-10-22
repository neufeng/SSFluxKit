part of 'ss_app_error.dart';

/// API error body `{ code, message, details? }` from SSFluxServer.
final class SSApiError extends SSAppError {
  const SSApiError({
    required this.code,
    required String message,
    this.details,
    this.statusCode,
    Object? cause,
  }) : super(message, cause: cause);

  final String code;
  final Map<String, dynamic>? details;
  final int? statusCode;

  @override
  String toString() => 'SSApiError($code): $message';
}

/// App user disabled by admin — session must be cleared and user sent to login.
final class SSAccountDisabledError extends SSApiError {
  const SSAccountDisabledError({
    String message = '账号已被禁用',
    Map<String, dynamic>? details,
    int? statusCode,
    Object? cause,
  }) : super(
          code: 'ACCOUNT_DISABLED',
          message: message,
          details: details,
          statusCode: statusCode,
          cause: cause,
        );
}
