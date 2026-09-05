import 'package:flutter/material.dart';

enum AccountCategory { bank, ewallet, virtualAccount, cash, valas, investment, savings, other }
enum AccountType { bank, ewallet, virtualAccount, cash, valas, investment, savings, other }

class AccountModel {
  final String id;
  final String? userId;
  final String name;
  final AccountType type;
  final AccountCategory category;
  double balance;
  final String currency;
  final String currencyCode;
  final String? icon;
  final dynamic color;
  final String? cardLastDigits;
  final String? bankName;
  final bool isActive;
  final bool includeInTotal;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AccountModel({
    required this.id,
    this.userId,
    required this.name,
    this.type = AccountType.bank,
    this.category = AccountCategory.bank,
    required this.balance,
    this.currency = 'IDR',
    String? currencyCode,
    this.icon,
    this.color,
    this.cardLastDigits,
    this.bankName,
    this.isActive = true,
    this.includeInTotal = true,
    this.createdAt,
    this.updatedAt,
  }) : currencyCode = currencyCode ?? currency;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type.name,
      'category': category.name,
      'balance': balance,
      'currency': currency,
      'currency_code': currencyCode,
      'icon': icon,
      'color': color is Color ? color.value : color,
      'card_last_digits': cardLastDigits,
      'bank_name': bankName,
      'is_active': isActive ? 1 : 0,
      'include_in_total': includeInTotal ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? json['user_id'] as String?,
      name: json['name'] as String? ?? '',
      type: AccountType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AccountType.bank,
      ),
      category: AccountCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => AccountCategory.bank,
      ),
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? json['currencyCode'] as String? ?? 'IDR',
      currencyCode: json['currencyCode'] as String? ?? json['currency_code'] as String? ?? 'IDR',
      icon: json['icon'] as String?,
      color: json['color'],
      cardLastDigits: json['cardLastDigits'] as String? ?? json['card_last_digits'] as String?,
      bankName: json['bankName'] as String? ?? json['bank_name'] as String?,
      isActive: json['isActive'] == 1 || json['isActive'] == true,
      includeInTotal: json['includeInTotal'] == 1 || json['includeInTotal'] == true,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }
}

typedef Account = AccountModel;
