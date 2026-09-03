import 'package:flutter/foundation.dart';

class FinancialInsight {
  final String id;
  final String title;
  final String message;
  final String? description;
  final String type;
  final DateTime? createdAt;
  final Map<String, dynamic>? data;

  FinancialInsight({
    required this.id,
    required this.title,
    required this.message,
    this.description,
    required this.type,
    this.createdAt,
    this.data,
  });

  factory FinancialInsight.fromJson(Map<String, dynamic> json) {
    return FinancialInsight(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? json['description'] ?? '',
      description: json['description'],
      type: json['type'] ?? 'info',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}

class NetWorthData {
  final double netWorth;
  final double totalAssets;
  final double totalLiabilities;
  final DateTime date;

  NetWorthData({
    required this.netWorth,
    required this.totalAssets,
    required this.totalLiabilities,
    required this.date,
  });
}

class CashflowData {
  final String period;
  final double income;
  final double expense;

  CashflowData({
    required this.period,
    required this.income,
    required this.expense,
  });
}

class DashboardModel {
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpense;
  final List<FinancialInsight> insights;
  final List<CashflowData> cashflow;

  DashboardModel({
    required this.totalBalance,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.insights,
    required this.cashflow,
  });
}
