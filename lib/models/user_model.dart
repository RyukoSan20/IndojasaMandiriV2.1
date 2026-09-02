import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

/// User model representing the authenticated user in FinTrack
/// Contains all user profile information and security settings
@JsonSerializable(explicitToJson: true)
class UserModel {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'email')
  final String email;

  @JsonKey(name: 'full_name')
  final String fullName;

  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  @JsonKey(name: 'phone_number')
  final String? phoneNumber;

  @JsonKey(name: 'date_of_birth')
  final DateTime? dateOfBirth;

  @JsonKey(name: 'timezone')
  final String timezone;

  @JsonKey(name: 'locale')
  final String locale;

  @JsonKey(name: 'theme')
  final String theme;

  @JsonKey(name: 'pin_enabled')
  final bool pinEnabled;

  @JsonKey(name: 'biometric_enabled')
  final bool biometricEnabled;

  @JsonKey(name: 'email_verified')
  final bool emailVerified;

  @JsonKey(name: 'email_verified_at')
  final DateTime? emailVerifiedAt;

  @JsonKey(name: 'is_active')
  final bool isActive;

  @JsonKey(name: 'is_premium')
  final bool isPremium;

  @JsonKey(name: 'premium_expires_at')
  final DateTime? premiumExpiresAt;

  @JsonKey(name: 'last_login_at')
  final DateTime? lastLoginAt;

  @JsonKey(name: 'settings')
  final UserSettingsModel? settings;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    this.phoneNumber,
    this.dateOfBirth,
    this.timezone = 'Asia/Jakarta',
    this.locale = 'id_ID',
    this.theme = 'light',
    this.pinEnabled = false,
    this.biometricEnabled = false,
    this.emailVerified = false,
    this.emailVerifiedAt,
    this.isActive = true,
    this.isPremium = false,
    this.premiumExpiresAt,
    this.lastLoginAt,
    this.settings,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory constructor to create UserModel from JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Convert UserModel to JSON map
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

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
    bool? pinEnabled,
    bool? biometricEnabled,
    bool? emailVerified,
    DateTime? emailVerifiedAt,
    bool? isActive,
    bool? isPremium,
    DateTime? premiumExpiresAt,
    DateTime? lastLoginAt,
    UserSettingsModel? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      timezone: timezone ?? this.timezone,
      locale: locale ?? this.locale,
      theme: theme ?? this.theme,
      pinEnabled: pinEnabled ?? this.pinEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      emailVerified: emailVerified ?? this.emailVerified,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      isActive: isActive ?? this.isActive,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if premium subscription is still valid
  bool get hasValidPremium {
    if (!isPremium) return false;
    if (premiumExpiresAt == null) return true;
    return premiumExpiresAt!.isAfter(DateTime.now());
  }

  /// Get user initials for avatar placeholder
  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  /// Get formatted display name
  String get displayName {
    if (fullName.isEmpty) return email.split('@').first;
    return fullName;
  }

  /// Check if user has completed profile setup
  bool get isProfileComplete {
    return fullName.isNotEmpty &&
        emailVerified &&
        (phoneNumber != null && phoneNumber!.isNotEmpty);
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
    return 'UserModel(id: $id, email: $email, fullName: $fullName)';
  }
}

/// User settings model for app preferences
@JsonSerializable()
class UserSettingsModel {
  @JsonKey(name: 'currency_code')
  final String currencyCode;

  @JsonKey(name: 'currency_symbol')
  final String currencySymbol;

  @JsonKey(name: 'date_format')
  final String dateFormat;

  @JsonKey(name: 'first_day_of_week')
  final int firstDayOfWeek;

  @JsonKey(name: 'decimal_separator')
  final String decimalSeparator;

  @JsonKey(name: 'thousand_separator')
  final String thousandSeparator;

  @JsonKey(name: 'default_account_id')
  final String? defaultAccountId;

  @JsonKey(name: 'enable_notifications')
  final bool enableNotifications;

  @JsonKey(name: 'enable_email_reports')
  final bool enableEmailReports;

  @JsonKey(name: 'report_frequency')
  final String reportFrequency;

  @JsonKey(name: 'low_balance_alert')
  final bool lowBalanceAlert;

  @JsonKey(name: 'low_balance_threshold')
  final double lowBalanceThreshold;

  @JsonKey(name: 'budget_alert_percentage')
  final int budgetAlertPercentage;

