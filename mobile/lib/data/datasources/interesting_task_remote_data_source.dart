import 'package:dio/dio.dart';

import '../../core/network/resilient_api_json.dart';
import '../../core/utils/json_bool.dart';

/// Mobil ro'yxat rejimi (API `kind` parametri bilan mos).
enum InterestingTasksListKind {
  interesting,
  project,
}

extension InterestingTasksListKindX on InterestingTasksListKind {
  String get apiKindValue =>
      this == InterestingTasksListKind.project ? 'project' : 'interesting';

  /// Har doim aniq `kind` — ro'yxatlar aralashmasligi uchun.
  Map<String, dynamic> get apiQuery => {'kind': apiKindValue};

  static InterestingTasksListKind? fromApiValue(String? value) {
    if (value == 'project') return InterestingTasksListKind.project;
    if (value == 'interesting') return InterestingTasksListKind.interesting;
    return null;
  }
}

/// Foydalanuvchining ushbu mavzu bo'yicha so'nggi topshirig'i (listTasks API).
class TaskMySubmissionBrief {
  final int id;
  final String status;
  final bool resultVisible;
  final int totalScore;

  const TaskMySubmissionBrief({
    required this.id,
    required this.status,
    required this.resultVisible,
    required this.totalScore,
  });

  factory TaskMySubmissionBrief.fromJson(Map<String, dynamic> j) => TaskMySubmissionBrief(
        id: j['id'] as int,
        status: j['status'] as String,
        resultVisible: jsonBool(j['result_visible']),
        totalScore: j['total_score'] as int? ?? 0,
      );

  /// Keyingi qiziqarli topshiriqni boshlash uchun: topshirilgan, tekshirilgan va natija foydalanuvchiga ochiq bo‘lishi kerak.
  bool get allowsStartingNextInterestingTask =>
      status == 'checked' && resultVisible;
}

/// Oldingi mavzuning topshirig‘i tugamaguncha keyingisi bloklanadi.
bool submissionAllowsNextInterestingTask(TaskMySubmissionBrief? ms) =>
    ms?.allowsStartingNextInterestingTask ?? false;

class InterestingTaskModel {
  final int id;
  final String title;
  final String? description;
  final int questionsCount;
  final String taskKind;
  final TaskMySubmissionBrief? mySubmission;

  const InterestingTaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.questionsCount,
    this.taskKind = 'interesting',
    this.mySubmission,
  });

  bool matchesListKind(InterestingTasksListKind kind) =>
      taskKind == kind.apiKindValue;

  factory InterestingTaskModel.fromJson(Map<String, dynamic> j) {
    TaskMySubmissionBrief? brief;
    final ms = j['my_submission'];
    if (ms is Map<String, dynamic>) {
      brief = TaskMySubmissionBrief.fromJson(ms);
    } else if (ms is Map) {
      brief = TaskMySubmissionBrief.fromJson(Map<String, dynamic>.from(ms));
    }
    return InterestingTaskModel(
      id: j['id'] as int,
      title: j['title'] as String,
      description: j['description'] as String?,
      questionsCount: j['questions_count'] as int? ?? 0,
      taskKind: j['task_kind'] as String? ?? 'interesting',
      mySubmission: brief,
    );
  }
}

class WordSearchClue {
  final int id;
  final String formula;
  final String commonName;
  final String answer; // faqat tekshiruv uchun — UI da ko'rsatilmaydi

  const WordSearchClue({
    required this.id,
    required this.formula,
    required this.commonName,
    required this.answer,
  });

  factory WordSearchClue.fromJson(Map<String, dynamic> j) => WordSearchClue(
        id: j['id'] as int,
        formula: j['formula'] as String,
        commonName: j['common_name'] as String,
        answer: (j['answer'] as String).toUpperCase(),
      );
}

class MatrixRow {
  final int id;
  final String text;

  const MatrixRow({
    required this.id,
    required this.text,
  });

  factory MatrixRow.fromJson(Map<String, dynamic> j) => MatrixRow(
        id: j['id'] as int,
        text: j['text'] as String,
      );
}

