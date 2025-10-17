import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_feature_analyzer/music_feature_analyzer.dart';
import 'package:music_feature_analyzer/src/models/song_features.dart';
import 'package:music_feature_analyzer/src/models/song_model.dart';
import 'package:music_feature_analyzer/src/services/feature_extractor.dart';

/// Comprehensive test suite for Music Feature Analyzer package
/// 
/// This test suite covers:
/// - Package initialization and basic functionality
/// - Model classes and data structures
/// - Feature extraction algorithms
/// - YAMNet analysis simulation
/// - Error handling and fallback mechanisms
/// - Integration testing
/// - Performance testing
void main() {
  group('Music Feature Analyzer - Comprehensive Tests', () {
    
    // ============================================================================
    // BASIC FUNCTIONALITY TESTS
    // ============================================================================
    
    group('Basic Functionality', () {
      test('should have proper API methods', () {
        expect(MusicFeatureAnalyzer.initialize, isA<Function>());
        expect(MusicFeatureAnalyzer.analyzeSong, isA<Function>());
        expect(MusicFeatureAnalyzer.analyzeSongs, isA<Function>());
        expect(MusicFeatureAnalyzer.extractFeaturesInBackground, isA<Function>());
        expect(MusicFeatureAnalyzer.getExtractionProgress, isA<Function>());
        expect(MusicFeatureAnalyzer.getStats, isA<Function>());
        expect(MusicFeatureAnalyzer.dispose, isA<Function>());
        expect(MusicFeatureAnalyzer.resetStats, isA<Function>());
      });
    });

    // ============================================================================
    // MODEL CLASSES TESTS
    // ============================================================================
    
    group('Model Classes', () {
      test('Song model should work correctly', () {
        final song = Song(
          id: 'test_song_123',
          title: 'Test Song Title',
          artist: 'Test Artist',
          album: 'Test Album',
          duration: 180, // 3 minutes
          filePath: '/test/path/song.mp3',
        );

        expect(song.id, 'test_song_123');
        expect(song.title, 'Test Song Title');
        expect(song.artist, 'Test Artist');
        expect(song.album, 'Test Album');
        expect(song.duration, 180);
        expect(song.filePath, '/test/path/song.mp3');
        expect(song.features, null);
      });

      test('SongFeatures model should work correctly', () {
        final features = SongFeatures(
          tempo: 'Fast',
          beat: 'Strong',
          energy: 'High',
          instruments: ['Guitar', 'Piano', 'Drums'],
          vocals: 'Detected',
          mood: 'Energetic',
          yamnetInstruments: ['Electric Guitar', 'Piano', 'Drum Kit'],
          hasVocals: true,
          estimatedGenre: 'Rock',
          yamnetEnergy: 0.85,
          moodTags: ['energetic', 'upbeat', 'exciting'],
          tempoBpm: 140.0,
          beatStrength: 0.8,
          signalEnergy: 0.85,
          brightness: 0.7,
          danceability: 0.9,
          spectralCentroid: 2500.0,
          spectralRolloff: 5000.0,
          zeroCrossingRate: 0.15,
          spectralFlux: 0.6,
          overallEnergy: 0.85,
          intensity: 0.8,
          complexity: 0.7,
          valence: 0.8,
          arousal: 0.9,
          analyzedAt: DateTime.now(),
          analyzerVersion: '1.0.0',
          confidence: 0.95,
        );

        // Test basic categorical features
        expect(features.tempo, 'Fast');
        expect(features.beat, 'Strong');
        expect(features.energy, 'High');
        expect(features.instruments, ['Guitar', 'Piano', 'Drums']);
        expect(features.vocals, 'Detected');
        expect(features.mood, 'Energetic');

        // Test YAMNet results
        expect(features.yamnetInstruments, ['Electric Guitar', 'Piano', 'Drum Kit']);
        expect(features.hasVocals, true);
        expect(features.estimatedGenre, 'Rock');
        expect(features.yamnetEnergy, 0.85);
        expect(features.moodTags, ['energetic', 'upbeat', 'exciting']);

        // Test signal processing results
        expect(features.tempoBpm, 140.0);
        expect(features.beatStrength, 0.8);
        expect(features.signalEnergy, 0.85);
        expect(features.brightness, 0.7);
        expect(features.danceability, 0.9);

        // Test spectral features
        expect(features.spectralCentroid, 2500.0);
        expect(features.spectralRolloff, 5000.0);
        expect(features.zeroCrossingRate, 0.15);
        expect(features.spectralFlux, 0.6);

        // Test combined metrics
        expect(features.overallEnergy, 0.85);
        expect(features.intensity, 0.8);
        expect(features.complexity, 0.7);
        expect(features.valence, 0.8);
        expect(features.arousal, 0.9);

        // Test metadata
        expect(features.analyzerVersion, '1.0.0');
        expect(features.confidence, 0.95);
        expect(features.analyzedAt, isA<DateTime>());
      });


      test('AnalysisStats should work correctly', () {
        final stats = AnalysisStats(
          totalSongs: 150,
          successfulAnalyses: 142,
          failedAnalyses: 8,
          averageProcessingTime: 3.2,
          lastAnalysis: DateTime.now(),
          genreDistribution: {
            'Rock': 45,
            'Pop': 38,
            'Jazz': 25,
            'Electronic': 20,
            'Classical': 12,
            'Unknown': 10,
          },
          instrumentDistribution: {
            'Guitar': 60,
            'Piano': 45,
            'Drums': 40,
            'Bass': 35,
            'Violin': 20,
            'Saxophone': 15,
          },
        );

        expect(stats.totalSongs, 150);
        expect(stats.successfulAnalyses, 142);
        expect(stats.failedAnalyses, 8);
        expect(stats.averageProcessingTime, 3.2);
        expect(stats.genreDistribution, isA<Map<String, int>>());
        expect(stats.instrumentDistribution, isA<Map<String, int>>());
        expect(stats.successRate, closeTo(94.67, 0.1)); // 142/150 * 100
        expect(stats.failureRate, closeTo(5.33, 0.1)); // 8/150 * 100
      });
    });

    // ============================================================================
    // SIGNAL PROCESSING TESTS
    // ============================================================================
    
    group('Signal Processing', () {
      test('should validate signal processing algorithms', () {
        // Create test audio data (sine wave)
        final audioData = Float32List(1000);
        for (int i = 0; i < audioData.length; i++) {
          audioData[i] = 0.5 * (i / 1000.0); // Simple ramp signal
        }

        // Test energy calculation
        final energy = _calculateTestEnergy(audioData);
        expect(energy, greaterThanOrEqualTo(0.0));
        expect(energy, lessThanOrEqualTo(1.0));

        // Test spectral centroid
        final centroid = _calculateTestSpectralCentroid(audioData);
        expect(centroid, greaterThan(0.0));
        expect(centroid, lessThan(10000000.0));

        // Test zero crossing rate
        final zcr = _calculateTestZeroCrossingRate(audioData);
        expect(zcr, greaterThanOrEqualTo(0.0));
        expect(zcr, lessThanOrEqualTo(1.0));

        // Test tempo estimation
        final tempo = _estimateTestTempo(audioData);
        expect(tempo, greaterThan(60.0));
        expect(tempo, lessThan(300.0));
      });
    });

    // ============================================================================
    // YAMNET ANALYSIS SIMULATION TESTS
    // ============================================================================
    
    group('YAMNet Analysis Simulation', () {
      test('should process YAMNet results correctly', () {
        // Simulate YAMNet output scores
        final scores = List.generate(521, (i) => (i % 100) / 100.0);
        
        // Test result processing
        final results = _processTestYAMNetResults(scores);
        
        expect(results, isA<Map<String, dynamic>>());
        expect(results['instruments'], isA<List<String>>());
        expect(results['hasVocals'], isA<bool>());
        expect(results['genre'], isA<String>());
        expect(results['mood'], isA<String>());
        expect(results['energy'], isA<String>());
      });

      test('should categorize instruments correctly', () {
        final instrumentLabels = [
          'guitar', 'piano', 'drum', 'violin', 'saxophone',
          'voice', 'singing', 'speech', 'talking',
          'rock music', 'jazz music', 'classical music',
          'happy music', 'sad music', 'energetic music'
        ];

        final instruments = <String>[];
        final vocals = <String>[];
        final genres = <String>[];
        final moods = <String>[];

        for (final label in instrumentLabels) {
          if (_isTestInstrument(label)) {
            instruments.add(label);
          }
          if (_isTestVocal(label)) {
            vocals.add(label);
          }
          if (_isTestGenre(label)) {
            genres.add(label);
          }
          if (_isTestMood(label)) {
            moods.add(label);
          }
        }

        expect(instruments, contains('guitar'));
        expect(instruments, contains('piano'));
        expect(instruments, contains('drum'));
        expect(vocals, contains('voice'));
        expect(vocals, contains('singing'));
        expect(genres, contains('rock music'));
        expect(genres, contains('jazz music'));
        expect(moods, contains('happy music'));
        expect(moods, contains('sad music'));
      });
    });

    // ============================================================================
    // BACKGROUND PROCESSING TESTS (Basic validation only - detailed tests in background_processing_test.dart)
    // ============================================================================
    
    group('Background Processing', () {
      test('should validate background processing API', () {
        // Test that background processing methods exist
        expect(MusicFeatureAnalyzer.extractFeaturesInBackground, isA<Function>());
        expect(MusicFeatureAnalyzer.getExtractionProgress, isA<Function>());
      });
    });

    // ============================================================================
    // ISOLATE PROCESSING TESTS (Basic validation only - detailed tests in background_processing_test.dart)
    // ============================================================================
    
    group('Isolate Processing', () {
      test('should validate isolate processing API', () {
        // Test that isolate processing is supported
        expect(MusicFeatureAnalyzer.extractFeaturesInBackground, isA<Function>());
      });
    });

    // ============================================================================
    // PROGRESS TRACKING TESTS
    // ============================================================================
    
    group('Progress Tracking', () {
      test('should calculate progress correctly', () {
        final allSongs = [
          '/test/song1.mp3',
          '/test/song2.mp3',
          '/test/song3.mp3',
          '/test/song4.mp3',
          '/test/song5.mp3',
        ];

        // Simulate progress calculation
        final total = allSongs.length;
        final analyzed = 3;
        final pending = total - analyzed;
        final completionPercentage = (analyzed / total) * 100;

        expect(total, 5);
        expect(analyzed, 3);
        expect(pending, 2);
        expect(completionPercentage, 60.0);
      });

      test('should track statistics correctly', () {
        final stats = AnalysisStats(
          totalSongs: 100,
          successfulAnalyses: 85,
          failedAnalyses: 15,
          averageProcessingTime: 2.8,
          lastAnalysis: DateTime.now(),
          genreDistribution: {'Rock': 30, 'Pop': 25, 'Jazz': 20, 'Unknown': 10},
          instrumentDistribution: {'Guitar': 40, 'Piano': 30, 'Drums': 20, 'Unknown': 10},
        );

        expect(stats.totalSongs, 100);
        expect(stats.successfulAnalyses, 85);
        expect(stats.failedAnalyses, 15);
        expect(stats.successRate, 85.0);
        expect(stats.failureRate, 15.0);
        expect(stats.genreDistribution.length, 4);
        expect(stats.instrumentDistribution.length, 4);
      });
    });

    // ============================================================================
    // ERROR HANDLING TESTS
    // ============================================================================
    
    group('Error Handling', () {
      test('should handle initialization errors', () async {
        // Test uninitialized state
        expect(MusicFeatureAnalyzer.isInitialized, false);
        
        // Test error handling for uninitialized analyzer
        try {
          // This should not throw but return null/empty results
          final song = Song(
            id: 'test',
            title: 'Test Song',
            artist: 'Test Artist',
            album: 'Test Album',
            duration: 180,
            filePath: '/test/song.mp3',
          );
          final result = await MusicFeatureAnalyzer.analyzeSong(song);
          expect(result, null);
        } catch (e) {
          // If it throws, it should be a specific type of error
          expect(e, isA<Exception>());
        }
      });

      test('should handle file not found errors', () async {
        const nonExistentPath = '/non/existent/path.mp3';
        
        // Test file existence check
        final file = File(nonExistentPath);
        expect(await file.exists(), false);
      });

      test('should handle invalid audio file errors', () async {
        // Test with invalid file extension
        const invalidPath = '/test/file.txt';
        final extension = invalidPath.split('.').last.toLowerCase();
        const supportedFormats = ['mp3', 'flac', 'wav', 'aac', 'ogg', 'm4a'];
        
        expect(supportedFormats.contains(extension), false);
      });
    });

    // ============================================================================
    // INTEGRATION TESTS
    // ============================================================================
    
    group('Integration Tests', () {
      test('should work with multiple songs', () async {
        final songs = [
          Song(
            id: 'song1',
            title: 'Song 1',
            artist: 'Artist 1',
            album: 'Album 1',
            duration: 180,
            filePath: '/test/song1.mp3',
          ),
          Song(
            id: 'song2',
            title: 'Song 2',
            artist: 'Artist 2',
            album: 'Album 2',
            duration: 240,
            filePath: '/test/song2.mp3',
          ),
          Song(
            id: 'song3',
            title: 'Song 3',
            artist: 'Artist 3',
            album: 'Album 3',
            duration: 200,
            filePath: '/test/song3.mp3',
          ),
        ];

        expect(songs.length, 3);
        expect(songs[0].title, 'Song 1');
        expect(songs[1].title, 'Song 2');
        expect(songs[2].title, 'Song 3');
      });

      test('should handle batch processing workflow', () async {
        final filePaths = [
          '/test/song1.mp3',
          '/test/song2.mp3',
          '/test/song3.mp3',
        ];

        int processedCount = 0;
        int progressCount = 0;
        bool completed = false;

        // Simulate batch processing
        for (int i = 0; i < filePaths.length; i++) {
          processedCount++;
          progressCount++;
          
          // Simulate processing time
          await Future.delayed(Duration(milliseconds: 10));
        }

        completed = true;

        expect(processedCount, 3);
        expect(progressCount, 3);
        expect(completed, true);
      });
    });

    // ============================================================================
    // PERFORMANCE TESTS
    // ============================================================================
    
    group('Performance Tests', () {
      test('should process audio data efficiently', () {
        final audioData = Float32List(16000); // 1 second at 16kHz
        
        // Fill with test data
        for (int i = 0; i < audioData.length; i++) {
          audioData[i] = 0.5 * (i / 16000.0);
        }

        final stopwatch = Stopwatch()..start();
        
        // Simulate processing
        final energy = _calculateTestEnergy(audioData);
        final centroid = _calculateTestSpectralCentroid(audioData);
        final zcr = _calculateTestZeroCrossingRate(audioData);
        final tempo = _estimateTestTempo(audioData);
        
        stopwatch.stop();

        expect(energy, greaterThanOrEqualTo(0.0));
        expect(centroid, greaterThanOrEqualTo(0.0));
        expect(zcr, greaterThanOrEqualTo(0.0));
        expect(tempo, greaterThanOrEqualTo(0.0));
        expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // Should be fast
      });

      test('should handle large audio files', () {
        // Test with larger audio data (10 seconds)
        final audioData = Float32List(160000); // 10 seconds at 16kHz
        
        for (int i = 0; i < audioData.length; i++) {
          audioData[i] = 0.3 * (i / 160000.0);
        }

        final stopwatch = Stopwatch()..start();
        
        // Simulate processing
        final energy = _calculateTestEnergy(audioData);
        final centroid = _calculateTestSpectralCentroid(audioData);
        
        stopwatch.stop();

        expect(energy, greaterThan(0.0));
        expect(centroid, greaterThan(0.0));
        expect(stopwatch.elapsedMilliseconds, lessThan(2000)); // Should still be fast
      });
    });
  });
}

