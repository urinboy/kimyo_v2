import '../../domain/entities/video.dart';
import '../../domain/repositories/video_repository.dart';
import '../datasources/video_remote_datasource.dart';

class VideoRepositoryImpl implements VideoRepository {
  final VideoRemoteDataSource remoteDataSource;
  VideoRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<VideoEntity>> getVideos({String? langCode}) =>
      remoteDataSource.getVideos(langCode: langCode);

  @override
  Future<VideoEntity> getVideo(int id, {String? langCode}) =>
      remoteDataSource.getVideo(id, langCode: langCode);
}
