# Music Feature Analyzer

A Flutter package to extract **song metadata** and **AI-powered music features** from audio files on Android and iOS.

Get title, artist, album, duration, bitrate, album art, genre, and more from local files—then run optional AI analysis for tempo (BPM), mood, instruments, danceability, and 20+ musical features.

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  music_feature_analyzer: ^1.0.3
```

Then run:

```bash
flutter pub get
```

[![pub package](https://img.shields.io/pub/v/music_feature_analyzer.svg)](https://pub.dev/packages/music_feature_analyzer) · [License: MIT](LICENSE)

---

## Supported platforms

| Platform | Supported |
|----------|-----------|
| **Android** | ✅ API 21+ |
| **iOS**     | ✅ 12.0+   |
| Web        | ❌        |
| Windows    | ❌        |
| macOS      | ❌        |
| Linux      | ❌        |

This package uses native Android (`MediaMetadataRetriever`) and iOS (`AVFoundation`) APIs and a TensorFlow Lite model (YAMNet). Desktop and web are not supported.

---

## Quick start

### 1. Song metadata (no initialization)

Get full song details from a file path. No AI model is loaded.

```dart
import 'package:music_feature_analyzer/music_feature_analyzer.dart';

// Single file
final song = await MusicFeatureAnalyzer.metadata('/path/to/song.mp3');
if (song != null) {
  print('${song.title} — ${song.artist}');
  print('Duration: ${song.duration} ms');
}

// Multiple files
final songs = await MusicFeatureAnalyzer.extractMetadataBatch([
  '/path/to/song1.mp3',
  '/path/to/song2.m4a',
]);
```

### 2. AI features (initialize once)

Tempo, mood, instruments, energy, danceability, and more. Requires one-time `initialize()` before analysis.

```dart
await MusicFeatureAnalyzer.initialize();

final song = await MusicFeatureAnalyzer.metadata('/path/to/song.mp3');
if (song != null && song.duration > 0) {
  final features = await MusicFeatureAnalyzer.analyzeSong(song);
  if (features != null) {
    print('Tempo: ${features.tempoBpm} BPM');
    print('Mood: ${features.mood}');
    print('Genre: ${features.estimatedGenre}');
    print('Danceability: ${features.danceability}');
  }
}
```

### 3. Background processing (keeps UI responsive)

For multiple songs, use `extractFeaturesInBackground`. You **must** pass `durationMsByPath` (map each file path to its duration in milliseconds). Providing durations avoids per-file metadata reads and ensures accurate analysis for long songs.

```dart
final filePaths = ['/path/to/a.mp3', '/path/to/b.mp3'];
final durationMsByPath = {
  '/path/to/a.mp3': 240000,  // 4 minutes
  '/path/to/b.mp3': 180000,  // 3 minutes
};

