import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:video_player/video_player.dart';

class VideoBannerItem extends StatefulWidget {
  final String videoUrl;
  final VoidCallback? onCompleted;
  final bool shouldPlay;

  const VideoBannerItem({
    super.key,
    required this.videoUrl,
    this.onCompleted,
    this.shouldPlay = true,
  });

  @override
  State<VideoBannerItem> createState() => _VideoBannerItemState();
}

class _VideoBannerItemState extends State<VideoBannerItem> {
  VideoPlayerController? _videoPlayerController;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void didUpdateWidget(covariant VideoBannerItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldPlay != oldWidget.shouldPlay &&
        _videoPlayerController != null) {
      if (widget.shouldPlay) {
        _videoPlayerController!.play();
      } else {
        _videoPlayerController!.pause();
        _videoPlayerController!.seekTo(Duration.zero);
      }
    }
  }

  Future<void> _initializePlayer() async {
    try {
      final fileInfo = await DefaultCacheManager().getFileFromCache(
        widget.videoUrl,
      );
      File file;
      if (fileInfo != null) {
        file = fileInfo.file;
      } else {
        file = await DefaultCacheManager().getSingleFile(widget.videoUrl);
      }

      if (!mounted) return;

      _videoPlayerController = VideoPlayerController.file(file);
      await _videoPlayerController!.initialize();
      await _videoPlayerController!.setLooping(false); // Disable looping
      await _videoPlayerController!.setVolume(0); // Mute for banner

      if (widget.shouldPlay) {
        await _videoPlayerController!.play();
      }

      _videoPlayerController!.addListener(() {
        if (_videoPlayerController!.value.isCompleted) {
          widget.onCompleted?.call();
          // Optional: Restart if you want to loop until swap,
          // but request was "do auto swap when completed", implies finish -> swap.
          // If it stays on this page, maybe we shouldn't restart unless specifically asked.
          // However, if the slider handles the swap, we are good.
        }
      });

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      );
    }
    if (_error != null) {
      return Center(
        child: Text(
          'Error loading video: $_error',
          style: const TextStyle(color: Colors.white),
        ),
      );
    }
    return _videoPlayerController != null &&
            _videoPlayerController!.value.isInitialized
        ? SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: _videoPlayerController!.value.size.width,
                height: _videoPlayerController!.value.size.height,
                child: VideoPlayer(_videoPlayerController!),
              ),
            ),
          )
        : const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
  }
}
