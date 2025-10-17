import 'package:logger/logger.dart';

class AppLogger {
  final String context;
  final Logger _logger;
  
  static const bool _enableTraceLogs = false;
  static const bool _enableDebugLogs = true;
  static const bool _enableInfoLogs = true;
  static const bool _enableWarningLogs = true;
  static const bool _enableErrorLogs = true;
  static const bool _enableFatalLogs = true;

  AppLogger(this.context)
      : _logger = Logger(
          printer: PrettyPrinter(
            methodCount: 0,
            errorMethodCount: 8,
            lineLength: 80,
            colors: true,
            printEmojis: true,
            noBoxingByDefault: true,
          ),
          filter: ProductionFilter(),
        );

  // Configuration methods

  // Trace logs - 🔍 (for detailed debugging)
  void t(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    if (_enableTraceLogs) {
      _logger.t('[music_feature_analyzer] $context: $message', error: error, stackTrace: stackTrace);
    }
  }

  // Debug logs - 🐛 (for development debugging)
  void d(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    if (_enableDebugLogs) {
      _logger.d('[music_feature_analyzer] $context: $message', error: error, stackTrace: stackTrace);
    }
  }

  // Info logs - ℹ️ (for general information)
  void i(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    if (_enableInfoLogs) {
      _logger.i('[music_feature_analyzer] $context: $message', error: error, stackTrace: stackTrace);
    }
  }

  // Warning logs - ⚠️ (for potential issues)
  void w(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    if (_enableWarningLogs) {
      _logger.w('[music_feature_analyzer] $context: $message', error: error, stackTrace: stackTrace);
    }
  }

  // Error logs - ❌ (for actual errors)
  void e(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    if (_enableErrorLogs) {
      _logger.e('[music_feature_analyzer] $context: $message', error: error, stackTrace: stackTrace);
    }
  }

  // Fatal logs - 💥 (for critical errors)
  void f(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    if (_enableFatalLogs) {
      _logger.f('[music_feature_analyzer] $context: $message', error: error, stackTrace: stackTrace);
    }
  }
}
