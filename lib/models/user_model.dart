import 'dart:convert';
import 'account_model.dart';

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

// ============================================================================
// NEW MODELS: Transaction, FinancialAccount, StockPortfolio, SavingsTarget, AppSettings
// ============================================================================

/// Transaction types enumeration
enum TransactionType {
  income,
  expense,
  transfer;

  String get displayName {
    switch (this) {
      case TransactionType.income:
        return 'Pemasukan';
      case TransactionType.expense:
        return 'Pengeluaran';
      case TransactionType.transfer:
        return 'Transfer';
    }
  }

  String get value {
    switch (this) {
      case TransactionType.income:
        return 'income';
      case TransactionType.expense:
        return 'expense';
      case TransactionType.transfer:
        return 'transfer';
    }
  }

  static TransactionType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'income':
        return TransactionType.income;
      case 'expense':
        return TransactionType.expense;
      case 'transfer':
        return TransactionType.transfer;
      default:
        return TransactionType.expense;
    }
  }
}

/// Transaction model for income, expense, and transfer transactions
class Transaction {
  final String id;
  final String userId;
  final String? accountId;
  final String? fromAccountId;
  final String? toAccountId;
  final TransactionType type;
  final double amount;
  final String? categoryId;
  final String? categoryName;
  final String? description;
  final String? notes;
  final DateTime transactionDate;
  final bool isRecurring;
  final RecurringConfig? recurringConfig;
  final String? linkedTransactionId;
  final List<String>? tags;
  final String? receiptUrl;
  final String? location;
  final Map<String, dynamic>? metadata;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const Transaction({
    required this.id,
    required this.userId,
    this.accountId,
    this.fromAccountId,
    this.toAccountId,
    required this.type,
    required this.amount,
    this.categoryId,
    this.categoryName,
    this.description,
    this.notes,
    required this.transactionDate,
    this.isRecurring = false,
    this.recurringConfig,
    this.linkedTransactionId,
    this.tags,
    this.receiptUrl,
    this.location,
    this.metadata,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Get the effective account ID based on transaction type
  String? get effectiveAccountId {
    if (accountId != null) return accountId;
    switch (type) {
      case TransactionType.income:
      case TransactionType.expense:
        return fromAccountId;
      case TransactionType.transfer:
        return fromAccountId;
    }
  }

  Transaction copyWith({
    String? id,
    String? userId,
    String? accountId,
    String? fromAccountId,
    String? toAccountId,
    TransactionType? type,
    double? amount,
    String? categoryId,
    String? categoryName,
    String? description,
    String? notes,
    DateTime? transactionDate,
    bool? isRecurring,
    RecurringConfig? recurringConfig,
    String? linkedTransactionId,
    List<String>? tags,
    String? receiptUrl,
    String? location,
    Map<String, dynamic>? metadata,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearAccountId = false,
    bool clearFromAccountId = false,
    bool clearToAccountId = false,
    bool clearCategoryId = false,
    bool clearCategoryName = false,
    bool clearDescription = false,
    bool clearNotes = false,
    bool clearRecurringConfig = false,
    bool clearLinkedTransactionId = false,
    bool clearReceiptUrl = false,
    bool clearLocation = false,
    bool clearMetadata = false,
    bool clearDeletedAt = false,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: clearAccountId ? null : (accountId ?? this.accountId),
      fromAccountId: clearFromAccountId ? null : (fromAccountId ?? this.fromAccountId),
      toAccountId: clearToAccountId ? null : (toAccountId ?? this.toAccountId),
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      categoryName: clearCategoryName ? null : (categoryName ?? this.categoryName),
      description: clearDescription ? null : (description ?? this.description),
      notes: clearNotes ? null : (notes ?? this.notes),
      transactionDate: transactionDate ?? this.transactionDate,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringConfig: clearRecurringConfig ? null : (recurringConfig ?? this.recurringConfig),
      linkedTransactionId: clearLinkedTransactionId ? null : (linkedTransactionId ?? this.linkedTransactionId),
      tags: tags ?? this.tags,
      receiptUrl: clearReceiptUrl ? null : (receiptUrl ?? this.receiptUrl),
      location: clearLocation ? null : (location ?? this.location),
      metadata: clearMetadata ? null : (metadata ?? this.metadata),
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'account_id': accountId,
      'from_account_id': fromAccountId,
      'to_account_id': toAccountId,
      'type': type.value,
      'amount': amount,
      'category_id': categoryId,
      'category_name': categoryName,
      'description': description,
      'notes': notes,
      'transaction_date': transactionDate.toIso8601String(),
      'is_recurring': isRecurring,
      'recurring_config': recurringConfig?.toJson(),
      'linked_transaction_id': linkedTransactionId,
      'tags': tags,
      'receipt_url': receiptUrl,
      'location': location,
      'metadata': metadata,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      accountId: json['account_id'] as String?,
      fromAccountId: json['from_account_id'] as String?,
      toAccountId: json['to_account_id'] as String?,
      type: TransactionType.fromString(json['type'] as String),
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['category_id'] as String?,
      categoryName: json['category_name'] as String?,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      isRecurring: json['is_recurring'] as bool? ?? false,
      recurringConfig: json['recurring_config'] != null
          ? RecurringConfig.fromJson(json['recurring_config'] as Map<String, dynamic>)
          : null,
      linkedTransactionId: json['linked_transaction_id'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>(),
      receiptUrl: json['receipt_url'] as String?,
      location: json['location'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isActive: json['is_active'] as bool? ?? true,
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

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'user_id': userId,
      'account_id': accountId,
      'from_account_id': fromAccountId,
      'to_account_id': toAccountId,
      'type': type.value,
      'amount': amount,
      'category_id': categoryId,
      'category_name': categoryName,
      'description': description,
      'notes': notes,
      'transaction_date': transactionDate.millisecondsSinceEpoch,
      'is_recurring': isRecurring,
      'recurring_config': recurringConfig?.toFirestore(),
      'linked_transaction_id': linkedTransactionId,
      'tags': tags,
      'receipt_url': receiptUrl,
      'location': location,
      'metadata': metadata,
      'is_active': isActive,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Transaction.fromFirestore(Map<String, dynamic> doc) {
    return Transaction(
      id: doc['id'] as String,
      userId: doc['user_id'] as String,
      accountId: doc['account_id'] as String?,
      fromAccountId: doc['from_account_id'] as String?,
      toAccountId: doc['to_account_id'] as String?,
      type: TransactionType.fromString(doc['type'] as String),
      amount: (doc['amount'] as num).toDouble(),
      categoryId: doc['category_id'] as String?,
      categoryName: doc['category_name'] as String?,
      description: doc['description'] as String?,
      notes: doc['notes'] as String?,
      transactionDate: DateTime.fromMillisecondsSinceEpoch(doc['transaction_date'] as int),
      isRecurring: doc['is_recurring'] as bool? ?? false,
      recurringConfig: doc['recurring_config'] != null
          ? RecurringConfig.fromFirestore(doc['recurring_config'] as Map<String, dynamic>)
          : null,
      linkedTransactionId: doc['linked_transaction_id'] as String?,
      tags: (doc['tags'] as List<dynamic>?)?.cast<String>(),
      receiptUrl: doc['receipt_url'] as String?,
      location: doc['location'] as String?,
      metadata: doc['metadata'] as Map<String, dynamic>?,
      isActive: doc['is_active'] as bool? ?? true,
      createdAt: doc['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(doc['created_at'] as int)
          : DateTime.now(),
      updatedAt: doc['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(doc['updated_at'] as int)
          : DateTime.now(),
      deletedAt: doc['deleted_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(doc['deleted_at'] as int)
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Transaction(id: $id, type: $type, amount: $amount, date: $transactionDate)';
  }
}

/// Configuration for recurring transactions
class RecurringConfig {
  final String frequency; // daily, weekly, monthly, yearly
  final int interval;
  final DateTime? nextOccurrence;
  final DateTime? endDate;
  final int? maxOccurrences;

  const RecurringConfig({
    required this.frequency,
    this.interval = 1,
    this.nextOccurrence,
    this.endDate,
    this.maxOccurrences,
  });

  Map<String, dynamic> toJson() {
    return {
      'frequency': frequency,
      'interval': interval,
      'next_occurrence': nextOccurrence?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'max_occurrences': maxOccurrences,
    };
  }

  factory RecurringConfig.fromJson(Map<String, dynamic> json) {
    return RecurringConfig(
      frequency: json['frequency'] as String,
      interval: json['interval'] as int? ?? 1,
      nextOccurrence: json['next_occurrence'] != null
          ? DateTime.parse(json['next_occurrence'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      maxOccurrences: json['max_occurrences'] as int?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'frequency': frequency,
      'interval': interval,
      'next_occurrence': nextOccurrence?.millisecondsSinceEpoch,
      'end_date': endDate?.millisecondsSinceEpoch,
      'max_occurrences': maxOccurrences,
    };
  }

  factory RecurringConfig.fromFirestore(Map<String, dynamic> doc) {
    return RecurringConfig(
      frequency: doc['frequency'] as String,
      interval: doc['interval'] as int? ?? 1,
      nextOccurrence: doc['next_occurrence'] != null
          ? DateTime.fromMillisecondsSinceEpoch(doc['next_occurrence'] as int)
          : null,
      endDate: doc['end_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(doc['end_date'] as int)
          : null,
      maxOccurrences: doc['max_occurrences'] as int?,
    );
  }
}
  
/// Financial Account model (cash, bank, investment accounts)
class FinancialAccount {
  final String id;
  final String userId;
  final String name;
  final AccountType type;
  final double balance;
  final double initialBalance;
  final String? currencyCode;
  final String? iconName;
  final String? color;
  final String? institutionName;
  final String? accountNumber;
  final bool includeInTotal;
  final bool showInDashboard;
  final int sortOrder;
  final bool isActive;
  final DateTime? lastSyncAt;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const FinancialAccount({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    this.balance = 0,
    this.initialBalance = 0,
    this.currencyCode = 'IDR',
    this.iconName,
    this.color,
    this.institutionName,
    this.accountNumber,
    this.includeInTotal = true,
    this.showInDashboard = true,
    this.sortOrder = 0,
    this.isActive = true,
    this.lastSyncAt,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Calculate total change from initial balance
  double get totalChange => balance - initialBalance;

  /// Calculate percentage change from initial balance
  double get percentageChange {
    if (initialBalance == 0) return 0;
    return ((balance - initialBalance) / initialBalance) * 100;
  }

  /// Check if balance is negative (for credit/loan accounts)
  bool get hasNegativeBalance => balance < 0;

  FinancialAccount copyWith({
    String? id,
    String? userId,
    String? name,
    AccountType? type,
    double? balance,
    double? initialBalance,
    String? currencyCode,
    String? iconName,
    String? color,
    String? institutionName,
    String? accountNumber,
    bool? includeInTotal,
    bool? showInDashboard,
    int? sortOrder,
    bool? isActive,
    DateTime? lastSyncAt,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearIconName = false,
    bool clearColor = false,
    bool clearInstitutionName = false,
    bool clearAccountNumber = false,
    bool clearLastSyncAt = false,
    bool clearMetadata = false,
    bool clearDeletedAt = false,
  }) {
    return FinancialAccount(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      initialBalance: initialBalance ?? this.initialBalance,
      currencyCode: currencyCode ?? this.currencyCode,
      iconName: clearIconName ? null : (iconName ?? this.iconName),
      color: clearColor ? null : (color ?? this.color),
      institutionName: clearInstitutionName ? null : (institutionName ?? this.institutionName),
      accountNumber: clearAccountNumber ? null : (accountNumber ?? this.accountNumber),
      includeInTotal: includeInTotal ?? this.includeInTotal,
      showInDashboard: showInDashboard ?? this.showInDashboard,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      lastSyncAt: clearLastSyncAt ? null : (lastSyncAt ?? this.lastSyncAt),
      metadata: clearMetadata ? null : (metadata ?? this.metadata),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type.value,
      'balance': balance,
      'initial_balance': initialBalance,
      'currency_code': currencyCode,
      'icon_name': iconName,
      'color': color,
      'institution_name': institutionName,
      'account_number': accountNumber,
      'include_in_total': includeInTotal,
      'show_in_dashboard': showInDashboard,
      'sort_order': sortOrder,
      'is_active': isActive,
      'last_sync_at': lastSyncAt?.toIso8601String(),
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  factory FinancialAccount.fromJson(Map<String, dynamic> json) {
    return FinancialAccount(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      type: AccountType.fromString(json['type'] as String),
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      initialBalance: (json['initial_balance'] as num?)?.toDouble() ?? 0,
      currencyCode: json['currency_code'] as String? ?? 'IDR',
      iconName: json['icon_name'] as String?,
      color: json['color'] as String?,
      institutionName: json['institution_name'] as String?,
      accountNumber: json['account_number'] as String?,
      includeInTotal: json['include_in_total'] as bool? ?? true,
      showInDashboard: json['show_in_dashboard'] as bool? ?? true,
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      lastSyncAt: json['last_sync_at'] != null
          ? DateTime.parse(json['last_sync_at'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
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

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type.value,
      'balance': balance,
      'initial_balance': initialBalance,
      'currency_code': currencyCode,
      'icon_name': iconName,
      'color': color,
      'institution_name': institutionName,
      'account_number': accountNumber,
      'include_in_total': includeInTotal,
      'show_in_dashboard': showInDashboard,
      'sort_order': sortOrder,
      'is_active': isActive,
      'last_sync_at': lastSyncAt?.millisecondsSinceEpoch,
      'metadata': metadata,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory FinancialAccount.fromFirestore(Map<String, dynamic> doc) {
    return FinancialAccount(
      id: doc['id'] as String,
      userId: doc['user_id'] as String,
      name: doc['name'] as String,
      type: AccountType.fromString(doc['type'] as String),
      balance: (doc['balance'] as num?)?.toDouble() ?? 0,
      initialBalance: (doc['initial_balance'] as num?)?.toDouble() ?? 0,
      currencyCode: doc['currency_code'] as String? ?? 'IDR',
      iconName: doc['icon_name'] as String?,
      color: doc['color'] as String?,
      institutionName: doc['institution_name'] as String?,
      accountNumber: doc['account_number'] as String?,
      includeInTotal: doc['include_in_total'] as bool? ?? true,
      showInDashboard: doc['show_in_dashboard'] as bool? ?? true,
      sortOrder: doc['sort_order'] as int? ?? 0,
      isActive: doc['is_active'] as bool? ?? true,
      lastSyncAt: doc['last_sync_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(doc['last_sync_at'] as int)
          : null,
      metadata: doc['metadata'] as Map<String, dynamic>?,
      createdAt: doc['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(doc['created_at'] as int)
          : DateTime.now(),
      updatedAt: doc['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(doc['updated_at'] as int)
          : DateTime.now(),
      deletedAt: doc['deleted_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(doc['deleted_at'] as int)
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FinancialAccount && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'FinancialAccount(id: $id, name: $name, type: $type, balance: $balance)';
  }
}

/// Stock exchange enumeration
enum StockExchange {
  idx,    // Indonesia Stock Exchange
  nyse,   // New York Stock Exchange
  nasdaq, // NASDAQ
  asx,    // Australian Securities Exchange
  lse,    // London Stock Exchange
  other;

  String get displayName {
    switch (this) {
      case StockExchange.idx:
        return 'IDX';
      case StockExchange.nyse:
        return 'NYSE';
      case StockExchange.nasdaq:
        return 'NASDAQ';
      case StockExchange.asx:
        return 'ASX';
      case StockExchange.lse:
        return 'LSE';
      case StockExchange.other:
        return 'Lainnya';
    }
  }

  String get value {
    switch (this) {
      case StockExchange.idx:
        return 'idx';
      case StockExchange.nyse:
        return 'nyse';
      case StockExchange.nasdaq:
        return 'nasdaq';
      case StockExchange.asx:
        return 'asx';
      case StockExchange.lse:
        return 'lse';
      case StockExchange.other:
        return 'other';
    }
  }

  static StockExchange fromString(String value) {
    switch (value.toLowerCase()) {
      case 'idx':
        return StockExchange.idx;
      case 'nyse':
        return StockExchange.nyse;
      case 'nasdaq':
        return StockExchange.nasdaq;
      case 'asx':
        return StockExchange.asx;
      case 'lse':
        return StockExchange.lse;
      default:
        return StockExchange.other;
    }
  }
}

/// Stock Portfolio model for tracking stock investments
class StockPortfolio {
  final String id;
  final String userId;
  final String ticker;
  final String? companyName;
  final StockExchange exchange;
  final int lot; // Number of lots owned (1 lot = 100 shares for IDX)
  final int shares; // Total number of shares
  final double averageBuyPrice;
  final double totalInvestment;
  final double? currentPrice;
  final double? currentValue;
  final double? profitLoss;
  final double? profitLossPercentage;
  final String? currencyCode;
  final String? accountId;
  final String? notes;
  final List<StockTransaction>? transactions;
  final bool isWatchlist;
  final double? targetPrice;
  final double? stopLossPrice;
  final Map<String, dynamic>? metadata;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const StockPortfolio({
    required this.id,
    required this.userId,
    required this.ticker,
    this.companyName,
    required this.exchange,
    this.lot = 0,
    this.shares = 0,
    this.averageBuyPrice = 0,
    this.totalInvestment = 0,
    this.currentPrice,
    this.currentValue,
    this.profitLoss,
    this.profitLossPercentage,
    this.currencyCode = 'IDR',
    this.accountId,
    this.notes,
    this.transactions,
    this.isWatchlist = false,
    this.targetPrice,
    this.stopLossPrice,
    this.metadata,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Check if this is a watchlist item (no holdings)
  bool get isHolding => shares > 0;

  /// Calculate total return including dividends (if available)
  double get totalReturn => profitLoss ?? 0;

  /// Check if currently in profit
  bool get isProfit => (profitLoss ?? 0) > 0;

  /// Check if currently at loss
  bool get isLoss => (profitLoss ?? 0) < 0;

  /// Calculate return percentage
  double get returnPercentage => profitLossPercentage ?? 0;

  /// Check if price reached target
  bool get reachedTarget => targetPrice != null && currentPrice != null && currentPrice! >= targetPrice!;

  /// Check if price hit stop loss
  bool get hitStopLoss => stopLossPrice != null && currentPrice != null && currentPrice! <= stopLossPrice!;

  StockPortfolio copyWith({
    String? id,
    String? userId,
    String? ticker,
    String? companyName,
    StockExchange? exchange,
    int? lot,
    int? shares,
    double? averageBuyPrice,
    double? totalInvestment,
    double? currentPrice,
    double? currentValue,
    double? profitLoss,
    double? profitLossPercentage,
    String? currencyCode,
    String? accountId,
    String? notes,
    List<StockTransaction>? transactions,
    bool? isWatchlist,
    double? targetPrice,
    double? stopLossPrice,
    Map<String, dynamic>? metadata,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearCompanyName = false,
    bool clearCurrentPrice = false,
    bool clearCurrentValue = false,
    bool clearProfitLoss = false,
    bool clearProfitLossPercentage = false,
    bool clearAccountId = false,
    bool clearNotes = false,
    bool clearTransactions = false,
    bool clearTargetPrice = false,
    bool clearStopLossPrice = false,
    bool clearMetadata = false,
    bool clearDeletedAt = false,
  }) {
    return StockPortfolio(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      ticker: ticker ?? this.ticker,
      companyName: clearCompanyName ? null : (companyName ?? this.companyName),
      exchange: exchange ?? this.exchange,
      lot: lot ?? this.lot,
      shares: shares ?? this.shares,
      averageBuyPrice: averageBuyPrice ?? this.averageBuyPrice,
      totalInvestment: totalInvestment ?? this.totalInvestment,
      currentPrice: clearCurrentPrice ? null : (currentPrice ?? this.currentPrice),
      currentValue: clearCurrentValue ? null : (currentValue ?? this.currentValue),
      profitLoss: clearProfitLoss ? null : (profitLoss ?? this.profitLoss),
      profitLossPercentage: clearProfitLossPercentage ? null : (profitLossPercentage ?? this.profitLossPercentage),
      currencyCode: currencyCode ?? this.currencyCode,
      accountId: clearAccountId ? null : (accountId ?? this.accountId),
      notes: clearNotes ? null : (notes ?? this.notes),
      transactions: clearTransactions ? null : (transactions ?? this.transactions),
      isWatchlist: isWatchlist ?? this.isWatchlist,
      targetPrice: clearTargetPrice ? null : (targetPrice ?? this.targetPrice),
      stopLossPrice: clearStopLossPrice ? null : (stopLossPrice ?? this.stopLossPrice),
      metadata: clearMetadata ? null : (metadata ?? this.metadata),
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'ticker': ticker,
      'company_name': companyName,
      'exchange': exchange.value,
      'lot': lot,
      'shares': shares,
      'average_buy_price': averageBuyPrice,
      'total_investment': totalInvestment,
      'current_price': currentPrice,
      'current_value': currentValue,
      'profit_loss': profitLoss,
      'profit_loss_percentage': profitLossPercentage,
      'currency_code': currencyCode,
      'account_id': accountId,
      'notes': notes,
      'transactions': transactions?.map((t) => t.toJson()).toList(),
      'is_watchlist': isWatchlist,
      'target_price': targetPrice,
      'stop_loss_price': stopLossPrice,
      'metadata': metadata,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  factory StockPortfolio.fromJson(Map<String, dynamic> json) {
    return StockPortfolio(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      ticker: json['ticker'] as String,
      companyName: json['company_name'] as String?,
      exchange: StockExchange.fromString(json['exchange'] as String),
      lot: json['lot'] as int? ?? 0,
      shares: json['shares'] as int? ?? 0,
      averageBuyPrice: (json['average_buy_price'] as num?)?.toDouble() ?? 0,
      totalInvestment: (json['total_investment'] as num?)?.toDouble() ?? 0,
      currentPrice: (json['current_price'] as num?)?.toDouble(),
      currentValue: (json['current_value'] as num?)?.toDouble(),
      profitLoss: (json['profit_loss'] as num?)?.toDouble(),
      profitLossPercentage: (json['profit_loss_percentage'] as num?)?.toDouble(),
      currencyCode: json['currency_code'] as String? ?? 'IDR',
      accountId: json['account_id'] as String?,
      notes: json['notes'] as String?,
      transactions: (json['transactions'] as List<dynamic>?)
          ?.map((t) => StockTransaction.fromJson(t as Map<String, dynamic>))
          .toList(),
      isWatchlist: json['is_watchlist'] as bool? ?? false,
      targetPrice: (json['target_price'] as num?)?.toDouble(),
      stopLossPrice: (json['stop_loss_price'] as num?)?.toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>?,
      isActive: json['is_active'] as bool? ?? true,
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

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'user_id': userId,
      'ticker': ticker,
      'company_name': companyName,
      'exchange': exchange.value,
      'lot': lot,
      'shares': shares,
      'average_buy_price': averageBuyPrice,
      'total_investment': totalInvestment,
      'current_price': currentPrice,
      'current_value': currentValue,
      'profit_loss': profitLoss,
      'profit_loss_percentage': profitLossPercentage,
      'currency_code': currencyCode,
      'account_id': accountId,
      'notes': notes,
      'transactions': transactions?.map((t) => t.toFirestore()).toList(),
      'is_watchlist': isWatchlist,
      'target_price': targetPrice,
      'stop_loss_price': stopLossPrice,
      'metadata': metadata,
      'is_active': isActive,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory StockPortfolio.fromFirestore(Map<String, dynamic> doc) {
    return StockPortfolio(
      id: doc['id'] as String,
      userId: doc['user_id'] as String,
      ticker: doc['ticker'] as String,
      companyName: doc['company_name'] as String?,
      exchange: StockExchange.fromString(doc['exchange'] as String),
      lot: doc['lot'] as int? ?? 0,
      shares: doc['shares'] as int? ?? 0,
      averageBuyPrice: (doc['average_buy_price'] as num?)?.toDouble() ?? 0,
      totalInvestment: (doc['total_investment'] as num?)?.toDouble() ?? 0,
      currentPrice: (doc['current_price'] as num?)?.toDouble(),
      currentValue: (doc['current_value'] as num?)?.toDouble(),
      profitLoss: (doc['profit_loss'] as num?)?.toDouble(),
      profitLossPercentage: (doc['profit_loss_percentage'] as num?)?.toDouble(),
      currencyCode: doc['currency_code'] as String? ?? 'IDR',
      accountId: doc['account_id'] as String?,
      notes: doc['notes'] as String?,
      transactions: (doc['transactions'] as List<dynamic>?)
          ?.map((t) => StockTransaction.fromFirestore(t as Map<String, dynamic>))
          .toList(),
      isWatchlist: doc['is_watchlist'] as bool? ?? false,
      targetPrice: (doc['target_price'] as num?)?.toDouble(),
      stopLossPrice: (doc['stop_loss_price'] as num?)?.toDouble(),
      metadata: doc['metadata'] as Map<String, dynamic>?,
      isActive: doc['is_active'] as bool? ?? true,
      createdAt: doc['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(doc['created_at'] as int)
          : DateTime.now(),
      updatedAt: doc['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(doc['updated_at'] as int)
          : DateTime.now(),
      deletedAt: doc['deleted_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(doc['deleted_at'] as int)
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StockPortfolio && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'StockPortfolio(id: $id, ticker: $ticker, shares: $shares, currentValue: $currentValue)';
  }
}

/// Stock transaction types
enum StockTransactionType {
  buy,
  sell,
  dividend,
  split,
  bonus,
  rights;

  String get displayName {
    switch (this) {
      case StockTransactionType.buy:
        return 'Beli';
      case StockTransactionType.sell:
        return 'Jual';
      case StockTransactionType.dividend:
        return 'Dividen';
      case StockTransactionType.split:
        return 'Stock Split';
      case StockTransactionType.bonus:
        return 'Bonus';
      case StockTransactionType.rights:
        return 'Rights Issue';
    }
  }

  String get value {
    switch (this) {
      case StockTransactionType.buy:
        return 'buy';
      case StockTransactionType.sell:
        return 'sell';
      case StockTransactionType.dividend:
        return 'dividend';
      case StockTransactionType.split:
        return 'split';
      case StockTransactionType.bonus:
        return 'bonus';
      case StockTransactionType.rights:
        return 'rights';
    }
  }

  static StockTransactionType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'buy':
        return StockTransactionType.buy;
      case 'sell':
        return StockTransactionType.sell;
      case 'dividend':
        return StockTransactionType.dividend;
      case 'split':
        return StockTransactionType.split;
      case 'bonus':
        return StockTransactionType.bonus;
      case 'rights':
        return StockTransactionType.rights;
      default:
        return StockTransactionType.buy;
    }
  }
}

/// Individual stock transaction record
class StockTransaction {
  final String id;
  final String portfolioId;
  final String userId;
  final String ticker;
  final StockTransactionType type;
  final int lot;
  final int shares;
  final double pricePerShare;
  final double totalAmount;
  final double? fee;
  final double? tax;
  final DateTime transactionDate;
  final String? exchange;
  final String? notes;
  final String? accountId;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StockTransaction({
    required this.id,
    required this.portfolioId,
    required this.userId,
    required this.ticker,
    required this.type,
    required this.lot,
    required this.shares,
    required this.pricePerShare,
    required this.totalAmount,
    this.fee,
    this.tax,
    required this.transactionDate,
    this.exchange,
    this.notes,
    this.accountId,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Total cost including fee and tax
  double get totalCost => totalAmount + (fee ?? 0) + (tax ?? 0);

  StockTransaction copyWith({
    String? id,
    String? portfolioId,
    String? userId,
    String? ticker,
    StockTransactionType? type,
    int? lot,
    int? shares,
    double? pricePerShare,
    double? totalAmount,
    double? fee,
    double? tax,
    DateTime? transactionDate,
    String? exchange,
    String? notes,
    String? accountId,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearFee = false,
    bool clearTax = false,
    bool clearExchange = false,
    bool clearNotes = false,
    bool clearAccountId = false,
    bool clearMetadata = false,
  }) {
    return StockTransaction(
      id: id ?? this.id,
      portfolioId: portfolioId ?? this.portfolioId,
      userId: userId ?? this.userId,
      ticker: ticker ?? this.ticker,
      type: type ?? this.type,
      lot: lot ?? this.lot,
      shares: shares ?? this.shares,
      pricePerShare: pricePerShare ?? this.pricePerShare,
      totalAmount: totalAmount ?? this.totalAmount,
      fee: clearFee ? null : (fee ?? this.fee),
      tax: clearTax ? null : (tax ?? this.tax),
      transactionDate: transactionDate ?? this.transactionDate,
      exchange: clearExchange ? null : (exchange ?? this.exchange),
      notes: clearNotes ? null : (notes ?? this.notes),
      accountId: clearAccountId ? null : (accountId ?? this.accountId),
      metadata: clearMetadata ? null : (metadata ?? this.metadata),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'portfolio_id': portfolioId,
      'user_id': userId,
      'ticker': ticker,
      'type': type.value,
      'lot': lot,
      'shares': shares,
      'price_per_share': pricePerShare,
      'total_amount': totalAmount,
      'fee': fee,
      'tax': tax,
      'transaction_date': transactionDate.toIso8601String(),
      'exchange': exchange,
      'notes': notes,
      'account_id': accountId,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory StockTransaction.fromJson(Map<String, dynamic> json) {
    return StockTransaction(
      id: json['id'] as String,
      portfolioId: json['portfolio_id'] as String,
      userId: json['user_id'] as String,
      ticker: json['ticker'] as String,
      type: StockTransactionType.fromString(json['type'] as String),
      lot: json['lot'] as int,
      shares: json['shares'] as int,
      pricePerShare: (json['price_per_share'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      fee: (json['fee'] as num?)?.toDouble(),
      tax: (json['tax'] as num?)?.toDouble(),
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      exchange: json['exchange'] as String?,
      notes: json['notes'] as String?,
      accountId: json['account_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'portfolio_id': portfolioId,
      'user_id': userId,
      'ticker': ticker,
      'type': type.value,
      'lot': lot,
      'shares': shares,
      'price_per_share': pricePerShare,
      'total_amount': totalAmount,
      'fee': fee,
      'tax': tax,
      'transaction_date': transactionDate.millisecondsSinceEpoch,
      'exchange': exchange,
      'notes': notes,
      'account_id': accountId,
      'metadata': metadata,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory StockTransaction.fromFirestore(Map<String, dynamic> doc) {
    return StockTransaction(
      id: doc['id'] as String,
      portfolioId: doc['portfolio_id'] as String,
      userId: doc['user_id'] as String,
      ticker: doc['ticker'] as String,
      type: StockTransactionType.fromString(doc['type'] as String),
      lot: doc['lot'] as int,
      shares: doc['shares'] as int,
      pricePerShare: (doc['price_per_share'] as num).toDouble(),
      totalAmount: (doc['total_amount'] as num).toDouble(),
      fee: (doc['fee'] as num?)?.toDouble(),
      tax: (doc['tax'] as num?)?.toDouble(),
      transactionDate: DateTime.fromMillisecondsSinceEpoch(doc['transaction_date'] as int),
      exchange: doc['exchange'] as String?,
      notes: doc['notes'] as String?,
      accountId: doc['account_id'] as String?,
      metadata: doc['metadata'] as Map<String, dynamic>?,
      createdAt: doc['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(doc['created_at'] as int)
          : DateTime.now(),
      updatedAt: doc['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(doc['updated_at'] as int)
          : DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StockTransaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Savings target status
enum SavingsStatus {
  active,
  completed,
  paused,
  cancelled;

  String get displayName {
    switch (this) {
      case SavingsStatus.active:
        return 'Aktif';
      case SavingsStatus.completed:
        return 'Tercapai';
      case SavingsStatus.paused:
        return 'Dijeda';
      case SavingsStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  String get value {
    switch (this) {
      case SavingsStatus.active:
        return 'active';
      case SavingsStatus.completed:
        return 'completed';
      case SavingsStatus.paused:
        return 'paused';
      case SavingsStatus.cancelled:
        return 'cancelled';
    }
  }

  static SavingsStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'active':
        return SavingsStatus.active;
      case 'completed':
        return SavingsStatus.completed;
      case 'paused':
        return SavingsStatus.paused;
      case 'cancelled':
        return SavingsStatus.cancelled;
      default:
        return SavingsStatus.active;
    }
  }
}

/// Priority levels for savings targets
enum SavingsPriority {
  low,
  medium,
  high,
  urgent;

  String get displayName {
    switch (this) {
      case SavingsPriority.low:
        return 'Rendah';
      case SavingsPriority.medium:
        return 'Sedang';
      case SavingsPriority.high:
        return 'Tinggi';
      case SavingsPriority.urgent:
        return 'Sangat Urgent';
    }
  }

  String get value {
    switch (this) {
      case SavingsPriority.low:
        return 'low';
      case SavingsPriority.medium:
        return 'medium';
      case SavingsPriority.high:
        return 'high';
      case SavingsPriority.urgent:
        return 'urgent';
    }
  }

  static SavingsPriority fromString(String value) {
    switch (value.toLowerCase()) {
      case 'low':
        return SavingsPriority.low;
      case 'medium':
        return SavingsPriority.medium;
      case 'high':
        return SavingsPriority.high;
      case 'urgent':
        return SavingsPriority.urgent;
      default:
        return SavingsPriority.medium;
    }
  }
}

/// Savings Target model for tracking savings goals
class SavingsTarget {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final double targetAmount;
  final double currentAmount;
  final String? currencyCode;
  final DateTime? targetDate;
  final DateTime? startDate;
  final SavingsStatus status;
  final SavingsPriority priority;
  final String? iconName;
  final String? color;
  final String? accountId;
  final double? monthlyTarget;
  final int? monthsRemaining;
  final double? requiredMonthlySaving;
  final List<SavingsContribution>? contributions;
  final List<String>? tags;
  final bool enableReminders;
  final bool autoSave;
  final Map<String, dynamic>? metadata;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const SavingsTarget({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.targetAmount,
    this.currentAmount = 0,
    this.currencyCode = 'IDR',
    this.targetDate,
    this.startDate,
    this.status = SavingsStatus.active,
    this.priority = SavingsPriority.medium,
    this.iconName,
    this.color,
    this.accountId,
    this.monthlyTarget,
    this.monthsRemaining,
    this.requiredMonthlySaving,
    this.contributions,
    this.tags,
    this.enableReminders = true,
    this.autoSave = false,
    this.metadata,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Calculate progress percentage
  double get progressPercentage {
    if (targetAmount <= 0) return 0;
    return (currentAmount / targetAmount * 100).clamp(0, 100);
  }

  /// Calculate remaining amount to reach goal
  double get remainingAmount => (targetAmount - currentAmount).clamp(0, double.infinity);

  /// Check if goal is completed
  bool get isCompleted => currentAmount >= targetAmount;

  /// Check if goal is overdue
  bool get isOverdue {
    if (targetDate == null) return false;
    return DateTime.now().isAfter(targetDate!) && !isCompleted;
  }

  /// Calculate days remaining until target date
  int? get daysRemaining {
    if (targetDate == null) return null;
    return targetDate!.difference(DateTime.now()).inDays;
  }

  /// Calculate suggested monthly saving to reach goal on time
  double get suggestedMonthlySaving {
    if (targetDate == null || remainingAmount <= 0) return 0;
    final days = daysRemaining;
    if (days == null || days <= 0) return remainingAmount;
    final months = (days / 30).ceil();
    return remainingAmount / months;
  }

  SavingsTarget copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    double? targetAmount,
    double? currentAmount,
    String? currencyCode,
    DateTime? targetDate,
    DateTime? startDate,
    SavingsStatus? status,
    SavingsPriority? priority,
    String? iconName,
    String? color,
    String? accountId,
    double? monthlyTarget,
    int? monthsRemaining,
    double? requiredMonthlySaving,
    List<SavingsContribution>? contributions,
    List<String>? tags,
    bool? enableReminders,
    bool? autoSave,
    Map<String, dynamic>? metadata,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearDescription = false,
    bool clearTargetDate = false,
    bool clearStartDate = false,
    bool clearIconName = false,
    bool clearColor = false,
    bool clearAccountId = false,
    bool clearMonthlyTarget = false,
    bool clearMonthsRemaining = false,
    bool clearRequiredMonthlySaving = false,
    bool clearContributions = false,
    bool clearTags = false,
    bool clearMetadata = false,
    bool clearDeletedAt = false,
  }) {
    return SavingsTarget(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: clearDescription ? null : (description ?? this.description),
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      currencyCode: currencyCode ?? this.currencyCode,
      targetDate: clearTargetDate ? null : (targetDate ?? this.targetDate),
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      status: status ?? this.status,
      priority: priority ?? this.priority,
      iconName: clearIconName ? null : (iconName ?? this.iconName),
      color: clearColor ? null : (color ?? this.color),
      accountId: clearAccountId ? null : (accountId ?? this.accountId),
      monthlyTarget: clearMonthlyTarget ? null : (monthlyTarget ?? this.monthlyTarget),
      monthsRemaining: clearMonthsRemaining ? null : (monthsRemaining ?? this.monthsRemaining),
      requiredMonthlySaving: clearRequiredMonthlySaving ? null : (requiredMonthlySaving ?? this.requiredMonthlySaving),
      contributions: clearContributions ? null : (contributions ?? this.contributions),
      tags: clearTags ? null : (tags ?? this.tags),
      enableReminders: enableReminders ?? this.enableReminders,
      autoSave: autoSave ?? this.autoSave,
      metadata: clearMetadata ? null : (metadata ?? this.metadata),
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'currency_code': currencyCode,
      'target_date': targetDate?.toIso8601String(),
      'start_date': startDate?.toIso8601String(),
      'status': status.value,
      'priority': priority.value,
      'icon_name': iconName,
      'color': color,
      'account_id': accountId,
      'monthly_target': monthlyTarget,
      'months_remaining': monthsRemaining,
      'required_monthly_saving': requiredMonthlySaving,
      'contributions': contributions?.map((c) => c.toJson()).toList(),
      'tags': tags,
      'enable_reminders': enableReminders,
      'auto_save': autoSave,
      'metadata': metadata,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  factory SavingsTarget.fromJson(Map<String, dynamic> json) {
    return SavingsTarget(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      targetAmount: (json['target_amount'] as num).toDouble(),
      currentAmount: (json['current_amount'] as num?)?.toDouble() ?? 0,
      currencyCode: json['currency_code'] as String? ?? 'IDR',
      targetDate: json['target_date'] != null
          ? DateTime.parse(json['target_date'] as String)
          : null,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      status: SavingsStatus.fromString(json['status'] as String? ?? 'active'),
      priority: SavingsPriority.fromString(json['priority'] as String? ?? 'medium'),
      iconName: json['icon_name'] as String?,
      color: json['color'] as String?,
      accountId: json['account_id'] as String?,
      monthlyTarget: (json['monthly_target'] as num?)?.toDouble(),
      monthsRemaining: json['months_remaining'] as int?,
      requiredMonthlySaving: (json['required_monthly_saving'] as num?)?.toDouble(),
      contributions: (json['contributions'] as List<dynamic>?)
          ?.map((c) => SavingsContribution.fromJson(c as Map<String, dynamic>))
          .toList(),
      tags: (json['tags'] as List<dynamic>?)?.cast<String>(),
      enableReminders: json['enable_reminders'] as bool? ?? true,
      autoSave: json['auto_save'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isActive: json['is_active'] as bool? ?? true,
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

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'currency_code': currencyCode,
      'target_date': targetDate?.millisecondsSinceEpoch,
      'start_date': startDate?.millisecondsSinceEpoch,
      'status': status.value,
      'priority': priority.value,
      'icon_name': iconName,
      'color': color,
      'account_id': accountId,
      'monthly_target': monthlyTarget,
      'months_remaining': monthsRemaining,
      'required_monthly_saving': requiredMonthlySaving,
      'contributions': contributions?.map((c) => c.toFirestore()).toList(),
      'tags': tags,
      'enable_reminders': enableReminders,
      'auto_save': autoSave,
      'metadata': metadata,
      'is_active': isActive,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory SavingsTarget.fromFirestore(Map<String, dynamic> doc) {
    return SavingsTarget(
      id: doc['id'] as String,
      userId: doc['user_id'] as String,
      name: doc['name'] as String,
      description: doc['description'] as String?,
      targetAmount: (doc['target_amount'] as num).toDouble(),
      currentAmount: (doc['current_amount'] as num?)?.toDouble() ?? 0,
      currencyCode: doc['currency_code'] as String? ?? 'IDR',
      targetDate: doc['target_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(doc['target_date'] as int)
          : null,
      startDate: doc['start_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(doc['start_date'] as int)
          : null,
      status: SavingsStatus.fromString(doc['status'] as String? ?? 'active'),
      priority: SavingsPriority.fromString(doc['priority'] as String? ?? 'medium'),
      iconName: doc['icon_name'] as String?,
      color: doc['color'] as String?,
      accountId: doc['account_id'] as String?,
      monthlyTarget: (doc['monthly_target'] as num?)?.toDouble(),
      monthsRemaining: doc['months_remaining'] as int?,
      requiredMonthlySaving: (doc['required_monthly_saving'] as num?)?.toDouble(),
      contributions: (doc['contributions'] as List<dynamic>?)
          ?.map((c) => SavingsContribution.fromFirestore(c as Map<String, dynamic>))
          .toList(),
      tags: (doc['tags'] as List<dynamic>?)?.cast<String>(),
      enableReminders: doc['enable_reminders'] as bool? ?? true,
      autoSave: doc['auto_save'] as bool? ?? false,
      metadata: doc['metadata'] as Map<String, dynamic>?,
      isActive: doc['is_active'] as bool? ?? true,
      createdAt: doc['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(doc['created_at'] as int)
          : DateTime.now(),
      updatedAt: doc['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(doc['updated_at'] as int)
          : DateTime.now(),
      deletedAt: doc['deleted_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(doc['deleted_at'] as int)
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SavingsTarget && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'SavingsTarget(id: $id, name: $name, progress: $progressPercentage%, current: $currentAmount, target: $targetAmount)';
  }
}

/// Individual savings contribution record
class SavingsContribution {
  final String id;
  final String savingsTargetId;
  final String userId;
  final double amount;
  final DateTime contributionDate;
  final String? notes;
  final String? accountId;
  final String? transactionId;
  final Map<String, dynamic>? metadata;
  final DateTime date;

  const SavingsContribution({
    required this.id,
    required this.savingsTargetId,
    required this.userId,
    required this.amount,
    required this.date,
    this.notes,
    this.accountId,
    this.transactionId,
    this.metadata,
    required this.createdAt,
  });

  SavingsContribution copyWith({
    String? id,
    String? savingsTargetId,
    String? userId,
    double? amount,
    DateTime? contributionDate,
    String? notes,
    String? accountId,
    String? transactionId,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    bool clearNotes = false,
    bool clearAccountId = false,
    bool clearTransactionId = false,
    bool clearMetadata = false,
  }) {
    return SavingsContribution(
      id: id ?? this.id,
      savingsTargetId: savingsTargetId ?? this.savingsTargetId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      contributionDate: contributionDate ?? this.contributionDate,
      notes: clearNotes ? null : (notes ?? this.notes),
      accountId: clearAccountId ? null : (accountId ?? this.accountId),
      transactionId: clearTransactionId ? null : (transactionId ?? this.transactionId),
      metadata: clearMetadata ? null : (metadata ?? this.metadata),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'savings_target_id': savingsTargetId,
      'user_id': userId,
      'amount': amount,
      'contribution_date': contributionDate.toIso8601String(),
      'notes': notes,
      'account_id': accountId,
      'transaction_id': transactionId,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SavingsContribution.fromJson(Map<String, dynamic> json) {
    return SavingsContribution(
      id: json['id'] as String,
      savingsTargetId: json['savings_target_id'] as String,
      userId: json['user_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      contributionDate: DateTime.parse(json['contribution_date'] as String),
      notes: json['notes'] as String?,
      accountId: json['account_id'] as String?,
      transactionId: json['transaction_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'savings_target_id': savingsTargetId,
      'user_id': userId,
      'amount': amount,
      'contribution_date': contributionDate.millisecondsSinceEpoch,
      'notes': notes,
      'account_id': accountId,
      'transaction_id': transactionId,
      'metadata': metadata,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory SavingsContribution.fromFirestore(Map<String, dynamic> doc) {
    return SavingsContribution(
      id: doc['id'] as String,
      savingsTargetId: doc['savings_target_id'] as String,
      userId: doc['user_id'] as String,
      amount: (doc['amount'] as num).toDouble(),
      contributionDate: DateTime.fromMillisecondsSinceEpoch(doc['contribution_date'] as int),
      notes: doc['notes'] as String?,
      accountId: doc['account_id'] as String?,
      transactionId: doc['transaction_id'] as String?,
      metadata: doc['metadata'] as Map<String, dynamic>?,
      createdAt: doc['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(doc['created_at'] as int)
          : DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SavingsContribution && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// App Settings model for global application configuration
class AppSettings {
  final String? userId;
  final String theme;
  final String locale;
  final String timezone;
  final String currencyCode;
  final String currencySymbol;
  final String dateFormat;
  final int firstDayOfWeek;
  final String decimalSeparator;
  final String thousandSeparator;
  final bool enableNotifications;
  final bool enableBiometric;
  final bool enablePinLock;
  final bool darkModeAuto;
  final bool compactMode;
  final bool showCents;
  final String defaultAccountId;
  final String? defaultSavingsTargetId;
  final NotificationSettings notificationSettings;
  final SecuritySettings securitySettings;
  final DisplaySettings displaySettings;
  final SyncSettings syncSettings;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppSettings({
    this.userId,
    this.theme = 'light',
    this.locale = 'id_ID',
    this.timezone = 'Asia/Jakarta',
    this.currencyCode = 'IDR',
    this.currencySymbol = 'Rp',
    this.dateFormat = 'DD/MM/YYYY',
    this.firstDayOfWeek = 1,
    this.decimalSeparator = ',',
    this.thousandSeparator = '.',
    this.enableNotifications = true,
    this.enableBiometric = false,
    this.enablePinLock = false,
    this.darkModeAuto = false,
    this.compactMode = false,
    this.showCents = false,
    this.defaultAccountId = '',
    this.defaultSavingsTargetId,
    this.notificationSettings = const NotificationSettings(),
    this.securitySettings = const SecuritySettings(),
    this.displaySettings = const DisplaySettings(),
    this.syncSettings = const SyncSettings(),
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Format amount with currency symbol
  String formatAmount(double amount) {
    final formattedNumber = amount
        .toStringAsFixed(showCents ? 2 : 0)
        .replaceAll('.', decimalSeparator)
        .replaceAll(',', thousandSeparator);
    return '$currencySymbol$formattedNumber';
  }

  AppSettings copyWith({
    String? userId,
    String? theme,
    String? locale,
    String? timezone,
    String? currencyCode,
    String? currencySymbol,
    String? dateFormat,
    int? firstDayOfWeek,
    String? decimalSeparator,
    String? thousandSeparator,
    bool? enableNotifications,
    bool? enableBiometric,
    bool? enablePinLock,
    bool? darkModeAuto,
    bool? compactMode,
    bool? showCents,
    String? defaultAccountId,
    String? defaultSavingsTargetId,
    NotificationSettings? notificationSettings,
    SecuritySettings? securitySettings,
    DisplaySettings? displaySettings,
    SyncSettings? syncSettings,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearDefaultSavingsTargetId = false,
    bool clearMetadata = false,
  }) {
    return AppSettings(
      userId: userId ?? this.userId,
      theme: theme ?? this.theme,
      locale: locale ?? this.locale,
      timezone: timezone ?? this.timezone,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      dateFormat: dateFormat ?? this.dateFormat,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
      decimalSeparator: decimalSeparator ?? this.decimalSeparator,
      thousandSeparator: thousandSeparator ?? this.thousandSeparator,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableBiometric: enableBiometric ?? this.enableBiometric,
      enablePinLock: enablePinLock ?? this.enablePinLock,
      darkModeAuto: darkModeAuto ?? this.darkModeAuto,
      compactMode: compactMode ?? this.compactMode,
      showCents: showCents ?? this.showCents,
      defaultAccountId: defaultAccountId ?? this.defaultAccountId,
      defaultSavingsTargetId:
          clearDefaultSavingsTargetId ? null : (defaultSavingsTargetId ?? this.defaultSavingsTargetId),
      notificationSettings: notificationSettings ?? this.notificationSettings,
      securitySettings: securitySettings ?? this.securitySettings,
      displaySettings: displaySettings ?? this.displaySettings,
      syncSettings: syncSettings ?? this.syncSettings,
      metadata: clearMetadata ? null : (metadata ?? this.metadata),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'theme': theme,
      'locale': locale,
      'timezone': timezone,
      'currency_code': currencyCode,
      'currency_symbol': currencySymbol,
      'date_format': dateFormat,
      'first_day_of_week': firstDayOfWeek,
      'decimal_separator': decimalSeparator,
      'thousand_separator': thousandSeparator,
      'enable_notifications': enableNotifications,
      'enable_biometric': enableBiometric,
      'enable_pin_lock': enablePinLock,
      'dark_mode_auto': darkModeAuto,
      'compact_mode': compactMode,
      'show_cents': showCents,
      'default_account_id': defaultAccountId,
      'default_savings_target_id': defaultSavingsTargetId,
      'notification_settings': notificationSettings.toJson(),
      'security_settings': securitySettings.toJson(),
      'display_settings': displaySettings.toJson(),
      'sync_settings': syncSettings.toJson(),
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      userId: json['user_id'] as String?,
      theme: json['theme'] as String? ?? 'light',
      locale: json['locale'] as String? ?? 'id_ID',
      timezone: json['timezone'] as String? ?? 'Asia/Jakarta',
      currencyCode: json['currency_code'] as String? ?? 'IDR',
      currencySymbol: json['currency_symbol'] as String? ?? 'Rp',
      dateFormat: json['date_format'] as String? ?? 'DD/MM/YYYY',
      firstDayOfWeek: json['first_day_of_week'] as int? ?? 1,
      decimalSeparator: json['decimal_separator'] as String? ?? ',',
      thousandSeparator: json['thousand_separator'] as String? ?? '.',
      enableNotifications: json['enable_notifications'] as bool? ?? true,
      enableBiometric: json['enable_biometric'] as bool? ?? false,
      enablePinLock: json['enable_pin_lock'] as bool? ?? false,
      darkModeAuto: json['dark_mode_auto'] as bool? ?? false,
      compactMode: json['compact_mode'] as bool? ?? false,
      showCents: json['show_cents'] as bool? ?? false,
      defaultAccountId: json['default_account_id'] as String? ?? '',
      defaultSavingsTargetId: json['default_savings_target_id'] as String?,
      notificationSettings: json['notification_settings'] != null
          ? NotificationSettings.fromJson(json['notification_settings'] as Map<String, dynamic>)
          : const NotificationSettings(),
      securitySettings: json['security_settings'] != null
          ? SecuritySettings.fromJson(json['security_settings'] as Map<String, dynamic>)
          : const SecuritySettings(),
      displaySettings: json['display_settings'] != null
          ? DisplaySettings.fromJson(json['display_settings'] as Map<String, dynamic>)
          : const DisplaySettings(),
      syncSettings: json['sync_settings'] != null
          ? SyncSettings.fromJson(json['sync_settings'] as Map<String, dynamic>)
          : const SyncSettings(),
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'theme': theme,
      'locale': locale,
      'timezone': timezone,
      'currency_code': currencyCode,
      'currency_symbol': currencySymbol,
      'date_format': dateFormat,
      'first_day_of_week': firstDayOfWeek,
      'decimal_separator': decimalSeparator,
      'thousand_separator': thousandSeparator,
      'enable_notifications': enableNotifications,
      'enable_biometric': enableBiometric,
      'enable_pin_lock': enablePinLock,
      'dark_mode_auto': darkModeAuto,
      'compact_mode': compactMode,
      'show_cents': showCents,
      'default_account_id': defaultAccountId,
      'default_savings_target_id': defaultSavingsTargetId,
      'notification_settings': notificationSettings.toFirestore(),
      'security_settings': securitySettings.toFirestore(),
      'display_settings': displaySettings.toFirestore(),
      'sync_settings': syncSettings.toFirestore(),
      'metadata': metadata,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory AppSettings.fromFirestore(Map<String, dynamic> doc) {
    return AppSettings(
      userId: doc['user_id'] as String?,
      theme: doc['theme'] as String? ?? 'light',
      locale: doc['locale'] as String? ?? 'id_ID',
      timezone: doc['timezone'] as String? ?? 'Asia/Jakarta',
      currencyCode: doc['currency_code'] as String? ?? 'IDR',
      currencySymbol: doc['currency_symbol'] as String? ?? 'Rp',
      dateFormat: doc['date_format'] as String? ?? 'DD/MM/YYYY',
      firstDayOfWeek: doc['first_day_of_week'] as int? ?? 1,
      decimalSeparator: doc['decimal_separator'] as String? ?? ',',
      thousandSeparator: doc['thousand_separator'] as String? ?? '.',
      enableNotifications: doc['enable_notifications'] as bool? ?? true,
      enableBiometric: doc['enable_biometric'] as bool? ?? false,
      enablePinLock: doc['enable_pin_lock'] as bool? ?? false,
      darkModeAuto: doc['dark_mode_auto'] as bool? ?? false,
      compactMode: doc['compact_mode'] as bool? ?? false,
      showCents: doc['show_cents'] as bool? ?? false,
      defaultAccountId: doc['default_account_id'] as String? ?? '',
      defaultSavingsTargetId: doc['default_savings_target_id'] as String?,
      notificationSettings: doc['notification_settings'] != null
          ? NotificationSettings.fromFirestore(doc['notification_settings'] as Map<String, dynamic>)
          : const NotificationSettings(),
      securitySettings: doc['security_settings'] != null
          ? SecuritySettings.fromFirestore(doc['security_settings'] as Map<String, dynamic>)
          : const SecuritySettings(),
      displaySettings: doc['display_settings'] != null
          ? DisplaySettings.fromFirestore(doc['display_settings'] as Map<String, dynamic>)
          : const DisplaySettings(),
      syncSettings: doc['sync_settings'] != null
          ? SyncSettings.fromFirestore(doc['sync_settings'] as Map<String, dynamic>)
          : const SyncSettings(),
      metadata: doc['metadata'] as Map<String, dynamic>?,
      createdAt: doc['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(doc['created_at'] as int)
          : DateTime.now(),
      updatedAt: doc['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(doc['updated_at'] as int)
          : DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}

/// Notification settings sub-model
class NotificationSettings {
  final bool transactionAlerts;
  final bool budgetAlerts;
  final bool savingsReminders;
  final bool investmentAlerts;
  final bool weeklyReports;
  final bool monthlyReports;
  final bool lowBalanceAlerts;
  final double lowBalanceThreshold;
  final int reminderTimeHour;
  final int reminderTimeMinute;
  final bool soundEnabled;
  final bool vibrationEnabled;

  const NotificationSettings({
    this.transactionAlerts = true,
    this.budgetAlerts = true,
    this.savingsReminders = true,
    this.investmentAlerts = true,
    this.weeklyReports = false,
    this.monthlyReports = true,
    this.lowBalanceAlerts = true,
    this.lowBalanceThreshold = 500000,
    this.reminderTimeHour = 9,
    this.reminderTimeMinute = 0,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  NotificationSettings copyWith({
    bool? transactionAlerts,
    bool? budgetAlerts,
    bool? savingsReminders,
    bool? investmentAlerts,
    bool? weeklyReports,
    bool? monthlyReports,
    bool? lowBalanceAlerts,
    double? lowBalanceThreshold,
    int? reminderTimeHour,
    int? reminderTimeMinute,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return NotificationSettings(
      transactionAlerts: transactionAlerts ?? this.transactionAlerts,
      budgetAlerts: budgetAlerts ?? this.budgetAlerts,
      savingsReminders: savingsReminders ?? this.savingsReminders,
      investmentAlerts: investmentAlerts ?? this.investmentAlerts,
      weeklyReports: weeklyReports ?? this.weeklyReports,
      monthlyReports: monthlyReports ?? this.monthlyReports,
      lowBalanceAlerts: lowBalanceAlerts ?? this.lowBalanceAlerts,
      lowBalanceThreshold: lowBalanceThreshold ?? this.lowBalanceThreshold,
      reminderTimeHour: reminderTimeHour ?? this.reminderTimeHour,
      reminderTimeMinute: reminderTimeMinute ?? this.reminderTimeMinute,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_alerts': transactionAlerts,
      'budget_alerts': budgetAlerts,
      'savings_reminders': savingsReminders,
      'investment_alerts': investmentAlerts,
      'weekly_reports': weeklyReports,
      'monthly_reports': monthlyReports,
      'low_balance_alerts': lowBalanceAlerts,
      'low_balance_threshold': lowBalanceThreshold,
      'reminder_time_hour': reminderTimeHour,
      'reminder_time_minute': reminderTimeMinute,
      'sound_enabled': soundEnabled,
      'vibration_enabled': vibrationEnabled,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      transactionAlerts: json['transaction_alerts'] as bool? ?? true,
      budgetAlerts: json['budget_alerts'] as bool? ?? true,
      savingsReminders: json['savings_reminders'] as bool? ?? true,
      investmentAlerts: json['investment_alerts'] as bool? ?? true,
      weeklyReports: json['weekly_reports'] as bool? ?? false,
      monthlyReports: json['monthly_reports'] as bool? ?? true,
      lowBalanceAlerts: json['low_balance_alerts'] as bool? ?? true,
      lowBalanceThreshold: (json['low_balance_threshold'] as num?)?.toDouble() ?? 500000,
      reminderTimeHour: json['reminder_time_hour'] as int? ?? 9,
      reminderTimeMinute: json['reminder_time_minute'] as int? ?? 0,
      soundEnabled: json['sound_enabled'] as bool? ?? true,
      vibrationEnabled: json['vibration_enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() => toJson();

  factory NotificationSettings.fromFirestore(Map<String, dynamic> doc) {
    return NotificationSettings.fromJson(doc);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationSettings &&
        other.transactionAlerts == transactionAlerts &&
        other.budgetAlerts == budgetAlerts &&
        other.savingsReminders == savingsReminders &&
        other.investmentAlerts == investmentAlerts &&
        other.weeklyReports == weeklyReports &&
        other.monthlyReports == monthlyReports &&
        other.lowBalanceAlerts == lowBalanceAlerts &&
        other.lowBalanceThreshold == lowBalanceThreshold &&
        other.reminderTimeHour == reminderTimeHour &&
        other.reminderTimeMinute == reminderTimeMinute &&
        other.soundEnabled == soundEnabled &&
        other.vibrationEnabled == vibrationEnabled;
  }

  @override
  int get hashCode => Object.hash(
        transactionAlerts,
        budgetAlerts,
        savingsReminders,
        investmentAlerts,
        weeklyReports,
        monthlyReports,
        lowBalanceAlerts,
        lowBalanceThreshold,
        reminderTimeHour,
        reminderTimeMinute,
        soundEnabled,
        vibrationEnabled,
      );
}

/// Security settings sub-model
class SecuritySettings {
  final bool requireAuthOnLaunch;
  final bool autoLockEnabled;
  final int autoLockTimeoutMinutes;
  final bool obscureAmounts;
  final bool allowScreenshots;
  final int maxLoginAttempts;
  final int lockoutDurationMinutes;

  const SecuritySettings({
    this.requireAuthOnLaunch = false,
    this.autoLockEnabled = true,
    this.autoLockTimeoutMinutes = 5,
    this.obscureAmounts = false,
    this.allowScreenshots = true,
    this.maxLoginAttempts = 5,
    this.lockoutDurationMinutes = 30,
  });

  SecuritySettings copyWith({
    bool? requireAuthOnLaunch,
    bool? autoLockEnabled,
    int? autoLockTimeoutMinutes,
    bool? obscureAmounts,
    bool? allowScreenshots,
    int? maxLoginAttempts,
    int? lockoutDurationMinutes,
  }) {
    return SecuritySettings(
      requireAuthOnLaunch: requireAuthOnLaunch ?? this.requireAuthOnLaunch,
      autoLockEnabled: autoLockEnabled ?? this.autoLockEnabled,
      autoLockTimeoutMinutes: autoLockTimeoutMinutes ?? this.autoLockTimeoutMinutes,
      obscureAmounts: obscureAmounts ?? this.obscureAmounts,
      allowScreenshots: allowScreenshots ?? this.allowScreenshots,
      maxLoginAttempts: maxLoginAttempts ?? this.maxLoginAttempts,
      lockoutDurationMinutes: lockoutDurationMinutes ?? this.lockoutDurationMinutes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'require_auth_on_launch': requireAuthOnLaunch,
      'auto_lock_enabled': autoLockEnabled,
      'auto_lock_timeout_minutes': autoLockTimeoutMinutes,
      'obscure_amounts': obscureAmounts,
      'allow_screenshots': allowScreenshots,
      'max_login_attempts': maxLoginAttempts,
      'lockout_duration_minutes': lockoutDurationMinutes,
    };
  }

  factory SecuritySettings.fromJson(Map<String, dynamic> json) {
    return SecuritySettings(
      requireAuthOnLaunch: json['require_auth_on_launch'] as bool? ?? false,
      autoLockEnabled: json['auto_lock_enabled'] as bool? ?? true,
      autoLockTimeoutMinutes: json['auto_lock_timeout_minutes'] as int? ?? 5,
      obscureAmounts: json['obscure_amounts'] as bool? ?? false,
      allowScreenshots: json['allow_screenshots'] as bool? ?? true,
      maxLoginAttempts: json['max_login_attempts'] as int? ?? 5,
      lockoutDurationMinutes: json['lockout_duration_minutes'] as int? ?? 30,
    );
  }

  Map<String, dynamic> toFirestore() => toJson();

  factory SecuritySettings.fromFirestore(Map<String, dynamic> doc) {
    return SecuritySettings.fromJson(doc);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SecuritySettings &&
        other.requireAuthOnLaunch == requireAuthOnLaunch &&
        other.autoLockEnabled == autoLockEnabled &&
        other.autoLockTimeoutMinutes == autoLockTimeoutMinutes &&
        other.obscureAmounts == obscureAmounts &&
        other.allowScreenshots == allowScreenshots &&
        other.maxLoginAttempts == maxLoginAttempts &&
        other.lockoutDurationMinutes == lockoutDurationMinutes;
  }

  @override
  int get hashCode => Object.hash(
        requireAuthOnLaunch,
        autoLockEnabled,
        autoLockTimeoutMinutes,
        obscureAmounts,
        allowScreenshots,
        maxLoginAttempts,
        lockoutDurationMinutes,
      );
}

/// Display settings sub-model
class DisplaySettings {
  final String dashboardLayout;
  final bool showAccountBalances;
  final bool showInvestmentSummary;
  final bool showSavingsProgress;
  final bool showRecentTransactions;
  final int recentTransactionsCount;
  final String chartType;
  final bool showTrendArrows;
  final bool animateCharts;

  const DisplaySettings({
    this.dashboardLayout = 'standard',
    this.showAccountBalances = true,
    this.showInvestmentSummary = true,
    this.showSavingsProgress = true,
    this.showRecentTransactions = true,
    this.recentTransactionsCount = 5,
    this.chartType = 'line',
    this.showTrendArrows = true,
    this.animateCharts = true,
  });

  DisplaySettings copyWith({
    String? dashboardLayout,
    bool? showAccountBalances,
    bool? showInvestmentSummary,
    bool? showSavingsProgress,
    bool? showRecentTransactions,
    int? recentTransactionsCount,
    String? chartType,
    bool? showTrendArrows,
    bool? animateCharts,
  }) {
    return DisplaySettings(
      dashboardLayout: dashboardLayout ?? this.dashboardLayout,
      showAccountBalances: showAccountBalances ?? this.showAccountBalances,
      showInvestmentSummary: showInvestmentSummary ?? this.showInvestmentSummary,
      showSavingsProgress: showSavingsProgress ?? this.showSavingsProgress,
      showRecentTransactions: showRecentTransactions ?? this.showRecentTransactions,
      recentTransactionsCount: recentTransactionsCount ?? this.recentTransactionsCount,
      chartType: chartType ?? this.chartType,
      showTrendArrows: showTrendArrows ?? this.showTrendArrows,
      animateCharts: animateCharts ?? this.animateCharts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dashboard_layout': dashboardLayout,
      'show_account_balances': showAccountBalances,
      'show_investment_summary': showInvestmentSummary,
      'show_savings_progress': showSavingsProgress,
      'show_recent_transactions': showRecentTransactions,
      'recent_transactions_count': recentTransactionsCount,
      'chart_type': chartType,
      'show_trend_arrows': showTrendArrows,
      'animate_charts': animateCharts,
    };
  }

  factory DisplaySettings.fromJson(Map<String, dynamic> json) {
    return DisplaySettings(
      dashboardLayout: json['dashboard_layout'] as String? ?? 'standard',
      showAccountBalances: json['show_account_balances'] as bool? ?? true,
      showInvestmentSummary: json['show_investment_summary'] as bool? ?? true,
      showSavingsProgress: json['show_savings_progress'] as bool? ?? true,
      showRecentTransactions: json['show_recent_transactions'] as bool? ?? true,
      recentTransactionsCount: json['recent_transactions_count'] as int? ?? 5,
      chartType: json['chart_type'] as String? ?? 'line',
      showTrendArrows: json['show_trend_arrows'] as bool? ?? true,
      animateCharts: json['animate_charts'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() => toJson();

  factory DisplaySettings.fromFirestore(Map<String, dynamic> doc) {
    return DisplaySettings.fromJson(doc);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DisplaySettings &&
        other.dashboardLayout == dashboardLayout &&
        other.showAccountBalances == showAccountBalances &&
        other.showInvestmentSummary == showInvestmentSummary &&
        other.showSavingsProgress == showSavingsProgress &&
        other.showRecentTransactions == showRecentTransactions &&
        other.recentTransactionsCount == recentTransactionsCount &&
        other.chartType == chartType &&
        other.showTrendArrows == showTrendArrows &&
        other.animateCharts == animateCharts;
  }

  @override
  int get hashCode => Object.hash(
        dashboardLayout,
        showAccountBalances,
        showInvestmentSummary,
        showSavingsProgress,
        showRecentTransactions,
        recentTransactionsCount,
        chartType,
        showTrendArrows,
        animateCharts,
      );
}

/// Sync settings sub-model
class SyncSettings {
  final bool autoSyncEnabled;
  final int syncIntervalMinutes;
  final bool syncOnWifiOnly;
  final bool syncContacts;
  final DateTime? lastSyncAt;

  const SyncSettings({
    this.autoSyncEnabled = true,
    this.syncIntervalMinutes = 15,
    this.syncOnWifiOnly = false,
    this.syncContacts = false,
    this.lastSyncAt,
  });

  SyncSettings copyWith({
    bool? autoSyncEnabled,
    int? syncIntervalMinutes,
    bool? syncOnWifiOnly,
    bool? syncContacts,
    DateTime? lastSyncAt,
    bool clearLastSyncAt = false,
  }) {
    return SyncSettings(
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      syncIntervalMinutes: syncIntervalMinutes ?? this.syncIntervalMinutes,
      syncOnWifiOnly: syncOnWifiOnly ?? this.syncOnWifiOnly,
      syncContacts: syncContacts ?? this.syncContacts,
      lastSyncAt: clearLastSyncAt ? null : (lastSyncAt ?? this.lastSyncAt),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'auto_sync_enabled': autoSyncEnabled,
      'sync_interval_minutes': syncIntervalMinutes,
      'sync_on_wifi_only': syncOnWifiOnly,
      'sync_contacts': syncContacts,
      'last_sync_at': lastSyncAt?.toIso8601String(),
    };
  }

  factory SyncSettings.fromJson(Map<String, dynamic> json) {
    return SyncSettings(
      autoSyncEnabled: json['auto_sync_enabled'] as bool? ?? true,
      syncIntervalMinutes: json['sync_interval_minutes'] as int? ?? 15,
      syncOnWifiOnly: json['sync_on_wifi_only'] as bool? ?? false,
      syncContacts: json['sync_contacts'] as bool? ?? false,
      lastSyncAt: json['last_sync_at'] != null
          ? DateTime.parse(json['last_sync_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'auto_sync_enabled': autoSyncEnabled,
      'sync_interval_minutes': syncIntervalMinutes,
      'sync_on_wifi_only': syncOnWifiOnly,
      'sync_contacts': syncContacts,
      'last_sync_at': lastSyncAt?.millisecondsSinceEpoch,
    };
  }

  factory SyncSettings.fromFirestore(Map<String, dynamic> doc) {
    return SyncSettings(
      autoSyncEnabled: doc['auto_sync_enabled'] as bool? ?? true,
      syncIntervalMinutes: doc['sync_interval_minutes'] as int? ?? 15,
      syncOnWifiOnly: doc['sync_on_wifi_only'] as bool? ?? false,
      syncContacts: doc['sync_contacts'] as bool? ?? false,
      lastSyncAt: doc['last_sync_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(doc['last_sync_at'] as int)
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SyncSettings &&
        other.autoSyncEnabled == autoSyncEnabled &&
        other.syncIntervalMinutes == syncIntervalMinutes &&
        other.syncOnWifiOnly == syncOnWifiOnly &&
        other.syncContacts == syncContacts &&
        other.lastSyncAt == lastSyncAt;
  }

  @override
  int get hashCode => Object.hash(
        autoSyncEnabled,
        syncIntervalMinutes,
        syncOnWifiOnly,
        syncContacts,
        lastSyncAt,
      );
}
