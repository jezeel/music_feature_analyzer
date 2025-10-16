import 'package:flutter_test/flutter_test.dart';
import 'package:music_feature_analyzer/music_feature_analyzer.dart';
import 'package:music_feature_analyzer/src/models/song_features.dart';
import 'package:music_feature_analyzer/src/models/song_model.dart';
import 'package:music_feature_analyzer/src/services/feature_extractor.dart';

void main() {
  group('Music Feature Analyzer Tests', () {
    test('should initialize without errors', () async {
      // This is a basic test to ensure the package can be imported and initialized
      expect(MusicFeatureAnalyzer.isInitialized, false);

      // Note: We can't actually test initialization without real model files
      // but we can test that the class exists and methods are callable
      expect(MusicFeatureAnalyzer.getStats, isA<Function>());
      expect(MusicFeatureAnalyzer.dispose, isA<Function>());
    });

    test('should have proper model classes', () {
      // Test that our model classes are properly defined
      final song = Song(
        id: 'test',
        title: 'Test Song',
        artist: 'Test Artist',
        album: 'Test Album',
        duration: 180,
        filePath: '/test/path.mp3',
      );

      expect(song.id, 'test');
      expect(song.title, 'Test Song');
      expect(song.artist, 'Test Artist');
      expect(song.album, 'Test Album');
      expect(song.duration, 180);
      expect(song.filePath, '/test/path.mp3');
    });

    test('should have proper feature classes', () {
      // Test that our feature classes are properly defined
      final features = SongFeatures(
        tempo: 'Medium',
        beat: 'Strong',
        energy: 'High',
        instruments: ['Guitar', 'Piano'],
        vocals: 'Detected',
        mood: 'Happy',
        yamnetInstruments: ['Guitar', 'Piano'],
        hasVocals: true,
        estimatedGenre: 'Rock',
        yamnetEnergy: 0.8,
        moodTags: ['energetic', 'upbeat'],
        tempoBpm: 120.0,
        beatStrength: 0.7,
        signalEnergy: 0.8,
        brightness: 0.6,
        danceability: 0.8,
        spectralCentroid: 2000.0,
        spectralRolloff: 4000.0,
        zeroCrossingRate: 0.1,
        spectralFlux: 0.5,
        overallEnergy: 0.8,
        intensity: 0.7,
        complexity: 0.6,
        valence: 0.7,
        arousal: 0.8,
        analyzedAt: DateTime.now(),
        analyzerVersion: '1.0.0',
        confidence: 0.9,
      );

      expect(features.tempo, 'Medium');
      expect(features.beat, 'Strong');
      expect(features.energy, 'High');
      expect(features.instruments, ['Guitar', 'Piano']);
      expect(features.vocals, 'Detected');
      expect(features.mood, 'Happy');
      expect(features.hasVocals, true);
      expect(features.estimatedGenre, 'Rock');
      expect(features.yamnetEnergy, 0.8);
      expect(features.moodTags, ['energetic', 'upbeat']);
      expect(features.tempoBpm, 120.0);
      expect(features.beatStrength, 0.7);
      expect(features.signalEnergy, 0.8);
      expect(features.brightness, 0.6);
      expect(features.danceability, 0.8);
      expect(features.overallEnergy, 0.8);
      expect(features.intensity, 0.7);
      expect(features.spectralCentroid, 2000.0);
      expect(features.spectralRolloff, 4000.0);
      expect(features.zeroCrossingRate, 0.1);
      expect(features.spectralFlux, 0.5);
      expect(features.complexity, 0.6);
      expect(features.valence, 0.7);
      expect(features.arousal, 0.8);
      expect(features.analyzerVersion, '1.0.0');
      expect(features.confidence, 0.9);
    });

    test('should have proper analysis options', () {
      final options = AnalysisOptions(
        enableYAMNet: true,
        enableSignalProcessing: true,
        enableSpectralAnalysis: true,
        confidenceThreshold: 0.5,
        maxInstruments: 10,
        verboseLogging: false,
      );

      expect(options.enableYAMNet, true);
      expect(options.enableSignalProcessing, true);
      expect(options.enableSpectralAnalysis, true);
      expect(options.confidenceThreshold, 0.5);
      expect(options.maxInstruments, 10);
      expect(options.verboseLogging, false);
    });

    test('should have proper analysis stats', () {
      final stats = AnalysisStats(
        totalSongs: 100,
        successfulAnalyses: 95,
        failedAnalyses: 5,
        averageProcessingTime: 2.5,
        lastAnalysis: DateTime.now(),
        genreDistribution: {'Rock': 30, 'Pop': 25, 'Jazz': 20},
        instrumentDistribution: {'Guitar': 40, 'Piano': 35, 'Drums': 25},
      );

      expect(stats.totalSongs, 100);
      expect(stats.successfulAnalyses, 95);
      expect(stats.failedAnalyses, 5);
      expect(stats.averageProcessingTime, 2.5);
      expect(stats.genreDistribution, {'Rock': 30, 'Pop': 25, 'Jazz': 20});
      expect(stats.instrumentDistribution, {
        'Guitar': 40,
        'Piano': 35,
        'Drums': 25,
      });
      expect(stats.successRate, 95.0);
      expect(stats.failureRate, 5.0);
    });
  });
}
