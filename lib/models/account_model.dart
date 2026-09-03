class AccountModel {
  final String id;
  final String name;
  final String type;
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
      type: json['type'] ?? '',
      balance: (json['balance'] ?? 0).toDouble(),
      accountNumber: json['accountNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'balance': balance,
      'accountNumber': accountNumber,
    };
  }
}
