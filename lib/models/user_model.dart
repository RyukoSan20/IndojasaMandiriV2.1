/// User model for FinTrack application
/// Represents the user entity with authentication and profile data

class UserModel {
  /// Unique identifier for the user
  final String id;

  /// User's email address (unique, used for authentication)
  final String email;

  /// User's display name
  final String name;

  /// User's first name
  final String? firstName;

  /// User's last name
  final String? lastName;

  /// Phone number (optional)
  final String? phoneNumber;

  /// Profile picture URL
  final String? avatarUrl;

  /// Hashed password (bcrypt/sha256)
  final String? passwordHash;

  /// User's date of birth
  final DateTime? dateOfBirth;

  /// User's timezone identifier
  final String timezone;

  /// User's preferred locale/language code
  final String locale;

  /// User's preferred currency code (ISO 4217)
  final String currency;

  /// User's country code (ISO 3166-1 alpha-2)
  final String? country;

  /// Email verification status
  final bool isEmailVerified;

  /// Phone verification status
  final bool isPhoneVerified;

  /// Account status (active, suspended, deleted)
  final String accountStatus;

  /// User's risk tolerance level for investments
  final String riskTolerance;

  /// Investment experience level
  final String investmentExperience;

  /// Two-factor authentication enabled
  final bool twoFactorEnabled;

  /// Two-factor authentication method
  final String? twoFactorMethod;

  /// Notification preferences - email enabled
  final bool notificationEmailEnabled;

  /// Notification preferences - push enabled
  final bool notificationPushEnabled;

  /// Notification preferences - SMS enabled
  final bool notificationSmsEnabled;

  /// Marketing communications enabled
  final bool marketingEnabled;

  /// Last login timestamp
  final DateTime? lastLoginAt;

  /// Account creation timestamp
  final DateTime createdAt;

  /// Last update timestamp
  final DateTime updatedAt;

  /// User's total net worth (calculated)
  final double? totalNetWorth;

  /// User's monthly income (for budgeting)
  final double? monthlyIncome;

  /// Default budget category ID
  final String? defaultBudgetId;

  /// Preferred chart theme (light/dark/system)
  final String chartTheme;

  /// Dashboard layout preference (JSON string)
  final String? dashboardLayout;

  /// Connected accounts count
  final int connectedAccountsCount;

  /// User's financial goals summary
  final int activeGoalsCount;

  /// Portfolio value
  final double? portfolioValue;

  /// Email change pending verification
  final String? pendingEmailChange;

  /// Password change timestamp (for session invalidation)
  final DateTime? passwordChangedAt;

  /// Account deletion scheduled date (if pending deletion)
  final DateTime? deletionScheduledAt;

  /// Referral code for user referral program
  final String? referralCode;

  /// Who referred this user
  final String? referredByUserId;

  /// User's subscription tier
  final String subscriptionTier;

  /// Subscription expiration date
  final DateTime? subscriptionExpiresAt;

  /// API rate limit tier
  final String apiRateLimitTier;

  /// Data export format preference
  final String dataExportFormat;

  /// GDPR consent given
  final bool gdprConsentGiven;

  /// Privacy policy accepted
  final bool privacyPolicyAccepted;

  /// Terms of service accepted
  final bool termsOfServiceAccepted;

  /// Marketing consent given
  final bool marketingConsentGiven;

  /// User's investment horizon in years
  final int? investmentHorizonYears;

  /// Monthly budget limit
  final double? monthlyBudgetLimit;

  /// Emergency fund target amount
  final double? emergencyFundTarget;

  /// Current emergency fund amount
  final double? emergencyFundCurrent;

  /// Default account ID for transactions
  final String? defaultAccountId;

  /// Quick actions pinned on dashboard
  final List<String>? pinnedQuickActions;

  /// Favorite transaction categories
  final List<String>? favoriteCategories;

  /// Social features enabled
  final bool socialFeaturesEnabled;

