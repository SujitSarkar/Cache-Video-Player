import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hive/hive.dart';

Future<void> storeVideo({required String videoUrl}) async {
  final File tempVideoFile =
      await DefaultCacheManager().getSingleFile(videoUrl);
  // Convert your file into bytes
  final Uint8List fileBytes = await tempVideoFile.readAsBytes();
  // Open a box and store the bytes
  var box = await Hive.openBox('myBox');
  await box.put(videoUrl, fileBytes);
}

Future<File?> retrieveVideoFile({required String videoUrl}) async {
  var box = await Hive.openBox('myBox');
  var fileBytes = box.get(videoUrl) as Uint8List?;

  if (fileBytes != null) {
    final File videoFile = await DefaultCacheManager().getSingleFile(videoUrl);
    final DateTime fileLastModified = await videoFile.lastModified();
    final Duration ageDuration = DateTime.now().difference(fileLastModified);
    if (ageDuration > const Duration(minutes: 2)) {
      DefaultCacheManager().removeFile(videoUrl);
      box.delete(videoUrl);
      debugPrint(
          'Video Timeout:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::');
      return null;
    } else {
      return await videoFile.writeAsBytes(fileBytes);
    }
  }
  return null;
}
