import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';
import '../constants/app_limits.dart';
import '../constants/error_messages.dart';
import '../exceptions/app_exception.dart';
import '../exceptions/firebase_exceptions.dart';
import 'logger_service.dart';

/// Centralized error handling service
class ErrorHandlerService {
  ErrorHandlerService._();

  /// Handle any exception and show appropriate user feedback
  static void handleError(
      BuildContext context,
      dynamic error, {
        String? customMessage,
        StackTrace? stackTrace,
        String? tag,
      }) {
    // Log the error
    LoggerService.error(
      customMessage ?? 'An error occurred',
      tag: tag,
      exception: error,
      stackTrace: stackTrace,
    );

    // Convert error to AppException
    final AppException appException = _convertToAppException(error);

    // Show user feedback
    _showErrorSnackbar(
      context,
      customMessage ?? appException.message,
    );
  }

  /// Convert any error to AppException
  static AppException _convertToAppException(dynamic error) {
    if (error is AppException) {
      return error;
    }

    if (error is FirebaseAuthException) {
      return FirebaseExceptionHandler.handleAuthException(error);
    }

    if (error is FirebaseException) {
      // Check if it's a Storage exception
      if (error.plugin == 'firebase_storage') {
        return FirebaseExceptionHandler.handleStorageException(error);
      }
      // Otherwise treat as Firestore
      return FirebaseExceptionHandler.handleFirestoreException(error);
    }

    // Generic unknown error
    return AppException(
      ErrorMessages.genericUnknown,
      originalException: error,
    );
  }

  /// Show error snackbar
  static void _showErrorSnackbar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        duration: Duration(seconds:AppLimits.errorSnackbarDurationSeconds),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show success snackbar
  static void showSuccess(BuildContext context, String message) {
    if (!context.mounted) return;

    LoggerService.success(message);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: AppColors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: Duration(seconds:AppLimits.successSnackbarDurationSeconds),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show info snackbar
  static void showInfo(BuildContext context, String message) {
    if (!context.mounted) return;

    LoggerService.info(message);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: AppColors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds:AppLimits.snackbarDurationSeconds),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show warning snackbar
  static void showWarning(BuildContext context, String message) {
    if (!context.mounted) return;

    LoggerService.warning(message);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.warning,
              color: AppColors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: AppLimits.snackbarDurationSeconds),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Execute a function with error handling
  static Future<T?> execute<T>(
      BuildContext context,
      Future<T> Function() function, {
        String? errorMessage,
        String? tag,
        bool showLoading = false,
      }) async {
    try {
      return await function();
    } catch (e, stackTrace) {
      handleError(
        context,
        e,
        customMessage: errorMessage,
        stackTrace: stackTrace,
        tag: tag,
      );
      return null;
    }
  }
}