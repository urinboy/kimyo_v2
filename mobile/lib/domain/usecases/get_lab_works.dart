import '../entities/lab_work.dart';
import '../repositories/lab_work_repository.dart';

class GetLabWorksUseCase {
  final LabWorkRepository repository;
  GetLabWorksUseCase(this.repository);

  Future<List<LabWorkEntity>> call({String? langCode}) =>
      repository.getLabWorks(langCode: langCode);
}
