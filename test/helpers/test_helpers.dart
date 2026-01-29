import 'package:music_feature_analyzer/src/models/extracted_song_features.dart';
import 'package:music_feature_analyzer/src/models/song_model.dart';

/// Shared test helpers for Music Feature Analyzer tests.
/// Use these to create consistent mock data and avoid duplication.

/// Creates a [SongModel] with optional overrides for tests.
SongModel createTestSong({
  String id = 'test_song_1',
  String title = 'Test Song',
  String artist = 'Test Artist',
  String album = 'Test Album',
  int duration = 180000, // 3 minutes in ms
  String filePath = '/test/path/song.mp3',
  ExtractedSongFeatures? features,
}) {
  return SongModel(
    id: id,
    title: title,
    artist: artist,
    album: album,
    duration: duration,
    filePath: filePath,
    features: features,
  );
}

/// Creates [ExtractedSongFeatures] with optional overrides for tests.
ExtractedSongFeatures createTestFeatures({
  String tempo = 'Medium',
  String beat = 'Strong',
  String energy = 'High',
  List<String> instruments = const ['Guitar', 'Piano'],
  String? vocals = 'Detected',
  String mood = 'Neutral',
  String estimatedGenre = 'Rock',
  bool hasVocals = true,
  double yamnetEnergy = 0.7,
  List<String> moodTags = const ['neutral'],
  double tempoBpm = 120.0,
  double beatStrength = 0.6,
  double signalEnergy = 0.7,
  double brightness = 0.5,
  double danceability = 0.6,
  double loudness = 0.5,
  double confidence = 0.8,
  double overallEnergy = 0.7,
  double intensity = 0.6,
  double spectralCentroid = 2000.0,
  double spectralRolloff = 4000.0,
  double zeroCrossingRate = 0.1,
  double spectralFlux = 0.4,
  double complexity = 0.5,
  double valence = 0.6,
  double arousal = 0.7,
  String analyzerVersion = '1.0.0',
}) {
  return ExtractedSongFeatures(
    tempo: tempo,
    beat: beat,
    energy: energy,
    instruments: instruments,
    vocals: vocals,
    mood: mood,
    yamnetInstruments: instruments,
    hasVocals: hasVocals,
    estimatedGenre: estimatedGenre,
    yamnetEnergy: yamnetEnergy,
    moodTags: moodTags,
    tempoBpm: tempoBpm,
    beatStrength: beatStrength,
    signalEnergy: signalEnergy,
    brightness: brightness,
    danceability: danceability,
    loudness: loudness,
    spectralCentroid: spectralCentroid,
    spectralRolloff: spectralRolloff,
    zeroCrossingRate: zeroCrossingRate,
    spectralFlux: spectralFlux,
    overallEnergy: overallEnergy,
    intensity: intensity,
    complexity: complexity,
    valence: valence,
    arousal: arousal,
    confidence: confidence,
    analyzedAt: DateTime.now(),
    analyzerVersion: analyzerVersion,
  );
}

/// Creates a list of [ExtractedSongFeatures] for 4-part combine tests (varying numeric values).
List<ExtractedSongFeatures> createFourPartFeaturesForCombine({
  double tempoBpm1 = 100,
  double tempoBpm2 = 110,
  double tempoBpm3 = 120,
  double tempoBpm4 = 130,
  double confidence1 = 0.7,
  double confidence2 = 0.9, // highest
  double confidence3 = 0.6,
  double confidence4 = 0.8,
}) {
  return [
    createTestFeatures(tempoBpm: tempoBpm1, confidence: confidence1, estimatedGenre: 'Rock', mood: 'Energetic'),
    createTestFeatures(tempoBpm: tempoBpm2, confidence: confidence2, estimatedGenre: 'Pop', mood: 'Happy'),
    createTestFeatures(tempoBpm: tempoBpm3, confidence: confidence3, estimatedGenre: 'Jazz', mood: 'Calm'),
    createTestFeatures(tempoBpm: tempoBpm4, confidence: confidence4, estimatedGenre: 'Electronic', mood: 'Neutral'),
  ];
}
