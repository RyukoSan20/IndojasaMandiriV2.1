import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

// ============================================================================
// Enums and Types
// ============================================================================

enum LoadingState { initial, loading, loaded, error }

enum TransactionType { income, expense, transfer }

enum AccountType { cash, bank, ewallet, savings, investment }

enum GoalStatus { active, completed, cancelled }

enum SyncStatus { idle, syncing, error, offline }

// ============================================================================
// User Model
// ============================================================================

class User {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final String currency;
  final String timezone;
  final String language;
  final bool pinEnabled;
  final bool biometricEnabled;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.currency = 'IDR',
    this.timezone = 'Asia/Jakarta',
    this.language = 'id',
    this.pinEnabled = false,
    this.biometricEnabled = false,
    this.emailVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    String? currency,
    String? timezone,
    String? language,
    bool? pinEnabled,
    bool? biometricEnabled,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      currency: currency ?? this.currency,
      timezone: timezone ?? this.timezone,
      language: language ?? this.language,
      pinEnabled: pinEnabled ?? this.pinEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatarUrl': avatarUrl,
      'currency': currency,
      'timezone': timezone,
      'language': language,
      'pinEnabled': pinEnabled,
      'biometricEnabled': biometricEnabled,
      'emailVerified': emailVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      currency: json['currency'] as String? ?? 'IDR',
      timezone: json['timezone'] as String? ?? 'Asia/Jakarta',
      language: json['language'] as String? ?? 'id',
      pinEnabled: json['pinEnabled'] as bool? ?? false,
      biometricEnabled: json['biometricEnabled'] as bool? ?? false,
      emailVerified: json['emailVerified'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

// ============================================================================
// Account Model
// ============================================================================

class Account {
  final String id;
  final String userId;
  final String name;
  final AccountType type;
  final double balance;
  final String currency;
  final String? icon;
  final String? color;
  final bool isActive;
  final String? cardLastDigits;
  final bool includeInTotal;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Account({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    this.balance = 0.0,
    this.currency = 'IDR',
    this.icon,
    this.color,
    this.isActive = true,
    this.cardLastDigits,
    this.includeInTotal = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Account copyWith({
    String? id,
    String? userId,
    String? name,
    AccountType? type,
    double? balance,
    String? currency,
    String? icon,
    String? color,
    bool? isActive,
    String? cardLastDigits,
    bool? includeInTotal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Account(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      cardLastDigits: cardLastDigits ?? this.cardLastDigits,
      includeInTotal: includeInTotal ?? this.includeInTotal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'type': type.name,
      'balance': balance,
      'currency': currency,
      'icon': icon,
      'color': color,
      'isActive': isActive,
      'cardLastDigits': cardLastDigits,
      'includeInTotal': includeInTotal,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      type: AccountType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AccountType.cash,
      ),
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'IDR',
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      cardLastDigits: json['cardLastDigits'] as String?,
      includeInTotal: json['includeInTotal'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  String get typeDisplayName {
    switch (type) {
      case AccountType.cash:
        return 'Tunai';
      case AccountType.bank:
        return 'Bank';
      case AccountType.ewallet:
        return 'E-Wallet';
      case AccountType.savings:
        return 'Tabungan';
      case AccountType.investment:
        return 'Investasi';
    }
  }

  String get typeIcon {
    switch (type) {
      case AccountType.cash:
        return 'wallet';
      case AccountType.bank:
        return 'account_balance';
      case AccountType.ewallet:
        return 'smartphone';
      case AccountType.savings:
        return 'savings';
      case AccountType.investment:
        return 'trending_up';
    }
  }
}

// ============================================================================
// Category Model
// ============================================================================

class Category {
  final String id;
  final String? userId;
  final String name;
  final String type; // income, expense
  final String icon;
  final String color;
  final String? parentId;
  final bool isSystem;
  final DateTime createdAt;

  const Category({
    required this.id,
    this.userId,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    this.parentId,
    this.isSystem = false,
    required this.createdAt,
  });

  Category copyWith({
    String? id,
    String? userId,
    String? name,
    String? type,
    String? icon,
    String? color,
    String? parentId,
    bool? isSystem,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      parentId: parentId ?? this.parentId,
      isSystem: isSystem ?? this.isSystem,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
      'parentId': parentId,
      'isSystem': isSystem,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      name: json['name'] as String,
      type: json['type'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      parentId: json['parentId'] as String?,
      isSystem: json['isSystem'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

// ============================================================================
// Transaction Model
// ============================================================================

class Transaction {
  final String id;
  final String userId;
  final String accountId;
  final String type; // income, expense, transfer
  final double amount;
  final String categoryId;
  final String? description;
  final DateTime date;
  final String? receiptUrl;
  final List<String>? tags;
  final bool isRecurring;
  final String? recurringId;
  final String? notes;
  final String? location;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Transaction({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.type,
    required this.amount,
    required this.categoryId,
    this.description,
    required this.date,
    this.receiptUrl,
    this.tags,
    this.isRecurring = false,
    this.recurringId,
    this.notes,
    this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  Transaction copyWith({
    String? id,
    String? userId,
    String? accountId,
    String? type,
    double? amount,
    String? categoryId,
    String? description,
    DateTime? date,
    String? receiptUrl,
    List<String>? tags,
    bool? isRecurring,
    String? recurringId,
    String? notes,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      date: date ?? this.date,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      tags: tags ?? this.tags,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringId: recurringId ?? this.recurringId,
      notes: notes ?? this.notes,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'accountId': accountId,
      'type': type,
      'amount': amount,
      'categoryId': categoryId,
      'description': description,
      'date': date.toIso8601String(),
      'receiptUrl': receiptUrl,
      'tags': tags,
      'isRecurring': isRecurring,
      'recurringId': recurringId,
      'notes': notes,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      userId: json['userId'] as String,
      accountId: json['accountId'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['categoryId'] as String,
      description: json['description'] as String?,
      date: DateTime.parse(json['date'] as String),
      receiptUrl: json['receiptUrl'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>(),
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurringId: json['recurringId'] as String?,
      notes: json['notes'] as String?,
      location: json['location'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';
  bool get isTransfer => type == 'transfer';
}

// ============================================================================
// Savings Goal Model
// ============================================================================

class SavingsGoal {
  final String id;
  final String userId;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final String? icon;
  final String? color;
  final int priority;
  final GoalStatus status;
  final String? notes;
  final List<GoalContribution>? contributions;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SavingsGoal({
    required this.id,
    required this.userId,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.deadline,
    this.icon,
    this.color,
    this.priority = 1,
    this.status = GoalStatus.active,
    this.notes,
    this.contributions,
    required this.createdAt,
    required this.updatedAt,
  });

  double get progressPercentage {
    if (targetAmount <= 0) return 0.0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0) * 100;
  }

  double get remainingAmount => (targetAmount - currentAmount).clamp(0.0, double.infinity);

  int? get daysRemaining {
    if (deadline == null) return null;
    return deadline!.difference(DateTime.now()).inDays;
  }

  SavingsGoal copyWith({
    String? id,
    String? userId,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    String? icon,
    String? color,
    int? priority,
    GoalStatus? status,
    String? notes,
    List<GoalContribution>? contributions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      contributions: contributions ?? this.contributions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': deadline?.toIso8601String(),
      'icon': icon,
      'color': color,
      'priority': priority,
      'status': status.name,
      'notes': notes,
      'contributions': contributions?.map((c) => c.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SavingsGoal.fromJson(Map<String, dynamic> json) {
    return SavingsGoal(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0.0,
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline'] as String) : null,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      priority: json['priority'] as int? ?? 1,
      status: GoalStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => GoalStatus.active,
      ),
      notes: json['notes'] as String?,
      contributions: (json['contributions'] as List<dynamic>?)
          ?.map((c) => GoalContribution.fromJson(c as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class GoalContribution {
  final String id;
  final double amount;
  final DateTime date;
  final String? note;
  final String? accountId;

  const GoalContribution({
    required this.id,
    required this.amount,
    required this.date,
    this.note,
    this.accountId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
      'accountId': accountId,
    };
  }

  factory GoalContribution.fromJson(Map<String, dynamic> json) {
    return GoalContribution(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
      accountId: json['accountId'] as String?,
    );
  }
}

// ============================================================================
// Stock Portfolio Model
// ============================================================================

class StockHolding {
  final String id;
  final String userId;
  final String symbol;
  final String companyName;
  final double shares;
  final double averageBuyPrice;
  final double currentPrice;
  final String? sector;
  final String? exchange;
  final String currency;
  final DateTime? lastUpdated;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StockHolding({
    required this.id,
    required this.userId,
    required this.symbol,
    required this.companyName,
    required this.shares,
    required this.averageBuyPrice,
    this.currentPrice = 0.0,
    this.sector,
    this.exchange,
    this.currency = 'IDR',
    this.lastUpdated,
    required this.createdAt,
    required this.updatedAt,
  });

  double get totalInvested => shares * averageBuyPrice;
  double get currentValue => shares * currentPrice;
  double get profitLoss => currentValue - totalInvested;
  double get profitLossPercentage {
    if (totalInvested <= 0) return 0.0;
    return (profitLoss / totalInvested) * 100;
  }

  StockHolding copyWith({
    String? id,
    String? userId,
    String? symbol,
    String? companyName,
    double? shares,
    double? averageBuyPrice,
    double? currentPrice,
    String? sector,
    String? exchange,
    String? currency,
    DateTime? lastUpdated,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StockHolding(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      symbol: symbol ?? this.symbol,
      companyName: companyName ?? this.companyName,
      shares: shares ?? this.shares,
      averageBuyPrice: averageBuyPrice ?? this.averageBuyPrice,
      currentPrice: currentPrice ?? this.currentPrice,
      sector: sector ?? this.sector,
      exchange: exchange ?? this.exchange,
      currency: currency ?? this.currency,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'symbol': symbol,
      'companyName': companyName,
      'shares': shares,
      'averageBuyPrice': averageBuyPrice,
      'currentPrice': currentPrice,
      'sector': sector,
      'exchange': exchange,
      'currency': currency,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory StockHolding.fromJson(Map<String, dynamic> json) {
    return StockHolding(
      id: json['id'] as String,
      userId: json['userId'] as String,
      symbol: json['symbol'] as String,
      companyName: json['companyName'] as String,
      shares: (json['shares'] as num).toDouble(),
      averageBuyPrice: (json['averageBuyPrice'] as num).toDouble(),
      currentPrice: (json['currentPrice'] as num?)?.toDouble() ?? 0.0,
      sector: json['sector'] as String?,
      exchange: json['exchange'] as String?,
      currency: json['currency'] as String? ?? 'IDR',
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

// ============================================================================
// Watchlist Model
// ============================================================================

class WatchlistItem {
  final String id;
  final String userId;
  final String symbol;
  final String? companyName;
  final double? lastPrice;
  final double? change;
  final double? changePercent;
  final double? targetPrice;
  final String? notes;
  final bool alertEnabled;
  final DateTime addedAt;

  const WatchlistItem({
    required this.id,
    required this.userId,
    required this.symbol,
    this.companyName,
    this.lastPrice,
    this.change,
    this.changePercent,
    this.targetPrice,
    this.notes,
    this.alertEnabled = false,
    required this.addedAt,
  });

  WatchlistItem copyWith({
    String? id,
    String? userId,
    String? symbol,
    String? companyName,
    double? lastPrice,
    double? change,
    double? changePercent,
    double? targetPrice,
    String? notes,
    bool? alertEnabled,
    DateTime? addedAt,
  }) {
    return WatchlistItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      symbol: symbol ?? this.symbol,
      companyName: companyName ?? this.companyName,
      lastPrice: lastPrice ?? this.lastPrice,
      change: change ?? this.change,
      changePercent: changePercent ?? this.changePercent,
      targetPrice: targetPrice ?? this.targetPrice,
      notes: notes ?? this.notes,
      alertEnabled: alertEnabled ?? this.alertEnabled,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'symbol': symbol,
      'companyName': companyName,
      'lastPrice': lastPrice,
      'change': change,
      'changePercent': changePercent,
      'targetPrice': targetPrice,
      'notes': notes,
      'alertEnabled': alertEnabled,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory WatchlistItem.fromJson(Map<String, dynamic> json) {
    return WatchlistItem(
      id: json['id'] as String,
      userId: json['userId'] as String,
      symbol: json['symbol'] as String,
      companyName: json['companyName'] as String?,
      lastPrice: (json['lastPrice'] as num?)?.toDouble(),
      change: (json['change'] as num?)?.toDouble(),
      changePercent: (json['changePercent'] as num?)?.toDouble(),
      targetPrice: (json['targetPrice'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      alertEnabled: json['alertEnabled'] as bool? ?? false,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }
}

// ============================================================================
// Dashboard Summary Model
// ============================================================================

class DashboardSummary {
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpense;
  final double totalSavings;
  final double portfolioValue;
  final double portfolioProfitLoss;
  final double portfolioProfitLossPercent;
  final double netWorth;
  final double netWorthChange;
  final double netWorthChangePercent;
  final double savingsRate;
  final int totalAccounts;
  final int activeGoals;
  final List<CashflowData> cashflowHistory;
  final List<NetWorthData> netWorthHistory;
  final List<CategorySpending> topCategories;
  final List<FinancialInsight> insights;

  const DashboardSummary({
    this.totalBalance = 0.0,
    this.monthlyIncome = 0.0,
    this.monthlyExpense = 0.0,
    this.totalSavings = 0.0,
    this.portfolioValue = 0.0,
    this.portfolioProfitLoss = 0.0,
    this.portfolioProfitLossPercent = 0.0,
    this.netWorth = 0.0,
    this.netWorthChange = 0.0,
    this.netWorthChangePercent = 0.0,
    this.savingsRate = 0.0,
    this.totalAccounts = 0,
    this.activeGoals = 0,
    this.cashflowHistory = const [],
    this.netWorthHistory = const [],
    this.topCategories = const [],
    this.insights = const [],
  });

  DashboardSummary copyWith({
    double? totalBalance,
    double? monthlyIncome,
    double? monthlyExpense,
    double? totalSavings,
    double? portfolioValue,
    double? portfolioProfitLoss,
    double? portfolioProfitLossPercent,
    double? netWorth,
    double? netWorthChange,
    double? netWorthChangePercent,
    double? savingsRate,
    int? totalAccounts,
    int? activeGoals,
    List<CashflowData>? cashflowHistory,
    List<NetWorthData>? netWorthHistory,
    List<CategorySpending>? topCategories,
    List<FinancialInsight>? insights,
  }) {
    return DashboardSummary(
      totalBalance: totalBalance ?? this.totalBalance,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      monthlyExpense: monthlyExpense ?? this.monthlyExpense,
      totalSavings: totalSavings ?? this.totalSavings,
      portfolioValue: portfolioValue ?? this.portfolioValue,
      portfolioProfitLoss: portfolioProfitLoss ?? this.portfolioProfitLoss,
      portfolioProfitLossPercent: portfolioProfitLossPercent ?? this.portfolioProfitLossPercent,
      netWorth: netWorth ?? this.netWorth,
      netWorthChange: netWorthChange ?? this.netWorthChange,
      netWorthChangePercent: netWorthChangePercent ?? this.netWorthChangePercent,
      savingsRate: savingsRate ?? this.savingsRate,
      totalAccounts: totalAccounts ?? this.totalAccounts,
      activeGoals: activeGoals ?? this.activeGoals,
      cashflowHistory: cashflowHistory ?? this.cashflowHistory,
      netWorthHistory: netWorthHistory ?? this.netWorthHistory,
      topCategories: topCategories ?? this.topCategories,
      insights: insights ?? this.insights,
    );
  }
}

class CashflowData {
  final DateTime date;
  final double income;
  final double expense;
  final double net;

  const CashflowData({
    required this.date,
    this.income = 0.0,
    this.expense = 0.0,
    this.net = 0.0,
  });

  factory CashflowData.fromJson(Map<String, dynamic> json) {
    return CashflowData(
      date: DateTime.parse(json['date'] as String),
      income: (json['income'] as num?)?.toDouble() ?? 0.0,
      expense: (json['expense'] as num?)?.toDouble() ?? 0.0,
      net: (json['net'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class NetWorthData {
  final DateTime date;
  final double netWorth;

  const NetWorthData({
    required this.date,
    this.netWorth = 0.0,
  });

  factory NetWorthData.fromJson(Map<String, dynamic> json) {
    return NetWorthData(
      date: DateTime.parse(json['date'] as String),
      netWorth: (json['netWorth'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CategorySpending {
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final String categoryColor;
  final double amount;
  final double percentage;
  final int transactionCount;

  const CategorySpending({
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    this.amount = 0.0,
    this.percentage = 0.0,
    this.transactionCount = 0,
  });

  factory CategorySpending.fromJson(Map<String, dynamic> json) {
    return CategorySpending(
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      categoryIcon: json['categoryIcon'] as String? ?? 'category',
      categoryColor: json['categoryColor'] as String? ?? '#6366F1',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      transactionCount: json['transactionCount'] as int? ?? 0,
    );
  }
}

class FinancialInsight {
  final String id;
  final String type;
  final String title;
  final String message;
  final String? icon;
  final String? color;
  final bool isRead;
  final DateTime createdAt;

  const FinancialInsight({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.icon,
    this.color,
    this.isRead = false,
    required this.createdAt,
  });

  FinancialInsight copyWith({
    String? id,
    String? type,
    String? title,
    String? message,
    String? icon,
    String? color,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return FinancialInsight(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory FinancialInsight.fromJson(Map<String, dynamic> json) {
    return FinancialInsight(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

// ============================================================================
// Transaction Filter Model
// ============================================================================

class TransactionFilter {
  final String? accountId;
  final String? categoryId;
  final String? type;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minAmount;
  final double? maxAmount;
  final List<String>? tags;
  final String? searchQuery;

  const TransactionFilter({
    this.accountId,
    this.categoryId,
    this.type,
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
    this.tags,
    this.searchQuery,
  });

  TransactionFilter copyWith({
    String? accountId,
    String? categoryId,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    List<String>? tags,
    String? searchQuery,
  }) {
    return TransactionFilter(
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      tags: tags ?? this.tags,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool get hasFilters =>
      accountId != null ||
      categoryId != null ||
      type != null ||
      startDate != null ||
      endDate != null ||
      minAmount != null ||
      maxAmount != null ||
      (tags != null && tags!.isNotEmpty) ||
      (searchQuery != null && searchQuery!.isNotEmpty);

  TransactionFilter clear() => const TransactionFilter();
}

// ============================================================================
// App Settings Model
// ============================================================================

class AppSettings {
  final String theme;
  final String currency;
  final String dateFormat;
  final String language;
  final int firstDayOfWeek;
  final bool notificationsEnabled;
  final bool dailyReminder;
  final String reminderTime;
  final bool transactionAlerts;
  final bool portfolioAlerts;
  final bool savingsMilestones;
  final bool biometricEnabled;
  final bool pinEnabled;
  final bool autoSync;
  final String syncFrequency;

  const AppSettings({
    this.theme = 'system',
    this.currency = 'IDR',
    this.dateFormat = 'DD/MM/YYYY',
    this.language = 'id',
    this.firstDayOfWeek = 1,
    this.notificationsEnabled = true,
    this.dailyReminder = true,
    this.reminderTime = '20:00',
    this.transactionAlerts = true,
    this.portfolioAlerts = true,
    this.savingsMilestones = true,
    this.biometricEnabled = false,
    this.pinEnabled = false,
    this.autoSync = true,
    this.syncFrequency = 'realtime',
  });

  AppSettings copyWith({
    String? theme,
    String? currency,
    String? dateFormat,
    String? language,
    int? firstDayOfWeek,
    bool? notificationsEnabled,
    bool? dailyReminder,
    String? reminderTime,
    bool? transactionAlerts,
    bool? portfolioAlerts,
    bool? savingsMilestones,
    bool? biometricEnabled,
    bool? pinEnabled,
    bool? autoSync,
    String? syncFrequency,
  }) {
    return AppSettings(
      theme: theme ?? this.theme,
      currency: currency ?? this.currency,
      dateFormat: dateFormat ?? this.dateFormat,
      language: language ?? this.language,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyReminder: dailyReminder ?? this.dailyReminder,
      reminderTime: reminderTime ?? this.reminderTime,
      transactionAlerts: transactionAlerts ?? this.transactionAlerts,
      portfolioAlerts: portfolioAlerts ?? this.portfolioAlerts,
      savingsMilestones: savingsMilestones ?? this.savingsMilestones,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      pinEnabled: pinEnabled ?? this.pinEnabled,
      autoSync: autoSync ?? this.autoSync,
      syncFrequency: syncFrequency ?? this.syncFrequency,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'currency': currency,
      'dateFormat': dateFormat,
      'language': language,
      'firstDayOfWeek': firstDayOfWeek,
      'notificationsEnabled': notificationsEnabled,
      'dailyReminder': dailyReminder,
      'reminderTime': reminderTime,
      'transactionAlerts': transactionAlerts,
      'portfolioAlerts': portfolioAlerts,
      'savingsMilestones': savingsMilestones,
      'biometricEnabled': biometricEnabled,
      'pinEnabled': pinEnabled,
      'autoSync': autoSync,
      'syncFrequency': syncFrequency,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      theme: json['theme'] as String? ?? 'system',
      currency: json['currency'] as String? ?? 'IDR',
      dateFormat: json['dateFormat'] as String? ?? 'DD/MM/YYYY',
      language: json['language'] as String? ?? 'id',
      firstDayOfWeek: json['firstDayOfWeek'] as int? ?? 1,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      dailyReminder: json['dailyReminder'] as bool? ?? true,
      reminderTime: json['reminderTime'] as String? ?? '20:00',
      transactionAlerts: json['transactionAlerts'] as bool? ?? true,
      portfolioAlerts: json['portfolioAlerts'] as bool? ?? true,
      savingsMilestones: json['savingsMilestones'] as bool? ?? true,
      biometricEnabled: json['biometricEnabled'] as bool? ?? false,
      pinEnabled: json['pinEnabled'] as bool? ?? false,
      autoSync: json['autoSync'] as bool? ?? true,
      syncFrequency: json['syncFrequency'] as String? ?? 'realtime',
    );
  }
}

// ============================================================================
// Notification Model
// ============================================================================

class AppNotification {
  final String id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    this.isRead = false,
    required this.createdAt,
  });

  AppNotification copyWith({
    String? id,
    String? type,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'body': body,
      'data': data,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      data: json['data'] as Map<String, dynamic>?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

// ============================================================================
// Main App Provider
// ============================================================================

class AppProvider extends ChangeNotifier {
  static const _uuid = Uuid();

  // ============================================================================
  // Authentication State
  // ============================================================================

  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isAuthLoading = false;
  String? _authError;
  String? _accessToken;
  String? _refreshToken;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isAuthLoading => _isAuthLoading;
  String? get authError => _authError;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  // ============================================================================
  // Accounts State
  // ============================================================================

  List<Account> _accounts = [];
  Account? _selectedAccount;
  bool _isAccountsLoading = false;
  String? _accountsError;

  List<Account> get accounts => _accounts;
  List<Account> get activeAccounts => _accounts.where((a) => a.isActive).toList();
  Account? get selectedAccount => _selectedAccount;
  bool get isAccountsLoading => _isAccountsLoading;
  String? get accountsError => _accountsError;

  double get totalBalance =>
      activeAccounts.where((a) => a.includeInTotal).fold(0.0, (sum, a) => sum + a.balance);

  Map<AccountType, double> get balanceByAccountType {
    final Map<AccountType, double> result = {};
    for (final type in AccountType.values) {
      result[type] = activeAccounts
          .where((a) => a.type == type && a.includeInTotal)
          .fold(0.0, (sum, a) => sum + a.balance);
    }
    return result;
  }

  // ============================================================================
  // Categories State
  // ============================================================================

  List<Category> _categories = [];
  bool _isCategoriesLoading = false;
  String? _categoriesError;

  List<Category> get categories => _categories;
  List<Category> get incomeCategories => _categories.where((c) => c.type == 'income').toList();
  List<Category> get expenseCategories => _categories.where((c) => c.type == 'expense').toList();
  bool get isCategoriesLoading => _isCategoriesLoading;
  String? get categoriesError => _categoriesError;

  // ============================================================================
  // Transactions State
  // ============================================================================

  List<Transaction> _transactions = [];
  TransactionFilter _transactionFilter = const TransactionFilter();
  bool _isTransactionsLoading = false;
  String? _transactionsError;
  int _transactionPage = 1;
  int _transactionTotalPages = 1;
  bool _hasMoreTransactions = true;

  List<Transaction> get transactions => _transactions;
  TransactionFilter get transactionFilter => _transactionFilter;
  bool get isTransactionsLoading => _isTransactionsLoading;
  String? get transactionsError => _transactionsError;
  bool get hasMoreTransactions => _hasMoreTransactions;

  List<Transaction> get filteredTransactions {
    var result = _transactions;

    if (_transactionFilter.accountId != null) {
      result = result.where((t) => t.accountId == _transactionFilter.accountId).toList();
    }
    if (_transactionFilter.categoryId != null) {
      result = result.where((t) => t.categoryId == _transactionFilter.categoryId).toList();
    }
    if (_transactionFilter.type != null) {
      result = result.where((t) => t.type == _transactionFilter.type).toList();
    }
    if (_transactionFilter.startDate != null) {
      result = result.where((t) => !t.date.isBefore(_transactionFilter.startDate!)).toList();
    }
    if (_transactionFilter.endDate != null) {
      result = result.where((t) => !t.date.isAfter(_transactionFilter.endDate!)).toList();
    }
    if (_transactionFilter.minAmount != null) {
      result = result.where((t) => t.amount >= _transactionFilter.minAmount!).toList();
    }
    if (_transactionFilter.maxAmount != null) {
      result = result.where((t) => t.amount <= _transactionFilter.maxAmount!).toList();
    }
    if (_transactionFilter.searchQuery != null && _transactionFilter.searchQuery!.isNotEmpty) {
      final query = _transactionFilter.searchQuery!.toLowerCase();
      result = result.where((t) =>
          t.description?.toLowerCase().contains(query) == true ||
          t.notes?.toLowerCase().contains(query) == true).toList();
    }

    return result;
  }

  double get totalMonthlyIncome {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return _transactions
        .where((t) => t.type == 'income' && !t.date.isBefore(startOfMonth))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalMonthlyExpense {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return _transactions
        .where((t) => t.type == 'expense' && !t.date.isBefore(startOfMonth))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // ============================================================================
  // Savings Goals State
  // ============================================================================

  List<SavingsGoal> _savingsGoals = [];
  bool _isSavingsLoading = false;
  String? _savingsError;

  List<SavingsGoal> get savingsGoals => _savingsGoals;
  List<SavingsGoal> get activeSavingsGoals =>
      _savingsGoals.where((g) => g.status == GoalStatus.active).toList();
  List<SavingsGoal> get completedSavingsGoals =>
      _savingsGoals.where((g) => g.status == GoalStatus.completed).toList();
  bool get isSavingsLoading => _isSavingsLoading;
  String? get savingsError => _savingsError;

  double get totalSavingsTarget =>
      activeSavingsGoals.fold(0.0, (sum, g) => sum + g.targetAmount);

  double get totalSavingsCurrent =>
      activeSavingsGoals.fold(0.0, (sum, g) => sum + g.currentAmount);

  double get overallSavingsProgress {
    if (totalSavingsTarget <= 0) return 0.0;
    return (totalSavingsCurrent / totalSavingsTarget).clamp(0.0, 1.0) * 100;
  }

  // ============================================================================
  // Stock Portfolio State
  // ============================================================================

  List<StockHolding> _portfolioHoldings = [];
  List<WatchlistItem> _watchlist = [];
  bool _isPortfolioLoading = false;
  String? _portfolioError;
  DateTime? _portfolioLastUpdated;

  List<StockHolding> get portfolioHoldings => _portfolioHoldings;
  List<WatchlistItem> get watchlist => _watchlist;
  bool get isPortfolioLoading => _isPortfolioLoading;
  String? get portfolioError => _portfolioError;
  DateTime? get portfolioLastUpdated => _portfolioLastUpdated;

  double get totalPortfolioValue =>
      _portfolioHoldings.fold(0.0, (sum, h) => sum + h.currentValue);

  double get totalPortfolioInvested =>
      _portfolioHoldings.fold(0.0, (sum, h) => sum + h.totalInvested);

  double get totalPortfolioProfitLoss =>
      _portfolioHoldings.fold(0.0, (sum, h) => sum + h.profitLoss);

  double get totalPortfolioProfitLossPercent {
    if (totalPortfolioInvested <= 0) return 0.0;
    return (totalPortfolioProfitLoss / totalPortfolioInvested) * 100;
  }

  Map<String, double> get sectorAllocation {
    final Map<String, double> result = {};
    final total = totalPortfolioValue;
    if (total <= 0) return result;

    for (final holding in _portfolioHoldings) {
      final sector = holding.sector ?? 'Lainnya';
      result[sector] = (result[sector] ?? 0) + holding.currentValue;
    }

    for (final key in result.keys.toList()) {
      result[key] = (result[key]! / total) * 100;
    }

    return result;
  }

  // ============================================================================
  // Dashboard State
  // ============================================================================

  DashboardSummary _dashboardSummary = const DashboardSummary();
  bool _isDashboardLoading = false;
  String? _dashboardError;

  DashboardSummary get dashboardSummary => _dashboardSummary;
  bool get isDashboardLoading => _isDashboardLoading;
  String? get dashboardError => _dashboardError;

  // ============================================================================
  // Settings State
  // ============================================================================

  AppSettings _settings = const AppSettings();
  bool _isSettingsLoading = false;
  String? _settingsError;

  AppSettings get settings => _settings;
  bool get isSettingsLoading => _isSettingsLoading;
  String? get settingsError => _settingsError;

  // ============================================================================
  // Notifications State
  // ============================================================================

  List<AppNotification> _notifications = [];
  int _unreadNotificationCount = 0;
  bool _isNotificationsLoading = false;

  List<AppNotification> get notifications => _notifications;
  int get unreadNotificationCount => _unreadNotificationCount;
  bool get isNotificationsLoading => _isNotificationsLoading;

  // ============================================================================
  // Sync State
  // ============================================================================

  SyncStatus _syncStatus = SyncStatus.idle;
  DateTime? _lastSyncTime;
  int _pendingChanges = 0;
  bool _isOffline = false;

  SyncStatus get syncStatus => _syncStatus;
  DateTime? get lastSyncTime => _lastSyncTime;
  int get pendingChanges => _pendingChanges;
  bool get isOffline => _isOffline;

  // ============================================================================
  // Global Loading/Error State
  // ============================================================================

  bool _isLoading = false;
  String? _globalError;

  bool get isLoading => _isLoading;
  String? get globalError => _globalError;

  // ============================================================================
  // Authentication Actions
  // ============================================================================

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    String currency = 'IDR',
    String timezone = 'Asia/Jakarta',
  }) async {
    _isAuthLoading = true;
    _authError = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final now = DateTime.now();
      _currentUser = User(
        id: _uuid.v4(),
        email: email,
        name: fullName,
        currency: currency,
        timezone: timezone,
        createdAt: now,
        updatedAt: now,
      );

      _accessToken = 'access_${_uuid.v4()}';
      _refreshToken = 'refresh_${_uuid.v4()}';
      _isAuthenticated = true;

      _isAuthLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _authError = e.toString();
      _isAuthLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isAuthLoading = true;
    _authError = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final now = DateTime.now();
      _currentUser = User(
        id: _uuid.v4(),
        email: email,
        name: 'User',
        createdAt: now,
        updatedAt: now,
      );

      _accessToken = 'access_${_uuid.v4()}';
      _refreshToken = 'refresh_${_uuid.v4()}';
      _isAuthenticated = true;

      _isAuthLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _authError = e.toString();
      _isAuthLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithGoogle(String idToken) async {
    _isAuthLoading = true;
    _authError = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));

      final now = DateTime.now();
      _currentUser = User(
        id: _uuid.v4(),
        email: 'user@gmail.com',
        name: 'Google User',
        emailVerified: true,
        createdAt: now,
        updatedAt: now,
      );

      _accessToken = 'access_${_uuid.v4()}';
      _refreshToken = 'refresh_${_uuid.v4()}';
      _isAuthenticated = true;

      _isAuthLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _authError = e.toString();
      _isAuthLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isAuthLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
    } finally {
      _currentUser = null;
      _accessToken = null;
      _refreshToken = null;
      _isAuthenticated = false;
      _isAuthLoading = false;
      notifyListeners();
    }
  }

  Future<bool> refreshToken() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _accessToken = 'access_${_uuid.v4()}';
      _refreshToken = 'refresh_${_uuid.v4()}';
      notifyListeners();
      return true;
    } catch (e) {
      await logout();
      return false;
    }
  }

  Future<bool> verifyPin(String pin) async {
    // PIN verification logic
    await Future.delayed(const Duration(milliseconds: 300));
    return pin.length == 6;
  }

  Future<bool> setupPin(String pin) async {
    if (_currentUser == null) return false;
    _currentUser = _currentUser!.copyWith(pinEnabled: true);
    notifyListeners();
    return true;
  }

  Future<bool> enableBiometric() async {
    if (_currentUser == null) return false;
    _currentUser = _currentUser!.copyWith(biometricEnabled: true);
    notifyListeners();
    return true;
  }

  Future<bool> disableBiometric() async {
    if (_currentUser == null) return false;
    _currentUser = _currentUser!.copyWith(biometricEnabled: false);
    notifyListeners();
    return true;
  }

  // ============================================================================
  // Account Actions
  // ============================================================================

  Future<Account?> createAccount({
    required String name,
    required AccountType type,
    double initialBalance = 0.0,
    String currency = 'IDR',
    String? icon,
    String? color,
    String? cardLastDigits,
    bool includeInTotal = true,
  }) async {
    _isAccountsLoading = true;
    _accountsError = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final now = DateTime.now();
      final account = Account(
        id: _uuid.v4(),
        userId: _currentUser?.id ?? '',
        name: name,
        type: type,
        balance: initialBalance,
        currency: currency,
        icon: icon,
        color: color,
        cardLastDigits: cardLastDigits,
        includeInTotal: includeInTotal,
        createdAt: now,
        updatedAt: now,
      );

      _accounts.add(account);
      _isAccountsLoading = false;
      notifyListeners();
      return account;
    } catch (e) {
      _accountsError = e.toString();
      _isAccountsLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<Account?> updateAccount(String id, {
    String? name,
    AccountType? type,
    String? icon,
    String? color,
    String? cardLastDigits,
    bool? includeInTotal,
  }) async {
    _isAccountsLoading = true;
    _accountsError = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _accounts.indexWhere((a) => a.id == id);
      if (index == -1) {
        _accountsError = 'Account not found';
        _isAccountsLoading = false;
        notifyListeners();
        return null;
      }

      final updated = _accounts[index].copyWith(
        name: name,
        type: type,
        icon: icon,
        color: color,
        cardLastDigits: cardLastDigits,
        includeInTotal: includeInTotal,
        updatedAt: DateTime.now(),
      );

      _accounts[index] = updated;
      _isAccountsLoading = false;
      notifyListeners();
      return updated;
    } catch (e) {
      _accountsError = e.toString();
      _isAccountsLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateAccountBalance(String id, double newBalance) async {
    try {
      final index = _accounts.indexWhere((a) => a.id == id);
      if (index == -1) return false;

      _accounts[index] = _accounts[index].copyWith(
        balance: newBalance,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteAccount(String id) async {
    _isAccountsLoading = true;
    _accountsError = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      _accounts.removeWhere((a) => a.id == id);
      if (_selectedAccount?.id == id) {
        _selectedAccount = null;
      }

      _isAccountsLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _accountsError = e.toString();
      _isAccountsLoading = false;
      notifyListeners();
      return false;
    }
  }

  void selectAccount(Account? account) {
    _selectedAccount = account;
    notifyListeners();
  }

  Future<void> loadAccounts() async {
    _isAccountsLoading = true;
    _accountsError = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      // Load accounts from API/Local DB
      _isAccountsLoading = false;
      notifyListeners();
    } catch (e) {
      _accountsError = e.toString();
      _isAccountsLoading = false;
      notifyListeners();
    }
  }

  // ============================================================================
  // Category Actions
  // ============================================================================

  Future<Category?> createCategory({
    required String name,
    required String type,
    required String icon,
    required String color,
    String? parentId,
  }) async {
    _isCategoriesLoading = true;
    _categoriesError = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final category = Category(
        id: _uuid.v4(),
        userId: _currentUser?.id,
        name: name,
        type: type,
        icon: icon,
        color: color,
        parentId: parentId,
        isSystem: false,
        createdAt: DateTime.now(),
      );

      _categories.add(category);
      _isCategoriesLoading = false;
      notifyListeners();
      return category;
    } catch (e) {
      _categoriesError = e.toString();
      _isCategoriesLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<Category?> updateCategory(String id, {
    String? name,
    String? icon,
    String? color,
  }) async {
    _isCategoriesLoading = true;
    _categoriesError = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _categories.indexWhere((c) => c.id == id);
      if (index == -1) {
        _categoriesError = 'Category not found';
        _isCategoriesLoading = false;
        notifyListeners();
        return null;
      }

      final updated = _categories[index].copyWith(
        name: name,
        icon: icon,
        color: color,
      );

      _categories[index] = updated;
      _isCategoriesLoading = false;
      notifyListeners();
      return updated;
    } catch (e) {
      _categoriesError = e.toString();
      _isCategoriesLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> deleteCategory(String id) async {
    final category = _categories.firstWhere((c) => c.id == id, orElse: () => throw Exception('Not found'));
    if (category.isSystem) {
      _categoriesError = 'Cannot delete system category';
      notifyListeners();
      return false;
    }

    _isCategoriesLoading = true;
    _categoriesError = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _categories.removeWhere((c) => c.id == id);
      _isCategoriesLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _categoriesError = e.toString();
      _isCategoriesLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadCategories() async {
    _isCategoriesLoading = true;
    _categoriesError = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));

      // Default categories
      _categories = [
        // Income categories
        Category(id: '1', name: 'Gaji', type: 'income', icon: 'briefcase', color: '#10B981', isSystem: true, createdAt: DateTime.now()),
        Category(id: '2', name: 'Freelance', type: 'income', icon: 'laptop', color: '#F59E0B', isSystem: true, createdAt: DateTime.now()),
        Category(id: '3', name: 'Investasi', type: 'income', icon: 'trending-up', color: '#6366F1', isSystem: true, createdAt: DateTime.now()),
        Category(id: '4', name: 'Hadiah', type: 'income', icon: 'gift', color: '#EC4899', isSystem: true, createdAt: DateTime.now()),
        Category(id: '5', name: 'Lainnya', type: 'income', icon: 'plus-circle', color: '#94A3B8', isSystem: true, createdAt: DateTime.now()),
        // Expense categories
        Category(id: '6', name: 'Makanan', type: 'expense', icon: 'utensils', color: '#EF4444', isSystem: true, createdAt: DateTime.now()),
        Category(id: '7', name: 'Transportasi', type: 'expense', icon: 'car', color: '#F59E0B', isSystem: true, createdAt: DateTime.now()),
        Category(id: '8', name: 'Belanja', type: 'expense', icon: 'shopping-bag', color: '#10B981', isSystem: true, createdAt: DateTime.now()),
        Category(id: '9', name: 'Hiburan', type: 'expense', icon: 'film', color: '#8B5CF6', isSystem: true, createdAt: DateTime.now()),
        Category(id: '10', name: 'Kesehatan', type: 'expense', icon: 'heart', color: '#EC4899', isSystem: true, createdAt: DateTime.now()),
        Category(id: '11', name: 'Pendidikan', type: 'expense', icon: 'book', color: '#06B6D4', isSystem: true, createdAt: DateTime.now()),
        Category(id: '12', name: 'Tagihan', type: 'expense', icon: 'file-text', color: '#6366F1', isSystem: true, createdAt: DateTime.now()),
        Category(id: '13', name: 'Lainnya', type: 'expense', icon: 'more-horizontal', color: '#94A3B8', isSystem: true, createdAt: DateTime.now()),
      ];

      _isCategoriesLoading = false;
      notifyListeners();
    } catch (e) {
      _categoriesError = e.toString();
      _isCategoriesLoading = false;
      notifyListeners();
    }
  }

  // ============================================================================
  // Transaction Actions
  // ============================================================================

  Future<Transaction?> createTransaction({
    required String accountId,
    required String type,
    required double amount,
    required String categoryId,
    String? description,
    required DateTime date,
    String? receiptUrl,
    List<String>? tags,
    String? notes,
    String? location,
  }) async {
    _isTransactionsLoading = true;
    _transactionsError = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final now = DateTime.now();
      final transaction = Transaction(
        id: _uuid.v4(),
        userId: _currentUser?.id ?? '',
        accountId: accountId,
        type: type,
        amount: amount,
        categoryId: categoryId,
        description: description,
        date: date,
        receiptUrl: receiptUrl,
        tags: tags,
        notes: notes,
        location: location,
        createdAt: now,
        updatedAt: now,
      );

      _transactions.insert(0, transaction);

      // Update account balance
      await _updateAccountBalanceForTransaction(accountId, type, amount);

      _isTransactionsLoading = false;
      notifyListeners();
      return transaction;
    } catch (e) {
      _transactionsError = e.toString();
      _isTransactionsLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<Transaction?> updateTransaction(String id, {
    String? accountId,
    String? type,
    double? amount,
    String? categoryId,
    String? description,
    DateTime? date,
    String? receiptUrl,
    List<String>? tags,
    String? notes,
    String? location,
  }) async {
    _isTransactionsLoading = true;
    _transactionsError = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _transactions.indexWhere((t) => t.id == id);
      if (index == -1) {
        _transactionsError = 'Transaction not found';
        _isTransactionsLoading = false;
        notifyListeners();
        return null;
      }

      final oldTransaction = _transactions[index];

      // Reverse old balance change
      await _updateAccountBalanceForTransaction(
        oldTransaction.accountId,
        oldTransaction.type,
        oldTransaction.amount,
        isReverse: true,
      );

      final updated = oldTransaction.copyWith(
        accountId: accountId,
        type: type,
        amount: amount,
        categoryId: categoryId,
        description: description,
        date: date,
        receiptUrl: receiptUrl,
        tags: tags,
        notes: notes,
        location: location,
        updatedAt: DateTime.now(),
      );

      _transactions[index] = updated;

      // Apply new balance change
      await _updateAccountBalanceForTransaction(
        accountId ?? oldTransaction.accountId,
        type ?? oldTransaction.type,
        amount ?? oldTransaction.amount,
      );

      _isTransactionsLoading = false;
      notifyListeners();
      return updated;
    } catch (e) {
      _transactionsError = e.toString();
      _isTransactionsLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> deleteTransaction(String id) async {
    _isTransactionsLoading = true;
    _transactionsError = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _transactions.indexWhere((t) => t.id == id);
      if (index == -1) {
        _transactionsError = 'Transaction not found';
        _isTransactionsLoading = false;
        notifyListeners();
        return false;
      }

      final transaction = _transactions[index];

      // Reverse balance change
      await _updateAccountBalanceForTransaction(
        transaction.accountId,
        transaction.type,
        transaction.amount,
        isReverse: true,
      );

      _transactions.removeAt(index);

      _isTransactionsLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _transactionsError = e.toString();
      _isTransactionsLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> _updateAccountBalanceForTransaction(
    String accountId,
    String type,
    double amount, {
    bool isReverse = false,
  }) async {
    try {
      final index = _accounts.indexWhere((a) => a.id == accountId);
      if (index == -1) return false;

      double balanceChange = 0;
      if (type == 'income') {
        balanceChange = isReverse ? -amount : amount;
      } else if (type == 'expense') {
        balanceChange = isReverse ? amount : -amount;
      }

      _accounts[index] = _accounts[index].copyWith(
        balance: _accounts[index].balance + balanceChange,
        updatedAt: DateTime.now(),
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> loadTransactions({bool refresh = false}) async {
    if (refresh) {
      _transactionPage = 1;
      _hasMoreTransactions = true;
    }

    _isTransactionsLoading = true;
    _transactionsError = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));

      // Add mock transactions for demo
      if (_transactions.isEmpty) {
        final now = DateTime.now();
        final categories = expenseCategories;

        for (var i = 0; i < 20; i++) {
          final date = now.subtract(Duration(days: i));
          final category = categories[i % categories.length];

          _transactions.add(Transaction(
            id: _uuid.v4(),
            userId: _currentUser?.id ?? '',
            accountId: _accounts.isNotEmpty ? _accounts.first.id : '',
            type: i % 3 == 0 ? 'income' : 'expense',
            amount: (i + 1) * 50000.0,
            categoryId: category.id,
            description: 'Transaction ${i + 1}',
            date: date,
            createdAt: date,
            updatedAt: date,
          ));
        }
      }

      _transactionPage++;
      _hasMoreTransactions = _transactionPage <= _transactionTotalPages;

      _isTransactionsLoading = false;
      notifyListeners();
    } catch (e) {
      _transactionsError = e.toString();
      _isTransactionsLoading = false;
      notifyListeners();
    }
  }

  void setTransactionFilter(TransactionFilter filter) {
    _transactionFilter = filter;
    notifyListeners();
  }

  void clearTransactionFilter() {
    _transactionFilter = const TransactionFilter();
    notifyListeners();
  }

  // ============================================================================
  // Savings Goal Actions
  // ============================================================================

  Future<SavingsGoal?> createSavingsGoal({
    required String name,
    required double targetAmount,
    DateTime? deadline,
    String? icon,
    String? color,
    int priority = 1,
    String? notes,
  }) async {
    _isSavingsLoading = true;
    _savingsError = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final now = DateTime.now();
      final goal = SavingsGoal(
        id: _uuid.v4(),
        userId: _currentUser?.id ?? '',
        name: name,
        targetAmount: targetAmount,
        currentAmount: 0,
        deadline: deadline,
        icon: icon,
        color: color,
        priority: priority,
        notes: notes,
        createdAt: now,
        updatedAt: now,
      );

      _savingsGoals.add(goal);
      _isSavingsLoading = false;
      notifyListeners();
      return goal;
    } catch (e) {
      _savingsError = e.toString();
      _isSavingsLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<SavingsGoal?> updateSavingsGoal(String id, {
    String? name,
    double? targetAmount,
    DateTime? deadline,
    String? icon,
    String? color,
    int? priority,
    GoalStatus? status,
    String? notes,
  }) async {
    _isSavingsLoading = true;
    _savingsError = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _savingsGoals.indexWhere((g) => g.id == id);
      if (index == -1) {
        _savingsError = 'Goal not found';
        _isSavingsLoading = false;
        notifyListeners();
        return null;
      }

      final updated = _savingsGoals[index].copyWith(
        name: name,
        targetAmount: targetAmount,
        deadline: deadline,
        icon: icon,
        color: color,
        priority: priority,
        status: status,
        notes: notes,
        updatedAt: DateTime.now(),
      );

      _savingsGoals[index] = updated;
      _isSavingsLoading = false;
      notifyListeners();
      return updated;
    } catch (e) {
      _savingsError = e.toString();
      _isSavingsLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<SavingsGoal?> contributeToGoal(String id, {
    required double amount,
    String? note,
    String? accountId,
  }) async {
    _isSavingsLoading = true;
    _savingsError = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _savingsGoals.indexWhere((g) => g.id == id);
      if (index == -1) {
        _savingsError = 'Goal not found';
        _isSavingsLoading = false;
        notifyListeners();
        return null;
      }

      final goal = _savingsGoals[index];
      final newAmount = goal.currentAmount + amount;
      final newStatus = newAmount >= goal.targetAmount ? GoalStatus.completed : goal.status;

      final contribution = GoalContribution(
        id: _uuid.v4(),
        amount: amount,
        date: DateTime.now(),
        note: note,
        accountId: accountId,
      );

      final updated = goal.copyWith(
        currentAmount: newAmount,
        status: newStatus,
        contributions: [...?goal.contributions, contribution],
        updatedAt: DateTime.now(),
      );

      _savingsGoals[index] = updated;
      _isSavingsLoading = false;
      notifyListeners();
      return updated;
    } catch (e) {
      _savingsError = e.toString();
      _isSavingsLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> deleteSavingsGoal(String id) async {
    _isSavingsLoading = true;
    _savingsError = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _savingsGoals.removeWhere((g) => g.id == id);
      _isSavingsLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _savingsError = e.toString();
      _isSavingsLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadSavingsGoals() async {
    _isSavingsLoading = true;
    _savingsError = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      _isSavingsLoading = false;
      notifyListeners();
    } catch (e) {
      _savingsError = e.toString();
      _isSavingsLoading = false;
      notifyListeners();
    }
  }

  // ============================================================================
  // Portfolio Actions
  // ============================================================================

  Future<StockHolding?> addStockHolding({
    required String symbol,
    required String companyName,
    required double shares,
    required double buyPrice,
    required DateTime buyDate,
    String? sector,
    String? exchange,
    double? fees,
    String? broker,
  }) async {
    _isPortfolioLoading = true;
    _portfolioError = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final now = DateTime.now();
      final holding = StockHolding(
        id: _uuid.v4(),
        userId: _currentUser?.id ?? '',
        symbol: symbol,
        companyName: companyName,
        shares: shares,
        averageBuyPrice: buyPrice,
        currentPrice: buyPrice,
        sector: sector,
        exchange: exchange,
        lastUpdated: now,
        createdAt: now,
        updatedAt: now,
      );

      _portfolioHoldings.add(holding);
      _isPortfolioLoading = false;
      notifyListeners();
      return holding;
    } catch (e) {
      _portfolioError = e.toString();
      _isPortfolioLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<StockHolding?> updateStockHolding(String id, {
    double? shares,
    double? averageBuyPrice,
    double? currentPrice,
    String? sector,
  }) async {
    _isPortfolioLoading = true;
    _portfolioError = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _portfolioHoldings.indexWhere((h) => h.id == id);
      if (index == -1) {
        _portfolioError = 'Holding not found';
        _isPortfolioLoading = false;
        notifyListeners();
        return null;
      }

      final updated = _portfolioHoldings[index].copyWith(
        shares: shares,
        averageBuyPrice: averageBuyPrice,
        currentPrice: currentPrice,
        sector: sector,
        updatedAt: DateTime.now(),
      );

      _portfolioHoldings[index] = updated;
      _isPortfolioLoading = false;
      notifyListeners();
      return updated;
    } catch (e) {
      _portfolioError = e.toString();
      _isPortfolioLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<StockHolding?> buyMoreStock(String id, {
    required double additionalShares,
    required double price,
    DateTime? date,
  }) async {
    _isPortfolioLoading = true;
    _portfolioError = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _portfolioHoldings.indexWhere((h) => h.id == id);
      if (index == -1) {
        _portfolioError = 'Holding not found';
        _isPortfolioLoading = false;
        notifyListeners();
        return null;
      }

      final holding = _portfolioHoldings[index];
      final totalShares = holding.shares + additionalShares;
      final totalCost = (holding.shares * holding.averageBuyPrice) + (additionalShares * price);
      final newAveragePrice = totalCost / totalShares;

      final updated = holding.copyWith(
        shares: totalShares,
        averageBuyPrice: newAveragePrice,
        updatedAt: DateTime.now(),
      );

      _portfolioHoldings[index] = updated;
      _isPortfolioLoading = false;
      notifyListeners();
      return updated;
    } catch (e) {
      _portfolioError = e.toString();
      _isPortfolioLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<StockHolding?> sellStock(String id, {
    required double sharesToSell,
    required double price,
    DateTime? date,
  }) async {
    _isPortfolioLoading = true;
    _portfolioError = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _portfolioHoldings.indexWhere((h) => h.id == id);
      if (index == -1) {
        _portfolioError = 'Holding not found';
        _isPortfolioLoading = false;
        notifyListeners();
        return null;
      }

      final holding = _portfolioHoldings[index];
      if (sharesToSell > holding.shares) {
        _portfolioError = 'Cannot sell more shares than owned';
        _isPortfolioLoading = false;
        notifyListeners();
        return null;
      }

      final newShares = holding.shares - sharesToSell;

      if (newShares <= 0) {
        _portfolioHoldings.removeAt(index);
      } else {
        _portfolioHoldings[index] = holding.copyWith(
          shares: newShares,
          updatedAt: DateTime.now(),
        );
      }

      _isPortfolioLoading = false;
      notifyListeners();
      return newShares > 0 ? _portfolioHoldings[index] : null;
    } catch (e) {
      _portfolioError = e.toString();
      _isPortfolioLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> removeStockHolding(String id) async {
    _isPortfolioLoading = true;
    _portfolioError = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _portfolioHoldings.removeWhere((h) => h.id == id);
      _isPortfolioLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _portfolioError = e.toString();
      _isPortfolioLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateStockPrices() async {
    _isPortfolioLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));

      // Simulate price updates
      for (var i = 0; i < _portfolioHoldings.length; i++) {
        final holding = _portfolioHoldings[i];
        final priceChange = ((i % 3) - 1) * 0.02; // -2% to +2%
        final newPrice = holding.currentPrice * (1 + priceChange);

        _portfolioHoldings[i] = holding.copyWith(
          currentPrice: newPrice,
          lastUpdated: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }

      _portfolioLastUpdated = DateTime.now();
      _isPortfolioLoading = false;
      notifyListeners();
    } catch (e) {
      _portfolioError = e.toString();
      _isPortfolioLoading = false;
      notifyListeners();
    }
  }

  // ============================================================================
  // Watchlist Actions
  // ============================================================================

  Future<WatchlistItem?> addToWatchlist({
    required String symbol,
    String? companyName,
    double? targetPrice,
    String? notes,
  }) async {
    try {
      // Check if already in watchlist
      if (_watchlist.any((w) => w.symbol == symbol)) {
        return null;
      }

      final item = WatchlistItem(
        id: _uuid.v4(),
        userId: _currentUser?.id ?? '',
        symbol: symbol,
        companyName: companyName,
        targetPrice: targetPrice,
        notes: notes,
        addedAt: DateTime.now(),
      );

      _watchlist.add(item);
      notifyListeners();
      return item;
    } catch (e) {
      return null;
    }
  }

  Future<bool> removeFromWatchlist(String id) async {
    try {
      _watchlist.removeWhere((w) => w.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<WatchlistItem?> updateWatchlistAlert(String id, {
    double? targetPrice,
    bool? alertEnabled,
    String? notes,
  }) async {
    try {
      final index = _watchlist.indexWhere((w) => w.id == id);
      if (index == -1) return null;

      final updated = _watchlist[index].copyWith(
        targetPrice: targetPrice,
        alertEnabled: alertEnabled,
        notes: notes,
      );

      _watchlist[index] = updated;
      notifyListeners();
      return updated;
    } catch (e) {
      return null;
    }
  }

  // ============================================================================
  // Dashboard Actions
  // ============================================================================

  Future<void> loadDashboard() async {
    _isDashboardLoading = true;
    _dashboardError = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));

      _dashboardSummary = DashboardSummary(
        totalBalance: totalBalance,
        monthlyIncome: totalMonthlyIncome,
        monthlyExpense: totalMonthlyExpense,
        totalSavings: totalSavingsCurrent,
        portfolioValue: totalPortfolioValue,
        portfolioProfitLoss: totalPortfolioProfitLoss,
        portfolioProfitLossPercent: totalPortfolioProfitLossPercent,
        netWorth: totalBalance + totalPortfolioValue,
        savingsRate: totalMonthlyIncome > 0
            ? ((totalMonthlyIncome - totalMonthlyExpense) / totalMonthlyIncome * 100).clamp(0, 100)
            : 0,
        totalAccounts: activeAccounts.length,
        activeGoals: activeSavingsGoals.length,
        topCategories: _getTopCategories(),
        insights: _generateInsights(),
      );

      _isDashboardLoading = false;
      notifyListeners();
    } catch (e) {
      _dashboardError = e.toString();
      _isDashboardLoading = false;
      notifyListeners();
    }
  }

  List<CategorySpending> _getTopCategories() {
    final categorySpending = <String, CategorySpending>{};

    final expenseTransactions = _transactions.where((t) => t.type == 'expense');
    for (final t in expenseTransactions) {
      final category = _categories.firstWhere(
        (c) => c.id == t.categoryId,
        orElse: () => Category(id: t.categoryId, name: 'Unknown', type: 'expense', icon: 'help', color: '#94A3B8', createdAt: DateTime.now()),
      );

      if (categorySpending.containsKey(t.categoryId)) {
        final existing = categorySpending[t.categoryId]!;
        categorySpending[t.categoryId] = CategorySpending(
          categoryId: t.categoryId,
          categoryName: category.name,
          categoryIcon: category.icon,
          categoryColor: category.color,
          amount: existing.amount + t.amount,
          percentage: 0,
          transactionCount: existing.transactionCount + 1,
        );
      } else {
        categorySpending[t.categoryId] = CategorySpending(
          categoryId: t.categoryId,
          categoryName: category.name,
          categoryIcon: category.icon,
          categoryColor: category.color,
          amount: t.amount,
          percentage: 0,
          transactionCount: 1,
        );
      }
    }

    final totalExpense = categorySpending.values.fold(0.0, (sum, c) => sum + c.amount);
    final sortedCategories = categorySpending.values.toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    return sortedCategories.take(5).map((c) {
      return CategorySpending(
        categoryId: c.categoryId,
        categoryName: c.categoryName,
        categoryIcon: c.categoryIcon,
        categoryColor: c.categoryColor,
        amount: c.amount,
        percentage: totalExpense > 0 ? (c.amount / totalExpense * 100) : 0,
        transactionCount: c.transactionCount,
      );
    }).toList();
  }

  List<FinancialInsight> _generateInsights() {
    final insights = <FinancialInsight>[];

    // Savings rate insight
    if (totalMonthlyIncome > 0) {
      final savingsRate = (totalMonthlyIncome - totalMonthlyExpense) / totalMonthlyIncome * 100;
      if (savingsRate < 20) {
        insights.add(FinancialInsight(
          id: _uuid.v4(),
          type: 'warning',
          title: 'Tingkat Tabungan Rendah',
          message: 'Tingkat tabungan Anda ${savingsRate.toStringAsFixed(1)}%. Pertimbangkan untuk mengurangi pengeluaran non-esensial.',
          icon: 'alert-triangle',
          color: '#F59E0B',
          createdAt: DateTime.now(),
        ));
      } else if (savingsRate > 50) {
        insights.add(FinancialInsight(
          id: _uuid.v4(),
          type: 'success',
          title: 'Tabungan Hebat!',
          message: 'Tingkat tabungan Anda ${savingsRate.toStringAsFixed(1)}%. Kerja bagus dalam mengelola keuangan!',
          icon: 'check-circle',
          color: '#10B981',
          createdAt: DateTime.now(),
        ));
      }
    }

    // Top spending category
    final topCategories = _getTopCategories();
    if (topCategories.isNotEmpty) {
      final top = topCategories.first;
      insights.add(FinancialInsight(
        id: _uuid.v4(),
        type: 'info',
        title: 'Pengeluaran Tertinggi',
        message: '${top.categoryName} adalah kategori pengeluaran tertinggi Anda bulan ini.',
        icon: 'info',
        color: '#6366F1',
        createdAt: DateTime.now(),
      ));
    }

    return insights;
  }

  // ============================================================================
  // Settings Actions
  // ============================================================================

  Future<void> loadSettings() async {
    _isSettingsLoading = true;
    _settingsError = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _isSettingsLoading = false;
      notifyListeners();
    } catch (e) {
      _settingsError = e.toString();
      _isSettingsLoading = false;
      notifyListeners();
    }
  }

  Future<AppSettings> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    notifyListeners();
    return _settings;
  }

  Future<void> updateTheme(String theme) async {
    _settings = _settings.copyWith(theme: theme);
    notifyListeners();
  }

  Future<void> updateCurrency(String currency) async {
    _settings = _settings.copyWith(currency: currency);
    notifyListeners();
  }

  Future<void> updateLanguage(String language) async {
    _settings = _settings.copyWith(language: language);
    notifyListeners();
  }

  // ============================================================================
  // Notification Actions
  // ============================================================================

  Future<void> loadNotifications() async {
    _isNotificationsLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _unreadNotificationCount = _notifications.where((n) => !n.isRead).length;
      _isNotificationsLoading = false;
      notifyListeners();
    } catch (e) {
      _isNotificationsLoading = false;
      notifyListeners();
    }
  }

  Future<void> markNotificationAsRead(String id) async {
    try {
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _unreadNotificationCount = _notifications.where((n) => !n.isRead).length;
        notifyListeners();
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      _unreadNotificationCount = 0;
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  // ============================================================================
  // Sync Actions
  // ============================================================================

  Future<void> syncData() async {
    _syncStatus = SyncStatus.syncing;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));
      _syncStatus = SyncStatus.idle;
      _lastSyncTime = DateTime.now();
      _pendingChanges = 0;
      notifyListeners();
    } catch (e) {
      _syncStatus = SyncStatus.error;
      notifyListeners();
    }
  }

  void setOfflineMode(bool offline) {
    _isOffline = offline;
    notifyListeners();
  }

  // ============================================================================
  // Utility Actions
  // ============================================================================

  void clearErrors() {
    _authError = null;
    _accountsError = null;
    _categoriesError = null;
    _transactionsError = null;
    _savingsError = null;
    _portfolioError = null;
    _dashboardError = null;
    _settingsError = null;
    _globalError = null;
    notifyListeners();
  }

  String formatCurrency(double amount, {String? currency}) {
    final curr = currency ?? _settings.currency;
    final symbol = curr == 'IDR' ? 'Rp' : curr == 'USD' ? '\$' : curr;
    final formatted = amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return '$symbol $formatted';
  }

  String formatCompactCurrency(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }

  String formatPercentage(double value, {bool showSign = true}) {
    final sign = showSign && value > 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(2)}%';
  }

  // ============================================================================
  // Initialize Data
  // ============================================================================

  Future<void> initializeApp() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        loadCategories(),
        loadAccounts(),
        loadTransactions(),
        loadSavingsGoals(),
        loadSettings(),
        loadDashboard(),
      ]);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
