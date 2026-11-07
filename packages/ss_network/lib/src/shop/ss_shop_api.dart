import 'package:dio/dio.dart';
import 'package:ss_core/ss_core.dart';

import '../client/ss_http_client.dart';
import '../errors/ss_api_error_mapper.dart';
import 'ss_shop_models.dart';

/// `/api/v1/shop` 客户端（公开目录 + Bearer 购物车/我的）。
class SSShopApi {
  SSShopApi({
    required Dio publicDio,
    required SSHttpClient authorizedClient,
  })  : _public = publicDio,
        _auth = authorizedClient;

  final Dio _public;
  final SSHttpClient _auth;

  static const _prefix = '/shop';

  Future<SSResult<SSShopHomeResponse>> getHome() async {
    return _publicGet(
      '$_prefix/home',
      (j) => SSShopHomeResponse.fromJson(j as Map<String, dynamic>),
    );
  }

  Future<SSResult<List<SSShopCategoryL1>>> getCategoriesL1() async {
    return _publicGetList(
      '$_prefix/categories/l1',
      (e) => SSShopCategoryL1.fromJson(e as Map<String, dynamic>),
    );
  }

  Future<SSResult<List<SSShopCategoryL2>>> getCategoriesL2(String l1Id) async {
    return _publicGetList(
      '$_prefix/categories/l1/$l1Id/l2',
      (e) => SSShopCategoryL2.fromJson(e as Map<String, dynamic>),
    );
  }

  Future<SSResult<SSShopProductPage>> getProducts({
    String? q,
    String? categoryL1Id,
    String? categoryL2Id,
    String? cursor,
    int limit = 20,
  }) async {
    return _publicGet(
      '$_prefix/products',
      (j) => SSShopProductPage.fromJson(j as Map<String, dynamic>),
      query: {
        if (q != null && q.isNotEmpty) 'q': q,
        if (categoryL1Id != null) 'categoryL1Id': categoryL1Id,
        if (categoryL2Id != null) 'categoryL2Id': categoryL2Id,
        if (cursor != null) 'cursor': cursor,
        'limit': limit,
      },
    );
  }

  Future<SSResult<SSShopProduct>> getProduct(String id) async {
    return _publicGet(
      '$_prefix/products/$id',
      (j) => SSShopProduct.fromJson(j as Map<String, dynamic>),
    );
  }

  Future<SSResult<SSShopMeResponse>> getMe() {
    return _auth.get(
      '$_prefix/me',
      parser: (j) => SSShopMeResponse.fromJson(j as Map<String, dynamic>),
    );
  }

  Future<SSResult<SSShopCartView>> getCart() {
    return _auth.get(
      '$_prefix/cart',
      parser: (j) => SSShopCartView.fromJson(j as Map<String, dynamic>),
    );
  }

  Future<SSResult<SSShopCartSummary>> getCartSummary() {
    return _auth.get(
      '$_prefix/cart/summary',
      parser: (j) => SSShopCartSummary.fromJson(j as Map<String, dynamic>),
    );
  }

  Future<SSResult<SSShopCartView>> addCartLine({
    required String productId,
    String? sku,
    int quantity = 1,
  }) {
    return _auth.post(
      '$_prefix/cart/lines',
      data: {
        'productId': productId,
        if (sku != null) 'sku': sku,
        'quantity': quantity,
      },
      parser: (j) => SSShopCartView.fromJson(j as Map<String, dynamic>),
    );
  }

  Future<SSResult<SSShopCartView>> patchCartLine(
    String lineId, {
    int? quantity,
    bool? selected,
  }) {
    return _auth.patch(
      '$_prefix/cart/lines/$lineId',
      data: {
        if (quantity != null) 'quantity': quantity,
        if (selected != null) 'selected': selected,
      },
      parser: (j) => SSShopCartView.fromJson(j as Map<String, dynamic>),
    );
  }

  Future<SSResult<SSShopCartView>> deleteCartLine(String lineId) {
    return _auth.delete(
      '$_prefix/cart/lines/$lineId',
      parser: (j) => SSShopCartView.fromJson(j as Map<String, dynamic>),
    );
  }

  Future<SSResult<SSShopCartView>> selectCart({
    bool? all,
    bool? selected,
    List<String>? lineIds,
  }) {
    return _auth.post(
      '$_prefix/cart/select',
      data: {
        if (all != null) 'all': all,
        if (selected != null) 'selected': selected,
        if (lineIds != null) 'lineIds': lineIds,
      },
      parser: (j) => SSShopCartView.fromJson(j as Map<String, dynamic>),
    );
  }

  Future<SSResult<SSShopCartView>> deleteSelectedLines() {
    return _auth.delete(
      '$_prefix/cart/lines/selected',
      parser: (j) => SSShopCartView.fromJson(j as Map<String, dynamic>),
    );
  }

  Future<SSResult<void>> clearCart() {
    return _auth.delete<void>(
      '$_prefix/cart',
      parser: (_) => null,
    );
  }

  Future<SSResult<T>> _publicGet<T>(
    String path,
    T Function(dynamic json) parser, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _public.get<dynamic>(
        path,
        queryParameters: query,
      );
      return SSSuccess(parser(response.data));
    } on DioException catch (e, st) {
      SSLogger.e('GET $path failed', e, st);
      return SSFailure(SSApiErrorMapper.fromDioException(e));
    } catch (e, st) {
      SSLogger.e('GET $path failed', e, st);
      return SSFailure(SSUnknownError(e.toString(), e));
    }
  }

  Future<SSResult<List<T>>> _publicGetList<T>(
    String path,
    T Function(dynamic json) parser,
  ) async {
    try {
      final response = await _public.get<dynamic>(path);
      final data = response.data;
      final list = data is List<dynamic>
          ? data
          : (data as Map<String, dynamic>)['items'] as List<dynamic>? ?? [];
      return SSSuccess(list.map(parser).toList());
    } on DioException catch (e, st) {
      SSLogger.e('GET $path failed', e, st);
      return SSFailure(SSApiErrorMapper.fromDioException(e));
    } catch (e, st) {
      SSLogger.e('GET $path failed', e, st);
      return SSFailure(SSUnknownError(e.toString(), e));
    }
  }
}
