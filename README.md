# 🎵 Music Feature Analyzer

Extract metadata and AI-powered features from audio files (Android & iOS).

> ⚠️ **Beta** — Not recommended for production.

[![pub](https://img.shields.io/badge/pub-1.0.1--beta-0175C2)](https://pub.dev/packages/music_feature_analyzer) [![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

---

## Install

```yaml
dependencies:
  music_feature_analyzer: ^1.0.1-beta
```

```bash
flutter pub get
```

---

## Data you get from the package

### Metadata (SongModel)

From `metadata()` and `extractMetadataBatch()` — one row per field:

| Field | Type | Description |
|-------|------|-------------|
| `id` | `String` | Unique identifier |
| `title` | `String` | Song title |
| `artist` | `String` | Artist name |
| `album` | `String` | Album name |
| `duration` | `int` | Duration in milliseconds |
| `filePath` | `String` | Path to the audio file |
| `albumArt` | `String?` | Path to album art image |
| `year` | `int?` | Release year |
| `genre` | `String?` | Genre from metadata |
| `trackNumber` | `int?` | Track number in album |
| `discNumber` | `int?` | Disc number for multi-disc albums |
| `albumArtist` | `String?` | Album artist (may differ from track artist) |
| `composer` | `String?` | Composer name |
| `writer` | `String?` | Songwriter name |
| `bitrate` | `int?` | Audio bitrate in kbps |
| `fileSize` | `int?` | File size in bytes |
| `mimeType` | `String?` | Audio file MIME type |
| `dateAdded` | `DateTime?` | When file was added/created |
| `features` | `ExtractedSongFeatures?` | Extracted features (null when only metadata is used) |

### AI Features (ExtractedSongFeatures)

From `analyzeSong()`, `analyzeSongs()`, and `extractFeaturesInBackground()` — one row per field:

| Field | Type | Description |
|-------|------|-------------|
| `tempo` | `String` | Tempo category (e.g. Fast, Medium, Slow) |
| `beat` | `String` | Beat category (e.g. Strong, Soft, No Beat) |
| `energy` | `String` | Energy category (e.g. High, Medium, Low) |
| `instruments` | `List<String>` | Detected instruments (e.g. Piano, Guitar) |
| `vocals` | `String?` | Vocal description or null for instrumental |
| `mood` | `String` | Mood classification (Happy, Sad, Energetic, etc.) |
| `yamnetInstruments` | `List<String>` | YAMNet-detected instruments |
| `hasVocals` | `bool` | Whether vocals are detected |
| `estimatedGenre` | `String` | Genre classification (Rock, Pop, Jazz, etc.) |
| `yamnetEnergy` | `double` | YAMNet energy score (0.0–1.0) |
| `moodTags` | `List<String>` | Multiple mood tags |
| `tempoBpm` | `double` | Tempo in beats per minute (60–200) |
| `beatStrength` | `double` | Beat strength (0.0–1.0) |
| `signalEnergy` | `double` | Signal energy (0.0–1.0) |
| `brightness` | `double` | Spectral brightness |
| `danceability` | `double` | Danceability score (0.0–1.0) |
| `loudness` | `double` | Normalized loudness (0.0–1.0) |
| `overallEnergy` | `double` | Combined energy level (0.0–1.0) |
| `intensity` | `double` | Overall intensity |
| `spectralCentroid` | `double` | Spectral centroid (Hz) |
| `spectralRolloff` | `double` | Spectral rolloff (Hz) |
| `zeroCrossingRate` | `double` | Zero crossing rate |
| `spectralFlux` | `double` | Spectral flux |
| `complexity` | `double` | Complexity score |
| `valence` | `double` | Emotional positivity (0.0–1.0) |
| `arousal` | `double` | Emotional intensity (0.0–1.0) |
| `confidence` | `double` | Analysis confidence (0.0–1.0) |
| `analyzedAt` | `DateTime` | When analysis was performed |
| `analyzerVersion` | `String` | Analyzer version used |

---

## Function calls

```dart
import 'package:music_feature_analyzer/music_feature_analyzer.dart';

// --- Metadata (no initialize) ---
final song = await MusicFeatureAnalyzer.metadata('/path/to/song.mp3');
final songs = await MusicFeatureAnalyzer.extractMetadataBatch(['/a.mp3', '/b.mp3']);

// --- Feature extraction (initialize once) ---
await MusicFeatureAnalyzer.initialize();
final features = await MusicFeatureAnalyzer.analyzeSong(song!);
final list = await MusicFeatureAnalyzer.analyzeSongs(songs);

// --- Background: runs in a separate isolate so the UI stays responsive; each song takes a few seconds. ---
// You don't need to pass duration — the package gets it from metadata for each file.
final results = await MusicFeatureAnalyzer.extractFeaturesInBackground(
  filePaths,
  onProgress: (current, total) {},
  onSongUpdated: (path, features) {},
  onCompleted: () {},
  onError: (msg) {},
);

// --- Utilities ---
await MusicFeatureAnalyzer.verifyPlatformSetup();
MusicFeatureAnalyzer.getExtractionProgress(filePaths);
MusicFeatureAnalyzer.getStats();
MusicFeatureAnalyzer.isInitialized;
await MusicFeatureAnalyzer.dispose();
```

---

## How analysis works

- **Short / no duration:** One ~0.975 s segment from the middle.
- **Duration ≥ 30 s:** Four segments (1/8, 3/8, 5/8, 7/8 of length); numeric features = mean, genre/mood = from highest-confidence segment.
- **Background:** Duration is taken from metadata when `durationMsByPath` is omitted; extraction runs in an isolate so the UI stays responsive.

---

## Requirements & platform

- Flutter 3.0.0+, Dart 3.8.1+
- Android API 21+, iOS 12.0+
- **Supported:** Android, iOS only. No desktop/web.

**Formats:** MP3, WAV, FLAC, AAC, M4A, OGG, WMA, OPUS, AIFF, ALAC (and platform-supported formats).

**Permissions:** Only if you read from device media library. See [BUILD_COMPATIBILITY.md](BUILD_COMPATIBILITY.md) for local path setup; [CHANGELOG.md](CHANGELOG.md) for history; [example/README.md](example/README.md) for integration.

**Tests:** `flutter test`

---

**Made with ❤️ by [P M JESIL](mailto:jxz101m@gmail.com)** · [Issues](https://github.com/jezeel/music_feature_analyzer/issues) · **License:** [MIT](LICENSE)
