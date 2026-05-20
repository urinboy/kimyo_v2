import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/mobile_api_settings.dart';
import 'dio_platform_io.dart' if (dart.library.html) 'dio_platform_stub.dart';

/// Android emulyator / qurilmada `127.0.0.1` host kompyuterni bildirmaydi.
String _normalizeLoopbackForAndroid(String url) {
  if (kIsWeb) return url;
  if (!kimyoPlatformIsAndroid) return url;
  var u = url.trim();
  u = u.replaceAll('127.0.0.1', '10.0.2.2');
  u = u.replaceAll(RegExp(r'\blocalhost\b', caseSensitive: false), '10.0.2.2');
  return u;
}

String get _resolvedBaseUrl {
  final override = MobileApiSettings.baseUrlOverride.trim();
  if (override.isNotEmpty) {
    return _normalizeLoopbackForAndroid(override);
  }
  if (kIsWeb) return 'http://127.0.0.1:8089/api/v1';
  if (kimyoPlatformIsIOS) return 'http://127.0.0.1:8089/api/v1';
  if (kimyoPlatformIsAndroid) return 'http://10.0.2.2:8089/api/v1';
  return 'http://127.0.0.1:8089/api/v1';
}

class DioClient {
  final Dio _dio;

  DioClient(this._dio) {
    final key = MobileApiSettings.apiKey;
    _dio
      ..options.baseUrl = _resolvedBaseUrl
      ..options.connectTimeout = const Duration(seconds: 20)
      ..options.receiveTimeout = const Duration(seconds: 60)
      ..options.responseType = ResponseType.json
      ..options.headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (key.isNotEmpty) 'X-API-Key': key,
      }
      ..interceptors.add(LogInterceptor(
        requestHeader: !kReleaseMode,
        requestBody: !kReleaseMode,
        responseHeader: false,
        responseBody: !kReleaseMode,
      ));
  }

  Dio get dio => _dio;

  static String get apiKey => MobileApiSettings.apiKey;

  /// Bearer token qo'shish (login/register dan keyin chaqiriladi)
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Tokenni o'chirish (logout dan keyin)
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}
