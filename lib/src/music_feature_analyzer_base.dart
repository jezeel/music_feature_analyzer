import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'models/song_features.dart';
import 'models/song_model.dart';
import 'services/feature_extractor.dart';

/// Main Music Feature Analyzer class
/// 
/// This is the primary interface for analyzing music features from audio files.
/// It provides a simple API for extracting comprehensive musical features
/// using YAMNet AI model and advanced signal processing.
class MusicFeatureAnalyzer {
  static final Logger _logger = Logger();
  static FeatureExtractor? _extractor;
  static bool _isInitialized = false;
  static bool _isBackgroundProcessing = false;

  /// Initialize the analyzer with required models and assets
  /// 
  /// This must be called before using any analysis functions.
  /// It loads the YAMNet model and prepares the analysis pipeline.
  static Future<bool> initialize() async {
    try {
      _logger.i('🎵 Initializing Music Feature Analyzer...');
      
      _extractor = FeatureExtractor();
      final success = await _extractor!.initialize();
      
      if (success) {
        _isInitialized = true;
        _logger.i('✅ Music Feature Analyzer initialized successfully');
        return true;
      } else {
        _logger.e('❌ Failed to initialize Music Feature Analyzer');
        return false;
      }
    } catch (e) {
      _logger.e('❌ Error initializing Music Feature Analyzer: $e');
      return false;
    }
  }

  /// Analyze a single song file and extract comprehensive features
  /// 
  /// [filePath] - Path to the audio file (supports MP3, WAV, FLAC, etc.)
  /// [options] - Optional analysis configuration
  /// 
  /// Returns [SongFeatures] with all extracted musical features
  static Future<SongFeatures?> analyzeSong(
    String filePath, {
    AnalysisOptions? options,
  }) async {
    if (!_isInitialized || _extractor == null) {
      _logger.e('❌ Analyzer not initialized. Call initialize() first.');
      return null;
    }

    try {
      _logger.i('🎵 Analyzing song: $filePath');
      
      // Check if file exists
      final file = File(filePath);
      if (!await file.exists()) {
        _logger.e('❌ File does not exist: $filePath');
        return null;
      }

      // Create song model
      final song = Song(
        id: filePath.hashCode.toString(),
        title: _getFileName(filePath),
        artist: 'Unknown',
        album: 'Unknown',
        duration: 0, // Will be updated during analysis
        filePath: filePath,
        features: null, // Will be populated
      );

      // Extract features
      final features = await _extractor!.extractSongFeatures(song);
      
      if (features != null) {
        _logger.i('✅ Analysis completed for: ${song.title}');
        _logger.d('🎵 Genre: ${features.estimatedGenre}');
        _logger.d('🎵 Tempo: ${features.tempoBpm.toStringAsFixed(1)} BPM');
        _logger.d('🎵 Instruments: ${features.instruments.join(', ')}');
      } else {
        _logger.w('⚠️ No features extracted for: ${song.title}');
      }

      return features;
    } catch (e) {
      _logger.e('❌ Error analyzing song: $e');
      return null;
    }
  }

  /// Analyze multiple songs in batch
  /// 
  /// [filePaths] - List of audio file paths
  /// [options] - Optional analysis configuration
  /// [onProgress] - Optional progress callback
  /// 
  /// Returns Map of filePath -> SongFeatures
  static Future<Map<String, SongFeatures?>> analyzeSongs(
    List<String> filePaths, {
    AnalysisOptions? options,
    Function(int current, int total)? onProgress,
  }) async {
    if (!_isInitialized || _extractor == null) {
      _logger.e('❌ Analyzer not initialized. Call initialize() first.');
      return {};
    }

    final results = <String, SongFeatures?>{};
    
    for (int i = 0; i < filePaths.length; i++) {
      final filePath = filePaths[i];
      
      // Call progress callback
      onProgress?.call(i + 1, filePaths.length);
      
      _logger.i('🎵 Analyzing song ${i + 1}/${filePaths.length}: $filePath');
      
      final features = await analyzeSong(filePath, options: options);
      results[filePath] = features;
    }

    return results;
  }