class MatrixSequenceConfig {
  final bool enabled;
  final String? label;
  final int? maxStep;

  const MatrixSequenceConfig({
    required this.enabled,
    this.label,
    this.maxStep,
  });
}

class TaskQuestionModel {
  final int id;
  final String body;
  final int sortOrder;
  final String questionType;
  final String? imageUrl;
  final List<String> matchLeft;
  final List<String> matchRight;
  final List<List<String>> wordSearchGrid;
  final List<WordSearchClue> wordSearchClues;
  final List<MatrixRow> matrixRows;
  final MatrixSequenceConfig? matrixSequence;

  const TaskQuestionModel({
    required this.id,
    required this.body,
    required this.sortOrder,
    this.questionType = 'text',
    this.imageUrl,
    this.matchLeft = const [],
    this.matchRight = const [],
    this.wordSearchGrid = const [],
    this.wordSearchClues = const [],
    this.matrixRows = const [],
    this.matrixSequence,
  });

  static List<String> _stringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return const [];
  }

  factory TaskQuestionModel.fromJson(Map<String, dynamic> j) {
    final md = j['match_data'];
    Map<String, dynamic>? matchMap;
    if (md is Map<String, dynamic>) {
      matchMap = md;
    } else if (md is Map) {
      matchMap = md.map((k, v) => MapEntry(k.toString(), v));
    }

    List<List<String>> wsGrid = const [];
    List<WordSearchClue> wsClues = const [];
    List<MatrixRow> matrixRows = const [];
    MatrixSequenceConfig? matrixSequence;
    if (matchMap != null && matchMap['grid'] != null) {
      final rawGrid = matchMap['grid'] as List<dynamic>;
      wsGrid = rawGrid
          .map((row) => _stringList(row))
          .toList();
      final rawClues = matchMap['clues'] as List<dynamic>? ?? [];
      wsClues = rawClues
          .map((c) => WordSearchClue.fromJson(
                (c is Map<String, dynamic>) ? c : Map<String, dynamic>.from(c as Map),
              ))
          .toList();
    }
    if (matchMap != null && matchMap['rows'] != null) {
      final rawRows = matchMap['rows'] as List<dynamic>;
      matrixRows = rawRows
          .map((r) => MatrixRow.fromJson(
                (r is Map<String, dynamic>) ? r : Map<String, dynamic>.from(r as Map),
              ))
          .toList();
    }
    if (matchMap != null && matchMap['sequence'] is Map) {
      final seqRaw = matchMap['sequence'];
      final seq = (seqRaw is Map<String, dynamic>)
          ? seqRaw
          : Map<String, dynamic>.from(seqRaw as Map);
      matrixSequence = MatrixSequenceConfig(
        enabled: jsonBool(seq['enabled']),
        label: seq['label'] as String?,
        maxStep: seq['max_step'] as int?,
      );
    }

    return TaskQuestionModel(
      id: j['id'] as int,
      body: j['body'] as String,
      sortOrder: j['sort_order'] as int? ?? 0,
      questionType: j['question_type'] as String? ?? 'text',
      imageUrl: j['image_url'] as String?,
      matchLeft: matchMap != null ? _stringList(matchMap['left']) : const [],
      matchRight: matchMap != null ? _stringList(matchMap['right']) : const [],
      wordSearchGrid: wsGrid,
      wordSearchClues: wsClues,
      matrixRows: matrixRows,
      matrixSequence: matrixSequence,
    );
  }
}

class TaskWithQuestionsModel {
  final int id;
  final String title;
  final String? description;
  final String taskKind;
  final List<TaskQuestionModel> questions;

  const TaskWithQuestionsModel({
    required this.id,
    required this.title,
    this.description,
    this.taskKind = 'interesting',
    required this.questions,
  });

  bool matchesListKind(InterestingTasksListKind kind) =>
      taskKind == kind.apiKindValue;

