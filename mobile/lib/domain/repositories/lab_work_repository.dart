import '../entities/lab_work.dart';

abstract class LabWorkRepository {
  Future<List<LabWorkEntity>> getLabWorks({String? langCode});
  Future<LabWorkEntity> getLabWork(int id, {String? langCode});
}
