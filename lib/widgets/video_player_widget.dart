import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';
import '../service/video_cache_service.dart';

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget(
      {super.key, required this.videoUrl, required this.cacheTimeout});
  final String videoUrl;
  final Duration cacheTimeout;

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

  void addVideoControllerListener() {
    videoPlayerController!.addListener(() {
      if (videoPlayerController != null &&
          videoPlayerController!.value.isCompleted) {
        setState(() {});
      }
    });
  }

  Future<void> onInit() async {
    // Open a box and store the bytes
    videoFile = await getCacheVideoFile(
        videoUrl: widget.videoUrl, cacheTimeout: widget.cacheTimeout);

    //video already cached
    if (videoFile != null) {
      videoPlayerController = VideoPlayerController.file(videoFile!)
        ..initialize().then((_) {
          setState(() {});
          videoPlayerController!.play();
        });
      addVideoControllerListener();
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
      addVideoControllerListener();
      debugPrint(
          'Video playing from online:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::');
      await cacheVideo(videoUrl: widget.videoUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return videoPlayerController == null
        ? const Center(child: CircularProgressIndicator())
        : AspectRatio(
            aspectRatio: videoPlayerController!.value.aspectRatio,
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(videoPlayerController!),
                Opacity(
                  opacity: 0.5,
                  child: Container(
                    height: double.infinity,
                    width: double.infinity,
                    color: Colors.black,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.fast_rewind,
                                    color: Colors.white, size: 40),
                                splashColor: Colors.white),
                            IconButton(
                                onPressed: () {
                                  if (videoPlayerController!.value.isPlaying) {
                                    videoPlayerController!.pause();
                                  } else {
                                    videoPlayerController!.play();
                                  }
                                  setState(() {});
                                },
                                icon: Icon(
                                    videoPlayerController!.value.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 44),
                                splashColor: Colors.white),
                            IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.fast_forward,
                                    color: Colors.white, size: 40),
                                splashColor: Colors.white),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
  }
}
