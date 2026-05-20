import '../entities/video.dart';
import '../repositories/video_repository.dart';

class GetVideosUseCase {
  final VideoRepository repository;
  GetVideosUseCase(this.repository);

  Future<List<VideoEntity>> call({String? langCode}) =>
      repository.getVideos(langCode: langCode);
}
