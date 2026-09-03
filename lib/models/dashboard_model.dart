import 'package:flutter/foundation.dart';

enum InsightPriority { low, medium, high }

class FinancialInsight {
  final String id;
  final String title;
  final String message;
  final String? description;
  final String type;
  final InsightPriority priority;
  final DateTime? createdAt;
  final Map<String, dynamic>? data;

  FinancialInsight({
    required this.id,
    required this.title,
    required this.message,
    this.description,
    required this.type,
    this.priority = InsightPriority.medium,
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
      priority: InsightPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => InsightPriority.medium,
      ),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'description': description,
      'type': type,
      'priority': priority.name,
      'createdAt': createdAt?.toIso8601String(),
      'data': data,
    };
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

  factory NetWorthData.fromJson(Map<String, dynamic> json) {
    return NetWorthData(
      netWorth: (json['netWorth'] as num?)?.toDouble() ?? 0.0,
      totalAssets: (json['totalAssets'] as num?)?.toDouble() ?? 0.0,
      totalLiabilities: (json['totalLiabilities'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'netWorth': netWorth,
      'totalAssets': totalAssets,
      'totalLiabilities': totalLiabilities,
      'date': date.toIso8601String(),
    };
  }
}

class CashflowData {
  final String period;
  final String? month;
  final double income;
  final double expense;

  CashflowData({
    required this.period,
    this.month,
    required this.income,
    required this.expense,
  });

  factory CashflowData.fromJson(Map<String, dynamic> json) {
    return CashflowData(
      period: json['period'] ?? '',
      month: json['month'],
      income: (json['income'] as num?)?.toDouble() ?? 0.0,
      expense: (json['expense'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'month': month,
      'income': income,
      'expense': expense,
    };
  }
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
