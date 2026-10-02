import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';

/// HTTP client that keeps the backend's cookie session for the current app run.
class ApiClient {
  ApiClient._(this.dio, this._cookieJar);

  final Dio dio;
  final CookieJar? _cookieJar;

  static Future<ApiClient> create({String? baseUrl}) async {
    final cookieJar = kIsWeb ? null : CookieJar();

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? _defaultBaseUrl(),
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        extra: const {'withCredentials': true},
        headers: const {
          Headers.contentTypeHeader: Headers.jsonContentType,
          Headers.acceptHeader: Headers.jsonContentType,
        },
      ),
    );

    // Browsers manage cookies themselves. CookieManager deliberately rejects
    // web because it relies on the platform's HTTP cookie APIs.
    if (cookieJar != null) dio.interceptors.add(CookieManager(cookieJar));

    return ApiClient._(dio, cookieJar);
  }

  Future<void> clearSession() async {
    await _cookieJar?.deleteAll();
  }

  static String _defaultBaseUrl() {
    if (kIsWeb) return 'http://localhost:6789';
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'http://127.0.0.1:6789';
    }
    return 'http://10.0.2.2:6789';
  }
}
