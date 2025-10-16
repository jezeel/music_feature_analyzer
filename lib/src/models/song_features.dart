import 'package:freezed_annotation/freezed_annotation.dart';

part 'song_features.freezed.dart';
part 'song_features.g.dart';

/// Comprehensive song features extracted by the analyzer
@freezed
class SongFeatures with _$SongFeatures {
  const factory SongFeatures({
    // Basic categorical features
    required String tempo, // e.g. "Fast", "Medium", "Slow"
    required String beat, // e.g. "Strong", "Soft", "No Beat"
    required String energy, // e.g. "High", "Medium", "Low"
    required List<String> instruments, // e.g. ["Piano", "Guitar"]
    String? vocals, // e.g. "Emotional", "Energetic", or null for instrumental
    required String mood, // e.g. "Happy", "Sad", "Calm"
    
    // YAMNet analysis results
    required List<String> yamnetInstruments, // YAMNet detected instruments
    required bool hasVocals, // YAMNet vocal detection
    required String estimatedGenre, // YAMNet genre classification
    required double yamnetEnergy, // YAMNet energy score (0.0-1.0)
    required List<String> moodTags, // YAMNet mood tags
    
    // Signal processing features
    required double tempoBpm, // Actual BPM value
    required double beatStrength, // Beat strength (0.0-1.0)
    required double signalEnergy, // Signal energy (0.0-1.0)
    required double brightness, // Spectral brightness
    required double danceability, // Danceability score (0.0-1.0)
    
    // Spectral features
    required double spectralCentroid, // Spectral centroid frequency
    required double spectralRolloff, // Spectral rolloff frequency
    required double zeroCrossingRate, // Zero crossing rate
    required double spectralFlux, // Spectral flux
    
    // Combined metrics
    required double overallEnergy, // Combined energy score (0.0-1.0)
    required double intensity, // Overall intensity
    required double complexity, // Musical complexity score (0.0-1.0)
    required double valence, // Emotional valence (0.0-1.0)
    required double arousal, // Emotional arousal (0.0-1.0)
    
    // Analysis metadata
    required DateTime analyzedAt,
    required String analyzerVersion,
    required double confidence, // Overall analysis confidence (0.0-1.0)
  }) = _SongFeatures;

  factory SongFeatures.fromJson(Map<String, dynamic> json) => _$SongFeaturesFromJson(json);
}

/// Tempo categories
enum TempoCategory {
  verySlow('Very Slow', 0, 60),
  slow('Slow', 60, 80),
  moderate('Moderate', 80, 120),
  fast('Fast', 120, 140),
  veryFast('Very Fast', 140, 200);

  const TempoCategory(this.label, this.minBpm, this.maxBpm);
  final String label;
  final int minBpm;
  final int maxBpm;

  static TempoCategory fromBpm(double bpm) {
    if (bpm < 60) return TempoCategory.verySlow;
    if (bpm < 80) return TempoCategory.slow;
    if (bpm < 120) return TempoCategory.moderate;
    if (bpm < 140) return TempoCategory.fast;
    return TempoCategory.veryFast;
  }
}

/// Energy levels
enum EnergyLevel {
  veryLow('Very Low', 0.0, 0.2),
  low('Low', 0.2, 0.4),
  medium('Medium', 0.4, 0.6),
  high('High', 0.6, 0.8),
  veryHigh('Very High', 0.8, 1.0);

  const EnergyLevel(this.label, this.minValue, this.maxValue);
  final String label;
  final double minValue;
  final double maxValue;

  static EnergyLevel fromValue(double value) {
    if (value < 0.2) return EnergyLevel.veryLow;
    if (value < 0.4) return EnergyLevel.low;
    if (value < 0.6) return EnergyLevel.medium;
    if (value < 0.8) return EnergyLevel.high;
    return EnergyLevel.veryHigh;
  }
}

/// Mood categories
enum MoodCategory {
  happy('Happy'),
  sad('Sad'),
  energetic('Energetic'),
  calm('Calm'),
  angry('Angry'),
  peaceful('Peaceful'),
  romantic('Romantic'),
  mysterious('Mysterious'),
  dramatic('Dramatic'),
  playful('Playful');

  const MoodCategory(this.label);
  final String label;
}
