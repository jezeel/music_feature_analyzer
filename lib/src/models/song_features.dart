import 'package:freezed_annotation/freezed_annotation.dart';

part 'song_features.freezed.dart';
part 'song_features.g.dart';

/// Comprehensive song features extracted by the analyzer
@freezed
class SongFeaturesModel with _$SongFeaturesModel {
  const factory SongFeaturesModel({
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
    
    // Combined metrics
    required double overallEnergy, // Combined energy score
    required double intensity, // Overall intensity
    required double spectralCentroid, // Spectral centroid
    required double spectralRolloff, // Spectral rolloff
    required double zeroCrossingRate, // Zero crossing rate
    required double spectralFlux, // Spectral flux
    required double complexity, // Complexity score
    required double valence, // Valence (emotional positivity)
    required double arousal, // Arousal (emotional intensity)
    required double confidence, // Analysis confidence
    
    // Analysis metadata
    required DateTime analyzedAt, // When analysis was performed
    required String analyzerVersion, // Analyzer version used
  }) = _SongFeaturesModel;

  factory SongFeaturesModel.fromJson(Map<String, dynamic> json) => _$SongFeaturesModelFromJson(json);
}

