package com.floppyswing.floppy_swing

import com.google.android.gms.games.PlayGamesSdk
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(VideoEncoderPlugin())
        // Play Games is started on demand (its automatic start-up provider is
        // removed in AndroidManifest.xml), only when the game has real ids.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "floppy_swing/play_games")
            .setMethodCallHandler { call, result ->
                if (call.method == "initialize") {
                    PlayGamesSdk.initialize(applicationContext)
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }
}
