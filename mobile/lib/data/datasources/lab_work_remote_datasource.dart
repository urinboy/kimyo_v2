import 'package:dio/dio.dart';

import '../../core/network/resilient_api_json.dart';
import '../models/lab_work_model.dart';

abstract class LabWorkRemoteDataSource {
  Future<List<LabWorkModel>> getLabWorks({String? langCode});
  Future<LabWorkModel> getLabWork(int id, {String? langCode});
}

class LabWorkRemoteDataSourceImpl implements LabWorkRemoteDataSource {
  final Dio dio;

  LabWorkRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<LabWorkModel>> getLabWorks({String? langCode}) async {
    final data = await ResilientApiJson.getMap(
      dio,
      '/lab-works',
      queryParameters: langCode != null ? {'lang': langCode} : null,
    );
    final list = data['data']?['lab_works'] as List? ?? [];
    return list
        .map((e) => LabWorkModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<LabWorkModel> getLabWork(int id, {String? langCode}) async {
    final data = await ResilientApiJson.getMap(
      dio,
      '/lab-works/$id',
      queryParameters: langCode != null ? {'lang': langCode} : null,
    );
    return LabWorkModel.fromJson(
      data['data']?['lab_work'] as Map<String, dynamic>,
    );
  }
}
