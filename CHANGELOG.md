# Changelog

All notable changes to this project will be documented in this file.

---

## [1.0.3] - 2026-02-06

### Added

- **Three long segments (6 s each)** — For songs with duration ≥ 30 s, analysis now uses three 6-second segments from the middle of each third (D/6, D/2, 5D/6) instead of three short 0.975 s clips. All signal features (tempo, beat, energy, loudness, danceability, spectral, etc.) are computed from the full 6 s per segment for better accuracy on 4–5 minute songs.
- **Onset + FFT tempo and beat** — For long segments (≥ 32k samples), tempo (BPM) and beat strength are derived from an onset-strength curve and its FFT, improving stability compared to autocorrelation on sub-second windows.
- **Single FFmpeg run for 3 segments** — `extractThreeLongSegmentsBatchOnMain` extracts all three long segments in one FFmpeg run to keep processing fast.
- **Defensive empty-audio check** — Feature extraction now returns `null` when audio data is null or empty to avoid runtime errors.

### Changed

- **`durationMsByPath` is now required** — `extractFeaturesInBackground()` no longer auto-fetches duration from metadata. Callers must pass a `Map<String, int>` mapping each file path to its duration in milliseconds. This avoids per-file metadata reads and ensures correct segment positions for long songs.
- **YAMNet input unchanged** — YAMNet still receives the first 0.975 s of each segment (15,600 samples). All other features use the full 6 s segment.
- **Spectral features on long segments** — Spectral centroid and rolloff use a middle 1024-sample window of each long segment for a representative spectrum.
- **Bass ratio performance** — For segments longer than 1024 samples, bass ratio uses a 1024-sample window instead of the full waveform to avoid O(n²) cost and keep the background isolate responsive.
- **README and docs** — Expanded README with full API summary, examples, supported platforms, and version 1.0.3. Added package-level `analysis_options.yaml` for static analysis.

### Technical

- Method channel: `com.music_feature_analyzer/audio_metadata`
- Flutter 3.0.0+, Dart 3.8.1+
- Android API 21+, iOS 12.0+
- Supported platforms: Android and iOS only (no desktop or web).

---

## [1.0.2] - 2026-01-31

### Changed

- **Album art optimization** — Timeout increased from 5s to 15s so large embedded art or slow devices can finish. On timeout or any error the original image is used with no log. Removed warnings for "album art data too small", "optimization failed", and "external search failed" so fallbacks are silent.
- **Logging** — Removed "getAlbumArt succeeded" info log from `NativeMetadataService`. Metadata validation (e.g. "Artist is missing") now logs only at debug level when `_enableDebugLogs` is false.
- **iOS (Swift)** — Fixed Swift compiler errors on newer Xcode/iOS SDK: explicit `self.` in closures (`extractCommonMetadata`, `sanitizeMetadata`, `detectMimeType`); replaced iOS-unavailable `AVMetadataKey` ID3 members with string literals (`TPE2` album artist, `TEXT` writer, `TPOS` disc number) for compatibility.
- **Pub.dev** — Added `flutter: ">=3.0.0"` to `environment` in `pubspec.yaml` so package validation passes (required for `flutter.plugin.platforms`).

### Technical

- Method channel: `com.music_feature_analyzer/audio_metadata`
- Flutter 3.0.0+, Dart 3.8.1+
- Android API 21+, iOS 12.0+

---

## [1.0.1] - 2026-01-29

**Stable release.** Song metadata extraction and AI feature analysis for Flutter (Android & iOS).

### Added

- **Song metadata extractor** — Get full song details from audio files without initializing the AI model. Use `metadata(path)` for a single file or `extractMetadataBatch(paths)` for multiple files. Returns `SongModel` with title, artist, album, duration, bitrate, album art path, genre, year, track/disc number, composer, writer, file size, MIME type, and more.
- **Native metadata APIs** — Android uses `MediaMetadataRetriever`; iOS uses `AVFoundation`. Album art and MIME type detection; bitrate in kbps; year/date parsing from file tags.
- **Platform validation** — Blank or invalid file path rejected on both platforms; invalid duration (NaN/infinite) handled on iOS; errors returned in metadata map instead of unhandled failures.

