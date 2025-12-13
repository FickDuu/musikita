/// Base exception class for all app exceptions
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;
  final StackTrace? stackTrace;

  AppException(
      this.message, {
        this.code,
        this.originalException,
        this.stackTrace,
      });

  @override
  String toString() {
    if (code != null) {
      return 'AppException[$code]: $message';
    }
    return 'AppException: $message';
  }
}

/// Authentication related exceptions
class AuthException extends AppException {
  AuthException(
      super.message, {
        super.code,
        super.originalException,
        super.stackTrace,
      });
}

/// Profile related exceptions
class ProfileException extends AppException {
  ProfileException(
      super.message, {
        super.code,
        super.originalException,
        super.stackTrace,
      });
}

/// Event related exceptions
class EventException extends AppException {
  EventException(
      super.message, {
        super.code,
        super.originalException,
        super.stackTrace,
      });
}

/// Music related exceptions
class MusicException extends AppException {
  MusicException(
      super.message, {
        super.code,
        super.originalException,
        super.stackTrace,
      });
}

/// Messaging related exceptions
class MessagingException extends AppException {
  MessagingException(
      super.message, {
        super.code,
        super.originalException,
        super.stackTrace,
      });
}

/// Network related exceptions
class NetworkException extends AppException {
  NetworkException(
      super.message, {
        super.code,
        super.originalException,
        super.stackTrace,
      });
}

/// File upload/download exceptions
class FileException extends AppException {
  FileException(
      super.message, {
        super.code,
        super.originalException,
        super.stackTrace,
      });
}

/// Validation exceptions
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  ValidationException(
      super.message, {
        this.fieldErrors,
        super.code,
        super.originalException,
        super.stackTrace,
      });
}