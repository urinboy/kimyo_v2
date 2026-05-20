import '../models/lesson_model.dart';
import 'lesson_local_data_source.dart';

/// Web: sqflite yo‘q — kesh yo‘q, faqat API.
class LessonLocalDataSourceImpl implements LessonLocalDataSource {
  @override
  Future<void> replaceAll(List<LessonModel> lessons) async {}

  @override
  Future<void> upsertLesson(LessonModel lesson) async {}

  @override
  Future<List<LessonModel>?> loadAllOrdered() async => null;

  @override
  Future<LessonModel?> loadOne(int id) async => null;
}
