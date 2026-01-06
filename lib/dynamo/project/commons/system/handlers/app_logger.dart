import 'package:dynamo_json_decoder/dynamo/project/commons/system/entities/log_level.dart';
import 'package:logger/logger.dart';

/// A utility class for handling application-wide logging.
class AppLogger {
  static Logger? _logger;
  static AppLogger? _instance;

  AppLogger._() {
    _logger = Logger(
      printer: PrettyPrinter(),
    );
  }

  /// Returns the singleton instance of [AppLogger].
  static AppLogger getInstance() {
    _instance ??= AppLogger._();

    return _instance!;
  }

  /// Outputs [logData] to the console, categorized by the provided [logLevel].
  ///
  /// If [logLevel] is not specified, it defaults to [LogLevel.none]
  /// - which in turn defaults to [LogLevel.info].
  void log(String logData, {LogLevel logLevel = LogLevel.none}) {
    if (logLevel == LogLevel.trace) {
      _logger!.t(logData);
    } else if (logLevel == LogLevel.debug) {
      _logger!.d(logData);
    } else if (logLevel == LogLevel.warning) {
      _logger!.w(logData);
    } else if (logLevel == LogLevel.error) {
      _logger!.e(logData);
    } else {
      _logger!.i(logData);
    }
  }
}
