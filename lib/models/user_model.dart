/// User model representing a FinTrack user account.
/// 
/// This model contains all user-related information including
/// authentication data, profile details, and application preferences.
library;

import 'dart:convert';
import 'package:equatable/equatable.dart';

/// Represents a FinTrack user account.
///
/// Contains all user-related data including authentication,
/// profile information, and application settings.
class UserModel extends Equatable {
  /// Unique identifier for the user.
  final String id;

  /// User's email address (used for authentication).
  final String email;

  /// User's first name.
  final String firstName;

  /// User's last name.
  final String lastName;

  /// User's date of birth for age verification.
  final DateTime? dateOfBirth;

  /// URL to user's profile picture.
  final String? profilePictureUrl;

  /// User's phone number for contact and 2FA.
  final String? phoneNumber;

  /// Whether the user's email has been verified.
  final bool isEmailVerified;

  /// Whether the user's phone number has been verified.
  final bool isPhoneVerified;

  /// User's preferred currency code (e.g., 'USD', 'EUR', 'GBP').
  final String preferredCurrency;

  /// User's preferred language code (e.g., 'en', 'es', 'fr').
  final String preferredLanguage;

  /// User's timezone identifier (e.g., 'America/New_York').
  final String timezone;

  /// User's country code for regional settings.
  final String? countryCode;

  /// User's address information as JSON string.
  final Map<String, dynamic>? address;

  /// List of user account IDs that this user has access to.
  final List<String> linkedAccountIds;

  /// User's monthly income for budgeting calculations.
  final double? monthlyIncome;

  /// User's risk tolerance for investment recommendations.
  final RiskTolerance? riskTolerance;

  /// Whether the user has enabled biometric authentication.
  final bool biometricEnabled;

  /// Whether push notifications are enabled.
  final bool pushNotificationsEnabled;

  /// Whether email notifications are enabled.
  final bool emailNotificationsEnabled;

  /// Whether SMS notifications are enabled.
  final bool smsNotificationsEnabled;

  /// User's investment experience level.
  final ExperienceLevel? investmentExperience;

  /// User's employment status.
  final EmploymentStatus? employmentStatus;

  /// Date when the user account was created.
  final DateTime createdAt;

  /// Date when the user account was last updated.
  final DateTime updatedAt;

  /// Date of the user's last login.
  final DateTime? lastLoginAt;

  /// User's current subscription tier.
  final SubscriptionTier subscriptionTier;

  /// Whether the user account is active.
  final bool isActive;

  /// Whether the user account is blocked.
  final bool isBlocked;

  /// User's theme preference ('light', 'dark', 'system').
  final String themePreference;

  /// Date format preference (e.g., 'MM/DD/YYYY', 'DD/MM/YYYY').
  final String dateFormat;

  /// Number format preference (e.g., '1,234.56', '1.234,56').
  final String numberFormat;

  /// Two-factor authentication method.
  final TwoFactorMethod? twoFactorMethod;

  /// User's total net worth (calculated field).
  final double? netWorth;

  /// User's savings goal progress percentage.
  final double? savingsProgress;

  /// Whether dark mode is enabled.
  final bool darkModeEnabled;

  /// User's display name (can be username or full name).
  final String? displayName;

  /// User's bio or description.
  final String? bio;

  /// Social media links as JSON string.
  final Map<String, String>? socialLinks;

  /// User's PIN code for quick authentication (hashed).
  final String? pinCode;

  /// Whether the user has completed onboarding.
  final bool onboardingCompleted;

  /// User's kyc (Know Your Customer) verification status.
  final KycStatus kycStatus;

  /// User's tax identification number (encrypted).
  final String? taxId;

  /// User's referrer ID if they were referred by another user.
  final String? referrerId;

  /// User's referral code to share with others.
  final String? referralCode;

