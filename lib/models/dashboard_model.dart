enum InsightPriority { low, medium, high }

class FinancialInsight {
  final String id;
  final String title;
  final String message;
  final InsightPriority priority;

  FinancialInsight({
    required this.id,
    required this.title,
    required this.message,
    required this.priority,
  });
}

class CashflowData {
  final String month;
  final double income;
  final double expense;

  CashflowData({
    required this.month,
    required this.income,
    required this.expense,
  });
}

class NetWorthData {
  final String date;
  final double amount;

  NetWorthData({
    required this.date,
    required this.amount,
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
