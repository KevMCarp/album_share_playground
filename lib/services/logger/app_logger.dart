import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../core/utils/extension_methods.dart';
import '../../models/log.dart';
import '../database/database_service.dart';

class AppLogger {
  static AppLogger? _instance;

  static AppLogger get instance => _instance ??= AppLogger._();

  AppLogger._() : _db = DatabaseService.instance {
    _truncateLogs();
    Logger.root.onRecord.listen(_writeLog);
  }

  static const maxEntries = 500;

  final DatabaseService _db;

  List<Log> _logBuffer = [];

  Timer? _timer;

  void _writeLog(LogRecord record) {
    if (kDebugMode) {
      print('$record  ${record.error ?? ''}');
    }
    _logBuffer.add(Log.fromRecord(record));
    _timer?.cancel();
    _timer ??= Timer(5.seconds, flush);
  }

  void flush() {
    _timer?.cancel();
    final logs = _logBuffer;
    _logBuffer = [];
    _db.addLogsSync(logs);
  }

  void _truncateLogs() {
    final overflow = _db.logCount() - maxEntries;
    if (overflow > 0) {
      _db.deleteLogs(overflow);
    }
  }

  String formatted() {
    flush();
    final logs = _db.getLogsSync();

    final sb = StringBuffer();

    for (final log in logs) {
      sb.writeln(log.format());
    }

    return sb.toString();
  }

  void clear() {
    _logBuffer.clear();
    _db.clearLogs();
  }
}