### Changed

- **README** — Clear, classic layout: install, quick start (metadata first, then AI features), data tables, API summary, requirements. Optimized for pub.dev discoverability (song metadata, audio metadata, music features, Flutter).
- **Package description** — Updated for pub.dev search: "Flutter package to extract song metadata and AI-powered music features from audio files."
- **Version** — Stable 1.0.1 (no beta suffix) across pubspec, Android Gradle, iOS podspec, and native plugin version strings.

### Technical

- Method channel: `com.music_feature_analyzer/audio_metadata`
- Flutter 3.0.0+, Dart 3.8.1+
- Android API 21+, iOS 12.0+

---

## [1.0.1-beta-07] - 2026-01-27

> **Beta release** (last before 1.0.1 stable). Native plugin improvements and validation.

### Changed

- **Android (`MusicFeatureAnalyzerPlugin.kt`)** — Reject blank file path with `INVALID_ARGUMENT` before any work. Bitrate sent to Dart in kbps (converted from bps). Extract and send `METADATA_KEY_DATE` as `date` for year parsing. Error handling and resource cleanup in `getMetadata`, `getAlbumArt`, `getAlbumArtMimeType`. Removed verbose logging; kept error and important warning logs.
- **iOS (`MusicFeatureAnalyzerPlugin.swift`)** — Reject blank or whitespace-only path. Wrap `getMetadata` in top-level `do-catch`; set `metadata["error"]` on any thrown error. Validate duration: only set `metadata["duration"]` when `durationInSeconds` is finite, non-NaN, and ≥ 0 (handles corrupt/unsupported files). Bitrate in kbps; year/date from common metadata. Album art and MIME detection unchanged.
- **pubspec.yaml** — Version set to `1.0.1-beta-07`. Description and dependencies unchanged.

### Technical Notes

- Method channel: `com.music_feature_analyzer/audio_metadata`
- Flutter 3.0.0+, Dart 3.8.1+
- Android API 21+, iOS 12.0+

---

## [1.0.1-beta-06] - 2026-01-23

> ⚠️ **Beta Release**: Plugin discovery configuration fix. Not recommended for production use.

### Changed
- 🔄 **Plugin Configuration**: Enabled `default_package: music_feature_analyzer` in Android plugin configuration to improve plugin discovery
- 🔄 **Plugin Discovery**: This should help Flutter's plugin discovery mechanism find the plugin automatically

### Fixed
- 🐛 **Plugin Discovery**: Fixed potential plugin discovery issues by explicitly setting default_package

### Technical Notes
- Method channel: `com.music_feature_analyzer/audio_metadata`
- Flutter **3.0.0+**, Dart **3.8.1+**
- Android **API 21+**, iOS **12.0+**

---

## [1.0.1-beta-05] - 2026-01-23

> ⚠️ **Beta Release**: Android plugin structure improvements and code quality enhancements. Not recommended for production use.

### Changed
- 🔄 **Android Plugin Structure**: Moved plugin file to proper package structure (`com/music_feature_analyzer/`)
- 🔄 **Package Declaration**: Added proper package declaration for better plugin discovery
- 🔄 **Code Quality**: Added `@Suppress("unused")` annotation to prevent false warnings
- 🔄 **Loading Mode Detection**: Enhanced loading mode detection with comprehensive path checking
- 🔄 **Example App**: Cleaned up MainActivity.kt (removed manual registration workaround)

### Fixed
- 🐛 **Plugin Discovery**: Fixed plugin file location to match package structure
- 🐛 **Code Organization**: Removed duplicate plugin file from incorrect location

### Technical Notes
- Method channel: `com.music_feature_analyzer/audio_metadata`
- Flutter **3.0.0+**, Dart **3.8.1+**
- Android **API 21+**, iOS **12.0+**

---

## [1.0.1-beta-04] - 2026-01-23

> ⚠️ **Beta Release**: Code quality improvements and import cleanup. Not recommended for production use.

### Fixed
- 🐛 **Code Quality**: Removed unnecessary imports in feature extractor and metadata service
- 🐛 **Test Imports**: Cleaned up redundant imports in test files
- ✅ **Lint Compliance**: All lib and test files now pass Flutter analyze with no issues

