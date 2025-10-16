import 'dart:math' as math;
import 'dart:typed_data';
import 'package:logger/logger.dart';

/// Signal processing service for audio analysis
class SignalProcessor {
  static final Logger _logger = Logger();

  /// Analyze audio signal and extract features
  Future<SignalProcessingResults> analyze(Float32List audioData) async {
    try {
      _logger.d('🔬 Starting signal processing analysis...');
      
      // Calculate tempo (BPM)
      final tempoBpm = _calculateTempoBPM(audioData);
      
      // Calculate beat strength
      final beatStrength = _calculateBeatStrength(audioData);
      
      // Calculate overall energy
      final overallEnergy = _calculateOverallEnergy(audioData);
      
      // Calculate brightness (spectral centroid)
      final brightness = _calculateBrightness(audioData);
      
      // Calculate danceability
      final danceability = _calculateDanceability(audioData, tempoBpm);
      
      // Calculate spectral features
      final spectralCentroid = _calculateSpectralCentroid(audioData);
      final spectralRolloff = _calculateSpectralRolloff(audioData);
      final zeroCrossingRate = _calculateZeroCrossingRate(audioData);
      final spectralFlux = _calculateSpectralFlux(audioData);
      
      // Calculate confidence based on signal quality
      final confidence = _calculateConfidence(audioData);
      
      _logger.d('✅ Signal processing completed');
      
      return SignalProcessingResults(
        tempoBpm: tempoBpm,
        beatStrength: beatStrength,
        overallEnergy: overallEnergy,
        brightness: brightness,
        danceability: danceability,
        spectralCentroid: spectralCentroid,
        spectralRolloff: spectralRolloff,
        zeroCrossingRate: zeroCrossingRate,
        spectralFlux: spectralFlux,
        confidence: confidence,
      );
    } catch (e) {
      _logger.e('❌ Error in signal processing: $e');
      return SignalProcessingResults.empty();
    }
  }

  /// Calculate tempo in BPM using autocorrelation
  double _calculateTempoBPM(Float32List audioData) {
    try {
      const sampleRate = 16000.0;
      const minBpm = 60.0;
      const maxBpm = 200.0;
      
      // Use 2-second window for tempo detection
      final windowSize = math.min((sampleRate * 2).toInt(), audioData.length);
      final window = audioData.take(windowSize).toList();
      
      if (window.length < 1024) {
        return 120.0; // Default tempo
      }
      
      // Apply high-pass filter
      final filtered = _applyHighPassFilter(window, 80.0, sampleRate);
      
      // Calculate onset strength
      final onsetStrength = _calculateOnsetStrength(filtered);
      
      // Calculate autocorrelation
      final autocorr = _calculateAutocorrelation(onsetStrength);
      
      // Find peaks
      final peaks = _findPeaks(autocorr);
      
      if (peaks.isEmpty) {
        return 120.0;
      }
      
      // Convert lag to BPM and find best tempo
      double bestTempo = 120.0;
      double bestScore = 0.0;
      
      for (final peak in peaks) {
        final lag = peak.lag;
        final bpm = (sampleRate * 60.0) / lag;
        
        if (bpm >= minBpm && bpm <= maxBpm) {
          final score = peak.strength * _getBpmLikelihood(bpm);
          
          if (score > bestScore) {
            bestScore = score;
            bestTempo = bpm;
          }
        }
      }
      
      return bestTempo;
    } catch (e) {
      _logger.e('❌ Error calculating tempo: $e');
      return 120.0;
    }
  }

  /// Calculate beat strength
  double _calculateBeatStrength(Float32List audioData) {
    try {
      // Use spectral flux for beat strength
      final spectralFlux = _calculateSpectralFlux(audioData);
      
      // Normalize to 0-1 range
      return math.min(1.0, spectralFlux);
    } catch (e) {
      _logger.e('❌ Error calculating beat strength: $e');
      return 0.5;
    }
  }

  /// Calculate overall energy
  double _calculateOverallEnergy(Float32List audioData) {
    try {
      double sum = 0.0;
      for (final sample in audioData) {
        sum += sample * sample;
      }
      
      // RMS energy
      final rms = math.sqrt(sum / audioData.length);
      
      // Normalize to 0-1 range
      return math.min(1.0, rms * 10.0);
    } catch (e) {
      _logger.e('❌ Error calculating energy: $e');
      return 0.5;
    }
  }

  /// Calculate brightness (spectral centroid)
  double _calculateBrightness(Float32List audioData) {
    try {
      final spectralCentroid = _calculateSpectralCentroid(audioData);
      
      // Normalize to 0-1 range (assuming max frequency is 8000 Hz)
      return math.min(1.0, spectralCentroid / 8000.0);
    } catch (e) {
      _logger.e('❌ Error calculating brightness: $e');
      return 0.5;
    }
  }