  /// Profile visibility (public/private)
  final String profileVisibility;

  /// User role (user/admin/premium)
  final String role;

  /// Last activity timestamp
  final DateTime? lastActivityAt;

  /// Login streak count
  final int loginStreak;

  /// Total logins count
  final int totalLogins;

  /// Device tokens for push notifications
  final List<String>? deviceTokens;

  /// Trusted devices list
  final List<String>? trustedDeviceIds;

  /// User preferences (flexible key-value store)
  final Map<String, dynamic>? preferences;

  /// Creates a new UserModel instance
  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.avatarUrl,
    this.passwordHash,
    this.dateOfBirth,
    this.timezone = 'UTC',
    this.locale = 'en',
    this.currency = 'USD',
    this.country,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.accountStatus = 'active',
    this.riskTolerance = 'moderate',
    this.investmentExperience = 'intermediate',
    this.twoFactorEnabled = false,
    this.twoFactorMethod,
    this.notificationEmailEnabled = true,
    this.notificationPushEnabled = true,
    this.notificationSmsEnabled = false,
    this.marketingEnabled = false,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
    this.totalNetWorth,
    this.monthlyIncome,
    this.defaultBudgetId,
    this.chartTheme = 'system',
    this.dashboardLayout,
    this.connectedAccountsCount = 0,
    this.activeGoalsCount = 0,
    this.portfolioValue,
    this.pendingEmailChange,
    this.passwordChangedAt,
    this.deletionScheduledAt,
    this.referralCode,
    this.referredByUserId,
    this.subscriptionTier = 'free',
    this.subscriptionExpiresAt,
    this.apiRateLimitTier = 'standard',
    this.dataExportFormat = 'json',
    this.gdprConsentGiven = false,
    this.privacyPolicyAccepted = false,
    this.termsOfServiceAccepted = false,
    this.marketingConsentGiven = false,
    this.investmentHorizonYears,
    this.monthlyBudgetLimit,
    this.emergencyFundTarget,
    this.emergencyFundCurrent,
    this.defaultAccountId,
    this.pinnedQuickActions,
    this.favoriteCategories,
    this.socialFeaturesEnabled = false,
    this.profileVisibility = 'private',
    this.role = 'user',
    this.lastActivityAt,
    this.loginStreak = 0,
    this.totalLogins = 0,
    this.deviceTokens,
    this.trustedDeviceIds,
    this.preferences,
  });

  /// Creates a UserModel from JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      passwordHash: json['passwordHash'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      timezone: json['timezone'] as String? ?? 'UTC',
      locale: json['locale'] as String? ?? 'en',
      currency: json['currency'] as String? ?? 'USD',
      country: json['country'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isPhoneVerified: json['isPhoneVerified'] as bool? ?? false,
      accountStatus: json['accountStatus'] as String? ?? 'active',
      riskTolerance: json['riskTolerance'] as String? ?? 'moderate',
      investmentExperience:
          json['investmentExperience'] as String? ?? 'intermediate',
      twoFactorEnabled: json['twoFactorEnabled'] as bool? ?? false,
      twoFactorMethod: json['twoFactorMethod'] as String?,
      notificationEmailEnabled:
          json['notificationEmailEnabled'] as bool? ?? true,
      notificationPushEnabled:
          json['notificationPushEnabled'] as bool? ?? true,
      notificationSmsEnabled: json['notificationSmsEnabled'] as bool? ?? false,
      marketingEnabled: json['marketingEnabled'] as bool? ?? false,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      totalNetWorth: (json['totalNetWorth'] as num?)?.toDouble(),
      monthlyIncome: (json['monthlyIncome'] as num?)?.toDouble(),
      defaultBudgetId: json['defaultBudgetId'] as String?,
      chartTheme: json['chartTheme'] as String? ?? 'system',
      dashboardLayout: json['dashboardLayout'] as String?,
      connectedAccountsCount: json['connectedAccountsCount'] as int? ?? 0,
      activeGoalsCount: json['activeGoalsCount'] as int? ?? 0,
      portfolioValue: (json['portfolioValue'] as num?)?.toDouble(),
      pendingEmailChange: json['pendingEmailChange'] as String?,
      passwordChangedAt: json['passwordChangedAt'] != null
          ? DateTime.parse(json['passwordChangedAt'] as String)
          : null,
      deletionScheduledAt: json['deletionScheduledAt'] != null
          ? DateTime.parse(json['deletionScheduledAt'] as String)
          : null,
      referralCode: json['referralCode'] as String?,
      referredByUserId: json['referredByUserId'] as String?,
      subscriptionTier: json['subscriptionTier'] as String? ?? 'free',
      subscriptionExpiresAt: json['subscriptionExpiresAt'] != null
          ? DateTime.parse(json['subscriptionExpiresAt'] as String)
          : null,
      apiRateLimitTier: json['apiRateLimitTier'] as String? ?? 'standard',
      dataExportFormat: json['dataExportFormat'] as String? ?? 'json',
      gdprConsentGiven: json['gdprConsentGiven'] as bool? ?? false,
      privacyPolicyAccepted: json['privacyPolicyAccepted'] as bool? ?? false,
      termsOfServiceAccepted: json['termsOfServiceAccepted'] as bool? ?? false,
      marketingConsentGiven: json['marketingConsentGiven'] as bool? ?? false,
      investmentHorizonYears: json['investmentHorizonYears'] as int?,
      monthlyBudgetLimit: (json['monthlyBudgetLimit'] as num?)?.toDouble(),
      emergencyFundTarget: (json['emergencyFundTarget'] as num?)?.toDouble(),
      emergencyFundCurrent:
          (json['emergencyFundCurrent'] as num?)?.toDouble(),
      defaultAccountId: json['defaultAccountId'] as String?,
      pinnedQuickActions: (json['pinnedQuickActions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      favoriteCategories: (json['favoriteCategories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      socialFeaturesEnabled: json['socialFeaturesEnabled'] as bool? ?? false,
      profileVisibility: json['profileVisibility'] as String? ?? 'private',
      role: json['role'] as String? ?? 'user',
      lastActivityAt: json['lastActivityAt'] != null
          ? DateTime.parse(json['lastActivityAt'] as String)
          : null,
      loginStreak: json['loginStreak'] as int? ?? 0,
      totalLogins: json['totalLogins'] as int? ?? 0,
      deviceTokens: (json['deviceTokens'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      trustedDeviceIds: (json['trustedDeviceIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      preferences: json['preferences'] as Map<String, dynamic>?,
    );
  }

  /// Converts UserModel to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'passwordHash': passwordHash,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'timezone': timezone,
      'locale': locale,
      'currency': currency,
      'country': country,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'accountStatus': accountStatus,
      'riskTolerance': riskTolerance,
      'investmentExperience': investmentExperience,
      'twoFactorEnabled': twoFactorEnabled,
      'twoFactorMethod': twoFactorMethod,
      'notificationEmailEnabled': notificationEmailEnabled,
      'notificationPushEnabled': notificationPushEnabled,
      'notificationSmsEnabled': notificationSmsEnabled,
      'marketingEnabled': marketingEnabled,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'totalNetWorth': totalNetWorth,
      'monthlyIncome': monthlyIncome,
      'defaultBudgetId': defaultBudgetId,
      'chartTheme': chartTheme,
      'dashboardLayout': dashboardLayout,
      'connectedAccountsCount': connectedAccountsCount,
      'activeGoalsCount': activeGoalsCount,
      'portfolioValue': portfolioValue,
      'pendingEmailChange': pendingEmailChange,
      'passwordChangedAt': passwordChangedAt?.toIso8601String(),
      'deletionScheduledAt': deletionScheduledAt?.toIso8601String(),
      'referralCode': referralCode,
      'referredByUserId': referredByUserId,
      'subscriptionTier': subscriptionTier,
      'subscriptionExpiresAt': subscriptionExpiresAt?.toIso8601String(),
      'apiRateLimitTier': apiRateLimitTier,
      'dataExportFormat': dataExportFormat,
      'gdprConsentGiven': gdprConsentGiven,
      'privacyPolicyAccepted': privacyPolicyAccepted,
      'termsOfServiceAccepted': termsOfServiceAccepted,
      'marketingConsentGiven': marketingConsentGiven,
      'investmentHorizonYears': investmentHorizonYears,
      'monthlyBudgetLimit': monthlyBudgetLimit,
      'emergencyFundTarget': emergencyFundTarget,
      'emergencyFundCurrent': emergencyFundCurrent,
      'defaultAccountId': defaultAccountId,
      'pinnedQuickActions': pinnedQuickActions,
      'favoriteCategories': favoriteCategories,
      'socialFeaturesEnabled': socialFeaturesEnabled,
      'profileVisibility': profileVisibility,
      'role': role,
      'lastActivityAt': lastActivityAt?.toIso8601String(),
      'loginStreak': loginStreak,
      'totalLogins': totalLogins,
      'deviceTokens': deviceTokens,
      'trustedDeviceIds': trustedDeviceIds,
      'preferences': preferences,
    };
  }

  /// Creates a copy of UserModel with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? avatarUrl,
    String? passwordHash,
    DateTime? dateOfBirth,
    String? timezone,
    String? locale,
    String? currency,
    String? country,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    String? accountStatus,
    String? riskTolerance,
    String? investmentExperience,
    bool? twoFactorEnabled,
    String? twoFactorMethod,
    bool? notificationEmailEnabled,
    bool? notificationPushEnabled,
    bool? notificationSmsEnabled,
    bool? marketingEnabled,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? totalNetWorth,
    double? monthlyIncome,
    String? defaultBudgetId,
    String? chartTheme,
    String? dashboardLayout,
    int? connectedAccountsCount,
    int? activeGoalsCount,
    double? portfolioValue,
    String? pendingEmailChange,
    DateTime? passwordChangedAt,
    DateTime? deletionScheduledAt,
    String? referralCode,
    String? referredByUserId,
    String? subscriptionTier,
    DateTime? subscriptionExpiresAt,
    String? apiRateLimitTier,
    String? dataExportFormat,
    bool? gdprConsentGiven,
    bool? privacyPolicyAccepted,
    bool? termsOfServiceAccepted,
    bool? marketingConsentGiven,
    int? investmentHorizonYears,
    double? monthlyBudgetLimit,
    double? emergencyFundTarget,
    double? emergencyFundCurrent,
    String? defaultAccountId,
    List<String>? pinnedQuickActions,
    List<String>? favoriteCategories,
    bool? socialFeaturesEnabled,
    String? profileVisibility,
    String? role,
    DateTime? lastActivityAt,
    int? loginStreak,
    int? totalLogins,
    List<String>? deviceTokens,
    List<String>? trustedDeviceIds,
    Map<String, dynamic>? preferences,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      passwordHash: passwordHash ?? this.passwordHash,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      timezone: timezone ?? this.timezone,
      locale: locale ?? this.locale,
      currency: currency ?? this.currency,
      country: country ?? this.country,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      accountStatus: accountStatus ?? this.accountStatus,
      riskTolerance: riskTolerance ?? this.riskTolerance,
      investmentExperience: investmentExperience ?? this.investmentExperience,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      twoFactorMethod: twoFactorMethod ?? this.twoFactorMethod,
      notificationEmailEnabled:
          notificationEmailEnabled ?? this.notificationEmailEnabled,
      notificationPushEnabled:
          notificationPushEnabled ?? this.notificationPushEnabled,
      notificationSmsEnabled:
          notificationSmsEnabled ?? this.notificationSmsEnabled,
      marketingEnabled: marketingEnabled ?? this.marketingEnabled,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalNetWorth: totalNetWorth ?? this.totalNetWorth,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      defaultBudgetId: defaultBudgetId ?? this.defaultBudgetId,
      chartTheme: chartTheme ?? this.chartTheme,
      dashboardLayout: dashboardLayout ?? this.dashboardLayout,
      connectedAccountsCount:
          connectedAccountsCount ?? this.connectedAccountsCount,
      activeGoalsCount: activeGoalsCount ?? this.activeGoalsCount,
      portfolioValue: portfolioValue ?? this.portfolioValue,
      pendingEmailChange: pendingEmailChange ?? this.pendingEmailChange,
      passwordChangedAt: passwordChangedAt ?? this.passwordChangedAt,
      deletionScheduledAt: deletionScheduledAt ?? this.deletionScheduledAt,
      referralCode: referralCode ?? this.referralCode,
      referredByUserId: referredByUserId ?? this.referredByUserId,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      subscriptionExpiresAt:
          subscriptionExpiresAt ?? this.subscriptionExpiresAt,
      apiRateLimitTier: apiRateLimitTier ?? this.apiRateLimitTier,
      dataExportFormat: dataExportFormat ?? this.dataExportFormat,
      gdprConsentGiven: gdprConsentGiven ?? this.gdprConsentGiven,
      privacyPolicyAccepted:
          privacyPolicyAccepted ?? this.privacyPolicyAccepted,
      termsOfServiceAccepted:
          termsOfServiceAccepted ?? this.termsOfServiceAccepted,
      marketingConsentGiven:
          marketingConsentGiven ?? this.marketingConsentGiven,
      investmentHorizonYears:
          investmentHorizonYears ?? this.investmentHorizonYears,
      monthlyBudgetLimit: monthlyBudgetLimit ?? this.monthlyBudgetLimit,
      emergencyFundTarget: emergencyFundTarget ?? this.emergencyFundTarget,
      emergencyFundCurrent:
          emergencyFundCurrent ?? this.emergencyFundCurrent,
      defaultAccountId: defaultAccountId ?? this.defaultAccountId,
      pinnedQuickActions: pinnedQuickActions ?? this.pinnedQuickActions,
      favoriteCategories: favoriteCategories ?? this.favoriteCategories,
      socialFeaturesEnabled:
          socialFeaturesEnabled ?? this.socialFeaturesEnabled,
      profileVisibility: profileVisibility ?? this.profileVisibility,
      role: role ?? this.role,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      loginStreak: loginStreak ?? this.loginStreak,
      totalLogins: totalLogins ?? this.totalLogins,
      deviceTokens: deviceTokens ?? this.deviceTokens,
      trustedDeviceIds: trustedDeviceIds ?? this.trustedDeviceIds,
      preferences: preferences ?? this.preferences,
    );
  }

  /// Returns true if the user account is active
  bool get isActive => accountStatus == 'active';

  /// Returns true if the user is a premium subscriber
  bool get isPremium =>
      subscriptionTier == 'premium' ||
      subscriptionTier == 'pro' ||
      subscriptionTier == 'enterprise';

  /// Returns true if the user has admin privileges
  bool get isAdmin => role == 'admin';

  /// Returns the user's full name
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return name;
  }

  /// Returns initials from the user's name
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  /// Returns emergency fund progress percentage
  double get emergencyFundProgress {
    if (emergencyFundTarget == null || emergencyFundTarget == 0) return 0;
    if (emergencyFundCurrent == null) return 0;
    return (emergencyFundCurrent! / emergencyFundTarget! * 100)
        .clamp(0, 100);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, name: $name, accountStatus: $accountStatus, subscriptionTier: $subscriptionTier)';
  }
}
