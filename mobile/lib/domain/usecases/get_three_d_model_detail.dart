import '../entities/three_d_model.dart';
import '../repositories/three_d_model_repository.dart';

class GetThreeDModelDetailUseCase {
  final ThreeDModelRepository repository;
  GetThreeDModelDetailUseCase(this.repository);

  Future<ThreeDModelEntity> call(int id, {String? langCode}) =>
      repository.getThreeDModelDetail(id, langCode: langCode);
}
