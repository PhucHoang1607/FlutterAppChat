import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    required this.color,
  });

  final String videoUrl;
  final Color color;

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late CachedVideoPlayerController videoPlayerController;
  bool isPlaying = true;
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    videoPlayerController = CachedVideoPlayerController.network(widget.videoUrl)
      ..addListener(() {})
      ..initialize().then((_) {
        videoPlayerController.setVolume(1);
        setState(() {
          isLoading = false;
        });
      });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : CachedVideoPlayer(videoPlayerController),
          Center(
            child: IconButton(
              onPressed: () {
                setState(() {
                  isPlaying = !isPlaying;
                  isPlaying
                      ? videoPlayerController.play()
                      : videoPlayerController.pause();
                });
              },
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
