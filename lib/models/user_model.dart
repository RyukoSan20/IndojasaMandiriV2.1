import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

/// User model representing a FinTrack user account.
/// 
/// Contains all user profile information, authentication settings,
/// and user preferences for the application.
@JsonSerializable(explicitToJson: true)
class UserModel {
  /// Unique identifier for the user (UUID format)
  final String id;

  /// User's email address (unique, required)
  final String email;

  /// User's full name (display name)
  @JsonKey(name: 'full_name')
  final String fullName;

  /// URL to user's avatar image
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  /// User's phone number
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;

  /// User's date of birth
  @JsonKey(name: 'date_of_birth', fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? dateOfBirth;

  /// Whether PIN authentication is enabled
  @JsonKey(name: 'pin_enabled')
  final bool pinEnabled;

  /// Whether biometric authentication is enabled
  @JsonKey(name: 'biometric_enabled')
  final bool biometricEnabled;

  /// User's timezone (IANA format, e.g., 'Asia/Jakarta')
  final String timezone;

  /// User's locale code (e.g., 'id_ID', 'en_US')
  final String locale;

  /// UI theme preference ('light', 'dark', 'system')
  final String theme;

  /// Whether email has been verified
  @JsonKey(name: 'email_verified')
  final bool emailVerified;

  /// Timestamp when email was verified
  @JsonKey(name: 'email_verified_at', fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? emailVerifiedAt;

  /// Whether the user account is active
  @JsonKey(name: 'is_active')
  final bool isActive;

  /// Whether the user has a premium subscription
  @JsonKey(name: 'is_premium')
  final bool isPremium;

  /// Premium subscription expiration date
  @JsonKey(name: 'premium_expires_at', fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? premiumExpiresAt;

  /// Last login timestamp
  @JsonKey(name: 'last_login_at', fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? lastLoginAt;

  /// User creation timestamp
  @JsonKey(name: 'created_at', fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime createdAt;

  /// Last update timestamp
  @JsonKey(name: 'updated_at', fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime updatedAt;

  /// User deletion timestamp (soft delete)
  @JsonKey(name: 'deleted_at', fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? deletedAt;

  /// User's custom settings/preferences
  @JsonKey(name: 'settings')
  final UserSettingsModel? settings;

  /// Authentication provider information
  @JsonKey(name: 'auth_provider')
  final AuthProviderModel? authProvider;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    this.phoneNumber,
    this.dateOfBirth,
    this.pinEnabled = false,
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
    this.settings,
    this.authProvider,
  });

  /// Creates a UserModel from JSON map.
  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  /// Converts this UserModel to JSON map.
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Creates a copy of this UserModel with optional field overrides.
  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? phoneNumber,
    DateTime? dateOfBirth,
    bool? pinEnabled,
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
    UserSettingsModel? settings,
    AuthProviderModel? authProvider,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      pinEnabled: pinEnabled ?? this.pinEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      timezone: timezone ?? this.timezone,
      locale: locale ?? this.locale,
      theme: theme ?? this.theme,
      emailVerified: emailVerified ?? this.emailVerified,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      isActive: isActive ?? this.isActive,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      settings: settings ?? this.settings,
      authProvider: authProvider ?? this.authProvider,
    );
  }

  /// Creates an empty/default user model.
  factory UserModel.empty() => UserModel(
    id: '',
    email: '',
    fullName: '',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  /// Returns true if this is a valid, non-empty user.
  bool get isValid => id.isNotEmpty && email.isNotEmpty && fullName.isNotEmpty;

  /// Returns true if the user's premium subscription is still valid.
  bool get hasValidPremium => isPremium && 
      (premiumExpiresAt == null || premiumExpiresAt!.isAfter(DateTime.now()));

  /// Returns the user's display name (fullName or email username).
  String get displayName => fullName.isNotEmpty ? fullName : email.split('@').first;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          fullName == other.fullName &&
          avatarUrl == other.avatarUrl &&
          phoneNumber == other.phoneNumber &&
          dateOfBirth == other.dateOfBirth &&
          pinEnabled == other.pinEnabled &&
          biometricEnabled == other.biometricEnabled &&
          timezone == other.timezone &&
          locale == other.locale &&
          theme == other.theme &&
          emailVerified == other.emailVerified &&
          isActive == other.isActive &&
          isPremium == other.isPremium;

  @override
  int get hashCode => Object.hash(
        id,
        email,
        fullName,
        avatarUrl,
        phoneNumber,
        dateOfBirth,
        pinEnabled,
        biometricEnabled,
        timezone,
        locale,
        theme,
        emailVerified,
        isActive,
        isPremium,
      );

  @override
  String toString() {
    return 'UserModel{id: $id, email: $email, fullName: $fullName, '
        'isPremium: $isPremium, theme: $theme}';
  }
}

/// Helper to parse DateTime from various formats.
DateTime? _dateTimeFromJson(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is String) return DateTime.tryParse(value);
  return null;
}

/// Helper to serialize DateTime to ISO 8601 string.
dynamic _dateTimeToJson(DateTime? dateTime) {
  return dateTime?.toIso8601String();
}

/// User settings and preferences model.
@JsonSerializable()
class UserSettingsModel {
  /// Currency code (ISO 4217, e.g., 'IDR', 'USD')
  @JsonKey(name: 'currency_code')
  final String currencyCode;

  /// Currency symbol (e.g., 'Rp', '$')
  @JsonKey(name: 'currency_symbol')
  final String currencySymbol;

  /// Date format string (e.g., 'DD/MM/YYYY', 'MM/DD/YYYY')
  @JsonKey(name: 'date_format')
  final String dateFormat;

  /// First day of week (0 = Sunday, 1 = Monday)
  @JsonKey(name: 'first_day_of_week')
  final int firstDayOfWeek;

  /// Decimal separator character
  @JsonKey(name: 'decimal_separator')
  final String decimalSeparator;

  /// Thousand separator character
  @JsonKey(name: 'thousand_separator')
  final String thousandSeparator;

  /// Default account ID for new transactions
  @JsonKey(name: 'default_account_id')
  final String? defaultAccountId;

  /// Whether notifications are enabled
  @JsonKey(name: 'enable_notifications')
  final bool enableNotifications;

  /// Whether email reports are enabled
  @JsonKey(name: 'enable_email_reports')
  final bool enableEmailReports;

  /// Email report frequency
  @JsonKey(name: 'report_frequency')
  final String reportFrequency;

  /// Whether low balance alerts are enabled
  @JsonKey(name: 'low_balance_alert')
  final bool lowBalanceAlert;

  /// Low balance threshold amount
  @JsonKey(name: 'low_balance_threshold')
  final double lowBalanceThreshold;

  /// Budget alert percentage (0-100)
  @JsonKey(name: 'budget_alert_percentage')
  final int budgetAlertPercentage;

  /// Investment alert percentage (0-100)
  @JsonKey(name: 'investment_alert_percentage')
  final int investmentAlertPercentage;

  /// Whether daily reminder is enabled
  @JsonKey(name: 'daily_reminder')
  final bool dailyReminder;

  /// Daily reminder time (HH:mm format)
  @JsonKey(name: 'reminder_time')
  final String? reminderTime;

  /// Whether transaction alerts are enabled
  @JsonKey(name: 'transaction_alerts')
  final bool transactionAlerts;

  /// Whether portfolio alerts are enabled
  @JsonKey(name: 'portfolio_alerts')
  final bool portfolioAlerts;

  /// Whether savings milestone notifications are enabled
  @JsonKey(name: 'savings_milestones')
  final bool savingsMilestones;

  /// Auto-sync enabled
  @JsonKey(name: 'auto_sync')
  final bool autoSync;

  /// Sync frequency ('realtime', 'hourly', 'daily')
  @JsonKey(name: 'sync_frequency')
  final String syncFrequency;

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
    this.dailyReminder = false,
    this.reminderTime,
    this.transactionAlerts = true,
    this.portfolioAlerts = true,
    this.savingsMilestones = true,
    this.autoSync = true,
    this.syncFrequency = 'realtime',
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
    bool? dailyReminder,
    String? reminderTime,
    bool? transactionAlerts,
    bool? portfolioAlerts,
    bool? savingsMilestones,
    bool? autoSync,
    String? syncFrequency,
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
      budgetAlertPercentage: budgetAlertPercentage ?? this.budgetAlertPercentage,
      investmentAlertPercentage: investmentAlertPercentage ?? this.investmentAlertPercentage,
      dailyReminder: dailyReminder ?? this.dailyReminder,
      reminderTime: reminderTime ?? this.reminderTime,
      transactionAlerts: transactionAlerts ?? this.transactionAlerts,
      portfolioAlerts: portfolioAlerts ?? this.portfolioAlerts,
      savingsMilestones: savingsMilestones ?? this.savingsMilestones,
      autoSync: autoSync ?? this.autoSync,
      syncFrequency: syncFrequency ?? this.syncFrequency,
    );
  }

  /// Formats a number with the user's currency settings.
  String formatCurrency(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}$thousandSeparator',
    );
    return '$currencySymbol$intPart$decimalSeparator${parts[1]}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsModel &&
          runtimeType == other.runtimeType &&
          currencyCode == other.currencyCode &&
          currencySymbol == other.currencySymbol &&
          dateFormat == other.dateFormat &&
          firstDayOfWeek == other.firstDayOfWeek &&
          enableNotifications == other.enableNotifications &&
          autoSync == other.autoSync;