  factory TaskWithQuestionsModel.fromJson(Map<String, dynamic> j) => TaskWithQuestionsModel(
        id: j['id'] as int,
        title: j['title'] as String,
        description: j['description'] as String?,
        taskKind: j['task_kind'] as String? ?? 'interesting',
        questions: (j['questions'] as List<dynamic>? ?? [])
            .map((e) => TaskQuestionModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class MySubmissionModel {
  final int id;
  final String studentName;
  final String status;
  final bool resultVisible;
  final int totalScore;
  final String? teacherComment;
  final DateTime createdAt;
  final Map<String, dynamic>? task;
  final List<Map<String, dynamic>>? answers;

  const MySubmissionModel({
    required this.id,
    required this.studentName,
    required this.status,
    required this.resultVisible,
    required this.totalScore,
    this.teacherComment,
    required this.createdAt,
    this.task,
    this.answers,
  });

  factory MySubmissionModel.fromJson(Map<String, dynamic> j) => MySubmissionModel(
        id: j['id'] as int,
        studentName: j['student_name'] as String,
        status: j['status'] as String,
        resultVisible: jsonBool(j['result_visible']),
        totalScore: j['total_score'] as int? ?? 0,
        teacherComment: j['teacher_comment'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
        task: j['task'] as Map<String, dynamic>?,
        answers: j['answers'] != null
            ? (j['answers'] as List<dynamic>)
                .map((e) => e as Map<String, dynamic>)
                .toList()
            : null,
      );
}

abstract class InterestingTaskRemoteDataSource {
  /// [listKind] — `interesting` (odatiy; API parametrsiz) yoki `project` (`kind=project`).
  Future<List<InterestingTaskModel>> getTasks({InterestingTasksListKind listKind = InterestingTasksListKind.interesting});
  Future<TaskWithQuestionsModel> getTask(
    int id, {
    InterestingTasksListKind? expectedKind,
  });
  Future<int> submit({
    required int taskId,
    required List<Map<String, dynamic>> answers,
  });
  Future<List<MySubmissionModel>> mySubmissions();
  Future<MySubmissionModel> mySubmissionDetail(int id);
}

class InterestingTaskRemoteDataSourceImpl implements InterestingTaskRemoteDataSource {
  final Dio dio;
  InterestingTaskRemoteDataSourceImpl({required this.dio});

  Future<Map<String, dynamic>> _getRoot(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) =>
      ResilientApiJson.getMap(dio, path, queryParameters: queryParameters);

  @override
  Future<List<InterestingTaskModel>> getTasks({InterestingTasksListKind listKind = InterestingTasksListKind.interesting}) async {
    final root = await _getRoot('/interesting-tasks', queryParameters: listKind.apiQuery);
    final list = root['data']?['tasks'] as List? ?? [];
    return list
        .map((e) => InterestingTaskModel.fromJson(e as Map<String, dynamic>))
        .where((task) => task.matchesListKind(listKind))
        .toList();
  }

  @override
  Future<TaskWithQuestionsModel> getTask(
    int id, {
    InterestingTasksListKind? expectedKind,
  }) async {
    final root = await _getRoot(
      '/interesting-tasks/$id',
      queryParameters: expectedKind?.apiQuery,
    );
    final task = TaskWithQuestionsModel.fromJson(
      root['data']?['task'] as Map<String, dynamic>,
    );
    if (expectedKind != null && !task.matchesListKind(expectedKind)) {
      throw StateError('Task kind mismatch');
    }
    return task;
  }

  @override
  Future<int> submit({
    required int taskId,
    required List<Map<String, dynamic>> answers,
  }) async {
    final res = await dio.post('/interesting-tasks/$taskId/submit', data: {
      'answers': answers,
    });
    return res.data['data']['submission_id'] as int;
  }

  @override
  Future<List<MySubmissionModel>> mySubmissions() async {
    final root = await _getRoot('/my-submissions');
    final list = root['data']?['submissions'] as List? ?? [];
    return list
        .map((e) => MySubmissionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MySubmissionModel> mySubmissionDetail(int id) async {
    final root = await _getRoot('/my-submissions/$id');
    return MySubmissionModel.fromJson(
      root['data']?['submission'] as Map<String, dynamic>,
    );
  }
}
