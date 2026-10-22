import 'package:logger/logger.dart';

/// SS-prefixed logging facade.
class SSLogger {
  SSLogger._();

  static Logger? _logger;

  static void init({Level level = Level.info}) {
    _logger = Logger(
      printer: PrettyPrinter(methodCount: 0, lineLength: 80),
      level: level,
    );
  }

  static Logger get _log {
    _logger ??= Logger(
      printer: PrettyPrinter(methodCount: 0),
      level: Level.info,
    );
    return _logger!;
  }

  static void d(Object? message, [Object? error, StackTrace? stackTrace]) {
    _log.d(message, error: error, stackTrace: stackTrace);
  }

  static void i(Object? message, [Object? error, StackTrace? stackTrace]) {
    _log.i(message, error: error, stackTrace: stackTrace);
  }

  static void w(Object? message, [Object? error, StackTrace? stackTrace]) {
    _log.w(message, error: error, stackTrace: stackTrace);
  }

  static void e(Object? message, [Object? error, StackTrace? stackTrace]) {
    _log.e(message, error: error, stackTrace: stackTrace);
  }
}
