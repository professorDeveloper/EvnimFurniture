import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/app_texts.dart';
import '../../domain/model/story_item.dart';

class StoryViewerScreen extends StatefulWidget {
  const StoryViewerScreen({
    super.key,
    required this.items,
    required this.initialIndex,
  });

  final List<StoryItem> items;
  final int initialIndex;

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen>
    with TickerProviderStateMixin {
  late int _index;
  late AnimationController _progressController;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isVideoLoading = false;
  bool _hasVideoError = false;

  StoryItem get _current => widget.items[_index];

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _progressController = AnimationController(vsync: this);
    _loadCurrentMedia();
    _startTimer();
  }

  bool get _isVideo {
    final type = _current.mediaType.toLowerCase();
    final url = _current.mediaUrl.toLowerCase();
    return type.contains('video') ||
        url.endsWith('.mp4') ||
        url.endsWith('.mov') ||
        url.endsWith('.webm') ||
        url.endsWith('.m3u8');
  }

  Future<void> _loadCurrentMedia() async {
    if (_isVideo) {
      await _initVideo();
    }
  }

  Future<void> _initVideo() async {
    _disposeVideo();
    _isVideoLoading = true;
    _hasVideoError = false;

    if (mounted) setState(() {});

    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(_current.mediaUrl),
      );

      await _videoController!.initialize();

      if (mounted && _videoController!.value.isInitialized) {
        _chewieController = ChewieController(
          videoPlayerController: _videoController!,
          autoPlay: true,
          looping: true,
          showControls: false,
          showOptions: false,
          autoInitialize: true,
          allowMuting: false,
          allowPlaybackSpeedChanging: false,
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.videocam_off,
                      color: Colors.white54, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    AppTexts.videoError.tr(),
                    style:
                        TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            );
          },
        );
        _isVideoLoading = false;
        if (mounted) setState(() {});
      }
    } catch (e) {
      _hasVideoError = true;
      _isVideoLoading = false;
      if (mounted) setState(() {});
    }
  }

  void _disposeVideo() {
    _chewieController?.dispose();
    _chewieController = null;
    _videoController?.dispose();
    _videoController = null;
  }

  void _startTimer() {
    _progressController.reset();
    final duration = Duration(seconds: _current.duration.clamp(3, 30));
    _progressController.duration = duration;
    _progressController.forward().then((_) {
      if (mounted) _goToNext();
    });
  }

  void _pauseTimer() {
    _progressController.stop();
    _videoController?.pause();
  }

  void _resumeTimer() {
    _videoController?.play();
    _startTimer();
  }

  void _goToNext() {
    if (_index < widget.items.length - 1) {
      _index++;
      _loadCurrentMedia().then((_) {
        if (mounted) _startTimer();
      });
      if (mounted) setState(() {});
    } else {
      Navigator.of(context).pop();
    }
  }

  void _goToPrev() {
    if (_index > 0) {
      _index--;
      _loadCurrentMedia().then((_) {
        if (mounted) _startTimer();
      });
      if (mounted) setState(() {});
    } else {
      _progressController.reset();
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    _disposeVideo();
    _progressController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return AppTexts.timeNow.tr();
    if (diff.inMinutes < 60) return AppTexts.timeMinutesAgo.tr(args: ['${diff.inMinutes}']);
    if (diff.inHours < 24) return AppTexts.timeHoursAgo.tr(args: ['${diff.inHours}']);
    if (diff.inDays < 7) return AppTexts.timeDaysAgo.tr(args: ['${diff.inDays}']);
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatViews(int views) {
    if (views >= 1000000) return '${(views / 1000000).toStringAsFixed(1)}M';
    if (views >= 1000) return '${(views / 1000).toStringAsFixed(1)}K';
    return views.toString();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final screenWidth = MediaQuery.of(context).size.width;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTapDown: (details) {
            if (details.globalPosition.dx < screenWidth * 0.35) {
              _goToPrev();
            } else {
              _goToNext();
            }
          },
          onLongPressStart: (_) => _pauseTimer(),
          onLongPressEnd: (_) => _resumeTimer(),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildMedia(),
              _buildGradient(topPadding),
              _buildProgressBars(topPadding),
              _buildCloseButton(topPadding),
              _buildContent(topPadding),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedia() {
    if (_isVideo) {
      if (_isVideoLoading) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      }
      if (_hasVideoError || _chewieController == null) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.videocam_off, color: Colors.white54, size: 64),
              const SizedBox(height: 16),
              Text(
                AppTexts.videoLoadFailed.tr(),
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              ),
            ],
          ),
        );
      }
      return Chewie(controller: _chewieController!);
    }

    return CachedNetworkImage(
      key: ValueKey(_current.id),
      imageUrl: _current.mediaUrl,
      memCacheWidth: 800,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (_, __) => const ColoredBox(color: Color(0xFF111111)),
      errorWidget: (_, __, ___) => const ColoredBox(
        color: Color(0xFF111111),
        child: Center(
          child: Icon(Icons.broken_image, color: Colors.white24, size: 64),
        ),
      ),
    );
  }

  Widget _buildGradient(double topPadding) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: topPadding + 120,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.7),
                  Colors.transparent
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 180,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.8),
                  Colors.transparent
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBars(double topPadding) {
    return Positioned(
      top: topPadding + 10,
      left: 12,
      right: 12,
      child: Row(
        children: List.generate(widget.items.length, (i) {
          if (i < _index) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: LinearProgressIndicator(
                  value: 1,
                  backgroundColor: Colors.white30,
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                  minHeight: 2.5,
                ),
              ),
            );
          } else if (i == _index) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: AnimatedBuilder(
                  animation: _progressController,
                  builder: (_, __) => LinearProgressIndicator(
                    value: _progressController.value,
                    backgroundColor: Colors.white30,
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                    minHeight: 2.5,
                  ),
                ),
              ),
            );
          } else {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: LinearProgressIndicator(
                  value: 0,
                  backgroundColor: Colors.white30,
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                  minHeight: 2.5,
                ),
              ),
            );
          }
        }),
      ),
    );
  }

  Widget _buildCloseButton(double topPadding) {
    return Positioned(
      top: topPadding + 16,
      right: 14,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.3),
          ),
          child: const Icon(Icons.close, color: Colors.white, size: 18),
        ),
      ),
    );
  }

  Widget _buildContent(double topPadding) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: topPadding + 40,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _current.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.black54, blurRadius: 10)],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (_current.viewsCount > 0) ...[
                Icon(Icons.visibility,
                    color: Colors.white.withValues(alpha: 0.8), size: 16),
                const SizedBox(width: 4),
                Text(
                  _formatViews(_current.viewsCount),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 16),
              ],
              if (_current.createdAt != null) ...[
                Icon(Icons.access_time,
                    color: Colors.white.withValues(alpha: 0.8), size: 16),
                const SizedBox(width: 4),
                Text(
                  _formatDate(_current.createdAt),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
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
