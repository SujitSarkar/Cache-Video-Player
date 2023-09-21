import 'package:flutter/material.dart';
import '../service/device_storage_service.dart';
import '../widgets/video_player_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Text('Cache and play video'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            VideoPlayerWidget(
              videoUrl:
                  'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
              cacheTimeout: Duration(minutes: 3),
            ),
            // const SizedBox(height: 20),
            // ElevatedButton(
            //     onPressed: () async {
            //       print(await DeviceStorageService.getAvailableSpaceInMb());
            //     },
            //     child: const Text('Available Storage')),
            // const SizedBox(height: 20),
            // ElevatedButton(
            //     onPressed: () async {
            //       print(await DeviceStorageService.getTotalSpaceInMb());
            //     },
            //     child: const Text('Total Storage')),
          ],
        ),
      ),
    );
  }
}
