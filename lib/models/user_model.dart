/// User model representing a FinTrack user account
class UserModel {
  /// Unique identifier for the user
  final String id;

  /// User's email address (used for authentication)
  final String email;

  /// User's display/username
  final String username;

  /// User's first name
  final String? firstName;

  /// User's last name
  final String? lastName;

  /// URL to user's profile avatar image
  final String? avatarUrl;

  /// User's phone number
  final String? phoneNumber;

  /// User's date of birth
  final DateTime? dateOfBirth;

  /// Preferred currency code (e.g., 'USD', 'EUR', 'GBP')
  final String preferredCurrency;

  /// User's timezone identifier (e.g., 'America/New_York')
  final String timezone;

  /// User's preferred language code (e.g., 'en', 'es', 'fr')
  final String language;

  /// Whether the user's email has been verified
  final bool isEmailVerified;

  /// Whether the user account is active
  final bool isActive;

  /// Whether two-factor authentication is enabled
  final bool isTwoFactorEnabled;

  /// Timestamp of last successful login
  final DateTime? lastLoginAt;

  /// Total number of successful logins
  final int loginCount;

  /// Number of failed login attempts since last success
  final int failedLoginAttempts;

  /// Timestamp until which the account is locked (if locked)
  final DateTime? lockedUntil;

  /// When the user's password was last changed
  final DateTime? passwordChangedAt;

  /// User's notification preferences as JSON
  final Map<String, dynamic> notificationPreferences;

  /// User's theme preference ('light', 'dark', 'system')
  final String themePreference;

  /// ID of the user's default/primary account
  final String? defaultAccountId;

  /// User's risk tolerance level for investments (1-5 scale)
  final int riskTolerance;

  /// Whether the user has completed onboarding
  final bool hasCompletedOnboarding;

  /// User's financial goals summary
  final String? financialGoals;

  /// User's monthly income target
  final double? monthlyIncomeTarget;

  /// User's monthly expense limit
  final double? monthlyExpenseLimit;

  /// Timestamp when the user account was created
  final DateTime createdAt;

  /// Timestamp when the user account was last updated
  final DateTime updatedAt;

  /// Creates a new UserModel instance
  const UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    this.phoneNumber,
    this.dateOfBirth,
    this.preferredCurrency = 'USD',
    this.timezone = 'UTC',
    this.language = 'en',
    this.isEmailVerified = false,
    this.isActive = true,
    this.isTwoFactorEnabled = false,
    this.lastLoginAt,
    this.loginCount = 0,
    this.failedLoginAttempts = 0,
    this.lockedUntil,
    this.passwordChangedAt,
    this.notificationPreferences = const {},
    this.themePreference = 'system',
    this.defaultAccountId,
    this.riskTolerance = 3,
    this.hasCompletedOnboarding = false,
    this.financialGoals,
    this.monthlyIncomeTarget,
    this.monthlyExpenseLimit,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Returns the user's full name or username if not available
  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    }
    return username;
  }

  /// Returns the user's initials for avatar fallback
  String get initials {
    if (firstName != null && lastName != null) {
      return '${firstName![0]}${lastName![0]}'.toUpperCase();
    } else if (firstName != null) {
      return firstName![0].toUpperCase();
    }
    return username.isNotEmpty ? username[0].toUpperCase() : '?';
  }

  /// Checks if the account is currently locked
  bool get isLocked {
    if (lockedUntil == null) return false;
    return DateTime.now().isBefore(lockedUntil!);
  }

  /// Creates a copy of the user with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? firstName,
    String? lastName,
    String? avatarUrl,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? preferredCurrency,
    String? timezone,
    String? language,
    bool? isEmailVerified,
    bool? isActive,
    bool? isTwoFactorEnabled,
    DateTime? lastLoginAt,
    int? loginCount,
    int? failedLoginAttempts,
    DateTime? lockedUntil,
    DateTime? passwordChangedAt,
    Map<String, dynamic>? notificationPreferences,
    String? themePreference,
    String? defaultAccountId,
    int? riskTolerance,
    bool? hasCompletedOnboarding,
    String? financialGoals,
    double? monthlyIncomeTarget,
    double? monthlyExpenseLimit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      timezone: timezone ?? this.timezone,
      language: language ?? this.language,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isActive: isActive ?? this.isActive,
      isTwoFactorEnabled: isTwoFactorEnabled ?? this.isTwoFactorEnabled,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      loginCount: loginCount ?? this.loginCount,
      failedLoginAttempts: failedLoginAttempts ?? this.failedLoginAttempts,
      lockedUntil: lockedUntil ?? this.lockedUntil,
      passwordChangedAt: passwordChangedAt ?? this.passwordChangedAt,
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
      themePreference: themePreference ?? this.themePreference,
      defaultAccountId: defaultAccountId ?? this.defaultAccountId,
      riskTolerance: riskTolerance ?? this.riskTolerance,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      financialGoals: financialGoals ?? this.financialGoals,
      monthlyIncomeTarget: monthlyIncomeTarget ?? this.monthlyIncomeTarget,
      monthlyExpenseLimit: monthlyExpenseLimit ?? this.monthlyExpenseLimit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converts the user model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'avatarUrl': avatarUrl,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'preferredCurrency': preferredCurrency,
      'timezone': timezone,
      'language': language,
      'isEmailVerified': isEmailVerified,
      'isActive': isActive,
      'isTwoFactorEnabled': isTwoFactorEnabled,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'loginCount': loginCount,
      'failedLoginAttempts': failedLoginAttempts,
      'lockedUntil': lockedUntil?.toIso8601String(),
      'passwordChangedAt': passwordChangedAt?.toIso8601String(),
      'notificationPreferences': notificationPreferences,
      'themePreference': themePreference,
      'defaultAccountId': defaultAccountId,
      'riskTolerance': riskTolerance,
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'financialGoals': financialGoals,
      'monthlyIncomeTarget': monthlyIncomeTarget,
      'monthlyExpenseLimit': monthlyExpenseLimit,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Creates a user model from a JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      preferredCurrency:
          json['preferredCurrency'] as String? ?? 'USD',
      timezone: json['timezone'] as String? ?? 'UTC',
      language: json['language'] as String? ?? 'en',
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      isTwoFactorEnabled: json['isTwoFactorEnabled'] as bool? ?? false,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      loginCount: json['loginCount'] as int? ?? 0,
      failedLoginAttempts: json['failedLoginAttempts'] as int? ?? 0,
      lockedUntil: json['lockedUntil'] != null
          ? DateTime.parse(json['lockedUntil'] as String)
          : null,
      passwordChangedAt: json['passwordChangedAt'] != null
          ? DateTime.parse(json['passwordChangedAt'] as String)
          : null,
      notificationPreferences:
          json['notificationPreferences'] as Map<String, dynamic>? ?? {},
      themePreference: json['themePreference'] as String? ?? 'system',
      defaultAccountId: json['defaultAccountId'] as String?,
      riskTolerance: json['riskTolerance'] as int? ?? 3,
      hasCompletedOnboarding: json['hasCompletedOnboarding'] as bool? ?? false,
      financialGoals: json['financialGoals'] as String?,
      monthlyIncomeTarget: (json['monthlyIncomeTarget'] as num?)?.toDouble(),
      monthlyExpenseLimit: (json['monthlyExpenseLimit'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
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
    return 'UserModel(id: $id, email: $email, username: $username)';
  }
}