  /// Calculate danceability
  double _calculateDanceability(Float32List audioData, double tempoBpm) {
    try {
      // Combine tempo and beat strength for danceability
      final tempoScore = _getTempoScore(tempoBpm);
      final beatStrength = _calculateBeatStrength(audioData);
      
      // Weighted combination
      return (tempoScore * 0.6 + beatStrength * 0.4);
    } catch (e) {
      _logger.e('❌ Error calculating danceability: $e');
      return 0.5;
    }
  }

  /// Calculate spectral centroid
  double _calculateSpectralCentroid(Float32List audioData) {
    try {
      const sampleRate = 16000.0;
      final windowSize = math.min(1024, audioData.length);
      final window = audioData.take(windowSize).toList();
      
      if (window.length < 64) {
        return 2000.0; // Default value
      }
      
      // Apply Hanning window
      final windowed = _applyHanningWindow(window);
      
      // Calculate magnitude spectrum
      final magnitudeSpectrum = _calculateMagnitudeSpectrum(windowed);
      
      // Calculate spectral centroid
      double weightedSum = 0.0;
      double magnitudeSum = 0.0;
      
      for (int i = 0; i < magnitudeSpectrum.length; i++) {
        final frequency = (i * sampleRate) / (2 * magnitudeSpectrum.length);
        final magnitude = magnitudeSpectrum[i];
        
        weightedSum += frequency * magnitude;
        magnitudeSum += magnitude;
      }
      
      return magnitudeSum > 0 ? weightedSum / magnitudeSum : 2000.0;
    } catch (e) {
      _logger.e('❌ Error calculating spectral centroid: $e');
      return 2000.0;
    }
  }

  /// Calculate spectral rolloff
  double _calculateSpectralRolloff(Float32List audioData) {
    try {
      const sampleRate = 16000.0;
      final windowSize = math.min(1024, audioData.length);
      final window = audioData.take(windowSize).toList();
      
      if (window.length < 64) {
        return 4000.0; // Default value
      }
      
      // Apply Hanning window
      final windowed = _applyHanningWindow(window);
      
      // Calculate magnitude spectrum
      final magnitudeSpectrum = _calculateMagnitudeSpectrum(windowed);
      
      // Calculate spectral rolloff (85% energy)
      final totalEnergy = magnitudeSpectrum.fold(0.0, (sum, mag) => sum + mag);
      final targetEnergy = totalEnergy * 0.85;
      
      double cumulativeEnergy = 0.0;
      for (int i = 0; i < magnitudeSpectrum.length; i++) {
        cumulativeEnergy += magnitudeSpectrum[i];
        if (cumulativeEnergy >= targetEnergy) {
          final frequency = (i * sampleRate) / (2 * magnitudeSpectrum.length);
          return frequency;
        }
      }
      
      return 4000.0; // Default value
    } catch (e) {
      _logger.e('❌ Error calculating spectral rolloff: $e');
      return 4000.0;
    }
  }

  /// Calculate zero crossing rate
  double _calculateZeroCrossingRate(Float32List audioData) {
    try {
      int crossings = 0;
      
      for (int i = 1; i < audioData.length; i++) {
        if ((audioData[i] >= 0) != (audioData[i - 1] >= 0)) {
          crossings++;
        }
      }
      
      return crossings / (audioData.length - 1);
    } catch (e) {
      _logger.e('❌ Error calculating zero crossing rate: $e');
      return 0.1;
    }
  }

  /// Calculate spectral flux
  double _calculateSpectralFlux(Float32List audioData) {
    try {
      // Calculate magnitude spectrum
      final magnitudeSpectrum = _calculateMagnitudeSpectrum(audioData);
      
      // Calculate spectral flux (difference between consecutive frames)
      double flux = 0.0;
      for (int i = 1; i < magnitudeSpectrum.length; i++) {
        final diff = magnitudeSpectrum[i] - magnitudeSpectrum[i - 1];
        flux += diff > 0 ? diff : 0; // Only positive differences
      }
      
      return flux / (magnitudeSpectrum.length - 1);
    } catch (e) {
      _logger.e('❌ Error calculating spectral flux: $e');
      return 0.5;
    }
  }

  /// Apply high-pass filter
  List<double> _applyHighPassFilter(List<double> data, double cutoffFreq, double sampleRate) {
    final alpha = math.exp(-2 * math.pi * cutoffFreq / sampleRate);
    final filtered = <double>[];
    double prev = 0.0;
    
    for (final sample in data) {
      final filteredSample = alpha * (prev + sample - (alpha * prev));
      filtered.add(filteredSample);
      prev = filteredSample;
    }
    
    return filtered;
  }

  /// Calculate onset strength
  List<double> _calculateOnsetStrength(List<double> data) {
    final onsetStrength = <double>[];
    
    for (int i = 1; i < data.length; i++) {
      final diff = data[i] - data[i - 1];
      onsetStrength.add(diff > 0 ? diff : 0);
    }
    
    return onsetStrength;
  }

