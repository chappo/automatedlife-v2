/// Form validation utilities for common input types
class NWValidators {
  static const String _emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  /// Validates that a field is not empty
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  /// Validates email format
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    final trimmedValue = value.trim();
    if (!RegExp(_emailPattern).hasMatch(trimmedValue)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  /// Validates password with customizable requirements
  static String? password(
    String? value, {
    int minLength = 8,
    bool requireUppercase = false,
    bool requireLowercase = false,
    bool requireNumbers = false,
    bool requireSpecialChars = false,
  }) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < minLength) {
      return 'Password must be at least $minLength characters long';
    }

    if (requireUppercase && !value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (requireLowercase && !value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    if (requireNumbers && !value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    if (requireSpecialChars && !value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  /// Validates that passwords match
  static String? confirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != originalPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validates minimum length
  static String? minLength(String? value, int minLength, {String? fieldName}) {
    if (value == null || value.length < minLength) {
      return '${fieldName ?? 'This field'} must be at least $minLength characters long';
    }
    return null;
  }

  /// Validates maximum length
  static String? maxLength(String? value, int maxLength, {String? fieldName}) {
    if (value != null && value.length > maxLength) {
      return '${fieldName ?? 'This field'} must be no more than $maxLength characters long';
    }
    return null;
  }

  /// Validates phone number format (basic)
  static String? phoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    // Remove all non-digit characters for validation
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    
    if (digitsOnly.length < 10) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validates URL format
  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'URL is required';
    }

    try {
      final uri = Uri.parse(value.trim());
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        return 'Please enter a valid URL';
      }
    } catch (e) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  /// Combines multiple validators
  static String? Function(String?) combine(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) {
          return result;
        }
      }
      return null;
    };
  }

  /// Creates a validator for building subdomain format
  static String? buildingSubdomain(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    final trimmedValue = value.trim().toLowerCase();
    
    // Basic subdomain validation
    if (!RegExp(r'^[a-z0-9]([a-z0-9-]*[a-z0-9])?$').hasMatch(trimmedValue)) {
      return 'Building subdomain can only contain letters, numbers, and hyphens';
    }

    if (trimmedValue.length < 3) {
      return 'Building subdomain must be at least 3 characters long';
    }

    if (trimmedValue.length > 63) {
      return 'Building subdomain must be no more than 63 characters long';
    }

    return null;
  }
}