import '../entities/video.dart';
import '../repositories/video_repository.dart';

class GetVideoDetailUseCase {
  final VideoRepository repository;
  GetVideoDetailUseCase(this.repository);

  Future<VideoEntity> call(int id, {String? langCode}) =>
      repository.getVideo(id, langCode: langCode);
}
