import 'dart:convert';

/// User model representing a FinTrack user account
/// 
/// This model contains all user-related data including authentication,
/// profile information, security settings, and preferences.
class UserModel {
  /// Unique identifier for the user
  final String id;

  /// User's email address (unique)
  final String email;

  /// User's full name
  final String fullName;

  /// URL to user's avatar image
  final String? avatarUrl;

  /// User's phone number
  final String? phoneNumber;

  /// User's date of birth
  final DateTime? dateOfBirth;

  /// Whether biometric authentication is enabled
  final bool biometricEnabled;

  /// User's timezone preference (IANA format, e.g., 'Asia/Jakarta')
  final String timezone;

  /// User's locale preference (e.g., 'id_ID', 'en_US')
  final String locale;

  /// User's theme preference ('light', 'dark', 'system')
  final String theme;

  /// Whether email has been verified
  final bool emailVerified;

  /// Timestamp when email was verified
  final DateTime? emailVerifiedAt;

  /// Whether the user account is active
  final bool isActive;

  /// Whether the user has premium subscription
  final bool isPremium;

  /// Premium subscription expiration date
  final DateTime? premiumExpiresAt;

  /// Last login timestamp
  final DateTime? lastLoginAt;

  /// Account creation timestamp
  final DateTime createdAt;

  /// Last update timestamp
  final DateTime updatedAt;

  /// Soft delete timestamp (null if not deleted)
  final DateTime? deletedAt;

  /// List of authentication providers linked to this user
  final List<AuthProviderModel> authProviders;

