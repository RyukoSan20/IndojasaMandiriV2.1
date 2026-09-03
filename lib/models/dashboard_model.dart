enum InsightPriority { low, medium, high }
enum InsightType { general, savings, investment, goal }

class FinancialInsight {
  final String id;
  final String title;
  final String? message;
  final String? description;
  final InsightPriority priority;
  final InsightType? type;

  FinancialInsight({
    required this.id,
    required this.title,
    this.message,
    this.description,
    required this.priority,
    this.type,
  });
}

class CashflowData {
  final dynamic month;
  final double income;
  final double expense;
  final double? netFlow;

  CashflowData({
    required this.month,
    required this.income,
    required this.expense,
    this.netFlow,
  });
}

class NetWorthData {
  final String date;
  final double amount;
  final double? totalAssets;
  final double? totalLiabilities;

  NetWorthData({
    required this.date,
    required this.amount,
    this.totalAssets,
    this.totalLiabilities,
  });
}

class DashboardModel {
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpense;

  DashboardModel({
    required this.totalBalance,
    required this.monthlyIncome,
    required this.monthlyExpense,
  });
}
