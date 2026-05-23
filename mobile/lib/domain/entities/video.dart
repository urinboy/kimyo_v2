import 'package:equatable/equatable.dart';

class VideoEntity extends Equatable {
  final int id;
  final String? youtubeVideoId;
  final String? youtubeUrl;
  final String? videoUrl;       // Server-hosted video stream URL
  final String? channelName;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final String? embedUrl;
  final DateTime? publishedAt;

  const VideoEntity({
    required this.id,
    this.youtubeVideoId,
    this.youtubeUrl,
    this.videoUrl,
    this.channelName,
    required this.title,
    this.description,
    this.thumbnailUrl,
    this.embedUrl,
    this.publishedAt,
  });

  /// Server videosi bormi?
  bool get hasServerVideo => videoUrl != null && videoUrl!.isNotEmpty;

  /// YouTube video bormi?
  bool get hasYoutube =>
      youtubeVideoId != null && youtubeVideoId!.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        youtubeVideoId,
        youtubeUrl,
        videoUrl,
        channelName,
        title,
        description,
        thumbnailUrl,
        embedUrl,
        publishedAt,
      ];
}
