import '../entities/three_d_model.dart';
import '../repositories/three_d_model_repository.dart';

class GetThreeDModelsUseCase {
  final ThreeDModelRepository repository;
  GetThreeDModelsUseCase(this.repository);

  Future<List<ThreeDModelEntity>> call({String? langCode}) =>
      repository.getThreeDModels(langCode: langCode);
}
