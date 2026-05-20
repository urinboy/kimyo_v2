import 'package:equatable/equatable.dart';

abstract class VideoEvent extends Equatable {
  const VideoEvent();
  @override
  List<Object?> get props => [];
}

class LoadVideosEvent extends VideoEvent {
  final String? langCode;
  const LoadVideosEvent({this.langCode});
  @override
  List<Object?> get props => [langCode];
}

class LoadVideoDetailEvent extends VideoEvent {
  final int id;
  final String? langCode;
  const LoadVideoDetailEvent(this.id, {this.langCode});
  @override
  List<Object?> get props => [id, langCode];
}
