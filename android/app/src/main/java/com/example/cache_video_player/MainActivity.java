package com.example.cache_video_player;
import io.flutter.embedding.android.FlutterActivity;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Bundle;

//Required plugin to get device storage
import android.os.Environment;
import android.os.StatFs;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example/invoke-java-method-channel";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler(
            (call, result) -> {
                // This method is invoked on the main thread.
                if (call.method.equals("getAvailableSpace")) {
                    String storage = getAvailableSpace();
                    if (storage != null && !storage.isEmpty()) {
                    result.success(storage);
                    } else {
                    result.error("UNAVAILABLE", "Error getting device available storage", null);
                    }
                }
                else if (call.method.equals("getTotalSpace")) {
                    String storage = getTotalSpace();
                    if (storage != null && !storage.isEmpty()) {
                    result.success(storage);
                    } else {
                    result.error("UNAVAILABLE", "Error getting device total storage", null);
                    }
                }
                 else {
                    result.notImplemented();
                }
            }
            );
    }


    private String getAvailableSpace() {
        StatFs stat = new StatFs(Environment.getExternalStorageDirectory().getPath());
        long bytesAvailable = (long)stat.getBlockSizeLong() * (long)stat.getAvailableBlocksLong();
        return String.valueOf(bytesAvailable / (1024 * 1024));  // Convert to MB or change as per your needs
    }

    private String getTotalSpace() {
        StatFs stat = new StatFs(Environment.getExternalStorageDirectory().getPath());
        long bytesTotal = (long)stat.getBlockSizeLong() * (long)stat.getBlockCountLong();
        return String.valueOf(bytesTotal / (1024 * 1024));  // Convert to MB or change as per your needs
    }

}
