import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'utils/app_logger.dart';
import 'utils/permission_helper.dart';
import 'models/extracted_song_features.dart';
import 'models/song_model.dart';
import 'services/feature_extractor.dart';
import 'services/metadata_extractor/metadata_extractor.dart';
import 'services/metadata_extractor/native_metadata_service.dart';

/// ============================================================================
/// MUSIC FEATURE ANALYZER - Main Package Entry Point
/// ============================================================================
/// 
/// PURPOSE: Comprehensive music feature extraction using YAMNet AI model
/// 
/// FEATURES:
/// - YAMNet AI analysis (instruments, vocals, genre, mood, energy)
/// - Signal processing (tempo, beat, energy, spectral features)
/// - Background processing with isolates (audio extraction and AI run off the UI thread)
/// - Progress tracking and statistics
/// 
/// ANALYSIS BEHAVIOUR:
/// - Short songs or when duration is unknown: one short segment (~0.975 s) from the middle.
/// - When duration is known and >= 30 s: three long segments (6 s each) from the middle of each third
///   (D/6, D/2, 5D/6) in one FFmpeg run. YAMNet uses the first 0.975 s of each; all other features
///   (tempo, beat, energy, loudness, danceability, spectral, etc.) use the full 6 s for accuracy.
/// [extractFeaturesInBackground] requires [durationMsByPath] (no per-file metadata fetch).
/// 
/// USAGE:
/// 1. Initialize: await MusicFeatureAnalyzer.initialize()
/// 2. Analyze: await MusicFeatureAnalyzer.analyzeSong(song)
/// 3. Background: await MusicFeatureAnalyzer.extractFeaturesInBackground(...)
/// 4. Dispose: await MusicFeatureAnalyzer.dispose()

class MusicFeatureAnalyzer {
  static final AppLogger _logger = AppLogger('MusicFeatureAnalyzer');
  
  // ============================================================================
  // STATE MANAGEMENT
  // ============================================================================
  
  static FeatureExtractor? _extractor;
  static bool _isInitialized = false;
  static bool _isBackgroundProcessing = false;
  
  // ============================================================================
  // PUBLIC API
  // ============================================================================
  
