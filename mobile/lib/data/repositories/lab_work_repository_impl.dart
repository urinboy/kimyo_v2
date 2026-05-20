import '../../domain/entities/lab_work.dart';
import '../../domain/repositories/lab_work_repository.dart';
import '../datasources/lab_work_remote_datasource.dart';

class LabWorkRepositoryImpl implements LabWorkRepository {
  final LabWorkRemoteDataSource remoteDataSource;

  LabWorkRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<LabWorkEntity>> getLabWorks({String? langCode}) =>
      remoteDataSource.getLabWorks(langCode: langCode);

  @override
  Future<LabWorkEntity> getLabWork(int id, {String? langCode}) =>
      remoteDataSource.getLabWork(id, langCode: langCode);
}
