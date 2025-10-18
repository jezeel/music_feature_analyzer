// Test file to verify package usage without model files
// This demonstrates that users don't need model files in their project

import 'package:flutter/material.dart';
import 'package:music_feature_analyzer/music_feature_analyzer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // This should work without any model files in the consuming project
  final initialized = await MusicFeatureAnalyzer.initialize();
  
  if (initialized) {
    print('✅ Package initialized successfully!');
    print('✅ No model files needed in consuming project!');
  } else {
    print('❌ Package initialization failed');
  }
}

