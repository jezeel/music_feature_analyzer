import 'dart:typed_data';
import 'dart:math' as math;

/// Audio utility functions
class AudioUtils {
  /// Convert audio bytes to Float32List
  static Float32List convertBytesToFloat32List(Uint8List bytes) {
    // Convert WAV bytes to float32 samples
    // This is a simplified conversion - in practice, you'd need proper WAV parsing
    final samples = <double>[];
    
    // Skip WAV header (44 bytes) and convert 16-bit samples to float
    for (int i = 44; i < bytes.length - 1; i += 2) {
      // Combine two bytes to form 16-bit sample
      final sample = (bytes[i + 1] << 8) | bytes[i];
      
      // Convert to signed 16-bit
      final signedSample = sample > 32767 ? sample - 65536 : sample;
      
      // Normalize to [-1, 1] range
      samples.add(signedSample / 32768.0);
    }
    
    return Float32List.fromList(samples);
  }

  /// Normalize audio data
  static Float32List normalize(Float32List audioData) {
    // Find maximum absolute value
    double maxVal = 0.0;
    for (final sample in audioData) {
      final absVal = sample.abs();
      if (absVal > maxVal) {
        maxVal = absVal;
      }
    }
    
    if (maxVal == 0.0) return audioData;
    
    // Normalize to [-1, 1] range
    final normalized = Float32List(audioData.length);
    for (int i = 0; i < audioData.length; i++) {
      normalized[i] = audioData[i] / maxVal;
    }
    
    return normalized;
  }

  /// Apply window function to audio data
  static Float32List applyWindow(Float32List audioData, WindowType windowType) {
    final windowed = Float32List(audioData.length);
    final n = audioData.length;
    
    for (int i = 0; i < n; i++) {
      double windowValue = 1.0;
      
      switch (windowType) {
        case WindowType.rectangular:
          windowValue = 1.0;
          break;
        case WindowType.hanning:
          windowValue = 0.5 * (1 - math.cos(2 * math.pi * i / (n - 1)));
          break;
        case WindowType.hamming:
          windowValue = 0.54 - 0.46 * math.cos(2 * math.pi * i / (n - 1));
          break;
        case WindowType.blackman:
          windowValue = 0.42 - 0.5 * math.cos(2 * math.pi * i / (n - 1)) + 
                       0.08 * math.cos(4 * math.pi * i / (n - 1));
          break;
      }
      
      windowed[i] = audioData[i] * windowValue;
    }
    
    return windowed;
  }

  /// Resample audio data
  static Float32List resample(Float32List audioData, int originalRate, int targetRate) {
    if (originalRate == targetRate) return audioData;
    
    final ratio = targetRate / originalRate;
    final newLength = (audioData.length * ratio).round();
    final resampled = Float32List(newLength);
    
    for (int i = 0; i < newLength; i++) {
      final originalIndex = i / ratio;
      final index = originalIndex.floor();
      final fraction = originalIndex - index;
      
      if (index < audioData.length - 1) {
        // Linear interpolation
        resampled[i] = audioData[index] * (1 - fraction) + audioData[index + 1] * fraction;
      } else {
        resampled[i] = audioData[audioData.length - 1];
      }
    }
    
    return resampled;
  }

  /// Apply low-pass filter
  static Float32List applyLowPassFilter(Float32List audioData, double cutoffFreq, double sampleRate) {
    final alpha = math.exp(-2 * math.pi * cutoffFreq / sampleRate);
    final filtered = Float32List(audioData.length);
    double prev = 0.0;
    
    for (int i = 0; i < audioData.length; i++) {
      filtered[i] = alpha * prev + (1 - alpha) * audioData[i];
      prev = filtered[i];
    }
    
    return filtered;
  }

  /// Apply high-pass filter
  static Float32List applyHighPassFilter(Float32List audioData, double cutoffFreq, double sampleRate) {
    final alpha = math.exp(-2 * math.pi * cutoffFreq / sampleRate);
    final filtered = Float32List(audioData.length);
    double prev = 0.0;
    
    for (int i = 0; i < audioData.length; i++) {
      filtered[i] = alpha * (prev + audioData[i] - alpha * prev);
      prev = filtered[i];
    }
    
    return filtered;
  }

  /// Calculate RMS (Root Mean Square) energy
  static double calculateRMS(Float32List audioData) {
    double sum = 0.0;
    for (final sample in audioData) {
      sum += sample * sample;
    }
    return math.sqrt(sum / audioData.length);
  }

  /// Calculate zero crossing rate
  static double calculateZeroCrossingRate(Float32List audioData) {
    int crossings = 0;
    
    for (int i = 1; i < audioData.length; i++) {
      if ((audioData[i] >= 0) != (audioData[i - 1] >= 0)) {
        crossings++;
      }
    }
    
    return crossings / (audioData.length - 1);
  }

  /// Calculate spectral centroid
  static double calculateSpectralCentroid(Float32List audioData, double sampleRate) {
    // Apply window
    final windowed = applyWindow(audioData, WindowType.hanning);
    
    // Calculate magnitude spectrum (simplified)
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
    
    return magnitudeSum > 0 ? weightedSum / magnitudeSum : 0.0;
  }

  /// Calculate magnitude spectrum (simplified FFT)
  static List<double> _calculateMagnitudeSpectrum(Float32List data) {
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
}

/// Window function types
enum WindowType {
  rectangular,
  hanning,
  hamming,
  blackman,
}
