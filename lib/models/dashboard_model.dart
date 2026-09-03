enum InsightPriority { low, medium, high }
enum InsightType { general, savings, investment, goal }

class FinancialInsight {
  final String id;
  final String title;
  final String message;
  final InsightPriority priority;
  final InsightType? type;

  FinancialInsight({
    required this.id,
    required this.title,
    required this.message,
    required this.priority,
    this.type,
  });
}

class CashflowData {
  final String month;
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

  NetWorthData({
    required this.date,
    required this.amount,
    this.totalAssets,
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
