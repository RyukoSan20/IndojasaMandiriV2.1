/// User model representing a FinTrack user account
/// 
/// This model contains all user-related data including authentication,
/// profile information, preferences, and account status for the
/// personal finance and stock portfolio tracking application.
class UserModel {
  /// Unique identifier for the user
  final String id;

  /// User's email address (used for authentication and notifications)
  final String email;

  /// User's display name shown throughout the application
  final String displayName;

  /// URL to user's profile picture (nullable if not set)
  final String? profilePictureUrl;

  /// User's first name
  final String firstName;

  /// User's last name
  final String lastName;

  /// User's phone number (nullable, used for 2FA and notifications)
  final String? phoneNumber;

  /// Date of birth for age verification and financial planning
  final DateTime? dateOfBirth;

  /// Two-factor authentication enabled status
  final bool isTwoFactorEnabled;

  /// User's preferred currency code (e.g., 'USD', 'EUR', 'GBP')
  final String preferredCurrency;

  /// User's locale for internationalization (e.g., 'en_US', 'es_ES')
  final String locale;

  /// User's timezone identifier (e.g., 'America/New_York')
  final String timezone;

  /// Account verification status
  final bool isEmailVerified;

  /// Account status (active, suspended, pending_verification, etc.)
  final AccountStatus accountStatus;

  /// User's current subscription tier
  final SubscriptionTier subscriptionTier;

  /// Date when the subscription expires
  final DateTime? subscriptionExpiresAt;

  /// User preferences stored as a map for flexibility
  final Map<String, dynamic> preferences;

  /// List of connected accounts (bank accounts, investment accounts)
  final List<String> connectedAccountIds;

  /// List of enabled notification types
  final List<NotificationType> enabledNotifications;

  /// User's risk tolerance level for investment recommendations
  final RiskTolerance riskTolerance;

  /// Emergency contact information
  final EmergencyContact? emergencyContact;

  /// User's security questions for account recovery
  final List<SecurityQuestion> securityQuestions;

  /// Last login timestamp
  final DateTime lastLoginAt;

  /// Account creation timestamp
  final DateTime createdAt;

  /// Last update timestamp
  final DateTime updatedAt;

  /// Constructor for UserModel
  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.profilePictureUrl,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.dateOfBirth,
    this.isTwoFactorEnabled = false,
    this.preferredCurrency = 'USD',
    this.locale = 'en_US',
    this.timezone = 'UTC',
    this.isEmailVerified = false,
    this.accountStatus = AccountStatus.pendingVerification,
    this.subscriptionTier = SubscriptionTier.free,
    this.subscriptionExpiresAt,
    Map<String, dynamic>? preferences,
    List<String>? connectedAccountIds,
    List<NotificationType>? enabledNotifications,
    this.riskTolerance = RiskTolerance.moderate,
    this.emergencyContact,
    List<SecurityQuestion>? securityQuestions,
    required this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
  })  : preferences = preferences ?? {},
        connectedAccountIds = connectedAccountIds ?? [],
        enabledNotifications = enabledNotifications ?? [],
        securityQuestions = securityQuestions ?? [];

  /// Creates a UserModel from a JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String,
      profilePictureUrl: json['profile_picture_url'] as String?,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      phoneNumber: json['phone_number'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      isTwoFactorEnabled: json['is_two_factor_enabled'] as bool? ?? false,
      preferredCurrency: json['preferred_currency'] as String? ?? 'USD',
      locale: json['locale'] as String? ?? 'en_US',
      timezone: json['timezone'] as String? ?? 'UTC',
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      accountStatus: AccountStatus.values.firstWhere(
        (e) => e.name == json['account_status'],
        orElse: () => AccountStatus.pendingVerification,
      ),
      subscriptionTier: SubscriptionTier.values.firstWhere(
        (e) => e.name == json['subscription_tier'],
        orElse: () => SubscriptionTier.free,
      ),
      subscriptionExpiresAt: json['subscription_expires_at'] != null
          ? DateTime.parse(json['subscription_expires_at'] as String)
          : null,
      preferences: json['preferences'] as Map<String, dynamic>? ?? {},
      connectedAccountIds:
          (json['connected_account_ids'] as List<dynamic>?)?.cast<String>() ??
              [],
      enabledNotifications:
          (json['enabled_notifications'] as List<dynamic>?)
                  ?.map((e) => NotificationType.values.firstWhere(
                        (n) => n.name == e,
                        orElse: () => NotificationType.transactionAlerts,
                      ))
                  .toList() ??
              [],
      riskTolerance: RiskTolerance.values.firstWhere(
        (e) => e.name == json['risk_tolerance'],
        orElse: () => RiskTolerance.moderate,
      ),
      emergencyContact: json['emergency_contact'] != null
          ? EmergencyContact.fromJson(
              json['emergency_contact'] as Map<String, dynamic>)
          : null,
      securityQuestions:
          (json['security_questions'] as List<dynamic>?)
              ?.map((e) => SecurityQuestion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  /// Converts the UserModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'profile_picture_url': profilePictureUrl,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'is_two_factor_enabled': isTwoFactorEnabled,
      'preferred_currency': preferredCurrency,
      'locale': locale,
      'timezone': timezone,
      'is_email_verified': isEmailVerified,
      'account_status': accountStatus.name,
      'subscription_tier': subscriptionTier.name,
      'subscription_expires_at': subscriptionExpiresAt?.toIso8601String(),
      'preferences': preferences,
      'connected_account_ids': connectedAccountIds,
      'enabled_notifications': enabledNotifications.map((e) => e.name).toList(),
      'risk_tolerance': riskTolerance.name,
      'emergency_contact': emergencyContact?.toJson(),
      'security_questions': securityQuestions.map((e) => e.toJson()).toList(),
      'last_login_at': lastLoginAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Creates a copy of UserModel with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? profilePictureUrl,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    bool? isTwoFactorEnabled,
    String? preferredCurrency,
    String? locale,
    String? timezone,
    bool? isEmailVerified,
    AccountStatus? accountStatus,
    SubscriptionTier? subscriptionTier,
    DateTime? subscriptionExpiresAt,
    Map<String, dynamic>? preferences,
    List<String>? connectedAccountIds,
    List<NotificationType>? enabledNotifications,
    RiskTolerance? riskTolerance,
    EmergencyContact? emergencyContact,
    List<SecurityQuestion>? securityQuestions,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      isTwoFactorEnabled: isTwoFactorEnabled ?? this.isTwoFactorEnabled,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      locale: locale ?? this.locale,
      timezone: timezone ?? this.timezone,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      accountStatus: accountStatus ?? this.accountStatus,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      subscriptionExpiresAt: subscriptionExpiresAt ?? this.subscriptionExpiresAt,
      preferences: preferences ?? this.preferences,
      connectedAccountIds: connectedAccountIds ?? this.connectedAccountIds,
      enabledNotifications: enabledNotifications ?? this.enabledNotifications,
      riskTolerance: riskTolerance ?? this.riskTolerance,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      securityQuestions: securityQuestions ?? this.securityQuestions,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Returns the user's full name
  String get fullName => '$firstName $lastName';

  /// Returns true if the user has an active subscription
  bool get hasActiveSubscription {
    if (subscriptionTier == SubscriptionTier.free) return false;
    if (subscriptionExpiresAt == null) return false;
    return subscriptionExpiresAt!.isAfter(DateTime.now());
  }

  /// Returns true if the user's account is active
  bool get isAccountActive => accountStatus == AccountStatus.active;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, displayName: $displayName, '
        'accountStatus: $accountStatus, subscriptionTier: $subscriptionTier)';
  }
}

