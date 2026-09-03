enum AccountType {
  cash,
  bank,
  eWallet,
  savings,
  investment,
  creditCard,
  loan,
  other;

  String get ewallet => 'ewallet';

  String get value {
    switch (this) {
      case AccountType.cash:
        return 'cash';
      case AccountType.bank:
        return 'bank';
      case AccountType.eWallet:
        return 'ewallet';
      case AccountType.savings:
        return 'savings';
      case AccountType.investment:
        return 'investment';
      case AccountType.creditCard:
        return 'credit_card';
      case AccountType.loan:
        return 'loan';
      case AccountType.other:
        return 'other';
    }
  }

  static AccountType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'cash':
        return AccountType.cash;
      case 'bank':
        return AccountType.bank;
      case 'ewallet':
      case 'e-wallet':
        return AccountType.eWallet;
      case 'savings':
        return AccountType.savings;
      case 'investment':
        return AccountType.investment;
      case 'credit_card':
        return AccountType.creditCard;
      case 'loan':
        return AccountType.loan;
      default:
        return AccountType.other;
    }
  }
}

// Alias untuk kompatibilitas jika dipanggil dengan ewallet
extension AccountTypeAlias on AccountType {
  static AccountType get ewallet => AccountType.eWallet;
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
      type: json['type'] != null 
          ? AccountType.fromString(json['type'].toString()) 
          : AccountType.other,
      balance: (json['balance'] ?? 0).toDouble(),
      accountNumber: json['accountNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.value,
      'balance': balance,
      'accountNumber': accountNumber,
    };
  }
}