  /// Extract features in background with isolate-based processing
  /// 
  /// This is the main background processing method that uses isolates
  /// to prevent UI blocking during heavy feature extraction.
  static Future<Map<String, SongFeatures?>> extractFeaturesInBackground(
    List<String> filePaths, {
    Function(int current, int total)? onProgress,
    Function(String filePath, SongFeatures? features)? onSongUpdated,
    Function()? onCompleted,
    Function(String error)? onError,
  }) async {
    if (_isBackgroundProcessing) {
      _logger.w('⚠️ Feature extraction already in progress');
      return {};
    }

    if (!_isInitialized || _extractor == null) {
      _logger.e('❌ Analyzer not initialized. Call initialize() first.');
      return {};
    }

    _isBackgroundProcessing = true;
    _logger.i('🎵 Starting UI-responsive background feature extraction for ${filePaths.length} songs...');
    
    try {
      // Filter songs that need analysis (same as original)
      final songsNeedingAnalysis = filePaths.where((filePath) {
        // For now, assume all songs need analysis
        // In a real implementation, you'd check if features already exist
        return true;
      }).toList();

      if (songsNeedingAnalysis.isEmpty) {
        _logger.i('✅ All songs already analyzed');
        onCompleted?.call();
        return {};
      }

      _logger.i('🎵 Found ${songsNeedingAnalysis.length} songs needing analysis');

      // Process songs with UI responsiveness (same as original)
      final results = await _processSongsWithUIResponsiveness(
        songsNeedingAnalysis,
        onSongUpdated,
        onProgress,
      );
      
      _logger.i('✅ UI-responsive background extraction completed');
      onCompleted?.call();
      return results;
    } catch (e) {
      _logger.e('❌ Error in UI-responsive background extraction: $e');
      onError?.call(e.toString());
      return {};
    } finally {
      _isBackgroundProcessing = false;
    }
  }

  /// Extract features in isolate to prevent UI blocking
  static Future<SongFeatures?> _extractFeaturesInIsolate(String filePath) async {
    try {
      // Create song model
      final song = Song(
        id: filePath.hashCode.toString(),
        title: _getFileName(filePath),
        artist: 'Unknown',
        album: 'Unknown',
        duration: 0,
        filePath: filePath,
        features: null,
      );

      // Use compute for isolate-based processing
      return await compute(_extractFeaturesInIsolateHelper, song);
    } catch (e) {
      _logger.e('❌ Error in isolate processing: $e');
      return null;
    }
  }

  /// Helper function for isolate processing
  static Future<SongFeatures?> _extractFeaturesInIsolateHelper(Song song) async {
    try {
      // Create a new extractor instance for the isolate
      final extractor = FeatureExtractor();
      await extractor.initialize();
      
      final features = await extractor.extractSongFeatures(song);
      await extractor.dispose();
      
      return features;
    } catch (e) {
      return null;
    }
  }

  /// Process songs with UI responsiveness using proper async scheduling (same as original)
  static Future<Map<String, SongFeatures?>> _processSongsWithUIResponsiveness(
    List<String> filePaths,
    Function(String filePath, SongFeatures? features)? onSongUpdated,
    Function(int current, int total)? onProgress,
  ) async {
    final results = <String, SongFeatures?>{};
    
    for (int i = 0; i < filePaths.length; i++) {
      final filePath = filePaths[i];
      
      try {
        // Call progress callback
        onProgress?.call(i + 1, filePaths.length);
        
        _logger.i('🎵 Processing song ${i + 1}/${filePaths.length}: $filePath');
        
        // Use isolate for heavy processing
        final features = await _extractFeaturesInIsolate(filePath);
        
        results[filePath] = features;
        
        // Call song updated callback
        onSongUpdated?.call(filePath, features);
        
        if (features != null) {
          _logger.d('✅ Features extracted for: ${_getFileName(filePath)}');
        } else {
          _logger.w('⚠️ Failed to extract features for: ${_getFileName(filePath)}');
        }
        
        // Allow UI to update by yielding control (same as original)
        await Future.delayed(Duration.zero);
        
      } catch (e) {
        _logger.e('❌ Error processing song $filePath: $e');
        results[filePath] = null;
      }
    }
    
    return results;
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

  /// Dispose resources
  static Future<void> dispose() async {
    if (_extractor != null) {
      await _extractor!.dispose();
      _extractor = null;
    }
    _isInitialized = false;
    _logger.i('🧹 Music Feature Analyzer disposed');
  }

  /// Extract filename from path
  static String _getFileName(String path) {
    return path.split('/').last.split('\\').last;
  }
}

/// Analysis configuration options
class AnalysisOptions {
  final bool enableYAMNet;
  final bool enableSignalProcessing;
  final bool enableSpectralAnalysis;
  final double confidenceThreshold;
  final int maxInstruments;
  final bool verboseLogging;

  const AnalysisOptions({
    this.enableYAMNet = true,
    this.enableSignalProcessing = true,
    this.enableSpectralAnalysis = true,
    this.confidenceThreshold = 0.1,
    this.maxInstruments = 10,
    this.verboseLogging = false,
  });
}

