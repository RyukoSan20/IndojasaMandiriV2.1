
class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? profileImageUrl;
  final UserProfile profile;
  final UserPreferences preferences;
  final UserSecurity security;
  final List<String> linkedAccounts;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool isActive;
  final String? referralCode;
  final String? referredBy;
  final UserSubscription subscription;
  final List<NotificationSettings> notificationSettings;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.profileImageUrl,
    required this.profile,
    required this.preferences,
    required this.security,
    required this.linkedAccounts,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.isActive = true,
    this.referralCode,
    this.referredBy,
    required this.subscription,
    required this.notificationSettings,
  });

  String get fullName => '$firstName $lastName';

  String get displayName => profile.displayName ?? fullName;

  bool get hasCompletedOnboarding => profile.onboardingCompleted;

  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profileImageUrl,
    UserProfile? profile,
    UserPreferences? preferences,
    UserSecurity? security,
    List<String>? linkedAccounts,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    bool? isActive,
    String? referralCode,
    String? referredBy,
    UserSubscription? subscription,
    List<NotificationSettings>? notificationSettings,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      profile: profile ?? this.profile,
      preferences: preferences ?? this.preferences,
      security: security ?? this.security,
      linkedAccounts: linkedAccounts ?? this.linkedAccounts,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isActive: isActive ?? this.isActive,
      referralCode: referralCode ?? this.referralCode,
      referredBy: referredBy ?? this.referredBy,
      subscription: subscription ?? this.subscription,
      notificationSettings: notificationSettings ?? this.notificationSettings,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      profile: UserProfile.fromJson(json['profile'] as Map<String, dynamic>),
      preferences: UserPreferences.fromJson(json['preferences'] as Map<String, dynamic>),
      security: UserSecurity.fromJson(json['security'] as Map<String, dynamic>),
      linkedAccounts: List<String>.from(json['linkedAccounts'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isPhoneVerified: json['isPhoneVerified'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      referralCode: json['referralCode'] as String?,
      referredBy: json['referredBy'] as String?,
      subscription: UserSubscription.fromJson(json['subscription'] as Map<String, dynamic>),
      notificationSettings: (json['notificationSettings'] as List<dynamic>?)
              ?.map((e) => NotificationSettings.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'profile': profile.toJson(),
      'preferences': preferences.toJson(),
      'security': security.toJson(),
      'linkedAccounts': linkedAccounts,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'isActive': isActive,
      'referralCode': referralCode,
      'referredBy': referredBy,
      'subscription': subscription.toJson(),
      'notificationSettings': notificationSettings.map((e) => e.toJson()).toList(),
    };
  }
}

class UserProfile {
  final String? displayName;
  final String? bio;
  final String? dateOfBirth;
  final String? country;
  final String? currency;
  final String? language;
  final String? timezone;
  final String? address;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? countryCode;
  final bool onboardingCompleted;
  final Map<String, dynamic>? metadata;

  UserProfile({
    this.displayName,
    this.bio,
    this.dateOfBirth,
    this.country,
    this.currency = 'USD',
    this.language = 'en',
    this.timezone = 'UTC',
    this.address,
    this.city,
    this.state,
    this.postalCode,
    this.countryCode,
    this.onboardingCompleted = false,
    this.metadata,
  });

  UserProfile copyWith({
    String? displayName,
    String? bio,
    String? dateOfBirth,
    String? country,
    String? currency,
    String? language,
    String? timezone,
    String? address,
    String? city,
    String? state,
    String? postalCode,
    String? countryCode,
    bool? onboardingCompleted,
    Map<String, dynamic>? metadata,
  }) {
    return UserProfile(
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      country: country ?? this.country,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      timezone: timezone ?? this.timezone,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      countryCode: countryCode ?? this.countryCode,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      metadata: metadata ?? this.metadata,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      displayName: json['displayName'] as String?,
      bio: json['bio'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      country: json['country'] as String?,
      currency: json['currency'] as String? ?? 'USD',
      language: json['language'] as String? ?? 'en',
      timezone: json['timezone'] as String? ?? 'UTC',
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      postalCode: json['postalCode'] as String?,
      countryCode: json['countryCode'] as String?,
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'bio': bio,
      'dateOfBirth': dateOfBirth,
      'country': country,
      'currency': currency,
      'language': language,
      'timezone': timezone,
      'address': address,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'countryCode': countryCode,
      'onboardingCompleted': onboardingCompleted,
      'metadata': metadata,
    };
  }
}

class UserPreferences {
  final String defaultCurrency;
  final String dateFormat;
  final String numberFormat;
  final String theme;
  final bool darkMode;
  final bool compactMode;
  final String defaultAccountId;
  final String defaultView;
  final List<String> favoriteStocks;
  final Map<String, bool> dashboardWidgets;
  final bool showNetWorth;
  final bool showStockPerformance;
  final bool autoRefreshData;
  final int refreshIntervalMinutes;

  UserPreferences({
    this.defaultCurrency = 'USD',
    this.dateFormat = 'MM/DD/YYYY',
    this.numberFormat = 'en_US',
    this.theme = 'system',
    this.darkMode = false,
    this.compactMode = false,
    this.defaultAccountId = '',
    this.defaultView = 'dashboard',
    this.favoriteStocks = const [],
    this.dashboardWidgets = const {},
    this.showNetWorth = true,
    this.showStockPerformance = true,
    this.autoRefreshData = true,
    this.refreshIntervalMinutes = 15,
  });

  UserPreferences copyWith({
    String? defaultCurrency,
    String? dateFormat,
    String? numberFormat,
    String? theme,
    bool? darkMode,
    bool? compactMode,
    String? defaultAccountId,
    String? defaultView,
    List<String>? favoriteStocks,
    Map<String, bool>? dashboardWidgets,
    bool? showNetWorth,
    bool? showStockPerformance,
    bool? autoRefreshData,
    int? refreshIntervalMinutes,
  }) {
    return UserPreferences(
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      dateFormat: dateFormat ?? this.dateFormat,
      numberFormat: numberFormat ?? this.numberFormat,
      theme: theme ?? this.theme,
      darkMode: darkMode ?? this.darkMode,
      compactMode: compactMode ?? this.compactMode,
      defaultAccountId: defaultAccountId ?? this.defaultAccountId,
      defaultView: defaultView ?? this.defaultView,
      favoriteStocks: favoriteStocks ?? this.favoriteStocks,
      dashboardWidgets: dashboardWidgets ?? this.dashboardWidgets,
      showNetWorth: showNetWorth ?? this.showNetWorth,
      showStockPerformance: showStockPerformance ?? this.showStockPerformance,
      autoRefreshData: autoRefreshData ?? this.autoRefreshData,
      refreshIntervalMinutes: refreshIntervalMinutes ?? this.refreshIntervalMinutes,
    );
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      defaultCurrency: json['defaultCurrency'] as String? ?? 'USD',
      dateFormat: json['dateFormat'] as String? ?? 'MM/DD/YYYY',
      numberFormat: json['numberFormat'] as String? ?? 'en_US',
      theme: json['theme'] as String? ?? 'system',
      darkMode: json['darkMode'] as bool? ?? false,
      compactMode: json['compactMode'] as bool? ?? false,
      defaultAccountId: json['defaultAccountId'] as String? ?? '',
      defaultView: json['defaultView'] as String? ?? 'dashboard',
      favoriteStocks: List<String>.from(json['favoriteStocks'] ?? []),
      dashboardWidgets: Map<String, bool>.from(json['dashboardWidgets'] ?? {}),
      showNetWorth: json['showNetWorth'] as bool? ?? true,
      showStockPerformance: json['showStockPerformance'] as bool? ?? true,
      autoRefreshData: json['autoRefreshData'] as bool? ?? true,
      refreshIntervalMinutes: json['refreshIntervalMinutes'] as int? ?? 15,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defaultCurrency': defaultCurrency,
      'dateFormat': dateFormat,
      'numberFormat': numberFormat,
      'theme': theme,
      'darkMode': darkMode,
      'compactMode': compactMode,
      'defaultAccountId': defaultAccountId,
      'defaultView': defaultView,
      'favoriteStocks': favoriteStocks,
      'dashboardWidgets': dashboardWidgets,
      'showNetWorth': showNetWorth,
      'showStockPerformance': showStockPerformance,
      'autoRefreshData': autoRefreshData,
      'refreshIntervalMinutes': refreshIntervalMinutes,
    };
  }
}

class UserSecurity {
  final bool twoFactorEnabled;
  final String? twoFactorMethod;
  final String? twoFactorPhone;
  final List<String> trustedDevices;
  final List<String> trustedBrowsers;
  final String? lastPasswordChange;
  final int failedLoginAttempts;
  final DateTime? lockoutUntil;
  final bool biometricEnabled;
  final String? biometricType;
  final List<String> backupCodes;
  final String securityQuestionsStatus;

  UserSecurity({
    this.twoFactorEnabled = false,
    this.twoFactorMethod,
    this.twoFactorPhone,
    this.trustedDevices = const [],
    this.trustedBrowsers = const [],
    this.lastPasswordChange,
    this.failedLoginAttempts = 0,
    this.lockoutUntil,
    this.biometricEnabled = false,
    this.biometricType,
    this.backupCodes = const [],
    this.securityQuestionsStatus = 'not_set',
  });

  bool get isLockedOut {
    if (lockoutUntil == null) return false;
    return DateTime.now().isBefore(lockoutUntil!);
  }

  int get lockoutRemainingMinutes {
    if (lockoutUntil == null) return 0;
    final remaining = lockoutUntil!.difference(DateTime.now()).inMinutes;
    return remaining > 0 ? remaining : 0;
  }

  UserSecurity copyWith({
    bool? twoFactorEnabled,
    String? twoFactorMethod,
    String? twoFactorPhone,
    List<String>? trustedDevices,
    List<String>? trustedBrowsers,
    String? lastPasswordChange,
    int? failedLoginAttempts,
    DateTime? lockoutUntil,
    bool? biometricEnabled,
    String? biometricType,
    List<String>? backupCodes,
    String? securityQuestionsStatus,
  }) {
    return UserSecurity(
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      twoFactorMethod: twoFactorMethod ?? this.twoFactorMethod,
      twoFactorPhone: twoFactorPhone ?? this.twoFactorPhone,
      trustedDevices: trustedDevices ?? this.trustedDevices,
      trustedBrowsers: trustedBrowsers ?? this.trustedBrowsers,
      lastPasswordChange: lastPasswordChange ?? this.lastPasswordChange,
      failedLoginAttempts: failedLoginAttempts ?? this.failedLoginAttempts,
      lockoutUntil: lockoutUntil ?? this.lockoutUntil,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      biometricType: biometricType ?? this.biometricType,
      backupCodes: backupCodes ?? this.backupCodes,
      securityQuestionsStatus: securityQuestionsStatus ?? this.securityQuestionsStatus,
    );
  }

  factory UserSecurity.fromJson(Map<String, dynamic> json) {
    return UserSecurity(
      twoFactorEnabled: json['twoFactorEnabled'] as bool? ?? false,
      twoFactorMethod: json['twoFactorMethod'] as String?,
      twoFactorPhone: json['twoFactorPhone'] as String?,
      trustedDevices: List<String>.from(json['trustedDevices'] ?? []),
      trustedBrowsers: List<String>.from(json['trustedBrowsers'] ?? []),
      lastPasswordChange: json['lastPasswordChange'] as String?,
      failedLoginAttempts: json['failedLoginAttempts'] as int? ?? 0,
      lockoutUntil: json['lockoutUntil'] != null
          ? DateTime.parse(json['lockoutUntil'] as String)
          : null,
      biometricEnabled: json['biometricEnabled'] as bool? ?? false,
      biometricType: json['biometricType'] as String?,
      backupCodes: List<String>.from(json['backupCodes'] ?? []),
      securityQuestionsStatus: json['securityQuestionsStatus'] as String? ?? 'not_set',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'twoFactorEnabled': twoFactorEnabled,
      'twoFactorMethod': twoFactorMethod,
      'twoFactorPhone': twoFactorPhone,
      'trustedDevices': trustedDevices,
      'trustedBrowsers': trustedBrowsers,
      'lastPasswordChange': lastPasswordChange,
      'failedLoginAttempts': failedLoginAttempts,
      'lockoutUntil': lockoutUntil?.toIso8601String(),
      'biometricEnabled': biometricEnabled,
      'biometricType': biometricType,
      'backupCodes': backupCodes,
      'securityQuestionsStatus': securityQuestionsStatus,
    };
  }
}

class UserSubscription {
  final String plan;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? nextBillingDate;
  final double? monthlyPrice;
  final String? billingCycle;
  final String? paymentMethod;
  final String? subscriptionId;
  final bool autoRenew;
  final List<String> features;
  final int? maxAccounts;
  final int? maxGoals;
  final int? maxTransactions;

  UserSubscription({
    this.plan = 'free',
    this.status = 'active',
    this.startDate,
    this.endDate,
    this.nextBillingDate,
    this.monthlyPrice,
    this.billingCycle = 'monthly',
    this.paymentMethod,
    this.subscriptionId,
    this.autoRenew = true,
    this.features = const [],
    this.maxAccounts = 3,
    this.maxGoals = 5,
    this.maxTransactions = 100,
  });

  bool get isPremium => plan != 'free';

  bool get isExpired {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!);
  }

  int get daysRemaining {
    if (nextBillingDate == null) return 0;
    return nextBillingDate!.difference(DateTime.now()).inDays;
  }

  UserSubscription copyWith({
    String? plan,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? nextBillingDate,
    double? monthlyPrice,
    String? billingCycle,
    String? paymentMethod,
    String? subscriptionId,
    bool? autoRenew,
    List<String>? features,
    int? maxAccounts,
    int? maxGoals,
    int? maxTransactions,
  }) {
    return UserSubscription(
      plan: plan ?? this.plan,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      billingCycle: billingCycle ?? this.billingCycle,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      autoRenew: autoRenew ?? this.autoRenew,
      features: features ?? this.features,
      maxAccounts: maxAccounts ?? this.maxAccounts,
      maxGoals: maxGoals ?? this.maxGoals,
      maxTransactions: maxTransactions ?? this.maxTransactions,
    );
  }

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      plan: json['plan'] as String? ?? 'free',
      status: json['status'] as String? ?? 'active',
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      nextBillingDate: json['nextBillingDate'] != null
          ? DateTime.parse(json['nextBillingDate'] as String)
          : null,
      monthlyPrice: (json['monthlyPrice'] as num?)?.toDouble(),
      billingCycle: json['billingCycle'] as String? ?? 'monthly',
      paymentMethod: json['paymentMethod'] as String?,
      subscriptionId: json['subscriptionId'] as String?,
      autoRenew: json['autoRenew'] as bool? ?? true,
      features: List<String>.from(json['features'] ?? []),
      maxAccounts: json['maxAccounts'] as int? ?? 3,
      maxGoals: json['maxGoals'] as int? ?? 5,
      maxTransactions: json['maxTransactions'] as int? ?? 100,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan': plan,
      'status': status,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'nextBillingDate': nextBillingDate?.toIso8601String(),
      'monthlyPrice': monthlyPrice,
      'billingCycle': billingCycle,
      'paymentMethod': paymentMethod,
      'subscriptionId': subscriptionId,
      'autoRenew': autoRenew,
      'features': features,
      'maxAccounts': maxAccounts,
      'maxGoals': maxGoals,
      'maxTransactions': maxTransactions,
    };
  }
}

