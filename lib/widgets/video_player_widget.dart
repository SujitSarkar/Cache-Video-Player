import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  int remainingDurationInSec = 0;
  bool showVideoControl = false;
  bool isFullScreen = false;

  @override
  void initState() {
    cacheManager = DefaultCacheManager();
    //Show video control
    if (videoPlayerController != null) {
      showVideoControl = true;
      Future.delayed(const Duration(seconds: 3))
          .then((value) => setState(() => showVideoControl = false));
    }
    onInit();
    // Lock to portrait mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.initState();
  }

  @override
  void dispose() {
    videoPlayerController!.dispose();
    // Reset to default orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  void showControl() {
    showVideoControl = true;
    setState(() {});
    Future.delayed(const Duration(seconds: 5))
        .then((value) => setState(() => showVideoControl = false));
  }

  void hideControl() {
    showVideoControl = false;
    setState(() {});
  }

  void addVideoControllerListener() async {
    videoPlayerController!.addListener(() {
      if (videoPlayerController != null) {
        remainingDurationInSec =
            videoPlayerController!.value.duration.inSeconds -
                videoPlayerController!.value.position.inSeconds;
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
    final Size size = MediaQuery.of(context).size;
    return videoPlayerController == null
        ? const Center(child: CircularProgressIndicator())
        : AspectRatio(
            aspectRatio: videoPlayerController!.value.aspectRatio,
            child: Stack(
              alignment: Alignment.center,
              children: [
                GestureDetector(
                    onTap: showControl,
                    child: VideoPlayer(videoPlayerController!)),
                showVideoControl
                    ? GestureDetector(
                        onTap: hideControl,
                        child: Opacity(
                          opacity: 0.5,
                          child: Container(
                            height:
                                isFullScreen ? size.height : double.infinity,
                            width: isFullScreen ? size.width : double.infinity,
                            color: Colors.black,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          rewindVideo();
                                        },
                                        icon: const Icon(Icons.fast_rewind,
                                            color: Colors.white, size: 40),
                                        splashColor: Colors.white),
                                    videoPlayerController!.value.isBuffering
                                        ? const SizedBox(
                                            height: 28,
                                            width: 28,
                                            child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.5))
                                        : IconButton(
                                            onPressed: () {
                                              if (videoPlayerController!
                                                  .value.isPlaying) {
                                                videoPlayerController!.pause();
                                              } else {
                                                videoPlayerController!.play();
                                              }
                                              setState(() {});
                                            },
                                            icon: Icon(
                                                videoPlayerController!
                                                        .value.isPlaying
                                                    ? Icons.pause
                                                    : Icons.play_arrow,
                                                color: Colors.white,
                                                size: 44),
                                            splashColor: Colors.white),
                                    IconButton(
                                        onPressed: () {
                                          forwardVideo();
                                        },
                                        icon: const Icon(Icons.fast_forward,
                                            color: Colors.white, size: 40),
                                        splashColor: Colors.white),
                                  ],
                                ),
                                Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: VideoProgressIndicator(
                                              videoPlayerController!,
                                              allowScrubbing: true,
                                              padding: const EdgeInsets.all(10),
                                              colors: const VideoProgressColors(
                                                  backgroundColor: Colors.grey,
                                                  bufferedColor: Colors.white,
                                                  playedColor: Colors.red)),
                                        ),
                                        Text(
                                          ' ${formatDuration(remainingDurationInSec)}',
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ],
                                    )),
                                Positioned(
                                  bottom: 10,
                                  right: 0,
                                  child: IconButton(
                                      onPressed: () {
                                        toggleFullScreen();
                                      },
                                      icon: Icon(
                                        isFullScreen
                                            ? Icons.fullscreen_exit
                                            : Icons.fullscreen,
                                        color: Colors.white,
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink()
              ],
            ),
          );
  }

  void forwardVideo() {
    final currentPosition = videoPlayerController!.value.position;
    final forwardPosition = currentPosition + const Duration(seconds: 10);
    videoPlayerController!.seekTo(forwardPosition);
  }

  void rewindVideo() {
    final currentPosition = videoPlayerController!.value.position;
    final rewindPosition = currentPosition - const Duration(seconds: 10);
    videoPlayerController!.seekTo(rewindPosition);
  }

  void toggleFullScreen() {
    if (isFullScreen) {
      // Exit full screen
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      // Show the status bar
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    } else {
      // Enter full screen
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      // Hide the status bar
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.bottom]);
    }

    setState(() {
      isFullScreen = !isFullScreen;
    });
  }

  String formatDuration(int seconds) {
    int hours = seconds ~/ 3600;
    seconds = seconds % 3600;
    int minutes = seconds ~/ 60;
    seconds = seconds % 60;
    return '${hours.toString()}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
