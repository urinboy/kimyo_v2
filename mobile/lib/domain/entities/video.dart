import 'package:equatable/equatable.dart';

class VideoEntity extends Equatable {
  final int id;
  final String youtubeVideoId;
  final String youtubeUrl;
  final String? channelName;
  final String title;
  final String? description;
  final String thumbnailUrl;
  final String embedUrl;
  final DateTime? publishedAt;

  const VideoEntity({
    required this.id,
    required this.youtubeVideoId,
    required this.youtubeUrl,
    this.channelName,
    required this.title,
    this.description,
    required this.thumbnailUrl,
    required this.embedUrl,
    this.publishedAt,
  });

  @override
  List<Object?> get props => [
        id,
        youtubeVideoId,
        youtubeUrl,
        channelName,
        title,
        description,
        thumbnailUrl,
        embedUrl,
        publishedAt,
      ];
}
