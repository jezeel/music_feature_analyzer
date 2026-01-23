package com.example.music_feature_analyzer_example

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.music_feature_analyzer.MusicFeatureAnalyzerPlugin

class MainActivity: FlutterActivity() {
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(MusicFeatureAnalyzerPlugin())
    }
}