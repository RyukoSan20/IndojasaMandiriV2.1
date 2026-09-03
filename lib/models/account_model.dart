enum AccountType { cash, bank, ewallet, savings, investment, creditCard, other }

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
  final String? color;
  final String? icon;

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
    this.color,
    this.icon,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] ?? '',
      userId: json['userId'],
      name: json['name'] ?? '',
      type: json['type'] ?? AccountType.bank,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'IDR',
      isActive: json['isActive'] ?? true,
      includeInTotal: json['includeInTotal'] ?? true,
      accountNumber: json['accountNumber'],
      color: json['color'],
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'type': type is AccountType ? (type as AccountType).name : type,
      'balance': balance,
      'currency': currency,
      'isActive': isActive,
      'includeInTotal': includeInTotal,
      'accountNumber': accountNumber,
      'color': color,
      'icon': icon,
    };
  }
}