  @override
  int get hashCode => Object.hash(
        currencyCode,
        currencySymbol,
        dateFormat,
        firstDayOfWeek,
        enableNotifications,
        autoSync,
      );
}

/// Authentication provider information.
@JsonSerializable()
class AuthProviderModel {
  /// Provider type ('email', 'google', 'apple')
  final String provider;

  /// Whether this is the primary provider
  @JsonKey(name: 'is_primary')
  final bool isPrimary;

  /// Provider user ID
  @JsonKey(name: 'provider_user_id')
  final String? providerUserId;

  /// Token expiration timestamp
  @JsonKey(name: 'token_expires_at', fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? tokenExpiresAt;

  /// Provider metadata
  final Map<String, dynamic>? metadata;

  const AuthProviderModel({
    required this.provider,
    this.isPrimary = false,
    this.providerUserId,
    this.tokenExpiresAt,
    this.metadata,
  });

  factory AuthProviderModel.fromJson(Map<String, dynamic> json) =>
      _$AuthProviderModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthProviderModelToJson(this);

  AuthProviderModel copyWith({
    String? provider,
    bool? isPrimary,
    String? providerUserId,
    DateTime? tokenExpiresAt,
    Map<String, dynamic>? metadata,
  }) {
    return AuthProviderModel(
      provider: provider ?? this.provider,
      isPrimary: isPrimary ?? this.isPrimary,
      providerUserId: providerUserId ?? this.providerUserId,
      tokenExpiresAt: tokenExpiresAt ?? this.tokenExpiresAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Returns true if the provider uses Google OAuth.
  bool get isGoogle => provider == 'google';

  /// Returns true if the provider uses Apple OAuth.
  bool get isApple => provider == 'apple';

  /// Returns true if the provider uses email/password.
  bool get isEmail => provider == 'email';

  /// Returns true if the token is expired.
  bool get isTokenExpired =>
      tokenExpiresAt != null && tokenExpiresAt!.isBefore(DateTime.now());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthProviderModel &&
          runtimeType == other.runtimeType &&
          provider == other.provider &&
          isPrimary == other.isPrimary;

  @override
  int get hashCode => Object.hash(provider, isPrimary);
}

/// Authentication tokens response model.
@JsonSerializable()
class AuthTokensModel {
  /// JWT access token
  @JsonKey(name: 'access_token')
  final String accessToken;

  /// Refresh token
  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  /// Token expiration time in seconds
  @JsonKey(name: 'expires_in')
  final int expiresIn;

  /// Token type (usually 'Bearer')
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

  /// Returns the Authorization header value.
  String get authorizationHeader => '$tokenType $accessToken';

  /// Returns the expiration DateTime.
  DateTime get expiresAt => DateTime.now().add(Duration(seconds: expiresIn));

  /// Returns true if the token is expired.
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Returns true if the token expires within the given duration.
  bool expiresWithin(Duration duration) =>
      DateTime.now().add(duration).isAfter(expiresAt);

  AuthTokensModel copyWith({
    String? accessToken,
    String? refreshToken,
    int? expiresIn,
    String? tokenType,
  }) {
    return AuthTokensModel(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresIn: expiresIn ?? this.expiresIn,
      tokenType: tokenType ?? this.tokenType,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthTokensModel &&
          runtimeType == other.runtimeType &&
          accessToken == other.accessToken &&
          refreshToken == other.refreshToken;

  @override
  int get hashCode => Object.hash(accessToken, refreshToken);
}

/// Complete authentication response model.
@JsonSerializable(explicitToJson: true)
class AuthResponseModel {
  /// The authenticated user
  final UserModel user;

  /// Authentication tokens
  @JsonKey(name: 'tokens')
  final AuthTokensModel tokens;

  /// Whether this is a new user (for OAuth flows)
  @JsonKey(name: 'is_new_user')
  final bool isNewUser;

  const AuthResponseModel({
    required this.user,
    required this.tokens,
    this.isNewUser = false,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);

  AuthResponseModel copyWith({
    UserModel? user,
    AuthTokensModel? tokens,
    bool? isNewUser,
  }) {
    return AuthResponseModel(
      user: user ?? this.user,
      tokens: tokens ?? this.tokens,
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }
}

/// Device information for authentication.
@JsonSerializable()
class DeviceInfoModel {
  /// Device name (e.g., 'iPhone 15 Pro')
  final String name;

  /// Platform ('ios', 'android', 'web')
  final String platform;

  /// OS/ browser version
  final String version;

  /// Device unique identifier
  @JsonKey(name: 'device_id')
  final String? deviceId;

  const DeviceInfoModel({
    required this.name,
    required this.platform,
    required this.version,
    this.deviceId,
  });

  factory DeviceInfoModel.fromJson(Map<String, dynamic> json) =>
      _$DeviceInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceInfoModelToJson(this);

  /// Creates device info from current platform.
  factory DeviceInfoModel.current({
    required String name,
    required String platform,
    required String version,
  }) {
    return DeviceInfoModel(
      name: name,
      platform: platform,
      version: version,
    );
  }

  /// Returns iOS device info.
  factory DeviceInfoModel.ios({required String name, required String version}) {
    return DeviceInfoModel(
      name: name,
      platform: 'ios',
      version: version,
    );
  }

  /// Returns Android device info.
  factory DeviceInfoModel.android({required String name, required String version}) {
    return DeviceInfoModel(
      name: name,
      platform: 'android',
      version: version,
    );
  }

  /// Returns Web browser info.
  factory DeviceInfoModel.web({required String name, required String version}) {
    return DeviceInfoModel(
      name: name,
      platform: 'web',
      version: version,
    );
  }

  DeviceInfoModel copyWith({
    String? name,
    String? platform,
    String? version,
    String? deviceId,
  }) {
    return DeviceInfoModel(
      name: name ?? this.name,
      platform: platform ?? this.platform,
      version: version ?? this.version,
      deviceId: deviceId ?? this.deviceId,
    );
  }

  bool get isIOS => platform == 'ios';
  bool get isAndroid => platform == 'android';
  bool get isWeb => platform == 'web';
  bool get isMobile => isIOS || isAndroid;
}
