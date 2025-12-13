
import 'package:flutter/foundation.dart';


/// Simple logging service for debugging
/// In production, this could integrate with Firebase Crashlytics or similar
class LoggerService {
  LoggerService._();

  static const String _tag = 'MUSIKITA';

  /// Log info message
  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      print('[$_tag${tag != null ? ':$tag' : ''}] ℹ️ $message');
    }
  }

  /// Log warning message
  static void warning(String message, {String? tag}) {
    if (kDebugMode) {
      print('[$_tag${tag != null ? ':$tag' : ''}] ⚠️ $message');
    }
  }

  /// Log error message with optional exception and stack trace
  static void error(
      String message, {
        String? tag,
        dynamic exception,
        StackTrace? stackTrace,
      }) {
    if (kDebugMode) {
      print('[$_tag${tag != null ? ':$tag' : ''}] ❌ $message');
      if (exception != null) {
        print('Exception: $exception');
      }
      if (stackTrace != null) {
        print('Stack trace: $stackTrace');
      }
    }

    // TODO: In production, send to Firebase Crashlytics
    // FirebaseCrashlytics.instance.recordError(exception, stackTrace);
  }

  /// Log debug message (only in debug mode)
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      print('[$_tag${tag != null ? ':$tag' : ''}] 🐛 $message');
    }
  }

  /// Log success message
  static void success(String message, {String? tag}) {
    if (kDebugMode) {
      print('[$_tag${tag != null ? ':$tag' : ''}] ✅ $message');
    }
  }
}