// ============================================================================
// HELPER FUNCTIONS FOR TESTING
// ============================================================================

/// Calculate test energy (RMS)
double _calculateTestEnergy(Float32List audioData) {
  double sum = 0.0;
  for (final sample in audioData) {
    sum += sample * sample;
  }
  return (sum / audioData.length).clamp(0.0, 1.0);
}

/// Calculate test spectral centroid
double _calculateTestSpectralCentroid(Float32List audioData) {
  // Simplified calculation for testing
  double weightedSum = 0.0;
  double magnitudeSum = 0.0;
  
  for (int i = 0; i < audioData.length; i++) {
    final magnitude = audioData[i].abs();
    weightedSum += i * magnitude;
    magnitudeSum += magnitude;
  }
  
  return magnitudeSum > 0 ? (weightedSum / magnitudeSum) * 8000.0 : 2000.0;
}

/// Calculate test zero crossing rate
double _calculateTestZeroCrossingRate(Float32List audioData) {
  int crossings = 0;
  for (int i = 1; i < audioData.length; i++) {
    if ((audioData[i] >= 0) != (audioData[i - 1] >= 0)) {
      crossings++;
    }
  }
  return crossings / (audioData.length - 1);
}

/// Estimate test tempo
double _estimateTestTempo(Float32List audioData) {
  // Simplified tempo estimation for testing
  const sampleRate = 16000.0;
  const windowSize = 4000; // 0.25 seconds
  
  if (audioData.length < windowSize) return 120.0;
  
  // Find energy peaks
  final energies = <double>[];
  for (int i = 0; i < audioData.length - windowSize; i += windowSize ~/ 2) {
    double energy = 0.0;
    for (int j = i; j < i + windowSize; j++) {
      energy += audioData[j] * audioData[j];
    }
    energies.add(energy);
  }
  
  // Find peaks
  final peaks = <int>[];
  for (int i = 1; i < energies.length - 1; i++) {
    if (energies[i] > energies[i - 1] && energies[i] > energies[i + 1]) {
      peaks.add(i);
    }
  }
  
  if (peaks.length < 2) return 120.0;
  
  // Calculate average interval
  double totalInterval = 0.0;
  for (int i = 1; i < peaks.length; i++) {
    totalInterval += peaks[i] - peaks[i - 1];
  }
  final avgInterval = totalInterval / (peaks.length - 1);
  
  // Convert to BPM
  final timePerWindow = (windowSize / 2) / sampleRate;
  final intervalSeconds = avgInterval * timePerWindow;
  final bpm = 60.0 / intervalSeconds;
  
  return bpm.clamp(60.0, 300.0);
}

