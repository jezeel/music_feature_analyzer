import 'package:logger/logger.dart';

class AppLogger {
  final String context;
  late final Logger _logger;

  AppLogger(this.context) {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      filter: ProductionFilter(),
    );
  }

  void t(String message) {
    _logger.t('[$context] $message');
  }

  void d(String message) {
    _logger.d('[$context] $message');
  }

  void i(String message) {
    _logger.i('[$context] $message');
  }

  void w(String message) {
    _logger.w('[$context] $message');
  }

  void e(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.e('[$context] $message', error: error, stackTrace: stackTrace);
  }

  void f(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.f('[$context] $message', error: error, stackTrace: stackTrace);
  }

}