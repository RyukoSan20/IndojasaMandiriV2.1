import 'user_model.dart';

class TransactionModel {
  final String id;
  final String? userId;
  final String accountId;
  final double amount;
  final dynamic type;
  final String categoryId;
  final String? description;
  final DateTime date;
  final List<String>? tags;

  TransactionModel({
    required this.id,
    this.userId,
    required this.accountId,
    required this.amount,
    required this.type,
    required this.categoryId,
    this.description,
    required this.date,
    this.tags,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      userId: json['userId'],
      accountId: json['accountId'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] ?? 'expense',
      categoryId: json['categoryId'] ?? '',
      description: json['description'],
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'accountId': accountId,
      'amount': amount,
      'type': type,
      'categoryId': categoryId,
      'description': description,
      'date': date.toIso8601String(),
      'tags': tags,
    };
  }
}
