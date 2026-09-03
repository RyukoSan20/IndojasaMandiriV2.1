enum AccountType { 
  cash, bank, ewallet, savings, investment, creditCard, other;

  String get value => name;

  static AccountType fromString(String val) {
    return AccountType.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => AccountType.bank,
    );
  }
}

class AccountModel {
  final String id;
  final String? userId;
  final String name;
  final dynamic type;
  final double balance;
  final String currency;
  final bool isActive;
  final bool includeInTotal;
  final String? accountNumber;
  final String? cardLastDigits;
  final String? color;
  final String? icon;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AccountModel({
    required this.id,
    this.userId,
    required this.name,
    required this.type,
    required this.balance,
    this.currency = 'IDR',
    this.isActive = true,
    this.includeInTotal = true,
    this.accountNumber,
    this.cardLastDigits,
    this.color,
    this.icon,
    this.createdAt,
    this.updatedAt,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] ?? '',
      userId: json['userId'],
      name: json['name'] ?? '',
      type: json['type'] != null ? AccountType.fromString(json['type'].toString()) : AccountType.bank,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'IDR',
      isActive: json['isActive'] ?? true,
      includeInTotal: json['includeInTotal'] ?? true,
      accountNumber: json['accountNumber'],
      cardLastDigits: json['cardLastDigits'],
      color: json['color'],
      icon: json['icon'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'type': type is AccountType ? (type as AccountType).value : type,
      'balance': balance,
      'currency': currency,
      'isActive': isActive,
      'includeInTotal': includeInTotal,
      'accountNumber': accountNumber,
      'cardLastDigits': cardLastDigits,
      'color': color,
      'icon': icon,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
