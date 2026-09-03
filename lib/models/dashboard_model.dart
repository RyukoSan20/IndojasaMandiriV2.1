import 'package:flutter/foundation.dart';

enum InsightPriority { low, medium, high }
enum InsightType { spending, savings, investment, goal, general, info }

class FinancialInsight {
  final String id;
  final String title;
  final String message;
  final String? description;
  final dynamic type;
  final InsightPriority priority;
  final DateTime? createdAt;
  final Map<String, dynamic>? data;

  FinancialInsight({
    required this.id,
    required this.title,
    String? message,
    String? description,
    required this.type,
    this.priority = InsightPriority.medium,
    this.createdAt,
    this.data,
  })  : message = message ?? description ?? '',
        description = description ?? message;
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
  final String? month;
  final double income;
  final double expense;
  final double netFlow;

  CashflowData({
    required this.period,
    this.month,
    required this.income,
    required this.expense,
    double? netFlow,
  }) : netFlow = netFlow ?? (income - expense);
}

class DashboardModel {
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpense;
  final double monthlyExpenses;
  final double netFlow;
  final List<FinancialInsight> insights;
  final List<CashflowData> cashflow;

  DashboardModel({
    required this.totalBalance,
    required this.monthlyIncome,
    double? monthlyExpense,
    double? monthlyExpenses,
    double? netFlow,
    required this.insights,
    required this.cashflow,
  })  : monthlyExpense = monthlyExpense ?? monthlyExpenses ?? 0.0,
        monthlyExpenses = monthlyExpenses ?? monthlyExpense ?? 0.0,
        netFlow = netFlow ?? 0.0;
}
