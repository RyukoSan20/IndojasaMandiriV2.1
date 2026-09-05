import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;
import '../data/local/database_helper.dart';
import '../models/account_model.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';

class AppProvider extends ChangeNotifier {
  final dbHelper = DatabaseHelper.instance;

  String _userName = 'Pengguna Baru';
  String _currency = 'IDR';
  double _monthlyIncomeValue = 0.0;
  bool _isOnboarded = false;

  List<AccountModel> _accounts = [];
  List<Transaction> _transactions = [];

  String get userName => _userName;
  String get currency => _currency;
  bool get isOnboarded => _isOnboarded;
  List<AccountModel> get accounts => _accounts;
  List<Transaction> get transactions => _transactions;

  UserModel? get currentUser => UserModel(
        id: 'user_main',
        name: _userName,
        displayName: _userName,
        email: 'user@fintrack.local',
        currency: _currency,
      );

  List<String> get incomeCategories => ['Gaji', 'Investasi', 'Bonus', 'Penjualan', 'Lainnya'];
  List<String> get expenseCategories => ['Makanan', 'Transportasi', 'Kebutuhan Pokok', 'Konsumtif', 'Tagihan', 'Lainnya'];

  double get totalBalance => _accounts.fold(0.0, (sum, acc) => sum + acc.balance);
  double get cashAndBankBalance => _accounts
      .where((a) => a.category != AccountCategory.investment)
      .fold(0.0, (sum, a) => sum + a.balance);
  double get totalPortfolioValue => _accounts
      .where((a) => a.category == AccountCategory.investment)
      .fold(0.0, (sum, a) => sum + a.balance);

  double get monthlyIncome => _transactions
      .where((t) => t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get monthlyExpenses => _transactions
      .where((t) => !t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get cashFlow => monthlyIncome - monthlyExpenses;
  double get monthlyIncomeValue => _monthlyIncomeValue;

  Future<void> refreshDashboard() async {
    await loadInitialData();
  }

  Future<void> loadInitialData() async {
    final db = await dbHelper.database;

    final userRes = await db.query('user_profile');
    if (userRes.isNotEmpty) {
      _userName = userRes.first['name'] as String? ?? 'Pengguna Baru';
      _currency = userRes.first['currency'] as String? ?? 'IDR';
      _monthlyIncomeValue = (userRes.first['monthly_income'] as num?)?.toDouble() ?? 0.0;
      _isOnboarded = true;
    } else {
      _isOnboarded = false;
    }

    final accRes = await db.query('accounts');
    _accounts = accRes.map((map) => AccountModel.fromJson(map)).toList();

    final txRes = await db.query('transactions', orderBy: 'date DESC');
    _transactions = txRes.map((map) => Transaction.fromMap(map)).toList();

    notifyListeners();
  }

  Future<void> completeOnboarding({
    required String name,
    required String currency,
    required double income,
    required bool hasIncome,
    required bool useFormula,
    required String goalType,
  }) async {
    final db = await dbHelper.database;
    _userName = name;
    _currency = currency;
    _monthlyIncomeValue = income;
    _isOnboarded = true;

    await db.insert('user_profile', {
      'id': 'user_main',
      'name': name,
      'currency': currency,
      'monthly_income': income,
      'has_monthly_income': hasIncome ? 1 : 0,
      'use_allocation_hack': useFormula ? 1 : 0,
      'goal_type': goalType,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    _accounts.clear();
    await db.delete('accounts');

    if (useFormula && income > 0) {
      // FORMULA HACK 50/5/30/15
      _accounts = [
        AccountModel(id: 'acc_needs', name: 'Kebutuhan Pokok (50%)', balance: income * 0.50, category: AccountCategory.bank, currency: currency),
        AccountModel(id: 'acc_wants', name: 'Konsumtif (5%)', balance: income * 0.05, category: AccountCategory.ewallet, currency: currency),
        AccountModel(id: 'acc_invest', name: 'Portofolio Investasi (30%)', balance: income * 0.30, category: AccountCategory.investment, currency: currency),
        AccountModel(id: 'acc_emergency', name: 'Dana Darurat (15%)', balance: income * 0.15, category: AccountCategory.cash, currency: currency),
      ];
    } else {
      _accounts = [
        AccountModel(id: 'acc_cash', name: 'Kas Utama / Tunai', balance: income, category: AccountCategory.cash, currency: currency),
        AccountModel(id: 'acc_bank', name: 'Bank Konvensional', balance: 0.0, category: AccountCategory.bank, currency: currency),
        AccountModel(id: 'acc_ewallet', name: 'E-Wallet (Gopay/OVO)', balance: 0.0, category: AccountCategory.ewallet, currency: currency),
        AccountModel(id: 'acc_valas', name: 'Akun Valas (USD/SAR)', balance: 0.0, category: AccountCategory.valas, currency: currency),
      ];
    }

    for (var acc in _accounts) {
      await db.insert('accounts', acc.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await loadInitialData();
  }

  Future<void> addTransaction({
    required String accountId,
    required String title,
    required double amount,
    required bool isIncome,
    required String category,
  }) async {
    final db = await dbHelper.database;
    final txId = DateTime.now().millisecondsSinceEpoch.toString();

    await db.insert('transactions', {
      'id': txId,
      'account_id': accountId,
      'title': title,
      'amount': amount,
      'type': isIncome ? 'income' : 'expense',
      'category': category,
      'date': DateTime.now().toIso8601String(),
    });

    final accIndex = _accounts.indexWhere((a) => a.id == accountId);
    if (accIndex != -1) {
      final acc = _accounts[accIndex];
      final newBalance = isIncome ? acc.balance + amount : acc.balance - amount;
      acc.balance = newBalance;
      await db.update('accounts', {'balance': newBalance}, where: 'id = ?', whereArgs: [accountId]);
    }

    await loadInitialData();
  }

  Future<void> transferFunds({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
  }) async {
    final db = await dbHelper.database;

    final fromAcc = _accounts.firstWhere((a) => a.id == fromAccountId);
    final toAcc = _accounts.firstWhere((a) => a.id == toAccountId);

    fromAcc.balance -= amount;
    toAcc.balance += amount;

    await db.update('accounts', {'balance': fromAcc.balance}, where: 'id = ?', whereArgs: [fromAccountId]);
    await db.update('accounts', {'balance': toAcc.balance}, where: 'id = ?', whereArgs: [toAccountId]);

    await addTransaction(
      accountId: fromAccountId,
      title: 'Transfer ke ${toAcc.name}',
      amount: amount,
      isIncome: false,
      category: 'Transfer',
    );
  }
}
