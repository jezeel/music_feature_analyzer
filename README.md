# Music Feature Analyzer

**Get song metadata and AI-powered music features from audio files in Flutter.**

Extract title, artist, album, duration, bitrate, album art, genre, year, and more from local audio files—then optionally run AI analysis for tempo, mood, instruments, and 20+ musical features. Android and iOS.

---

## Install

```yaml
dependencies:
  music_feature_analyzer: ^1.0.2
```

```bash
flutter pub get
```

[![pub package](https://img.shields.io/pub/v/music_feature_analyzer.svg)](https://pub.dev/packages/music_feature_analyzer) · [License: MIT](LICENSE)

---

## Quick start

### Song metadata (no initialization)

Get full song details from a file path. Uses native Android `MediaMetadataRetriever` and iOS `AVFoundation`.

```dart
import 'package:music_feature_analyzer/music_feature_analyzer.dart';

// Single file
final song = await MusicFeatureAnalyzer.metadata('/path/to/song.mp3');
// song.title, song.artist, song.album, song.duration, song.bitrate, song.genre, etc.

// Multiple files
final songs = await MusicFeatureAnalyzer.extractMetadataBatch([
  '/path/to/song1.mp3',
  '/path/to/song2.m4a',
]);
```

### AI features (initialize once)

Tempo, mood, instruments, energy, danceability, and more. Requires one-time `initialize()`.

```dart
await MusicFeatureAnalyzer.initialize();

final features = await MusicFeatureAnalyzer.analyzeSong(song!);
// features.tempoBpm, features.mood, features.instruments, features.danceability, etc.

// Background processing (keeps UI responsive)
final results = await MusicFeatureAnalyzer.extractFeaturesInBackground(
  filePaths,
  onProgress: (current, total) => print('$current / $total'),
  onSongUpdated: (path, features) => {},
  onCompleted: () => print('Done'),
);
```

---

## What you get

### Metadata (`SongModel`)

| Field | Type | Description |
|-------|------|--------------|
| `id` | `String` | Unique identifier |
| `title` | `String` | Song title |
| `artist` | `String` | Artist name |
| `album` | `String` | Album name |
| `duration` | `int` | Duration in milliseconds |
| `filePath` | `String` | Path to the audio file |
| `albumArt` | `String?` | Path to album art image |
| `year` | `int?` | Release year |
| `genre` | `String?` | Genre from file metadata |
| `trackNumber` | `int?` | Track number |
| `discNumber` | `int?` | Disc number |
| `albumArtist` | `String?` | Album artist |
| `composer` | `String?` | Composer |
| `writer` | `String?` | Writer |
| `bitrate` | `int?` | Bitrate in kbps |
| `fileSize` | `int?` | File size in bytes |
| `mimeType` | `String?` | MIME type |
| `dateAdded` | `DateTime?` | File date added |
| `features` | `ExtractedSongFeatures?` | AI features (when analyzed) |

### AI features (`ExtractedSongFeatures`)

From `analyzeSong()`, `analyzeSongs()`, or `extractFeaturesInBackground()`:

- **Categories:** `tempo`, `beat`, `energy`, `mood`, `vocals`, `estimatedGenre`
- **Lists:** `instruments`, `yamnetInstruments`, `moodTags`
- **Numeric:** `tempoBpm`, `beatStrength`, `danceability`, `loudness`, `valence`, `arousal`, `spectralCentroid`, `spectralRolloff`, `zeroCrossingRate`, `spectralFlux`, `complexity`, `confidence`, and more.

---

## API summary

| Method | Description |
|--------|-------------|
| `metadata(path)` | Get song metadata for one file. No `initialize()` needed. |
| `extractMetadataBatch(paths)` | Get metadata for multiple files. |
| `initialize()` | Load AI model. Required before analysis. |
| `analyzeSong(song)` | Analyze one `SongModel`; returns `ExtractedSongFeatures?`. |
| `analyzeSongs(songs)` | Analyze multiple songs. |
| `extractFeaturesInBackground(paths, ...)` | Run analysis in a separate isolate; optional `durationMsByPath`, progress and completion callbacks. |
| `verifyPlatformSetup()` | Check native setup (Android/iOS). |
| `getStats()` | Analysis statistics. |
| `getExtractionProgress(paths)` | Progress for background run. |
| `dispose()` | Release resources. |

---

## How analysis works

- **Metadata:** Read directly from the file via native APIs. No model load.
- **Short / unknown duration:** One short segment from the middle.
- **Duration ≥ 30 s:** Three segments (middle of each third); numeric features averaged, genre/mood from highest-confidence segment.
- **Background:** `extractFeaturesInBackground` runs in an isolate; duration is read from file metadata when not provided.

---

## Requirements

- **Flutter** 3.0.0+, **Dart** 3.8.1+
- **Android** API 21+ · **iOS** 12.0+
- **Platforms:** Android and iOS only (no desktop or web).

**Formats:** MP3, WAV, FLAC, AAC, M4A, OGG, WMA, OPUS, AIFF, ALAC (and platform-supported formats).

For media library access, configure permissions in your app. See [BUILD_COMPATIBILITY.md](BUILD_COMPATIBILITY.md) for setup; [CHANGELOG.md](CHANGELOG.md) for version history; [example/README.md](example/README.md) for a full demo.

---

## Links

- [Pub.dev](https://pub.dev/packages/music_feature_analyzer)
- [GitHub](https://github.com/jezeel/music_feature_analyzer)
- [Issues](https://github.com/jezeel/music_feature_analyzer/issues)

*Music Feature Analyzer* · MIT License · [P M JESIL](mailto:jxz101m@gmail.com)
