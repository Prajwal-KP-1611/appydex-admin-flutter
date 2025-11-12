/// Error mapping utility for normalizing backend and client errors
/// to user-friendly messages
library;

import 'package:dio/dio.dart';

/// Maps exceptions to user-friendly error messages
class ErrorMapper {
  /// Map any error to a user-friendly message
  static String mapErrorToMessage(Object error) {
    if (error is DioException) {
      return _mapDioError(error);
    }

    if (error is FormatException) {
      return 'Invalid data format received from server';
    }

    if (error is TypeError) {
      return 'Unexpected data structure received';
    }

    // Default fallback
    return error.toString();
  }

  /// Map Dio-specific errors
  static String _mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timed out. Please check your internet connection and try again.';

      case DioExceptionType.sendTimeout:
        return 'Request timed out. Please try again.';

      case DioExceptionType.receiveTimeout:
        return 'Server response timed out. Please try again.';

      case DioExceptionType.badCertificate:
        return 'Security certificate error. Please contact support.';

      case DioExceptionType.badResponse:
        return _mapBadResponse(error);

      case DioExceptionType.cancel:
        return 'Request was cancelled';

      case DioExceptionType.connectionError:
        return 'Cannot connect to server. Please check your internet connection.';

      case DioExceptionType.unknown:
        return _mapUnknownError(error);
    }
  }

  /// Map HTTP status code errors
  static String _mapBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    // Try to extract error message from response
    String? serverMessage;
    if (data is Map<String, dynamic>) {
      serverMessage =
          data['message'] as String? ??
          data['error'] as String? ??
          data['detail'] as String?;
    }

    // Return server message if available and reasonable
    if (serverMessage != null &&
        serverMessage.isNotEmpty &&
        serverMessage.length < 200) {
      return serverMessage;
    }

    // Fall back to status code mapping
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input and try again.';
      case 401:
        return 'Session expired. Please log in again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'Resource not found.';
      case 409:
        return 'Conflict detected. The resource may have been modified by another user.';
      case 422:
        return 'Validation failed. Please check your input.';
      case 429:
        return 'Too many requests. Please wait a moment and try again.';
      case 500:
        return 'Internal server error. Please try again later.';
      case 502:
        return 'Bad gateway. Please try again later.';
      case 503:
        return 'Service temporarily unavailable. Please try again later.';
      case 504:
        return 'Gateway timeout. Please try again later.';
      default:
        return 'Server error (${statusCode ?? "unknown"}). Please try again.';
    }
  }

  /// Map unknown Dio errors
  static String _mapUnknownError(DioException error) {
    if (error.error != null) {
      final errorObj = error.error!;

      if (errorObj.toString().contains('SocketException')) {
        return 'Network error. Please check your internet connection.';
      }

      if (errorObj.toString().contains('HandshakeException')) {
        return 'Secure connection failed. Please try again.';
      }

      if (errorObj.toString().contains('FormatException')) {
        return 'Invalid response format received from server.';
      }
    }

    return 'An unexpected error occurred. Please try again.';
  }

  /// Get a short error title for dialogs
  static String getErrorTitle(Object error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      switch (statusCode) {
        case 401:
          return 'Authentication Required';
        case 403:
          return 'Access Denied';
        case 404:
          return 'Not Found';
        case 409:
          return 'Conflict';
        case 422:
          return 'Validation Error';
        case 429:
          return 'Rate Limit Exceeded';
        case 500:
        case 502:
        case 503:
        case 504:
          return 'Server Error';
        default:
          return 'Error';
      }
    }

    return 'Error';
  }

  /// Check if error is retryable
  static bool isRetryable(Object error) {
    if (error is! DioException) return true;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        // Retry on server errors but not client errors
        return statusCode != null && statusCode >= 500;

      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
        return false;

      case DioExceptionType.unknown:
        // Retry on network-related unknown errors
        return error.error.toString().contains('SocketException') ||
            error.error.toString().contains('HandshakeException');
    }
  }

  /// Check if error requires re-authentication
  static bool requiresReAuth(Object error) {
    if (error is! DioException) return false;
    return error.response?.statusCode == 401;
  }

  /// Check if error is a permission issue
  static bool isPermissionError(Object error) {
    if (error is! DioException) return false;
    return error.response?.statusCode == 403;
  }
}
