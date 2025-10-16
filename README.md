# Music Feature Analyzer

A comprehensive Flutter package for extracting detailed musical features from audio files using YAMNet AI model and advanced signal processing.

## Features

- 🎵 **AI-Powered Analysis**: Uses Google's YAMNet model for instrument detection, genre classification, and mood analysis
- 🔬 **Signal Processing**: Advanced DSP algorithms for tempo detection, spectral analysis, and energy calculation
- 🎯 **Comprehensive Features**: Extracts 20+ musical features including tempo, mood, energy, instruments, and more
- ⚡ **High Performance**: Optimized for mobile devices with efficient processing
- 📱 **Cross-Platform**: Works on both iOS and Android
- 🎨 **Easy Integration**: Simple API for quick implementation

## Supported Features

### AI-Powered Features (YAMNet)
- **Instrument Detection**: Piano, Guitar, Drums, Violin, Saxophone, etc.
- **Genre Classification**: Rock, Pop, Jazz, Classical, Electronic, etc.
- **Mood Analysis**: Happy, Sad, Energetic, Calm, etc.
- **Vocal Detection**: Speech, Singing, Choir, etc.

### Signal Processing Features
- **Tempo Detection**: Accurate BPM calculation
- **Energy Analysis**: Overall energy and intensity
- **Spectral Features**: Centroid, Rolloff, Flux, Brightness
- **Beat Analysis**: Beat strength and danceability
- **Zero Crossing Rate**: Percussiveness detection

### Combined Metrics
- **Complexity**: Musical complexity score
- **Valence**: Emotional positivity
- **Arousal**: Emotional intensity
- **Confidence**: Analysis reliability

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  music_feature_analyzer: ^1.0.0
```

## Usage

### Basic Usage

```dart
import 'package:music_feature_analyzer/music_feature_analyzer.dart';

// Initialize the analyzer
await MusicFeatureAnalyzer.initialize();

// Analyze a single song
final features = await MusicFeatureAnalyzer.analyzeSong('/path/to/song.mp3');

if (features != null) {
  print('Genre: ${features.estimatedGenre}');
  print('Tempo: ${features.tempoBpm} BPM');
  print('Instruments: ${features.instruments.join(', ')}');
  print('Mood: ${features.mood}');
  print('Energy: ${features.overallEnergy}');
}
```

### Batch Analysis

```dart
// Analyze multiple songs
final filePaths = [
  '/path/to/song1.mp3',
  '/path/to/song2.mp3',
  '/path/to/song3.mp3',
];

final results = await MusicFeatureAnalyzer.analyzeSongs(
  filePaths,
  onProgress: (current, total) {
    print('Progress: $current/$total');
  },
);

// Process results
for (final entry in results.entries) {
  final filePath = entry.key;
  final features = entry.value;
  
  if (features != null) {
    print('$filePath: ${features.estimatedGenre}');
  }
}
```

### Advanced Configuration

```dart
// Custom analysis options
final options = AnalysisOptions(
  enableYAMNet: true,
  enableSignalProcessing: true,
  enableSpectralAnalysis: true,
  confidenceThreshold: 0.1,
  maxInstruments: 10,
  verboseLogging: true,
);

final features = await MusicFeatureAnalyzer.analyzeSong(
  '/path/to/song.mp3',
  options: options,
);
```

### Get Analysis Statistics

```dart
final stats = MusicFeatureAnalyzer.getStats();
print('Total songs analyzed: ${stats.totalSongs}');
print('Success rate: ${(stats.successRate * 100).toStringAsFixed(1)}%');
print('Average processing time: ${stats.averageProcessingTime.toStringAsFixed(2)}s');
```

## API Reference

### MusicFeatureAnalyzer

#### Methods

- `initialize()` - Initialize the analyzer (required before use)
- `analyzeSong(String filePath, {AnalysisOptions? options})` - Analyze a single song
- `analyzeSongs(List<String> filePaths, {...})` - Analyze multiple songs
- `getStats()` - Get analysis statistics
- `dispose()` - Clean up resources

#### Properties

- `isInitialized` - Check if analyzer is initialized

### SongFeatures

The main result object containing all extracted features:

```dart
class SongFeatures {
  // Basic features
  final String tempo;
  final String beat;
  final String energy;
  final List<String> instruments;
  final String? vocals;
  final String mood;
  
