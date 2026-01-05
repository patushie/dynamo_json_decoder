import 'package:dynamo_json_decoder/dynamo/project/commons/system/entities/log_level.dart';
import 'package:logger/logger.dart';

class AppLogger {
  static Logger? _logger;
  static var _instance;

  AppLogger._() {
    _logger = Logger(
      printer: PrettyPrinter(),
    );
  }

  static AppLogger getInstance() {
    if (_instance == null) {
      _instance = AppLogger._();
    }

    return _instance;
  }

  void log(String logData, {LogLevel logLevel = LogLevel.none}) {
    if(logLevel == LogLevel.trace) {
      _logger!.t(logData);
    } else if(logLevel == LogLevel.debug) {
      _logger!.d(logData);
    } else if(logLevel == LogLevel.warning) {
      _logger!.w(logData);
    }else if(logLevel == LogLevel.error) {
      _logger!.e(logData);
    } else {
      _logger!.i(logData);
    }
  }
}
