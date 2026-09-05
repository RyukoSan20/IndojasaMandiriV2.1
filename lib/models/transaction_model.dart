class Transaction {
  final String id;
  final String title;
  final double amount;
  final bool isIncome;
  final String category;
  final DateTime date;
  final String? accountId;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.category,
    required this.date,
    this.accountId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': isIncome ? 'income' : 'expense',
      'category': category,
      'date': date.toIso8601String(),
      'account_id': accountId,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      isIncome: map['type'] == 'income' || map['isIncome'] == true,
      category: map['category'] as String? ?? 'Lainnya',
      date: map['date'] != null ? DateTime.tryParse(map['date'] as String) ?? DateTime.now() : DateTime.now(),
      accountId: map['account_id'] as String?,
    );
  }
}
