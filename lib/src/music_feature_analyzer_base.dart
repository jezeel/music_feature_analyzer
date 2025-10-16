import 'dart:io';
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

  /// Get analysis statistics
  static AnalysisStats getStats() {
    return _extractor?.getStatistics() ?? AnalysisStats.empty();
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

/// Analysis statistics
class AnalysisStats {
  final int totalSongs;
  final int successfulAnalyses;
  final int failedAnalyses;
  final double averageProcessingTime;
  final Map<String, int> genreDistribution;
  final Map<String, int> instrumentDistribution;

  const AnalysisStats({
    required this.totalSongs,
    required this.successfulAnalyses,
    required this.failedAnalyses,
    required this.averageProcessingTime,
    required this.genreDistribution,
    required this.instrumentDistribution,
  });

  factory AnalysisStats.empty() {
    return const AnalysisStats(
      totalSongs: 0,
      successfulAnalyses: 0,
      failedAnalyses: 0,
      averageProcessingTime: 0.0,
      genreDistribution: {},
      instrumentDistribution: {},
    );
  }

  double get successRate => totalSongs > 0 ? successfulAnalyses / totalSongs : 0.0;
  double get failureRate => totalSongs > 0 ? failedAnalyses / totalSongs : 0.0;
}
