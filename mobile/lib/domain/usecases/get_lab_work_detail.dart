import '../entities/lab_work.dart';
import '../repositories/lab_work_repository.dart';

class GetLabWorkDetailUseCase {
  final LabWorkRepository repository;
  GetLabWorkDetailUseCase(this.repository);

  Future<LabWorkEntity> call(int id, {String? langCode}) =>
      repository.getLabWork(id, langCode: langCode);
}
