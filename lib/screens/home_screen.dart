import 'package:flutter/material.dart';
import '../service/device_storage_service.dart';
import '../widgets/video_player_widget.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final DeviceStorageService deviceStorageService = DeviceStorageService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cache and play video'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const VideoPlayerWidget(
                videoUrl:
                    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4'),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () async {
                  print(await deviceStorageService.getAvailableSpace());
                },
                child: const Text('Available Storage')),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () async {
                  print(await deviceStorageService.getTotalSpace());
                },
                child: const Text('Total Storage')),
          ],
        ),
      ),
    );
  }
}
