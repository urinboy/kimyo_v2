import '../entities/video.dart';

abstract class VideoRepository {
  Future<List<VideoEntity>> getVideos({String? langCode});
  Future<VideoEntity> getVideo(int id, {String? langCode});
}
