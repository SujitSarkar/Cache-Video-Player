import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DeviceStorageService {
  static const channel = "com.example/invoke-java-method-channel";
  static const platform = MethodChannel(channel);

  Future<String> getAvailableSpace() async {
    String? storage;
    try {
      final String? result = await platform.invokeMethod('getAvailableSpace');
      storage = result;
    } catch (e) {
      debugPrint(e.toString());
    }
    return storage!;
  }

  Future<String> getTotalSpace() async {
    String? storage;
    try {
      final String? result = await platform.invokeMethod('getTotalSpace');
      storage = result;
    } catch (e) {
      debugPrint(e.toString());
    }
    return storage!;
  }
}