  // YAMNet results
  final List<String> yamnetInstruments;
  final bool hasVocals;
  final String estimatedGenre;
  final double yamnetEnergy;
  final List<String> moodTags;
  
  // Signal processing
  final double tempoBpm;
  final double beatStrength;
  final double signalEnergy;
  final double brightness;
  final double danceability;
  
  // Spectral features
  final double spectralCentroid;
  final double spectralRolloff;
  final double zeroCrossingRate;
  final double spectralFlux;
  
  // Combined metrics
  final double overallEnergy;
  final double complexity;
  final double valence;
  final double arousal;
  
  // Metadata
  final DateTime analyzedAt;
  final String analyzerVersion;
  final double confidence;
}
```

### AnalysisOptions

Configuration options for analysis:

```dart
class AnalysisOptions {
  final bool enableYAMNet;
  final bool enableSignalProcessing;
  final bool enableSpectralAnalysis;
  final double confidenceThreshold;
  final int maxInstruments;
  final bool verboseLogging;
}
```

## Supported Audio Formats

- MP3
- WAV
- FLAC
- AAC
- M4A
- OGG
- WMA
- OPUS
- AIFF
- ALAC

## Requirements

- Flutter 3.0.0+
- Dart 3.0.0+
- iOS 11.0+ / Android API 21+

## Dependencies

- `tflite_flutter` - TensorFlow Lite for YAMNet model
- `ffmpeg_kit_flutter_new` - Audio processing
- `path_provider` - File system access
- `freezed_annotation` - Data classes
- `logger` - Logging

## Performance

- **Processing Time**: ~2-5 seconds per song (depending on device)
- **Memory Usage**: ~50-100MB during analysis
- **Model Size**: ~15MB (YAMNet model)
- **Accuracy**: 90%+ for common genres and instruments

## Examples

### Music Player Integration

```dart
class MusicPlayerService {
  Future<void> analyzePlaylist(List<String> songPaths) async {
    // Initialize analyzer
    await MusicFeatureAnalyzer.initialize();
    
    // Analyze all songs
    final results = await MusicFeatureAnalyzer.analyzeSongs(
      songPaths,
      onProgress: (current, total) {
        // Update UI with progress
        updateProgress(current, total);
      },
    );
    
    // Store features in database
    for (final entry in results.entries) {
      if (entry.value != null) {
        await database.storeSongFeatures(entry.key, entry.value!);
      }
    }
  }
}
```

### AI Shuffle Implementation

```dart
class AIShuffleService {
  List<String> reorderPlaylist(List<String> songIds, String currentSongId) {
    // Get features for current song
    final currentFeatures = getSongFeatures(currentSongId);
    
    // Calculate similarities
    final similarities = <String, double>{};
    for (final songId in songIds) {
      final features = getSongFeatures(songId);
      final similarity = calculateSimilarity(currentFeatures, features);
      similarities[songId] = similarity;
    }
    
    // Sort by similarity
    songIds.sort((a, b) => similarities[b]!.compareTo(similarities[a]!));
    
    return songIds;
  }
}
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## License

MIT License - see LICENSE file for details.

## Support

- 📧 Email: support@musicfeatureanalyzer.com
- 🐛 Issues: [GitHub Issues](https://github.com/jezeel/music_feature_analyzer/issues)
- 📖 Documentation: [Full Documentation](https://github.com/jezeel/music_feature_analyzer#readme)

## Changelog

### v1.0.0
- Initial release
- YAMNet integration
- Signal processing features
- Comprehensive feature extraction
- Cross-platform support
