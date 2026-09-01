class UserModel {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? phoneNumber;
  final String? avatarUrl;
  final UserProfile? profile;
  final UserSecurity? security;
  final UserPreferences? preferences;
  final UserFinancialProfile? financialProfile;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool isActive;
  final bool isPremium;
  final String? referralCode;
  final String? referredBy;

  UserModel({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.username,
    this.phoneNumber,
    this.avatarUrl,
    this.profile,
    this.security,
    this.preferences,
    this.financialProfile,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.isActive = true,
    this.isPremium = false,
    this.referralCode,
    this.referredBy,
  });

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return firstName ?? lastName ?? username ?? email;
  }

  String get displayName => username ?? firstName ?? email.split('@').first;

  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? username,
    String? phoneNumber,
    String? avatarUrl,
    UserProfile? profile,
    UserSecurity? security,
    UserPreferences? preferences,
    UserFinancialProfile? financialProfile,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    bool? isActive,
    bool? isPremium,
    String? referralCode,
    String? referredBy,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      profile: profile ?? this.profile,
      security: security ?? this.security,
      preferences: preferences ?? this.preferences,
      financialProfile: financialProfile ?? this.financialProfile,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isActive: isActive ?? this.isActive,
      isPremium: isPremium ?? this.isPremium,
      referralCode: referralCode ?? this.referralCode,
      referredBy: referredBy ?? this.referredBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'profile': profile?.toJson(),
      'security': security?.toJson(),
      'preferences': preferences?.toJson(),
      'financialProfile': financialProfile?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'isActive': isActive,
      'isPremium': isPremium,
      'referralCode': referralCode,
      'referredBy': referredBy,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      username: json['username'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      profile: json['profile'] != null
          ? UserProfile.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
      security: json['security'] != null
          ? UserSecurity.fromJson(json['security'] as Map<String, dynamic>)
          : null,
      preferences: json['preferences'] != null
          ? UserPreferences.fromJson(json['preferences'] as Map<String, dynamic>)
          : null,
      financialProfile: json['financialProfile'] != null
          ? UserFinancialProfile.fromJson(
              json['financialProfile'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isPhoneVerified: json['isPhoneVerified'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      isPremium: json['isPremium'] as bool? ?? false,
      referralCode: json['referralCode'] as String?,
      referredBy: json['referredBy'] as String?,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, username: $username, fullName: $fullName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class UserProfile {
  final String? dateOfBirth;
  final String? gender;
  final String? country;
  final String? state;
  final String? city;
  final String? address;
  final String? postalCode;
  final String? timezone;
  final String? language;
  final String? occupation;
  final String? employer;
  final double? annualIncome;
  final String? currency;

  UserProfile({
    this.dateOfBirth,
    this.gender,
    this.country,
    this.state,
    this.city,
    this.address,
    this.postalCode,
    this.timezone,
    this.language,
    this.occupation,
    this.employer,
    this.annualIncome,
    this.currency,
  });

  Map<String, dynamic> toJson() {
    return {
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'country': country,
      'state': state,
      'city': city,
      'address': address,
      'postalCode': postalCode,
      'timezone': timezone,
      'language': language,
      'occupation': occupation,
      'employer': employer,
      'annualIncome': annualIncome,
      'currency': currency,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      dateOfBirth: json['dateOfBirth'] as String?,
      gender: json['gender'] as String?,
      country: json['country'] as String?,
      state: json['state'] as String?,
      city: json['city'] as String?,
      address: json['address'] as String?,
      postalCode: json['postalCode'] as String?,
      timezone: json['timezone'] as String?,
      language: json['language'] as String?,
      occupation: json['occupation'] as String?,
      employer: json['employer'] as String?,
      annualIncome: (json['annualIncome'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
    );
  }

  UserProfile copyWith({
    String? dateOfBirth,
    String? gender,
    String? country,
    String? state,
    String? city,
    String? address,
    String? postalCode,
    String? timezone,
    String? language,
    String? occupation,
    String? employer,
    double? annualIncome,
    String? currency,
  }) {
    return UserProfile(
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      country: country ?? this.country,
      state: state ?? this.state,
      city: city ?? this.city,
      address: address ?? this.address,
      postalCode: postalCode ?? this.postalCode,
      timezone: timezone ?? this.timezone,
      language: language ?? this.language,
      occupation: occupation ?? this.occupation,
      employer: employer ?? this.employer,
      annualIncome: annualIncome ?? this.annualIncome,
      currency: currency ?? this.currency,
    );
  }
}

class UserSecurity {
  final bool twoFactorEnabled;
  final String? twoFactorMethod;
  final List<String>? trustedDevices;
  final List<String>? backupCodes;
  final DateTime? passwordChangedAt;
  final bool isLocked;
  final DateTime? lockedUntil;
  final int failedLoginAttempts;
  final List<String>? securityQuestions;
  final String? biometricEnabled;

  UserSecurity({
    this.twoFactorEnabled = false,
    this.twoFactorMethod,
    this.trustedDevices,
    this.backupCodes,
    this.passwordChangedAt,
    this.isLocked = false,
    this.lockedUntil,
    this.failedLoginAttempts = 0,
    this.securityQuestions,
    this.biometricEnabled,
  });

  Map<String, dynamic> toJson() {
    return {
      'twoFactorEnabled': twoFactorEnabled,
      'twoFactorMethod': twoFactorMethod,
      'trustedDevices': trustedDevices,
      'backupCodes': backupCodes,
      'passwordChangedAt': passwordChangedAt?.toIso8601String(),
      'isLocked': isLocked,
      'lockedUntil': lockedUntil?.toIso8601String(),
      'failedLoginAttempts': failedLoginAttempts,
      'securityQuestions': securityQuestions,
      'biometricEnabled': biometricEnabled,
    };
  }

  factory UserSecurity.fromJson(Map<String, dynamic> json) {
    return UserSecurity(
      twoFactorEnabled: json['twoFactorEnabled'] as bool? ?? false,
      twoFactorMethod: json['twoFactorMethod'] as String?,
      trustedDevices: (json['trustedDevices'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      backupCodes: (json['backupCodes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      passwordChangedAt: json['passwordChangedAt'] != null
          ? DateTime.parse(json['passwordChangedAt'] as String)
          : null,
      isLocked: json['isLocked'] as bool? ?? false,
      lockedUntil: json['lockedUntil'] != null
          ? DateTime.parse(json['lockedUntil'] as String)
          : null,
      failedLoginAttempts: json['failedLoginAttempts'] as int? ?? 0,
      securityQuestions: (json['securityQuestions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      biometricEnabled: json['biometricEnabled'] as String?,
    );
  }

  UserSecurity copyWith({
    bool? twoFactorEnabled,
    String? twoFactorMethod,
    List<String>? trustedDevices,
    List<String>? backupCodes,
    DateTime? passwordChangedAt,
    bool? isLocked,
    DateTime? lockedUntil,
    int? failedLoginAttempts,
    List<String>? securityQuestions,
    String? biometricEnabled,
  }) {
    return UserSecurity(
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      twoFactorMethod: twoFactorMethod ?? this.twoFactorMethod,
      trustedDevices: trustedDevices ?? this.trustedDevices,
      backupCodes: backupCodes ?? this.backupCodes,
      passwordChangedAt: passwordChangedAt ?? this.passwordChangedAt,
      isLocked: isLocked ?? this.isLocked,
      lockedUntil: lockedUntil ?? this.lockedUntil,
      failedLoginAttempts: failedLoginAttempts ?? this.failedLoginAttempts,
      securityQuestions: securityQuestions ?? this.securityQuestions,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    );
  }
}

class UserPreferences {
  final String? theme;
  final String? currency;
  final String? dateFormat;
  final String? numberFormat;
  final bool notificationsEnabled;
  final NotificationSettings? notifications;
  final List<String>? connectedAccounts;
  final DashboardLayout? dashboardLayout;
  final List<String>? favoriteAccounts;
  final bool showTutorial;
  final bool autoRefreshData;

  UserPreferences({
    this.theme = 'system',
    this.currency = 'USD',
    this.dateFormat = 'MM/DD/YYYY',
    this.numberFormat = 'en_US',
    this.notificationsEnabled = true,
    this.notifications,
    this.connectedAccounts,
    this.dashboardLayout,
    this.favoriteAccounts,
    this.showTutorial = true,
    this.autoRefreshData = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'currency': currency,
      'dateFormat': dateFormat,
      'numberFormat': numberFormat,
      'notificationsEnabled': notificationsEnabled,
      'notifications': notifications?.toJson(),
      'connectedAccounts': connectedAccounts,
      'dashboardLayout': dashboardLayout?.toJson(),
      'favoriteAccounts': favoriteAccounts,
      'showTutorial': showTutorial,
      'autoRefreshData': autoRefreshData,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      theme: json['theme'] as String? ?? 'system',
      currency: json['currency'] as String? ?? 'USD',
      dateFormat: json['dateFormat'] as String? ?? 'MM/DD/YYYY',
      numberFormat: json['numberFormat'] as String? ?? 'en_US',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      notifications: json['notifications'] != null
          ? NotificationSettings.fromJson(
              json['notifications'] as Map<String, dynamic>)
          : null,
      connectedAccounts: (json['connectedAccounts'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      dashboardLayout: json['dashboardLayout'] != null
          ? DashboardLayout.fromJson(
              json['dashboardLayout'] as Map<String, dynamic>)
          : null,
      favoriteAccounts: (json['favoriteAccounts'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      showTutorial: json['showTutorial'] as bool? ?? true,
      autoRefreshData: json['autoRefreshData'] as bool? ?? true,
    );
  }

  UserPreferences copyWith({
    String? theme,
    String? currency,
    String? dateFormat,
    String? numberFormat,
    bool? notificationsEnabled,
    NotificationSettings? notifications,
    List<String>? connectedAccounts,
    DashboardLayout? dashboardLayout,
    List<String>? favoriteAccounts,
    bool? showTutorial,
    bool? autoRefreshData,
  }) {
    return UserPreferences(
      theme: theme ?? this.theme,
      currency: currency ?? this.currency,
      dateFormat: dateFormat ?? this.dateFormat,
      numberFormat: numberFormat ?? this.numberFormat,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notifications: notifications ?? this.notifications,
      connectedAccounts: connectedAccounts ?? this.connectedAccounts,
      dashboardLayout: dashboardLayout ?? this.dashboardLayout,
      favoriteAccounts: favoriteAccounts ?? this.favoriteAccounts,
      showTutorial: showTutorial ?? this.showTutorial,
      autoRefreshData: autoRefreshData ?? this.autoRefreshData,
    );
  }
}

class NotificationSettings {
  final bool emailNotifications;
  final bool pushNotifications;
  final bool smsNotifications;
  final bool transactionAlerts;
  final bool budgetAlerts;
  final bool goalReminders;
  final bool marketAlerts;
  final bool weeklyReport;
  final bool monthlyReport;
  final bool securityAlerts;

  NotificationSettings({
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.smsNotifications = false,
    this.transactionAlerts = true,
    this.budgetAlerts = true,
    this.goalReminders = true,
    this.marketAlerts = false,
    this.weeklyReport = true,
    this.monthlyReport = true,
    this.securityAlerts = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
      'smsNotifications': smsNotifications,
      'transactionAlerts': transactionAlerts,
      'budgetAlerts': budgetAlerts,
      'goalReminders': goalReminders,
      'marketAlerts': marketAlerts,
      'weeklyReport': weeklyReport,
      'monthlyReport': monthlyReport,
      'securityAlerts': securityAlerts,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      emailNotifications: json['emailNotifications'] as bool? ?? true,
      pushNotifications: json['pushNotifications'] as bool? ?? true,
      smsNotifications: json['smsNotifications'] as bool? ?? false,
      transactionAlerts: json['transactionAlerts'] as bool? ?? true,
      budgetAlerts: json['budgetAlerts'] as bool? ?? true,
      goalReminders: json['goalReminders'] as bool? ?? true,
      marketAlerts: json['marketAlerts'] as bool? ?? false,
      weeklyReport: json['weeklyReport'] as bool? ?? true,
      monthlyReport: json['monthlyReport'] as bool? ?? true,
      securityAlerts: json['securityAlerts'] as bool? ?? true,
    );
  }

  NotificationSettings copyWith({
    bool? emailNotifications,
    bool? pushNotifications,
    bool? smsNotifications,
    bool? transactionAlerts,
    bool? budgetAlerts,
    bool? goalReminders,
    bool? marketAlerts,
    bool? weeklyReport,
    bool? monthlyReport,
    bool? securityAlerts,
  }) {
    return NotificationSettings(
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      transactionAlerts: transactionAlerts ?? this.transactionAlerts,
      budgetAlerts: budgetAlerts ?? this.budgetAlerts,
      goalReminders: goalReminders ?? this.goalReminders,
      marketAlerts: marketAlerts ?? this.marketAlerts,
      weeklyReport: weeklyReport ?? this.weeklyReport,
      monthlyReport: monthlyReport ?? this.monthlyReport,
      securityAlerts: securityAlerts ?? this.securityAlerts,
    );
  }
}

class DashboardLayout {
  final bool showNetWorth;
  final bool showSpendingChart;
  final bool showIncomeChart;
  final bool showBudgetProgress;
  final bool showSavingsGoals;
  final bool showPortfolio;
  final bool showRecentTransactions;
  final List<String>? widgetOrder;
  final int? compactMode;

  DashboardLayout({
    this.showNetWorth = true,
    this.showSpendingChart = true,
    this.showIncomeChart = true,
    this.showBudgetProgress = true,
    this.showSavingsGoals = true,
    this.showPortfolio = true,
    this.showRecentTransactions = true,
    this.widgetOrder,
    this.compactMode = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'showNetWorth': showNetWorth,
      'showSpendingChart': showSpendingChart,
      'showIncomeChart': showIncomeChart,
      'showBudgetProgress': showBudgetProgress,
      'showSavingsGoals': showSavingsGoals,
      'showPortfolio': showPortfolio,
      'showRecentTransactions': showRecentTransactions,
      'widgetOrder': widgetOrder,
      'compactMode': compactMode,
    };
  }

  factory DashboardLayout.fromJson(Map<String, dynamic> json) {
    return DashboardLayout(
      showNetWorth: json['showNetWorth'] as bool? ?? true,
      showSpendingChart: json['showSpendingChart'] as bool? ?? true,
      showIncomeChart: json['showIncomeChart'] as bool? ?? true,
      showBudgetProgress: json['showBudgetProgress'] as bool? ?? true,
      showSavingsGoals: json['showSavingsGoals'] as bool? ?? true,
      showPortfolio: json['showPortfolio'] as bool? ?? true,
      showRecentTransactions: json['showRecentTransactions'] as bool? ?? true,
      widgetOrder: (json['widgetOrder'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      compactMode: json['compactMode'] as int? ?? 0,
    );
  }

  DashboardLayout copyWith({
    bool? showNetWorth,
    bool? showSpendingChart,
    bool? showIncomeChart,
    bool? showBudgetProgress,
    bool? showSavingsGoals,
    bool? showPortfolio,
    bool? showRecentTransactions,
    List<String>? widgetOrder,
    int? compactMode,
  }) {
    return DashboardLayout(
      showNetWorth: showNetWorth ?? this.showNetWorth,
      showSpendingChart: showSpendingChart ?? this.showSpendingChart,
      showIncomeChart: showIncomeChart ?? this.showIncomeChart,
      showBudgetProgress: showBudgetProgress ?? this.showBudgetProgress,
      showSavingsGoals: showSavingsGoals ?? this.showSavingsGoals,
      showPortfolio: showPortfolio ?? this.showPortfolio,
      showRecentTransactions:
          showRecentTransactions ?? this.showRecentTransactions,
      widgetOrder: widgetOrder ?? this.widgetOrder,
      compactMode: compactMode ?? this.compactMode,
    );
  }
}

class UserFinancialProfile {
  final double? netWorth;
  final double? totalAssets;
  final double? totalLiabilities;
  final double? monthlyIncome;
  final double? monthlyExpenses;
  final double? monthlySavings;
  final double? savingsRate;
  final double? debtToIncomeRatio;
  final int? creditScore;
  final String? riskTolerance;
  final String? investmentExperience;
  final List<String>? investmentGoals;
  final String? taxFilingStatus;
  final List<String>? dependents;

  UserFinancialProfile({
    this.netWorth,
    this.totalAssets,
    this.totalLiabilities,
    this.monthlyIncome,
    this.monthlyExpenses,
    this.monthlySavings,
    this.savingsRate,
    this.debtToIncomeRatio,
    this.creditScore,
    this.riskTolerance,
    this.investmentExperience,
    this.investmentGoals,
    this.taxFilingStatus,
    this.dependents,
  });

  Map<String, dynamic> toJson() {
    return {
      'netWorth': netWorth,
      'totalAssets': totalAssets,
      'totalLiabilities': totalLiabilities,
      'monthlyIncome': monthlyIncome,
      'monthlyExpenses': monthlyExpenses,
      'monthlySavings': monthlySavings,
      'savingsRate': savingsRate,
      'debtToIncomeRatio': debtToIncomeRatio,
      'creditScore': creditScore,
      'riskTolerance': riskTolerance,
      'investmentExperience': investmentExperience,
      'investmentGoals': investmentGoals,
      'taxFilingStatus': taxFilingStatus,
      'dependents': dependents,
    };
  }

  factory UserFinancialProfile.fromJson(Map<String, dynamic> json) {
    return UserFinancialProfile(
      netWorth: (json['netWorth'] as num?)?.toDouble(),
      totalAssets: (json['totalAssets'] as num?)?.toDouble(),
      totalLiabilities: (json['totalLiabilities'] as num?)?.toDouble(),
      monthlyIncome: (json['monthlyIncome'] as num?)?.toDouble(),
      monthlyExpenses: (json['monthlyExpenses'] as num?)?.toDouble(),
      monthlySavings: (json['monthlySavings'] as num?)?.toDouble(),
      savingsRate: (json['savingsRate'] as num?)?.toDouble(),
      debtToIncomeRatio: (json['debtToIncomeRatio'] as num?)?.toDouble(),
      creditScore: json['creditScore'] as int?,
      riskTolerance: json['riskTolerance'] as String?,
      investmentExperience: json['investmentExperience'] as String?,
      investmentGoals: (json['investmentGoals'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      taxFilingStatus: json['taxFilingStatus'] as String?,
      dependents: (json['dependents'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  UserFinancialProfile copyWith({
    double? netWorth,
    double? totalAssets,
    double? totalLiabilities,
    double? monthlyIncome,
    double? monthlyExpenses,
    double? monthlySavings,
    double? savingsRate,
    double? debtToIncomeRatio,
    int? creditScore,
    String? riskTolerance,
    String? investmentExperience,
    List<String>? investmentGoals,
    String? taxFilingStatus,
    List<String>? dependents,
  }) {
    return UserFinancialProfile(
      netWorth: netWorth ?? this.netWorth,
      totalAssets: totalAssets ?? this.totalAssets,
      totalLiabilities: totalLiabilities ?? this.totalLiabilities,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      monthlyExpenses: monthlyExpenses ?? this.monthlyExpenses,
      monthlySavings: monthlySavings ?? this.monthlySavings,
      savingsRate: savingsRate ?? this.savingsRate,
      debtToIncomeRatio: debtToIncomeRatio ?? this.debtToIncomeRatio,
      creditScore: creditScore ?? this.creditScore,
      riskTolerance: riskTolerance ?? this.riskTolerance,
      investmentExperience: investmentExperience ?? this.investmentExperience,
      investmentGoals: investmentGoals ?? this.investmentGoals,
      taxFilingStatus: taxFilingStatus ?? this.taxFilingStatus,
      dependents: dependents ?? this.dependents,
    );
  }
}
