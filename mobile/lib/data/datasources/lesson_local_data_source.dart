import '../models/lesson_model.dart';

/// Nazariy / mashg‘ulot darslari — mahalliy SQLite kesh (offline + sinxron keyingi bosqichlar uchun).
abstract class LessonLocalDataSource {
  Future<void> replaceAll(List<LessonModel> lessons);

  Future<void> upsertLesson(LessonModel lesson);

  Future<List<LessonModel>?> loadAllOrdered();

  Future<LessonModel?> loadOne(int id);
}