  /// Initialize the music feature analyzer
  /// 
  /// **Platform Support**: This package supports Android and iOS only.
  /// Desktop and Web platforms are not supported.
  static Future<bool> initialize() async {
    try {
      // Check platform support - Android and iOS only
      if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
        _logger.e('This package supports Android and iOS only');
        _logger.e('Current platform is not supported');
        return false;
      }
      
      if (_isInitialized) {
        return true;
      }

      _extractor = FeatureExtractor();
      final success = await _extractor!.initialize();
      if (success) {
        _isInitialized = true;
        return true;
      }
      _logger.e('Failed to initialize feature extractor');
      return false;
    } catch (e, stackTrace) {
      _logger.e('Initialization failed: $e', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Analyze a single song.
  /// Uses the same isolate-based path as [extractFeaturesInBackground] so YAMNet and signal
  /// processing run off the main isolate and do not block the UI.
  static Future<ExtractedSongFeatures?> analyzeSong(SongModel song) async {
    if (!_isInitialized || _extractor == null) {
      _logger.e('Analyzer not initialized. Call initialize() first.');
      return null;
    }
    try {
      final durationMs = song.duration > 0 ? song.duration : null;
      return await _extractFeaturesInIsolate(song.filePath, durationMs: durationMs);
    } catch (e) {
      _logger.e('Error analyzing song: $e', error: e);
      return null;
    }
  }

  /// Analyze multiple songs.
  /// Uses the same isolate-based path as [extractFeaturesInBackground]; yields to the UI
  /// between each song so the UI stays responsive.
  static Future<List<ExtractedSongFeatures?>> analyzeSongs(List<SongModel> songs) async {
    if (!_isInitialized || _extractor == null) {
      _logger.e('Analyzer not initialized. Call initialize() first.');
      return [];
    }
    try {
      final results = <ExtractedSongFeatures?>[];
      for (final song in songs) {
        final durationMs = song.duration > 0 ? song.duration : null;
        final features = await _extractFeaturesInIsolate(song.filePath, durationMs: durationMs);
        results.add(features);
        await Future.delayed(Duration.zero);
      }
      return results;
    } catch (e) {
      _logger.e('Error analyzing songs: $e', error: e);
      return [];
    }
  }

  /// Extract metadata from a single audio file
  /// Returns SongModel with all metadata fields populated (features will be null)
  static Future<SongModel?> metadata(String filePath) async {
    try {
      await MetadataExtractor.initialize();
      final song = await MetadataExtractor.extractMetadata(filePath);
      if (song == null) {
        _logger.w('Failed to extract metadata: $filePath');
      }
      return song;
    } catch (e, stackTrace) {
      _logger.e('Error extracting metadata: $e', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Extract metadata from multiple audio files
  static Future<List<SongModel?>> extractMetadataBatch(List<String> filePaths) async {
    try {
      
      // Initialize metadata extractor if needed
      await MetadataExtractor.initialize();
      
      final results = <SongModel?>[];
      
      for (final filePath in filePaths) {
        final song = await MetadataExtractor.extractMetadata(filePath);
        results.add(song);
      }
      
      return results;
    } catch (e) {
      _logger.e('Error extracting metadata batch: $e', error: e);
      return [];
    }
  }

  /// Extract features in background with isolate-based processing.
  ///
  /// UI impact: Audio extraction (FFmpeg) runs on the main isolate (platform channel requirement).
  /// YAMNet and all signal processing run in a separate isolate via [compute], so they do not block the UI.
  /// After each song, [Future.delayed(Duration.zero)] yields so the UI can update. Callbacks run on main isolate.
  ///
  /// [durationMsByPath] is required: map each file path to its duration in milliseconds.
  static Future<Map<String, ExtractedSongFeatures?>> extractFeaturesInBackground(
    List<String> filePaths, {
    required Map<String, int> durationMsByPath,
    Function(int current, int total)? onProgress,
    Function(String filePath, ExtractedSongFeatures? features)? onSongUpdated,
    Function()? onCompleted,
    Function(String error)? onError,
  }) async {
    if (_isBackgroundProcessing) {
      _logger.w('Feature extraction already in progress');
      return {};
    }
    if (!_isInitialized || _extractor == null) {
      _logger.e('Analyzer not initialized. Call initialize() first.');
      return {};
    }
    _isBackgroundProcessing = true;
    try {
      final songsNeedingAnalysis = filePaths.where((_) => true).toList();
      if (songsNeedingAnalysis.isEmpty) {
        onCompleted?.call();
        return {};
      }
      final results = await _processSongsWithUIResponsiveness(
        songsNeedingAnalysis,
        onSongUpdated,
        onProgress,
        durationMsByPath: durationMsByPath,
      );
      
      onCompleted?.call();
      return results;
    } catch (e) {
      _logger.e('Background extraction failed: $e', error: e);
      onError?.call(e.toString());
      return {};
    } finally {
      _isBackgroundProcessing = false;
    }
  }

  /// Get extraction progress (same as original)
  static Map<String, dynamic> getExtractionProgress(List<String> allSongs) {
    final total = allSongs.length;
    
    // For now, we can't check individual song features since we don't have access to Song objects
    // This is a limitation of the package approach vs the original
    // In a real implementation, you'd need to pass Song objects or check a database
    
    // Use statistics as fallback (same approach as original when features can't be checked)
    final AnalysisStats stats;
    if (_extractor != null) {
      stats = _extractor!.getStats();
    } else {
      stats = AnalysisStats.empty();
    }
    final analyzed = stats.successfulAnalyses; // Only count successful analyses as "analyzed"
    
    return {
      'totalSongs': total,
      'analyzedSongs': analyzed,
      'pendingSongs': total - analyzed,
      'completionPercentage': total > 0 ? (analyzed / total * 100) : 0.0,
    };
  }

  /// Get extraction progress with Song objects (for project integration)
  static Map<String, dynamic> getExtractionProgressWithSongs(List<dynamic> allSongs) {
    final total = allSongs.length;
    final analyzed = allSongs
        .where((s) => s.features != null)
        .length;
    
    return {
      'totalSongs': total,
      'analyzedSongs': analyzed,
      'pendingSongs': total - analyzed,
      'completionPercentage': total > 0 ? (analyzed / total * 100) : 0.0,
    };
  }

  /// Get analysis statistics
  static AnalysisStats getStats() {
    if (_extractor != null) {
      return _extractor!.getStats();
    } else {
      return AnalysisStats.empty();
    }
  }

  /// Reset statistics
  static void resetStats() {
    _extractor?.resetStats();
  }

  /// Check if analyzer is initialized
  static bool get isInitialized => _isInitialized;

  /// Get permission instructions for the current platform
  /// 
  /// This method provides guidance on how to request permissions
  /// required for metadata extraction. It returns platform-specific
  /// instructions including code examples.
  /// 
  /// **Note:** This package does not include `permission_handler` as a dependency.
  /// Users should add it to their app's pubspec.yaml and use the provided
  /// code examples to request permissions.
  /// 
  /// Returns a map with permission instructions:
  /// - `platform`: Platform name
  /// - `permission`: Permission name
  /// - `code`: Example code snippet
  /// - `manifestRequired`: Whether manifest/plist changes are needed
  /// - `manifestInstructions`: Manifest/plist configuration code
  /// 
  /// Example:
  /// ```dart
  /// final instructions = MusicFeatureAnalyzer.getPermissionInstructions();
  /// print('Platform: ${instructions['platform']}');
  /// print('Code: ${instructions['code']}');
  /// ```
  static Map<String, dynamic> getPermissionInstructions() {
    return PermissionHelper.getPermissionInstructions();
  }

  /// Log permission instructions to console
  /// 
  /// Convenience method that logs detailed permission instructions
  /// for the current platform, including code examples and manifest
  /// configuration requirements.
  static void logPermissionInstructions() {
    PermissionHelper.logPermissionInstructions();
  }

  /// Verify platform setup for metadata extraction
  /// 
  /// Checks if the native method channel is properly configured.
  /// This helps users identify setup issues early.
  /// 
  /// Returns a map with setup status information:
  /// - `isConfigured`: Whether setup is complete
  /// - `platform`: Current platform
  /// - `issues`: List of identified issues
  /// - `suggestions`: List of fix suggestions
  /// - `message`: Summary message
  /// - `setupGuide`: Link to setup documentation
  /// 
  /// Example:
  /// ```dart
  /// final status = await MusicFeatureAnalyzer.verifyPlatformSetup();
  /// if (!status['isConfigured']) {
  ///   print('Issues: ${status['issues']}');
  ///   print('Suggestions: ${status['suggestions']}');
  /// }
  /// ```
  static Future<Map<String, dynamic>> verifyPlatformSetup() async {
    
    final isWeb = kIsWeb;
    final isAndroid = !isWeb && Platform.isAndroid;
    final isIOS = !isWeb && Platform.isIOS;
    final isDesktop = !isWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
    
    final status = <String, dynamic>{
      'isConfigured': false,
      'platform': defaultTargetPlatform.toString(),
      'platformName': _getPlatformName(),
      'issues': <String>[],
      'suggestions': <String>[],
      'setupGuide': 'See PLATFORM_SETUP_GUIDE.md for complete setup instructions',
    };
    
    // This package supports Android and iOS only
    if (isWeb) {
      status['isConfigured'] = false;
      status['message'] = '❌ Web platform is not supported';
      status['issues'].add('This package supports Android and iOS only');
      status['issues'].add('Web platform does not support native metadata extraction');
      status['issues'].add('Web platform does not support AI feature extraction');
      status['suggestions'].add('This package is designed for mobile platforms (Android/iOS) only');
      status['suggestions'].add('For web applications, consider server-side processing');
      status['nativeCode'] = 'Not supported - Android/iOS only';
      return status;
    }
    
    if (isDesktop) {
      status['isConfigured'] = false;
      status['message'] = '❌ Desktop platforms are not supported';
      status['issues'].add('This package supports Android and iOS only');
      status['issues'].add('Desktop platforms (Windows/Linux/macOS) are not supported');
      status['issues'].add('Native metadata extraction requires Android MediaMetadataRetriever or iOS AVFoundation');
      status['issues'].add('AI feature extraction requires mobile-optimized TensorFlow Lite');
      status['suggestions'].add('This package is designed for mobile platforms (Android/iOS) only');
      status['suggestions'].add('For desktop applications, consider alternative solutions');
      status['nativeCode'] = 'Not supported - Android/iOS only';
      return status;
    }
    
    // Ensure we're on Android or iOS
    if (!isAndroid && !isIOS) {
      status['isConfigured'] = false;
      status['message'] = '❌ Unsupported platform';
      status['issues'].add('This package supports Android and iOS only');
      status['suggestions'].add('Please use this package on Android or iOS platforms');
      status['nativeCode'] = 'Not supported - Android/iOS only';
      return status;
    }

    try {
      // Try to call a simple method to check if channel is registered
      final testResult = await _testMethodChannel();
      
      if (testResult) {
        status['isConfigured'] = true;
        status['message'] = '✅ Platform setup verified successfully';
        status['nativeCode'] = 'Registered';
      } else {
        status['issues'].add('Method channel not registered');
        status['issues'].add('Plugin may not be registered automatically');
        status['suggestions'].add(
          'For published packages: Run flutter clean && flutter pub get && rebuild',
        );
        status['suggestions'].add('For local path dependencies: See BUILD_COMPATIBILITY.md');
        status['suggestions'].add('Verify GeneratedPluginRegistrant includes the plugin');
        status['message'] = '⚠️ Platform setup incomplete - native code not registered';
        status['nativeCode'] = 'Not registered';
        _logger.w('Platform setup incomplete - method channel not registered. See BUILD_COMPATIBILITY.md');
      }
    } on PlatformException catch (e) {
      if (e.code == 'not_implemented') {
        status['issues'].add('Method channel handler not implemented');
        status['suggestions'].add('For published packages: Run flutter clean && flutter pub get && rebuild');
        status['suggestions'].add('For local path dependencies: See BUILD_COMPATIBILITY.md');
        status['message'] = '❌ Method channel not implemented';
        status['nativeCode'] = 'Not implemented';
      } else {
        status['issues'].add('Error verifying setup: ${e.message}');
        status['suggestions'].add('Check PLATFORM_SETUP_GUIDE.md for setup instructions');
        status['message'] = '❌ Error verifying platform setup';
      }
      _logger.e('Platform setup verification failed: ${e.message}', error: e);
    } catch (e) {
      status['issues'].add('Unexpected error: $e');
      status['suggestions'].add('Check PLATFORM_SETUP_GUIDE.md for setup instructions');
      status['message'] = '❌ Error verifying platform setup';
      _logger.e('Platform setup verification failed: $e', error: e);
    }

    return status;
  }
  
  /// Verify method channel connection and detect dependency loading mode
  /// 
  /// This method checks:
  /// - If the method channel is connected
  /// - How the dependency is loaded (published package vs local path)
  /// - Connection status and handler configuration
  /// 
  /// Returns a map with:
  /// - `connected`: bool - Whether the method channel is connected
  /// - `channelName`: String - The method channel name
  /// - `loadingMode`: String - "PUBLISHED_PACKAGE" or "LOCAL_PATH"
  /// - `handlerSet`: bool - Whether the handler is set
  /// - `message`: String - Human-readable status message
  /// 
  /// Example:
  /// ```dart
  /// final connection = await MusicFeatureAnalyzer.verifyConnection();
  /// print('Connected: ${connection['connected']}');
  /// print('Loading Mode: ${connection['loadingMode']}');
  /// ```
  static Future<Map<String, dynamic>> verifyConnection() async {
    
    final result = await NativeMetadataService.verifyConnection();
    
    if (result == null) {
      return {
        'connected': false,
        'message': '❌ Connection verification failed - no response from native code',
        'channelName': 'com.music_feature_analyzer/audio_metadata',
        'loadingMode': 'unknown',
        'handlerSet': false,
      };
    }
    
    final connected = result['connected'] as bool? ?? false;
    final channelName = result['channelName'] as String? ?? 'com.music_feature_analyzer/audio_metadata';
    final loadingMode = result['loadingMode'] as String? ?? 'unknown';
    final handlerSet = result['handlerSet'] as bool? ?? false;
    
    String message;
    if (connected) {
      if (loadingMode == NativeMetadataService.loadingModePublished) {
        message = '✅ Connected (Published Package) - Automatic registration working';
      } else if (loadingMode == NativeMetadataService.loadingModeLocal) {
        message = '✅ Connected (Local Path) - Manual registration may be needed';
      } else {
        message = '✅ Connected - Loading mode: $loadingMode';
      }
    } else {
      message = '❌ Not connected - Plugin may not be registered';
      if (result.containsKey('error')) {
        message += '\nError: ${result['error']}';
      }
    }
    
    return {
      'connected': connected,
      'channelName': channelName,
      'loadingMode': loadingMode,
      'handlerSet': handlerSet,
      'message': message,
      ...result,
    };
  }
  
  /// Get human-readable platform name
  /// This package supports Android and iOS only
  static String _getPlatformName() {
    if (kIsWeb) return 'Web (Not Supported)';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isMacOS) return 'macOS (Not Supported)';
    if (Platform.isWindows) return 'Windows (Not Supported)';
    if (Platform.isLinux) return 'Linux (Not Supported)';
    return 'Unknown (Not Supported)';
  }

  /// Test if method channel is properly set up
  static Future<bool> _testMethodChannel() async {
    try {
      // Try a simple call - if it throws not_implemented, channel isn't set up
      final testChannel = const MethodChannel('com.music_feature_analyzer/audio_metadata');
      await testChannel.invokeMethod('getMetadata', {'path': '/test'});
      return true;
    } on PlatformException catch (e) {
      if (e.code == 'not_implemented') {
        return false; // Channel not set up
      }
      // Other errors (like file not found) mean channel exists
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Dispose resources
  static Future<void> dispose() async {
    if (_extractor != null) {
      await _extractor!.dispose();
      _extractor = null;
    }
    _isInitialized = false;
  }

  /// Extract filename from path
  static String _getFileName(String path) {
    return path.split('/').last.split('\\').last;
  }

  /// Process YAMNet results in isolate (SAME AS ORIGINAL)
  static Map<String, dynamic> _processYAMNetResultsInIsolate(
    List<double> results,
    List<String> labels,
  ) {
    try {
      // Find top predictions
      final indexedResults = results.asMap().entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      final topPredictions = indexedResults.take(15).toList();
      
      // Extract features
      final instruments = <String>[];
      bool hasVocals = false;
      String genre = 'Unknown';
      double energy = 0.5;
      final moodTags = <String>[];
      double moodScore = 0.5;

      for (final prediction in topPredictions) {
        final label = labels[prediction.key];
        final score = prediction.value;

        if (score > 0.1) { // Threshold for relevance
          if (_isInstrument(label)) {
            instruments.add(label);
          }
          if (_isVocal(label)) {
            hasVocals = true;
          }
          if (_isGenre(label)) {
            genre = label;
          }
          if (_isMood(label)) {
            if (moodTags.length < 3 && score > 0.15) moodTags.add(label);
            moodScore = _moodTagToScoreInIsolate(label, score, moodScore);
          }
        }
      }

      // Calculate energy from results
      energy = results.take(100).reduce((a, b) => a + b) / 100;

      final vocalIntensity = hasVocals ? energy.clamp(0.0, 1.0) : 0.0;
      return {
        'instruments': instruments.isEmpty ? ['Unknown'] : instruments,
        'hasVocals': hasVocals,
        'genre': genre.isEmpty ? 'Unknown' : genre,
        'mood': moodTags.isEmpty ? 'Neutral' : moodTags.first,
        'moodTags': moodTags.isEmpty ? ['Neutral'] : moodTags,
        'moodScore': moodScore.clamp(0.0, 1.0),
        'energyValue': energy.clamp(0.0, 1.0),
        'vocalIntensity': vocalIntensity,
      };
    } catch (e) {
      return {
        'instruments': ['Unknown'],
        'hasVocals': false,
        'genre': 'Unknown',
        'mood': 'Neutral',
        'moodTags': ['Neutral'],
        'moodScore': 0.5,
        'energyValue': 0.5,
        'vocalIntensity': 0.0,
      };
    }
  }

  /// Map mood tag to numeric score (0=sad/calm, 1=happy/energetic). Mirrors FeatureExtractor._moodTagToScore.
  static double _moodTagToScoreInIsolate(String displayName, double score, double current) {
    final lower = displayName.toLowerCase();
    final weighted = score.clamp(0.0, 1.0);
    if (lower.contains('happy') || lower.contains('joyful') || lower.contains('upbeat') ||
        lower.contains('cheerful') || lower.contains('exciting') || lower.contains('party') ||
        lower.contains('celebrat') || lower.contains('dance') || lower.contains('energetic')) {
      return math.max(current, 0.5 + weighted * 0.45);
    }
    if (lower.contains('romantic') || lower.contains('tender') || lower.contains('love') || lower.contains('passionate')) {
      return math.max(current, 0.55 + weighted * 0.35);
    }
    if (lower.contains('workout') || lower.contains('intense') || lower.contains('powerful') || lower.contains('driving')) {
      return math.max(current, 0.6 + weighted * 0.35);
    }
    if (lower.contains('sad') || lower.contains('melancholy') || lower.contains('gloomy') ||
        lower.contains('somber') || lower.contains('depress') || lower.contains('heartbreak')) {
      return math.min(current, 0.35 - weighted * 0.35);
    }
    if (lower.contains('scary') || lower.contains('dark') || lower.contains('angry') || lower.contains('aggressive') ||
        lower.contains('frighten') || lower.contains('tense')) {
      return math.min(current, 0.4 - weighted * 0.2);
    }
    if (lower.contains('calm') || lower.contains('peaceful') || lower.contains('relaxing') ||
        lower.contains('serene') || lower.contains('chill') || lower.contains('lullaby') ||
        lower.contains('sleep') || lower.contains('meditation') || lower.contains('zen') ||
        lower.contains('ambient') || lower.contains('soothing')) {
      return (current + 0.45) / 2;
    }
    if (lower.contains('focus') || lower.contains('study') || lower.contains('concentration')) {
      return (current + 0.5) / 2;
    }
    if (lower.contains('rap') || lower.contains('hip') || lower.contains('hip hop')) {
      return math.max(current, 0.45 + weighted * 0.4);
    }
    return current;
  }

  static String _genreFromMap(dynamic g) {
    if (g == null) return 'Unknown';
    final s = g.toString().trim();
    return s.isEmpty ? 'Unknown' : s;
  }

  static double _calculateValenceInIsolate(double yamnetEnergy, List<String> moodTags, double signalEnergy) {
    double moodComponent = 0.5;
    for (final tag in moodTags) {
      final lower = tag.toLowerCase();
      if (lower.contains('happy') || lower.contains('upbeat') || lower.contains('joyful')) {
        moodComponent = math.max(moodComponent, 0.6);
        break;
      }
      if (lower.contains('sad') || lower.contains('melancholy')) {
        moodComponent = math.min(moodComponent, 0.4);
        break;
      }
    }
    return (moodComponent * 0.7 + (signalEnergy * 0.4)).clamp(0.0, 1.0);
  }

  static double _calculateArousalInIsolate(double yamnetEnergy, double tempoBpm, double signalEnergy) {
    final tempoComponent = ((tempoBpm.clamp(60.0, 200.0) - 60) / 140).clamp(0.0, 1.0);
    return (signalEnergy * 0.6 + tempoComponent * 0.4).clamp(0.0, 1.0);
  }

  /// Calculate signal features in isolate. For long segments (>= 32k samples) uses onset+FFT for tempo/beat.
  static SignalFeatures _calculateSignalFeaturesInIsolate(Float32List audioData) {
    try {
      const longSegmentMinSamples = 32000; // ~2s at 16kHz; use onset+FFT for better accuracy
      final useLongSegmentTempoBeat = audioData.length >= longSegmentMinSamples;

      // Calculate energy (full segment)
      final energy = _calculateEnergyInIsolate(audioData);

      // Tempo and beat: onset+FFT for long segments, else autocorrelation/flux
      final tempoBpm = useLongSegmentTempoBeat
          ? _calculateTempoFromOnsetFFTInIsolate(audioData)
          : _calculateTempoInIsolate(audioData);
      final beatStrength = useLongSegmentTempoBeat
          ? _calculateBeatStrengthFromOnsetInIsolate(audioData)
          : _calculateBeatStrengthInIsolate(audioData);
      
      // Calculate spectral features
      final spectralCentroid = _calculateSpectralCentroidInIsolate(audioData);
      final spectralRolloff = _calculateSpectralRolloffInIsolate(audioData);
      final zeroCrossingRate = _calculateZeroCrossingRateInIsolate(audioData);
      
      // Brightness: normalized spectral centroid (0-1)
      final brightness = (spectralCentroid / 8000.0).clamp(0.0, 1.0);
      
      // Loudness: perceived loudness 0-1
      final loudness = _calculateLoudnessInIsolate(audioData);
      
      return SignalFeatures(
        tempoBpm: tempoBpm,
        beatStrength: beatStrength,
        energy: energy,
        brightness: brightness,
        danceability: _calculateDanceabilityAdvancedInIsolate(audioData, tempoBpm, beatStrength, energy),
        loudness: loudness,
        spectralCentroid: spectralCentroid,
        spectralRolloff: spectralRolloff,
        zeroCrossingRate: zeroCrossingRate,
      );
    } catch (e) {
      // Return default values if calculation fails
      return SignalFeatures(
        tempoBpm: 120.0,
        beatStrength: 0.5,
        energy: 0.5,
        brightness: 0.25,
        danceability: 0.5,
        loudness: 0.0,
        spectralCentroid: 2000.0,
        spectralRolloff: 4000.0,
        zeroCrossingRate: 0.1,
      );
    }
  }

  /// Calculate perceived loudness (0-1) in isolate
  static double _calculateLoudnessInIsolate(Float32List waveform) {
    if (waveform.isEmpty) return 0.0;
    final rms = _calculateEnergyInIsolate(waveform);
    const refRms = 0.25;
    final linear = (rms / refRms).clamp(0.0, 1.0);
    return linear <= 0 ? 0.0 : math.pow(linear, 0.6).toDouble();
  }

  /// Calculate energy in isolate
  static double _calculateEnergyInIsolate(Float32List audioData) {
    double sum = 0.0;
    for (final sample in audioData) {
      sum += sample * sample;
    }
    return math.sqrt(sum / audioData.length);
  }

  /// Calculate tempo using improved autocorrelation in isolate
  static double _calculateTempoInIsolate(Float32List audioData) {
    try {
      const sampleRate = 16000.0;
      const minBpm = 60.0;
      const maxBpm = 200.0;
      
      // Use larger window for better tempo detection (2 seconds)
      final windowSize = math.min((sampleRate * 2).toInt(), audioData.length);
      final window = audioData.take(windowSize).toList();
      
      if (window.length < 1024) {
        return 120.0; // Not enough data
      }
      
      // Calculate autocorrelation
      final autocorr = _calculateAutocorrelationInIsolate(window);
      
      // Find peaks in autocorrelation
      final peaks = _findPeaksInIsolate(autocorr);
      
      if (peaks.isEmpty) {
        return 120.0; // No clear tempo found
      }
      
      // Convert lag to BPM and find best tempo
      double bestTempo = 120.0;
      double bestScore = 0.0;
      
      for (final peak in peaks) {
        final lag = peak.lag;
        final bpm = (sampleRate * 60.0) / lag;
        
        // Check if BPM is in reasonable range
        if (bpm >= minBpm && bpm <= maxBpm) {
          // Score based on autocorrelation strength and BPM likelihood
          final score = peak.strength * _getTempoLikelihoodInIsolate(bpm);
          
          if (score > bestScore) {
            bestScore = score;
            bestTempo = bpm;
          }
        }
      }
      
      return bestTempo;
    } catch (e) {
      return 120.0;
    }
  }

  /// Calculate autocorrelation in isolate (SAME AS ORIGINAL)
  static List<double> _calculateAutocorrelationInIsolate(List<double> data) {
    final n = data.length;
    final autocorr = <double>[];
    
    for (int lag = 0; lag < n ~/ 2; lag++) {
      double sum = 0.0;
      for (int i = 0; i < n - lag; i++) {
        sum += data[i] * data[i + lag];
      }
      autocorr.add(sum / (n - lag));
    }
    
    return autocorr;
  }

  /// Find peaks in autocorrelation in isolate (SAME AS ORIGINAL)
  static List<Peak> _findPeaksInIsolate(List<double> autocorr) {
    final peaks = <Peak>[];
    const minPeakHeight = 0.1;
    const minPeakDistance = 10;
    
    for (int i = 1; i < autocorr.length - 1; i++) {
      if (autocorr[i] > autocorr[i - 1] && 
          autocorr[i] > autocorr[i + 1] && 
          autocorr[i] > minPeakHeight) {
        
        // Check distance from previous peaks
        bool tooClose = false;
        for (final peak in peaks) {
          if ((i - peak.lag).abs() < minPeakDistance) {
            tooClose = true;
            break;
          }
        }
        
        if (!tooClose) {
          peaks.add(Peak(lag: i, strength: autocorr[i]));
        }
      }
    }
    
    // Sort by strength
    peaks.sort((a, b) => b.strength.compareTo(a.strength));
    return peaks.take(5).toList(); // Return top 5 peaks
  }

  /// Get tempo likelihood score in isolate
  static double _getTempoLikelihoodInIsolate(double bpm) {
    // Common tempo ranges with different likelihoods
    if (bpm >= 60 && bpm <= 80) return 0.8;   // Slow ballads
    if (bpm >= 80 && bpm <= 100) return 1.0;  // Medium tempo (most common)
    if (bpm >= 100 && bpm <= 120) return 1.0; // Pop/rock tempo
    if (bpm >= 120 && bpm <= 140) return 0.9; // Dance tempo
    if (bpm >= 140 && bpm <= 180) return 0.7; // Fast dance
    if (bpm >= 180 && bpm <= 200) return 0.5; // Very fast
    return 0.3; // Unusual tempo
  }

  /// Calculate beat strength in isolate (SAME AS ORIGINAL)
  static double _calculateBeatStrengthInIsolate(Float32List audioData) {
    try {
      const windowSize = 1024;
      const hopSize = 512;
      
      if (audioData.length < windowSize * 2) return 0.5;
      
      // Calculate spectral flux (onset detection)
      final energies = <double>[];
      final spectralFlux = <double>[];
      
      for (int i = 0; i < audioData.length - windowSize; i += hopSize) {
        final window = audioData.sublist(i, i + windowSize);
        final windowed = _applyHannWindowInIsolate(Float32List.fromList(window));
        final fft = _performFFTInIsolate(windowed);
        final magnitudes = _calculateMagnitudeSpectrumFromFFTInIsolate(fft);
        
        // Calculate energy in different frequency bands
        final lowEnergy = magnitudes.take(magnitudes.length ~/ 4).fold(0.0, (sum, mag) => sum + mag);
        final midEnergy = magnitudes.skip(magnitudes.length ~/ 4).take(magnitudes.length ~/ 2).fold(0.0, (sum, mag) => sum + mag);
        final highEnergy = magnitudes.skip(3 * magnitudes.length ~/ 4).fold(0.0, (sum, mag) => sum + mag);
        
        final totalEnergy = lowEnergy + midEnergy + highEnergy;
        energies.add(totalEnergy);
        
        // Calculate spectral flux (difference from previous frame)
        if (energies.length > 1) {
          final flux = math.max(0.0, totalEnergy - energies[energies.length - 2]);
          spectralFlux.add(flux);
        }
      }
      
      if (spectralFlux.isEmpty) return 0.5;
      
      // Beat strength is based on spectral flux peaks
      final meanFlux = spectralFlux.reduce((a, b) => a + b) / spectralFlux.length;
      final fluxVariance = spectralFlux.map((f) => math.pow(f - meanFlux, 2)).reduce((a, b) => a + b) / spectralFlux.length;
      
      // Normalize to 0-1 range
      return math.min(fluxVariance / (meanFlux + 1e-6), 1.0);
    } catch (e) {
      return 0.5; // Safe fallback
    }
  }

  /// Build onset strength curve (spectral flux per frame) for long segment. Used for accurate tempo/beat.
  static List<double> _onsetStrengthCurveInIsolate(Float32List audioData) {
    const windowSize = 1024;
    const hopSize = 512;
    if (audioData.length < windowSize * 2) return [];
    final curve = <double>[];
    List<double>? prevMag;
    for (int i = 0; i <= audioData.length - windowSize; i += hopSize) {
      final window = audioData.sublist(i, i + windowSize);
      final windowed = _applyHannWindowInIsolate(Float32List.fromList(window));
      final fft = _performFFTInIsolate(windowed);
      final mag = _calculateMagnitudeSpectrumFromFFTInIsolate(fft);
      if (prevMag != null && mag.length == prevMag.length) {
        double flux = 0.0;
        for (int j = 0; j < mag.length; j++) {
          final d = mag[j] - prevMag[j];
          if (d > 0) flux += d;
        }
        curve.add(flux);
      }
      prevMag = mag;
    }
    return curve;
  }

  /// Tempo (BPM) from long segment via onset-strength FFT. More accurate than autocorrelation on <1s.
  static double _calculateTempoFromOnsetFFTInIsolate(Float32List longAudio) {
    const sampleRate = 16000.0;
    const hopSize = 512;
    const minBpm = 60.0;
    const maxBpm = 180.0;
    final curve = _onsetStrengthCurveInIsolate(longAudio);
    if (curve.length < 32) return 120.0;
    final n = curve.length;
    final fftSize = _nextPowerOf2InIsolate(n);
    final padded = Float32List(fftSize);
    for (int i = 0; i < n; i++) padded[i] = curve[i];
    final fft = _performFFTInIsolate(padded);
    final mag = _calculateMagnitudeSpectrumFromFFTInIsolate(fft);
    final half = mag.length;
    double bestBpm = 120.0;
    double bestMag = 0.0;
    for (int k = 1; k < half; k++) {
      final bpm = 60.0 * sampleRate * k / (fftSize * hopSize);
      if (bpm >= minBpm && bpm <= maxBpm) {
        final m = mag[k];
        if (m > bestMag) {
          bestMag = m;
          bestBpm = bpm;
        }
      }
    }
    return bestMag > 0 ? bestBpm : 120.0;
  }

  /// Beat strength (0-1) from long segment: normalized peak strength of tempo FFT in BPM range.
  static double _calculateBeatStrengthFromOnsetInIsolate(Float32List longAudio) {
    const sampleRate = 16000.0;
    const hopSize = 512;
    const minBpm = 60.0;
    const maxBpm = 180.0;
    final curve = _onsetStrengthCurveInIsolate(longAudio);
    if (curve.length < 32) return 0.5;
    final n = curve.length;
    final fftSize = _nextPowerOf2InIsolate(n);
    final padded = Float32List(fftSize);
    for (int i = 0; i < n; i++) padded[i] = curve[i];
    final fft = _performFFTInIsolate(padded);
    final mag = _calculateMagnitudeSpectrumFromFFTInIsolate(fft);
    final half = mag.length;
    double maxInRange = 0.0;
    double maxOverall = 0.0;
    for (int k = 1; k < half; k++) {
      final bpm = 60.0 * sampleRate * k / (fftSize * hopSize);
      if (bpm >= minBpm && bpm <= maxBpm && mag[k] > maxInRange) maxInRange = mag[k];
      if (mag[k] > maxOverall) maxOverall = mag[k];
    }
    if (maxOverall <= 0) return 0.5;
    return (maxInRange / maxOverall).clamp(0.0, 1.0);
  }

  /// Calculate spectral centroid in isolate. Uses middle window for long segments.
  static double _calculateSpectralCentroidInIsolate(Float32List audioData) {
    try {
      const windowSize = 1024;
      if (audioData.length < 64) return 2000.0;
      final List<double> window;
      if (audioData.length > windowSize * 2) {
        final start = (audioData.length - windowSize) ~/ 2;
        window = audioData.sublist(start, start + windowSize).toList();
      } else {
        window = audioData.take(windowSize).toList();
      }
      
      if (window.length < 64) {
        return 2000.0; // Default value
      }
      
      // Apply window function (Hanning window)
      final windowed = _applyHannWindowInIsolate(Float32List.fromList(window));
      
      // Calculate magnitude spectrum (simplified FFT)
      final magnitudeSpectrum = _calculateMagnitudeSpectrumInIsolate(windowed);
      
      // Calculate spectral centroid
      double weightedSum = 0.0;
      double magnitudeSum = 0.0;
      
      for (int i = 0; i < magnitudeSpectrum.length; i++) {
        final frequency = (i * 16000.0) / (2 * magnitudeSpectrum.length);
        final magnitude = magnitudeSpectrum[i];
        
        weightedSum += frequency * magnitude;
        magnitudeSum += magnitude;
      }
      
      return magnitudeSum > 0 ? weightedSum / magnitudeSum : 2000.0;
    } catch (e) {
      return 2000.0;
    }
  }

  /// Calculate spectral rolloff in isolate. Uses middle window for long segments.
  static double _calculateSpectralRolloffInIsolate(Float32List audioData) {
    try {
      const windowSize = 1024;
      if (audioData.length < 64) return 4000.0;
      final List<double> window;
      if (audioData.length > windowSize * 2) {
        final start = (audioData.length - windowSize) ~/ 2;
        window = audioData.sublist(start, start + windowSize).toList();
      } else {
        window = audioData.take(windowSize).toList();
      }
      
      if (window.length < 64) {
        return 4000.0; // Default value
      }
      
      // Apply window function
      final windowed = _applyHannWindowInIsolate(Float32List.fromList(window));
      
      // Calculate magnitude spectrum
      final magnitudeSpectrum = _calculateMagnitudeSpectrumInIsolate(windowed);
      
      // Calculate total energy
      double totalEnergy = 0.0;
      for (final magnitude in magnitudeSpectrum) {
        totalEnergy += magnitude * magnitude;
      }
      
      // Find 85% energy rolloff point
      double cumulativeEnergy = 0.0;
      for (int i = 0; i < magnitudeSpectrum.length; i++) {
        cumulativeEnergy += magnitudeSpectrum[i] * magnitudeSpectrum[i];
        if (cumulativeEnergy >= 0.85 * totalEnergy) {
          // Convert bin index to frequency
          final frequency = (i / magnitudeSpectrum.length) * 8000.0; // Nyquist frequency
          return frequency;
        }
      }
      
      return 4000.0; // Default if not found
    } catch (e) {
      return 4000.0;
    }
  }

  /// Calculate zero crossing rate in isolate (SAME AS ORIGINAL)
  static double _calculateZeroCrossingRateInIsolate(Float32List audioData) {
    int crossings = 0;
    for (int i = 1; i < audioData.length; i++) {
      if ((audioData[i] >= 0) != (audioData[i - 1] >= 0)) {
        crossings++;
      }
    }
    return crossings / (audioData.length - 1);
  }

  /// Apply Hann window in isolate (SAME AS ORIGINAL)
  static Float32List _applyHannWindowInIsolate(Float32List waveform) {
    final windowed = Float32List(waveform.length);
    for (int i = 0; i < waveform.length; i++) {
      final windowValue = 0.5 * (1 - math.cos(2 * math.pi * i / (waveform.length - 1)));
      windowed[i] = waveform[i] * windowValue;
    }
    return windowed;
  }

  /// Perform FFT in isolate (SAME AS ORIGINAL)
  static List<Complex> _performFFTInIsolate(Float32List signal) {
    final n = signal.length;
    if (n == 1) return [Complex(signal[0], 0)];
    
    // Pad to power of 2
    final paddedLength = _nextPowerOf2InIsolate(n);
    final padded = Float32List(paddedLength);
    for (int i = 0; i < n; i++) {
      padded[i] = signal[i];
    }
    
    return _fftRecursiveInIsolate(padded);
  }

  /// Recursive FFT implementation in isolate (SAME AS ORIGINAL)
  static List<Complex> _fftRecursiveInIsolate(Float32List signal) {
    final n = signal.length;
    if (n == 1) return [Complex(signal[0], 0)];
    
    // Split into even and odd
    final even = <double>[];
    final odd = <double>[];
    for (int i = 0; i < n; i += 2) {
      even.add(signal[i]);
      if (i + 1 < n) odd.add(signal[i + 1]);
    }
    
    final evenFFT = _fftRecursiveInIsolate(Float32List.fromList(even));
    final oddFFT = _fftRecursiveInIsolate(Float32List.fromList(odd));
    
    final result = List<Complex>.filled(n, Complex(0, 0));
    final halfN = n ~/ 2;
    
    for (int k = 0; k < halfN; k++) {
      final t = oddFFT[k] * Complex(math.cos(-2 * math.pi * k / n), math.sin(-2 * math.pi * k / n));
      result[k] = evenFFT[k] + t;
      result[k + halfN] = evenFFT[k] - t;
    }
    
    return result;
  }

  /// Calculate magnitude spectrum from FFT result in isolate (SAME AS ORIGINAL)
  static List<double> _calculateMagnitudeSpectrumFromFFTInIsolate(List<Complex> fft) {
    return fft.map((c) => math.sqrt(c.real * c.real + c.imaginary * c.imaginary)).toList();
  }

  /// Calculate magnitude spectrum in isolate (SAME AS ORIGINAL)
  static List<double> _calculateMagnitudeSpectrumInIsolate(Float32List data) {
    // Simplified FFT using basic DFT
    final n = data.length;
    final real = List<double>.filled(n, 0.0);
    final imag = List<double>.filled(n, 0.0);
    
    for (int k = 0; k < n; k++) {
      for (int i = 0; i < n; i++) {
        final angle = -2 * math.pi * k * i / n;
        real[k] += data[i] * math.cos(angle);
        imag[k] += data[i] * math.sin(angle);
      }
    }
    
    // Calculate magnitude
    final magnitude = <double>[];
    for (int i = 0; i < n ~/ 2; i++) { // Only use first half (Nyquist theorem)
      final mag = math.sqrt(real[i] * real[i] + imag[i] * imag[i]);
      magnitude.add(mag);
    }
    
    return magnitude;
  }

  /// Find next power of 2 in isolate (SAME AS ORIGINAL)
  static int _nextPowerOf2InIsolate(int n) {
    if (n <= 0) return 1;
    if ((n & (n - 1)) == 0) return n;
    return 1 << (n.bitLength);
  }

  /// Advanced danceability in isolate: tempo zone (95–135 BPM), beat strength, regularity, energy, bass, loudness.
  static double _calculateDanceabilityAdvancedInIsolate(
    Float32List waveform,
    double tempoBpm,
    double beatStrength,
    double energy,
  ) {
    if (waveform.isEmpty) return 0.0;
    const optBpmLow = 95.0;
    const optBpmHigh = 135.0;
    const optBpmPeak = 115.0;
    double tempoFactor;
    if (tempoBpm >= optBpmLow && tempoBpm <= optBpmHigh) {
      final distFromPeak = (tempoBpm - optBpmPeak).abs();
      tempoFactor = 0.7 + 0.3 * math.max(0.0, 1.0 - distFromPeak / 25.0);
    } else if (tempoBpm < optBpmLow) {
      tempoFactor = 0.3 * (tempoBpm / optBpmLow);
    } else {
      tempoFactor = math.max(0.0, 0.5 - (tempoBpm - optBpmHigh) / 120.0);
    }
    tempoFactor = tempoFactor.clamp(0.0, 1.0);
    final beatComponent = beatStrength.clamp(0.0, 1.0);
    final regularity = _calculateBeatRegularityInIsolate(waveform);
    final energyComponent = math.min(1.0, ((energy - 0.2).clamp(0.0, 0.7) / 0.7) * 1.2);
    final bassComponent = _calculateBassRatioInIsolate(waveform);
    final loudnessComponent = _calculateLoudnessInIsolate(waveform).clamp(0.0, 1.0);
    const wTempo = 0.28;
    const wBeat = 0.23;
    const wRegularity = 0.18;
    const wEnergy = 0.14;
    const wBass = 0.09;
    const wLoudness = 0.08;
    final raw = wTempo * tempoFactor + wBeat * beatComponent + wRegularity * regularity + wEnergy * energyComponent + wBass * bassComponent + wLoudness * loudnessComponent;
    return raw.clamp(0.0, 1.0);
  }

  static double _calculateBeatRegularityInIsolate(Float32List waveform) {
    try {
      const windowSize = 1024;
      const hopSize = 512;
      if (waveform.length < windowSize * 3) return 0.5;
      final energies = <double>[];
      for (int i = 0; i < waveform.length - windowSize; i += hopSize) {
        final window = waveform.sublist(i, i + windowSize);
        energies.add(_calculateEnergyInIsolate(Float32List.fromList(window)));
      }
      if (energies.length < 4) return 0.5;
      final mean = energies.reduce((a, b) => a + b) / energies.length;
      final variance = energies.map((e) => math.pow(e - mean, 2)).reduce((a, b) => a + b) / energies.length;
      final std = math.sqrt(variance);
      if (mean < 1e-9) return 0.5;
      final cv = std / mean;
      return (1.0 / (1.0 + cv * 2.0)).clamp(0.0, 1.0);
    } catch (e) {
      return 0.5;
    }
  }

  static double _calculateBassRatioInIsolate(Float32List waveform) {
    try {
      const maxWindow = 1024;
      final Float32List toUse;
      if (waveform.length > maxWindow) {
        final start = (waveform.length - maxWindow) ~/ 2;
        toUse = Float32List.sublistView(waveform, start, start + maxWindow);
      } else {
        toUse = waveform;
      }
      final windowed = _applyHannWindowInIsolate(toUse);
      final magnitudeSpectrum = _calculateMagnitudeSpectrumInIsolate(windowed);
      if (magnitudeSpectrum.isEmpty) return 0.25;
      final lowLen = (magnitudeSpectrum.length / 4).clamp(1.0, magnitudeSpectrum.length.toDouble()).toInt();
      final lowEnergy = magnitudeSpectrum.take(lowLen).fold<double>(0.0, (s, m) => s + m);
      final total = magnitudeSpectrum.fold<double>(0.0, (s, m) => s + m);
      if (total < 1e-9) return 0.25;
      return (lowEnergy / total).clamp(0.0, 1.0);
    } catch (e) {
      return 0.25;
    }
  }

  /// Categorize tempo in isolate (SAME AS ORIGINAL)
  static String _categorizeTempoInIsolate(double bpm) {
    if (bpm < 60) return 'Very Slow';
    if (bpm < 80) return 'Slow';
    if (bpm < 120) return 'Moderate';
    if (bpm < 140) return 'Fast';
    return 'Very Fast';
  }

  /// Categorize beat in isolate (SAME AS ORIGINAL)
  static String _categorizeBeatInIsolate(double strength) {
    if (strength < 0.3) return 'Soft';
    if (strength < 0.7) return 'Medium';
    return 'Strong';
  }

  /// Categorize energy in isolate (SAME AS ORIGINAL)
  static String _categorizeEnergyInIsolate(double energy) {
    if (energy < 0.3) return 'Low';
    if (energy < 0.7) return 'Medium';
    return 'High';
  }

  /// Categorize vocals in isolate (SAME AS ORIGINAL)
  static String _categorizeVocalsInIsolate(double intensity) {
    if (intensity < 0.3) return 'Soft';
    if (intensity < 0.7) return 'Medium';
    return 'Strong';
  }

  /// Categorize mood in isolate (SAME AS ORIGINAL)
  static String _categorizeMoodInIsolate(List<String> moodTags) {
    if (moodTags.isEmpty) return 'Neutral';
    final positive = ['happy', 'upbeat', 'energetic', 'joyful', 'cheerful'];
    final negative = ['sad', 'melancholy', 'dark', 'somber', 'gloomy'];
    final calm = ['calm', 'peaceful', 'relaxing', 'serene', 'tranquil'];
    for (final tag in moodTags) {
      final lower = tag.toLowerCase();
      if (positive.any((m) => lower.contains(m))) return 'Happy';
      if (negative.any((m) => lower.contains(m))) return 'Sad';
      if (calm.any((m) => lower.contains(m))) return 'Calm';
    }
    return 'Neutral';
  }

  /// Advanced mood category in isolate: Chill/Sleeping, Party/Energetic, Rap/Hip-hop, Very Happy/Upbeat, etc.
  /// [moodScore] when non-null enables "Very Happy / Upbeat" vs "Upbeat / Happy" and Sad/Calm/Neutral from score.
  static String _computeMoodCategoryInIsolate(
    List<String> moodTags,
    String genre,
    double tempoBpm,
    double energy, [
    double? moodScore,
  ]) {
    final s = (moodScore ?? 0.5).clamp(0.0, 1.0);
    final genreLower = genre.toLowerCase();
    final tagsLower = moodTags.map((t) => t.toLowerCase()).toList();
    bool hasTag(String sub) => tagsLower.any((t) => t.contains(sub));
    bool genreHas(String sub) => genreLower.contains(sub);

    if (hasTag('lullaby') || hasTag('sleep') || hasTag('chill') || hasTag('ambient') || hasTag('soothing') || (tempoBpm < 85 && energy < 0.35)) return 'Chill / Sleeping';
    if (hasTag('meditation') || hasTag('zen') || hasTag('peaceful') || (energy < 0.25 && tempoBpm < 90)) return 'Meditation';
    if (s < 0.3 || hasTag('sad') || hasTag('melancholy') || hasTag('gloomy') || hasTag('somber')) return 'Sad / Melancholy';
    if (hasTag('scary') || hasTag('dark') || hasTag('angry') || hasTag('frighten') || hasTag('tense')) return 'Scary / Dark';
    if (genreHas('hip') || genreHas('rap') || hasTag('rap') || hasTag('hip')) return 'Rap / Hip-hop';
    if (hasTag('party') || hasTag('dance') || hasTag('energetic') || hasTag('celebrat') || (tempoBpm >= 120 && energy >= 0.65)) return 'Party / Energetic';
    if (hasTag('workout') || hasTag('intense') || hasTag('powerful') || hasTag('driving') || (tempoBpm >= 125 && energy >= 0.7)) return 'Workout';
    if (hasTag('romantic') || hasTag('tender') || hasTag('love') || hasTag('passionate')) return 'Romantic';
    if (s >= 0.7 || hasTag('happy') || hasTag('joyful') || hasTag('upbeat') || hasTag('cheerful')) {
      return s >= 0.85 ? 'Very Happy / Upbeat' : 'Upbeat / Happy';
    }
    if (hasTag('focus') || hasTag('study') || (tempoBpm >= 80 && tempoBpm <= 110 && energy >= 0.3 && energy <= 0.6)) return 'Focus / Study';
    if (s < 0.45 || hasTag('calm') || hasTag('relaxing') || hasTag('serene')) return 'Calm';
    if (s < 0.55) return 'Neutral';
    return _categorizeMoodInIsolate(moodTags);
  }

  /// Process songs with UI responsiveness. [durationMsByPath] is required (no metadata fetch).
  static Future<Map<String, ExtractedSongFeatures?>> _processSongsWithUIResponsiveness(
    List<String> filePaths,
    Function(String filePath, ExtractedSongFeatures? features)? onSongUpdated,
    Function(int current, int total)? onProgress, {
    required Map<String, int> durationMsByPath,
  }) async {
    final results = <String, ExtractedSongFeatures?>{};

    for (int i = 0; i < filePaths.length; i++) {
      final filePath = filePaths[i];
      final durationMs = durationMsByPath[filePath];
      if (durationMs == null || durationMs <= 0) {
        _logger.w('Skipping ${_getFileName(filePath)}: duration missing or invalid in durationMsByPath');
        results[filePath] = null;
        onSongUpdated?.call(filePath, null);
        onProgress?.call(i + 1, filePaths.length);
        continue;
      }

      try {
        onProgress?.call(i + 1, filePaths.length);
        final features = await _extractFeaturesInIsolate(filePath, durationMs: durationMs);
        
        results[filePath] = features;
        
        // Call song updated callback
        onSongUpdated?.call(filePath, features);
        
        if (features != null) {
        } else {
          _logger.w('Failed to extract features: ${_getFileName(filePath)}');
        }
        
        // Allow UI to update by yielding control (same as original)
        await Future.delayed(Duration.zero);
        
      } catch (e) {
        _logger.e('Error processing song: $filePath', error: e);
        results[filePath] = null;
        onSongUpdated?.call(filePath, null);
      }
    }
    
    return results;
  }

  /// Extract features in isolate to prevent UI blocking.
  /// Audio extraction runs on the MAIN isolate (FFmpegKit uses platform channels and cannot run inside compute).
  /// Only YAMNet + signal processing run in the background isolate.
  /// [durationMs] improves middle-segment accuracy when provided (e.g. from metadata).
  static Future<ExtractedSongFeatures?> _extractFeaturesInIsolate(String filePath, {int? durationMs}) async {
    try {
      final modelBytes = _extractor?.getModelBytes();
      final labels = _extractor?.getLabels();
      if (modelBytes == null || labels == null) {
        _logger.e('Model or labels not available - ensure initialize() was called');
        return null;
      }

      final duration = durationMs ?? 0;
      const minDurationForThreePartMs = 30000;
      Float32List? preExtractedAudio;
      List<Float32List>? preExtractedAudios;

      if (duration >= minDurationForThreePartMs) {
        // Prefer 3 long segments (6s each) from middle of each third: all features from long segments for accuracy
        final longSegments = await FeatureExtractor.extractThreeLongSegmentsBatchOnMain(filePath, duration);
        if (longSegments != null && longSegments.length == 3) {
          preExtractedAudios = longSegments;
        } else {
          final startTimes = FeatureExtractor.getThreePartStartTimesSeconds(duration);
          if (startTimes.length >= 3) {
            List<Float32List>? segments = await FeatureExtractor.extractThreeSegmentsBatchOnMain(filePath, startTimes);
            if (segments == null || segments.length < 3) {
              segments = <Float32List>[];
              for (final startSec in startTimes) {
                final audio = await FeatureExtractor.extractSegmentAtStartOnMain(filePath, startSec);
                if (audio != null) segments.add(audio);
              }
            }
            if (segments.isNotEmpty) preExtractedAudios = segments;
          }
        }
      }
      if (preExtractedAudios == null) {
        preExtractedAudio = await FeatureExtractor.extractAudioOnMain(filePath, duration);
      }

      final hasAudio = (preExtractedAudios != null && preExtractedAudios.isNotEmpty) ||
          (preExtractedAudio != null);
      if (!hasAudio) {
        _logger.w('No audio extracted for: ${_getFileName(filePath)}');
        return null;
      }

      final input = IsolateInputData(
        filePath: filePath,
        durationMs: duration,
        yamnetModelBytes: modelBytes,
        yamnetLabels: labels,
        modelVersion: '1.0.0',
        fileName: _getFileName(filePath),
        preExtractedAudio: preExtractedAudio,
        preExtractedAudios: preExtractedAudios,
      );
      return await compute(_extractFeaturesInIsolateFull, input);
    } catch (e) {
      _logger.e('❌ Error in isolate processing: $e');
      return null;
    }
  }

  /// Full isolate entry: run YAMNet + signal processing only. Audio must be pre-extracted on main (FFmpegKit cannot run in isolate).
  /// When [input.preExtractedAudios] has segments, uses 3-part analysis (mean of features). Otherwise uses [input.preExtractedAudio].
  /// Uses a single interpreter for all segments to avoid native resource exhaustion.
  static Future<ExtractedSongFeatures?> _extractFeaturesInIsolateFull(IsolateInputData input) async {
    try {
      final song = SongModel(
        id: input.filePath.hashCode.toString(),
        title: input.fileName,
        artist: 'Unknown',
        album: 'Unknown',
        duration: input.durationMs,
        filePath: input.filePath,
        features: null,
      );
      // When 3-part: each segment is long (6s). YAMNet uses first 0.975s; all signal features from full segment.
      final segments = input.preExtractedAudios;
      if (segments != null && segments.isNotEmpty) {
        Interpreter? interpreter;
        try {
          interpreter = Interpreter.fromBuffer(input.yamnetModelBytes);
          final parts = <ExtractedSongFeatures>[];
          const segmentTimeout = Duration(seconds: 60);
          for (final audioData in segments) {
            final partFeatures = await _extractFeaturesWithPreloadedData(
              song,
              interpreter,
              input.yamnetLabels,
              input.modelVersion,
              audioData,
            ).timeout(segmentTimeout, onTimeout: () => null);
            if (partFeatures != null) parts.add(partFeatures);
          }
          if (parts.isNotEmpty) return _combineMultiPartFeatures(parts);
        } finally {
          interpreter?.close();
        }
      }
      if (input.preExtractedAudio != null) {
        final isolateData = IsolateFeatureData(
          song: song,
          yamnetModelBytes: input.yamnetModelBytes,
          yamnetLabels: input.yamnetLabels,
          modelVersion: input.modelVersion,
          audioData: input.preExtractedAudio,
        );
        return await _extractFeaturesInIsolateHelper(isolateData)
            .timeout(const Duration(seconds: 60), onTimeout: () => null);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Combine multi-part (e.g. 3-part) segment results: mean for numeric fields, merge/dedupe lists, pick categorical from max-confidence segment.
  static ExtractedSongFeatures _combineMultiPartFeatures(List<ExtractedSongFeatures> parts) {
    if (parts.length == 1) return parts.first;
    final n = parts.length;
    double mean(Iterable<double> values) => values.reduce((a, b) => a + b) / n;
    var bestIdx = 0;
    for (var i = 1; i < parts.length; i++) {
      if (parts[i].confidence > parts[bestIdx].confidence) bestIdx = i;
    }
    final best = parts[bestIdx];
    final instruments = <String>{};
    final moodTagsSet = <String>{};
    for (final p in parts) {
      instruments.addAll(p.instruments);
      moodTagsSet.addAll(p.moodTags);
    }
    return ExtractedSongFeatures(
      tempo: best.tempo,
      beat: best.beat,
      energy: best.energy,
      instruments: instruments.toList(),
      vocals: parts.any((p) => p.vocals != null) ? best.vocals : null,
      mood: best.mood,
      yamnetInstruments: instruments.toList(),
      hasVocals: parts.any((p) => p.hasVocals),
      estimatedGenre: best.estimatedGenre,
      yamnetEnergy: mean(parts.map((p) => p.yamnetEnergy)),
      moodTags: moodTagsSet.toList(),
      tempoBpm: mean(parts.map((p) => p.tempoBpm)),
      beatStrength: mean(parts.map((p) => p.beatStrength)),
      signalEnergy: mean(parts.map((p) => p.signalEnergy)),
      brightness: mean(parts.map((p) => p.brightness)),
      danceability: mean(parts.map((p) => p.danceability)),
      loudness: mean(parts.map((p) => p.loudness)),
      overallEnergy: mean(parts.map((p) => p.overallEnergy)),
      intensity: mean(parts.map((p) => p.intensity)),
      spectralCentroid: mean(parts.map((p) => p.spectralCentroid)),
      spectralRolloff: mean(parts.map((p) => p.spectralRolloff)),
      zeroCrossingRate: mean(parts.map((p) => p.zeroCrossingRate)),
      spectralFlux: mean(parts.map((p) => p.spectralFlux)),
      complexity: mean(parts.map((p) => p.complexity)),
      valence: mean(parts.map((p) => p.valence)),
      arousal: mean(parts.map((p) => p.arousal)),
      confidence: mean(parts.map((p) => p.confidence)),
      analyzedAt: DateTime.now(),
      analyzerVersion: best.analyzerVersion,
    );
  }

  /// Helper function for isolate processing with pre-loaded data.
  /// Interpreter is always closed in finally to avoid native resource leaks.
  static Future<ExtractedSongFeatures?> _extractFeaturesInIsolateHelper(IsolateFeatureData data) async {
    Interpreter? interpreter;
    try {
      interpreter = Interpreter.fromBuffer(data.yamnetModelBytes);
      return await _extractFeaturesWithPreloadedData(
        data.song,
        interpreter,
        data.yamnetLabels,
        data.modelVersion,
        data.audioData,
      );
    } catch (_) {
      return null;
    } finally {
      interpreter?.close();
    }
  }

  /// Extract features using pre-loaded model and labels (SAME AS ORIGINAL)
  static Future<ExtractedSongFeatures?> _extractFeaturesWithPreloadedData(
    SongModel song,
    Interpreter interpreter,
    List<String> yamnetLabels,
    String modelVersion,
    Float32List? audioData,
  ) async {
    try {
      if (audioData == null || audioData.isEmpty) {
        _logger.w('No pre-processed audio for: ${song.title}');
        return null;
      }

      // Run YAMNet inference (uses first 15,600 samples; full audioData used for signal features)
      final yamnetResults = await _runYAMNetInference(interpreter, audioData);
      
      // Process YAMNet results
      final yamnetFeatures = _processYAMNetResultsInIsolate(yamnetResults, yamnetLabels);
      
      // Calculate real signal features (SAME AS ORIGINAL)
      final signalFeatures = _calculateSignalFeaturesInIsolate(audioData);
      
      
      // Create comprehensive features (SAME AS ORIGINAL)
      final yamnetEnergyVal = (yamnetFeatures['energyValue'] as num).toDouble().clamp(0.0, 1.0);
      final signalEnergyVal = signalFeatures.energy.clamp(0.0, 1.0);
      final moodTagsList = yamnetFeatures['moodTags'] as List<String>;
      final valenceVal = _calculateValenceInIsolate(yamnetEnergyVal, moodTagsList, signalEnergyVal);
      final arousalVal = _calculateArousalInIsolate(yamnetEnergyVal, signalFeatures.tempoBpm, signalEnergyVal);
      final complexityVal = (signalFeatures.zeroCrossingRate.clamp(0.0, 1.0) + (signalFeatures.spectralCentroid / 8000.0) + 0.5) / 3.0;

      final songFeatures = ExtractedSongFeatures(
        tempo: _categorizeTempoInIsolate(signalFeatures.tempoBpm),
        beat: _categorizeBeatInIsolate(signalFeatures.beatStrength),
        energy: _categorizeEnergyInIsolate(signalFeatures.energy),
        instruments: yamnetFeatures['instruments'] as List<String>,
        vocals: yamnetFeatures['hasVocals'] as bool ? _categorizeVocalsInIsolate((yamnetFeatures['vocalIntensity'] as num?)?.toDouble() ?? yamnetEnergyVal) : null,
        mood: _computeMoodCategoryInIsolate(
          moodTagsList,
          _genreFromMap(yamnetFeatures['genre']),
          signalFeatures.tempoBpm,
          signalEnergyVal,
          (yamnetFeatures['moodScore'] as num?)?.toDouble(),
        ),
        yamnetInstruments: yamnetFeatures['instruments'] as List<String>,
        hasVocals: yamnetFeatures['hasVocals'] as bool,
        estimatedGenre: _genreFromMap(yamnetFeatures['genre']),
        yamnetEnergy: yamnetEnergyVal,
        moodTags: moodTagsList,
        tempoBpm: signalFeatures.tempoBpm,
        beatStrength: signalFeatures.beatStrength,
        signalEnergy: signalEnergyVal,
        brightness: signalFeatures.brightness,
        danceability: signalFeatures.danceability,
        loudness: signalFeatures.loudness,
        overallEnergy: (yamnetEnergyVal + signalEnergyVal) / 2.0,
        intensity: signalEnergyVal,
        spectralCentroid: signalFeatures.spectralCentroid,
        spectralRolloff: signalFeatures.spectralRolloff,
        zeroCrossingRate: signalFeatures.zeroCrossingRate,
        spectralFlux: signalEnergyVal * 0.5,
        complexity: complexityVal.clamp(0.0, 1.0),
        valence: valenceVal,
        arousal: arousalVal,
        confidence: (signalFeatures.beatStrength + signalEnergyVal + signalFeatures.brightness) / 3.0,
        analyzerVersion: modelVersion,
        analyzedAt: DateTime.now(),
      );

      return songFeatures;
    } catch (e) {
      _logger.e('Error extracting features: ${song.title}', error: e);
      return null;
    }
  }

  /// Run YAMNet inference
  static Future<List<double>> _runYAMNetInference(
    Interpreter interpreter,
    Float32List audioData,
  ) async {
    try {
      // Prepare input tensor (ensure 15,600 samples)
      final inputWaveform = _prepareYAMNetInput(audioData);
      final input = [inputWaveform];
      final output = [List.filled(521, 0.0)]; // 2D array: [1, 521]
      
      // Run inference
      interpreter.run(input, output);
      
      return output[0];
    } catch (e) {
      _logger.e('YAMNet inference failed', error: e);
      return List.filled(521, 0.0);
    }
  }

  /// Prepare YAMNet input (ensure 15,600 samples)
  static Float32List _prepareYAMNetInput(Float32List waveform) {
    const expectedSamples = 15600;
    
    if (waveform.length == expectedSamples) {
      return waveform;
    } else if (waveform.length > expectedSamples) {
      return Float32List.sublistView(waveform, 0, expectedSamples);
    } else {
      final padded = Float32List(expectedSamples);
      for (int i = 0; i < waveform.length; i++) {
        padded[i] = waveform[i];
      }
      return padded;
    }
  }

  /// Check if label is an instrument
  static bool _isInstrument(String label) {
    final instrumentKeywords = [
      'guitar', 'piano', 'drum', 'violin', 'bass', 'saxophone',
      'trumpet', 'flute', 'clarinet', 'organ', 'synthesizer'
    ];
    return instrumentKeywords.any((keyword) => label.toLowerCase().contains(keyword));
  }

  /// Check if label indicates vocals
  static bool _isVocal(String label) {
    final vocalKeywords = [
      'voice', 'vocal', 'singing', 'speech', 'talking', 'whispering'
    ];
    return vocalKeywords.any((keyword) => label.toLowerCase().contains(keyword));
  }

  /// Check if label is a genre
  static bool _isGenre(String label) {
    final genreKeywords = [
      'rock', 'pop', 'jazz', 'classical', 'blues', 'country',
      'electronic', 'hip hop', 'reggae', 'folk', 'metal',
      'heavy metal', 'punk rock', 'progressive rock', 'psychedelic rock',
      'rock and roll', 'rhythm and blues', 'soul music', 'swing music',
      'bluegrass', 'folk music', 'middle eastern music', 'opera',
      'drum and bass', 'electronica', 'electronic dance music',
      'ambient music', 'trance music', 'music of latin america',
      'salsa music', 'flamenco', 'music for children', 'new-age music',
      'vocal music', 'a capella', 'music of africa', 'afrobeat',
      'christian music', 'gospel music', 'music of asia', 'carnatic music',
      'music of bollywood', 'ska', 'traditional music', 'independent music',
      'background music', 'theme music', 'jingle', 'soundtrack music',
      'lullaby', 'video game music', 'christmas music', 'dance music',
      'wedding music', 'happy music', 'sad music', 'tender music',
      'exciting music', 'angry music', 'scary music', 'music'
    ];
    final lower = label.toLowerCase();
    
    // Check for exact matches first
    if (genreKeywords.any((keyword) => lower == keyword)) return true;
    
    // Check for partial matches
    if (genreKeywords.any((keyword) => lower.contains(keyword))) return true;
    
    // Check for music-related terms
    if (lower.contains('music') || lower.contains('song') || lower.contains('tune')) return true;
    
    return false;
  }

  /// Check if label indicates mood
  static bool _isMood(String label) {
    final moodKeywords = [
      'happy', 'sad', 'calm', 'energetic', 'peaceful', 'melancholy',
      'upbeat', 'relaxing', 'exciting', 'dramatic'
    ];
    return moodKeywords.any((keyword) => label.toLowerCase().contains(keyword));
  }
}

/// Input for background isolate: file path, duration, and pre-loaded model/labels.
/// Pre-extracted audio is passed from main isolate because FFmpegKit (platform channel) cannot run inside compute isolate.
class IsolateInputData {
  final String filePath;
  final int durationMs;
  final Uint8List yamnetModelBytes;
  final List<String> yamnetLabels;
  final String modelVersion;
  final String fileName;
  /// Single segment (used when duration < 30s or fallback). Extracted on main thread.
  final Float32List? preExtractedAudio;
  /// Multiple segments for 3-part analysis (duration >= 30s). Each can be long (6s) for accuracy.
  final List<Float32List>? preExtractedAudios;

  const IsolateInputData({
    required this.filePath,
    required this.durationMs,
    required this.yamnetModelBytes,
    required this.yamnetLabels,
    required this.modelVersion,
    required this.fileName,
    this.preExtractedAudio,
    this.preExtractedAudios,
  });
}

/// Data model for passing feature extraction data to isolates
/// This allows us to pre-load assets in the main thread and pass them to isolates
class IsolateFeatureData {
  final SongModel song;
  final Uint8List yamnetModelBytes;
  final List<String> yamnetLabels;
  final String modelVersion;
  final Float32List? audioData; // Pre-processed audio data

  const IsolateFeatureData({
    required this.song,
    required this.yamnetModelBytes,
    required this.yamnetLabels,
    required this.modelVersion,
    this.audioData,
  });
}

/// Signal processing features
class SignalFeatures {
  final double tempoBpm;
  final double beatStrength;
  final double energy;
  final double brightness;
  final double danceability;
  final double loudness;
  final double spectralCentroid;
  final double spectralRolloff;
  final double zeroCrossingRate;

  SignalFeatures({
    required this.tempoBpm,
    required this.beatStrength,
    required this.energy,
    required this.brightness,
    required this.danceability,
    required this.loudness,
    required this.spectralCentroid,
    required this.spectralRolloff,
    required this.zeroCrossingRate,
  });
}


/// Complex number class for FFT calculations (SAME AS ORIGINAL)
class Complex {
  final double real;
  final double imaginary;

  Complex(this.real, this.imaginary);

  Complex operator +(Complex other) {
    return Complex(real + other.real, imaginary + other.imaginary);
  }

  Complex operator -(Complex other) {
    return Complex(real - other.real, imaginary - other.imaginary);
  }

  Complex operator *(Complex other) {
    return Complex(
      real * other.real - imaginary * other.imaginary,
      real * other.imaginary + imaginary * other.real,
    );
  }
}

/// Peak data class for tempo detection (SAME AS ORIGINAL)
class Peak {
  final int lag;
  final double strength;

  Peak({
    required this.lag,
    required this.strength,
  });
}