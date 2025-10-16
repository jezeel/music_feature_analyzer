import 'dart:math' as math;

/// Mathematical utility functions
class MathUtils {
  /// Calculate mean of a list of numbers
  static double mean(List<double> values) {
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  /// Calculate standard deviation
  static double standardDeviation(List<double> values) {
    if (values.isEmpty) return 0.0;
    
    final meanValue = mean(values);
    final variance = values.map((x) => math.pow(x - meanValue, 2)).reduce((a, b) => a + b) / values.length;
    return math.sqrt(variance);
  }

  /// Calculate median
  static double median(List<double> values) {
    if (values.isEmpty) return 0.0;
    
    final sorted = List<double>.from(values)..sort();
    final n = sorted.length;
    
    if (n % 2 == 0) {
      return (sorted[n ~/ 2 - 1] + sorted[n ~/ 2]) / 2.0;
    } else {
      return sorted[n ~/ 2];
    }
  }

  /// Calculate percentile
  static double percentile(List<double> values, double percentile) {
    if (values.isEmpty) return 0.0;
    
    final sorted = List<double>.from(values)..sort();
    final index = (percentile / 100.0) * (sorted.length - 1);
    
    if (index == index.floor()) {
      return sorted[index.floor()];
    } else {
      final lower = sorted[index.floor()];
      final upper = sorted[index.ceil()];
      final fraction = index - index.floor();
      return lower + fraction * (upper - lower);
    }
  }

  /// Calculate correlation coefficient
  static double correlation(List<double> x, List<double> y) {
    if (x.length != y.length || x.isEmpty) return 0.0;
    
    final n = x.length;
    final meanX = mean(x);
    final meanY = mean(y);
    
    double numerator = 0.0;
    double sumXSquared = 0.0;
    double sumYSquared = 0.0;
    
    for (int i = 0; i < n; i++) {
      final xDiff = x[i] - meanX;
      final yDiff = y[i] - meanY;
      
      numerator += xDiff * yDiff;
      sumXSquared += xDiff * xDiff;
      sumYSquared += yDiff * yDiff;
    }
    
    final denominator = math.sqrt(sumXSquared * sumYSquared);
    return denominator == 0.0 ? 0.0 : numerator / denominator;
  }

  /// Calculate Euclidean distance
  static double euclideanDistance(List<double> a, List<double> b) {
    if (a.length != b.length) return double.infinity;
    
    double sum = 0.0;
    for (int i = 0; i < a.length; i++) {
      final diff = a[i] - b[i];
      sum += diff * diff;
    }
    
    return math.sqrt(sum);
  }

  /// Calculate Manhattan distance
  static double manhattanDistance(List<double> a, List<double> b) {
    if (a.length != b.length) return double.infinity;
    
    double sum = 0.0;
    for (int i = 0; i < a.length; i++) {
      sum += (a[i] - b[i]).abs();
    }
    
    return sum;
  }

  /// Calculate cosine similarity
  static double cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) return 0.0;
    
    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;
    
    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    
    final denominator = math.sqrt(normA) * math.sqrt(normB);
    return denominator == 0.0 ? 0.0 : dotProduct / denominator;
  }

  /// Normalize values to [0, 1] range
  static List<double> normalize(List<double> values) {
    if (values.isEmpty) return values;
    
    final minVal = values.reduce(math.min);
    final maxVal = values.reduce(math.max);
    
    if (maxVal == minVal) {
      return List.filled(values.length, 0.5);
    }
    
    return values.map((x) => (x - minVal) / (maxVal - minVal)).toList();
  }

  /// Normalize values to [-1, 1] range
  static List<double> normalizeSigned(List<double> values) {
    if (values.isEmpty) return values;
    
    final maxAbs = values.map((x) => x.abs()).reduce(math.max);
    
    if (maxAbs == 0.0) {
      return List.filled(values.length, 0.0);
    }
    
    return values.map((x) => x / maxAbs).toList();
  }

  /// Apply softmax function
  static List<double> softmax(List<double> values) {
    if (values.isEmpty) return values;
    
    // Find maximum value for numerical stability
    final maxVal = values.reduce(math.max);
    
    // Calculate exponentials
    final expValues = values.map((x) => math.exp(x - maxVal)).toList();
    final sum = expValues.reduce((a, b) => a + b);
    
    return expValues.map((x) => x / sum).toList();
  }

  /// Calculate entropy
  static double entropy(List<double> probabilities) {
    double entropy = 0.0;
    for (final p in probabilities) {
      if (p > 0.0) {
        entropy -= p * math.log(p) / math.ln2;
      }
    }
    return entropy;
  }

  /// Calculate mutual information
  static double mutualInformation(List<double> x, List<double> y, int bins) {
    if (x.length != y.length || x.isEmpty) return 0.0;
    
    // Create histograms
    final xMin = x.reduce(math.min);
    final xMax = x.reduce(math.max);
    final yMin = y.reduce(math.min);
    final yMax = y.reduce(math.max);
    
    final xBinSize = (xMax - xMin) / bins;
    final yBinSize = (yMax - yMin) / bins;
    
    final jointHist = List.generate(bins, (_) => List.filled(bins, 0));
    final xHist = List.filled(bins, 0);
    final yHist = List.filled(bins, 0);
    
    // Fill histograms
    for (int i = 0; i < x.length; i++) {
      final xBin = math.min(bins - 1, ((x[i] - xMin) / xBinSize).floor());
      final yBin = math.min(bins - 1, ((y[i] - yMin) / yBinSize).floor());
      
      jointHist[xBin][yBin]++;
      xHist[xBin]++;
      yHist[yBin]++;
    }
    
    // Calculate mutual information
    double mi = 0.0;
    for (int i = 0; i < bins; i++) {
      for (int j = 0; j < bins; j++) {
        if (jointHist[i][j] > 0) {
          final pJoint = jointHist[i][j] / x.length;
          final pX = xHist[i] / x.length;
          final pY = yHist[j] / x.length;
          
          mi += pJoint * math.log(pJoint / (pX * pY)) / math.ln2;
        }
      }
    }
    
    return mi;
  }

  /// Calculate autocorrelation
  static List<double> autocorrelation(List<double> data) {
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

  /// Find peaks in data
  static List<int> findPeaks(List<double> data, {double threshold = 0.0, int minDistance = 1}) {
    final peaks = <int>[];
    
    for (int i = 1; i < data.length - 1; i++) {
      if (data[i] > data[i - 1] && data[i] > data[i + 1] && data[i] > threshold) {
        // Check distance from existing peaks
        bool tooClose = false;
        for (final peak in peaks) {
          if ((i - peak).abs() < minDistance) {
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

  /// Calculate spectral flux
  static double spectralFlux(List<double> magnitudeSpectrum) {
    if (magnitudeSpectrum.length < 2) return 0.0;
    
    double flux = 0.0;
    for (int i = 1; i < magnitudeSpectrum.length; i++) {
      final diff = magnitudeSpectrum[i] - magnitudeSpectrum[i - 1];
      flux += diff > 0 ? diff : 0; // Only positive differences
    }
    
    return flux / (magnitudeSpectrum.length - 1);
  }

  /// Calculate spectral rolloff
  static double spectralRolloff(List<double> magnitudeSpectrum, double threshold) {
    final totalEnergy = magnitudeSpectrum.reduce((a, b) => a + b);
    final targetEnergy = totalEnergy * threshold;
    
    double cumulativeEnergy = 0.0;
    for (int i = 0; i < magnitudeSpectrum.length; i++) {
      cumulativeEnergy += magnitudeSpectrum[i];
      if (cumulativeEnergy >= targetEnergy) {
        return i / magnitudeSpectrum.length;
      }
    }
    
    return 1.0;
  }

  /// Calculate spectral centroid
  static double spectralCentroid(List<double> magnitudeSpectrum) {
    double weightedSum = 0.0;
    double magnitudeSum = 0.0;
    
    for (int i = 0; i < magnitudeSpectrum.length; i++) {
      weightedSum += i * magnitudeSpectrum[i];
      magnitudeSum += magnitudeSpectrum[i];
    }
    
    return magnitudeSum > 0 ? weightedSum / magnitudeSum : 0.0;
  }

  /// Calculate spectral bandwidth
  static double spectralBandwidth(List<double> magnitudeSpectrum, double centroid) {
    double weightedSum = 0.0;
    double magnitudeSum = 0.0;
    
    for (int i = 0; i < magnitudeSpectrum.length; i++) {
      final diff = i - centroid;
      weightedSum += diff * diff * magnitudeSpectrum[i];
      magnitudeSum += magnitudeSpectrum[i];
    }
    
    return magnitudeSum > 0 ? math.sqrt(weightedSum / magnitudeSum) : 0.0;
  }

  /// Calculate next power of 2
  static int nextPowerOf2(int n) {
    if (n <= 0) return 1;
    if ((n & (n - 1)) == 0) return n;
    return 1 << (n.bitLength);
  }

  /// Apply Hanning window to reduce spectral leakage
  static List<double> applyHanningWindow(List<double> data) {
    final windowed = <double>[];
    final n = data.length;
    
    for (int i = 0; i < n; i++) {
      final windowValue = 0.5 * (1 - math.cos(2 * math.pi * i / (n - 1)));
      windowed.add(data[i] * windowValue);
    }
    
    return windowed;
  }

  /// Perform FFT using Cooley-Tukey algorithm
  static List<Complex> performFFT(List<double> signal) {
    final n = signal.length;
    if (n == 1) return [Complex(signal[0], 0)];
    
    // Pad to power of 2
    final paddedLength = nextPowerOf2(n);
    final padded = List<double>.filled(paddedLength, 0.0);
    for (int i = 0; i < n; i++) {
      padded[i] = signal[i];
    }
    
    return _fftRecursive(padded);
  }

  /// Recursive FFT implementation
  static List<Complex> _fftRecursive(List<double> signal) {
    final n = signal.length;
    if (n == 1) return [Complex(signal[0], 0)];
    
    // Split into even and odd
    final even = <double>[];
    final odd = <double>[];
    for (int i = 0; i < n; i += 2) {
      even.add(signal[i]);
      if (i + 1 < n) odd.add(signal[i + 1]);
    }
    
    final evenFFT = _fftRecursive(even);
    final oddFFT = _fftRecursive(odd);
    
    final result = List<Complex>.filled(n, Complex(0, 0));
    final halfN = n ~/ 2;
    
    for (int k = 0; k < halfN; k++) {
      final t = oddFFT[k] * Complex(math.cos(-2 * math.pi * k / n), math.sin(-2 * math.pi * k / n));
      result[k] = evenFFT[k] + t;
      result[k + halfN] = evenFFT[k] - t;
    }
    
    return result;
  }

  /// Calculate magnitude spectrum from FFT result
  static List<double> calculateMagnitudeSpectrum(List<Complex> fft) {
    return fft.map((c) => math.sqrt(c.real * c.real + c.imaginary * c.imaginary)).toList();
  }
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
