import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class LoggerService {
  static final LoggerService instance = LoggerService._internal();

  LoggerService._internal();

  Box<String>? _errorBox;

  Future<void> init() async {
    _errorBox = await Hive.openBox<String>('error_log');
  }

  void logError(Object error, StackTrace? stack, {String? context}) {
    if (_errorBox == null) return;

    final timestamp = DateTime.now().toIso8601String();
    final logEntry = {
      'timestamp': timestamp,
      'error': error.toString(),
      'stack': stack?.toString(),
      'context': context,
    };

    // Silent. No user-facing output.
    _errorBox!.put(timestamp, jsonEncode(logEntry));
  }
}