  @JsonKey(name: 'investment_alert_percentage')
  final int investmentAlertPercentage;

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
  });

  factory UserSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserSettingsModelToJson(this);

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
  }) {
    return UserSettingsModel(
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      dateFormat: dateFormat ?? this.dateFormat,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
      decimalSeparator: decimalSeparator ?? this.decimalSeparator,
      thousandSeparator: thousandSeparator ?? this.thousandSeparator,
      defaultAccountId: defaultAccountId ?? this.defaultAccountId,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableEmailReports: enableEmailReports ?? this.enableEmailReports,
      reportFrequency: reportFrequency ?? this.reportFrequency,
      lowBalanceAlert: lowBalanceAlert ?? this.lowBalanceAlert,
      lowBalanceThreshold: lowBalanceThreshold ?? this.lowBalanceThreshold,
      budgetAlertPercentage:
          budgetAlertPercentage ?? this.budgetAlertPercentage,
      investmentAlertPercentage:
          investmentAlertPercentage ?? this.investmentAlertPercentage,
    );
  }
}

/// Authentication tokens response model
@JsonSerializable()
class AuthTokensModel {
  @JsonKey(name: 'access_token')
  final String accessToken;

  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  @JsonKey(name: 'expires_in')
  final int expiresIn;

  @JsonKey(name: 'token_type')
  final String tokenType;

  const AuthTokensModel({
    required this.accessToken,
    required this.refreshToken,
    this.expiresIn = 900,
    this.tokenType = 'Bearer',
  });

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthTokensModelToJson(this);
}

/// Device information for authentication tracking
@JsonSerializable()
class DeviceInfoModel {
  @JsonKey(name: 'device_id')
  final String? deviceId;

  @JsonKey(name: 'device_name')
  final String? deviceName;

  @JsonKey(name: 'platform')
  final String platform;

  @JsonKey(name: 'os_version')
  final String? osVersion;

  @JsonKey(name: 'app_version')
  final String? appVersion;

  @JsonKey(name: 'ip_address')
  final String? ipAddress;

  @JsonKey(name: 'user_agent')
  final String? userAgent;

  const DeviceInfoModel({
    this.deviceId,
    this.deviceName,
    required this.platform,
    this.osVersion,
    this.appVersion,
    this.ipAddress,
    this.userAgent,
  });

  factory DeviceInfoModel.fromJson(Map<String, dynamic> json) =>
      _$DeviceInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceInfoModelToJson(this);
}

/// Login history entry model
@JsonSerializable()
class LoginHistoryModel {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'device')
  final String device;

  @JsonKey(name: 'ip_address')
  final String? ipAddress;

  @JsonKey(name: 'location')
  final String? location;

  @JsonKey(name: 'timestamp')
  final DateTime timestamp;

  @JsonKey(name: 'status')
  final String status;

  const LoginHistoryModel({
    required this.id,
    required this.device,
    this.ipAddress,
    this.location,
    required this.timestamp,
    required this.status,
  });

  factory LoginHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$LoginHistoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginHistoryModelToJson(this);
}

/// Auth state model for managing authentication status
@JsonSerializable()
class AuthStateModel {
  @JsonKey(name: 'user')
  final UserModel? user;

  @JsonKey(name: 'tokens')
  final AuthTokensModel? tokens;

  @JsonKey(name: 'is_authenticated')
  final bool isAuthenticated;

  @JsonKey(name: 'is_loading')
  final bool isLoading;

  @JsonKey(name: 'error')
  final String? error;

  @JsonKey(name: 'last_auth_time')
  final DateTime? lastAuthTime;

  const AuthStateModel({
    this.user,
    this.tokens,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.lastAuthTime,
  });

  factory AuthStateModel.fromJson(Map<String, dynamic> json) =>
      _$AuthStateModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthStateModelToJson(this);

  AuthStateModel copyWith({
    UserModel? user,
    AuthTokensModel? tokens,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    DateTime? lastAuthTime,
  }) {
    return AuthStateModel(
      user: user ?? this.user,
      tokens: tokens ?? this.tokens,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastAuthTime: lastAuthTime ?? this.lastAuthTime,
    );
  }

  /// Create authenticated state with user and tokens
  factory AuthStateModel.authenticated({
    required UserModel user,
    required AuthTokensModel tokens,
  }) {
    return AuthStateModel(
      user: user,
      tokens: tokens,
      isAuthenticated: true,
      isLoading: false,
      lastAuthTime: DateTime.now(),
    );
  }

  /// Create initial unauthenticated state
  factory AuthStateModel.initial() {
    return const AuthStateModel();
  }

  /// Create loading state
  factory AuthStateModel.loading() {
    return const AuthStateModel(isLoading: true);
  }

  /// Create error state
  factory AuthStateModel.error(String message) {
    return AuthStateModel(error: message);
  }
}
