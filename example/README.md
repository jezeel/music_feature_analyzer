# 🎵 Music Feature Analyzer - Example App

A comprehensive, beautifully designed example demonstrating the `music_feature_analyzer` package functionality with modern UI/UX.

## 📱 Features Demonstrated

### 🏠 **Modern Single Screen App**
- **🎨 Beautiful UI**: Modern Material 3 design with gradients and animations
- **📊 System Status**: Real-time initialization status with statistics
- **📁 File Selection**: Easy single or multiple audio file selection
- **⚡ Analysis Modes**: Standard, Background, and Advanced processing options
- **📈 Progress Tracking**: Real-time progress with animated indicators
- **🎯 Detailed Results**: Comprehensive feature extraction with interactive cards
- **📊 Statistics**: Built-in analytics and performance metrics
- **🔄 Background Processing**: Non-blocking analysis using isolates
- **💫 Interactive UI**: Tap results for detailed analysis dialogs

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Dart SDK 3.8.1 or higher

### Installation

1. **Navigate to the example directory**:
   ```bash
   cd music_feature_analyzer/example
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the example**:
   ```bash
   flutter run
   ```

## 📦 Package Integration

This example demonstrates how to integrate the `music_feature_analyzer` package into your Flutter project:

### 1. **Add to pubspec.yaml**
This example uses the package from **Git** (for testing before publishing). After publishing, you can switch to the version from pub.dev.
```yaml
dependencies:
  # From Git (current setup - keep for pre-publish testing):
  music_feature_analyzer:
    git:
      url: https://github.com/jezeel/music_feature_analyzer.git
      ref: main
  # From pub.dev:
  # music_feature_analyzer: ^1.0.1
```
**After pushing package updates to Git:** run `flutter pub upgrade music_feature_analyzer` (or `flutter clean` then `flutter pub get`) in the example so plugin registration picks up the latest version.

### 2. **Initialize the Package**
```dart
import 'package:music_feature_analyzer/music_feature_analyzer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Music Feature Analyzer
  final initialized = await MusicFeatureAnalyzer.initialize();
  if (initialized) {
    print('✅ Music Feature Analyzer ready!');
  }
  
  runApp(MyApp());
}
```

### 3. **Analyze songs**
```dart
// Get metadata first (optional; needed for SongModel with duration)
final song = await MusicFeatureAnalyzer.metadata('path/to/song.mp3');
if (song == null) return;

// Single song analysis (pass SongModel)
final features = await MusicFeatureAnalyzer.analyzeSong(song);

// Multiple songs
final songs = await MusicFeatureAnalyzer.extractMetadataBatch([
  'path/to/song1.mp3',
  'path/to/song2.mp3',
]);
final results = <ExtractedSongFeatures?>[];
for (final s in songs) {
  if (s != null) results.add(await MusicFeatureAnalyzer.analyzeSong(s));
}