  /// User's application settings
  final UserSettingsModel settings;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    this.phoneNumber,
    this.dateOfBirth,
    this.biometricEnabled = false,
    this.timezone = 'Asia/Jakarta',
    this.locale = 'id_ID',
    this.theme = 'light',
    this.emailVerified = false,
    this.emailVerifiedAt,
    this.isActive = true,
    this.isPremium = false,
    this.premiumExpiresAt,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.authProviders = const [],
    required this.settings,
  });

  /// Creates a UserModel from a JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String? ?? json['fullName'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? json['avatarUrl'] as String?,
      phoneNumber: json['phone_number'] as String? ?? json['phoneNumber'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : json['dateOfBirth'] != null
              ? DateTime.parse(json['dateOfBirth'] as String)
              : null,
      biometricEnabled: json['biometric_enabled'] as bool? ??
          json['biometricEnabled'] as bool? ??
          false,
      timezone: json['timezone'] as String? ?? 'Asia/Jakarta',
      locale: json['locale'] as String? ?? 'id_ID',
      theme: json['theme'] as String? ?? 'light',
      emailVerified: json['email_verified'] as bool? ??
          json['emailVerified'] as bool? ??
          false,
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'] as String)
          : json['emailVerifiedAt'] != null
              ? DateTime.parse(json['emailVerifiedAt'] as String)
              : null,
      isActive: json['is_active'] as bool? ?? json['isActive'] as bool? ?? true,
      isPremium: json['is_premium'] as bool? ?? json['isPremium'] as bool? ?? false,
      premiumExpiresAt: json['premium_expires_at'] != null
          ? DateTime.parse(json['premium_expires_at'] as String)
          : json['premiumExpiresAt'] != null
              ? DateTime.parse(json['premiumExpiresAt'] as String)
              : null,
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : json['lastLoginAt'] != null
              ? DateTime.parse(json['lastLoginAt'] as String)
              : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : DateTime.now(),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : json['deletedAt'] != null
              ? DateTime.parse(json['deletedAt'] as String)
              : null,
      authProviders: json['auth_providers'] != null
          ? (json['auth_providers'] as List<dynamic>)
              .map((e) => AuthProviderModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : json['authProviders'] != null
              ? (json['authProviders'] as List<dynamic>)
                  .map((e) => AuthProviderModel.fromJson(e as Map<String, dynamic>))
                  .toList()
              : const [],
      settings: json['settings'] != null
          ? UserSettingsModel.fromJson(
              json['settings'] is String
                  ? jsonDecode(json['settings'] as String) as Map<String, dynamic>
                  : json['settings'] as Map<String, dynamic>,
            )
          : const UserSettingsModel(),
    );
  }

  /// Creates a UserModel from JSON string
  factory UserModel.fromJsonString(String jsonString) {
    return UserModel.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  /// Converts this UserModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'phone_number': phoneNumber,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'biometric_enabled': biometricEnabled,
      'timezone': timezone,
      'locale': locale,
      'theme': theme,
      'email_verified': emailVerified,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'is_active': isActive,
      'is_premium': isPremium,
      'premium_expires_at': premiumExpiresAt?.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'auth_providers': authProviders.map((e) => e.toJson()).toList(),
      'settings': settings.toJson(),
    };
  }

  /// Converts this UserModel to a JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Creates a copy of this UserModel with the given fields replaced
  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? phoneNumber,
    DateTime? dateOfBirth,
    bool? biometricEnabled,
    String? timezone,
    String? locale,
    String? theme,
    bool? emailVerified,
    DateTime? emailVerifiedAt,
    bool? isActive,
    bool? isPremium,
    DateTime? premiumExpiresAt,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    List<AuthProviderModel>? authProviders,
    UserSettingsModel? settings,
    bool clearAvatarUrl = false,
    bool clearPhoneNumber = false,
    bool clearDateOfBirth = false,
    bool clearEmailVerifiedAt = false,
    bool clearPremiumExpiresAt = false,
    bool clearLastLoginAt = false,
    bool clearDeletedAt = false,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: clearAvatarUrl ? null : (avatarUrl ?? this.avatarUrl),
      phoneNumber: clearPhoneNumber ? null : (phoneNumber ?? this.phoneNumber),
      dateOfBirth: clearDateOfBirth ? null : (dateOfBirth ?? this.dateOfBirth),
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      timezone: timezone ?? this.timezone,
      locale: locale ?? this.locale,
      theme: theme ?? this.theme,
      emailVerified: emailVerified ?? this.emailVerified,
      emailVerifiedAt:
          clearEmailVerifiedAt ? null : (emailVerifiedAt ?? this.emailVerifiedAt),
      isActive: isActive ?? this.isActive,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiresAt:
          clearPremiumExpiresAt ? null : (premiumExpiresAt ?? this.premiumExpiresAt),
      lastLoginAt: clearLastLoginAt ? null : (lastLoginAt ?? this.lastLoginAt),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
      authProviders: authProviders ?? this.authProviders,
      settings: settings ?? this.settings,
    );
  }

  /// Returns the user's display name (full name or email prefix)
  String get displayName {
    if (fullName.isNotEmpty) return fullName;
    return email.split('@').first;
  }

  /// Returns initials from the user's full name
  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  /// Checks if the user has a premium subscription that's still valid
  bool get hasActivePremium {
    if (!isPremium) return false;
    if (premiumExpiresAt == null) return true;
    return premiumExpiresAt!.isAfter(DateTime.now());
  }

  /// Checks if the user has set up biometric authentication
  bool get hasBiometricSetup => biometricEnabled;

  /// Checks if the user has verified their email
  bool get hasVerifiedEmail => emailVerified;

  /// Returns the primary auth provider for this user
  AuthProviderModel? get primaryAuthProvider {
    if (authProviders.isEmpty) return null;
    return authProviders.first;
  }

  /// Checks if the user is registered with Google
  bool get hasGoogleAuth {
    return authProviders.any((p) => p.provider == AuthProviderType.google);
  }

  /// Checks if the user is using email/password authentication
  bool get hasEmailAuth {
    return authProviders.any((p) => p.provider == AuthProviderType.email);
  }

  /// Checks if the user account is deleted (soft delete)
  bool get isDeleted => deletedAt != null;

  /// Checks if the user account is suspended
  bool get isSuspended => !isActive && deletedAt == null;

  /// Returns a safe version of the user model for client-side use
  /// (excludes sensitive fields like password hashes)
  UserModel toSafeModel() {
    return copyWith();
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
    return 'UserModel(id: $id, email: $email, fullName: $fullName, '
        'isPremium: $isPremium, isActive: $isActive)';
  }
}

