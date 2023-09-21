import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DeviceStorageService {
  static const channel = "com.example/invoke-java-method-channel";
  static const platform = MethodChannel(channel);

  static Future<String> getAvailableSpaceInMb() async {
    String? storage;
    if (Platform.isAndroid) {
      try {
        final String? result = await platform.invokeMethod('getAvailableSpace');
        storage = result;
      } catch (e) {
        debugPrint(e.toString());
      }
      return storage ?? '0';
    } else if (Platform.isIOS) {
      return storage ?? '0';
    } else {
      return storage ?? '0';
    }
  }

  static Future<String> getTotalSpaceInMb() async {
    String? storage;
    if (Platform.isAndroid) {
      try {
        final String? result = await platform.invokeMethod('getTotalSpace');
        storage = result;
      } catch (e) {
        debugPrint(e.toString());
      }
      return storage ?? '0';
    } else if (Platform.isIOS) {
      return storage ?? '0';
    } else {
      return storage ?? '0';
    }
  }
}
