import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/colors.dart';
import '../../domain/entities/video.dart';
import '../bloc/video_bloc.dart';
import '../bloc/video_event.dart';
import '../bloc/video_state.dart';

class VideoDetailPage extends StatefulWidget {
  final int videoId;
  const VideoDetailPage({super.key, required this.videoId});

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  YoutubePlayerController? _playerController;
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

  @override
  void dispose() {
    _playerController?.close();
    super.dispose();
  }

  void _initPlayer(VideoEntity video) {
    if (_playerController != null) return;
    _playerController = YoutubePlayerController.fromVideoId(
      videoId: video.youtubeVideoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        mute: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.scaffoldBackgroundDark : AppColors.scaffoldBackground,
      body: BlocConsumer<VideoBloc, VideoState>(
        listener: (context, state) {
          if (state is VideoDetailLoaded) {
            _initPlayer(state.video);
            setState(() {});
          }
        },
        builder: (context, state) {
          if (state is VideoLoading || _playerController == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is VideoError) {
            return Center(child: Text(state.message));
          }
          if (state is! VideoDetailLoaded) {
            return const SizedBox.shrink();
          }

          final video = state.video;
          final meta = _formatMeta(context, video);

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: isDark ? Colors.black : Colors.white,
                foregroundColor: isDark ? Colors.white : Colors.black,
                title: Text(
                  context.tr('video_details'),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              SliverToBoxAdapter(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: YoutubePlayer(
                    controller: _playerController!,
                    aspectRatio: 16 / 9,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text(
                      video.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.15),
                          child: Icon(
                            Icons.play_circle_outline,
                            color: AppColors.primaryPurple,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                video.channelName ?? context.tr('videos_channel_default'),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              if (meta.isNotEmpty)
                                Text(
                                  meta,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? Colors.white54 : Colors.black45,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (video.description != null && video.description!.trim().isNotEmpty)
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
                                height: 1.45,
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
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatMeta(BuildContext context, VideoEntity video) {
    if (video.publishedAt == null) return '';
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat.yMMMd(locale).format(video.publishedAt!);
  }
}
