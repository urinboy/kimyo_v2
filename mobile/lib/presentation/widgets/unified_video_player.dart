import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../domain/entities/video.dart';

/// YouTube yoki server-hosted video uchun yagona player.
///
/// Ustuvorlik tartibi:
///   1. [video.hasServerVideo] → Chewie (video_player)
///   2. [video.hasYoutube]     → YoutubePlayerIframe
///   3. Hech narsa yo'q        → xato widgeti
class UnifiedVideoPlayer extends StatefulWidget {
  final VideoEntity video;

  const UnifiedVideoPlayer({super.key, required this.video});

  @override
  State<UnifiedVideoPlayer> createState() => _UnifiedVideoPlayerState();
}

class _UnifiedVideoPlayerState extends State<UnifiedVideoPlayer> {
  // ── Chewie ──────────────────────────────────────────────────────────────
  VideoPlayerController? _vpController;
  ChewieController? _chewieController;
  bool _chewieReady = false;
  String? _chewieError;

  // ── YouTube ─────────────────────────────────────────────────────────────
  YoutubePlayerController? _ytController;
  bool _ytError = false;

  @override
  void initState() {
    super.initState();
    if (widget.video.hasServerVideo) {
      _initChewie();
    } else if (widget.video.hasYoutube) {
      _initYoutube();
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _vpController?.dispose();
    _ytController?.close();
    super.dispose();
  }

  // ── Init ─────────────────────────────────────────────────────────────────

  void _initChewie() {
    _vpController = VideoPlayerController.networkUrl(
      Uri.parse(widget.video.videoUrl!),
    );
    _vpController!.initialize().then((_) {
      if (!mounted) return;
      _chewieController = ChewieController(
        videoPlayerController: _vpController!,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        placeholder: _thumbnail(),
        errorBuilder: (context, msg) => _ErrorOverlay(
          message: msg,
          onOpenUrl: widget.video.youtubeUrl != null
              ? () => _openUrl(widget.video.youtubeUrl!)
              : null,
        ),
      );
      setState(() => _chewieReady = true);
    }).catchError((e) {
      if (!mounted) return;
      setState(() => _chewieError = e.toString());
    });
  }

  void _initYoutube() {
    _ytController = YoutubePlayerController.fromVideoId(
      videoId: widget.video.youtubeVideoId!,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        mute: false,
        enableJavaScript: true,
      ),
    );

    _ytController!.stream.listen((value) {
      final fatal = value.error == YoutubeError.notEmbeddable ||
          value.error == YoutubeError.sameAsNotEmbeddable ||
          value.error == YoutubeError.videoNotFound ||
          value.error == YoutubeError.cannotFindVideo;
      if (fatal && mounted && !_ytError) {
        setState(() => _ytError = true);
      }
    });
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _thumbnail() {
    final url = widget.video.thumbnailUrl;
    if (url == null || url.isEmpty) return Container(color: Colors.black);
    return Image.network(url, fit: BoxFit.cover);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (widget.video.hasServerVideo) {
      return _buildChewie();
    }
    if (widget.video.hasYoutube) {
      return _buildYoutube();
    }
    return _noSource();
  }

  Widget _buildChewie() {
    if (_chewieError != null) {
      return _ErrorOverlay(
        message: 'Video ochilmadi',
        onOpenUrl: widget.video.youtubeUrl != null
            ? () => _openUrl(widget.video.youtubeUrl!)
            : null,
      );
    }
    if (!_chewieReady) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _thumbnail(),
            Container(color: Colors.black45),
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          ],
        ),
      );
    }
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Chewie(controller: _chewieController!),
    );
  }

  Widget _buildYoutube() {
    if (_ytError) {
      return _ErrorOverlay(
        message: 'Video ilovada ochilmayapti',
        thumbnail: widget.video.thumbnailUrl,
        onOpenUrl: widget.video.youtubeUrl != null
            ? () => _openUrl(widget.video.youtubeUrl!)
            : null,
      );
    }
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: YoutubePlayer(
        controller: _ytController!,
        aspectRatio: 16 / 9,
      ),
    );
  }

  Widget _noSource() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black87,
        child: const Center(
          child: Text(
            'Video manbasi topilmadi',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ),
    );
  }
}

// ─── Error overlay ──────────────────────────────────────────────────────────

class _ErrorOverlay extends StatelessWidget {
  final String message;
  final String? thumbnail;
  final VoidCallback? onOpenUrl;

  const _ErrorOverlay({
    required this.message,
    this.thumbnail,
    this.onOpenUrl,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (thumbnail != null)
            Image.network(thumbnail!, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.black)),
          Container(color: Colors.black.withValues(alpha: 0.65)),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.play_circle_outline, color: Colors.white60, size: 48),
              const SizedBox(height: 8),
              Text(message,
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
              if (onOpenUrl != null) ...[
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: onOpenUrl,
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: const Text("YouTube-da ko'rish"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF0000),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