/// Authentication provider types
class AuthProviderType {
  static const String email = 'email';
  static const String google = 'google';
  static const String apple = 'apple';
}

/// Model representing an authentication provider linked to a user
class AuthProviderModel {
  final String id;
  final String userId;
  final String provider;
  final String providerUserId;
  final String? providerAccessToken;
  final String? providerRefreshToken;
  final DateTime? providerTokenExpiresAt;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AuthProviderModel({
    required this.id,
    required this.userId,
    required this.provider,
    required this.providerUserId,
    this.providerAccessToken,
    this.providerRefreshToken,
    this.providerTokenExpiresAt,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory AuthProviderModel.fromJson(Map<String, dynamic> json) {
    return AuthProviderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? json['userId'] as String? ?? '',
      provider: json['provider'] as String,
      providerUserId: json['provider_user_id'] as String? ??
          json['providerUserId'] as String? ??
          '',
      providerAccessToken: json['provider_access_token'] as String? ??
          json['providerAccessToken'] as String?,
      providerRefreshToken: json['provider_refresh_token'] as String? ??
          json['providerRefreshToken'] as String?,
      providerTokenExpiresAt: json['provider_token_expires_at'] != null
          ? DateTime.parse(json['provider_token_expires_at'] as String)
          : json['providerTokenExpiresAt'] != null
              ? DateTime.parse(json['providerTokenExpiresAt'] as String)
              : null,
      metadata: json['metadata'] is Map
          ? json['metadata'] as Map<String, dynamic>
          : json['metadata'] is String
              ? jsonDecode(json['metadata'] as String) as Map<String, dynamic>
              : const {},
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'provider': provider,
      'provider_user_id': providerUserId,
      'provider_access_token': providerAccessToken,
      'provider_refresh_token': providerRefreshToken,
      'provider_token_expires_at': providerTokenExpiresAt?.toIso8601String(),
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  AuthProviderModel copyWith({
    String? id,
    String? userId,
    String? provider,
    String? providerUserId,
    String? providerAccessToken,
    String? providerRefreshToken,
    DateTime? providerTokenExpiresAt,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AuthProviderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      provider: provider ?? this.provider,
      providerUserId: providerUserId ?? this.providerUserId,
      providerAccessToken: providerAccessToken ?? this.providerAccessToken,
      providerRefreshToken: providerRefreshToken ?? this.providerRefreshToken,
      providerTokenExpiresAt:
          providerTokenExpiresAt ?? this.providerTokenExpiresAt,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isGoogle => provider == AuthProviderType.google;
  bool get isApple => provider == AuthProviderType.apple;
  bool get isEmail => provider == AuthProviderType.email;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthProviderModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// User application settings model
class UserSettingsModel {
  /// Currency code (ISO 4217, e.g., 'IDR', 'USD')
  final String currencyCode;

  /// Currency symbol (e.g., 'Rp', '$')
  final String currencySymbol;

  /// Date format (e.g., 'DD/MM/YYYY', 'MM/DD/YYYY')
  final String dateFormat;

  /// First day of week (0 = Sunday, 1 = Monday)
  final int firstDayOfWeek;

  /// Decimal separator character
  final String decimalSeparator;

  /// Thousand separator character
  final String thousandSeparator;

  /// Default account ID for transactions
  final String? defaultAccountId;

  /// Whether notifications are enabled
  final bool enableNotifications;

  /// Whether email reports are enabled
  final bool enableEmailReports;

  /// Report frequency ('daily', 'weekly', 'monthly')
  final String reportFrequency;

  /// Whether low balance alerts are enabled
  final bool lowBalanceAlert;

  /// Low balance threshold amount
  final double lowBalanceThreshold;

  /// Budget alert percentage (triggers alert when % of budget used)
  final int budgetAlertPercentage;

  /// Investment alert percentage (triggers alert for price changes)
  final int investmentAlertPercentage;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserSettingsModel({
    this.currencyCode = 'IDR',
    this.currencySymbol = 'Rp',
    this.dateFormat = 'DD/MM/YYYY',
    this.firstDayOfWeek = 1,
    this.decimalSeparator = ',',
    this.thousandSeparator = '.',
    this.defaultAccountId,
    this.enableNotifications = true,
    this.enableEmailReports = false,
    this.reportFrequency = 'weekly',
    this.lowBalanceAlert = true,
    this.lowBalanceThreshold = 500000,
    this.budgetAlertPercentage = 80,
    this.investmentAlertPercentage = 10,
    this.createdAt,
    this.updatedAt,
  });

  factory UserSettingsModel.fromJson(Map<String, dynamic> json) {
    return UserSettingsModel(
      currencyCode: json['currency_code'] as String? ??
          json['currencyCode'] as String? ??
          'IDR',
      currencySymbol: json['currency_symbol'] as String? ??
          json['currencySymbol'] as String? ??
          'Rp',
      dateFormat: json['date_format'] as String? ??
          json['dateFormat'] as String? ??
          'DD/MM/YYYY',
      firstDayOfWeek: json['first_day_of_week'] as int? ??
          json['firstDayOfWeek'] as int? ??
          1,
      decimalSeparator: json['decimal_separator'] as String? ??
          json['decimalSeparator'] as String? ??
          ',',
      thousandSeparator: json['thousand_separator'] as String? ??
          json['thousandSeparator'] as String? ??
          '.',
      defaultAccountId: json['default_account_id'] as String? ??
          json['defaultAccountId'] as String?,
      enableNotifications: json['enable_notifications'] as bool? ??
          json['enableNotifications'] as bool? ??
          true,
      enableEmailReports: json['enable_email_reports'] as bool? ??
          json['enableEmailReports'] as bool? ??
          false,
      reportFrequency: json['report_frequency'] as String? ??
          json['reportFrequency'] as String? ??
          'weekly',
      lowBalanceAlert: json['low_balance_alert'] as bool? ??
          json['lowBalanceAlert'] as bool? ??
          true,
      lowBalanceThreshold: (json['low_balance_threshold'] as num?)?.toDouble() ??
          (json['lowBalanceThreshold'] as num?)?.toDouble() ??
          500000,
      budgetAlertPercentage: json['budget_alert_percentage'] as int? ??
          json['budgetAlertPercentage'] as int? ??
          80,
      investmentAlertPercentage: json['investment_alert_percentage'] as int? ??
          json['investmentAlertPercentage'] as int? ??
          10,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currency_code': currencyCode,
      'currency_symbol': currencySymbol,
      'date_format': dateFormat,
      'first_day_of_week': firstDayOfWeek,
      'decimal_separator': decimalSeparator,
      'thousand_separator': thousandSeparator,
      'default_account_id': defaultAccountId,
      'enable_notifications': enableNotifications,
      'enable_email_reports': enableEmailReports,
      'report_frequency': reportFrequency,
      'low_balance_alert': lowBalanceAlert,
      'low_balance_threshold': lowBalanceThreshold,
      'budget_alert_percentage': budgetAlertPercentage,
      'investment_alert_percentage': investmentAlertPercentage,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserSettingsModel copyWith({
    String? currencyCode,
    String? currencySymbol,
    String? dateFormat,
    int? firstDayOfWeek,
    String? decimalSeparator,
    String? thousandSeparator,
    String? defaultAccountId,
    bool? enableNotifications,
    bool? enableEmailReports,
    String? reportFrequency,
    bool? lowBalanceAlert,
    double? lowBalanceThreshold,
    int? budgetAlertPercentage,
    int? investmentAlertPercentage,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearDefaultAccountId = false,
  }) {
    return UserSettingsModel(
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      dateFormat: dateFormat ?? this.dateFormat,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
      decimalSeparator: decimalSeparator ?? this.decimalSeparator,
      thousandSeparator: thousandSeparator ?? this.thousandSeparator,
      defaultAccountId:
          clearDefaultAccountId ? null : (defaultAccountId ?? this.defaultAccountId),
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableEmailReports: enableEmailReports ?? this.enableEmailReports,
      reportFrequency: reportFrequency ?? this.reportFrequency,
      lowBalanceAlert: lowBalanceAlert ?? this.lowBalanceAlert,
      lowBalanceThreshold: lowBalanceThreshold ?? this.lowBalanceThreshold,
      budgetAlertPercentage: budgetAlertPercentage ?? this.budgetAlertPercentage,
      investmentAlertPercentage:
          investmentAlertPercentage ?? this.investmentAlertPercentage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Formats a number as currency using user's settings
  String formatCurrency(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}$thousandSeparator',
    );
    return '$currencySymbol$intPart$decimalSeparator${parts[1]}';
  }

  /// Formats a date according to user's date format setting
  String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;

    switch (dateFormat) {
      case 'MM/DD/YYYY':
        return '$month/$day/$year';
      case 'YYYY-MM-DD':
        return '$year-$month-$day';
      case 'DD-MM-YYYY':
        return '$day-$month-$year';
      case 'DD/MM/YYYY':
      default:
        return '$day/$month/$year';
    }
  }

  /// Returns whether Monday is the first day of week
  bool get isMondayFirstDayOfWeek => firstDayOfWeek == 1;
}

/// Device information for login/session tracking
class DeviceInfoModel {
  final String deviceId;
  final String deviceName;
  final String platform; // 'ios', 'android', 'web'
  final String osVersion;
  final String appVersion;
  final String? pushToken;
  final DateTime? lastActiveAt;

  const DeviceInfoModel({
    required this.deviceId,
    required this.deviceName,
    required this.platform,
    required this.osVersion,
    required this.appVersion,
    this.pushToken,
    this.lastActiveAt,
  });

  factory DeviceInfoModel.fromJson(Map<String, dynamic> json) {
    return DeviceInfoModel(
      deviceId: json['device_id'] as String? ??
          json['deviceId'] as String? ??
          '',
      deviceName: json['device_name'] as String? ??
          json['deviceName'] as String? ??
          json['name'] as String? ??
          'Unknown Device',
      platform: json['platform'] as String? ?? 'unknown',
      osVersion: json['os_version'] as String? ??
          json['osVersion'] as String? ??
          json['version'] as String? ??
          'Unknown',
      appVersion: json['app_version'] as String? ??
          json['appVersion'] as String? ??
          json['version'] as String? ??
          '1.0.0',
      pushToken: json['push_token'] as String? ??
          json['pushToken'] as String?,
      lastActiveAt: json['last_active_at'] != null
          ? DateTime.parse(json['last_active_at'] as String)
          : json['lastActiveAt'] != null
              ? DateTime.parse(json['lastActiveAt'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'device_name': deviceName,
      'platform': platform,
      'os_version': osVersion,
      'app_version': appVersion,
      'push_token': pushToken,
      'last_active_at': lastActiveAt?.toIso8601String(),
    };
  }

  bool get isIOS => platform.toLowerCase() == 'ios';
  bool get isAndroid => platform.toLowerCase() == 'android';
  bool get isWeb => platform.toLowerCase() == 'web';
}

/// Login history entry model
class LoginHistoryModel {
  final String id;
  final String userId;
  final String deviceName;
  final String? ipAddress;
  final String? location;
  final DateTime timestamp;
  final String status; // 'success', 'failed'
  final String? failureReason;
  final DeviceInfoModel? deviceInfo;

  const LoginHistoryModel({
    required this.id,
    required this.userId,
    required this.deviceName,
    this.ipAddress,
    this.location,
    required this.timestamp,
    required this.status,
    this.failureReason,
    this.deviceInfo,
  });

  factory LoginHistoryModel.fromJson(Map<String, dynamic> json) {
    return LoginHistoryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? json['userId'] as String? ?? '',
      deviceName: json['device'] as String? ??
          json['device_name'] as String? ??
          json['deviceName'] as String? ??
          'Unknown Device',
      ipAddress: json['ip_address'] as String? ?? json['ipAddress'] as String?,
      location: json['location'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      status: json['status'] as String? ?? 'success',
      failureReason: json['failure_reason'] as String? ??
          json['failureReason'] as String?,
      deviceInfo: json['device_info'] != null
          ? DeviceInfoModel.fromJson(
              json['device_info'] is String
                  ? jsonDecode(json['device_info'] as String) as Map<String, dynamic>
                  : json['device_info'] as Map<String, dynamic>,
            )
          : json['deviceInfo'] != null
              ? DeviceInfoModel.fromJson(
                  json['deviceInfo'] is String
                      ? jsonDecode(json['deviceInfo'] as String) as Map<String, dynamic>
                      : json['deviceInfo'] as Map<String, dynamic>,
                )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'device_name': deviceName,
      'ip_address': ipAddress,
      'location': location,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'failure_reason': failureReason,
      'device_info': deviceInfo?.toJson(),
    };
  }

  bool get isSuccess => status == 'success';
  bool get isFailed => status == 'failed';
}

/// Auth tokens response model
class AuthTokensModel {
  final String accessToken;
  final String refreshToken;
  final int expiresIn; // seconds
  final DateTime? issuedAt;

  const AuthTokensModel({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    this.issuedAt,
  });

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    return AuthTokensModel(
      accessToken: json['access_token'] as String? ??
          json['accessToken'] as String? ??
          '',
      refreshToken: json['refresh_token'] as String? ??
          json['refreshToken'] as String? ??
          '',
      expiresIn: json['expires_in'] as int? ??
          json['expiresIn'] as int? ??
          900, // 15 minutes default
      issuedAt: json['issued_at'] != null
          ? DateTime.parse(json['issued_at'] as String)
          : json['issuedAt'] != null
              ? DateTime.parse(json['issuedAt'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_in': expiresIn,
      'issued_at': issuedAt?.toIso8601String(),
    };
  }

  /// Returns the expiration time
  DateTime get expiresAt {
    return (issuedAt ?? DateTime.now()).add(Duration(seconds: expiresIn));
  }

  /// Checks if the access token is expired
  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  /// Checks if the access token is about to expire (within 5 minutes)
  bool get isAboutToExpire {
    return DateTime.now().isAfter(expiresAt.subtract(const Duration(minutes: 5)));
  }
}

/// Complete authentication response model
class AuthResponseModel {
  final UserModel user;
  final AuthTokensModel tokens;
  final bool isNewUser;
  final String? sessionToken;

  const AuthResponseModel({
    required this.user,
    required this.tokens,
    this.isNewUser = false,
    this.sessionToken,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: json['user'] != null
          ? UserModel.fromJson(
              json['user'] is String
                  ? jsonDecode(json['user'] as String) as Map<String, dynamic>
                  : json['user'] as Map<String, dynamic>,
            )
          : throw const FormatException('User field is required in AuthResponseModel'),
      tokens: json['tokens'] != null
          ? AuthTokensModel.fromJson(
              json['tokens'] is String
                  ? jsonDecode(json['tokens'] as String) as Map<String, dynamic>
                  : json['tokens'] as Map<String, dynamic>,
            )
          : throw const FormatException('Tokens field is required in AuthResponseModel'),
      isNewUser: json['is_new_user'] as bool? ?? json['isNewUser'] as bool? ?? false,
      sessionToken: json['session_token'] as String? ?? json['sessionToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'tokens': tokens.toJson(),
      'is_new_user': isNewUser,
      'session_token': sessionToken,
    };
  }
}
