import 'dart:convert';

/// User model representing the authenticated user in FinTrack
/// Contains all user profile information, authentication settings, and preferences
class UserModel {
  /// Unique identifier for the user (UUID format)
  final String id;

  /// User's email address (unique, used for authentication)
  final String email;

  /// User's full name
  final String? fullName;

  /// URL to user's avatar image
  final String? avatarUrl;

  /// User's phone number
  final String? phoneNumber;

  /// User's date of birth
  final DateTime? dateOfBirth;

  /// User's timezone (IANA format, e.g., 'Asia/Jakarta')
  final String timezone;

  /// User's locale/language code (e.g., 'id', 'en')
  final String locale;

  /// App theme preference ('light', 'dark', 'system')
  final String theme;

  /// Whether email has been verified
  final bool emailVerified;

  /// Timestamp when email was verified
  final DateTime? emailVerifiedAt;

  /// Whether the user account is active
  final bool isActive;

  /// Whether the user has premium subscription
  final bool isPremium;

  /// Premium subscription expiration timestamp
  final DateTime? premiumExpiresAt;

  /// Whether PIN protection is enabled
  final bool pinEnabled;

  /// Whether biometric authentication is enabled
  final bool biometricEnabled;

  /// User's preferred currency code (ISO 4217, e.g., 'IDR')
  final String currencyCode;

  /// User's preferred currency symbol (e.g., 'Rp')
  final String currencySymbol;

  /// Date format preference (e.g., 'DD/MM/YYYY')
  final String dateFormat;

  /// First day of week (0=Sunday, 1=Monday)
  final int firstDayOfWeek;

  /// Default account ID for new transactions
  final String? defaultAccountId;

  /// Default account name for display purposes
  final String? defaultAccountName;

  /// Social login provider ('email', 'google', 'apple', null)
  final String? authProvider;

  /// Timestamp of user's last login
  final DateTime? lastLoginAt;

  /// Account creation timestamp
  final DateTime createdAt;

  /// Last update timestamp
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.phoneNumber,
    this.dateOfBirth,
    this.timezone = 'Asia/Jakarta',
    this.locale = 'id',
    this.theme = 'light',
    this.emailVerified = false,
    this.emailVerifiedAt,
    this.isActive = true,
    this.isPremium = false,
    this.premiumExpiresAt,
    this.pinEnabled = false,
    this.biometricEnabled = false,
    this.currencyCode = 'IDR',
    this.currencySymbol = 'Rp',
    this.dateFormat = 'DD/MM/YYYY',
    this.firstDayOfWeek = 1,
    this.defaultAccountId,
    this.defaultAccountName,
    this.authProvider,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get the user's display name (full name or email if name not set)
  String get displayName => fullName ?? email.split('@').first;

  /// Check if user has verified their email
  bool get hasVerifiedEmail => emailVerified;

  /// Check if premium subscription is active
  bool get hasActivePremium {
    if (!isPremium) return false;
    if (premiumExpiresAt == null) return true;
    return premiumExpiresAt!.isAfter(DateTime.now());
  }

  /// Get user initials for avatar placeholder
  String get initials {
    if (fullName == null || fullName!.isEmpty) {
      return email.substring(0, 1).toUpperCase();
    }
    final parts = fullName!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first.substring(0, parts.first.length.clamp(0, 2)).toUpperCase();
  }

