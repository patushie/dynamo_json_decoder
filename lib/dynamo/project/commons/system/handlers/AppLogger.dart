import 'package:dynamo_json_decoder/dynamo/project/commons/system/entities/LogLevel.dart';
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
      _instance = new AppLogger._();
    }

    return _instance;
  }

  void log(String logData, {LogLevel logLevel = LogLevel.NONE}) {
    if(logLevel == LogLevel.TRACE) {
      _logger!.t(logData);
    } else if(logLevel == LogLevel.DEBUG) {
      _logger!.d(logData);
    } else if(logLevel == LogLevel.WARNING) {
      _logger!.w(logData);
    }else if(logLevel == LogLevel.ERROR) {
      _logger!.e(logData);
    } else {
      _logger!.i(logData);
    }
  }
}
