class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? avatarUrl;
  final DateTime? dateOfBirth;
  final String? currency;
  final String? timezone;
  final String? country;
  final String? language;
  final bool emailVerified;
  final bool phoneVerified;
  final bool isActive;
  final bool isPremium;
  final DateTime? premiumExpiresAt;
  final Map<String, dynamic>? preferences;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;

  const UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.avatarUrl,
    this.dateOfBirth,
    this.currency,
    this.timezone,
    this.country,
    this.language,
    this.emailVerified = false,
    this.phoneVerified = false,
    this.isActive = true,
    this.isPremium = false,
    this.premiumExpiresAt,
    this.preferences,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
  });

  String get fullName {
    if (displayName != null && displayName!.isNotEmpty) {
      return displayName!;
    }
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    if (firstName != null) {
      return firstName!;
    }
    if (lastName != null) {
      return lastName!;
    }
    return email.split('@').first;
  }

  String get initials {
    final name = fullName;
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  bool get isPremiumActive {
    if (!isPremium) return false;
    if (premiumExpiresAt == null) return true;
    return premiumExpiresAt!.isAfter(DateTime.now());
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? avatarUrl,
    DateTime? dateOfBirth,
    String? currency,
    String? timezone,
    String? country,
    String? language,
    bool? emailVerified,
    bool? phoneVerified,
    bool? isActive,
    bool? isPremium,
    DateTime? premiumExpiresAt,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      currency: currency ?? this.currency,
      timezone: timezone ?? this.timezone,
      country: country ?? this.country,
      language: language ?? this.language,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      isActive: isActive ?? this.isActive,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'currency': currency,
      'timezone': timezone,
      'country': country,
      'language': language,
      'emailVerified': emailVerified,
      'phoneVerified': phoneVerified,
      'isActive': isActive,
      'isPremium': isPremium,
      'premiumExpiresAt': premiumExpiresAt?.toIso8601String(),
      'preferences': preferences,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      currency: json['currency'] as String?,
      timezone: json['timezone'] as String?,
      country: json['country'] as String?,
      language: json['language'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
      phoneVerified: json['phoneVerified'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      isPremium: json['isPremium'] as bool? ?? false,
      premiumExpiresAt: json['premiumExpiresAt'] != null
          ? DateTime.parse(json['premiumExpiresAt'] as String)
          : null,
      preferences: json['preferences'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
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
    return 'UserModel(id: $id, email: $email, displayName: $displayName)';
  }
}
