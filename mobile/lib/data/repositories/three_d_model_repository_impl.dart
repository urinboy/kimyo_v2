import '../../domain/entities/three_d_model.dart';
import '../../domain/repositories/three_d_model_repository.dart';
import '../datasources/three_d_model_remote_datasource.dart';

class ThreeDModelRepositoryImpl implements ThreeDModelRepository {
  final ThreeDModelRemoteDataSource remoteDataSource;
  ThreeDModelRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ThreeDModelEntity>> getThreeDModels({String? langCode}) =>
      remoteDataSource.getThreeDModels(langCode: langCode);

  @override
  Future<ThreeDModelEntity> getThreeDModelDetail(int id, {String? langCode}) =>
      remoteDataSource.getThreeDModelDetail(id, langCode: langCode);
}
