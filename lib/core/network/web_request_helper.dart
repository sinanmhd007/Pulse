import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class WebRequestHelper {
  WebRequestHelper._();

  static const String _corsProxyBase = 'https://corsproxy.io/?';

  static Future<Response<dynamic>> getWithWebCorsFallback({
    required Dio dio,
    required String url,
    Map<String, dynamic>? queryParameters,
  }) async {
    if (!kIsWeb) {
      return dio.get(url, queryParameters: queryParameters);
    }

    try {
      return await dio.get(url, queryParameters: queryParameters);
    } catch (_) {
      final encodedUrl = Uri.encodeComponent(url);
      final proxiedUrl = '$_corsProxyBase$encodedUrl';
      return dio.get(proxiedUrl, queryParameters: queryParameters);
    }
  }
}
