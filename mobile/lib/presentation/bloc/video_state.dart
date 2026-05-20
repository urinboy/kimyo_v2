import 'package:equatable/equatable.dart';
import '../../domain/entities/video.dart';

abstract class VideoState extends Equatable {
  const VideoState();
  @override
  List<Object?> get props => [];
}

class VideoInitial extends VideoState {
  const VideoInitial();
}

class VideoLoading extends VideoState {
  const VideoLoading();
}

class VideosLoaded extends VideoState {
  final List<VideoEntity> videos;
  const VideosLoaded(this.videos);
  @override
  List<Object?> get props => [videos];
}

class VideoDetailLoaded extends VideoState {
  final VideoEntity video;
  const VideoDetailLoaded(this.video);
  @override
  List<Object?> get props => [video];
}

class VideoError extends VideoState {
  final String message;
  const VideoError(this.message);
  @override
  List<Object?> get props => [message];
}
