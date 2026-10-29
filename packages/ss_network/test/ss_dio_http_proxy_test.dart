import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ss_network/src/client/ss_dio_factory.dart';
import 'package:ss_network/src/client/ss_dio_http_proxy_io.dart';
import 'package:ss_network/src/client/ss_dio_http_proxy_logic.dart';

void main() {
  group('ssHttpProxyFindProxyValue', () {
    test('empty hostPort uses DIRECT', () {
      expect(ssHttpProxyFindProxyValue(''), 'DIRECT');
      expect(ssHttpProxyFindProxyValue('   '), 'DIRECT');
    });

    test('non-empty hostPort uses PROXY directive', () {
      expect(
        ssHttpProxyFindProxyValue('10.193.233.3:8888'),
        'PROXY 10.193.233.3:8888',
      );
    });
  });

  group('SSDioFactory', () {
    test('empty httpProxy does not replace adapter with custom createHttpClient', () {
      final dio = SSDioFactory.create(
        baseUrl: 'http://api.example.cn/api/v1',
        httpProxy: '',
      );
      final adapter = dio.httpClientAdapter;
      if (adapter is IOHttpClientAdapter) {
        expect(adapter.createHttpClient, isNull);
      }
    });

    test('httpProxy installs IOHttpClientAdapter with createHttpClient', () {
      final dio = SSDioFactory.create(
        baseUrl: 'http://api.example.cn/api/v1',
        httpProxy: '192.168.1.2:8888',
      );
      expect(dio.httpClientAdapter, isA<IOHttpClientAdapter>());
      final adapter = dio.httpClientAdapter as IOHttpClientAdapter;
      expect(adapter.createHttpClient, isNotNull);
      final client = adapter.createHttpClient!.call();
      addTearDown(client.close);
      expect(client, isA<HttpClient>());
    });
  });

  test('applySsHttpProxy no-op when empty', () {
    final dio = Dio();
    final before = dio.httpClientAdapter;
    applySsHttpProxy(dio, '');
    expect(dio.httpClientAdapter, same(before));
  });
}
