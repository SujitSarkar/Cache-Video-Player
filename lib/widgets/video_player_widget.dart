import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';
import '../service/video_cache_service.dart';

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({super.key, required this.videoUrl});
  final String videoUrl;

  @override
  State<VideoPlayerWidget> createState() => VideoPlayerWidgetState();
}

class VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? videoPlayerController;
  late DefaultCacheManager cacheManager;
  File? videoFile;

  @override
  void initState() {
    cacheManager = DefaultCacheManager();
    onInit();
    super.initState();
  }

  @override
  void dispose() {
    videoPlayerController!.dispose();
    super.dispose();
  }

  Future<void> onInit() async {
    // Open a box and store the bytes
    videoFile = await retrieveVideoFile(videoUrl: widget.videoUrl);

    //video already cached
    if (videoFile != null) {
      videoPlayerController = VideoPlayerController.file(videoFile!)
        ..initialize().then((_) {
          setState(() {});
          videoPlayerController!.play();
        });
      debugPrint(
          'Video playing from cache:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::');
    } else {
      //video didn't cache yet
      videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
            ..initialize().then((_) {
              setState(() {});
              videoPlayerController!.play();
            });
      debugPrint(
          'Video playing from online:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::');
      await storeVideo(videoUrl: widget.videoUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return videoPlayerController == null
        ? const Center(child: CircularProgressIndicator())
        : AspectRatio(
            aspectRatio: videoPlayerController!.value.aspectRatio,
            child: VideoPlayer(videoPlayerController!),
          );
  }
}
