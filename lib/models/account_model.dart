enum AccountType {
  bank,
  ewallet,
  cash,
  savings,
  investment,
  other,
}

class AccountModel {
  final String id;
  final String name;
  final AccountType type;
  final double balance;
  final String? accountNumber;

  AccountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    this.accountNumber,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: AccountType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => AccountType.other,
      ),
      balance: (json['balance'] ?? 0).toDouble(),
      accountNumber: json['accountNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'balance': balance,
      'accountNumber': accountNumber,
    };
  }
}
