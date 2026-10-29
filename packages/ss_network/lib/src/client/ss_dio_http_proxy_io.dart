import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import 'ss_dio_http_proxy_logic.dart';

void applySsHttpProxy(Dio dio, String httpProxyHostPort) {
  final trimmed = httpProxyHostPort.trim();
  if (trimmed.isEmpty) {
    return;
  }

  final adapter = IOHttpClientAdapter();
  adapter.createHttpClient = () {
    final client = HttpClient();
    client.findProxy = (_) => ssHttpProxyFindProxyValue(trimmed);
    return client;
  };
  dio.httpClientAdapter = adapter;
}
