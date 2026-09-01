import 'dart:convert';

class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? avatarUrl;
  final UserProfile profile;
  final UserFinancialSettings financialSettings;
  final UserSecuritySettings securitySettings;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool isActive;
  final String? referralCode;
  final String? referredBy;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.avatarUrl,
    required this.profile,
    required this.financialSettings,
    required this.securitySettings,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.isActive = true,
    this.referralCode,
    this.referredBy,
  });

  String get fullName => '$firstName $lastName';

  String get initials {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last';
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? avatarUrl,
    UserProfile? profile,
    UserFinancialSettings? financialSettings,
    UserSecuritySettings? securitySettings,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    bool? isActive,
    String? referralCode,
    String? referredBy,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      profile: profile ?? this.profile,
      financialSettings: financialSettings ?? this.financialSettings,
      securitySettings: securitySettings ?? this.securitySettings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isActive: isActive ?? this.isActive,
      referralCode: referralCode ?? this.referralCode,
      referredBy: referredBy ?? this.referredBy,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'profile': profile.toMap(),
      'financialSettings': financialSettings.toMap(),
      'securitySettings': securitySettings.toMap(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'isActive': isActive,
      'referralCode': referralCode,
      'referredBy': referredBy,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      phoneNumber: map['phoneNumber'] as String?,
      avatarUrl: map['avatarUrl'] as String?,
      profile: UserProfile.fromMap(map['profile'] as Map<String, dynamic>),
      financialSettings: UserFinancialSettings.fromMap(
        map['financialSettings'] as Map<String, dynamic>,
      ),
      securitySettings: UserSecuritySettings.fromMap(
        map['securitySettings'] as Map<String, dynamic>,
      ),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      lastLoginAt: map['lastLoginAt'] != null
          ? DateTime.parse(map['lastLoginAt'] as String)
          : null,
      isEmailVerified: map['isEmailVerified'] as bool? ?? false,
      isPhoneVerified: map['isPhoneVerified'] as bool? ?? false,
      isActive: map['isActive'] as bool? ?? true,
      referralCode: map['referralCode'] as String?,
      referredBy: map['referredBy'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, firstName: $firstName, lastName: $lastName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id && other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}

class UserProfile {
  final String? dateOfBirth;
  final String? gender;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final String? timezone;
  final String? language;
  final String? currency;
  final String? occupation;
  final double? annualIncome;
  final String? employerName;

  UserProfile({
    this.dateOfBirth,
    this.gender,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.timezone,
    this.language,
    this.currency,
    this.occupation,
    this.annualIncome,
    this.employerName,
  });

  UserProfile copyWith({
    String? dateOfBirth,
    String? gender,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? timezone,
    String? language,
    String? currency,
    String? occupation,
    double? annualIncome,
    String? employerName,
  }) {
    return UserProfile(
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      timezone: timezone ?? this.timezone,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      occupation: occupation ?? this.occupation,
      annualIncome: annualIncome ?? this.annualIncome,
      employerName: employerName ?? this.employerName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'timezone': timezone,
      'language': language,
      'currency': currency,
      'occupation': occupation,
      'annualIncome': annualIncome,
      'employerName': employerName,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      dateOfBirth: map['dateOfBirth'] as String?,
      gender: map['gender'] as String?,
      address: map['address'] as String?,
      city: map['city'] as String?,
      state: map['state'] as String?,
      country: map['country'] as String?,
      postalCode: map['postalCode'] as String?,
      timezone: map['timezone'] as String?,
      language: map['language'] as String?,
      currency: map['currency'] as String?,
      occupation: map['occupation'] as String?,
      annualIncome: (map['annualIncome'] as num?)?.toDouble(),
      employerName: map['employerName'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfile.fromJson(String source) =>
      UserProfile.fromMap(json.decode(source) as Map<String, dynamic>);
}

class UserFinancialSettings {
  final String defaultCurrency;
  final String dateFormat;
  final String numberFormat;
  final bool enableNotifications;
  final bool enableEmailReports;
  final bool enableSmsAlerts;
  final bool enablePushNotifications;
  final double? monthlyBudgetLimit;
  final List<String> enabledCategories;
  final bool autoCategorizeTransactions;
  final bool roundUpSavings;
  final double? roundUpAmount;

  UserFinancialSettings({
    this.defaultCurrency = 'USD',
    this.dateFormat = 'yyyy-MM-dd',
    this.numberFormat = 'en_US',
    this.enableNotifications = true,
    this.enableEmailReports = true,
    this.enableSmsAlerts = false,
    this.enablePushNotifications = true,
    this.monthlyBudgetLimit,
    this.enabledCategories = const [],
    this.autoCategorizeTransactions = true,
    this.roundUpSavings = false,
    this.roundUpAmount,
  });

  UserFinancialSettings copyWith({
    String? defaultCurrency,
    String? dateFormat,
    String? numberFormat,
    bool? enableNotifications,
    bool? enableEmailReports,
    bool? enableSmsAlerts,
    bool? enablePushNotifications,
    double? monthlyBudgetLimit,
    List<String>? enabledCategories,
    bool? autoCategorizeTransactions,
    bool? roundUpSavings,
    double? roundUpAmount,
  }) {
    return UserFinancialSettings(
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      dateFormat: dateFormat ?? this.dateFormat,
      numberFormat: numberFormat ?? this.numberFormat,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableEmailReports: enableEmailReports ?? this.enableEmailReports,
      enableSmsAlerts: enableSmsAlerts ?? this.enableSmsAlerts,
      enablePushNotifications:
          enablePushNotifications ?? this.enablePushNotifications,
      monthlyBudgetLimit: monthlyBudgetLimit ?? this.monthlyBudgetLimit,
      enabledCategories: enabledCategories ?? this.enabledCategories,
      autoCategorizeTransactions:
          autoCategorizeTransactions ?? this.autoCategorizeTransactions,
      roundUpSavings: roundUpSavings ?? this.roundUpSavings,
      roundUpAmount: roundUpAmount ?? this.roundUpAmount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'defaultCurrency': defaultCurrency,
      'dateFormat': dateFormat,
      'numberFormat': numberFormat,
      'enableNotifications': enableNotifications,
      'enableEmailReports': enableEmailReports,
      'enableSmsAlerts': enableSmsAlerts,
      'enablePushNotifications': enablePushNotifications,
      'monthlyBudgetLimit': monthlyBudgetLimit,
      'enabledCategories': enabledCategories,
      'autoCategorizeTransactions': autoCategorizeTransactions,
      'roundUpSavings': roundUpSavings,
      'roundUpAmount': roundUpAmount,
    };
  }

  factory UserFinancialSettings.fromMap(Map<String, dynamic> map) {
    return UserFinancialSettings(
      defaultCurrency: map['defaultCurrency'] as String? ?? 'USD',
      dateFormat: map['dateFormat'] as String? ?? 'yyyy-MM-dd',
      numberFormat: map['numberFormat'] as String? ?? 'en_US',
      enableNotifications: map['enableNotifications'] as bool? ?? true,
      enableEmailReports: map['enableEmailReports'] as bool? ?? true,
      enableSmsAlerts: map['enableSmsAlerts'] as bool? ?? false,
      enablePushNotifications: map['enablePushNotifications'] as bool? ?? true,
      monthlyBudgetLimit: (map['monthlyBudgetLimit'] as num?)?.toDouble(),
      enabledCategories: (map['enabledCategories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      autoCategorizeTransactions:
          map['autoCategorizeTransactions'] as bool? ?? true,
      roundUpSavings: map['roundUpSavings'] as bool? ?? false,
      roundUpAmount: (map['roundUpAmount'] as num?)?.toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserFinancialSettings.fromJson(String source) =>
      UserFinancialSettings.fromMap(
          json.decode(source) as Map<String, dynamic>);
}

class UserSecuritySettings {
  final bool twoFactorEnabled;
  final String? twoFactorMethod;
  final bool biometricLoginEnabled;
  final bool loginNotifications;
  final bool deviceTracking;
  final int sessionTimeoutMinutes;
  final int maxLoginAttempts;
  final String? lastKnownIp;
  final DateTime? lastSecurityAlertAt;
  final List<String> trustedDevices;

  UserSecuritySettings({
    this.twoFactorEnabled = false,
    this.twoFactorMethod,
    this.biometricLoginEnabled = false,
    this.loginNotifications = true,
    this.deviceTracking = true,
    this.sessionTimeoutMinutes = 30,
    this.maxLoginAttempts = 5,
    this.lastKnownIp,
    this.lastSecurityAlertAt,
    this.trustedDevices = const [],
  });

  UserSecuritySettings copyWith({
    bool? twoFactorEnabled,
    String? twoFactorMethod,
    bool? biometricLoginEnabled,
    bool? loginNotifications,
    bool? deviceTracking,
    int? sessionTimeoutMinutes,
    int? maxLoginAttempts,
    String? lastKnownIp,
    DateTime? lastSecurityAlertAt,
    List<String>? trustedDevices,
  }) {
    return UserSecuritySettings(
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      twoFactorMethod: twoFactorMethod ?? this.twoFactorMethod,
      biometricLoginEnabled:
          biometricLoginEnabled ?? this.biometricLoginEnabled,
      loginNotifications: loginNotifications ?? this.loginNotifications,
      deviceTracking: deviceTracking ?? this.deviceTracking,
      sessionTimeoutMinutes:
          sessionTimeoutMinutes ?? this.sessionTimeoutMinutes,
      maxLoginAttempts: maxLoginAttempts ?? this.maxLoginAttempts,
      lastKnownIp: lastKnownIp ?? this.lastKnownIp,
      lastSecurityAlertAt: lastSecurityAlertAt ?? this.lastSecurityAlertAt,
      trustedDevices: trustedDevices ?? this.trustedDevices,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'twoFactorEnabled': twoFactorEnabled,
      'twoFactorMethod': twoFactorMethod,
      'biometricLoginEnabled': biometricLoginEnabled,
      'loginNotifications': loginNotifications,
      'deviceTracking': deviceTracking,
      'sessionTimeoutMinutes': sessionTimeoutMinutes,
      'maxLoginAttempts': maxLoginAttempts,
      'lastKnownIp': lastKnownIp,
      'lastSecurityAlertAt': lastSecurityAlertAt?.toIso8601String(),
      'trustedDevices': trustedDevices,
    };
  }

  factory UserSecuritySettings.fromMap(Map<String, dynamic> map) {
    return UserSecuritySettings(
      twoFactorEnabled: map['twoFactorEnabled'] as bool? ?? false,
      twoFactorMethod: map['twoFactorMethod'] as String?,
      biometricLoginEnabled: map['biometricLoginEnabled'] as bool? ?? false,
      loginNotifications: map['loginNotifications'] as bool? ?? true,
      deviceTracking: map['deviceTracking'] as bool? ?? true,
      sessionTimeoutMinutes: map['sessionTimeoutMinutes'] as int? ?? 30,
      maxLoginAttempts: map['maxLoginAttempts'] as int? ?? 5,
      lastKnownIp: map['lastKnownIp'] as String?,
      lastSecurityAlertAt: map['lastSecurityAlertAt'] != null
          ? DateTime.parse(map['lastSecurityAlertAt'] as String)
          : null,
      trustedDevices: (map['trustedDevices'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  String toJson() => json.encode(toMap());

  factory UserSecuritySettings.fromJson(String source) =>
      UserSecuritySettings.fromMap(
          json.decode(source) as Map<String, dynamic>);
}
