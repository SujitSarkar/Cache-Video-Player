import 'package:flutter/material.dart';
import '../widgets/video_player_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.grey,
      body: Center(
        child: VideoPlayerWidget(
          videoUrl:
              'https://storage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
          cacheTimeout: Duration(minutes: 3),
        ),
      ),
    );
  }
}
