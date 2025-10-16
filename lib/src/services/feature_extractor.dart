import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/song_model.dart';
import '../models/song_features.dart';
import 'yamnet_helper.dart';
import 'signal_processor.dart';
import '../utils/audio_utils.dart';
import '../music_feature_analyzer_base.dart';

/// Data model for passing feature extraction data to isolates
/// This allows us to pre-load assets in the main thread and pass them to isolates
class IsolateFeatureData {
  final Song song;
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

/// Main feature extractor service
class FeatureExtractor {
  static final Logger _logger = Logger();
  
  Interpreter? _yamnetModel;
  List<String> _yamnetLabels = [];
  bool _isInitialized = false;
  
  // Statistics
  int _totalSongs = 0;
  int _successfulAnalyses = 0;
  int _failedAnalyses = 0;
  double _totalProcessingTime = 0.0;
  final Map<String, int> _genreDistribution = {};
  final Map<String, int> _instrumentDistribution = {};

  /// Initialize the feature extractor
  Future<bool> initialize() async {
    try {
      _logger.i('🎵 Initializing Feature Extractor...');
      
      // Load YAMNet model
      await _loadYAMNetModel();
      
      // Load YAMNet labels
      await _loadYAMNetLabels();
      
      _isInitialized = true;
      _logger.i('✅ Feature Extractor initialized successfully');
      return true;
    } catch (e) {
      _logger.e('❌ Error initializing Feature Extractor: $e');
      return false;
    }
  }

  /// Extract features for a single song
  Future<SongFeatures?> extractSongFeatures(Song song) async {
    if (!_isInitialized) {
      _logger.e('❌ Feature Extractor not initialized');
      return null;
    }

    final stopwatch = Stopwatch()..start();
    _totalSongs++;

    try {
      _logger.i('🎵 Extracting features for: ${song.title}');
      
      // Extract audio data
      final audioData = await _extractAudioData(song.filePath);
      if (audioData == null) {
        _logger.e('❌ Failed to extract audio data for: ${song.title}');
        _failedAnalyses++;
        return null;
      }

      // Run YAMNet analysis
      final yamnetResults = await _runYAMNetAnalysis(audioData);
      
      // Run signal processing
      final signalResults = await _runSignalProcessing(audioData);
      
      // Combine results
      final features = _combineResults(yamnetResults, signalResults, song);
      
      _successfulAnalyses++;
      _updateStatistics(features);
      
      stopwatch.stop();
      _totalProcessingTime += stopwatch.elapsedMilliseconds / 1000.0;
      
      _logger.i('✅ Features extracted for: ${song.title} (${stopwatch.elapsedMilliseconds}ms)');
      return features;
      
    } catch (e) {
      _logger.e('❌ Error extracting features for ${song.title}: $e');
      _failedAnalyses++;
      return null;
    }
  }

  /// Load YAMNet model
  Future<void> _loadYAMNetModel() async {
    try {
      _logger.i('📱 Loading YAMNet model...');
      
      // Load model from assets
      final modelBytes = await rootBundle.load('assets/models/yamnet.tflite');
      final modelBuffer = modelBytes.buffer.asUint8List();
      
      // Create interpreter
      _yamnetModel = Interpreter.fromBuffer(modelBuffer);
      
      _logger.i('✅ YAMNet model loaded successfully');
    } catch (e) {
      _logger.e('❌ Error loading YAMNet model: $e');
      rethrow;
    }
  }

  /// Load YAMNet labels
  Future<void> _loadYAMNetLabels() async {
    try {
      _logger.i('📋 Loading YAMNet labels...');
      
      final labelsData = await rootBundle.loadString('assets/models/yamnet_class_map.csv');
      _yamnetLabels = labelsData.split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) => line.split(',').last.trim())
          .toList();
      