final results = await MusicFeatureAnalyzer.extractFeaturesInBackground(
  filePaths,
  durationMsByPath: durationMsByPath,
  onProgress: (current, total) => print('$current / $total'),
  onSongUpdated: (path, features) => { /* update UI */ },
  onCompleted: () => print('Done'),
  onError: (error) => print('Error: $error'),
);
// results[path] == ExtractedSongFeatures? for each path
```

If you have a list of `SongModel` (e.g. from metadata), build the map like this:

```dart
final durationMsByPath = { for (final s in songs) s.filePath: s.duration };
```

---

## Data models

### SongModel (metadata)

| Field        | Type        | Description                    |
|-------------|-------------|--------------------------------|
| `id`        | `String`    | Unique identifier              |
| `title`     | `String`    | Song title                     |
| `artist`    | `String`    | Artist name                    |
| `album`     | `String`    | Album name                     |
| `duration`  | `int`       | Duration in milliseconds       |
| `filePath`  | `String`    | Path to the audio file         |
| `albumArt`  | `String?`   | Path to album art image        |
| `year`      | `int?`      | Release year                   |
| `genre`     | `String?`   | Genre from file metadata       |
| `trackNumber` | `int?`    | Track number                   |
| `discNumber`  | `int?`    | Disc number                    |
| `albumArtist` | `String?`  | Album artist                   |
| `composer`  | `String?`   | Composer                       |
| `writer`    | `String?`   | Writer                         |
| `bitrate`   | `int?`      | Bitrate in kbps                |
| `fileSize`  | `int?`      | File size in bytes             |
| `mimeType`  | `String?`   | MIME type                      |
| `dateAdded` | `DateTime?` | File date added                |
| `features`  | `ExtractedSongFeatures?` | AI features (when analyzed) |

### ExtractedSongFeatures (AI analysis)

From `analyzeSong()`, `analyzeSongs()`, or `extractFeaturesInBackground()`:

| Category   | Fields |
|-----------|--------|
| **Categorical** | `tempo`, `beat`, `energy`, `mood`, `vocals`, `estimatedGenre` |
| **Lists**       | `instruments`, `yamnetInstruments`, `moodTags` |
| **Numeric**     | `tempoBpm`, `beatStrength`, `signalEnergy`, `brightness`, `danceability`, `loudness`, `overallEnergy`, `intensity`, `spectralCentroid`, `spectralRolloff`, `zeroCrossingRate`, `spectralFlux`, `complexity`, `valence`, `arousal`, `confidence` |
| **YAMNet**      | `yamnetEnergy`, `hasVocals` |

---

## API reference

| Method | Description |
|--------|-------------|
| `metadata(path)` | Get song metadata for one file. No `initialize()` needed. |
| `extractMetadataBatch(paths)` | Get metadata for multiple files. |
| `initialize()` | Load AI model. Required before any analysis. |
| `analyzeSong(song)` | Analyze one `SongModel`; returns `ExtractedSongFeatures?`. |
| `analyzeSongs(songs)` | Analyze multiple songs; yields between each for UI. |
| `extractFeaturesInBackground(paths, durationMsByPath: ..., onProgress, onSongUpdated, onCompleted, onError)` | Run analysis in a separate isolate. **Required:** `durationMsByPath`. Callbacks run on main isolate. |
| `verifyPlatformSetup()` | Check native setup (Android/iOS). |
| `getStats()` | Analysis statistics (success/fail counts, etc.). |
| `getExtractionProgress(paths)` | Progress info for background run. |
| `dispose()` | Release resources. |

---

## How analysis works

- **Metadata** — Read from the file via native Android/iOS APIs. No model load.
- **Short or unknown duration** — One short segment (~0.975 s) from the middle.
- **Duration ≥ 30 s** — Three **long segments** (6 s each) from the middle of each third of the song (D/6, D/2, 5D/6). YAMNet uses the first 0.975 s of each; all other features (tempo, beat, energy, loudness, danceability, spectral, etc.) use the full 6 s for accuracy. Numeric features are averaged across the three parts; categorical (genre, mood) come from the highest-confidence part.
- **Background** — `extractFeaturesInBackground` runs heavy work in a separate isolate. You must pass `durationMsByPath`; no per-file metadata read is performed.

---

## Requirements

- **Flutter** 3.0.0+, **Dart** 3.8.1+
- **Android** API 21+
- **iOS** 12.0+
- **Platforms:** Android and iOS only (no desktop or web)

**Formats:** MP3, WAV, FLAC, AAC, M4A, OGG, WMA, OPUS, AIFF, ALAC (and other platform-supported formats).

For media library access, configure permissions in your app. See [BUILD_COMPATIBILITY.md](BUILD_COMPATIBILITY.md) for setup.

---

## More information

- [CHANGELOG.md](CHANGELOG.md) — Version history
- [example/README.md](example/README.md) — Full example app
- [Pub.dev](https://pub.dev/packages/music_feature_analyzer)
- [GitHub](https://github.com/jezeel/music_feature_analyzer)
- [Issues](https://github.com/jezeel/music_feature_analyzer/issues)

*Music Feature Analyzer* · MIT License · [P M JESIL](mailto:jxz101m@gmail.com)
