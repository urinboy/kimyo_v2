import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/network/json_response_sanitize.dart';
import '../models/lesson_lab_item_model.dart';

abstract class LessonLabItemRemoteDataSource {
  Future<List<LessonLabItemModel>> getLabItems(int lessonId);
}

class LessonLabItemRemoteDataSourceImpl implements LessonLabItemRemoteDataSource {
  final Dio dio;

  LessonLabItemRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<LessonLabItemModel>> getLabItems(int lessonId) async {
    try {
      final response = await dio.get<List<int>>(
        '/lessons/$lessonId/lab-items',
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

        final List data = responseData['data']['items'] ?? [];
        return data
            .map((json) => LessonLabItemModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      } else {
        throw Exception('Failed to load lab items: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        debugPrint('Dio error: ${e.type} - ${e.message}');
        if (e.response != null) {
          debugPrint('Response status: ${e.response?.statusCode}');
          debugPrint('Response data: ${e.response?.data}');
        }
      }
      rethrow;
    }
  }
}
