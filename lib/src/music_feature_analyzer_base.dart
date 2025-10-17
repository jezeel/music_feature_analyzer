import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'utils/app_logger.dart';
import 'models/song_features.dart';
import 'models/song_model.dart';
import 'services/feature_extractor.dart';

/// ============================================================================
/// MUSIC FEATURE ANALYZER - Main Package Entry Point
/// ============================================================================
/// 
/// PURPOSE: Comprehensive music feature extraction using YAMNet AI model
/// 
/// FEATURES:
/// - YAMNet AI analysis (instruments, vocals, genre, mood, energy)
/// - Signal processing (tempo, beat, energy, spectral features)
/// - Background processing with isolates
/// - Progress tracking and statistics
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
  static Future<bool> initialize() async {
    try {
      if (_isInitialized) {
        _logger.d('✅ Already initialized');
        return true;
      }

      _logger.i('🚀 Initializing Music Feature Analyzer...');
      
      // Initialize the feature extractor
      _extractor = FeatureExtractor();
      final success = await _extractor!.initialize();
      
      if (success) {
        _isInitialized = true;
        _logger.i('✅ Music Feature Analyzer initialized successfully');
        return true;
      } else {
        _logger.e('❌ Failed to initialize feature extractor');
        return false;
      }
    } catch (e, stackTrace) {
      _logger.e('❌ Initialization failed: $e');
      _logger.e('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Analyze a single song
  static Future<SongFeatures?> analyzeSong(Song song) async {
    if (!_isInitialized || _extractor == null) {
      _logger.e('❌ Analyzer not initialized. Call initialize() first.');
      return null;
    }

    try {
      _logger.i('🎵 Analyzing song: ${song.title}');
      return await _extractor!.extractSongFeatures(song);
    } catch (e) {
      _logger.e('❌ Error analyzing song: $e');
      return null;
    }
  }

  /// Analyze multiple songs
  static Future<List<SongFeatures?>> analyzeSongs(List<Song> songs) async {
    if (!_isInitialized || _extractor == null) {
      _logger.e('❌ Analyzer not initialized. Call initialize() first.');
      return [];
    }

    try {
      _logger.i('🎵 Analyzing ${songs.length} songs');
      final results = <SongFeatures?>[];
      
      for (final song in songs) {
        final features = await _extractor!.extractSongFeatures(song);
        results.add(features);
      }
      
      return results;
    } catch (e) {
      _logger.e('❌ Error analyzing songs: $e');
      return [];
    }
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
            moodTags.add(label);
          }
        }
      }
      
      // Calculate energy from results
      energy = results.take(100).reduce((a, b) => a + b) / 100;
      
      return {
        'instruments': instruments.isEmpty ? ['Unknown'] : instruments,
        'hasVocals': hasVocals,
        'genre': genre,
        'mood': moodTags.isEmpty ? 'Neutral' : moodTags.first,
        'moodTags': moodTags.isEmpty ? ['Neutral'] : moodTags,
        'energyValue': energy,
      };
    } catch (e) {
      return {
        'instruments': ['Unknown'],
        'hasVocals': false,
        'genre': 'Unknown',
        'mood': 'Neutral',
        'moodTags': ['Neutral'],
        'energyValue': 0.5,
      };
    }
  }

  /// Calculate signal features in isolate (SAME AS ORIGINAL)
  static SignalFeatures _calculateSignalFeaturesInIsolate(Float32List audioData) {
    try {
      // Calculate energy
      final energy = _calculateEnergyInIsolate(audioData);
      
      // Calculate tempo (simplified autocorrelation)
      final tempoBpm = _calculateTempoInIsolate(audioData);
      
      // Calculate beat strength
      final beatStrength = _calculateBeatStrengthInIsolate(audioData);
      
      // Calculate spectral features
      final spectralCentroid = _calculateSpectralCentroidInIsolate(audioData);
      final spectralRolloff = _calculateSpectralRolloffInIsolate(audioData);
      final zeroCrossingRate = _calculateZeroCrossingRateInIsolate(audioData);
      
      return SignalFeatures(
        tempoBpm: tempoBpm,
        beatStrength: beatStrength,
        energy: energy,
        brightness: spectralCentroid,
        danceability: _calculateDanceabilityInIsolate(energy, tempoBpm),
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
        brightness: 2000.0,
        danceability: 0.5,
        spectralCentroid: 2000.0,
        spectralRolloff: 4000.0,
        zeroCrossingRate: 0.1,
      );
    }
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

  /// Calculate spectral centroid in isolate (SAME AS ORIGINAL)
  static double _calculateSpectralCentroidInIsolate(Float32List audioData) {
    try {
      final windowSize = math.min(1024, audioData.length);
      final window = audioData.take(windowSize).toList();
      
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

  /// Calculate spectral rolloff in isolate (SAME AS ORIGINAL)
  static double _calculateSpectralRolloffInIsolate(Float32List audioData) {
    try {
      final windowSize = math.min(1024, audioData.length);
      final window = audioData.take(windowSize).toList();
      
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

  /// Calculate danceability in isolate (SAME AS ORIGINAL)
  static double _calculateDanceabilityInIsolate(double energy, double tempo) {
    // Danceability based on energy and tempo
    final tempoFactor = math.min(1.0, tempo / 140.0);
    final energyFactor = energy;
    return (tempoFactor + energyFactor) / 2;
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

      // Pre-load assets in main thread (same as original)
      final isolateData = await _prepareIsolateData(song);
      
      // Use compute for isolate-based processing with pre-loaded data
      return await compute(_extractFeaturesInIsolateHelper, isolateData);
    } catch (e) {
      _logger.e('❌ Error in isolate processing: $e');
      return null;
    }
  }

  /// Helper function for isolate processing with pre-loaded data
  static Future<SongFeatures?> _extractFeaturesInIsolateHelper(IsolateFeatureData data) async {
    try {
      // Initialize TFLite interpreter with pre-loaded model bytes
      final interpreter = Interpreter.fromBuffer(data.yamnetModelBytes);
      
      // Extract features using the pre-loaded data
      final features = await _extractFeaturesWithPreloadedData(
        data.song,
        interpreter,
        data.yamnetLabels,
        data.modelVersion,
        data.audioData,
      );
      
      // Close interpreter
      interpreter.close();
      
      return features;
    } catch (e) {
      return null;
    }
  }

  /// Prepare data for isolate processing (same as original)
  static Future<IsolateFeatureData> _prepareIsolateData(Song song) async {
    try {
      _logger.d('📦 Preparing isolate data for: ${song.title}');

      // Get pre-loaded model bytes and labels from main extractor
      final modelBytes = _extractor?.getModelBytes();
      final labels = _extractor?.getLabels();
      
      if (modelBytes == null || labels == null) {
        throw Exception('Model or labels not available - ensure main extractor is initialized');
      }

      // Pre-process audio in main thread (FFmpeg can be used here)
      final audioData = await _extractor?.extractAudioWaveform(song.filePath, Duration(minutes: 3));
      
      return IsolateFeatureData(
        song: song,
        yamnetModelBytes: modelBytes,
        yamnetLabels: labels,
        modelVersion: '1.0.0',
        audioData: audioData,
      );
    } catch (e) {
      _logger.e('❌ Error preparing isolate data: $e');
      rethrow;
    }
  }

  /// Extract features using pre-loaded model and labels (SAME AS ORIGINAL)
  static Future<SongFeatures?> _extractFeaturesWithPreloadedData(
    Song song,
    Interpreter interpreter,
    List<String> yamnetLabels,
    String modelVersion,
    Float32List? audioData,
  ) async {
    try {
      // Use pre-processed audio data
      if (audioData == null) {
        _logger.w('⚠️ No pre-processed audio data available for ${song.title}');
        return null;
      }

      _logger.d('🤖 Running YAMNet analysis in isolate for: ${song.title}');
      
      // Run YAMNet inference (SAME AS ORIGINAL)
      final yamnetResults = await _runYAMNetInference(interpreter, audioData);
      
      _logger.d('🔍 YAMNet results: ${yamnetResults.length} scores, top 5: ${yamnetResults.take(5).toList()}');
      
      // Process YAMNet results (SAME AS ORIGINAL)
      final yamnetFeatures = _processYAMNetResultsInIsolate(yamnetResults, yamnetLabels);
      
      // Calculate real signal features (SAME AS ORIGINAL)
      final signalFeatures = _calculateSignalFeaturesInIsolate(audioData);
      
      _logger.d('🎵 Processed features: genre=${yamnetFeatures['genre']}, instruments=${yamnetFeatures['instruments']}, hasVocals=${yamnetFeatures['hasVocals']}');
      _logger.d('🎵 Signal features: tempo=${signalFeatures.tempoBpm}, energy=${signalFeatures.energy}, spectralCentroid=${signalFeatures.spectralCentroid}');
      
      // Create comprehensive features (SAME AS ORIGINAL)
      final songFeatures = SongFeatures(
        tempo: _categorizeTempoInIsolate(signalFeatures.tempoBpm),
        beat: _categorizeBeatInIsolate(signalFeatures.beatStrength),
        energy: _categorizeEnergyInIsolate(signalFeatures.energy),
        instruments: yamnetFeatures['instruments'] as List<String>,
        vocals: yamnetFeatures['hasVocals'] as bool ? _categorizeVocalsInIsolate(yamnetFeatures['energyValue'] as double) : null,
        mood: _categorizeMoodInIsolate(yamnetFeatures['moodTags'] as List<String>),
        yamnetInstruments: yamnetFeatures['instruments'] as List<String>,
        hasVocals: yamnetFeatures['hasVocals'] as bool,
        estimatedGenre: yamnetFeatures['genre'] as String,
        yamnetEnergy: yamnetFeatures['energyValue'] as double,
        moodTags: yamnetFeatures['moodTags'] as List<String>,
        tempoBpm: signalFeatures.tempoBpm,
        beatStrength: signalFeatures.beatStrength,
        signalEnergy: signalFeatures.energy,
        brightness: signalFeatures.spectralCentroid,
        danceability: signalFeatures.danceability,
        overallEnergy: ((yamnetFeatures['energyValue'] as double) + signalFeatures.energy) / 2.0,
        intensity: signalFeatures.energy,
        spectralCentroid: signalFeatures.spectralCentroid,
        spectralRolloff: signalFeatures.spectralRolloff,
        zeroCrossingRate: signalFeatures.zeroCrossingRate,
        spectralFlux: signalFeatures.energy * 0.5, // Simplified calculation
        complexity: (signalFeatures.zeroCrossingRate + (signalFeatures.spectralCentroid / 8000.0)) / 2.0,
        valence: yamnetFeatures['energyValue'] as double,
        arousal: signalFeatures.energy,
        confidence: (signalFeatures.beatStrength + signalFeatures.energy + (signalFeatures.spectralCentroid / 8000.0)) / 3.0,
        analyzerVersion: modelVersion,
        analyzedAt: DateTime.now(),
      );

      _logger.d('✅ Created SongFeatures: genre=${songFeatures.estimatedGenre}, tempo=${songFeatures.tempoBpm}');
      return songFeatures;
    } catch (e) {
      _logger.e('❌ Error extracting features for ${song.title}: $e');
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
      _logger.e('❌ Error running YAMNet inference: $e');
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

/// Signal processing features
class SignalFeatures {
  final double tempoBpm;
  final double beatStrength;
  final double energy;
  final double brightness;
  final double danceability;
  final double spectralCentroid;
  final double spectralRolloff;
  final double zeroCrossingRate;

  SignalFeatures({
    required this.tempoBpm,
    required this.beatStrength,
    required this.energy,
    required this.brightness,
    required this.danceability,
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