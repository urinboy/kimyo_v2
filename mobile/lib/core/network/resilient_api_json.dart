import 'dart:convert';

import 'package:dio/dio.dart';

import 'json_response_sanitize.dart';

/// JSON o‘rniga HTML (admin SPA) yoki boshqa format kelganda.
class ApiResponseParseException implements Exception {
  final String message;
  ApiResponseParseException(this.message);

  @override
  String toString() => message;
}

/// Katta JSON javoblarda Dio `ResponseType.json` ba'zan `FormatException` beradi.
/// Avval JSON, xato bo'lsa bytes + sanitize fallback.
class ResilientApiJson {
  static const String _htmlHint =
      'Server JSON emas (HTML sahifa). API yangilanmagan bo‘lishi mumkin — '
      'mahalliy sinov uchun mobile_api.env: API_BASE_URL=http://127.0.0.1:8089/api/v1';

  static bool _looksLikeHtml(String raw) {
    final t = raw.trimLeft();
    return t.startsWith('<!') || t.startsWith('<html');
  }

  static Map<String, dynamic> _ensureJsonMap(dynamic data, String path) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String) {
      if (_looksLikeHtml(data)) {
        throw ApiResponseParseException('$_htmlHint ($path)');
      }
      return JsonResponseSanitize.decodeJsonMap(data);
    }
    throw ApiResponseParseException(
      'Kutilmagan javob ($path): ${data.runtimeType}',
    );
  }
  static const Duration longReceive = Duration(seconds: 120);

  static Options get jsonOptions => Options(
        receiveTimeout: longReceive,
        validateStatus: (s) => s != null && s < 500,
      );

  static Options get bytesOptions => Options(
        responseType: ResponseType.bytes,
        receiveTimeout: longReceive,
        validateStatus: (s) => s != null && s < 500,
      );

  static Future<Map<String, dynamic>> getMap(
    Dio dio,
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final res = await dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
        options: jsonOptions,
      );
      if (res.statusCode == 200 && res.data != null) {
        return _ensureJsonMap(res.data, path);
      }
      if (res.statusCode == 404) {
        throw ApiResponseParseException(
          'API topilmadi (404): $path. Serverda route deploy qilinganmi?',
        );
      }
      throw Exception('Failed to load $path (${res.statusCode})');
    } on DioException catch (e) {
      // FormatException yoki TypeError (masalan HTML ni Map<> ga cast qilishda) —
      // bytes fallback orqali HTML ni to'g'ri aniqlash uchun o'tkazib yuboramiz.
      if (e.error is! FormatException && e.error is! TypeError) rethrow;
    } on TypeError catch (_) {
      // Dio javobini Map<String,dynamic>-ga cast qilishda xato — bytes fallback ishlatamiz.
    }

    final res = await dio.get<List<int>>(
      path,
      queryParameters: queryParameters,
      options: bytesOptions,
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to load $path (${res.statusCode})');
    }
    var raw = utf8.decode(res.data ?? [], allowMalformed: true);
    if (raw.isNotEmpty && raw.codeUnitAt(0) == 0xFEFF) {
      raw = raw.substring(1);
    }
    if (_looksLikeHtml(raw)) {
      throw ApiResponseParseException('$_htmlHint ($path)');
    }
    return JsonResponseSanitize.decodeJsonMap(raw);
  }
}
