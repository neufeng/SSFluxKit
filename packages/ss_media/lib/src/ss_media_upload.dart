import 'package:dio/dio.dart';
import 'package:ss_core/ss_core.dart';
import 'package:ss_network/ss_network.dart';

class SSMediaAsset {
  const SSMediaAsset({
    required this.id,
    this.url,
    this.contentType,
    this.sizeBytes,
  });

  final String id;
  final String? url;
  final String? contentType;
  final int? sizeBytes;

  factory SSMediaAsset.fromJson(Map<String, dynamic> json) {
    return SSMediaAsset(
      id: json['id'] as String? ?? json['mediaId'] as String? ?? '',
      url: json['url'] as String? ?? json['publicUrl'] as String?,
      contentType: json['contentType'] as String?,
      sizeBytes: (json['sizeBytes'] as num?)?.toInt(),
    );
  }
}

class SSPresignResponse {
  const SSPresignResponse({
    required this.mediaId,
    required this.uploadUrl,
    this.expiresAt,
  });

  final String mediaId;
  final String uploadUrl;
  final DateTime? expiresAt;

  factory SSPresignResponse.fromJson(Map<String, dynamic> json) {
    return SSPresignResponse(
      mediaId: json['mediaId'] as String,
      uploadUrl: json['uploadUrl'] as String,
      expiresAt: json['expiresAt'] is String
          ? DateTime.tryParse(json['expiresAt'] as String)
          : null,
    );
  }
}

/// Presign → PUT → confirm flow for `/api/v1/media/*`.
class SSMediaUploadService {
  SSMediaUploadService(this._client);

  final SSHttpClient _client;

  Future<SSResult<SSMediaAsset>> uploadBytes({
    required List<int> bytes,
    required String fileName,
    required String contentType,
  }) async {
    final presign = await _client.post<Map<String, dynamic>>(
      '/media/upload-url',
      data: {
        'fileName': fileName,
        'contentType': contentType,
        'sizeBytes': bytes.length,
      },
      parser: (json) => json as Map<String, dynamic>,
    );

    if (presign is SSFailure<Map<String, dynamic>>) {
      return SSFailure(presign.error);
    }
    final json = (presign as SSSuccess<Map<String, dynamic>>).data;

    final presigned = SSPresignResponse.fromJson(json);
    try {
      await Dio().put<void>(
        presigned.uploadUrl,
        data: bytes,
        options: Options(headers: {'Content-Type': contentType}),
      );
    } on DioException catch (e) {
      return SSFailure(SSApiErrorMapper.fromDioException(e));
    }

    final confirmed = await _client.post<Map<String, dynamic>>(
      '/media/${presigned.mediaId}/confirm',
      parser: (j) => j as Map<String, dynamic>,
    );
    return confirmed.when(
      success: (body) => SSSuccess(SSMediaAsset.fromJson(body)),
      failure: (e) => SSFailure(e),
    );
  }
}
