/// Music Feature Analyzer Package
/// 
/// A comprehensive music feature analysis package that extracts detailed
/// musical features from audio files using YAMNet AI model and signal processing.
/// 
/// Features:
/// - AI-powered instrument detection
/// - Genre classification
/// - Mood analysis
/// - Tempo detection (BPM)
/// - Energy analysis
/// - Spectral features
/// - Vocal detection
/// 
/// Usage:
/// ```dart
/// import 'package:music_feature_analyzer/music_feature_analyzer.dart';
/// 
/// final analyzer = MusicFeatureAnalyzer();
/// await analyzer.initialize();
/// 
/// final features = await analyzer.analyzeSong('/path/to/song.mp3');
/// print('Genre: ${features.estimatedGenre}');
/// print('Tempo: ${features.tempoBpm} BPM');
/// print('Instruments: ${features.instruments}');
/// ```

library music_feature_analyzer;

export 'src/models/song_features.dart';
export 'src/models/song_model.dart';
export 'src/services/feature_extractor.dart';
export 'src/services/yamnet_helper.dart' hide YAMNetResults;
export 'src/services/signal_processor.dart' hide SignalProcessingResults;
export 'src/utils/audio_utils.dart';
export 'src/utils/math_utils.dart' hide Complex;
export 'src/music_feature_analyzer_base.dart';
