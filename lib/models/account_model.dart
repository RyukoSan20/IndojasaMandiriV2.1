class AccountModel {
  final String id;
  final String? userId;
  final String name;
  final String type;
  final double balance;
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
      type: json['type'] ?? 'general',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
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
      'type': type,
      'balance': balance,
      'isActive': isActive,
      'includeInTotal': includeInTotal,
      'accountNumber': accountNumber,
      'color': color,
      'icon': icon,
    };
  }
}