class NotificationSettings {
  final String type;
  final bool emailEnabled;
  final bool pushEnabled;
  final bool smsEnabled;
  final bool inAppEnabled;
  final List<String> frequency;

  NotificationSettings({
    required this.type,
    this.emailEnabled = true,
    this.pushEnabled = true,
    this.smsEnabled = false,
    this.inAppEnabled = true,
    this.frequency = const ['realtime'],
  });

  NotificationSettings copyWith({
    String? type,
    bool? emailEnabled,
    bool? pushEnabled,
    bool? smsEnabled,
    bool? inAppEnabled,
    List<String>? frequency,
  }) {
    return NotificationSettings(
      type: type ?? this.type,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      smsEnabled: smsEnabled ?? this.smsEnabled,
      inAppEnabled: inAppEnabled ?? this.inAppEnabled,
      frequency: frequency ?? this.frequency,
    );
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      type: json['type'] as String,
      emailEnabled: json['emailEnabled'] as bool? ?? true,
      pushEnabled: json['pushEnabled'] as bool? ?? true,
      smsEnabled: json['smsEnabled'] as bool? ?? false,
      inAppEnabled: json['inAppEnabled'] as bool? ?? true,
      frequency: List<String>.from(json['frequency'] ?? ['realtime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'emailEnabled': emailEnabled,
      'pushEnabled': pushEnabled,
      'smsEnabled': smsEnabled,
      'inAppEnabled': inAppEnabled,
      'frequency': frequency,
    };
  }
}
