/// Form validators for admin panel inputs
library;

class Validators {
  const Validators._();

  /// Email validation
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Password validation (minimum requirements)
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  /// Required field validation
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  /// Minimum length validation
  static String? minLength(String? value, int length, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    if (value.length < length) {
      return '${fieldName ?? 'This field'} must be at least $length characters';
    }

    return null;
  }

  /// Maximum length validation
  static String? maxLength(String? value, int length, {String? fieldName}) {
    if (value != null && value.length > length) {
      return '${fieldName ?? 'This field'} must not exceed $length characters';
    }
    return null;
  }

  /// Numeric validation
  static String? numeric(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    if (double.tryParse(value) == null) {
      return '${fieldName ?? 'This field'} must be a valid number';
    }

    return null;
  }

  /// URL validation
  static String? url(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'URL'} is required';
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  /// Phone number validation (basic)
  static String? phone(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Phone number'} is required';
    }

    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');

    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }

    if (value.replaceAll(RegExp(r'\D'), '').length < 10) {
      return 'Phone number must be at least 10 digits';
    }

    return null;
  }

  /// Confirm password validation
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Combine multiple validators
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}
