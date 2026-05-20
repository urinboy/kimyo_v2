import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_video_detail.dart';
import '../../domain/usecases/get_videos.dart';
import 'video_event.dart';
import 'video_state.dart';

class VideoBloc extends Bloc<VideoEvent, VideoState> {
  final GetVideosUseCase getVideos;
  final GetVideoDetailUseCase getVideoDetail;

  VideoBloc({
    required this.getVideos,
    required this.getVideoDetail,
  }) : super(const VideoInitial()) {
    on<LoadVideosEvent>(_onLoadVideos);
    on<LoadVideoDetailEvent>(_onLoadDetail);
  }

  Future<void> _onLoadVideos(LoadVideosEvent event, Emitter<VideoState> emit) async {
    emit(const VideoLoading());
    try {
      final list = await getVideos(langCode: event.langCode);
      emit(VideosLoaded(list));
    } catch (e) {
      emit(VideoError(e.toString()));
    }
  }

  Future<void> _onLoadDetail(
    LoadVideoDetailEvent event,
    Emitter<VideoState> emit,
  ) async {
    emit(const VideoLoading());
    try {
      final video = await getVideoDetail(event.id, langCode: event.langCode);
      emit(VideoDetailLoaded(video));
    } catch (e) {
      emit(VideoError(e.toString()));
    }
  }
}
