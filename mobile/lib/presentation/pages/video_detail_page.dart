import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/colors.dart';
import '../../domain/entities/video.dart';
import '../bloc/video_bloc.dart';
import '../bloc/video_event.dart';
import '../bloc/video_state.dart';
import '../widgets/unified_video_player.dart';

class VideoDetailPage extends StatefulWidget {
  final int videoId;
  const VideoDetailPage({super.key, required this.videoId});

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  bool _descExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lang = Localizations.localeOf(context).languageCode;
      context.read<VideoBloc>().add(
            LoadVideoDetailEvent(widget.videoId, langCode: lang),
          );
    });
  }

  Future<void> _openExternal(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.scaffoldBackgroundDark : AppColors.scaffoldBackground,
      body: BlocBuilder<VideoBloc, VideoState>(
        builder: (context, state) {
          if (state is VideoLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is VideoError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 56,
                        color: isDark ? Colors.white38 : Colors.black26),
                    const SizedBox(height: 12),
                    Text(state.message, textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }
          if (state is! VideoDetailLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final video = state.video;
          final externalUrl = video.youtubeUrl ?? video.videoUrl;

          return CustomScrollView(
            slivers: [
              // AppBar
              SliverAppBar(
                pinned: true,
                backgroundColor: isDark ? Colors.black : Colors.white,
                foregroundColor: isDark ? Colors.white : Colors.black,
                title: Text(
                  video.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15),
                ),
                actions: [
                  if (externalUrl != null)
                    IconButton(
                      icon: const Icon(Icons.open_in_new_rounded),
                      tooltip: video.hasServerVideo ? 'Tashqi brauzerda ochish' : 'YouTube-da ochish',
                      onPressed: () => _openExternal(externalUrl),
                    ),
                ],
              ),

              // Video player (YouTube yoki Server)
              SliverToBoxAdapter(
                child: UnifiedVideoPlayer(key: ValueKey(video.id), video: video),
              ),

              // Info qismi
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Title
                    Text(
                      video.title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Channel + sana + tashqi link
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.15),
                          child: Icon(Icons.science_rounded,
                              color: AppColors.primaryPurple, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                video.channelName ?? context.tr('videos_channel_default'),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              if (video.publishedAt != null)
                                Text(
                                  _formatDate(context, video.publishedAt!),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white54 : Colors.black45,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Tashqi link tugmasi
                        if (externalUrl != null)
                          OutlinedButton.icon(
                            onPressed: () => _openExternal(externalUrl),
                            icon: const Icon(Icons.open_in_new, size: 16),
                            label: Text(
                              video.hasServerVideo ? 'Brauzer' : 'YouTube',
                              style: const TextStyle(fontSize: 12),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: video.hasServerVideo
                                  ? AppColors.primaryPurple
                                  : const Color(0xFFFF0000),
                              side: BorderSide(
                                color: video.hasServerVideo
                                    ? AppColors.primaryPurple
                                    : const Color(0xFFFF0000),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                            ),
                          ),
                      ],
                    ),

                    // Source badge
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (video.hasServerVideo)
                          _SourceBadge(
                            icon: Icons.storage_rounded,
                            label: 'Server video',
                            color: AppColors.primaryPurple,
                          ),
                        if (video.hasServerVideo && video.hasYoutube)
                          const SizedBox(width: 8),
                        if (video.hasYoutube)
                          _SourceBadge(
                            icon: Icons.play_circle_outline,
                            label: 'YouTube',
                            color: const Color(0xFFFF0000),
                          ),
                      ],
                    ),

                    // Description
                    if (video.description != null &&
                        video.description!.trim().isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.black.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _descExpanded || video.description!.length < 160
                                  ? video.description!
                                  : '${video.description!.substring(0, 160)}…',
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                            if (video.description!.length >= 160)
                              TextButton(
                                onPressed: () =>
                                    setState(() => _descExpanded = !_descExpanded),
                                child: Text(
                                  _descExpanded
                                      ? context.tr('show_less')
                                      : context.tr('show_more'),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat.yMMMd(locale).format(date);
  }
}

class _SourceBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SourceBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