  /// Calculate autocorrelation
  List<double> _calculateAutocorrelation(List<double> data) {
    final n = data.length;
    final autocorr = List<double>.filled(n, 0.0);
    
    for (int lag = 0; lag < n; lag++) {
      double sum = 0.0;
      for (int i = 0; i < n - lag; i++) {
        sum += data[i] * data[i + lag];
      }
      autocorr[lag] = sum / (n - lag);
    }
    
    return autocorr;
  }

  /// Find peaks in autocorrelation
  List<Peak> _findPeaks(List<double> data) {
    final peaks = <Peak>[];
    const minDistance = 20; // Minimum distance between peaks
    const threshold = 0.1; // Minimum peak strength
    
    for (int i = 1; i < data.length - 1; i++) {
      if (data[i] > data[i - 1] && data[i] > data[i + 1] && data[i] > threshold) {
        // Check distance from existing peaks
        bool tooClose = false;
        for (final peak in peaks) {
          if ((i - peak.lag).abs() < minDistance) {
            tooClose = true;
            break;
          }
        }
        
        if (!tooClose) {
          peaks.add(Peak(lag: i, strength: data[i]));
        }
      }
    }
    
    // Sort by strength
    peaks.sort((a, b) => b.strength.compareTo(a.strength));
    
    return peaks.take(10).toList();
  }

  /// Apply Hanning window
  List<double> _applyHanningWindow(List<double> data) {
    final windowed = <double>[];
    final n = data.length;
    
    for (int i = 0; i < n; i++) {
      final windowValue = 0.5 * (1 - math.cos(2 * math.pi * i / (n - 1)));
      windowed.add(data[i] * windowValue);
    }
    
    return windowed;
  }

  /// Calculate magnitude spectrum (simplified FFT)
  List<double> _calculateMagnitudeSpectrum(List<double> data) {
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

  /// Get BPM likelihood score
  double _getBpmLikelihood(double bpm) {
    // Common tempo ranges get higher scores
    if (bpm >= 60 && bpm <= 80) return 0.8; // Slow
    if (bpm >= 80 && bpm <= 120) return 1.0; // Medium (most common)
    if (bpm >= 120 && bpm <= 140) return 0.9; // Fast
    if (bpm >= 140 && bpm <= 180) return 0.7; // Very fast
    return 0.3; // Uncommon tempos
  }

  /// Get tempo score for danceability
  double _getTempoScore(double bpm) {
    // Optimal dance tempo is around 120-130 BPM
    if (bpm >= 110 && bpm <= 140) return 1.0;
    if (bpm >= 90 && bpm <= 160) return 0.8;
    if (bpm >= 70 && bpm <= 180) return 0.6;
    return 0.3;
  }

  /// Calculate confidence based on signal quality
  double _calculateConfidence(Float32List audioData) {
    try {
      // Calculate signal-to-noise ratio
      final energy = _calculateOverallEnergy(audioData);
      final noise = _calculateNoiseLevel(audioData);
      
      if (noise > 0) {
        final snr = 20 * math.log(energy / noise) / math.ln10;
        return math.min(1.0, math.max(0.0, (snr + 20) / 40)); // Normalize to 0-1
      }
      
      return 0.5; // Default confidence
    } catch (e) {
      _logger.e('❌ Error calculating confidence: $e');
      return 0.5;
    }
  }

  /// Calculate noise level
  double _calculateNoiseLevel(Float32List audioData) {
    // Simple noise estimation using minimum values
    final sortedData = List<double>.from(audioData)..sort();
    final noiseLevel = sortedData.take(sortedData.length ~/ 10).fold(0.0, (sum, val) => sum + val.abs()) / (sortedData.length ~/ 10);
    return noiseLevel;
  }

}

/// Peak data class
class Peak {
  final int lag;
  final double strength;

  const Peak({
    required this.lag,
    required this.strength,
  });
}

/// Complex number class for FFT calculations
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

/// Signal processing results
class SignalProcessingResults {
  final double tempoBpm;
  final double beatStrength;
  final double overallEnergy;
  final double brightness;
  final double danceability;
  final double spectralCentroid;
  final double spectralRolloff;
  final double zeroCrossingRate;
  final double spectralFlux;
  final double confidence;

  const SignalProcessingResults({
    required this.tempoBpm,
    required this.beatStrength,
    required this.overallEnergy,
    required this.brightness,
    required this.danceability,
    required this.spectralCentroid,
    required this.spectralRolloff,
    required this.zeroCrossingRate,
    required this.spectralFlux,
    required this.confidence,
  });

  factory SignalProcessingResults.empty() {
    return const SignalProcessingResults(
      tempoBpm: 120.0,
      beatStrength: 0.5,
      overallEnergy: 0.5,
      brightness: 0.5,
      danceability: 0.5,
      spectralCentroid: 2000.0,
      spectralRolloff: 4000.0,
      zeroCrossingRate: 0.1,
      spectralFlux: 0.5,
      confidence: 0.0,
    );
  }
}