### Technical Notes
- Method channel: `com.music_feature_analyzer/audio_metadata`
- Flutter **3.0.0+**, Dart **3.8.1+**
- Android **API 21+**, iOS **12.0+**

---

## [1.0.1-beta-03] - 2026-01-23

> ⚠️ **Beta Release**: Documentation and error message improvements. Not recommended for production use.

### Changed
- 🔄 **Improved Documentation**: Clarified zero-configuration setup for published packages
- 🔄 **Better Error Messages**: More accurate troubleshooting guidance distinguishing published vs local packages
- 🔄 **README Updates**: Explicitly states no platform-specific configuration needed for pub.dev packages

### Fixed
- 📝 **Documentation Clarity**: Removed confusion about manual registration requirements
- 📝 **Permission Documentation**: Clarified that permissions are optional (only needed for media library access)

### Technical Notes
- Method channel: `com.music_feature_analyzer/audio_metadata`
- Flutter **3.0.0+**, Dart **3.8.1+**
- Android **API 21+**, iOS **11.0+**

---

## [1.0.1-beta-02] - 2026-01-22

> ⚠️ **Beta Release**: Major native plugin improvements. Not recommended for production use.

### Added
- ✅ **Rewritten Native Plugins**: Android and iOS plugins rebuilt for better performance and stability
- ✅ **iOS AVFoundation Integration**: Full metadata extraction using `AVAsset`
- ✅ **Album Art MIME Detection**: Automatic detection of embedded artwork formats
- ✅ **Improved Metadata Parsing**: Better handling of track/disc numbers and year/date formats
- ✅ **Enhanced Platform Verification**: Extended `verifyConnection()` with platform details
- ✅ **Graceful Error Recovery**: Safe handling of corrupted or incomplete audio files

### Changed
- 🔄 **Optimized Native Threading**: Improved background execution and main-thread safety
- 🔄 **Better Resource Management**: Proper cleanup to avoid memory leaks
- 🔄 **Improved Method Channel Stability**: Reduced overhead and more reliable communication

### Fixed
- 🐞 Android file size overflow issues
- 🐞 Album art detection inconsistencies
- 🐞 Metadata parsing edge cases
- 🐞 Native concurrency and memory issues

### Technical Notes
- Method channel: `com.music_feature_analyzer/audio_metadata`
- Flutter **3.0.0+**, Dart **3.8.1+**
- Android **API 21+**, iOS **11.0+**

---

## [1.0.1-beta-01] - 2026-01-21

> ⚠️ **Beta Release**: This version may have issues. Not recommended for production use.

### Added
- ✅ **Automatic Native Code Registration** via Flutter plugin system
- ✅ **Metadata Extraction APIs**: `metadata()` and `extractMetadataBatch()`
- ✅ **Comprehensive Audio Metadata**: Title, artist, album, album art, genre, year, track/disc number, bitrate, file size, and more
- ✅ **Permission Helpers**: Platform-specific permission guidance utilities
- ✅ **Setup Verification**: `verifyPlatformSetup()` to validate native configuration
- ✅ **Platform Guides**: Android and iOS integration documentation

### Changed
- 🔄 **Simplified Setup**: No manual `MainActivity.kt` or `AppDelegate.swift` changes required
- 🔄 **Improved Error Messages**: Clearer setup and runtime guidance
- 🔄 **Documentation Updates**: All guides updated for automatic registration

### Technical Notes
- Flutter plugin-based architecture
- Android plugin implements `FlutterPlugin`
- iOS plugin implements `FlutterPlugin`
- Thread-safe native operations
- File size overflow protection
- Optimized method channel handling
- Reduced verbose native logging

---

## [1.0.0] - 2025-10-01

### Added
- 🎉 Initial release of **Music Feature Analyzer**
- 🎵 YAMNet AI integration for genre, mood, and instrument detection
- 🎚 Advanced signal processing for tempo, energy, and spectral features
- 📊 20+ extracted musical features
- 📦 Batch processing with progress callbacks
- 📱 Cross-platform support for Android and iOS
- 🧩 Freezed-based data models
- 🔄 JSON serialization support
