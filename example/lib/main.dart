import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:music_feature_analyzer/music_feature_analyzer.dart';
import 'screens/home_screen.dart';
import 'utils/app_theme.dart';
import 'utils/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final logger = AppLogger('Main');
  logger.i('🎵 Music Feature Analyzer Example starting...');

  // Initialize Music Feature Analyzer (same as your main project)
  try {
    logger.i('🚀 Initializing Music Feature Analyzer...');
    final analyzerInitialized = await MusicFeatureAnalyzer.initialize();
    if (analyzerInitialized) {
      logger.i('✅ Music Feature Analyzer initialized successfully');
    } else {
      logger.w('⚠️ Music Feature Analyzer initialization failed - will retry later');
    }
  } catch (e) {
    logger.e('❌ Music Feature Analyzer initialization error: $e');
    // Continue anyway - will retry in home screen if needed
  }
  
  runApp(const MusicAnalyzerExampleApp());
}

class MusicAnalyzerExampleApp extends StatelessWidget {
  const MusicAnalyzerExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Music Feature Analyzer Example',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          home: const HomeScreen(),
        );
      },
    );
  }
}