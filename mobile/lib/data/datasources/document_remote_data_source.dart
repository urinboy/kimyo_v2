import 'package:dio/dio.dart';

import '../../core/network/resilient_api_json.dart';
import '../models/document_model.dart';

abstract class DocumentRemoteDataSource {
  Future<List<DocumentModel>> getAll({String? category});
}

class DocumentRemoteDataSourceImpl implements DocumentRemoteDataSource {
  DocumentRemoteDataSourceImpl({required this.dio});

  final Dio dio;

  @override
  Future<List<DocumentModel>> getAll({String? category}) async {
    final params = <String, dynamic>{};
    if (category != null) params['category'] = category;

    final data = await ResilientApiJson.getMap(
      dio,
      '/documents',
      queryParameters: params.isEmpty ? null : params,
    );
    final list = (data['data']?['documents'] ?? data['documents'] ?? []) as List;
    return list
        .cast<Map<String, dynamic>>()
        .map(DocumentModel.fromJson)
        .toList();
  }
}