  /// Constructor for creating a UserModel instance.
  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.dateOfBirth,
    this.profilePictureUrl,
    this.phoneNumber,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.preferredCurrency = 'USD',
    this.preferredLanguage = 'en',
    this.timezone = 'UTC',
    this.countryCode,
    this.address,
    this.linkedAccountIds = const [],
    this.monthlyIncome,
    this.riskTolerance,
    this.biometricEnabled = false,
    this.pushNotificationsEnabled = true,
    this.emailNotificationsEnabled = true,
    this.smsNotificationsEnabled = false,
    this.investmentExperience,
    this.employmentStatus,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    this.subscriptionTier = SubscriptionTier.free,
    this.isActive = true,
    this.isBlocked = false,
    this.themePreference = 'system',
    this.dateFormat = 'MM/DD/YYYY',
    this.numberFormat = '1,234.56',
    this.twoFactorMethod,
    this.netWorth,
    this.savingsProgress,
    this.darkModeEnabled = false,
    this.displayName,
    this.bio,
    this.socialLinks,
    this.pinCode,
    this.onboardingCompleted = false,
    this.kycStatus = KycStatus.none,
    this.taxId,
    this.referrerId,
    this.referralCode,
  });

  /// Returns the user's full name.
  String get fullName => '$firstName $lastName';

  /// Returns the user's initials for avatar display.
  String get initials {
    final firstInitial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }

  /// Checks if the user has enabled two-factor authentication.
  bool get hasTwoFactorEnabled => twoFactorMethod != null;

  /// Checks if the user is a premium subscriber.
  bool get isPremium =>
      subscriptionTier == SubscriptionTier.premium ||
      subscriptionTier == SubscriptionTier.enterprise;

  /// Creates a UserModel from a JSON map.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String? ?? json['firstName'] as String? ?? '',
      lastName: json['last_name'] as String? ?? json['lastName'] as String? ?? '',
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'] as String)
          : json['dateOfBirth'] != null
              ? DateTime.tryParse(json['dateOfBirth'] as String)
              : null,
      profilePictureUrl: json['profile_picture_url'] as String? ??
          json['profilePictureUrl'] as String?,
      phoneNumber: json['phone_number'] as String? ?? json['phoneNumber'] as String?,
      isEmailVerified: json['is_email_verified'] as bool? ??
          json['isEmailVerified'] as bool? ??
          false,
      isPhoneVerified: json['is_phone_verified'] as bool? ??
          json['isPhoneVerified'] as bool? ??
          false,
      preferredCurrency: json['preferred_currency'] as String? ??
          json['preferredCurrency'] as String? ??
          'USD',
      preferredLanguage: json['preferred_language'] as String? ??
          json['preferredLanguage'] as String? ??
          'en',
      timezone: json['timezone'] as String? ?? 'UTC',
      countryCode: json['country_code'] as String? ?? json['countryCode'] as String?,
      address: json['address'] as Map<String, dynamic>?,
      linkedAccountIds: (json['linked_account_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          json['linkedAccountIds'] as List<String>? ??
          [],
      monthlyIncome: (json['monthly_income'] as num?)?.toDouble() ??
          (json['monthlyIncome'] as num?)?.toDouble(),
      riskTolerance: json['risk_tolerance'] != null
          ? RiskTolerance.values.firstWhere(
              (e) => e.name == json['risk_tolerance'],
              orElse: () => RiskTolerance.moderate,
            )
          : json['riskTolerance'] != null
              ? RiskTolerance.values.firstWhere(
                  (e) => e.name == json['riskTolerance'],
                  orElse: () => RiskTolerance.moderate,
                )
              : null,
      biometricEnabled: json['biometric_enabled'] as bool? ??
          json['biometricEnabled'] as bool? ??
          false,
      pushNotificationsEnabled:
          json['push_notifications_enabled'] as bool? ??
              json['pushNotificationsEnabled'] as bool? ??
              true,
      emailNotificationsEnabled:
          json['email_notifications_enabled'] as bool? ??
              json['emailNotificationsEnabled'] as bool? ??
              true,
      smsNotificationsEnabled:
          json['sms_notifications_enabled'] as bool? ??
              json['smsNotificationsEnabled'] as bool? ??
              false,
      investmentExperience: json['investment_experience'] != null
          ? ExperienceLevel.values.firstWhere(
              (e) => e.name == json['investment_experience'],
              orElse: () => ExperienceLevel.beginner,
            )
          : json['investmentExperience'] != null
              ? ExperienceLevel.values.firstWhere(
                  (e) => e.name == json['investmentExperience'],
                  orElse: () => ExperienceLevel.beginner,
                )
              : null,
      employmentStatus: json['employment_status'] != null
          ? EmploymentStatus.values.firstWhere(
              (e) => e.name == json['employment_status'],
              orElse: () => EmploymentStatus.employed,
            )
          : json['employmentStatus'] != null
              ? EmploymentStatus.values.firstWhere(
                  (e) => e.name == json['employmentStatus'],
                  orElse: () => EmploymentStatus.employed,
                )
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
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.tryParse(json['last_login_at'] as String)
          : json['lastLoginAt'] != null
              ? DateTime.tryParse(json['lastLoginAt'] as String)
              : null,
      subscriptionTier: json['subscription_tier'] != null
          ? SubscriptionTier.values.firstWhere(
              (e) => e.name == json['subscription_tier'],
              orElse: () => SubscriptionTier.free,
            )
          : json['subscriptionTier'] != null
              ? SubscriptionTier.values.firstWhere(
                  (e) => e.name == json['subscriptionTier'],
                  orElse: () => SubscriptionTier.free,
                )
              : SubscriptionTier.free,
      isActive: json['is_active'] as bool? ?? json['isActive'] as bool? ?? true,
      isBlocked: json['is_blocked'] as bool? ?? json['isBlocked'] as bool? ?? false,
      themePreference: json['theme_preference'] as String? ??
          json['themePreference'] as String? ??
          'system',
      dateFormat: json['date_format'] as String? ??
          json['dateFormat'] as String? ??
          'MM/DD/YYYY',
      numberFormat: json['number_format'] as String? ??
          json['numberFormat'] as String? ??
          '1,234.56',
      twoFactorMethod: json['two_factor_method'] != null
          ? TwoFactorMethod.values.firstWhere(
              (e) => e.name == json['two_factor_method'],
              orElse: () => TwoFactorMethod.none,
            )
          : json['twoFactorMethod'] != null
              ? TwoFactorMethod.values.firstWhere(
                  (e) => e.name == json['twoFactorMethod'],
                  orElse: () => TwoFactorMethod.none,
                )
              : null,
      netWorth: (json['net_worth'] as num?)?.toDouble() ??
          (json['netWorth'] as num?)?.toDouble(),
      savingsProgress: (json['savings_progress'] as num?)?.toDouble() ??
          (json['savingsProgress'] as num?)?.toDouble(),
      darkModeEnabled:
          json['dark_mode_enabled'] as bool? ?? json['darkModeEnabled'] as bool? ?? false,
      displayName: json['display_name'] as String? ?? json['displayName'] as String?,
      bio: json['bio'] as String?,
      socialLinks: json['social_links'] != null
          ? Map<String, String>.from(json['social_links'] as Map)
          : json['socialLinks'] != null
              ? Map<String, String>.from(json['socialLinks'] as Map)
              : null,
      pinCode: json['pin_code'] as String? ?? json['pinCode'] as String?,
      onboardingCompleted:
          json['onboarding_completed'] as bool? ?? json['onboardingCompleted'] as bool? ?? false,
      kycStatus: json['kyc_status'] != null
          ? KycStatus.values.firstWhere(
              (e) => e.name == json['kyc_status'],
              orElse: () => KycStatus.none,
            )
          : json['kycStatus'] != null
              ? KycStatus.values.firstWhere(
                  (e) => e.name == json['kycStatus'],
                  orElse: () => KycStatus.none,
                )
              : KycStatus.none,
      taxId: json['tax_id'] as String? ?? json['taxId'] as String?,
      referrerId: json['referrer_id'] as String? ?? json['referrerId'] as String?,
      referralCode: json['referral_code'] as String? ?? json['referralCode'] as String?,
    );
  }

  /// Converts this UserModel to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'profile_picture_url': profilePictureUrl,
      'phone_number': phoneNumber,
      'is_email_verified': isEmailVerified,
      'is_phone_verified': isPhoneVerified,
      'preferred_currency': preferredCurrency,
      'preferred_language': preferredLanguage,
      'timezone': timezone,
      'country_code': countryCode,
      'address': address,
      'linked_account_ids': linkedAccountIds,
      'monthly_income': monthlyIncome,
      'risk_tolerance': riskTolerance?.name,
      'biometric_enabled': biometricEnabled,
      'push_notifications_enabled': pushNotificationsEnabled,
      'email_notifications_enabled': emailNotificationsEnabled,
      'sms_notifications_enabled': smsNotificationsEnabled,
      'investment_experience': investmentExperience?.name,
      'employment_status': employmentStatus?.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
      'subscription_tier': subscriptionTier.name,
      'is_active': isActive,
      'is_blocked': isBlocked,
      'theme_preference': themePreference,
      'date_format': dateFormat,
      'number_format': numberFormat,
      'two_factor_method': twoFactorMethod?.name,
      'net_worth': netWorth,
      'savings_progress': savingsProgress,
      'dark_mode_enabled': darkModeEnabled,
      'display_name': displayName,
      'bio': bio,
      'social_links': socialLinks,
      'pin_code': pinCode,
      'onboarding_completed': onboardingCompleted,
      'kyc_status': kycStatus.name,
      'tax_id': taxId,
      'referrer_id': referrerId,
      'referral_code': referralCode,
    };
  }

  /// Converts this UserModel to a JSON string.
  String toJsonString() => jsonEncode(toJson());

  /// Creates a UserModel from a JSON string.
  factory UserModel.fromJsonString(String jsonString) {
    return UserModel.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  /// Creates a copy of this UserModel with the given fields replaced.
  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    String? profilePictureUrl,
    String? phoneNumber,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    String? preferredCurrency,
    String? preferredLanguage,
    String? timezone,
    String? countryCode,
    Map<String, dynamic>? address,
    List<String>? linkedAccountIds,
    double? monthlyIncome,
    RiskTolerance? riskTolerance,
    bool? biometricEnabled,
    bool? pushNotificationsEnabled,
    bool? emailNotificationsEnabled,
    bool? smsNotificationsEnabled,
    ExperienceLevel? investmentExperience,
    EmploymentStatus? employmentStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    SubscriptionTier? subscriptionTier,
    bool? isActive,
    bool? isBlocked,
    String? themePreference,
    String? dateFormat,
    String? numberFormat,
    TwoFactorMethod? twoFactorMethod,
    double? netWorth,
    double? savingsProgress,
    bool? darkModeEnabled,
    String? displayName,
    String? bio,
    Map<String, String>? socialLinks,
    String? pinCode,
    bool? onboardingCompleted,
    KycStatus? kycStatus,
    String? taxId,
    String? referrerId,
    String? referralCode,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      timezone: timezone ?? this.timezone,
      countryCode: countryCode ?? this.countryCode,
      address: address ?? this.address,
      linkedAccountIds: linkedAccountIds ?? this.linkedAccountIds,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      riskTolerance: riskTolerance ?? this.riskTolerance,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      emailNotificationsEnabled:
          emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      smsNotificationsEnabled:
          smsNotificationsEnabled ?? this.smsNotificationsEnabled,
      investmentExperience: investmentExperience ?? this.investmentExperience,
      employmentStatus: employmentStatus ?? this.employmentStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      isActive: isActive ?? this.isActive,
      isBlocked: isBlocked ?? this.isBlocked,
      themePreference: themePreference ?? this.themePreference,
      dateFormat: dateFormat ?? this.dateFormat,
      numberFormat: numberFormat ?? this.numberFormat,
      twoFactorMethod: twoFactorMethod ?? this.twoFactorMethod,
      netWorth: netWorth ?? this.netWorth,
      savingsProgress: savingsProgress ?? this.savingsProgress,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      socialLinks: socialLinks ?? this.socialLinks,
      pinCode: pinCode ?? this.pinCode,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      kycStatus: kycStatus ?? this.kycStatus,
      taxId: taxId ?? this.taxId,
      referrerId: referrerId ?? this.referrerId,
      referralCode: referralCode ?? this.referralCode,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        dateOfBirth,
        profilePictureUrl,
        phoneNumber,
        isEmailVerified,
        isPhoneVerified,
        preferredCurrency,
        preferredLanguage,
        timezone,
        countryCode,
        address,
        linkedAccountIds,
        monthlyIncome,
        riskTolerance,
        biometricEnabled,
        pushNotificationsEnabled,
        emailNotificationsEnabled,
        smsNotificationsEnabled,
        investmentExperience,
        employmentStatus,
        createdAt,
        updatedAt,
        lastLoginAt,
        subscriptionTier,
        isActive,
        isBlocked,
        themePreference,
        dateFormat,
        numberFormat,
        twoFactorMethod,
        netWorth,
        savingsProgress,
        darkModeEnabled,
        displayName,
        bio,
        socialLinks,
        pinCode,
        onboardingCompleted,
        kycStatus,
        taxId,
        referrerId,
        referralCode,
      ];

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, firstName: $firstName, lastName: $lastName, '
        'subscriptionTier: $subscriptionTier, isEmailVerified: $isEmailVerified)';
  }
}

