# Changelog

All notable changes to this project will be documented in this file.

## [1.0.1-beta-01] - 2026-01-21

> ⚠️ **Beta Release**: This version may have issues. Not recommended for production use.

### Added
- ✅ **Automatic Native Code Registration**: Native code now registers automatically via Flutter plugin system
- ✅ **Metadata Extraction**: New `metadata()` and `extractMetadataBatch()` methods for extracting audio metadata
- ✅ **Comprehensive Metadata**: Extracts title, artist, album, album art, genre, year, track number, disc number, bitrate, file size, and more
- ✅ **Permission Helper**: `getPermissionInstructions()` and `logPermissionInstructions()` for platform-specific guidance
- ✅ **Setup Verification**: `verifyPlatformSetup()` to check if native code is properly configured
- ✅ **Platform-Specific Guides**: Android and iOS integration guides with automatic registration support

### Changed
- ✅ **Simplified Setup**: No manual MainActivity.kt or AppDelegate.swift changes needed
- ✅ **Better Error Messages**: Enhanced error handling with setup guidance
- ✅ **Documentation**: Updated all guides to reflect automatic registration

### Technical Details
- Flutter plugin structure with automatic registration
- Android plugin implements `FlutterPlugin` interface
- iOS plugin implements `FlutterPlugin` protocol
- Method channel: `com.music_feature_analyzer/audio_metadata`
- Thread-safe operations on both platforms
- File size overflow protection
- Optimized method channel handling (removed unnecessary thread switching)
- Clean code with removed verbose logging

## [1.0.0] - 2025-10-01

### Added
- Initial release of Music Feature Analyzer package
- YAMNet AI model integration for instrument detection, genre classification, and mood analysis
- Advanced signal processing for tempo detection, energy analysis, and spectral features
- Comprehensive feature extraction with 20+ musical features
- Cross-platform support for iOS and Android
- Batch processing capabilities with progress callbacks
- Full test coverage
- Modern Flutter architecture with Freezed data classes
- JSON serialization support
