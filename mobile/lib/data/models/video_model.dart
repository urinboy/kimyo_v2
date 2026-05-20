import '../../domain/entities/video.dart';

class VideoModel extends VideoEntity {
  const VideoModel({
    required super.id,
    required super.youtubeVideoId,
    required super.youtubeUrl,
    super.channelName,
    required super.title,
    super.description,
    required super.thumbnailUrl,
    required super.embedUrl,
    super.publishedAt,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    DateTime? published;
    final raw = json['published_at'];
    if (raw is String && raw.isNotEmpty) {
      published = DateTime.tryParse(raw);
    }

    return VideoModel(
      id: json['id'] as int,
      youtubeVideoId: json['youtube_video_id'] as String,
      youtubeUrl: json['youtube_url'] as String? ?? '',
      channelName: json['channel_name'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String? ?? '',
      embedUrl: json['embed_url'] as String? ?? '',
      publishedAt: published,
    );
  }
}
