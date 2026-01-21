package com.example.music_feature_analyzer_example

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.music_feature_analyzer.MusicFeatureAnalyzerPlugin

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // For local path dependencies (example app), manually register the plugin
        // This ensures the plugin works even if Flutter's auto-discovery doesn't find it
        // For published packages from pub.dev, this is not needed - plugin registers automatically
        try {
            flutterEngine.plugins.add(MusicFeatureAnalyzerPlugin())
            android.util.Log.i("MainActivity", "✅ MusicFeatureAnalyzerPlugin registered manually in MainActivity (example app)")
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "❌ Failed to register MusicFeatureAnalyzerPlugin: ${e.message}", e)
        }
    }
}