  /// Create UserModel from JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String? ?? json['name'] as String?,
      avatarUrl: json['avatar_url'] as String? ?? json['avatarUrl'] as String?,
      phoneNumber: json['phone_number'] as String? ?? json['phoneNumber'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'] as String)
          : null,
      timezone: json['timezone'] as String? ?? 'Asia/Jakarta',
      locale: json['locale'] as String? ?? 'id',
      theme: json['theme'] as String? ?? 'light',
      emailVerified: json['email_verified'] as bool? ?? json['emailVerified'] as bool? ?? false,
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.tryParse(json['email_verified_at'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? json['isActive'] as bool? ?? true,
      isPremium: json['is_premium'] as bool? ?? json['isPremium'] as bool? ?? false,
      premiumExpiresAt: json['premium_expires_at'] != null
          ? DateTime.tryParse(json['premium_expires_at'] as String)
          : null,
      pinEnabled: json['pin_enabled'] as bool? ?? json['pinEnabled'] as bool? ?? false,
      biometricEnabled: json['biometric_enabled'] as bool? ??
          json['biometricEnabled'] as bool? ?? false,
      currencyCode: json['currency_code'] as String? ??
          json['currencyCode'] as String? ??
          'IDR',
      currencySymbol: json['currency_symbol'] as String? ??
          json['currencySymbol'] as String? ??
          'Rp',
      dateFormat: json['date_format'] as String? ?? json['dateFormat'] as String? ?? 'DD/MM/YYYY',
      firstDayOfWeek: json['first_day_of_week'] as int? ??
          json['firstDayOfWeek'] as int? ??
          1,
      defaultAccountId: json['default_account_id'] as String? ??
          json['defaultAccountId'] as String?,
      defaultAccountName: json['default_account_name'] as String? ??
          json['defaultAccountName'] as String?,
      authProvider: json['auth_provider'] as String? ?? json['authProvider'] as String?,
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.tryParse(json['last_login_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  /// Create UserModel from JSON string
  factory UserModel.fromJsonString(String jsonString) {
    return UserModel.fromJson(json.decode(jsonString) as Map<String, dynamic>);
  }

  /// Convert UserModel to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'phone_number': phoneNumber,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'timezone': timezone,
      'locale': locale,
      'theme': theme,
      'email_verified': emailVerified,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'is_active': isActive,
      'is_premium': isPremium,
      'premium_expires_at': premiumExpiresAt?.toIso8601String(),
      'pin_enabled': pinEnabled,
      'biometric_enabled': biometricEnabled,
      'currency_code': currencyCode,
      'currency_symbol': currencySymbol,
      'date_format': dateFormat,
      'first_day_of_week': firstDayOfWeek,
      'default_account_id': defaultAccountId,
      'default_account_name': defaultAccountName,
      'auth_provider': authProvider,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert UserModel to JSON string
  String toJsonString() {
    return json.encode(toJson());
  }

  /// Create a copy of UserModel with optional field overrides
  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? timezone,
    String? locale,
    String? theme,
    bool? emailVerified,
    DateTime? emailVerifiedAt,
    bool? isActive,
    bool? isPremium,
    DateTime? premiumExpiresAt,
    bool? pinEnabled,
    bool? biometricEnabled,
    String? currencyCode,
    String? currencySymbol,
    String? dateFormat,
    int? firstDayOfWeek,
    String? defaultAccountId,
    String? defaultAccountName,
    String? authProvider,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    // Nullable field setters for explicit null assignment
    bool clearFullName = false,
    bool clearAvatarUrl = false,
    bool clearPhoneNumber = false,
    bool clearDateOfBirth = false,
    bool clearEmailVerifiedAt = false,
    bool clearPremiumExpiresAt = false,
    bool clearDefaultAccountId = false,
    bool clearDefaultAccountName = false,
    bool clearAuthProvider = false,
    bool clearLastLoginAt = false,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: clearFullName ? null : (fullName ?? this.fullName),
      avatarUrl: clearAvatarUrl ? null : (avatarUrl ?? this.avatarUrl),
      phoneNumber: clearPhoneNumber ? null : (phoneNumber ?? this.phoneNumber),
      dateOfBirth: clearDateOfBirth ? null : (dateOfBirth ?? this.dateOfBirth),
      timezone: timezone ?? this.timezone,
      locale: locale ?? this.locale,
      theme: theme ?? this.theme,
      emailVerified: emailVerified ?? this.emailVerified,
      emailVerifiedAt: clearEmailVerifiedAt
          ? null
          : (emailVerifiedAt ?? this.emailVerifiedAt),
      isActive: isActive ?? this.isActive,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiresAt: clearPremiumExpiresAt
          ? null
          : (premiumExpiresAt ?? this.premiumExpiresAt),
      pinEnabled: pinEnabled ?? this.pinEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      dateFormat: dateFormat ?? this.dateFormat,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
      defaultAccountId: clearDefaultAccountId
          ? null
          : (defaultAccountId ?? this.defaultAccountId),
      defaultAccountName: clearDefaultAccountName
          ? null
          : (defaultAccountName ?? this.defaultAccountName),
      authProvider: clearAuthProvider ? null : (authProvider ?? this.authProvider),
      lastLoginAt: clearLastLoginAt ? null : (lastLoginAt ?? this.lastLoginAt),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, fullName: $fullName, isPremium: $isPremium)';
  }
}

/// Extension for UserModel to handle API response parsing
extension UserModelParsing on UserModel {
  /// Parse user from API response data
  static UserModel? tryFromApiResponse(Map<String, dynamic>? response) {
    if (response == null) return null;
    if (response.containsKey('user')) {
      return UserModel.fromJson(response['user'] as Map<String, dynamic>);
    }
    if (response.containsKey('data')) {
      final data = response['data'];
      if (data is Map<String, dynamic>) {
        return UserModel.fromJson(data);
      }
    }
    return UserModel.fromJson(response);
  }
}
