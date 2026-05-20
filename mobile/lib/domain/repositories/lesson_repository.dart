import 'package:dartz/dartz.dart';
import '../entities/lesson.dart';

abstract class LessonRepository {
  Future<Either<Exception, List<LessonEntity>>> getAllLessons();

  Future<Either<Exception, LessonEntity>> getLesson(int id);
}
