import 'dart:convert';

import 'package:dio/dio.dart';

import '../../core/utils/json_bool.dart';

/// GET /standalone-quizzes (mobil — kimyo testlari ro'yxati)
class StandaloneQuizListItem {
  final int id;
  final String titleUz;
  final String? titleRu;
  final String? titleEn;
  final int questionsCount;
  final String category;

  const StandaloneQuizListItem({
    required this.id,
    required this.titleUz,
    this.titleRu,
    this.titleEn,
    required this.questionsCount,
    required this.category,
  });

  factory StandaloneQuizListItem.fromJson(Map<String, dynamic> j) => StandaloneQuizListItem(
        id: j['id'] as int,
        titleUz: j['title_uz'] as String? ?? '',
        titleRu: j['title_ru'] as String?,
        titleEn: j['title_en'] as String?,
        questionsCount: j['questions_count'] as int? ?? 0,
        category: j['category'] as String? ?? '',
      );

  String titleForLang(String lang) {
    switch (lang) {
      case 'ru':
        return titleRu?.trim().isNotEmpty == true ? titleRu! : titleUz;
      case 'en':
        return titleEn?.trim().isNotEmpty == true ? titleEn! : titleUz;
      default:
        return titleUz;
    }
  }
}

class ApiQuizOption {
  final int id;
  final bool isCorrect;
  final List<dynamic> translations;

  const ApiQuizOption({
    required this.id,
    required this.isCorrect,
    required this.translations,
  });

  factory ApiQuizOption.fromJson(Map<String, dynamic> j) => ApiQuizOption(
        id: j['id'] as int,
        isCorrect: jsonBool(j['is_correct']),
        translations: j['translations'] as List<dynamic>? ?? [],
      );
}

class ApiQuizQuestion {
  final int id;
  final int order;
  final List<dynamic> translations;
  final List<ApiQuizOption> options;

  const ApiQuizQuestion({
    required this.id,
    required this.order,
    required this.translations,
    required this.options,
  });

  factory ApiQuizQuestion.fromJson(Map<String, dynamic> j) {
    final opts = (j['options'] as List<dynamic>? ?? [])
        .map((e) => ApiQuizOption.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    return ApiQuizQuestion(
      id: j['id'] as int,
      order: j['order'] as int? ?? 0,
      translations: j['translations'] as List<dynamic>? ?? [],
      options: opts,
    );
  }
}

class ApiQuizDetail {
  final int id;
  final String titleUz;
  final List<ApiQuizQuestion> questions;

  const ApiQuizDetail({
    required this.id,
    required this.titleUz,
    required this.questions,
  });

  factory ApiQuizDetail.fromJson(Map<String, dynamic> j) {
    final qs = (j['questions'] as List<dynamic>? ?? [])
        .map((e) => ApiQuizQuestion.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    return ApiQuizDetail(
      id: j['id'] as int,
      titleUz: j['title_uz'] as String? ?? '',
      questions: qs,
    );
  }
}

abstract class StandaloneQuizRemoteDataSource {
  Future<List<StandaloneQuizListItem>> listChemistry();
  Future<ApiQuizDetail> getQuiz(int id);
  Future<Map<String, int>> submitAttempt(int quizId, List<Map<String, int>> answers);
}

class StandaloneQuizRemoteDataSourceImpl implements StandaloneQuizRemoteDataSource {
  final Dio dio;

  StandaloneQuizRemoteDataSourceImpl({required this.dio});

  /// Raw bytes → UTF-8 decode → JSON parse (Elements endpoint-dagi kabi).
  Map<String, dynamic> _decodeJsonBytes(List<int> bytes) {
    String raw = utf8.decode(bytes, allowMalformed: true);
    // BOM olib tashlash
    if (raw.isNotEmpty && raw.codeUnitAt(0) == 0xFEFF) {
      raw = raw.substring(1);
    }
    raw = raw.trim();
    return json.decode(raw) as Map<String, dynamic>;
  }

  @override
  Future<List<StandaloneQuizListItem>> listChemistry() async {
    final res = await dio.get<List<int>>(
      '/standalone-quizzes',
      queryParameters: {'type': 'chemistry'},
      options: Options(responseType: ResponseType.bytes),
    );
    final body = _decodeJsonBytes(res.data ?? []);
    final list = body['data']['quizzes'] as List<dynamic>;
    return list.map((e) => StandaloneQuizListItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<ApiQuizDetail> getQuiz(int id) async {
    final res = await dio.get<List<int>>(
      '/standalone-quizzes/$id',
      options: Options(
        responseType: ResponseType.bytes,
        receiveTimeout: const Duration(seconds: 120),
      ),
    );
    final body = _decodeJsonBytes(res.data ?? []);
    final quiz = body['data']['quiz'] as Map<String, dynamic>;
    return ApiQuizDetail.fromJson(quiz);
  }

  /// [answers]: `[{question_id, option_id}, ...]`
  @override
  Future<Map<String, int>> submitAttempt(int quizId, List<Map<String, int>> answers) async {
    final res = await dio.post<Map<String, dynamic>>(
      '/standalone-quizzes/$quizId/attempts',
      data: {
        'answers': answers
            .map((e) => {'question_id': e['question_id'], 'option_id': e['option_id']})
            .toList(),
      },
    );
    final data = res.data!['data'] as Map<String, dynamic>;
    return {
      'attempt_id': data['attempt_id'] as int,
      'correct_count': data['correct_count'] as int,
      'total_count': data['total_count'] as int,
    };
  }
}

String pickTranslatedText(List<dynamic> rows, int langId) {
  for (final row in rows) {
    final m = row as Map<String, dynamic>;
    if (m['language_id'] == langId) {
      return (m['text'] as String?)?.trim() ?? '';
    }
  }
  if (rows.isNotEmpty) {
    final m = rows.first as Map<String, dynamic>;
    return (m['text'] as String?)?.trim() ?? '';
  }
  return '';
}

int languageIdFromCode(String code) {
  switch (code) {
    case 'ru':
      return 2;
    case 'en':
      return 3;
    case 'kaa':
      return 4;
    case 'uz':
    default:
      return 1;
  }
}
