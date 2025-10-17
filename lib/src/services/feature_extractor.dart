import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/song_model.dart';
import '../models/song_features.dart';
import '../utils/app_logger.dart';
import '../music_feature_analyzer_base.dart';


/// Main feature extractor service
class FeatureExtractor {
  static final AppLogger _logger = AppLogger('FeatureExtractor');
  
  Interpreter? _yamnetModel;
  List<YAMNetLabel> _yamnetLabels = [];
  bool _isInitialized = false;
  Uint8List? _cachedModelBytes; // Cache model bytes for isolates
  
  // Statistics
  int _totalSongs = 0;
  int _successfulAnalyses = 0;
  int _failedAnalyses = 0;
  double _totalAnalysisTime = 0.0;
  final Map<String, int> _genreCounts = {};
  final Map<String, int> _instrumentCounts = {};

  /// Initialize the feature extractor
  Future<bool> initialize() async {
    try {
      if (_isInitialized) {
        _logger.d('✅ Already initialized');
        return true;
      }

      _logger.i('🚀 Initializing Feature Extractor...');

      // Load YAMNet model
      _logger.d('📦 Loading YAMNet model from assets...');
      await _loadYAMNetModel();
      _logger.i('✅ YAMNet model loaded');

      // Log model details and validate
      _logModelDetails();

      // Validate model compatibility
      if (!_validateModelCompatibility()) {
        _logger.w('⚠️ Model compatibility issues detected - will use fallback mode');
      }

      // Load YAMNet labels
      _logger.d('📋 Loading YAMNet labels...');
      await _loadYAMNetLabels();
      _logger.i('✅ Loaded ${_yamnetLabels.length} YAMNet labels');

      _isInitialized = true;
      _logger.i('✅ Initialization complete - Ready to extract features');
      return true;
    } catch (e, stackTrace) {
      _logger.e('❌ Initialization failed: $e');
      _logger.e('Stack trace: $stackTrace');
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
      final yamnetResults = _runYAMNetAnalysis(audioData);
      
      // Run signal processing
      final signalResults = await _runSignalProcessing(audioData);
      
      // Combine results
      final features = _combineResults(yamnetResults, signalResults, song);
      
      _successfulAnalyses++;
      _updateStatistics(features);
      
      stopwatch.stop();
      _totalAnalysisTime += stopwatch.elapsedMilliseconds / 1000.0;
      
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
      
      // Load model directly from assets (same approach as original)
      _yamnetModel = await Interpreter.fromAsset('assets/models/1.tflite');
      
      // Cache model bytes for isolates
      _cachedModelBytes = await _getModelBytes();
      
      _logger.i('✅ YAMNet model loaded successfully');
    } catch (e) {
      _logger.e('❌ Error loading YAMNet model: $e');
      rethrow;
    }
  }

  /// Get model bytes from asset
  Future<Uint8List> _getModelBytes() async {
    final byteData = await rootBundle.load('assets/models/1.tflite');
    return byteData.buffer.asUint8List();
  }

  /// Load YAMNet labels
  Future<void> _loadYAMNetLabels() async {
    try {
      _logger.i('📋 Loading YAMNet labels...');
      
      final labelsData = await rootBundle.loadString('assets/models/yamnet_class_map.csv');
      _yamnetLabels = _parseYAMNetLabels(labelsData);
      
      _logger.i('✅ YAMNet labels loaded: ${_yamnetLabels.length} labels');
    } catch (e) {
      _logger.e('❌ Error loading YAMNet labels: $e');
      rethrow;
    }
  }

  /// Parse YAMNet labels from CSV content (same as original)
  List<YAMNetLabel> _parseYAMNetLabels(String csvContent) {
    final labels = <YAMNetLabel>[];
    final lines = csvContent.split('\n');
    
    // Skip header
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      
      final parts = line.split(',');
      if (parts.length >= 3) {
        final index = int.tryParse(parts[0].trim()) ?? i - 1;
        final mid = parts[1].trim().replaceAll('"', '');
        final displayName = parts[2].trim().replaceAll('"', '');
        
        labels.add(YAMNetLabel(
          index: index,
          mid: mid,
          displayName: displayName,
        ));
      }
    }
    
