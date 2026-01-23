# 🎵 Music Feature Analyzer

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**Extract metadata and AI-powered features from audio files**

> ⚠️ **Beta Version**: This is a beta release (`1.0.1-beta-03`) and may have issues. Not recommended for production use. Please wait for a stable version.

[![GitHub stars](https://img.shields.io/github/stars/jezeel/music_feature_analyzer?style=social)](https://github.com/jezeel/music_feature_analyzer)

</div>

---

## ✨ Features

- 📊 **Metadata Extraction**: Title, Artist, Album, Album Art, Duration, Genre, Year, Bitrate, and more
- 🤖 **AI Analysis**: Genre, Instruments, Mood, Vocals detection using YAMNet
- 🎵 **Signal Processing**: Tempo (BPM), Energy, Danceability, Spectral features
- ⚡ **Background Processing**: Process multiple files with progress tracking

---

## 🚀 Quick Start

### Installation

**✅ Zero Configuration Required!** When using the published package from pub.dev, no platform-specific setup is needed. Just add it to your `pubspec.yaml`:

```yaml
dependencies:
  music_feature_analyzer: ^1.0.1-beta-03
```

```bash
flutter pub get
```

The plugin automatically registers itself - no manual `MainActivity.kt` or `AppDelegate.swift` changes needed!

> **Note**: For local path dependencies (development), see [BUILD_COMPATIBILITY.md](BUILD_COMPATIBILITY.md)

### Basic Usage

```dart
import 'package:music_feature_analyzer/music_feature_analyzer.dart';

// Extract metadata (no initialization needed)
final song = await MusicFeatureAnalyzer.metadata('/path/to/song.mp3');
print('Title: ${song?.title}');
print('Artist: ${song?.artist}');

// Extract AI features (requires initialization)
await MusicFeatureAnalyzer.initialize();
final features = await MusicFeatureAnalyzer.analyzeSong(song!);
print('Genre: ${features?.estimatedGenre}');
print('Tempo: ${features?.tempoBpm} BPM');
```

---

## 📊 Extracted Data

### Metadata

| Field | Type | Description |
|-------|------|-------------|
| `title`, `artist`, `album` | `String` | Basic song information |
| `albumArt` | `String?` | Path to album art image |
| `duration` | `int` | Duration in milliseconds |
| `genre`, `year` | `String?`, `int?` | Genre and release year |
| `bitrate`, `fileSize` | `int?` | Audio quality and file size |
| `trackNumber`, `discNumber` | `int?` | Track position in album |
| `composer`, `writer` | `String?` | Credits information |

### AI Features

| Field | Type | Description |
|-------|------|-------------|
| `estimatedGenre` | `String` | Genre classification (Rock, Pop, Jazz, etc.) |
| `yamnetInstruments` | `List<String>` | Detected instruments |
| `hasVocals` | `bool` | Whether vocals are detected |
| `tempoBpm` | `double` | Tempo in beats per minute (60-200) |
| `danceability` | `double` | Danceability score (0.0-1.0) |
| `overallEnergy` | `double` | Energy level (0.0-1.0) |
| `mood` | `String` | Mood classification (Happy, Sad, Energetic, etc.) |
| `moodTags` | `List<String>` | Multiple mood tags |

### Signal Processing

| Field | Type | Range |
|-------|------|-------|
| `tempoBpm` | `double` | 60-200 BPM |
| `beatStrength` | `double` | 0.0-1.0 |
| `spectralCentroid` | `double` | 0-5000 Hz |
| `danceability` | `double` | 0.0-1.0 |
| `valence`, `arousal` | `double` | 0.0-1.0 |

---

## 📚 API Reference

### Metadata Extraction

```dart
// Single file
final song = await MusicFeatureAnalyzer.metadata('/path/to/song.mp3');

// Multiple files
final songs = await MusicFeatureAnalyzer.extractMetadataBatch([
  '/path/to/song1.mp3',
  '/path/to/song2.mp3',
]);
```

### Feature Extraction

```dart
// Initialize (required once)
await MusicFeatureAnalyzer.initialize();

// Analyze single song
final features = await MusicFeatureAnalyzer.analyzeSong(song);

// Batch analysis
final featuresList = await MusicFeatureAnalyzer.analyzeSongs(songs);

// Background processing with progress
final results = await MusicFeatureAnalyzer.extractFeaturesInBackground(
  filePaths,
  onProgress: (current, total) {
    print('Progress: $current/$total');
  },
);
```

### Utility Functions

```dart
// Verify setup
final setup = await MusicFeatureAnalyzer.verifyPlatformSetup();

// Get progress
final progress = MusicFeatureAnalyzer.getExtractionProgress(filePaths);

// Clean up
await MusicFeatureAnalyzer.dispose();
```

---

## ⚙️ Platform Setup

### ✅ Automatic Registration

**For published packages (pub.dev):** No setup required! The plugin automatically registers itself via Flutter's plugin system. Just add the package and use it.

### 📱 Permissions (Optional)

Permissions are **only required** if you need to access files from the device's media library. If you're providing file paths directly (e.g., from file picker), permissions are not needed.

#### Android

**If accessing media library, add to `android/app/src/main/AndroidManifest.xml`:**

```xml
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" 
                 android:maxSdkVersion="32" />
```

**Request permissions at runtime:**

```dart
import 'package:permission_handler/permission_handler.dart';
await Permission.audio.request(); // Android 13+
await Permission.storage.request(); // Android 12-
```

#### iOS

**If accessing media library, add to `ios/Runner/Info.plist`:**

```xml
<key>NSAppleMusicUsageDescription</key>
<string>This app needs access to your music library.</string>
<key>NSMediaLibraryUsageDescription</key>
<string>This app needs access to your media library.</string>
```

**Request permissions at runtime:**

```dart
import 'package:permission_handler/permission_handler.dart';
await Permission.mediaLibrary.request();
```

---

## 🎯 Supported Formats

MP3, WAV, FLAC, AAC, M4A, OGG, WMA, OPUS, AIFF, ALAC

---

## 📋 Requirements

- Flutter: 3.0.0+
- Dart: 3.8.1+
- iOS: 12.0+
- Android: API 21+

---

## 📚 Documentation

- **[Build Compatibility](BUILD_COMPATIBILITY.md)** - Local path dependency setup
- **[Changelog](CHANGELOG.md)** - Version history 

---

## 🤝 Contributing

Contributions are welcome! Please open an issue or submit a pull request.

---

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

---

<div align="center">

**Made with ❤️ by [P M JESIL](mailto:jxz101m@gmail.com)**

[📧 Email](mailto:jxz101m@gmail.com) • [🐛 Issues](https://github.com/jezeel/music_feature_analyzer/issues)

</div>
