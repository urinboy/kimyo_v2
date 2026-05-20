import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/network/json_response_sanitize.dart';
import '../models/lesson_model.dart';

abstract class LessonRemoteDataSource {
  Future<List<LessonModel>> getAllLessons();

  /// To‘liq dars (markdown content) — ro‘yxat `summary=1` bilan yengil bo‘lgani uchun.
  Future<LessonModel> getLesson(int id);
}

class LessonRemoteDataSourceImpl implements LessonRemoteDataSource {
  final Dio dio;

  LessonRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<LessonModel>> getAllLessons() async {
    try {
      final response = await dio.get<List<int>>(
        '/lessons',
        queryParameters: const {'summary': '1'},
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: const Duration(seconds: 120),
        ),
      );

      if (response.statusCode == 200) {
        final bytes = response.data ?? <int>[];
        String raw = utf8.decode(bytes, allowMalformed: true);
        if (raw.isNotEmpty && raw.codeUnitAt(0) == 0xFEFF) {
          raw = raw.substring(1);
        }
        raw = raw.trim();
        final Map<String, dynamic> responseData =
            JsonResponseSanitize.decodeJsonMap(raw);
        final List data = responseData['data']['lessons'];
        return data.map((json) => LessonModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load lessons: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        debugPrint('Lesson Dio error: ${e.type} - ${e.message}');
        if (e.response != null) {
          debugPrint('Response status: ${e.response?.statusCode}');
        }
      } else if (e is FormatException) {
        debugPrint('Lesson JSON parse error: ${e.message} (offset: ${e.offset})');
      }
      rethrow;
    }
  }

  @override
  Future<LessonModel> getLesson(int id) async {
    try {
      final response = await dio.get<List<int>>(
        '/lessons/$id',
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: const Duration(seconds: 120),
        ),
      );

      if (response.statusCode == 200) {
        final bytes = response.data ?? <int>[];
        var raw = utf8.decode(bytes, allowMalformed: true);
        if (raw.isNotEmpty && raw.codeUnitAt(0) == 0xFEFF) {
          raw = raw.substring(1);
        }
        raw = raw.trim();
        final Map<String, dynamic> responseData =
            JsonResponseSanitize.decodeJsonMap(raw);
        final json = responseData['data']['lesson'];
        return LessonModel.fromJson(Map<String, dynamic>.from(json as Map));
      }
      throw Exception('Failed to load lesson: ${response.statusCode}');
    } catch (e) {
      if (e is DioException) {
        debugPrint('Lesson (single) Dio error: ${e.type} - ${e.message}');
        if (e.response != null) {
          debugPrint('Response status: ${e.response?.statusCode}');
        }
      } else if (e is FormatException) {
        debugPrint(
          'Lesson JSON parse error: ${e.message} (offset: ${e.offset})',
        );
      }
      rethrow;
    }
  }
}