// Background processing (file paths only; duration is auto-fetched from metadata)
await MusicFeatureAnalyzer.extractFeaturesInBackground(
  ['path/to/song1.mp3', 'path/to/song2.mp3'],
  onProgress: (current, total) => print('$current / $total'),
  onSongUpdated: (filePath, features) => print('Updated: $filePath'),
  onCompleted: () => print('Done'),
);
```

## 🎯 Key Features Demonstrated

### **🤖 AI-Powered Analysis**
- **YAMNet Model**: Advanced instrument detection and classification
- **Genre Classification**: Automatic music genre identification
- **Vocal Detection**: Speech and singing detection
- **Mood Analysis**: Emotional context analysis
- **28+ Features**: Comprehensive musical feature extraction

### **🔬 Signal Processing**
- **Tempo Detection**: Accurate BPM calculation
- **Energy Analysis**: Musical intensity measurement
- **Spectral Features**: Centroid, rolloff, flux analysis
- **Beat Strength**: Rhythmic pattern analysis
- **Danceability**: How danceable the music is
- **Zero Crossing Rate**: Percussiveness detection

### **⚡ Advanced Processing**
- **Background Processing**: Isolate-based non-blocking analysis
- **Progress Tracking**: Real-time progress callbacks
- **Error Handling**: Comprehensive error management
- **Statistics**: Performance metrics and analytics
- **Multiple Modes**: Standard, Background, and Advanced options

## 🎨 UI/UX Features

### **🎨 Modern Design System**
- **Material 3**: Latest Material Design principles
- **Custom Themes**: Light and dark theme support
- **Gradient Backgrounds**: Beautiful gradient overlays
- **Responsive Layout**: ScreenUtil for perfect scaling
- **Google Fonts**: Poppins font family integration
- **Rounded Corners**: Modern border radius design

### **💫 Interactive Elements**
- **Animated Progress**: Smooth progress indicators with animations
- **Feature Cards**: Interactive result cards with hover effects
- **Detailed Dialogs**: Full-screen analysis result dialogs
- **File Selection**: Drag-and-drop style file picker
- **Mode Selection**: Toggle between analysis modes
- **Statistics Panel**: Expandable analytics section

### **🚀 User Experience**
- **Real-time Updates**: Live progress and status updates
- **Comprehensive Results**: Detailed feature analysis views
- **Error Handling**: User-friendly error messages and recovery
- **Intuitive Interface**: Simple, clean, and easy to use
- **Performance Optimized**: Smooth animations and transitions

## 🆕 What's New in This Example

### **🎨 Enhanced UI Design**
- **Gradient Headers**: Beautiful gradient backgrounds for visual appeal
- **Interactive Cards**: Hover effects and smooth transitions
- **Modern Typography**: Poppins font with proper hierarchy
- **Color-coded Features**: Visual feature chips with color coding
- **Responsive Layout**: Perfect scaling across all devices

### **📊 Advanced Features**
- **Analysis Modes**: Choose between Standard, Background, and Advanced processing
- **Real-time Statistics**: Live analytics and performance metrics
- **Progress Tracking**: Animated progress bars with current song display
- **Detailed Dialogs**: Full-screen analysis results with comprehensive data
- **Error Recovery**: Graceful error handling with user feedback

### **⚡ Performance Optimizations**
- **Background Processing**: Non-blocking analysis using isolates
- **Memory Management**: Efficient resource usage
- **Smooth Animations**: 60fps animations and transitions
- **Fast File Selection**: Optimized file picker integration

## 📱 Screenshots

The example app includes:
- **🎨 Modern Interface**: Beautiful Material 3 design with gradients
- **📁 File Selection**: Easy single or multiple audio file selection
- **⚡ Analysis Modes**: Toggle between different processing modes
- **📈 Progress Tracking**: Real-time progress with animated indicators
- **🎯 Detailed Results**: Interactive cards with comprehensive feature data
- **📊 Statistics Panel**: Expandable analytics and performance metrics

## 🔧 Customization

### **Theming**
The example uses a custom theme system:
```dart
// lib/utils/app_theme.dart
class AppTheme {
  static ThemeData get lightTheme { ... }
  static ThemeData get darkTheme { ... }
}
```

### **Logging**
Custom logging system for debugging:
```dart
// lib/utils/app_logger.dart
AppLogger.info('Analysis started');
AppLogger.success('Analysis completed');
AppLogger.error('Analysis failed: $error');
```

## 📚 API reference

### Core methods
- `MusicFeatureAnalyzer.initialize()` — Initialize the analyzer (required before feature extraction)
- `MusicFeatureAnalyzer.metadata(filePath)` — Extract metadata; returns `SongModel?`
- `MusicFeatureAnalyzer.extractMetadataBatch(filePaths)` — Batch metadata extraction
- `MusicFeatureAnalyzer.analyzeSong(song)` — Analyze a single song (`SongModel`); returns `ExtractedSongFeatures?`
- `MusicFeatureAnalyzer.analyzeSongs(songs)` — Analyze multiple songs
- `MusicFeatureAnalyzer.extractFeaturesInBackground(filePaths, { durationMsByPath, onProgress, onSongUpdated, onCompleted, onError })` — Background processing (duration optional; auto-fetched from metadata)

### Utilities
- `MusicFeatureAnalyzer.getStats()` — Analysis statistics
- `MusicFeatureAnalyzer.getExtractionProgress(filePaths)` — Progress info
- `MusicFeatureAnalyzer.verifyPlatformSetup()` — Verify setup
- `MusicFeatureAnalyzer.dispose()` — Clean up

### Status
- `MusicFeatureAnalyzer.isInitialized` — Whether the analyzer is initialized

## 🐛 Troubleshooting

### **Common Issues**

1. **Initialization Failed**
   - Ensure model files are present
   - Check device storage space
   - Verify audio file permissions

2. **Analysis Errors**
   - Check audio file format support
   - Verify file paths are correct
   - Ensure sufficient device memory

3. **Performance Issues**
   - Use background processing for large batches
   - Monitor device memory usage
   - Consider processing in smaller chunks

## 🤝 Contributing

This example is part of the `music_feature_analyzer` package. To contribute:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This example is provided under the same license as the `music_feature_analyzer` package.

## 🔗 Links

- [Package documentation](../README.md)
- [Pub.dev package](https://pub.dev/packages/music_feature_analyzer)
- [GitHub repository](https://github.com/jezeel/music_feature_analyzer)

---

**Built with ❤️ using Flutter and the Music Feature Analyzer package**