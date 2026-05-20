import 'package:dartz/dartz.dart';

import '../../domain/entities/lesson.dart';
import '../../domain/repositories/lesson_repository.dart';
import '../datasources/lesson_local_data_source.dart';
import '../datasources/lesson_remote_data_source.dart';

class LessonRepositoryImpl implements LessonRepository {
  final LessonRemoteDataSource remoteDataSource;
  final LessonLocalDataSource localDataSource;

  LessonRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Exception, List<LessonEntity>>> getAllLessons() async {
    try {
      final lessons = await remoteDataSource.getAllLessons();
      await localDataSource.replaceAll(lessons);
      return Right(lessons);
    } catch (e) {
      final cached = await localDataSource.loadAllOrdered();
      if (cached != null && cached.isNotEmpty) {
        return Right(cached);
      }
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, LessonEntity>> getLesson(int id) async {
    try {
      final lesson = await remoteDataSource.getLesson(id);
      await localDataSource.upsertLesson(lesson);
      return Right(lesson);
    } catch (e) {
      final cached = await localDataSource.loadOne(id);
      if (cached != null) return Right(cached);
      return Left(Exception(e.toString()));
    }
  }
}
