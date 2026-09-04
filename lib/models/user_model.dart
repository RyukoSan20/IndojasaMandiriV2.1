class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? fullName;
  final String? avatarUrl;
  final String? photoUrl;
  final String? phone;
  final bool emailVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    String? fullName,
    String? avatarUrl,
    this.photoUrl,
    this.phone,
    this.emailVerified = false,
    this.createdAt,
    this.updatedAt,
  })  : fullName = fullName ?? displayName,
        avatarUrl = avatarUrl ?? photoUrl;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? json['fullName'] ?? '',
      fullName: json['fullName'],
      avatarUrl: json['avatarUrl'] ?? json['photoUrl'],
      photoUrl: json['photoUrl'],
      phone: json['phone'],
      emailVerified: json['emailVerified'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'fullName': fullName,
      'avatarUrl': avatarUrl,
      'photoUrl': photoUrl,
      'phone': phone,
      'emailVerified': emailVerified,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class SavingsContribution {
  final String id;
  final String? accountId;
  final double amount;
  final DateTime date;
  final DateTime contributionDate;
  final DateTime createdAt;
  final String? note;

  const SavingsContribution({
    required this.id,
    this.accountId,
    required this.amount,
    required this.date,
    DateTime? contributionDate,
    DateTime? createdAt,
    this.note,
  })  : contributionDate = contributionDate ?? date,
        createdAt = createdAt ?? date;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'amount': amount,
      'date': date.toIso8601String(),
      'contribution_date': contributionDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'note': note,
    };
  }

  Map<String, dynamic> toFirestore() => toJson();

  factory SavingsContribution.fromJson(Map<String, dynamic> json) {
    final parsedDate = json['date'] != null
        ? DateTime.parse(json['date'] as String)
        : DateTime.now();
    return SavingsContribution(
      id: json['id'] as String? ?? '',
      accountId: json['accountId'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: parsedDate,
      contributionDate: json['contribution_date'] != null
          ? DateTime.parse(json['contribution_date'] as String)
          : parsedDate,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : parsedDate,
      note: json['note'] as String?,
    );
  }

  factory SavingsContribution.fromFirestore(Map<String, dynamic> json) =>
      SavingsContribution.fromJson(json);
}
