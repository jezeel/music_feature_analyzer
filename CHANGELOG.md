# Changelog

All notable changes to this project will be documented in this file.

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
