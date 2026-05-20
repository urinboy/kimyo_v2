import 'package:dartz/dartz.dart';
import '../entities/lesson.dart';
import '../repositories/lesson_repository.dart';

class GetLessonsUseCase {
  final LessonRepository repository;

  GetLessonsUseCase(this.repository);

  Future<Either<Exception, List<LessonEntity>>> call() async {
    return await repository.getAllLessons();
  }
}
