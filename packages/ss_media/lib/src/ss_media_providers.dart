import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_network/ss_network.dart';

import 'ss_media_upload.dart';

final ssMediaUploadServiceProvider = Provider<SSMediaUploadService>((ref) {
  return SSMediaUploadService(ref.watch(ssHttpClientProvider));
});
