import 'package:flutter/material.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:video_player/video_player.dart';

class VideoItemWidget extends StatefulWidget {
  final String videoPath;
  final VoidCallback? onVideoCompleted;
  final bool shouldLoop;

  const VideoItemWidget({
    super.key,
    required this.videoPath,
    this.onVideoCompleted,
    this.shouldLoop = false,
  });

  @override
  State<VideoItemWidget> createState() => _VideoItemWidgetState();
}

class _VideoItemWidgetState extends State<VideoItemWidget> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        // Ensure the widget is still mounted before calling setState
        if (mounted) {
          setState(() {
            _initialized = true;
            _controller.setLooping(widget.shouldLoop);
            _controller.setVolume(0.0); // Mute audio
            _controller.play();
          });
        }
      });

    _controller.addListener(() {
      if (_controller.value.position >= _controller.value.duration &&
          _controller.value.duration != Duration.zero) {
        if (widget.onVideoCompleted != null) widget.onVideoCompleted!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _initialized
            ? SizedBox.expand(
                child: Transform.scale(
                  scale:
                      1.005, // Scale up slightly to prevent thin lines at edges
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                ),
              )
            : Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              ),
      ),
    );
  }
}
