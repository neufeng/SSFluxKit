import 'package:dio/dio.dart';
import 'package:ss_core/ss_core.dart';

class SSApiErrorMapper {
  SSApiErrorMapper._();

  static SSAppError fromDioException(DioException e) {
    final status = e.response?.statusCode;
    final body = e.response?.data;
    if (body is Map<String, dynamic>) {
      final code = body['code'];
      if (code is String) {
        final message = body['message'] as String? ?? '请求失败';
        final details = body['details'];
        final mapDetails =
            details is Map<String, dynamic> ? details : null;
        if (code == 'ACCOUNT_DISABLED') {
          return SSAccountDisabledError(
            message: message,
            details: mapDetails,
            statusCode: status,
            cause: e,
          );
        }
        return SSApiError(
          code: code,
          message: message,
          details: mapDetails,
          statusCode: status,
          cause: e,
        );
      }
    }

    if (status == 401) {
      return SSUnauthorizedError(e.message ?? '未授权，请登录');
    }
    if (status == 403) {
      return SSUnauthorizedError(e.message ?? '无权限');
    }
    if (status == 404) {
      return SSNotFoundError();
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return SSNetworkError('请求超时', cause: e, statusCode: status);
    }
    if (e.type == DioExceptionType.connectionError) {
      return SSNetworkError('网络不可用', cause: e, statusCode: status);
    }
    return SSNetworkError(
      e.message ?? '网络请求失败',
      cause: e,
      statusCode: status,
    );
  }
}
