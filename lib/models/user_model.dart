import 'dart:convert';

class User {
  final String id;
  final String email;
  final String? passwordHash;
  final String fullName;
  final String? avatarUrl;
  final String? googleId;
  final String? pinHash;
  final bool biometricEnabled;
  final String phone;
  final DateTime? dateOfBirth;
  final String timezone;
  final String locale;
  final String theme;
  final bool emailVerified;
  final DateTime? emailVerifiedAt;
  final bool isActive;
  final bool isPremium;
  final DateTime? premiumExpiresAt;
  final DateTime? lastLoginAt;
  final UserSettings settings;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const User({
    required this.id,
    required this.email,
    this.passwordHash,
    required this.fullName,
    this.avatarUrl,
    this.googleId,
    this.pinHash,
    this.biometricEnabled = false,
    this.phone = '',
    this.dateOfBirth,
    this.timezone = 'Asia/Jakarta',
    this.locale = 'id_ID',
    this.theme = 'light',
    this.emailVerified = false,
    this.emailVerifiedAt,
    this.isActive = true,
    this.isPremium = false,
    this.premiumExpiresAt,
    this.lastLoginAt,
    this.settings = const UserSettings(),
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  bool get hasPassword => passwordHash != null && passwordHash!.isNotEmpty;
  bool get hasGoogle => googleId != null && googleId!.isNotEmpty;
  bool get hasPin => pinHash != null && pinHash!.isNotEmpty;
  bool get hasBiometric => biometricEnabled;
  bool get premiumActive =>
      isPremium && (premiumExpiresAt == null || premiumExpiresAt!.isAfter(DateTime.now()));

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  String get displayName => fullName.isNotEmpty ? fullName : email.split('@').first;

  User copyWith({
    String? id,
    String? email,
    String? passwordHash,
    String? fullName,
    String? avatarUrl,
    String? googleId,
    String? pinHash,
    bool? biometricEnabled,
    String? phone,
    DateTime? dateOfBirth,
    String? timezone,
    String? locale,
    String? theme,
    bool? emailVerified,
    DateTime? emailVerifiedAt,
    bool? isActive,
    bool? isPremium,
    DateTime? premiumExpiresAt,
    DateTime? lastLoginAt,
    UserSettings? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearPasswordHash = false,
    bool clearPinHash = false,
    bool clearAvatarUrl = false,
    bool clearGoogleId = false,
    bool clearDateOfBirth = false,
    bool clearEmailVerifiedAt = false,
    bool clearPremiumExpiresAt = false,
    bool clearLastLoginAt = false,
    bool clearDeletedAt = false,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      passwordHash: clearPasswordHash ? null : (passwordHash ?? this.passwordHash),
      fullName: fullName ?? this.fullName,
      avatarUrl: clearAvatarUrl ? null : (avatarUrl ?? this.avatarUrl),
      googleId: clearGoogleId ? null : (googleId ?? this.googleId),
      pinHash: clearPinHash ? null : (pinHash ?? this.pinHash),
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      phone: phone ?? this.phone,
      dateOfBirth: clearDateOfBirth ? null : (dateOfBirth ?? this.dateOfBirth),
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
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password_hash': passwordHash,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'google_id': googleId,
      'pin_hash': pinHash,
      'biometric_enabled': biometricEnabled,
      'phone': phone,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'timezone': timezone,
      'locale': locale,
      'theme': theme,
      'email_verified': emailVerified,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'is_active': isActive,
      'is_premium': isPremium,
      'premium_expires_at': premiumExpiresAt?.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
      'settings': settings.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      passwordHash: json['password_hash'] as String?,
      fullName: json['full_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      googleId: json['google_id'] as String?,
      pinHash: json['pin_hash'] as String?,
      biometricEnabled: json['biometric_enabled'] as bool? ?? false,
      phone: json['phone'] as String? ?? '',
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      timezone: json['timezone'] as String? ?? 'Asia/Jakarta',
      locale: json['locale'] as String? ?? 'id_ID',
      theme: json['theme'] as String? ?? 'light',
      emailVerified: json['email_verified'] as bool? ?? false,
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      isPremium: json['is_premium'] as bool? ?? false,
      premiumExpiresAt: json['premium_expires_at'] != null
          ? DateTime.parse(json['premium_expires_at'] as String)
          : null,
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
      settings: json['settings'] != null
          ? UserSettings.fromJson(
              json['settings'] is String
                  ? jsonDecode(json['settings'] as String) as Map<String, dynamic>
                  : json['settings'] as Map<String, dynamic>,
            )
          : const UserSettings(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory User.fromJsonString(String jsonString) =>
      User.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'phone': phone,
      'date_of_birth': dateOfBirth?.millisecondsSinceEpoch,
      'timezone': timezone,
      'locale': locale,
      'theme': theme,
      'email_verified': emailVerified,
      'is_active': isActive,
      'is_premium': isPremium,
      'premium_expires_at': premiumExpiresAt?.millisecondsSinceEpoch,
      'last_login_at': lastLoginAt?.millisecondsSinceEpoch,
      'settings': settings.toFirestore(),
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory User.fromFirestore(Map<String, dynamic> doc) {
    final data = doc;
    return User(
      id: data['id'] as String,
      email: data['email'] as String,
      fullName: data['full_name'] as String? ?? '',
      avatarUrl: data['avatar_url'] as String?,
      phone: data['phone'] as String? ?? '',
      dateOfBirth: data['date_of_birth'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['date_of_birth'] as int)
          : null,
      timezone: data['timezone'] as String? ?? 'Asia/Jakarta',
      locale: data['locale'] as String? ?? 'id_ID',
      theme: data['theme'] as String? ?? 'light',
      emailVerified: data['email_verified'] as bool? ?? false,
      isActive: data['is_active'] as bool? ?? true,
      isPremium: data['is_premium'] as bool? ?? false,
      premiumExpiresAt: data['premium_expires_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['premium_expires_at'] as int)
          : null,
      lastLoginAt: data['last_login_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['last_login_at'] as int)
          : null,
      settings: data['settings'] != null
          ? UserSettings.fromFirestore(
              data['settings'] as Map<String, dynamic>,
            )
          : const UserSettings(),
      createdAt: data['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['created_at'] as int)
          : DateTime.now(),
      updatedAt: data['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['updated_at'] as int)
          : DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User(id: $id, email: $email, fullName: $fullName, isPremium: $isPremium)';
  }
}

class UserSettings {
  final String currencyCode;
  final String currencySymbol;
  final String dateFormat;
  final int firstDayOfWeek;
  final String decimalSeparator;
  final String thousandSeparator;
  final String? defaultAccountId;
  final bool enableNotifications;
  final bool enableEmailReports;
  final String reportFrequency;
  final bool lowBalanceAlert;
  final double lowBalanceThreshold;
  final int budgetAlertPercentage;
  final int investmentAlertPercentage;

  const UserSettings({
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

  UserSettings copyWith({
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
    bool clearDefaultAccountId = false,
  }) {
    return UserSettings(
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
    };
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      currencyCode: json['currency_code'] as String? ?? 'IDR',
      currencySymbol: json['currency_symbol'] as String? ?? 'Rp',
      dateFormat: json['date_format'] as String? ?? 'DD/MM/YYYY',
      firstDayOfWeek: json['first_day_of_week'] as int? ?? 1,
      decimalSeparator: json['decimal_separator'] as String? ?? ',',
      thousandSeparator: json['thousand_separator'] as String? ?? '.',
      defaultAccountId: json['default_account_id'] as String?,
      enableNotifications: json['enable_notifications'] as bool? ?? true,
      enableEmailReports: json['enable_email_reports'] as bool? ?? false,
      reportFrequency: json['report_frequency'] as String? ?? 'weekly',
      lowBalanceAlert: json['low_balance_alert'] as bool? ?? true,
      lowBalanceThreshold:
          (json['low_balance_threshold'] as num?)?.toDouble() ?? 500000,
      budgetAlertPercentage: json['budget_alert_percentage'] as int? ?? 80,
      investmentAlertPercentage:
          json['investment_alert_percentage'] as int? ?? 10,
    );
  }

  Map<String, dynamic> toFirestore() {
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
    };
  }

  factory UserSettings.fromFirestore(Map<String, dynamic> doc) {
    return UserSettings(
      currencyCode: doc['currency_code'] as String? ?? 'IDR',
      currencySymbol: doc['currency_symbol'] as String? ?? 'Rp',
      dateFormat: doc['date_format'] as String? ?? 'DD/MM/YYYY',
      firstDayOfWeek: doc['first_day_of_week'] as int? ?? 1,
      decimalSeparator: doc['decimal_separator'] as String? ?? ',',
      thousandSeparator: doc['thousand_separator'] as String? ?? '.',
      defaultAccountId: doc['default_account_id'] as String?,
      enableNotifications: doc['enable_notifications'] as bool? ?? true,
      enableEmailReports: doc['enable_email_reports'] as bool? ?? false,
      reportFrequency: doc['report_frequency'] as String? ?? 'weekly',
      lowBalanceAlert: doc['low_balance_alert'] as bool? ?? true,
      lowBalanceThreshold:
          (doc['low_balance_threshold'] as num?)?.toDouble() ?? 500000,
      budgetAlertPercentage: doc['budget_alert_percentage'] as int? ?? 80,
      investmentAlertPercentage:
          doc['investment_alert_percentage'] as int? ?? 10,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserSettings &&
        other.currencyCode == currencyCode &&
        other.currencySymbol == currencySymbol &&
        other.dateFormat == dateFormat &&
        other.firstDayOfWeek == firstDayOfWeek &&
        other.decimalSeparator == decimalSeparator &&
        other.thousandSeparator == thousandSeparator &&
        other.defaultAccountId == defaultAccountId &&
        other.enableNotifications == enableNotifications &&
        other.enableEmailReports == enableEmailReports &&
        other.reportFrequency == reportFrequency &&
        other.lowBalanceAlert == lowBalanceAlert &&
        other.lowBalanceThreshold == lowBalanceThreshold &&
        other.budgetAlertPercentage == budgetAlertPercentage &&
        other.investmentAlertPercentage == investmentAlertPercentage;
  }

  @override
  int get hashCode {
    return Object.hash(
      currencyCode,
      currencySymbol,
      dateFormat,
      firstDayOfWeek,
      decimalSeparator,
      thousandSeparator,
      defaultAccountId,
      enableNotifications,
      enableEmailReports,
      reportFrequency,
      lowBalanceAlert,
      lowBalanceThreshold,
      budgetAlertPercentage,
      investmentAlertPercentage,
    );
  }
}

class UserRegistrationRequest {
  final String email;
  final String password;
  final String fullName;
  final String? phone;
  final String currency;
  final String timezone;

  const UserRegistrationRequest({
    required this.email,
    required this.password,
    required this.fullName,
    this.phone,
    this.currency = 'IDR',
    this.timezone = 'Asia/Jakarta',
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'full_name': fullName,
      'phone': phone,
      'currency': currency,
      'timezone': timezone,
    };
  }

  factory UserRegistrationRequest.fromJson(Map<String, dynamic> json) {
    return UserRegistrationRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      currency: json['currency'] as String? ?? 'IDR',
      timezone: json['timezone'] as String? ?? 'Asia/Jakarta',
    );
  }
}

class UserLoginRequest {
  final String email;
  final String password;
  final DeviceInfo? deviceInfo;

  const UserLoginRequest({
    required this.email,
    required this.password,
    this.deviceInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      if (deviceInfo != null) 'device_info': deviceInfo!.toJson(),
    };
  }

  factory UserLoginRequest.fromJson(Map<String, dynamic> json) {
    return UserLoginRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      deviceInfo: json['device_info'] != null
          ? DeviceInfo.fromJson(json['device_info'] as Map<String, dynamic>)
          : null,
    );
  }
}

class DeviceInfo {
  final String name;
  final String platform;
  final String version;

  const DeviceInfo({
    required this.name,
    required this.platform,
    required this.version,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'platform': platform,
      'version': version,
    };
  }

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      name: json['name'] as String,
      platform: json['platform'] as String,
      version: json['version'] as String,
    );
  }
}

class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    this.expiresIn = 900,
  });

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_in': expiresIn,
    };
  }

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresIn: json['expires_in'] as int? ?? 900,
    );
  }
}

class AuthResponse {
  final User user;
  final AuthTokens tokens;
  final bool isNewUser;

  const AuthResponse({
    required this.user,
    required this.tokens,
    this.isNewUser = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'tokens': tokens.toJson(),
      'is_new_user': isNewUser,
    };
  }

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      tokens: AuthTokens.fromJson(json['tokens'] as Map<String, dynamic>),
      isNewUser: json['is_new_user'] as bool? ?? false,
    );
  }
}
