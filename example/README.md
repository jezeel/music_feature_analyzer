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
```yaml
dependencies:
  music_feature_analyzer:
    path: ../  # or from pub.dev
```

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

### 3. **Analyze Songs**
```dart
// Single song analysis
final features = await MusicFeatureAnalyzer.analyzeSong('path/to/song.mp3');

// Multiple songs analysis
final songs = [
  Song(path: 'path/to/song1.mp3', title: 'Song 1'),
  Song(path: 'path/to/song2.mp3', title: 'Song 2'),
];
final results = await MusicFeatureAnalyzer.analyzeSongs(songs);

// Background processing
await MusicFeatureAnalyzer.extractFeaturesInBackground(
  ['path/to/song1.mp3', 'path/to/song2.mp3'],
  onProgress: (current, total) {
    print('Progress: $current/$total');
  },
  onSongUpdated: (filePath, features) {
    print('Updated: $filePath');
  },
  onCompleted: () {
    print('Analysis completed!');
  },
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

## 📚 API Reference

### **Core Methods**
- `MusicFeatureAnalyzer.initialize()` - Initialize the analyzer
- `MusicFeatureAnalyzer.analyzeSong(path)` - Analyze single song
- `MusicFeatureAnalyzer.analyzeSongs(songs)` - Analyze multiple songs
- `MusicFeatureAnalyzer.extractFeaturesInBackground()` - Background processing

### **Statistics**
- `MusicFeatureAnalyzer.getStats()` - Get analysis statistics
- `MusicFeatureAnalyzer.getExtractionProgress()` - Get progress info

### **Status**
- `MusicFeatureAnalyzer.isInitialized` - Check initialization status

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

- [Package Documentation](../README.md)
- [Pub.dev Package](https://pub.dev/packages/music_feature_analyzer)
- [GitHub Repository](https://github.com/your-username/music_feature_analyzer)

---

**Built with ❤️ using Flutter and the Music Feature Analyzer package**