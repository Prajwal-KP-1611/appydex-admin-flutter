import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api_client.dart';

/// Repository for OTP (One-Time Password) operations
/// Handles OTP request for two-step authentication
class OtpRepository {
  OtpRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// Request OTP for email or phone (ADMIN)
  /// POST /api/v1/admin/auth/request-otp
  ///
  /// Request: { "email_or_phone": "admin@example.com" } or { "email_or_phone": "+1234567890" }
  /// Response: { "message": "...", "otp_sent": { "email": true, "otp_email": "000000" }, "requires_password": true }
  ///
  /// Note: This endpoint does not require authentication (skipAuth: true)
  /// Backend accepts unified "email_or_phone" field
  Future<OtpRequestResult> requestOtp({required String emailOrPhone}) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/admin/auth/request-otp',
        data: {
          'email_or_phone': emailOrPhone,
        }, // Backend expects 'email_or_phone' field
        options: Options(
          extra: {'skipAuth': true},
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final data = response.data ?? {};
      return OtpRequestResult.fromJson(data);
    } on DioException catch (error) {
      // Extract error message from response if available
      final errorMessage =
          error.response?.data?['message'] as String? ??
          error.response?.data?['detail'] as String? ??
          'Failed to request OTP. Please try again.';

      throw OtpException(
        message: errorMessage,
        statusCode: error.response?.statusCode,
      );
    } catch (error) {
      throw OtpException(
        message: 'Network error. Please check your connection.',
      );
    }
  }
}

/// Result of OTP request operation
class OtpRequestResult {
  const OtpRequestResult({required this.message, this.success = true});

  final String message;
  final bool success;

  factory OtpRequestResult.fromJson(Map<String, dynamic> json) {
    // Admin backend returns:
    // {
    //   "message": "OTP sent successfully",
    //   "otp_sent": { "email": true, "otp_email": "000000" },
    //   "requires_password": true
    // }
    final message = json['message'] as String?;
    final otpSent = json['otp_sent'] as Map<String, dynamic>?;
    final otpEmail = otpSent?['otp_email'] as String?;
    final otpPhone = otpSent?['otp_phone'] as String?;

    // Build user-friendly message
    String displayMessage = message ?? 'OTP sent successfully';
    if (otpEmail != null) {
      displayMessage +=
          '\n\n✅ Email OTP: $otpEmail\n\nFor testing, use this OTP code.';
    } else if (otpPhone != null) {
      displayMessage +=
          '\n\n✅ Phone OTP: $otpPhone\n\nFor testing, use this OTP code.';
    } else {
      displayMessage += '\n\nPlease check your email/phone for the OTP code.';
    }

    return OtpRequestResult(message: displayMessage, success: message != null);
  }
}

/// Exception thrown when OTP operations fail
class OtpException implements Exception {
  OtpException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() =>
      'OtpException: $message (Status: ${statusCode ?? 'N/A'})';
}

final otpRepositoryProvider = Provider<OtpRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return OtpRepository(apiClient: apiClient);
});
