import 'package:flutter_test/flutter_test.dart';
import 'package:music_feature_analyzer/music_feature_analyzer.dart';
import 'helpers/test_helpers.dart';

/// Main test suite for Music Feature Analyzer package
///
/// Covers:
/// - Package initialization and public API
/// - Model classes (SongModel, ExtractedSongFeatures)
/// - Metadata and background extraction API surface
void main() {
  group('Music Feature Analyzer - Main Tests', () {
    test('should expose all required API methods', () {
      expect(MusicFeatureAnalyzer.initialize, isA<Function>());
      expect(MusicFeatureAnalyzer.analyzeSong, isA<Function>());
      expect(MusicFeatureAnalyzer.analyzeSongs, isA<Function>());
      expect(MusicFeatureAnalyzer.extractFeaturesInBackground, isA<Function>());
      expect(MusicFeatureAnalyzer.getExtractionProgress, isA<Function>());
      expect(MusicFeatureAnalyzer.getStats, isA<Function>());
      expect(MusicFeatureAnalyzer.dispose, isA<Function>());
      expect(MusicFeatureAnalyzer.resetStats, isA<Function>());
      expect(MusicFeatureAnalyzer.metadata, isA<Function>());
      expect(MusicFeatureAnalyzer.extractMetadataBatch, isA<Function>());
      expect(MusicFeatureAnalyzer.isInitialized, isA<bool>());
    });

    test('SongModel works with test helper', () {
      final song = createTestSong(
        id: 'test',
        title: 'Test Song',
        duration: 180000,
        filePath: '/test/path.mp3',
      );
      expect(song.id, 'test');
      expect(song.title, 'Test Song');
      expect(song.artist, 'Test Artist');
      expect(song.album, 'Test Album');
      expect(song.duration, 180000);
      expect(song.filePath, '/test/path.mp3');
      expect(song.features, null);
    });

    test('ExtractedSongFeatures works with test helper', () {
      final features = createTestFeatures(
        tempo: 'Medium',
        energy: 'High',
        estimatedGenre: 'Rock',
        instruments: ['Guitar', 'Piano'],
        confidence: 0.9,
      );
      expect(features.tempo, 'Medium');
      expect(features.energy, 'High');
      expect(features.estimatedGenre, 'Rock');
      expect(features.instruments, ['Guitar', 'Piano']);
      expect(features.confidence, 0.9);
      expect(features.loudness, 0.5);
      expect(features.analyzedAt, isA<DateTime>());
    });

    test('extractFeaturesInBackground accepts optional durationMsByPath', () {
      final filePaths = ['/a.mp3', '/b.mp3'];
      final durationMsByPath = <String, int>{'/a.mp3': 180000, '/b.mp3': 240000};
      expect(filePaths.length, 2);
      expect(durationMsByPath.length, 2);
      expect(durationMsByPath['/a.mp3'], 180000);
    });

    test('metadata API exists and is callable', () {
      expect(MusicFeatureAnalyzer.metadata, isA<Function>());
    });
  });
}
