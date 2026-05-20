import 'dart:convert';

import 'package:dio/dio.dart';

import 'json_response_sanitize.dart';

/// Katta JSON javoblarda Dio `ResponseType.json` ba'zan `FormatException` beradi.
/// Avval JSON, xato bo'lsa bytes + sanitize fallback.
class ResilientApiJson {
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
        return res.data!;
      }
      throw Exception('Failed to load $path (${res.statusCode})');
    } on DioException catch (e) {
      if (e.error is! FormatException) rethrow;
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
    return JsonResponseSanitize.decodeJsonMap(raw);
  }
}