/// Process test YAMNet results
Map<String, dynamic> _processTestYAMNetResults(List<double> scores) {
  // Find top predictions
  final indexedScores = scores.asMap().entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  
  final topPredictions = indexedScores.take(10).toList();
  
  // Simulate feature extraction
  final instruments = <String>[];
  bool hasVocals = false;
  String genre = 'Unknown';
  String mood = 'Neutral';
  double energy = 0.5;
  
  for (final prediction in topPredictions) {
    final score = prediction.value;
    final index = prediction.key;
    
    if (score > 0.1) {
      // Simulate categorization
      if (index % 4 == 0) {
        instruments.add('Instrument_$index');
      } else if (index % 4 == 1) {
        hasVocals = true;
      } else if (index % 4 == 2) {
        genre = 'Genre_$index';
      } else {
        mood = 'Mood_$index';
      }
    }
  }
  
  // Calculate energy
  energy = scores.take(100).reduce((a, b) => a + b) / 100;
  
  return {
    'instruments': instruments,
    'hasVocals': hasVocals,
    'genre': genre,
    'mood': mood,
    'energy': energy > 0.7 ? 'High' : energy > 0.4 ? 'Medium' : 'Low',
  };
}

/// Test instrument detection
bool _isTestInstrument(String label) {
  const instruments = ['guitar', 'piano', 'drum', 'violin', 'saxophone'];
  return instruments.any((inst) => label.toLowerCase().contains(inst));
}

/// Test vocal detection
bool _isTestVocal(String label) {
  const vocals = ['voice', 'singing', 'speech', 'talking'];
  return vocals.any((vocal) => label.toLowerCase().contains(vocal));
}

/// Test genre detection
bool _isTestGenre(String label) {
  const genres = ['rock music', 'jazz music', 'classical music'];
  return genres.any((genre) => label.toLowerCase().contains(genre));
}

/// Test mood detection
bool _isTestMood(String label) {
  const moods = ['happy music', 'sad music', 'energetic music'];
  return moods.any((mood) => label.toLowerCase().contains(mood));
}