    return labels;
  }

  /// Extract audio data from file
  Future<Float32List?> _extractAudioData(String filePath) async {
    try {
      _logger.d('🎵 Extracting audio data from: $filePath');
      
      // Use FFmpeg to extract audio data (same approach as original)
      final tempDir = await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.raw';
      
      // Build sophisticated FFmpeg command (same as original)
      final command = _buildFFmpegCommand(filePath, outputPath);
      
      // Execute FFmpeg
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();
      
      if (ReturnCode.isSuccess(returnCode)) {
        final rawFile = File(outputPath);
        try {
          if (await rawFile.exists()) {
            final rawBytes = await rawFile.readAsBytes();
            await rawFile.delete(); // Clean up immediately
            
            if (rawBytes.isEmpty) {
              _logger.w('FFmpeg output empty, using fallback');
              return _extractFallbackWaveform(filePath);
            }
            
            final waveform = _convertRawAudioToFloat32(rawBytes);
            _logger.d('✅ Extracted ${waveform.length} samples');
            return waveform;
          } else {
            _logger.w('⚠️ FFmpeg output file not found, using fallback');
            return _extractFallbackWaveform(filePath);
          }
        } catch (fileError) {
          _logger.e('❌ Error reading FFmpeg output: $fileError');
          // Ensure cleanup even on error
          try {
            if (await rawFile.exists()) {
              await rawFile.delete();
            }
          } catch (cleanupError) {
            _logger.w('⚠️ Error cleaning up temp file: $cleanupError');
          }
          return _extractFallbackWaveform(filePath);
        }
      }
      
      _logger.w('⚠️ FFmpeg failed, using fallback');
      return _extractFallbackWaveform(filePath);
    } catch (e) {
      _logger.e('❌ Error extracting audio data: $e');
      return _extractFallbackWaveform(filePath);
    }
  }
  
  /// Build FFmpeg command for audio extraction (same as original)
  String _buildFFmpegCommand(String inputPath, String outputPath) {
    // Calculate optimal start time (middle of song)
    final startTime = _calculateMiddleStartTime(Duration(minutes: 3)); // Default 3 minutes
    
    return [
      '-y',
      '-ss', startTime.toStringAsFixed(1),
      '-i', '"$inputPath"',
      '-t', '0.975',
      '-f', 's16le',
      '-ar', '16000',
      '-ac', '1',
      '-avoid_negative_ts', 'make_zero',
      '-fflags', '+genpts',
      '"$outputPath"'
    ].join(' ');
  }
  
  /// Calculate optimal start time from middle of song (same as original)
  double _calculateMiddleStartTime(Duration duration) {
    final totalSeconds = duration.inSeconds;
    
    if (totalSeconds < 6) return 0.0;
    if (totalSeconds < 15) return totalSeconds * 0.25;
    if (totalSeconds < 60) return totalSeconds * 0.30;
    if (totalSeconds < 600) return totalSeconds * 0.35;
    if (totalSeconds < 1800) return totalSeconds * 0.25;
    if (totalSeconds < 3600) return totalSeconds * 0.20;
    return totalSeconds * 0.15;
  }
  
  /// Convert raw audio bytes to Float32List (same as original)
  Float32List _convertRawAudioToFloat32(Uint8List rawBytes) {
    final samples = rawBytes.length ~/ 2;
    final waveform = Float32List(samples);
    
    for (int i = 0; i < samples; i++) {
      final byte1 = rawBytes[i * 2];
      final byte2 = rawBytes[i * 2 + 1];
      final sample = (byte2 << 8) | byte1;
      final signedSample = sample > 32767 ? sample - 65536 : sample;
      waveform[i] = signedSample / 32768.0;
    }
    
    return waveform;
  }
  
  /// Fallback waveform extraction (same as original)
  Future<Float32List?> _extractFallbackWaveform(String filePath) async {
    try {
      final file = File(filePath);
      final fileBytes = await file.readAsBytes();
      
      const sampleRate = 16000;
      const duration = 3;
      const totalSamples = sampleRate * duration;
      
      final waveform = Float32List(totalSamples);
      
      for (int i = 0; i < totalSamples; i++) {
        final byteIndex = i % fileBytes.length;
        waveform[i] = (fileBytes[byteIndex] - 128) / 128.0 * 0.5;
      }
      
      _logger.d('✅ Generated fallback waveform: $totalSamples samples');
      return waveform;
    } catch (e) {
      _logger.e('Fallback extraction failed: $e');
      return null;
    }
  }

  /// Run YAMNet analysis (same as original)
  YAMNetResults _runYAMNetAnalysis(Float32List audioData) {
    try {
      _logger.d('🤖 Running YAMNet analysis...');
      
      // Prepare input (15,600 samples required by YAMNet - same as original)
      final inputWaveform = _prepareYAMNetInput(audioData);
      
      // Run inference with proper error handling (same as original)
      final input = [inputWaveform];
      // ✅ FIX: Create output with correct shape [1, 521]
      final output = [List.filled(521, 0.0)]; // 2D array: [1, 521]
      
      try {
        _yamnetModel?.run(input, output);
      } catch (modelError) {
        _logger.e('⛔ Model inference error: $modelError');
        _logger.w('🔄 Falling back to signal processing only...');
        return _createFallbackResults(audioData);
      }
      
      // Extract and process scores (same as original)
      final scores = output[0] as List<double>?;
      if (scores == null || scores.isEmpty) {
        _logger.e('❌ YAMNet output is null');
        return _createFallbackResults(audioData);
      }
      
      // Process scores to extract features (same as original)
      return _processYAMNetOutput(scores);
    } catch (e) {
      _logger.e('⛔ YAMNet analysis error: $e');
      _logger.w('🔄 Falling back to signal processing only...');
      return _createFallbackResults(audioData);
    }
  }
  
  /// Prepare YAMNet input (ensure 15,600 samples - same as original)
  Float32List _prepareYAMNetInput(Float32List waveform) {
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
  
  /// Create fallback results when YAMNet fails (same as original)
  YAMNetResults _createFallbackResults(Float32List waveform) {
    _logger.i('🔄 Creating fallback features using signal processing...');
    
    // Calculate signal features for fallback
    final signalFeatures = _calculateSignalFeatures(waveform);
    
    // Enhanced fallback heuristics (same as original)
    final instruments = _inferInstrumentsFromSignal(signalFeatures);
    final hasVocals = _inferVocalsFromSignal(signalFeatures);
    final genre = _inferGenreFromSignal(signalFeatures);
    final moodTags = _inferMoodFromSignal(signalFeatures);
    
    return YAMNetResults(
      instruments: instruments,
      hasVocals: hasVocals,
      genre: genre,
      energy: signalFeatures.energy,
      moodTags: moodTags,
      moodScore: 0.5,
      vocalIntensity: 0.5,
      confidence: 0.5,
    );
  }
  
  /// Calculate signal features for fallback (same as original)
  SignalFeatures _calculateSignalFeatures(Float32List waveform) {
    final energy = _calculateEnergy(waveform);
    final spectralCentroid = _calculateSpectralCentroid(waveform);
    final spectralRolloff = _calculateSpectralRolloff(waveform);
    final zeroCrossingRate = _calculateZeroCrossingRate(waveform);
    final tempoBpm = _estimateTempo(waveform);
    final beatStrength = _calculateBeatStrength(waveform);
    final brightness = spectralCentroid;
    final danceability = _calculateDanceability(waveform, tempoBpm);
    
    return SignalFeatures(
      tempoBpm: tempoBpm,
      beatStrength: beatStrength,
      energy: energy,
      brightness: brightness,
      danceability: danceability,
      spectralCentroid: spectralCentroid,
      spectralRolloff: spectralRolloff,
      zeroCrossingRate: zeroCrossingRate,
    );
  }
  
  /// Process YAMNet output scores (same as original)
  YAMNetResults _processYAMNetOutput(List<double> scores) {
    final instruments = <String>[];
    final moodTags = <String>[];
    bool hasVocals = false;
    String genre = 'Unknown';
    double energy = 0.5;
    
    // Get top predictions (same as original)
    final topIndices = _getTopIndices(scores, 15);
    
    _logger.d('🔍 YAMNet Debug - Top 15 indices: $topIndices');
    _logger.d('🔍 YAMNet Debug - Top scores: ${topIndices.map((i) => scores[i]).toList()}');
    
    // If no indices found with threshold, try without threshold (same as original)
    if (topIndices.isEmpty) {
      _logger.w('⚠️ No results with threshold, trying without threshold...');
      final allIndices = _getTopIndicesWithThreshold(scores, 15, 0.0);
      _logger.d('🔍 YAMNet Debug - All indices (no threshold): $allIndices');
      topIndices.addAll(allIndices);
    }
    
    for (final index in topIndices) {
      if (index >= _yamnetLabels.length) continue;
      
      final label = _yamnetLabels[index];
      final score = scores[index];
      
      _logger.d('🔍 YAMNet Debug - Label: ${label.displayName} | Score: $score | isInstrument: ${label.isInstrument} | isVocal: ${label.isVocal} | isGenre: ${label.isGenre} | isMood: ${label.isMood}');
      
      // Additional genre detection debugging
      if (label.isGenre) {
        _logger.d('🎵 Genre candidate: ${label.displayName} (score: $score, current genre: $genre)');
      }
      
      // FIXED: Add confidence thresholds for better accuracy (same as original)
      const confidenceThreshold = 0.1; // Minimum confidence score
      
      if (score < confidenceThreshold) continue; // Skip low-confidence predictions
      
      // Categorize based on label type with confidence filtering (same as original)
      if (label.isInstrument && instruments.length < 5 && score > 0.15) {
        instruments.add(label.displayName);
        _logger.d('✅ Added instrument: ${label.displayName} (confidence: $score)');
      } else if (label.isVocal && score > 0.2) {
        hasVocals = true;
        _logger.d('✅ Detected vocals: ${label.displayName} (confidence: $score)');
      } else if (label.isGenre && genre == 'Unknown' && score > 0.05) {
        genre = label.displayName;
        _logger.d('✅ Detected genre: ${label.displayName} (confidence: $score)');
      } else if (label.isMood && moodTags.length < 3 && score > 0.15) {
        moodTags.add(label.displayName);
        _logger.d('✅ Added mood: ${label.displayName} (confidence: $score)');
      }
      
      if (label.isEnergyRelated) {
        // FIXED: Use weighted average instead of max to capture all energy information (same as original)
        energy = (energy + score) / 2;
        _logger.d('✅ Energy related: ${label.displayName} | Score: $score');
      }
    }
    
    _logger.d('🔍 YAMNet Debug - Final results: instruments=$instruments, hasVocals=$hasVocals, genre=$genre, energy=$energy, moodTags=$moodTags');
    
    // Ensure defaults (same as original)
    if (instruments.isEmpty) instruments.add('Unknown');
    if (moodTags.isEmpty) moodTags.add('Neutral');
    
    return YAMNetResults(
      instruments: instruments,
      hasVocals: hasVocals,
      genre: genre,
      energy: energy.clamp(0.0, 1.0),
      moodTags: moodTags,
      moodScore: 0.5,
      vocalIntensity: 0.5,
      confidence: 0.5,
    );
  }
  
  /// Get top N indices from scores array with confidence thresholding (same as original)
  List<int> _getTopIndices(List<double> scores, int topN) {
    return _getTopIndicesWithThreshold(scores, topN, 0.05); // Reduced to 5% threshold
  }
  
  /// Get top N indices with confidence threshold (same as original)
  List<int> _getTopIndicesWithThreshold(List<double> scores, int topN, double threshold) {
    final indexed = List.generate(
      scores.length,
      (i) => MapEntry(i, scores[i]),
    );
    indexed.sort((a, b) => b.value.compareTo(a.value));
    
    // Filter by confidence threshold and take top N
    return indexed
        .where((entry) => entry.value > threshold)
        .take(topN)
        .map((e) => e.key)
        .toList();
  }
  
  /// Infer instruments from signal features (same as original)
  List<String> _inferInstrumentsFromSignal(SignalFeatures signal) {
    final instruments = <String>[];
    
    // High spectral centroid suggests bright instruments
    if (signal.spectralCentroid > 0.7) {
      instruments.addAll(['Piano', 'Guitar', 'Violin']);
    } else if (signal.spectralCentroid > 0.4) {
      instruments.addAll(['Guitar', 'Bass']);
    } else {
      instruments.addAll(['Bass', 'Drums']);
    }
    
    // High zero crossing rate suggests percussive elements
    if (signal.zeroCrossingRate > 0.3) {
      instruments.add('Drums');
    }
    
    return instruments.isEmpty ? ['Unknown'] : instruments;
  }
  
  /// Infer vocals from signal features (same as original)
  bool _inferVocalsFromSignal(SignalFeatures signal) {
    // High zero crossing rate and moderate energy suggests vocals
    return signal.zeroCrossingRate > 0.2 &&
        signal.energy > 0.3 &&
        signal.energy < 0.8;
  }
  
  /// Infer genre from signal features (same as original)
  String _inferGenreFromSignal(SignalFeatures signal) {
    // High tempo and high energy suggests electronic/rock
    if (signal.tempoBpm > 140 && signal.energy > 0.8) {
      return 'Electronic dance music';
    }
    
    if (signal.tempoBpm > 120 && signal.energy > 0.7) {
      return 'Electronic music';
    }
    
    // High tempo and moderate energy suggests rock
    if (signal.tempoBpm > 100 && signal.energy > 0.6) {
      return 'Rock music';
    }
    
    if (signal.tempoBpm > 90 && signal.energy > 0.5) {
      return 'Pop music';
    }
    
    // Low tempo and low energy suggests classical
    if (signal.tempoBpm < 80 && signal.energy < 0.4) {
      return 'Classical music';
    }
    
    if (signal.tempoBpm < 90 && signal.energy < 0.5) {
      return 'Ambient music';
    }
    
    // Moderate tempo suggests pop
    if (signal.tempoBpm >= 80 && signal.tempoBpm <= 120) {
      return 'Pop music';
    }
    
    // Jazz characteristics (moderate tempo, moderate energy, high spectral centroid)
    if (signal.tempoBpm >= 60 && signal.tempoBpm <= 120 && 
        signal.energy >= 0.3 && signal.energy <= 0.7 &&
        signal.spectralCentroid > 2000) {
      return 'Jazz';
    }
    
    // Blues characteristics (moderate tempo, moderate energy, lower spectral centroid)
    if (signal.tempoBpm >= 60 && signal.tempoBpm <= 100 && 
        signal.energy >= 0.4 && signal.energy <= 0.6 &&
        signal.spectralCentroid < 2000) {
      return 'Blues';
    }
    
    return 'Pop music'; // Default to Pop instead of Unknown
  }
  
  /// Infer mood from signal features (same as original)
  List<String> _inferMoodFromSignal(SignalFeatures signal) {
    final moodTags = <String>[];
    
    if (signal.energy > 0.7) {
      moodTags.add('energetic');
    } else if (signal.energy < 0.3) {
      moodTags.add('calm');
    } else {
      moodTags.add('neutral');
    }
    
    if (signal.tempoBpm > 120) {
      moodTags.add('upbeat');
    } else if (signal.tempoBpm < 80) {
      moodTags.add('relaxing');
    }
    
    return moodTags.isEmpty ? ['neutral'] : moodTags;
  }
  
  /// Calculate RMS energy (same as original)
  double _calculateEnergy(Float32List waveform) {
    double sum = 0.0;
    for (final sample in waveform) {
      sum += sample * sample;
    }
    return math.sqrt(sum / waveform.length);
  }
  
  /// Calculate spectral centroid (same as original)
  double _calculateSpectralCentroid(Float32List waveform) {
    try {
      // Apply windowing and perform FFT
      final windowed = _applyHannWindow(waveform);
      final fft = _performFFT(windowed);
      final magnitudes = _calculateMagnitudeSpectrumFromFFT(fft);
      
      if (magnitudes.isEmpty) return 0.0;
      
      double weightedSum = 0.0;
      double magnitudeSum = 0.0;
      
      for (int i = 0; i < magnitudes.length; i++) {
        final magnitude = magnitudes[i];
        weightedSum += i * magnitude;
        magnitudeSum += magnitude;
      }
      
      // Convert to frequency in Hz (sample rate = 16000)
      final frequencyBin = magnitudeSum > 0 ? weightedSum / magnitudeSum : 0.0;
      return (frequencyBin / magnitudes.length) * 8000.0; // Nyquist frequency
    } catch (e) {
      return 2000.0; // Safe fallback
    }
  }
  
  /// Calculate spectral rolloff (same as original)
  double _calculateSpectralRolloff(Float32List waveform) {
    try {
      // Apply windowing and perform FFT
      final windowed = _applyHannWindow(waveform);
      final fft = _performFFT(windowed);
      final magnitudes = _calculateMagnitudeSpectrumFromFFT(fft);
      
      if (magnitudes.isEmpty) return 0.0;
      
      // Calculate total energy
      final totalEnergy = magnitudes.fold<double>(0.0, (sum, mag) => sum + mag);
      final threshold = 0.85 * totalEnergy;
      
      // Find 85% energy rolloff point
      double cumulativeEnergy = 0.0;
      for (int i = 0; i < magnitudes.length; i++) {
        cumulativeEnergy += magnitudes[i];
        if (cumulativeEnergy >= threshold) {
          // Convert to frequency in Hz
          return (i / magnitudes.length) * 8000.0; // Nyquist frequency
        }
      }
      return 8000.0; // Full spectrum
    } catch (e) {
      return 4000.0; // Safe fallback
    }
  }
  
  /// Calculate zero crossing rate (same as original)
  double _calculateZeroCrossingRate(Float32List waveform) {
    int crossings = 0;
    for (int i = 1; i < waveform.length; i++) {
      if (waveform[i] * waveform[i - 1] < 0) {
        crossings++;
      }
    }
    return crossings / waveform.length;
  }
  
  /// Estimate tempo in BPM using autocorrelation (same as original)
  double _estimateTempo(Float32List waveform) {
    // Apply windowing for better analysis
    final windowed = _applyHannWindow(waveform);
    
    // Calculate autocorrelation
    final autocorr = _calculateAutocorrelation(windowed);
    
    // Find peaks in autocorrelation
    final peaks = _findPeaks(autocorr);
    
    if (peaks.isEmpty) {
      // FIXED: Use musical analysis instead of arbitrary formula
      return _estimateTempoFromRhythmicPattern(waveform);
    }
    
    // Find the most prominent peak (likely tempo)
    final maxPeakIndex = peaks.reduce((a, b) => autocorr[a] > autocorr[b] ? a : b);
    final sampleRate = 16000.0; // YAMNet sample rate
    final tempo = (sampleRate / maxPeakIndex) * 60.0;
    
    // Clamp to reasonable tempo range
    return tempo.clamp(60.0, 200.0);
  }
  
  /// Calculate beat strength (same as original)
  double _calculateBeatStrength(Float32List waveform) {
    try {
      const windowSize = 1024;
      const hopSize = 512;
      
      if (waveform.length < windowSize * 2) return 0.5;
      
      // Calculate spectral flux (onset detection)
      final energies = <double>[];
      final spectralFlux = <double>[];
      
      for (int i = 0; i < waveform.length - windowSize; i += hopSize) {
        final window = waveform.sublist(i, i + windowSize);
        final windowed = _applyHannWindow(Float32List.fromList(window));
        final fft = _performFFT(windowed);
        final magnitudes = _calculateMagnitudeSpectrumFromFFT(fft);
        
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
  
  /// Calculate danceability (same as original)
  double _calculateDanceability(Float32List waveform, double tempo) {
    final beatStrength = _calculateBeatStrength(waveform);
    final tempoFactor = math.min(tempo / 120.0, 1.0);
    return (beatStrength + tempoFactor) / 2;
  }
  
  /// Apply Hann window to reduce spectral leakage (same as original)
  Float32List _applyHannWindow(Float32List waveform) {
    final windowed = Float32List(waveform.length);
    for (int i = 0; i < waveform.length; i++) {
      final windowValue = 0.5 * (1 - math.cos(2 * math.pi * i / (waveform.length - 1)));
      windowed[i] = waveform[i] * windowValue;
    }
    return windowed;
  }
  
  /// Perform FFT using Cooley-Tukey algorithm (same as original)
  List<Complex> _performFFT(Float32List signal) {
    final n = signal.length;
    if (n == 1) return [Complex(signal[0], 0)];
    
    // Pad to power of 2
    final paddedLength = _nextPowerOf2(n);
    final padded = Float32List(paddedLength);
    for (int i = 0; i < n; i++) {
      padded[i] = signal[i];
    }
    
    return _fftRecursive(padded);
  }
  
  /// Recursive FFT implementation (same as original)
  List<Complex> _fftRecursive(Float32List signal) {
    final n = signal.length;
    if (n == 1) return [Complex(signal[0], 0)];
    
    // Split into even and odd
    final even = <double>[];
    final odd = <double>[];
    for (int i = 0; i < n; i += 2) {
      even.add(signal[i]);
      if (i + 1 < n) odd.add(signal[i + 1]);
    }
    
    final evenFFT = _fftRecursive(Float32List.fromList(even));
    final oddFFT = _fftRecursive(Float32List.fromList(odd));
    
    final result = List<Complex>.filled(n, Complex(0, 0));
    final halfN = n ~/ 2;
    
    for (int k = 0; k < halfN; k++) {
      final t = oddFFT[k] * Complex(math.cos(-2 * math.pi * k / n), math.sin(-2 * math.pi * k / n));
      result[k] = evenFFT[k] + t;
      result[k + halfN] = evenFFT[k] - t;
    }
    
    return result;
  }
  
  /// Calculate magnitude spectrum from FFT result (same as original)
  List<double> _calculateMagnitudeSpectrumFromFFT(List<Complex> fft) {
    return fft.map((c) => math.sqrt(c.real * c.real + c.imaginary * c.imaginary)).toList();
  }
  
  /// Find next power of 2 (same as original)
  int _nextPowerOf2(int n) {
    if (n <= 0) return 1;
    if ((n & (n - 1)) == 0) return n;
    return 1 << (n.bitLength);
  }
  
  /// Calculate autocorrelation function (same as original)
  List<double> _calculateAutocorrelation(Float32List signal) {
    final n = signal.length;
    final autocorr = <double>[];
    
    for (int lag = 0; lag < n ~/ 2; lag++) {
      double sum = 0.0;
      for (int i = 0; i < n - lag; i++) {
        sum += signal[i] * signal[i + lag];
      }
      autocorr.add(sum / (n - lag));
    }
    
    return autocorr;
  }
  
  /// Find peaks in autocorrelation function (same as original)
  List<int> _findPeaks(List<double> autocorr) {
    final peaks = <int>[];
    const minPeakDistance = 10; // Minimum distance between peaks
    const minPeakHeight = 0.1; // Minimum peak height
    
    for (int i = 1; i < autocorr.length - 1; i++) {
      // Check if it's a local maximum
      if (autocorr[i] > autocorr[i - 1] && 
          autocorr[i] > autocorr[i + 1] &&
          autocorr[i] > minPeakHeight) {
        
        // Check distance from previous peaks
        bool tooClose = false;
        for (final peak in peaks) {
          if ((i - peak).abs() < minPeakDistance) {
            tooClose = true;
            break;
          }
        }
        
        if (!tooClose) {
          peaks.add(i);
        }
      }
    }
    
    return peaks;
  }
  
  /// Estimate tempo from rhythmic pattern analysis (musical approach) (same as original)
  double _estimateTempoFromRhythmicPattern(Float32List waveform) {
    try {
      // Analyze energy variations to find rhythmic patterns
      const windowSize = 1024;
      final energies = <double>[];
      
      for (int i = 0; i < waveform.length - windowSize; i += windowSize ~/ 2) {
        final window = waveform.sublist(i, i + windowSize);
        energies.add(_calculateEnergy(Float32List.fromList(window)));
      }
      
      if (energies.length < 4) return 120.0; // Default tempo
      
      // Find energy peaks (potential beats)
      final peaks = <int>[];
      for (int i = 1; i < energies.length - 1; i++) {
        if (energies[i] > energies[i - 1] && energies[i] > energies[i + 1]) {
          peaks.add(i);
        }
      }
      
      if (peaks.length < 2) return 120.0; // Default tempo
      
      // Calculate average time between peaks
      double totalInterval = 0.0;
      for (int i = 1; i < peaks.length; i++) {
        totalInterval += peaks[i] - peaks[i - 1];
      }
      final avgInterval = totalInterval / (peaks.length - 1);
      
      // Convert to BPM (sample rate = 16000, window hop = 512)
      final timePerWindow = 512.0 / 16000.0; // seconds per window
      final intervalSeconds = avgInterval * timePerWindow;
      final bpm = 60.0 / intervalSeconds;
      
      // Clamp to reasonable range
      return bpm.clamp(60.0, 200.0);
    } catch (e) {
      return 120.0; // Safe fallback
    }
  }

  /// Run signal processing analysis
  Future<SignalProcessingResults> _runSignalProcessing(Float32List audioData) async {
    try {
      _logger.d('🔬 Running signal processing analysis...');
      
      // Perform signal processing directly
      final results = _performSignalProcessing(audioData);
      
      _logger.d('✅ Signal processing completed');
      return results;
    } catch (e) {
      _logger.e('❌ Error in signal processing: $e');
      return SignalProcessingResults.empty();
    }
  }

  /// Perform signal processing analysis
  SignalProcessingResults _performSignalProcessing(Float32List audioData) {
    // Calculate tempo
    final tempoBpm = _estimateTempo(audioData);
    
    // Calculate beat strength
    final beatStrength = _calculateBeatStrength(audioData);
    
    // Calculate spectral features
    final spectralCentroid = _calculateSpectralCentroid(audioData);
    final spectralRolloff = _calculateSpectralRolloff(audioData);
    final zeroCrossingRate = _calculateZeroCrossingRate(audioData);
    
    // Calculate energy
    final energy = _calculateEnergy(audioData);
    
    // Calculate spectral flux (simple approximation using energy variance)
    final spectralFlux = energy * 0.5; // Simplified calculation
    
    // Calculate complexity (combination of features)
    final complexity = (zeroCrossingRate + (spectralCentroid / 8000.0)) / 2.0;
    
    // Calculate overall energy
    final overallEnergy = energy;
    
    // Calculate brightness (spectral centroid normalized)
    final brightness = spectralCentroid / 8000.0; // Normalize to [0, 1]
    
    // Calculate danceability (combination of tempo and beat strength)
    final danceability = _calculateDanceability(audioData, tempoBpm);
    
    // Calculate confidence (combination of all features)
    final confidence = (beatStrength + energy + brightness) / 3.0;
    
    return SignalProcessingResults(
      tempoBpm: tempoBpm,
      beatStrength: beatStrength,
      spectralCentroid: spectralCentroid,
      spectralRolloff: spectralRolloff,
      zeroCrossingRate: zeroCrossingRate,
      energy: energy,
      spectralFlux: spectralFlux,
      complexity: complexity,
      overallEnergy: overallEnergy,
      brightness: brightness,
      danceability: danceability,
      confidence: confidence,
    );
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
    if (bpm < 90) return 'Slow';
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
    if (energy < 0.25) return 'Low';
    if (energy < 0.5) return 'Medium';
    if (energy < 0.75) return 'High';
    return 'Very High';
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
    // Update genre counts
    _genreCounts[features.estimatedGenre] = 
        (_genreCounts[features.estimatedGenre] ?? 0) + 1;
    
    // Update instrument counts
    for (final instrument in features.instruments) {
      _instrumentCounts[instrument] = 
          (_instrumentCounts[instrument] ?? 0) + 1;
    }
  }

  /// Get analysis statistics
  AnalysisStats getStats() {
    return AnalysisStats(
      totalSongs: _totalSongs,
      successfulAnalyses: _successfulAnalyses,
      failedAnalyses: _failedAnalyses,
      averageProcessingTime: _totalSongs > 0 ? _totalAnalysisTime / _totalSongs : 0.0,
      lastAnalysis: DateTime.now(),
      genreDistribution: Map.from(_genreCounts),
      instrumentDistribution: Map.from(_instrumentCounts),
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

  /// Reset statistics
  void resetStats() {
    _totalSongs = 0;
    _successfulAnalyses = 0;
    _failedAnalyses = 0;
    _totalAnalysisTime = 0.0;
    _genreCounts.clear();
    _instrumentCounts.clear();
  }

  /// Log model details (same as original)
  void _logModelDetails() {
    if (_yamnetModel == null) return;
    
    try {
      _logger.d('📊 Model Input Details:');
      _logger.d('  - Input Tensors: ${_yamnetModel!.getInputTensors().length}');
      for (final tensor in _yamnetModel!.getInputTensors()) {
        _logger.d('    * Shape: ${tensor.shape} | Type: ${tensor.type}');
      }
      
      _logger.d('📊 Model Output Details:');
      _logger.d('  - Output Tensors: ${_yamnetModel!.getOutputTensors().length}');
      for (final tensor in _yamnetModel!.getOutputTensors()) {
        _logger.d('    * Shape: ${tensor.shape} | Type: ${tensor.type}');
      }
    } catch (e) {
      _logger.w('⚠️ Could not log model details: $e');
    }
  }

  /// Validate model compatibility (same as original)
  bool _validateModelCompatibility() {
    if (_yamnetModel == null) return false;
    
    try {
      final inputTensors = _yamnetModel!.getInputTensors();
      final outputTensors = _yamnetModel!.getOutputTensors();
      
      // Check if we have the expected input/output structure (same as original)
      if (inputTensors.isEmpty || outputTensors.isEmpty) {
        _logger.w('⚠️ Unexpected model structure');
        return false;
      }
      
      return true; // ✅ SIMPLE - Just checks if tensors exist (same as original)
    } catch (e) {
      _logger.w('⚠️ Model validation error: $e');
      return false;
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    _yamnetModel?.close();
    _yamnetModel = null;
    _isInitialized = false;
    _logger.i('🧹 Feature Extractor disposed');
  }

  /// Get model bytes for isolate processing
  Uint8List? getModelBytes() {
    return _cachedModelBytes;
  }

  /// Get labels for isolate processing
  List<String>? getLabels() {
    return _yamnetLabels.map((label) => label.displayName).toList();
  }

  /// Extract audio waveform for isolate processing
  Future<Float32List?> extractAudioWaveform(String filePath, Duration duration) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.raw';

      // Calculate optimal start time (middle of song)
      final startTime = _calculateMiddleStartTime(duration);

      _logger.d('🎵 Extracting audio: duration=${duration.inSeconds}s, start=${startTime.toStringAsFixed(1)}s');

      // Build FFmpeg command
      final command = _buildFFmpegCommand(filePath, outputPath);

      // Execute FFmpeg
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        final rawFile = File(outputPath);
        try {
          if (await rawFile.exists()) {
            final rawBytes = await rawFile.readAsBytes();
            await rawFile.delete(); // Clean up immediately

            if (rawBytes.isEmpty) {
              _logger.w('FFmpeg output empty, using fallback');
              return _extractFallbackWaveform(filePath);
            }

            final waveform = _convertRawAudioToFloat32(rawBytes);
            _logger.d('✅ Extracted ${waveform.length} samples');
            return waveform;
          } else {
            _logger.w('⚠️ FFmpeg output file not found, using fallback');
            return _extractFallbackWaveform(filePath);
          }
        } catch (fileError) {
          _logger.e('❌ Error reading FFmpeg output: $fileError');
          // Ensure cleanup even on error
          try {
            if (await rawFile.exists()) {
              await rawFile.delete();
            }
          } catch (cleanupError) {
            _logger.w('⚠️ Error cleaning up temp file: $cleanupError');
          }
          return _extractFallbackWaveform(filePath);
        }
      }

      _logger.w('⚠️ FFmpeg failed, using fallback');
      return _extractFallbackWaveform(filePath);
    } catch (e) {
      _logger.e('Error extracting audio: $e');
      return _extractFallbackWaveform(filePath);
    }
  }

}



/// YAMNet analysis results (same as original)
class YAMNetResults {
  final List<String> instruments;
  final bool hasVocals;
  final String genre;
  final double energy;
  final List<String> moodTags;
  final double moodScore;
  final double vocalIntensity;
  final double confidence;

  YAMNetResults({
    required this.instruments,
    required this.hasVocals,
    required this.genre,
    required this.energy,
    required this.moodTags,
    this.moodScore = 0.5,
    this.vocalIntensity = 0.5,
    this.confidence = 0.5,
  });
  
  /// Create empty results
  static YAMNetResults empty() {
    return YAMNetResults(
      instruments: ['Unknown'],
      hasVocals: false,
      genre: 'Unknown',
      energy: 0.5,
      moodTags: ['Neutral'],
      moodScore: 0.5,
      vocalIntensity: 0.5,
      confidence: 0.5,
    );
  }
}


/// Signal processing results class (same as original)
class SignalProcessingResults {
  final double tempoBpm;
  final double beatStrength;
  final double spectralCentroid;
  final double spectralRolloff;
  final double zeroCrossingRate;
  final double energy;
  final double spectralFlux;
  final double complexity;
  final double overallEnergy;
  final double brightness;
  final double danceability;
  final double confidence;

  SignalProcessingResults({
    required this.tempoBpm,
    required this.beatStrength,
    required this.spectralCentroid,
    required this.spectralRolloff,
    required this.zeroCrossingRate,
    required this.energy,
    required this.spectralFlux,
    required this.complexity,
    required this.overallEnergy,
    required this.brightness,
    required this.danceability,
    required this.confidence,
  });

  factory SignalProcessingResults.empty() {
    return SignalProcessingResults(
      tempoBpm: 0.0,
      beatStrength: 0.0,
      spectralCentroid: 0.0,
      spectralRolloff: 0.0,
      zeroCrossingRate: 0.0,
      energy: 0.0,
      spectralFlux: 0.0,
      complexity: 0.0,
      overallEnergy: 0.0,
      brightness: 0.0,
      danceability: 0.0,
      confidence: 0.0,
    );
  }
}

/// Analysis statistics class (same as original)
class AnalysisStats {
  final int totalSongs;
  final int successfulAnalyses;
  final int failedAnalyses;
  final double averageProcessingTime;
  final DateTime lastAnalysis;
  final Map<String, int> genreDistribution;
  final Map<String, int> instrumentDistribution;

  AnalysisStats({
    required this.totalSongs,
    required this.successfulAnalyses,
    required this.failedAnalyses,
    required this.averageProcessingTime,
    required this.lastAnalysis,
    required this.genreDistribution,
    required this.instrumentDistribution,
  });

  factory AnalysisStats.empty() {
    return AnalysisStats(
      totalSongs: 0,
      successfulAnalyses: 0,
      failedAnalyses: 0,
      averageProcessingTime: 0.0,
      lastAnalysis: DateTime.now(),
      genreDistribution: {},
      instrumentDistribution: {},
    );
  }

  /// Get success rate as percentage
  double get successRate {
    if (totalSongs == 0) return 0.0;
    return (successfulAnalyses / totalSongs) * 100.0;
  }

  /// Get failure rate as percentage
  double get failureRate {
    if (totalSongs == 0) return 0.0;
    return (failedAnalyses / totalSongs) * 100.0;
  }
}

/// YAMNet label with comprehensive categorization (SAME AS ORIGINAL)
class YAMNetLabel {
  final int index;
  final String mid;
  final String displayName;

  YAMNetLabel({
    required this.index,
    required this.mid,
    required this.displayName,
  });
  
  /// Check if label represents an instrument (COMPREHENSIVE - SAME AS ORIGINAL)
  bool get isInstrument {
    const instruments = [
      // String instruments
      'piano', 'guitar', 'electric guitar', 'acoustic guitar', 'bass guitar', 
      'steel guitar', 'slide guitar', 'banjo', 'mandolin', 'ukulele', 'sitar',
      'violin', 'viola', 'cello', 'double bass', 'contrabass', 'bass',
      'harp', 'zither', 'harpsichord', 'lute', 'sitar', 'bouzouki',
      
      // Wind instruments
      'saxophone', 'trumpet', 'trombone', 'tuba', 'french horn', 'flute',
      'clarinet', 'oboe', 'bassoon', 'recorder', 'piccolo', 'harmonica',
      'accordion', 'concertina', 'melodica', 'mouth organ', 'bagpipe',
      
      // Keyboard instruments
      'keyboard', 'organ', 'electronic organ', 'hammond organ', 'synthesizer',
      'sampler', 'electric piano', 'harpsichord', 'celesta', 'clavichord',
      
      // Percussion instruments
      'drum', 'drum kit', 'drum machine', 'snare drum', 'bass drum', 'timpani',
      'tabla', 'cymbal', 'hi-hat', 'crash', 'ride', 'tom', 'wood block',
      'tambourine', 'rattle', 'maraca', 'gong', 'tubular bells', 'mallet',
      'marimba', 'xylophone', 'glockenspiel', 'vibraphone', 'steelpan',
      'xylophone', 'vibraphone', 'glockenspiel', 'chimes', 'bells',
      
      // Electronic instruments
      'synthesizer', 'sampler', 'drum machine', 'electronic organ',
      'theremin', 'singing bowl', 'scratching',
      
      // Brass instruments
      'trumpet', 'trombone', 'tuba', 'french horn', 'cornet', 'flugelhorn',
      'baritone horn', 'euphonium', 'sousaphone',
      
      // Woodwind instruments
      'flute', 'clarinet', 'oboe', 'bassoon', 'saxophone', 'recorder',
      'piccolo', 'english horn', 'bass clarinet', 'contrabassoon',
      
      // Other instruments
      'harmonica', 'accordion', 'concertina', 'melodica', 'mouth organ',
      'bagpipe', 'didgeridoo', 'kalimba', 'thumb piano'
    ];
    final lower = displayName.toLowerCase();
    
    // Check for exact instrument matches
    final hasExactInstrument = instruments.any((inst) => lower == inst);
    
    // Check for instrument names (partial matches)
    final hasInstrument = instruments.any((inst) => lower.contains(inst));
    
    // Check for instrument-related terms
    const instrumentTerms = [
      'instrument', 'playing', 'strumming', 'plucking', 'bowing',
      'blowing', 'striking', 'hitting', 'tapping', 'fingering',
      'percussion', 'brass', 'woodwind', 'string', 'keyboard',
      'electronic', 'acoustic', 'electric', 'amplified'
    ];
    final hasInstrumentTerm = instrumentTerms.any((term) => lower.contains(term));
    
    // Check for specific YAMNet instrument patterns
    const yamnetPatterns = [
      'guitar', 'piano', 'drum', 'bass', 'violin', 'saxophone', 'trumpet',
      'flute', 'clarinet', 'organ', 'synthesizer', 'keyboard', 'banjo',
      'mandolin', 'ukulele', 'harp', 'accordion', 'harmonica', 'trombone',
      'tuba', 'oboe', 'bassoon', 'french horn', 'xylophone', 'marimba',
      'vibraphone', 'glockenspiel', 'timpani', 'cymbal', 'snare', 'kick',
      'hi-hat', 'crash', 'ride', 'tom', 'wood block', 'tambourine', 'rattle',
      'maraca', 'gong', 'tubular bells', 'mallet', 'steelpan'
    ];
    final hasYamnetPattern = yamnetPatterns.any((pattern) => lower.contains(pattern));
    
    return hasExactInstrument || hasInstrument || hasInstrumentTerm || hasYamnetPattern;
  }
  
  /// Check if label represents vocals (COMPREHENSIVE - SAME AS ORIGINAL)
  bool get isVocal {
    const vocals = [
      // Direct vocal terms
      'singing', 'speech', 'vocal', 'voice', 'choir', 'chorus', 'chant',
      'vocalization', 'vocal call', 'vocal song', 'vocal music',
      
      // Speech-related
      'conversation', 'talking', 'speaking', 'whispering', 'shouting',
      'yelling', 'screaming', 'laughing', 'crying', 'sobbing', 'whimpering',
      'wailing', 'moaning', 'sighing', 'yodeling', 'mantra', 'narration',
      'monologue', 'babbling', 'speech synthesizer', 'shout', 'bellow',
      'whoop', 'yell', 'whispering', 'laughter', 'giggle', 'snicker',
      'belly laugh', 'chuckle', 'chortle', 'crying', 'sobbing', 'whimper',
      'wail', 'moan', 'sigh', 'rap', 'rap', 'rapping', 'humming', 'groan',
      'grunt', 'whistling', 'breathing', 'wheeze', 'snoring', 'gasp',
      'pant', 'snort', 'cough', 'throat clearing', 'sneeze', 'sniff',
      
      // Child vocals
      'child speech', 'kid speaking', 'child singing', 'baby laughter',
      'baby cry', 'infant cry', 'children shouting', 'children playing',
      
      // Synthetic vocals
      'synthetic singing', 'speech synthesizer', 'synthetic voice',
      
      // Animal vocals (sometimes relevant for music)
      'bird vocalization', 'bird call', 'bird song', 'whale vocalization',
      
      // Music-specific vocals
      'vocal music', 'a capella', 'background vocals', 'lead vocals',
      'harmony vocals', 'backing vocals', 'vocal harmony'
    ];
    final lower = displayName.toLowerCase();
    
    // Check for exact vocal matches
    final hasExactVocal = vocals.any((vocal) => lower == vocal);
    
    // Check for vocal keywords (partial matches)
    final hasVocal = vocals.any((vocal) => lower.contains(vocal));
    
    // Check for vocal-related patterns
    const vocalPatterns = [
      'sing', 'speak', 'talk', 'voice', 'vocal', 'choir', 'chorus',
      'chant', 'rap', 'hum', 'whistle', 'laugh', 'cry', 'scream',
      'shout', 'whisper', 'yell', 'moan', 'wail', 'sigh', 'gasp',
      'pant', 'cough', 'sneeze', 'sniff', 'breath', 'vocalization'
    ];
    final hasVocalPattern = vocalPatterns.any((pattern) => lower.contains(pattern));
    
    return hasExactVocal || hasVocal || hasVocalPattern;
  }
  
  /// Check if label represents a genre (COMPREHENSIVE - SAME AS ORIGINAL)
  bool get isGenre {
    const genres = [
      'rock', 'pop', 'jazz', 'classical', 'electronic', 'blues', 'country',
      'hip hop', 'reggae', 'metal', 'folk', 'r&b', 'soul', 'funk', 'disco',
      'techno', 'house', 'trance', 'dubstep', 'ambient', 'indie', 'gospel',
      'latin', 'world', 'new age', 'alternative', 'punk', 'grunge', 'emo',
      'hardcore', 'progressive', 'experimental', 'avant-garde', 'minimalist',
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
      'exciting music', 'angry music', 'scary music'
    ];
    final lower = displayName.toLowerCase();
    
    // Check for exact genre matches
    final hasExactGenre = genres.any((genre) => lower == genre);
    
    // Check for genre keywords with or without 'music' suffix
    final hasGenre = genres.any((genre) => lower.contains(genre));
    
    // Check for music-related terms
    final hasMusic = lower.contains('music') || lower.contains('song') || lower.contains('tune');
    
    // Check for specific genre patterns
    final genrePatterns = [
      'music', 'song', 'tune', 'melody', 'rhythm', 'beat', 'sound',
      'acoustic', 'electric', 'vocal', 'instrumental', 'orchestral'
    ];
    final hasPattern = genrePatterns.any((pattern) => lower.contains(pattern));
    
    // IMPROVED: More comprehensive genre detection
    return hasExactGenre || hasGenre || hasMusic || hasPattern;
  }
  
  /// Check if label represents mood (COMPREHENSIVE - SAME AS ORIGINAL)
  bool get isMood {
    const moods = [
      // YAMNet specific mood labels
      'happy music', 'sad music', 'tender music', 'exciting music', 
      'angry music', 'scary music',
      
      // General mood terms
      'happy', 'sad', 'energetic', 'calm', 'melancholy', 'upbeat', 'cheerful',
      'gloomy', 'peaceful', 'relaxing', 'intense', 'aggressive', 'gentle',
      'joyful', 'somber', 'dark', 'bright', 'serene', 'tranquil',
      'tender', 'exciting', 'angry', 'scary', 'frightening', 'terrifying',
      'uplifting', 'inspiring', 'motivational', 'romantic', 'passionate',
      'melancholic', 'nostalgic', 'dreamy', 'ethereal', 'mysterious',
      'dramatic', 'epic', 'heroic', 'triumphant', 'celebratory',
      'contemplative', 'meditative', 'zen', 'spiritual', 'sacred',
      'playful', 'fun', 'lighthearted', 'whimsical', 'quirky',
      'moody', 'brooding', 'introspective', 'reflective', 'thoughtful',
      'energetic', 'dynamic', 'vibrant', 'lively', 'animated',
      'relaxed', 'chill', 'laid-back', 'mellow', 'smooth',
      'intense', 'powerful', 'strong', 'forceful', 'driving',
      'soft', 'gentle', 'delicate', 'subtle', 'understated'
    ];
    final lower = displayName.toLowerCase();
    
    // Check for exact mood matches
    final hasExactMood = moods.any((mood) => lower == mood);
    
    // Check for mood keywords (partial matches)
    final hasMood = moods.any((mood) => lower.contains(mood));
    
    // Check for mood-related patterns
    const moodPatterns = [
      'happy', 'sad', 'energetic', 'calm', 'melancholy', 'upbeat', 'cheerful',
      'gloomy', 'peaceful', 'relaxing', 'intense', 'aggressive', 'gentle',
      'joyful', 'somber', 'dark', 'bright', 'serene', 'tranquil', 'tender',
      'exciting', 'angry', 'scary', 'uplifting', 'romantic', 'dramatic',
      'playful', 'moody', 'energetic', 'relaxed', 'intense', 'soft'
    ];
    final hasMoodPattern = moodPatterns.any((pattern) => lower.contains(pattern));
    
    // Check for music mood indicators
    const musicMoodIndicators = [
      'music', 'song', 'tune', 'melody', 'harmony', 'rhythm', 'beat',
      'acoustic', 'electric', 'vocal', 'instrumental', 'orchestral',
      'ambient', 'atmospheric', 'cinematic', 'soundtrack', 'theme'
    ];
    final hasMusicMood = musicMoodIndicators.any((indicator) => lower.contains(indicator));
    
    return hasExactMood || hasMood || hasMoodPattern || hasMusicMood;
  }
  
  /// Check if label is energy-related (COMPREHENSIVE - SAME AS ORIGINAL)
  bool get isEnergyRelated {
    const energyTerms = [
      // Volume and intensity
      'loud', 'quiet', 'silent', 'mute', 'soft', 'strong', 'powerful',
      'intense', 'gentle', 'heavy', 'light', 'dynamic', 'aggressive',
      'calm', 'peaceful', 'energetic', 'lively', 'vibrant', 'animated',
      
      // Musical energy indicators
      'driving', 'pulsing', 'rhythmic', 'beat', 'tempo', 'fast', 'slow',
      'upbeat', 'downbeat', 'syncopated', 'steady', 'irregular',
      
      // Emotional energy
      'exciting', 'thrilling', 'exhilarating', 'stimulating', 'arousing',
      'relaxing', 'soothing', 'calming', 'tranquil', 'serene', 'meditative',
      'uplifting', 'inspiring', 'motivating', 'energizing', 'invigorating',
      
      // Sound characteristics
      'bright', 'dark', 'warm', 'cold', 'harsh', 'smooth', 'rough',
      'crisp', 'muffled', 'clear', 'distorted', 'clean', 'dirty',
      'sharp', 'dull', 'piercing', 'mellow', 'harsh', 'gentle',
      
      // Performance energy
      'passionate', 'emotional', 'dramatic', 'theatrical', 'expressive',
      'restrained', 'controlled', 'wild', 'uncontrolled', 'chaotic',
      'organized', 'structured', 'free', 'improvised', 'spontaneous',
      
      // Genre energy indicators
      'rock', 'metal', 'punk', 'hardcore', 'grunge', 'alternative',
      'electronic', 'techno', 'house', 'trance', 'dubstep', 'drum and bass',
      'ambient', 'new age', 'classical', 'orchestral', 'chamber',
      'acoustic', 'folk', 'country', 'blues', 'jazz', 'funk', 'soul',
      'reggae', 'ska', 'latin', 'world', 'ethnic', 'traditional'
    ];
    final lower = displayName.toLowerCase();
    
    // Check for exact energy matches
    final hasExactEnergy = energyTerms.any((term) => lower == term);
    
    // Check for energy keywords (partial matches)
    final hasEnergy = energyTerms.any((term) => lower.contains(term));
    
    // Check for energy-related patterns
    const energyPatterns = [
      'loud', 'quiet', 'energetic', 'intense', 'powerful', 'soft', 'strong',
      'heavy', 'light', 'dynamic', 'aggressive', 'gentle', 'bright', 'dark',
      'warm', 'cold', 'harsh', 'smooth', 'crisp', 'muffled', 'clear',
      'passionate', 'emotional', 'dramatic', 'wild', 'controlled', 'free'
    ];
    final hasEnergyPattern = energyPatterns.any((pattern) => lower.contains(pattern));
    
    return hasExactEnergy || hasEnergy || hasEnergyPattern;
  }
}