      _logger.i('✅ YAMNet labels loaded: ${_yamnetLabels.length} labels');
    } catch (e) {
      _logger.e('❌ Error loading YAMNet labels: $e');
      rethrow;
    }
  }

  /// Extract audio data from file
  Future<Float32List?> _extractAudioData(String filePath) async {
    try {
      _logger.d('🎵 Extracting audio data from: $filePath');
      
      // Use FFmpeg to extract audio data
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_audio.wav');
      
      // Convert to WAV format with specific parameters
      final session = await FFmpegKit.execute(
        '-i "$filePath" -ar 16000 -ac 1 -f wav "${tempFile.path}"'
      );
      
      if (ReturnCode.isSuccess(await session.getReturnCode())) {
        // Read audio data
        final audioBytes = await tempFile.readAsBytes();
        final audioData = AudioUtils.convertBytesToFloat32List(audioBytes);
        
        // Clean up temp file
        await tempFile.delete();
        
        _logger.d('✅ Audio data extracted: ${audioData.length} samples');
        return audioData;
      } else {
        _logger.e('❌ FFmpeg conversion failed');
        return null;
      }
    } catch (e) {
      _logger.e('❌ Error extracting audio data: $e');
      return null;
    }
  }

  /// Run YAMNet analysis
  YAMNetResults _runYAMNetAnalysis(Float32List audioData) {
    try {
      _logger.d('🤖 Running YAMNet analysis...');
      
      // Prepare input data (1 second window)
      final windowSize = 16000; // 1 second at 16kHz
      final inputData = audioData.take(windowSize).toList();
      
      // Pad or truncate to exact size
      final paddedData = List<double>.filled(windowSize, 0.0);
      for (int i = 0; i < math.min(inputData.length, windowSize); i++) {
        paddedData[i] = inputData[i];
      }
      
      // Prepare input tensor
      final input = [paddedData];
      final output = List.filled(1, List.filled(_yamnetLabels.length, 0.0));
      
      // Run inference
      _yamnetModel?.run(input, output);
      
      // Process results
      final results = YAMNetHelper.processOutput(output[0], _yamnetLabels);
      
      _logger.d('✅ YAMNet analysis completed');
      return results;
    } catch (e) {
      _logger.e('❌ Error in YAMNet analysis: $e');
      return YAMNetResults.empty();
    }
  }

  /// Run signal processing analysis
  Future<SignalProcessingResults> _runSignalProcessing(Float32List audioData) async {
    try {
      _logger.d('🔬 Running signal processing analysis...');
      
      final processor = SignalProcessor();
      final results = await processor.analyze(audioData);
      
      _logger.d('✅ Signal processing completed');
      return results;
    } catch (e) {
      _logger.e('❌ Error in signal processing: $e');
      return SignalProcessingResults.empty();
    }
  }

  /// Combine YAMNet and signal processing results
  SongFeatures _combineResults(
    YAMNetResults yamnetResults,
    SignalProcessingResults signalResults,
    Song song,
  ) {
    return SongFeatures(
      // Basic categorical features
      tempo: _categorizeTempo(signalResults.tempoBpm),
      beat: _categorizeBeat(signalResults.beatStrength),
      energy: _categorizeEnergy(signalResults.overallEnergy),
      instruments: yamnetResults.instruments,
      vocals: yamnetResults.hasVocals ? _categorizeVocals(yamnetResults.vocalIntensity) : null,
      mood: _categorizeMood(yamnetResults.moodScore),
      
      // YAMNet results
      yamnetInstruments: yamnetResults.instruments,
      hasVocals: yamnetResults.hasVocals,
      estimatedGenre: yamnetResults.genre,
      yamnetEnergy: yamnetResults.energy,
      moodTags: yamnetResults.moodTags,
      
      // Signal processing results
      tempoBpm: signalResults.tempoBpm,
      beatStrength: signalResults.beatStrength,
      signalEnergy: signalResults.overallEnergy,
      brightness: signalResults.brightness,
      danceability: signalResults.danceability,
      
      // Spectral features
      spectralCentroid: signalResults.spectralCentroid,
      spectralRolloff: signalResults.spectralRolloff,
      zeroCrossingRate: signalResults.zeroCrossingRate,
      spectralFlux: signalResults.spectralFlux,
      
      // Combined metrics
      overallEnergy: (yamnetResults.energy + signalResults.overallEnergy) / 2.0,
      intensity: signalResults.overallEnergy, // Overall intensity
      complexity: _calculateComplexity(signalResults),
      valence: _calculateValence(yamnetResults, signalResults),
      arousal: _calculateArousal(yamnetResults, signalResults),
      
      // Metadata
      analyzedAt: DateTime.now(),
      analyzerVersion: '1.0.0',
      confidence: _calculateConfidence(yamnetResults, signalResults),
    );
  }

  /// Categorize tempo
  String _categorizeTempo(double bpm) {
    if (bpm < 60) return 'Very Slow';
    if (bpm < 80) return 'Slow';
    if (bpm < 120) return 'Moderate';
    if (bpm < 140) return 'Fast';
    return 'Very Fast';
  }

  /// Categorize beat strength
  String _categorizeBeat(double strength) {
    if (strength < 0.3) return 'Soft';
    if (strength < 0.7) return 'Medium';
    return 'Strong';
  }

  /// Categorize energy
  String _categorizeEnergy(double energy) {
    if (energy < 0.3) return 'Low';
    if (energy < 0.7) return 'Medium';
    return 'High';
  }

  /// Categorize vocals
  String _categorizeVocals(double intensity) {
    if (intensity < 0.3) return 'Soft';
    if (intensity < 0.7) return 'Medium';
    return 'Strong';
  }

  /// Categorize mood
  String _categorizeMood(double moodScore) {
    if (moodScore < 0.2) return 'Sad';
    if (moodScore < 0.4) return 'Melancholy';
    if (moodScore < 0.6) return 'Neutral';
    if (moodScore < 0.8) return 'Happy';
    return 'Very Happy';
  }

  /// Calculate complexity
  double _calculateComplexity(SignalProcessingResults results) {
    // Combine spectral features to estimate complexity
    final spectralComplexity = (results.spectralCentroid / 8000.0) + 
                              (results.spectralRolloff / 8000.0) + 
                              results.zeroCrossingRate;
    return math.min(1.0, spectralComplexity / 3.0);
  }

  /// Calculate valence (emotional positivity)
  double _calculateValence(YAMNetResults yamnet, SignalProcessingResults signal) {
    // Combine mood and energy for valence
    return (yamnet.moodScore + (signal.overallEnergy * 0.5)) / 1.5;
  }

  /// Calculate arousal (emotional intensity)
  double _calculateArousal(YAMNetResults yamnet, SignalProcessingResults signal) {
    // Combine energy and tempo for arousal
    return (yamnet.energy + (signal.tempoBpm / 200.0) + signal.overallEnergy) / 3.0;
  }

  /// Calculate overall confidence
  double _calculateConfidence(YAMNetResults yamnet, SignalProcessingResults signal) {
    return (yamnet.confidence + signal.confidence) / 2.0;
  }

  /// Update statistics
  void _updateStatistics(SongFeatures features) {
    // Update genre distribution
    _genreDistribution[features.estimatedGenre] = 
        (_genreDistribution[features.estimatedGenre] ?? 0) + 1;
    
    // Update instrument distribution
    for (final instrument in features.instruments) {
      _instrumentDistribution[instrument] = 
          (_instrumentDistribution[instrument] ?? 0) + 1;
    }
  }

  /// Get analysis statistics
  AnalysisStats getStats() {
    return AnalysisStats(
      totalSongs: _totalSongs,
      successfulAnalyses: _successfulAnalyses,
      failedAnalyses: _failedAnalyses,
      averageProcessingTime: _totalSongs > 0 ? _totalProcessingTime / _totalSongs : 0.0,
      genreDistribution: Map.from(_genreDistribution),
      instrumentDistribution: Map.from(_instrumentDistribution),
    );
  }


  /// Extract features from multiple songs (batch processing)
  Future<List<SongFeatures>> extractMultipleSongs(List<Song> songs) async {
    final results = <SongFeatures>[];
    
    for (final song in songs) {
      try {
        final features = await extractSongFeatures(song);
        if (features != null) {
          results.add(features);
        }
      } catch (e) {
        _logger.e('❌ Error processing song ${song.title}: $e');
      }
    }
    
    return results;
  }

  /// Get extraction statistics
  AnalysisStats getStatistics() {
    return AnalysisStats(
      totalSongs: _totalSongs,
      successfulAnalyses: _successfulAnalyses,
      failedAnalyses: _failedAnalyses,
      averageProcessingTime: _totalSongs > 0 ? _totalProcessingTime / _totalSongs : 0.0,
      genreDistribution: Map.from(_genreDistribution),
      instrumentDistribution: Map.from(_instrumentDistribution),
    );
  }

  /// Reset statistics
  void resetStats() {
    _totalSongs = 0;
    _successfulAnalyses = 0;
    _failedAnalyses = 0;
    _totalProcessingTime = 0.0;
    _genreDistribution.clear();
    _instrumentDistribution.clear();
  }

  /// Dispose resources
  Future<void> dispose() async {
    _yamnetModel?.close();
    _yamnetModel = null;
    _isInitialized = false;
    _logger.i('🧹 Feature Extractor disposed');
  }
}


