package com.example.music_feature_analyzer_example

// import android.util.Log
import io.flutter.embedding.android.FlutterActivity
// import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {
    // override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    //     super.configureFlutterEngine(flutterEngine)
        
    //     // Manual plugin registration using reflection (workaround for plugin discovery issue)
    //     try {
    //         val pluginClass = Class.forName("com.music_feature_analyzer.MusicFeatureAnalyzerPlugin")
    //         val pluginInstance = pluginClass.getDeclaredConstructor().newInstance()
    //         val pluginInterface = pluginInstance as? io.flutter.embedding.engine.plugins.FlutterPlugin
    //         if (pluginInterface != null) {
    //             flutterEngine.plugins.add(pluginInterface)
    //             Log.i("MainActivity", "✅ MusicFeatureAnalyzerPlugin registered successfully via reflection")
    //         } else {
    //             Log.e("MainActivity", "❌ Plugin instance does not implement FlutterPlugin")
    //         }
    //     } catch (e: ClassNotFoundException) {
    //         Log.e("MainActivity", "❌ MusicFeatureAnalyzerPlugin class not found: ${e.message}")
    //         Log.e("MainActivity", "⚠️ Plugin may not be included in build dependencies")
    //     } catch (e: Exception) {
    //         Log.e("MainActivity", "❌ Failed to register MusicFeatureAnalyzerPlugin: ${e.message}", e)
    //     }
    // }
}