/// Risk tolerance levels for investment recommendations.
enum RiskTolerance {
  /// Conservative investor - prefers low risk, stable returns.
  conservative,

  /// Moderate investor - balanced risk and reward.
  moderate,

  /// Aggressive investor - prefers high risk, high reward.
  aggressive,

  /// Very aggressive investor - maximum risk tolerance.
  veryAggressive,
}

/// User's investment experience level.
enum ExperienceLevel {
  /// No investment experience.
  beginner,

  /// Some investment experience.
  intermediate,

  /// Experienced investor.
  advanced,

  /// Professional investor.
  expert,
}

/// User's employment status.
enum EmploymentStatus {
  /// Currently employed full-time.
  employed,

  /// Currently employed part-time.
  partTime,

  /// Self-employed.
  selfEmployed,

  /// Currently unemployed.
  unemployed,

  /// Retired.
  retired,

  /// Student.
  student,

  /// Other employment status.
  other,
}

/// User's subscription tier levels.
enum SubscriptionTier {
  /// Free tier with basic features.
  free,

  /// Basic paid subscription.
  basic,

  /// Premium subscription with advanced features.
  premium,

  /// Enterprise subscription for businesses.
  enterprise,
}

/// Two-factor authentication methods.
enum TwoFactorMethod {
  /// No two-factor authentication enabled.
  none,

  /// Two-factor via SMS text message.
  sms,

  /// Two-factor via email.
  email,

  /// Two-factor via authenticator app (TOTP).
  authenticatorApp,

  /// Two-factor via hardware security key.
  hardwareKey,
}

/// KYC (Know Your Customer) verification status.
enum KycStatus {
  /// No KYC verification started.
  none,

  /// KYC verification pending review.
  pending,

  /// KYC verification in progress.
  inProgress,

  /// KYC verification completed and approved.
  verified,

  /// KYC verification failed.
  failed,

  /// KYC verification expired and needs renewal.
  expired,
}
