import 'package:dio/dio.dart';

import '../../core/network/resilient_api_json.dart';
import '../models/video_model.dart';

abstract class VideoRemoteDataSource {
  Future<List<VideoModel>> getVideos({String? langCode});
  Future<VideoModel> getVideo(int id, {String? langCode});
}

class VideoRemoteDataSourceImpl implements VideoRemoteDataSource {
  final Dio dio;
  VideoRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<VideoModel>> getVideos({String? langCode}) async {
    try {
      final data = await ResilientApiJson.getMap(
        dio,
        '/videos',
        queryParameters: langCode != null ? {'lang': langCode} : null,
      );
      final status = data['status']?.toString();
      if (status != 'success') {
        throw ApiResponseParseException(
          data['message']?.toString() ?? 'Videolar yuklanmadi (status: $status)',
        );
      }
      final raw = data['data']?['videos'];
      if (raw == null) return [];
      final list = raw as List;
      return list
          .map((e) => VideoModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiResponseParseException {
      // Server JSON emas (HTML) yoki route yo'q → bo'sh ro'yxat qaytaramiz
      return [];
    }
  }

  @override
  Future<VideoModel> getVideo(int id, {String? langCode}) async {
    final data = await ResilientApiJson.getMap(
      dio,
      '/videos/$id',
      queryParameters: langCode != null ? {'lang': langCode} : null,
    );
    final status = data['status']?.toString();
    if (status != 'success') {
      throw ApiResponseParseException(
        data['message']?.toString() ?? 'Video topilmadi',
      );
    }
    return VideoModel.fromJson(
      data['data']?['video'] as Map<String, dynamic>,
    );
  }
}
