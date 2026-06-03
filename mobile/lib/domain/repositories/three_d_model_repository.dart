import '../entities/three_d_model.dart';

abstract class ThreeDModelRepository {
  Future<List<ThreeDModelEntity>> getThreeDModels({String? langCode});
  Future<ThreeDModelEntity> getThreeDModelDetail(int id, {String? langCode});
}
