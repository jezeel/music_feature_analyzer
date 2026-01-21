/// Music Feature Analyzer Package
/// 
/// A comprehensive music feature analysis package that extracts detailed
/// musical features and metadata from audio files using YAMNet AI model and signal processing.
/// 
/// **Platform Support**: This package supports Android and iOS only.
/// Desktop (Windows, Linux, macOS) and Web platforms are not supported.
/// 
/// Features:
/// - AI-powered instrument detection
/// - Genre classification
/// - Mood analysis
/// - Tempo detection (BPM)
/// - Energy analysis
/// - Spectral features
/// - Vocal detection
/// - Complete metadata extraction (title, artist, album, album art, etc.)
/// 
/// Usage:
/// ```dart
/// import 'package:music_feature_analyzer/music_feature_analyzer.dart';
/// 
/// // Initialize
/// await MusicFeatureAnalyzer.initialize();
/// 
/// // Extract metadata
/// final song = await MusicFeatureAnalyzer.metadata('/path/to/song.mp3');
/// print('Title: ${song.title}');
/// print('Artist: ${song.artist}');
/// print('Album: ${song.album}');
/// 
/// // Extract features
/// final features = await MusicFeatureAnalyzer.analyzeSong(song);
/// print('Genre: ${features.estimatedGenre}');
/// print('Tempo: ${features.tempoBpm} BPM');
/// print('Instruments: ${features.instruments}');
/// ```

library music_feature_analyzer;

export 'src/models/extracted_song_features.dart';
export 'src/models/song_model.dart';
export 'src/services/feature_extractor.dart' hide AnalysisStats;
export 'src/music_feature_analyzer_base.dart';
