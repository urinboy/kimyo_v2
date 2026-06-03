import 'package:dio/dio.dart';

import '../../core/network/resilient_api_json.dart';
import '../models/three_d_model_model.dart';

abstract class ThreeDModelRemoteDataSource {
  Future<List<ThreeDModelModel>> getThreeDModels({String? langCode});
  Future<ThreeDModelModel> getThreeDModelDetail(int id, {String? langCode});
}

class ThreeDModelRemoteDataSourceImpl implements ThreeDModelRemoteDataSource {
  final Dio dio;
  ThreeDModelRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ThreeDModelModel>> getThreeDModels({String? langCode}) async {
    try {
      final data = await ResilientApiJson.getMap(
        dio,
        '/3d-models',
        queryParameters: langCode != null ? {'lang': langCode} : null,
      );
      final status = data['status']?.toString();
      if (status != 'success') {
        throw ApiResponseParseException(
          data['message']?.toString() ?? '3D modellar yuklanmadi (status: $status)',
        );
      }
      final raw = data['data']?['three_d_models'];
      if (raw == null) return [];
      return (raw as List)
          .map((e) => ThreeDModelModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiResponseParseException {
      return [];
    }
  }

  @override
  Future<ThreeDModelModel> getThreeDModelDetail(int id, {String? langCode}) async {
    final data = await ResilientApiJson.getMap(
      dio,
      '/3d-models/$id',
      queryParameters: langCode != null ? {'lang': langCode} : null,
    );
    final status = data['status']?.toString();
    if (status != 'success') {
      throw ApiResponseParseException(
        data['message']?.toString() ?? '3D model topilmadi',
      );
    }
    return ThreeDModelModel.fromJson(
      data['data']?['three_d_model'] as Map<String, dynamic>,
    );
  }
}