/// Enum representing possible account statuses
enum AccountStatus {
  /// Account is active and fully functional
  active,

  /// Account is pending email verification
  pendingVerification,

  /// Account is temporarily suspended
  suspended,

  /// Account has been permanently deactivated
  deactivated,

  /// Account is locked due to security concerns
  locked,

  /// Account is in the process of being deleted
  pendingDeletion,
}

/// Enum representing subscription tiers
enum SubscriptionTier {
  /// Free tier with basic features
  free,

  /// Premium tier with advanced features
  premium,

  /// Professional tier for power users
  professional,

  /// Enterprise tier for business accounts
  enterprise,
}

/// Enum representing notification types
enum NotificationType {
  /// Alert for new transactions
  transactionAlerts,

  /// Reminder for upcoming bill payments
  billReminders,

  /// Notification for savings goal milestones
  savingsGoalMilestones,

  /// Alert for unusual spending patterns
  spendingAlerts,

  /// Notification for portfolio performance updates
  portfolioUpdates,

  /// Reminder for investment opportunities
  investmentRecommendations,

  /// Security-related notifications
  securityAlerts,

  /// Marketing and promotional emails
  marketingEmails,

  /// Weekly and monthly financial summaries
  financialSummaries,
}

/// Enum representing risk tolerance levels for investment recommendations
enum RiskTolerance {
  /// Conservative investor - prefers stability over high returns
  conservative,

  /// Moderate investor - balanced approach
  moderate,

  /// Aggressive investor - willing to take risks for higher returns
  aggressive,

  /// Very aggressive investor - maximum risk tolerance
  veryAggressive,
}

/// Model for emergency contact information
class EmergencyContact {
  /// Contact's full name
  final String name;

  /// Contact's relationship to the user
  final String relationship;

  /// Contact's phone number
  final String phoneNumber;

  /// Contact's email address (optional)
  final String? email;

  /// Constructor for EmergencyContact
  EmergencyContact({
    required this.name,
    required this.relationship,
    required this.phoneNumber,
    this.email,
  });

  /// Creates an EmergencyContact from a JSON map
  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'] as String,
      relationship: json['relationship'] as String,
      phoneNumber: json['phone_number'] as String,
      email: json['email'] as String?,
    );
  }

  /// Converts the EmergencyContact to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'relationship': relationship,
      'phone_number': phoneNumber,
      'email': email,
    };
  }

  /// Creates a copy of EmergencyContact with updated fields
  EmergencyContact copyWith({
    String? name,
    String? relationship,
    String? phoneNumber,
    String? email,
  }) {
    return EmergencyContact(
      name: name ?? this.name,
      relationship: relationship ?? this.relationship,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
    );
  }
}

/// Model for security questions
class SecurityQuestion {
  /// Unique identifier for the question
  final String id;

  /// The question text
  final String question;

  /// The user's answer (stored hashed)
  final String hashedAnswer;

  /// Constructor for SecurityQuestion
  SecurityQuestion({
    required this.id,
    required this.question,
    required this.hashedAnswer,
  });

  /// Creates a SecurityQuestion from a JSON map
  factory SecurityQuestion.fromJson(Map<String, dynamic> json) {
    return SecurityQuestion(
      id: json['id'] as String,
      question: json['question'] as String,
      hashedAnswer: json['hashed_answer'] as String,
    );
  }

  /// Converts the SecurityQuestion to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'hashed_answer': hashedAnswer,
    };
  }

  /// Creates a copy of SecurityQuestion with updated fields
  SecurityQuestion copyWith({
    String? id,
    String? question,
    String? hashedAnswer,
  }) {
    return SecurityQuestion(
      id: id ?? this.id,
      question: question ?? this.question,
      hashedAnswer: hashedAnswer ?? this.hashedAnswer,
    );
  }
}
