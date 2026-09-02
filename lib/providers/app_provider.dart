import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// Enum representing the type of financial account
enum AccountType {
  cash,
  bank,
  ewallet,
  savings,
  investment,
}

/// Enum representing transaction type
enum TransactionType {
  income,
  expense,
  transfer,
}

/// Enum representing savings goal status
enum GoalStatus {
  active,
  completed,
  cancelled,
}

/// Enum representing sync status
enum SyncStatus {
  idle,
  syncing,
  synced,
  error,
  offline,
}

/// Model representing a user
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

  User({
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

/// Model representing a financial account
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
  final bool includeInTotal;
  final String? cardLastDigits;
  final DateTime createdAt;
  final DateTime updatedAt;

  Account({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    this.balance = 0,
    this.currency = 'IDR',
    this.icon,
    this.color,
    this.isActive = true,
    this.includeInTotal = true,
    this.cardLastDigits,
    required this.createdAt,
    required this.updatedAt,
  });

  String get typeLabel {
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

  String get formattedBalance {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: currency == 'IDR' ? 'Rp' : '\$',
      decimalDigits: 0,
    );
    return formatter.format(balance);
  }

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
    bool? includeInTotal,
    String? cardLastDigits,
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
      includeInTotal: includeInTotal ?? this.includeInTotal,
      cardLastDigits: cardLastDigits ?? this.cardLastDigits,
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
      'includeInTotal': includeInTotal,
      'cardLastDigits': cardLastDigits,
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
        orElse: () => AccountType.bank,
      ),
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'IDR',
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      includeInTotal: json['includeInTotal'] as bool? ?? true,
      cardLastDigits: json['cardLastDigits'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// Model representing a transaction category
class Category {
  final String id;
  final String? userId;
  final String name;
  final TransactionType type;
  final String icon;
  final String color;
  final String? parentId;
  final bool isSystem;
  final DateTime createdAt;

  Category({
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
    TransactionType? type,
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
      'type': type.name,
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
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.expense,
      ),
      icon: json['icon'] as String,
      color: json['color'] as String,
      parentId: json['parentId'] as String?,
      isSystem: json['isSystem'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// Model representing a financial transaction
class Transaction {
  final String id;
  final String userId;
  final String accountId;
  final TransactionType type;
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

  Transaction({
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

  String get formattedAmount {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    final prefix = type == TransactionType.expense ? '- ' : '+ ';
    return prefix + formatter.format(amount);
  }

  String get typeLabel {
    switch (type) {
      case TransactionType.income:
        return 'Pemasukan';
      case TransactionType.expense:
        return 'Pengeluaran';
      case TransactionType.transfer:
        return 'Transfer';
    }
  }

  Transaction copyWith({
    String? id,
    String? userId,
    String? accountId,
    TransactionType? type,
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
      'type': type.name,
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
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.expense,
      ),
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['categoryId'] as String,
      description: json['description'] as String?,
      date: DateTime.parse(json['date'] as String),
      receiptUrl: json['receiptUrl'] as String?,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : null,
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurringId: json['recurringId'] as String?,
      notes: json['notes'] as String?,
      location: json['location'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// Model representing a savings goal contribution
class GoalContribution {
  final String id;
  final double amount;
  final DateTime date;
  final String? note;

  GoalContribution({
    required this.id,
    required this.amount,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory GoalContribution.fromJson(Map<String, dynamic> json) {
    return GoalContribution(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
    );
  }
}

/// Model representing a savings goal
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
  final List<GoalContribution> contributions;
  final DateTime createdAt;
  final DateTime updatedAt;

  SavingsGoal({
    required this.id,
    required this.userId,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0,
    this.deadline,
    this.icon,
    this.color,
    this.priority = 1,
    this.status = GoalStatus.active,
    this.notes,
    this.contributions = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  double get progress {
    if (targetAmount <= 0) return 0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  double get progressPercentage => progress * 100;

  double get remainingAmount => (targetAmount - currentAmount).clamp(0, targetAmount);

  int? get daysRemaining {
    if (deadline == null) return null;
    return deadline!.difference(DateTime.now()).inDays;
  }

  bool get isCompleted => status == GoalStatus.completed;
  bool get isExpired => deadline != null && DateTime.now().isAfter(deadline!) && !isCompleted;

  String get formattedTargetAmount {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(targetAmount);
  }

  String get formattedCurrentAmount {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(currentAmount);
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
      'contributions': contributions.map((c) => c.toJson()).toList(),
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
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      priority: json['priority'] as int? ?? 1,
      status: GoalStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => GoalStatus.active,
      ),
      notes: json['notes'] as String?,
      contributions: json['contributions'] != null
          ? (json['contributions'] as List)
              .map((c) => GoalContribution.fromJson(c as Map<String, dynamic>))
              .toList()
          : [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// Model representing a stock holding
class StockHolding {
  final String id;
  final String userId;
  final String symbol;
  final String companyName;
  final double shares;
  final double averagePrice;
  final double currentPrice;
  final String sector;
  final String exchange;
  final String? broker;
  final double totalInvested;
  final double currentValue;
  final double profitLoss;
  final double profitLossPercent;
  final double dayChange;
  final double dayChangePercent;
  final DateTime? lastUpdated;
  final DateTime createdAt;
  final DateTime updatedAt;

  StockHolding({
    required this.id,
    required this.userId,
    required this.symbol,
    required this.companyName,
    required this.shares,
    required this.averagePrice,
    required this.currentPrice,
    this.sector = '',
    this.exchange = 'IDX',
    this.broker,
    required this.totalInvested,
    required this.currentValue,
    required this.profitLoss,
    required this.profitLossPercent,
    this.dayChange = 0,
    this.dayChangePercent = 0,
    this.lastUpdated,
    required this.createdAt,
    required this.updatedAt,
  });

  double get returnPercent {
    if (totalInvested <= 0) return 0;
    return ((currentValue - totalInvested) / totalInvested) * 100;
  }

  String get formattedCurrentValue {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(currentValue);
  }

  String get formattedProfitLoss {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    final prefix = profitLoss >= 0 ? '+ ' : '';
    return prefix + formatter.format(profitLoss);
  }

  StockHolding copyWith({
    String? id,
    String? userId,
    String? symbol,
    String? companyName,
    double? shares,
    double? averagePrice,
    double? currentPrice,
    String? sector,
    String? exchange,
    String? broker,
    double? totalInvested,
    double? currentValue,
    double? profitLoss,
    double? profitLossPercent,
    double? dayChange,
    double? dayChangePercent,
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
      averagePrice: averagePrice ?? this.averagePrice,
      currentPrice: currentPrice ?? this.currentPrice,
      sector: sector ?? this.sector,
      exchange: exchange ?? this.exchange,
      broker: broker ?? this.broker,
      totalInvested: totalInvested ?? this.totalInvested,
      currentValue: currentValue ?? this.currentValue,
      profitLoss: profitLoss ?? this.profitLoss,
      profitLossPercent: profitLossPercent ?? this.profitLossPercent,
      dayChange: dayChange ?? this.dayChange,
      dayChangePercent: dayChangePercent ?? this.dayChangePercent,
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
      'averagePrice': averagePrice,
      'currentPrice': currentPrice,
      'sector': sector,
      'exchange': exchange,
      'broker': broker,
      'totalInvested': totalInvested,
      'currentValue': currentValue,
      'profitLoss': profitLoss,
      'profitLossPercent': profitLossPercent,
      'dayChange': dayChange,
      'dayChangePercent': dayChangePercent,
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
      averagePrice: (json['averagePrice'] as num).toDouble(),
      currentPrice: (json['currentPrice'] as num).toDouble(),
      sector: json['sector'] as String? ?? '',
      exchange: json['exchange'] as String? ?? 'IDX',
      broker: json['broker'] as String?,
      totalInvested: (json['totalInvested'] as num?)?.toDouble() ?? 0,
      currentValue: (json['currentValue'] as num?)?.toDouble() ?? 0,
      profitLoss: (json['profitLoss'] as num?)?.toDouble() ?? 0,
      profitLossPercent: (json['profitLossPercent'] as num?)?.toDouble() ?? 0,
      dayChange: (json['dayChange'] as num?)?.toDouble() ?? 0,
      dayChangePercent: (json['dayChangePercent'] as num?)?.toDouble() ?? 0,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// Model representing a stock transaction
class StockTransaction {
  final String id;
  final String userId;
  final String symbol;
  final String type; // 'buy', 'sell', 'dividend'
  final double shares;
  final double price;
  final double totalAmount;
  final double fee;
  final String? broker;
  final DateTime date;
  final String? notes;
  final DateTime createdAt;

  StockTransaction({
    required this.id,
    required this.userId,
    required this.symbol,
    required this.type,
    required this.shares,
    required this.price,
    required this.totalAmount,
    this.fee = 0,
    this.broker,
    required this.date,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'symbol': symbol,
      'type': type,
      'shares': shares,
      'price': price,
      'totalAmount': totalAmount,
      'fee': fee,
      'broker': broker,
      'date': date.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory StockTransaction.fromJson(Map<String, dynamic> json) {
    return StockTransaction(
      id: json['id'] as String,
      userId: json['userId'] as String,
      symbol: json['symbol'] as String,
      type: json['type'] as String,
      shares: (json['shares'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      fee: (json['fee'] as num?)?.toDouble() ?? 0,
      broker: json['broker'] as String?,
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// Model representing a watchlist item
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

  WatchlistItem({
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

  bool get isTargetReached {
    if (targetPrice == null || lastPrice == null) return false;
    return lastPrice! >= targetPrice!;
  }

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

/// Model representing dashboard summary data
class DashboardSummary {
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpense;
  final double totalSavings;
  final double portfolioValue;
  final double dayChange;
  final double dayChangePercent;
  final List<RecentTransaction> recentTransactions;
  final List<CategoryBreakdown> expenseBreakdown;
  final List<CategoryBreakdown> incomeBreakdown;
  final List<NetWorthData> netWorthHistory;
  final double netWorth;

  DashboardSummary({
    this.totalBalance = 0,
    this.monthlyIncome = 0,
    this.monthlyExpense = 0,
    this.totalSavings = 0,
    this.portfolioValue = 0,
    this.dayChange = 0,
    this.dayChangePercent = 0,
    this.recentTransactions = const [],
    this.expenseBreakdown = const [],
    this.incomeBreakdown = const [],
    this.netWorthHistory = const [],
    this.netWorth = 0,
  });

  double get monthlyNetFlow => monthlyIncome - monthlyExpense;
  double get savingsRate => monthlyIncome > 0 ? (monthlyNetFlow / monthlyIncome) * 100 : 0;

  Map<String, dynamic> toJson() {
    return {
      'totalBalance': totalBalance,
      'monthlyIncome': monthlyIncome,
      'monthlyExpense': monthlyExpense,
      'totalSavings': totalSavings,
      'portfolioValue': portfolioValue,
      'dayChange': dayChange,
      'dayChangePercent': dayChangePercent,
      'recentTransactions': recentTransactions.map((t) => t.toJson()).toList(),
      'expenseBreakdown': expenseBreakdown.map((b) => b.toJson()).toList(),
      'incomeBreakdown': incomeBreakdown.map((b) => b.toJson()).toList(),
      'netWorthHistory': netWorthHistory.map((n) => n.toJson()).toList(),
      'netWorth': netWorth,
    };
  }

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalBalance: (json['totalBalance'] as num?)?.toDouble() ?? 0,
      monthlyIncome: (json['monthlyIncome'] as num?)?.toDouble() ?? 0,
      monthlyExpense: (json['monthlyExpense'] as num?)?.toDouble() ?? 0,
      totalSavings: (json['totalSavings'] as num?)?.toDouble() ?? 0,
      portfolioValue: (json['portfolioValue'] as num?)?.toDouble() ?? 0,
      dayChange: (json['dayChange'] as num?)?.toDouble() ?? 0,
      dayChangePercent: (json['dayChangePercent'] as num?)?.toDouble() ?? 0,
      recentTransactions: json['recentTransactions'] != null
          ? (json['recentTransactions'] as List)
              .map((t) => RecentTransaction.fromJson(t as Map<String, dynamic>))
              .toList()
          : [],
      expenseBreakdown: json['expenseBreakdown'] != null
          ? (json['expenseBreakdown'] as List)
              .map((b) => CategoryBreakdown.fromJson(b as Map<String, dynamic>))
              .toList()
          : [],
      incomeBreakdown: json['incomeBreakdown'] != null
          ? (json['incomeBreakdown'] as List)
              .map((b) => CategoryBreakdown.fromJson(b as Map<String, dynamic>))
              .toList()
          : [],
      netWorthHistory: json['netWorthHistory'] != null
          ? (json['netWorthHistory'] as List)
              .map((n) => NetWorthData.fromJson(n as Map<String, dynamic>))
              .toList()
          : [],
      netWorth: (json['netWorth'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Model for recent transaction display
class RecentTransaction {
  final String id;
  final String description;
  final double amount;
  final String type;
  final String categoryName;
  final String categoryIcon;
  final String categoryColor;
  final DateTime date;

  RecentTransaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'type': type,
      'categoryName': categoryName,
      'categoryIcon': categoryIcon,
      'categoryColor': categoryColor,
      'date': date.toIso8601String(),
    };
  }

  factory RecentTransaction.fromJson(Map<String, dynamic> json) {
    return RecentTransaction(
      id: json['id'] as String,
      description: json['description'] as String? ?? '',
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      categoryName: json['categoryName'] as String? ?? 'Lainnya',
      categoryIcon: json['categoryIcon'] as String? ?? 'tag',
      categoryColor: json['categoryColor'] as String? ?? '#6366F1',
      date: DateTime.parse(json['date'] as String),
    );
  }
}

/// Model for category breakdown
class CategoryBreakdown {
  final String categoryId;
  final String categoryName;
  final String icon;
  final String color;
  final double total;
  final double percentage;
  final int transactionCount;

  CategoryBreakdown({
    required this.categoryId,
    required this.categoryName,
    required this.icon,
    required this.color,
    required this.total,
    required this.percentage,
    required this.transactionCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'icon': icon,
      'color': color,
      'total': total,
      'percentage': percentage,
      'transactionCount': transactionCount,
    };
  }

  factory CategoryBreakdown.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdown(
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      icon: json['icon'] as String? ?? 'tag',
      color: json['color'] as String? ?? '#6366F1',
      total: (json['total'] as num).toDouble(),
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
      transactionCount: json['transactionCount'] as int? ?? 0,
    );
  }
}

/// Model for net worth history data point
class NetWorthData {
  final DateTime date;
  final double netWorth;
  final double assets;
  final double liabilities;

  NetWorthData({
    required this.date,
    required this.netWorth,
    this.assets = 0,
    this.liabilities = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'netWorth': netWorth,
      'assets': assets,
      'liabilities': liabilities,
    };
  }

  factory NetWorthData.fromJson(Map<String, dynamic> json) {
    return NetWorthData(
      date: DateTime.parse(json['date'] as String),
      netWorth: (json['netWorth'] as num).toDouble(),
      assets: (json['assets'] as num?)?.toDouble() ?? 0,
      liabilities: (json['liabilities'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Model for portfolio summary
class PortfolioSummary {
  final double totalInvested;
  final double currentValue;
  final double totalProfitLoss;
  final double totalProfitLossPercent;
  final double dayChange;
  final double dayChangePercent;
  final StockHolding? bestPerformer;
  final StockHolding? worstPerformer;
  final List<SectorAllocation> sectorAllocation;

  PortfolioSummary({
    this.totalInvested = 0,
    this.currentValue = 0,
    this.totalProfitLoss = 0,
    this.totalProfitLossPercent = 0,
    this.dayChange = 0,
    this.dayChangePercent = 0,
    this.bestPerformer,
    this.worstPerformer,
    this.sectorAllocation = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'totalInvested': totalInvested,
      'currentValue': currentValue,
      'totalProfitLoss': totalProfitLoss,
      'totalProfitLossPercent': totalProfitLossPercent,
      'dayChange': dayChange,
      'dayChangePercent': dayChangePercent,
      'bestPerformer': bestPerformer?.toJson(),
      'worstPerformer': worstPerformer?.toJson(),
      'sectorAllocation': sectorAllocation.map((s) => s.toJson()).toList(),
    };
  }

  factory PortfolioSummary.fromJson(Map<String, dynamic> json) {
    return PortfolioSummary(
      totalInvested: (json['totalInvested'] as num?)?.toDouble() ?? 0,
      currentValue: (json['currentValue'] as num?)?.toDouble() ?? 0,
      totalProfitLoss: (json['totalProfitLoss'] as num?)?.toDouble() ?? 0,
      totalProfitLossPercent: (json['totalProfitLossPercent'] as num?)?.toDouble() ?? 0,
      dayChange: (json['dayChange'] as num?)?.toDouble() ?? 0,
      dayChangePercent: (json['dayChangePercent'] as num?)?.toDouble() ?? 0,
      bestPerformer: json['bestPerformer'] != null
          ? StockHolding.fromJson(json['bestPerformer'] as Map<String, dynamic>)
          : null,
      worstPerformer: json['worstPerformer'] != null
          ? StockHolding.fromJson(json['worstPerformer'] as Map<String, dynamic>)
          : null,
      sectorAllocation: json['sectorAllocation'] != null
          ? (json['sectorAllocation'] as List)
              .map((s) => SectorAllocation.fromJson(s as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}

/// Model for sector allocation
class SectorAllocation {
  final String sector;
  final double value;
  final double percentage;

  SectorAllocation({
    required this.sector,
    required this.value,
    required this.percentage,
  });

  Map<String, dynamic> toJson() {
    return {
      'sector': sector,
      'value': value,
      'percentage': percentage,
    };
  }

  factory SectorAllocation.fromJson(Map<String, dynamic> json) {
    return SectorAllocation(
      sector: json['sector'] as String,
      value: (json['value'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
}

/// Model for statistics data
class Statistics {
  final double totalSpending;
  final int spendingTransactionCount;
  final double averageSpending;
  final double totalIncome;
  final int incomeTransactionCount;
  final double averageIncome;
  final double netCashflow;
  final double savingsRate;
  final double totalAssets;
  final double totalLiabilities;
  final double netWorth;
  final List<CategoryBreakdown> spendingByCategory;
  final List<CategoryBreakdown> incomeByCategory;
  final List<NetWorthData> netWorthHistory;

  Statistics({
    this.totalSpending = 0,
    this.spendingTransactionCount = 0,
    this.averageSpending = 0,
    this.totalIncome = 0,
    this.incomeTransactionCount = 0,
    this.averageIncome = 0,
    this.netCashflow = 0,
    this.savingsRate = 0,
    this.totalAssets = 0,
    this.totalLiabilities = 0,
    this.netWorth = 0,
    this.spendingByCategory = const [],
    this.incomeByCategory = const [],
    this.netWorthHistory = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'totalSpending': totalSpending,
      'spendingTransactionCount': spendingTransactionCount,
      'averageSpending': averageSpending,
      'totalIncome': totalIncome,
      'incomeTransactionCount': incomeTransactionCount,
      'averageIncome': averageIncome,
      'netCashflow': netCashflow,
      'savingsRate': savingsRate,
      'totalAssets': totalAssets,
      'totalLiabilities': totalLiabilities,
      'netWorth': netWorth,
      'spendingByCategory': spendingByCategory.map((c) => c.toJson()).toList(),
      'incomeByCategory': incomeByCategory.map((c) => c.toJson()).toList(),
      'netWorthHistory': netWorthHistory.map((n) => n.toJson()).toList(),
    };
  }

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      totalSpending: (json['totalSpending'] as num?)?.toDouble() ?? 0,
      spendingTransactionCount: json['spendingTransactionCount'] as int? ?? 0,
      averageSpending: (json['averageSpending'] as num?)?.toDouble() ?? 0,
      totalIncome: (json['totalIncome'] as num?)?.toDouble() ?? 0,
      incomeTransactionCount: json['incomeTransactionCount'] as int? ?? 0,
      averageIncome: (json['averageIncome'] as num?)?.toDouble() ?? 0,
      netCashflow: (json['netCashflow'] as num?)?.toDouble() ?? 0,
      savingsRate: (json['savingsRate'] as num?)?.toDouble() ?? 0,
      totalAssets: (json['totalAssets'] as num?)?.toDouble() ?? 0,
      totalLiabilities: (json['totalLiabilities'] as num?)?.toDouble() ?? 0,
      netWorth: (json['netWorth'] as num?)?.toDouble() ?? 0,
      spendingByCategory: json['spendingByCategory'] != null
          ? (json['spendingByCategory'] as List)
              .map((c) => CategoryBreakdown.fromJson(c as Map<String, dynamic>))
              .toList()
          : [],
      incomeByCategory: json['incomeByCategory'] != null
          ? (json['incomeByCategory'] as List)
              .map((c) => CategoryBreakdown.fromJson(c as Map<String, dynamic>))
              .toList()
          : [],
      netWorthHistory: json['netWorthHistory'] != null
          ? (json['netWorthHistory'] as List)
              .map((n) => NetWorthData.fromJson(n as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}

/// Model for app settings
class AppSettings {
  final String theme;
  final String language;
  final String currency;
  final String dateFormat;
  final bool notificationsEnabled;
  final bool dailyReminderEnabled;
  final String reminderTime;
  final bool biometricEnabled;
  final bool pinEnabled;
  final bool autoSync;
  final int firstDayOfWeek;

  AppSettings({
    this.theme = 'system',
    this.language = 'id',
    this.currency = 'IDR',
    this.dateFormat = 'DD/MM/YYYY',
    this.notificationsEnabled = true,
    this.dailyReminderEnabled = true,
    this.reminderTime = '20:00',
    this.biometricEnabled = false,
    this.pinEnabled = false,
    this.autoSync = true,
    this.firstDayOfWeek = 1,
  });

  AppSettings copyWith({
    String? theme,
    String? language,
    String? currency,
    String? dateFormat,
    bool? notificationsEnabled,
    bool? dailyReminderEnabled,
    String? reminderTime,
    bool? biometricEnabled,
    bool? pinEnabled,
    bool? autoSync,
    int? firstDayOfWeek,
  }) {
    return AppSettings(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      dateFormat: dateFormat ?? this.dateFormat,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      pinEnabled: pinEnabled ?? this.pinEnabled,
      autoSync: autoSync ?? this.autoSync,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'language': language,
      'currency': currency,
      'dateFormat': dateFormat,
      'notificationsEnabled': notificationsEnabled,
      'dailyReminderEnabled': dailyReminderEnabled,
      'reminderTime': reminderTime,
      'biometricEnabled': biometricEnabled,
      'pinEnabled': pinEnabled,
      'autoSync': autoSync,
      'firstDayOfWeek': firstDayOfWeek,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      theme: json['theme'] as String? ?? 'system',
      language: json['language'] as String? ?? 'id',
      currency: json['currency'] as String? ?? 'IDR',
      dateFormat: json['dateFormat'] as String? ?? 'DD/MM/YYYY',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      dailyReminderEnabled: json['dailyReminderEnabled'] as bool? ?? true,
      reminderTime: json['reminderTime'] as String? ?? '20:00',
      biometricEnabled: json['biometricEnabled'] as bool? ?? false,
      pinEnabled: json['pinEnabled'] as bool? ?? false,
      autoSync: json['autoSync'] as bool? ?? true,
      firstDayOfWeek: json['firstDayOfWeek'] as int? ?? 1,
    );
  }
}

/// Transaction filter model
class TransactionFilter {
  final TransactionType? type;
  final String? accountId;
  final String? categoryId;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minAmount;
  final double? maxAmount;
  final String? searchQuery;
  final List<String>? tags;

  TransactionFilter({
    this.type,
    this.accountId,
    this.categoryId,
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
    this.searchQuery,
    this.tags,
  });

  TransactionFilter copyWith({
    TransactionType? type,
    String? accountId,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    String? searchQuery,
    List<String>? tags,
  }) {
    return TransactionFilter(
      type: type ?? this.type,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      searchQuery: searchQuery ?? this.searchQuery,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    if (type != null) params['type'] = type!.name;
    if (accountId != null) params['accountId'] = accountId;
    if (categoryId != null) params['categoryId'] = categoryId;
    if (startDate != null) params['startDate'] = startDate!.toIso8601String();
    if (endDate != null) params['endDate'] = endDate!.toIso8601String();
    if (minAmount != null) params['minAmount'] = minAmount;
    if (maxAmount != null) params['maxAmount'] = maxAmount;
    if (searchQuery != null) params['search'] = searchQuery;
    if (tags != null && tags!.isNotEmpty) params['tags'] = tags!.join(',');
    return params;
  }

  bool get hasFilters =>
      type != null ||
      accountId != null ||
      categoryId != null ||
      startDate != null ||
      endDate != null ||
      minAmount != null ||
      maxAmount != null ||
      (searchQuery != null && searchQuery!.isNotEmpty) ||
      (tags != null && tags!.isNotEmpty);

  TransactionFilter clear() {
    return TransactionFilter();
  }
}

/// Main application provider using ChangeNotifier
class AppProvider extends ChangeNotifier {
  // Authentication state
  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  String? _accessToken;
  String? _refreshToken;

  // User data
  AppSettings _settings = AppSettings();

  // Financial accounts
  List<Account> _accounts = [];
  Account? _selectedAccount;

  // Transactions
  List<Transaction> _transactions = [];
  TransactionFilter _transactionFilter = TransactionFilter();
  bool _isLoadingTransactions = false;
  int _transactionPage = 1;
  bool _hasMoreTransactions = true;

  // Categories
  List<Category> _categories = [];
  List<Category> _expenseCategories = [];
  List<Category> _incomeCategories = [];

  // Savings goals
  List<SavingsGoal> _savingsGoals = [];
  bool _isLoadingGoals = false;

  // Stock portfolio
  List<StockHolding> _holdings = [];
  List<StockTransaction> _stockTransactions = [];
  PortfolioSummary _portfolioSummary = PortfolioSummary();
  bool _isLoadingPortfolio = false;

  // Watchlist
  List<WatchlistItem> _watchlist = [];
  bool _isLoadingWatchlist = false;

  // Dashboard & Statistics
  DashboardSummary _dashboardSummary = DashboardSummary();
  Statistics _statistics = Statistics();
  bool _isLoadingDashboard = false;

  // Sync state
  SyncStatus _syncStatus = SyncStatus.idle;
  DateTime? _lastSyncTime;
  int _pendingChangesCount = 0;

  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get accessToken => _accessToken;
  AppSettings get settings => _settings;

  List<Account> get accounts => _accounts;
  List<Account> get activeAccounts => _accounts.where((a) => a.isActive).toList();
  Account? get selectedAccount => _selectedAccount;
  double get totalBalance =>
      activeAccounts.where((a) => a.includeInTotal).fold(0, (sum, a) => sum + a.balance);

  List<Transaction> get transactions => _transactions;
  TransactionFilter get transactionFilter => _transactionFilter;
  bool get isLoadingTransactions => _isLoadingTransactions;
  bool get hasMoreTransactions => _hasMoreTransactions;

  List<Category> get categories => _categories;
  List<Category> get expenseCategories => _expenseCategories;
  List<Category> get incomeCategories => _incomeCategories;

  List<SavingsGoal> get savingsGoals => _savingsGoals;
  List<SavingsGoal> get activeSavingsGoals =>
      _savingsGoals.where((g) => g.status == GoalStatus.active).toList();
  double get totalSavingsTarget =>
      _savingsGoals.fold(0, (sum, g) => sum + g.targetAmount);
  double get totalSavingsCurrent =>
      _savingsGoals.fold(0, (sum, g) => sum + g.currentAmount);

  List<StockHolding> get holdings => _holdings;
  List<StockTransaction> get stockTransactions => _stockTransactions;
  PortfolioSummary get portfolioSummary => _portfolioSummary;
  bool get isLoadingPortfolio => _isLoadingPortfolio;
  double get totalPortfolioValue =>
      _holdings.fold(0, (sum, h) => sum + h.currentValue);

  List<WatchlistItem> get watchlist => _watchlist;
  bool get isLoadingWatchlist => _isLoadingWatchlist;

  DashboardSummary get dashboardSummary => _dashboardSummary;
  Statistics get statistics => _statistics;
  bool get isLoadingDashboard => _isLoadingDashboard;

  SyncStatus get syncStatus => _syncStatus;
  DateTime? get lastSyncTime => _lastSyncTime;
  int get pendingChangesCount => _pendingChangesCount;

  // Authentication methods
  Future<void> login(String email, String password) async {
    _setLoading(true);
    _error = null;

    try {
      // Simulate API call - replace with actual implementation
      await Future.delayed(const Duration(seconds: 1));

      final now = DateTime.now();
      _currentUser = User(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: 'User',
        currency: 'IDR',
        createdAt: now,
        updatedAt: now,
      );
      _accessToken = 'mock_access_token';
      _refreshToken = 'mock_refresh_token';
      _isAuthenticated = true;

      await _loadInitialData();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    String currency = 'IDR',
  }) async {
    _setLoading(true);
    _error = null;

    try {
      await Future.delayed(const Duration(seconds: 1));

      final now = DateTime.now();
      _currentUser = User(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: name,
        currency: currency,
        createdAt: now,
        updatedAt: now,
      );
      _accessToken = 'mock_access_token';
      _refreshToken = 'mock_refresh_token';
      _isAuthenticated = true;

      await _initializeDefaultData();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      _currentUser = null;
      _isAuthenticated = false;
      _accessToken = null;
      _refreshToken = null;
      _accounts = [];
      _transactions = [];
      _categories = [];
      _savingsGoals = [];
      _holdings = [];
      _watchlist = [];
      _dashboardSummary = DashboardSummary();
      _statistics = Statistics();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshToken() async {
    if (_refreshToken == null) {
      _error = 'No refresh token available';
      return;
    }

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _accessToken = 'new_access_token_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
    }
  }

  Future<void> updateProfile({
    String? name,
    String? avatarUrl,
    String? phone,
  }) async {
    if (_currentUser == null) return;

    _setLoading(true);

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      _currentUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        avatarUrl: avatarUrl ?? _currentUser!.avatarUrl,
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Account CRUD operations
  Future<Account?> createAccount({
    required String name,
    required AccountType type,
    double initialBalance = 0,
    String? icon,
    String? color,
    String? cardLastDigits,
    bool includeInTotal = true,
  }) async {
    if (_currentUser == null) return null;

    _setLoading(true);

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final now = DateTime.now();
      final account = Account(
        id: 'acc_${DateTime.now().millisecondsSinceEpoch}',
        userId: _currentUser!.id,
        name: name,
        type: type,
        balance: initialBalance,
        currency: _currentUser!.currency,
        icon: icon,
        color: color,
        cardLastDigits: cardLastDigits,
        includeInTotal: includeInTotal,
        createdAt: now,
        updatedAt: now,
      );

      _accounts.add(account);
      _incrementPendingChanges();
      notifyListeners();

      return account;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateAccount(String id, {
    String? name,
    AccountType? type,
    String? icon,
    String? color,
    bool? isActive,
    bool? includeInTotal,
    String? cardLastDigits,
  }) async {
    final index = _accounts.indexWhere((a) => a.id == id);
    if (index == -1) return false;

    _setLoading(true);

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final updated = _accounts[index].copyWith(
        name: name,
        type: type,
        icon: icon,
        color: color,
        isActive: isActive,
        includeInTotal: includeInTotal,
        cardLastDigits: cardLastDigits,
        updatedAt: DateTime.now(),
      );

      _accounts[index] = updated;
      _incrementPendingChanges();
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateAccountBalance(String id, double newBalance) async {
    final index = _accounts.indexWhere((a) => a.id == id);
    if (index == -1) return false;

    try {
      _accounts[index] = _accounts[index].copyWith(
        balance: newBalance,
        updatedAt: DateTime.now(),
      );
      _incrementPendingChanges();
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> deleteAccount(String id) async {
    final index = _accounts.indexWhere((a) => a.id == id);
    if (index == -1) return false;

    _setLoading(true);

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      _accounts.removeAt(index);
      if (_selectedAccount?.id == id) {
        _selectedAccount = null;
      }
      _incrementPendingChanges();
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void selectAccount(Account? account) {
    _selectedAccount = account;
    notifyListeners();
  }

  // Transaction CRUD operations
  Future<Transaction?> createTransaction({
    required String accountId,
    required TransactionType type,
    required double amount,
    required String categoryId,
    String? description,
    DateTime? date,
    List<String>? tags,
    String? receiptUrl,
    String? notes,
  }) async {
    if (_currentUser == null) return null;

    _setLoading(true);

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final now = DateTime.now();
      final transaction = Transaction(
        id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
        userId: _currentUser!.id,
        accountId: accountId,
        type: type,
        amount: amount,
        categoryId: categoryId,
        description: description,
        date: date ?? now,
        tags: tags,
        receiptUrl: receiptUrl,
        notes: notes,
        createdAt: now,
        updatedAt: now,
      );

      _transactions.insert(0, transaction);

      // Update account balance
      final accountIndex = _accounts.indexWhere((a) => a.id == accountId);
      if (accountIndex != -1) {
        final newBalance = type == TransactionType.income
            ? _accounts[accountIndex].balance + amount
            : _accounts[accountIndex].balance - amount;
        _accounts[accountIndex] = _accounts[accountIndex].copyWith(
          balance: newBalance,
          updatedAt: now,
        );
      }

      _incrementPendingChanges();
      notifyListeners();

      return transaction;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateTransaction(String id, {
    TransactionType? type,
    double? amount,
    String? categoryId,
    String? description,
    DateTime? date,
    List<String>? tags,
    String? receiptUrl,
    String? notes,
  }) async {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index == -1) return false;

    _setLoading(true);

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final oldTransaction = _transactions[index];
      final updated = oldTransaction.copyWith(
        type: type,
        amount: amount,
        categoryId: categoryId,
        description: description,
        date: date,
        tags: tags,
        receiptUrl: receiptUrl,
        notes: notes,
        updatedAt: DateTime.now(),
      );

      _transactions[index] = updated;

      // Recalculate account balance if amount or type changed
      if (amount != null || type != null) {
        await _recalculateAccountBalance(oldTransaction.accountId);
      }

      _incrementPendingChanges();
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteTransaction(String id) async {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index == -1) return false;

    _setLoading(true);

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final transaction = _transactions[index];
      _transactions.removeAt(index);

      // Reverse account balance
      await _recalculateAccountBalance(transaction.accountId);

      _incrementPendingChanges();
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _recalculateAccountBalance(String accountId) async {
    final accountIndex = _accounts.indexWhere((a) => a.id == accountId);
    if (accountIndex == -1) return;

    final accountTransactions = _transactions.where((t) => t.accountId == accountId);
    double newBalance = 0;

    for (final txn in accountTransactions) {
      if (txn.type == TransactionType.income) {
        newBalance += txn.amount;
      } else if (txn.type == TransactionType.expense) {
        newBalance -= txn.amount;
      }
    }

    _accounts[accountIndex] = _accounts[accountIndex].copyWith(
      balance: newBalance,
      updatedAt: DateTime.now(),
    );
  }

  void setTransactionFilter(TransactionFilter filter) {
    _transactionFilter = filter;
    _transactionPage = 1;
    _hasMoreTransactions = true;
    notifyListeners();
  }

  void clearTransactionFilter() {
    _transactionFilter = TransactionFilter();
    _transactionPage = 1;
    _hasMoreTransactions = true;
    notifyListeners();
  }

  Future<void> loadMoreTransactions() async {
    if (_isLoadingTransactions || !_hasMoreTransactions) return;

    _isLoadingTransactions = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _transactionPage++;

      // In real app, fetch next page from API
      // For now, just mark as loaded
      _hasMoreTransactions = false;
    } finally {
      _isLoadingTransactions = false;
      notifyListeners();
    }
  }

  // Category CRUD operations
  Future<Category?> createCategory({
    required String name,
    required TransactionType type,
    required String icon,
    required String color,
    String? parentId,
  }) async {
    if (_currentUser == null) return null;

    _setLoading(true);

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final category = Category(
        id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
        userId: _currentUser!.id,
        name: name,
        type: type,
        icon: icon,
        color: color,
        parentId: parentId,
        isSystem: false,
        createdAt: DateTime.now(),
      );

      _categories.add(category);
      _updateCategoryLists();

      _incrementPendingChanges();
      notifyListeners();

      return category;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateCategory(String id, {
    String? name,
    String? icon,
    String? color,
  }) async {
    final index = _categories.indexWhere((c) => c.id == id);
    if (index == -1) return false;

    try {
      _categories[index] = _categories[index].copyWith(
        name: name,
        icon: icon,
        color: color,
      );

      _updateCategoryLists();
      _incrementPendingChanges();
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> deleteCategory(String id) async {
    final category = _categories.firstWhere(
      (c) => c.id == id,
      orElse: () => throw Exception('Category not found'),
    );

    if (category.isSystem) {
      _error = 'Cannot delete system category';
      notifyListeners();
      return false;
    }

    _setLoading(true);

    try {
      _categories.removeWhere((c) => c.id == id);
      _updateCategoryLists();

      _incrementPendingChanges();
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _updateCategoryLists() {
    _expenseCategories = _categories.where((c) => c.type == TransactionType.expense).toList();
    _incomeCategories = _categories.where((c) => c.type == TransactionType.income).toList();
  }

  // Savings Goal CRUD operations
  Future<SavingsGoal?> createSavingsGoal({
    required String name,
    required double targetAmount,
    DateTime? deadline,
    String? icon,
    String? color,
    int priority = 1,
    String? notes,
  }) async {
    if (_currentUser == null) return null;

    _isLoadingGoals = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final now = DateTime.now();
      final goal = SavingsGoal(
        id: 'goal_${DateTime.now().millisecondsSinceEpoch}',
        userId: _currentUser!.id,
        name: name,
        targetAmount: targetAmount,
        deadline: deadline,
        icon: icon,
        color: color,
        priority: priority,
        notes: notes,
        createdAt: now,
        updatedAt: now,
      );

      _savingsGoals.add(goal);
      _incrementPendingChanges();

      return goal;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoadingGoals = false;
      notifyListeners();
    }
  }

  Future<bool> updateSavingsGoal(String id, {
    String? name,
    double? targetAmount,
    DateTime? deadline,
    String? icon,
    String? color,
    int? priority,
    GoalStatus? status,
    String? notes,
  }) async {
    final index = _savingsGoals.indexWhere((g) => g.id == id);
    if (index == -1) return false;

    try {
      _savingsGoals[index] = _savingsGoals[index].copyWith(
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

      _incrementPendingChanges();
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> contributeToGoal(String goalId, {
    required double amount,
    String? note,
    DateTime? date,
  }) async {
    final index = _savingsGoals.indexWhere((g) => g.id == goalId);
    if (index == -1) return false;

    try {
      final goal = _savingsGoals[index];
      final newAmount = goal.currentAmount + amount;
      final newStatus = newAmount >= goal.targetAmount
          ? GoalStatus.completed
          : goal.status;

      final contribution = GoalContribution(
        id: 'contrib_${DateTime.now().millisecondsSinceEpoch}',
        amount: amount,
        date: date ?? DateTime.now(),
        note: note,
      );

      final updatedContributions = [...goal.contributions, contribution];

      _savingsGoals[index] = goal.copyWith(
        currentAmount: newAmount,
        status: newStatus,
        contributions: updatedContributions,
        updatedAt: DateTime.now(),
      );

      _incrementPendingChanges();
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> deleteSavingsGoal(String id) async {
    final index = _savingsGoals.indexWhere((g) => g.id == id);
    if (index == -1) return false;

    _isLoadingGoals = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      _savingsGoals.removeAt(index);
      _incrementPendingChanges();

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoadingGoals = false;
      notifyListeners();
    }
  }

  // Stock Portfolio CRUD operations
  Future<StockHolding?> addStockHolding({
    required String symbol,
    required String companyName,
    required double shares,
    required double buyPrice,
    required double currentPrice,
    String? sector,
    String? exchange,
    String? broker,
  }) async {
    if (_currentUser == null) return null;

    _isLoadingPortfolio = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final totalInvested = shares * buyPrice;
      final currentValue = shares * currentPrice;
      final profitLoss = currentValue - totalInvested;
      final profitLossPercent = totalInvested > 0
          ? (profitLoss / totalInvested) * 100
          : 0;

      final now = DateTime.now();
      final holding = StockHolding(
        id: 'hold_${DateTime.now().millisecondsSinceEpoch}',
        userId: _currentUser!.id,
        symbol: symbol.toUpperCase(),
        companyName: companyName,
        shares: shares,
        averagePrice: buyPrice,
        currentPrice: currentPrice,
        sector: sector ?? '',
        exchange: exchange ?? 'IDX',
        broker: broker,
        totalInvested: totalInvested,
        currentValue: currentValue,
        profitLoss: profitLoss,
        profitLossPercent: profitLossPercent,
        lastUpdated: now,
        createdAt: now,
        updatedAt: now,
      );

      _holdings.add(holding);
      _updatePortfolioSummary();
      _incrementPendingChanges();

      return holding;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoadingPortfolio = false;
      notifyListeners();
    }
  }

  Future<bool> updateStockHolding(String id, {
    double? shares,
    double? averagePrice,
    double? currentPrice,
    String? broker,
  }) async {
    final index = _holdings.indexWhere((h) => h.id == id);
    if (index == -1) return false;

    try {
      final holding = _holdings[index];
      final newShares = shares ?? holding.shares;
      final newAvgPrice = averagePrice ?? holding.averagePrice;
      final newCurrentPrice = currentPrice ?? holding.currentPrice;

      final totalInvested = newShares * newAvgPrice;
      final currentValue = newShares * newCurrentPrice;
      final profitLoss = currentValue - totalInvested;
      final profitLossPercent = totalInvested > 0
          ? (profitLoss / totalInvested) * 100
          : 0;

      _holdings[index] = holding.copyWith(
        shares: newShares,
        averagePrice: newAvgPrice,
        currentPrice: newCurrentPrice,
        broker: broker,
        totalInvested: totalInvested,
        currentValue: currentValue,
        profitLoss: profitLoss,
        profitLossPercent: profitLossPercent,
        lastUpdated: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _updatePortfolioSummary();
      _incrementPendingChanges();
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> recordStockBuy(String holdingId, {
    required double shares,
    required double price,
    required DateTime date,
    double fee = 0,
    String? broker,
    String? notes,
  }) async {
    final index = _holdings.indexWhere((h) => h.id == holdingId);
    if (index == -1) return false;

    try {
      final holding = _holdings[index];

      // Calculate new average price
      final totalOldValue = holding.shares * holding.averagePrice;
      final totalNewValue = shares * price;
      final totalShares = holding.shares + shares;
      final newAvgPrice = totalShares > 0
          ? (totalOldValue + totalNewValue) / totalShares
          : 0;

      // Create stock transaction record
      final stockTxn = StockTransaction(
        id: 'stxn_${DateTime.now().millisecondsSinceEpoch}',
        userId: _currentUser!.id,
        symbol: holding.symbol,
        type: 'buy',
        shares: shares,
        price: price,
        totalAmount: totalNewValue + fee,
        fee: fee,
        broker: broker,
        date: date,
        notes: notes,
        createdAt: DateTime.now(),
      );

      _stockTransactions.add(stockTxn);

      // Update holding
      final currentValue = totalShares * holding.currentPrice;
      final profitLoss = currentValue - (totalShares * newAvgPrice);
      final profitLossPercent = newAvgPrice > 0
          ? (profitLoss / (totalShares * newAvgPrice)) * 100
          : 0;

      _holdings[index] = holding.copyWith(
        shares: totalShares,
        averagePrice: newAvgPrice,
        totalInvested: totalOldValue + totalNewValue,
        currentValue: currentValue,
        profitLoss: profitLoss,
        profitLossPercent: profitLossPercent,
        lastUpdated: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _updatePortfolioSummary();
      _incrementPendingChanges();
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> recordStockSell(String holdingId, {
    required double shares,
    required double price,
    required DateTime date,
    double fee = 0,
    String? broker,
    String? notes,
  }) async {
    final index = _holdings.indexWhere((h) => h.id == holdingId);
    if (index == -1) return false;

    try {
      final holding = _holdings[index];

      if (shares > holding.shares) {
        _error = 'Cannot sell more shares than owned';
        notifyListeners();
        return false;
      }

      // Create stock transaction record
      final stockTxn = StockTransaction(
        id: 'stxn_${DateTime.now().millisecondsSinceEpoch}',
        userId: _currentUser!.id,
        symbol: holding.symbol,
        type: 'sell',
        shares: shares,
        price: price,
        totalAmount: (shares * price) - fee,
        fee: fee,
        broker: broker,
        date: date,
        notes: notes,
        createdAt: DateTime.now(),
      );

      _stockTransactions.add(stockTxn);

      // Update holding
      final newShares = holding.shares - shares;
      final newCurrentValue = newShares * holding.currentPrice;
      final realizedProfit = (price - holding.averagePrice) * shares - fee;

      if (newShares <= 0) {
        _holdings.removeAt(index);
      } else {
        _holdings[index] = holding.copyWith(
          shares: newShares,
          currentValue: newCurrentValue,
          profitLoss: newCurrentValue - (newShares * holding.averagePrice),
          profitLossPercent: ((newCurrentValue - (newShares * holding.averagePrice))
              / (newShares * holding.averagePrice)) * 100,
          lastUpdated: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }

      _updatePortfolioSummary();
      _incrementPendingChanges();
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> deleteStockHolding(String id) async {
    final index = _holdings.indexWhere((h) => h.id == id);
    if (index == -1) return false;

    _isLoadingPortfolio = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      _holdings.removeAt(index);
      _updatePortfolioSummary();
      _incrementPendingChanges();

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoadingPortfolio = false;
      notifyListeners();
    }
  }

  Future<void> refreshStockPrices() async {
    _isLoadingPortfolio = true;
    notifyListeners();

    try {
      // Simulate fetching latest prices from API
      await Future.delayed(const Duration(seconds: 1));

      final now = DateTime.now();

      _holdings = _holdings.map((holding) {
        // Simulate price change
        final priceChange = holding.currentPrice * 0.01 * (DateTime.now().millisecond % 10 - 5);
        final newPrice = holding.currentPrice + priceChange;

        final currentValue = holding.shares * newPrice;
        final profitLoss = currentValue - holding.totalInvested;
        final profitLossPercent = holding.totalInvested > 0
            ? (profitLoss / holding.totalInvested) * 100
            : 0;

        return holding.copyWith(
          currentPrice: newPrice,
          currentValue: currentValue,
          profitLoss: profitLoss,
          profitLossPercent: profitLossPercent,
          dayChange: priceChange,
          dayChangePercent: priceChange / holding.currentPrice * 100,
          lastUpdated: now,
          updatedAt: now,
        );
      }).toList();

      _updatePortfolioSummary();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingPortfolio = false;
      notifyListeners();
    }
  }

  void _updatePortfolioSummary() {
    final totalInvested = _holdings.fold(0.0, (sum, h) => sum + h.totalInvested);
    final currentValue = _holdings.fold(0.0, (sum, h) => sum + h.currentValue);
    final totalProfitLoss = currentValue - totalInvested;
    final totalProfitLossPercent = totalInvested > 0
        ? (totalProfitLoss / totalInvested) * 100
        : 0;

    final dayChange = _holdings.fold(0.0, (sum, h) => sum + (h.dayChange * h.shares));
    final dayChangePercent = currentValue > 0
        ? (dayChange / currentValue) * 100
        : 0;

    StockHolding? bestPerformer;
    StockHolding? worstPerformer;

    if (_holdings.isNotEmpty) {
      final sorted = List<StockHolding>.from(_holdings)
        ..sort((a, b) => b.profitLossPercent.compareTo(a.profitLossPercent));
      bestPerformer = sorted.first;
      worstPerformer = sorted.last;
    }

    // Calculate sector allocation
    final sectorMap = <String, double>{};
    for (final holding in _holdings) {
      final sector = holding.sector.isNotEmpty ? holding.sector : 'Lainnya';
      sectorMap[sector] = (sectorMap[sector] ?? 0) + holding.currentValue;
    }

    final sectorAllocation = sectorMap.entries.map((entry) {
      return SectorAllocation(
        sector: entry.key,
        value: entry.value,
        percentage: currentValue > 0 ? (entry.value / currentValue) * 100 : 0,
      );
    }).toList();

    _portfolioSummary = PortfolioSummary(
      totalInvested: totalInvested,
      currentValue: currentValue,
      totalProfitLoss: totalProfitLoss,
      totalProfitLossPercent: totalProfitLossPercent,
      dayChange: dayChange,
      dayChangePercent: dayChangePercent,
      bestPerformer: bestPerformer,
      worstPerformer: worstPerformer,
      sectorAllocation: sectorAllocation,
    );
  }

  // Watchlist CRUD operations
  Future<WatchlistItem?> addToWatchlist({
    required String symbol,
    String? companyName,
    double? targetPrice,
    String? notes,
    bool alertEnabled = false,
  }) async {
    if (_currentUser == null) return null;

    // Check if already in watchlist
    if (_watchlist.any((w) => w.symbol == symbol.toUpperCase())) {
      _error = 'Stock already in watchlist';
      notifyListeners();
      return null;
    }

    _isLoadingWatchlist = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final item = WatchlistItem(
        id: 'watch_${DateTime.now().millisecondsSinceEpoch}',
        userId: _currentUser!.id,
        symbol: symbol.toUpperCase(),
        companyName: companyName,
        targetPrice: targetPrice,
        notes: notes,
        alertEnabled: alertEnabled,
        addedAt: DateTime.now(),
      );

      _watchlist.add(item);
      _incrementPendingChanges();

      return item;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoadingWatchlist = false;
      notifyListeners();
    }
  }

  Future<bool> updateWatchlistItem(String id, {
    double? targetPrice,
    String? notes,
    bool? alertEnabled,
  }) async {
    final index = _watchlist.indexWhere((w) => w.id == id);
    if (index == -1) return false;

    try {
      _watchlist[index] = _watchlist[index].copyWith(
        targetPrice: targetPrice,
        notes: notes,
        alertEnabled: alertEnabled,
      );

      _incrementPendingChanges();
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> removeFromWatchlist(String id) async {
    final index = _watchlist.indexWhere((w) => w.id == id);
    if (index == -1) return false;

    _isLoadingWatchlist = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      _watchlist.removeAt(index);
      _incrementPendingChanges();

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoadingWatchlist = false;
      notifyListeners();
    }
  }

  // Settings operations
  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    _incrementPendingChanges();
    notifyListeners();
  }

  Future<void> updateTheme(String theme) async {
    _settings = _settings.copyWith(theme: theme);
    _incrementPendingChanges();
    notifyListeners();
  }

  Future<void> updateCurrency(String currency) async {
    _settings = _settings.copyWith(currency: currency);
    _incrementPendingChanges();
    notifyListeners();
  }

  Future<void> toggleBiometric(bool enabled) async {
    _settings = _settings.copyWith(biometricEnabled: enabled);
    _incrementPendingChanges();
    notifyListeners();
  }

  Future<void> toggleNotifications(bool enabled) async {
    _settings = _settings.copyWith(notificationsEnabled: enabled);
    _incrementPendingChanges();
    notifyListeners();
  }

  // Dashboard & Statistics
  Future<void> loadDashboard() async {
    _isLoadingDashboard = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));

      // Calculate summary from actual data
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      final monthlyTransactions = _transactions.where(
        (t) => t.date.isAfter(startOfMonth) || t.date.isAtSameMomentAs(startOfMonth),
      );

      final monthlyIncome = monthlyTransactions
          .where((t) => t.type == TransactionType.income)
          .fold(0.0, (sum, t) => sum + t.amount);

      final monthlyExpense = monthlyTransactions
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (sum, t) => sum + t.amount);

      // Generate recent transactions for dashboard
      final recentTransactions = _transactions.take(5).map((t) {
        final category = _categories.firstWhere(
          (c) => c.id == t.categoryId,
          orElse: () => Category(
            id: '',
            name: 'Lainnya',
            type: t.type,
            icon: 'tag',
            color: '#6366F1',
            createdAt: DateTime.now(),
          ),
        );

        return RecentTransaction(
          id: t.id,
          description: t.description ?? '',
          amount: t.amount,
          type: t.type.name,
          categoryName: category.name,
          categoryIcon: category.icon,
          categoryColor: category.color,
          date: t.date,
        );
      }).toList();

      // Generate category breakdowns
      final expenseByCategory = <String, Map<String, dynamic>>{};
      for (final txn in monthlyTransactions.where((t) => t.type == TransactionType.expense)) {
        final category = _categories.firstWhere(
          (c) => c.id == txn.categoryId,
          orElse: () => Category(
            id: '',
            name: 'Lainnya',
            type: TransactionType.expense,
            icon: 'tag',
            color: '#6366F1',
            createdAt: DateTime.now(),
          ),
        );

        expenseByCategory[category.id] ??= {
          'categoryId': category.id,
          'categoryName': category.name,
          'icon': category.icon,
          'color': category.color,
          'total': 0.0,
          'count': 0,
        };
        expenseByCategory[category.id]!['total'] += txn.amount;
        expenseByCategory[category.id]!['count']++;
      }

      final expenseBreakdown = expenseByCategory.values.map((data) {
        return CategoryBreakdown(
          categoryId: data['categoryId'] as String,
          categoryName: data['categoryName'] as String,
          icon: data['icon'] as String,
          color: data['color'] as String,
          total: data['total'] as double,
          percentage: monthlyExpense > 0 ? (data['total'] as double) / monthlyExpense * 100 : 0,
          transactionCount: data['count'] as int,
        );
      }).toList()
        ..sort((a, b) => b.total.compareTo(a.total));

      final incomeByCategory = <String, Map<String, dynamic>>{};
      for (final txn in monthlyTransactions.where((t) => t.type == TransactionType.income)) {
        final category = _categories.firstWhere(
          (c) => c.id == txn.categoryId,
          orElse: () => Category(
            id: '',
            name: 'Lainnya',
            type: TransactionType.income,
            icon: 'tag',
            color: '#10B981',
            createdAt: DateTime.now(),
          ),
        );

        incomeByCategory[category.id] ??= {
          'categoryId': category.id,
          'categoryName': category.name,
          'icon': category.icon,
          'color': category.color,
          'total': 0.0,
          'count': 0,
        };
        incomeByCategory[category.id]!['total'] += txn.amount;
        incomeByCategory[category.id]!['count']++;
      }

      final incomeBreakdown = incomeByCategory.values.map((data) {
        return CategoryBreakdown(
          categoryId: data['categoryId'] as String,
          categoryName: data['categoryName'] as String,
          icon: data['icon'] as String,
          color: data['color'] as String,
          total: data['total'] as double,
          percentage: monthlyIncome > 0 ? (data['total'] as double) / monthlyIncome * 100 : 0,
          transactionCount: data['count'] as int,
        );
      }).toList()
        ..sort((a, b) => b.total.compareTo(a.total));

      // Generate net worth history
      final netWorthHistory = <NetWorthData>[];
      final netWorth = totalBalance + totalPortfolioValue;

      for (int i = 5; i >= 0; i--) {
        final date = DateTime(now.year, now.month - i, now.day);
        final variation = (i * 0.02 - 0.05) * netWorth;
        netWorthHistory.add(NetWorthData(
          date: date,
          netWorth: netWorth + variation,
          assets: netWorth + variation,
          liabilities: 0,
        ));
      }

      _dashboardSummary = DashboardSummary(
        totalBalance: totalBalance,
        monthlyIncome: monthlyIncome,
        monthlyExpense: monthlyExpense,
        totalSavings: totalSavingsCurrent,
        portfolioValue: totalPortfolioValue,
        dayChange: _portfolioSummary.dayChange,
        dayChangePercent: _portfolioSummary.dayChangePercent,
        recentTransactions: recentTransactions,
        expenseBreakdown: expenseBreakdown,
        incomeBreakdown: incomeBreakdown,
        netWorthHistory: netWorthHistory,
        netWorth: netWorth,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingDashboard = false;
      notifyListeners();
    }
  }

  Future<void> loadStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoadingDashboard = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));

      final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final end = endDate ?? DateTime.now();

      final filteredTransactions = _transactions.where((t) =>
        (t.date.isAfter(start) || t.date.isAtSameMomentAs(start)) &&
        (t.date.isBefore(end) || t.date.isAtSameMomentAs(end))
      );

      final spending = filteredTransactions.where((t) => t.type == TransactionType.expense).toList();
      final income = filteredTransactions.where((t) => t.type == TransactionType.income).toList();

      final totalSpending = spending.fold(0.0, (sum, t) => sum + t.amount);
      final totalIncome = income.fold(0.0, (sum, t) => sum + t.amount);

      // Generate category breakdowns for statistics
      final spendingByCategory = _calculateCategoryBreakdown(spending, totalSpending, TransactionType.expense);
      final incomeByCategory = _calculateCategoryBreakdown(income, totalIncome, TransactionType.income);

      // Generate net worth history
      final netWorthHistory = <NetWorthData>[];
      final netWorth = totalBalance + totalPortfolioValue;

      for (int i = 11; i >= 0; i--) {
        final date = DateTime(now.year, now.month - i, 1);
        final variation = (i * 0.015 - 0.08) * netWorth;
        netWorthHistory.add(NetWorthData(
          date: date,
          netWorth: netWorth + variation,
          assets: netWorth + variation,
          liabilities: 0,
        ));
      }

      _statistics = Statistics(
        totalSpending: totalSpending,
        spendingTransactionCount: spending.length,
        averageSpending: spending.isNotEmpty ? totalSpending / spending.length : 0,
        totalIncome: totalIncome,
        incomeTransactionCount: income.length,
        averageIncome: income.isNotEmpty ? totalIncome / income.length : 0,
        netCashflow: totalIncome - totalSpending,
        savingsRate: totalIncome > 0 ? ((totalIncome - totalSpending) / totalIncome) * 100 : 0,
        totalAssets: totalBalance + totalPortfolioValue,
        totalLiabilities: 0,
        netWorth: netWorth,
        spendingByCategory: spendingByCategory,
        incomeByCategory: incomeByCategory,
        netWorthHistory: netWorthHistory,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingDashboard = false;
      notifyListeners();
    }
  }

  List<CategoryBreakdown> _calculateCategoryBreakdown(
    List<Transaction> transactions,
    double total,
    TransactionType type,
  ) {
    final categoryMap = <String, Map<String, dynamic>>{};

    for (final txn in transactions) {
      final category = _categories.firstWhere(
        (c) => c.id == txn.categoryId,
        orElse: () => Category(
          id: '',
          name: 'Lainnya',
          type: type,
          icon: 'tag',
          color: type == TransactionType.expense ? '#EF4444' : '#10B981',
          createdAt: DateTime.now(),
        ),
      );

      categoryMap[category.id] ??= {
        'categoryId': category.id,
        'categoryName': category.name,
        'icon': category.icon,
        'color': category.color,
        'total': 0.0,
        'count': 0,
      };
      categoryMap[category.id]!['total'] += txn.amount;
      categoryMap[category.id]!['count']++;
    }

    return categoryMap.values.map((data) {
      return CategoryBreakdown(
        categoryId: data['categoryId'] as String,
        categoryName: data['categoryName'] as String,
        icon: data['icon'] as String,
        color: data['color'] as String,
        total: data['total'] as double,
        percentage: total > 0 ? (data['total'] as double) / total * 100 : 0,
        transactionCount: data['count'] as int,
      );
    }).toList()
      ..sort((a, b) => b.total.compareTo(a.total));
  }

  // Sync operations
  Future<void> syncData() async {
    if (_syncStatus == SyncStatus.syncing) return;

    _syncStatus = SyncStatus.syncing;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));

      _lastSyncTime = DateTime.now();
      _pendingChangesCount = 0;
      _syncStatus = SyncStatus.synced;
    } catch (e) {
      _error = e.toString();
      _syncStatus = SyncStatus.error;
    }

    notifyListeners();
  }

  void _incrementPendingChanges() {
    _pendingChangesCount++;
    if (_syncStatus == SyncStatus.synced) {
      _syncStatus = SyncStatus.idle;
    }
  }

  // Data initialization
  Future<void> _loadInitialData() async {
    await _initializeDefaultData();
    await loadDashboard();
  }

  Future<void> _initializeDefaultData() async {
    final now = DateTime.now();

    // Default expense categories
    _expenseCategories = [
      Category(
        id: 'cat_food',
        name: 'Makanan & Minuman',
        type: TransactionType.expense,
        icon: 'restaurant',
        color: '#EF4444',
        isSystem: true,
        createdAt: now,
      ),
      Category(
        id: 'cat_transport',
        name: 'Transportasi',
        type: TransactionType.expense,
        icon: 'directions_car',
        color: '#F59E0B',
        isSystem: true,
        createdAt: now,
      ),
      Category(
        id: 'cat_shopping',
        name: 'Belanja',
        type: TransactionType.expense,
        icon: 'shopping_bag',
        color: '#10B981',
        isSystem: true,
        createdAt: now,
      ),
      Category(
        id: 'cat_entertainment',
        name: 'Hiburan',
        type: TransactionType.expense,
        icon: 'movie',
        color: '#8B5CF6',
        isSystem: true,
        createdAt: now,
      ),
      Category(
        id: 'cat_health',
        name: 'Kesehatan',
        type: TransactionType.expense,
        icon: 'favorite',
        color: '#EC4899',
        isSystem: true,
        createdAt: now,
      ),
      Category(
        id: 'cat_education',
        name: 'Pendidikan',
        type: TransactionType.expense,
        icon: 'school',
        color: '#06B6D4',
        isSystem: true,
        createdAt: now,
      ),
      Category(
        id: 'cat_bills',
        name: 'Tagihan',
        type: TransactionType.expense,
        icon: 'receipt',
        color: '#6366F1',
        isSystem: true,
        createdAt: now,
      ),
      Category(
        id: 'cat_other_expense',
        name: 'Lainnya',
        type: TransactionType.expense,
        icon: 'more_horiz',
        color: '#94A3B8',
        isSystem: true,
        createdAt: now,
      ),
    ];

    // Default income categories
    _incomeCategories = [
      Category(
        id: 'cat_salary',
        name: 'Gaji',
        type: TransactionType.income,
        icon: 'work',
        color: '#10B981',
        isSystem: true,
        createdAt: now,
      ),
      Category(
        id: 'cat_freelance',
        name: 'Freelance',
        type: TransactionType.income,
        icon: 'computer',
        color: '#F59E0B',
        isSystem: true,
        createdAt: now,
      ),
      Category(
        id: 'cat_investment',
        name: 'Investasi',
        type: TransactionType.income,
        icon: 'trending_up',
        color: '#6366F1',
        isSystem: true,
        createdAt: now,
      ),
      Category(
        id: 'cat_gift',
        name: 'Hadiah',
        type: TransactionType.income,
        icon: 'card_giftcard',
        color: '#EC4899',
        isSystem: true,
        createdAt: now,
      ),
      Category(
        id: 'cat_other_income',
        name: 'Lainnya',
        type: TransactionType.income,
        icon: 'add_circle',
        color: '#94A3B8',
        isSystem: true,
        createdAt: now,
      ),
    ];

    _categories = [..._expenseCategories, ..._incomeCategories];

    // Create default account
    await createAccount(
      name: 'Dompet Utama',
      type: AccountType.cash,
      initialBalance: 0,
      icon: 'wallet',
      color: '#2563EB',
    );
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Utility methods
  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  Account? getAccountById(String id) {
    try {
      return _accounts.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Transaction> getFilteredTransactions() {
    var filtered = List<Transaction>.from(_transactions);

    if (_transactionFilter.type != null) {
      filtered = filtered.where((t) => t.type == _transactionFilter.type).toList();
    }

    if (_transactionFilter.accountId != null) {
      filtered = filtered.where((t) => t.accountId == _transactionFilter.accountId).toList();
    }

    if (_transactionFilter.categoryId != null) {
      filtered = filtered.where((t) => t.categoryId == _transactionFilter.categoryId).toList();
    }

    if (_transactionFilter.startDate != null) {
      filtered = filtered.where((t) =>
        t.date.isAfter(_transactionFilter.startDate!) ||
        t.date.isAtSameMomentAs(_transactionFilter.startDate!)
      ).toList();
    }

    if (_transactionFilter.endDate != null) {
      filtered = filtered.where((t) =>
        t.date.isBefore(_transactionFilter.endDate!) ||
        t.date.isAtSameMomentAs(_transactionFilter.endDate!)
      ).toList();
    }

    if (_transactionFilter.minAmount != null) {
      filtered = filtered.where((t) => t.amount >= _transactionFilter.minAmount!).toList();
    }

    if (_transactionFilter.maxAmount != null) {
      filtered = filtered.where((t) => t.amount <= _transactionFilter.maxAmount!).toList();
    }

    if (_transactionFilter.searchQuery != null && _transactionFilter.searchQuery!.isNotEmpty) {
      final query = _transactionFilter.searchQuery!.toLowerCase();
      filtered = filtered.where((t) =>
        (t.description?.toLowerCase().contains(query) ?? false) ||
        (t.notes?.toLowerCase().contains(query) ?? false)
      ).toList();
    }

    if (_transactionFilter.tags != null && _transactionFilter.tags!.isNotEmpty) {
      filtered = filtered.where((t) =>
        t.tags?.any((tag) => _transactionFilter.tags!.contains(tag)) ?? false
      ).toList();
    }

    // Sort by date descending
    filtered.sort((a, b) => b.date.compareTo(a.date));

    return filtered;
  }

  double getTotalByType(TransactionType type) {
    return _transactions
        .where((t) => t.type == type)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getMonthlyTotalByType(TransactionType type) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    return _transactions
        .where((t) =>
          t.type == type &&
          (t.date.isAfter(startOfMonth) || t.date.isAtSameMomentAs(startOfMonth))
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }
}
