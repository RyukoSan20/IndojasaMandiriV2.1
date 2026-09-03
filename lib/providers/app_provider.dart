import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/account_model.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/savings_goal_model.dart';
import '../models/portfolio_model.dart';
import '../models/watchlist_model.dart';
import '../models/dashboard_model.dart';
import '../models/settings_model.dart';

/// AppProvider - Central state management for FinTrack application
/// Handles all CRUD operations for accounts, transactions, savings goals,
/// portfolio holdings, and provides dashboard analytics
class AppProvider extends ChangeNotifier {
  // UUID Generator
  static const _uuid = Uuid();

  // ==================== STATE VARIABLES ====================

  // Authentication State
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  UserModel? _currentUser;
  String? _accessToken;
  String? _refreshToken;

  // Accounts State
  List<AccountModel> _accounts = [];
  AccountModel? _selectedAccount;
  double _totalBalance = 0.0;

  // Transactions State
  List<TransactionModel> _transactions = [];
  List<TransactionModel> _filteredTransactions = [];
  TransactionFilter _transactionFilter = TransactionFilter();
  int _transactionPage = 1;
  bool _hasMoreTransactions = true;

  // Categories State
  List<CategoryModel> _categories = [];
  List<CategoryModel> _incomeCategories = [];
  List<CategoryModel> _expenseCategories = [];

  // Savings Goals State
  List<SavingsGoalModel> _savingsGoals = [];
  double _totalSavingsTarget = 0.0;
  double _totalSavingsCurrent = 0.0;

  // Portfolio State
  List<PortfolioHoldingModel> _portfolioHoldings = [];
  double _totalPortfolioValue = 0.0;
  double _totalPortfolioInvested = 0.0;
  double _totalPortfolioProfitLoss = 0.0;
  double _totalPortfolioReturnPercent = 0.0;

  // Watchlist State
  List<WatchlistItemModel> _watchlist = [];

  // Dashboard State
  DashboardModel? _dashboardData;
  List<CashflowData> _cashflowData = [];
  List<NetWorthData> _netWorthHistory = [];
  List<FinancialInsight> _insights = [];

  // Statistics State
  Map<String, double> _expensesByCategory = {};
  Map<String, double> _incomeByCategory = {};
  double _monthlyIncome = 0.0;
  double _monthlyExpenses = 0.0;
  double _savingsRate = 0.0;

  // Settings State
  SettingsModel _settings = SettingsModel();

  // Sync State
  SyncStatus _syncStatus = SyncStatus.idle;
  DateTime? _lastSyncTime;
  int _pendingChanges = 0;

  // ==================== CONSTRUCTOR ====================

  AppProvider() {
    _initializeDefaults();
  }

  void _initializeDefaults() {
    // Initialize default categories
    _categories = _getDefaultCategories();
    _incomeCategories = _categories.where((c) => c.type == 'income').toList();
    _expenseCategories = _categories.where((c) => c.type == 'expense').toList();
  }

  // ==================== AUTHENTICATION ====================

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  UserModel? get currentUser => _currentUser;

  Future<bool> login({
    required String email,
    required String password,
    Map<String, dynamic>? deviceInfo,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock successful login - using standard UserModel constructor
      _currentUser = UserModel(
        id: _uuid.v4(),
        email: email,
        fullName: email.split('@').first,
        createdAt: DateTime.now(),
      );

      _accessToken = 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}';
      _refreshToken = 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}';
      _isAuthenticated = true;

      // Load user data
      await _loadUserData();

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    String? currency,
    String? timezone,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await Future.delayed(const Duration(milliseconds: 1000));

      _currentUser = UserModel(
        id: _uuid.v4(),
        email: email,
        fullName: fullName,
        createdAt: DateTime.now(),
      );

      _accessToken = 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}';
      _refreshToken = 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}';
      _isAuthenticated = true;

      // Create default account for new user
      await _createDefaultAccount();

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Registration failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> loginWithGoogle(String idToken, Map<String, dynamic>? deviceInfo) async {
    _setLoading(true);
    _clearError();

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock Google login - using standard UserModel constructor
      _currentUser = UserModel(
        id: _uuid.v4(),
        email: 'user@gmail.com',
        fullName: 'Google User',
        avatarUrl: 'https://lh3.googleusercontent.com/photo.jpg',
        emailVerified: true,
        createdAt: DateTime.now(),
      );

      _accessToken = 'mock_google_token_${DateTime.now().millisecondsSinceEpoch}';
      _refreshToken = 'mock_google_refresh_${DateTime.now().millisecondsSinceEpoch}';
      _isAuthenticated = true;

      await _loadUserData();

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Google login failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      _isAuthenticated = false;
      _currentUser = null;
      _accessToken = null;
      _refreshToken = null;

      // Clear all user data
      _accounts.clear();
      _transactions.clear();
      _filteredTransactions.clear();
      _savingsGoals.clear();
      _portfolioHoldings.clear();
      _watchlist.clear();
      _dashboardData = null;

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> refreshToken() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _accessToken = 'refreshed_token_${DateTime.now().millisecondsSinceEpoch}';
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Token refresh failed');
      return false;
    }
  }

  Future<void> _loadUserData() async {
    // In real app, fetch from API/DB
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> _createDefaultAccount() async {
    final cashAccount = AccountModel(
      id: _uuid.v4(),
      userId: _currentUser?.id ?? '',
      name: 'Tunai',
      type: AccountType.cash,
      balance: 0,
      currency: 'IDR',
      icon: 'wallet',
      color: '#10B981',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _accounts.add(cashAccount);
  }

  // ==================== ACCOUNTS CRUD ====================

  List<AccountModel> get accounts => _accounts;
  List<AccountModel> get activeAccounts => _accounts.where((a) => a.isActive).toList();
  AccountModel? get selectedAccount => _selectedAccount;
  double get totalBalance => _totalBalance;

  Future<AccountModel?> createAccount({
    required String name,
    required AccountType type,
    required double initialBalance,
    String currency = 'IDR',
    String? icon,
    String? color,
    String? cardLastDigits,
    bool includeInTotal = true,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final account = AccountModel(
        id: _uuid.v4(),
        userId: _currentUser?.id ?? '',
        name: name,
        type: type,
        balance: initialBalance,
        currency: currency,
        icon: icon ?? _getDefaultIconForType(type),
        color: color ?? _getDefaultColorForType(type),
        cardLastDigits: cardLastDigits,
        isActive: true,
        includeInTotal: includeInTotal,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _accounts.add(account);
      _calculateTotalBalance();

      // If initial balance is set, create a transaction
      if (initialBalance > 0) {
        await createTransaction(
          type: TransactionType.income,
          amount: initialBalance,
          categoryId: _categories.firstWhere(
            (c) => c.type == 'income' && c.name == 'Saldo Awal',
            orElse: () => _categories.firstWhere((c) => c.type == 'income'),
          ).id,
          accountId: account.id,
          description: 'Saldo awal $name',
          date: DateTime.now(),
        );
      }

      notifyListeners();
      return account;
    } catch (e) {
      _setError('Failed to create account: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<AccountModel?> updateAccount({
    required String accountId,
    String? name,
    AccountType? type,
    String? icon,
    String? color,
    bool? isActive,
    bool? includeInTotal,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final index = _accounts.indexWhere((a) => a.id == accountId);
      if (index == -1) {
        _setError('Account not found');
        return null;
      }

      final account = _accounts[index];
      final updatedAccount = AccountModel(
        id: account.id,
        userId: account.userId,
        name: name ?? account.name,
        type: type ?? account.type,
        balance: account.balance,
        currency: account.currency,
        icon: icon ?? account.icon,
        color: color ?? account.color,
        cardLastDigits: account.cardLastDigits,
        isActive: isActive ?? account.isActive,
        includeInTotal: includeInTotal ?? account.includeInTotal,
        createdAt: account.createdAt,
        updatedAt: DateTime.now(),
      );

      _accounts[index] = updatedAccount;
      _calculateTotalBalance();

      notifyListeners();
      return updatedAccount;
    } catch (e) {
      _setError('Failed to update account: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteAccount(String accountId) async {
    _setLoading(true);
    _clearError();

    try {
      _accounts.removeWhere((a) => a.id == accountId);
      _calculateTotalBalance();

      // Also remove transactions for this account
      _transactions.removeWhere((t) => t.accountId == accountId);

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete account: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateAccountBalance(String accountId, double newBalance) async {
    try {
      final index = _accounts.indexWhere((a) => a.id == accountId);
      if (index == -1) return false;

      final account = _accounts[index];
      _accounts[index] = AccountModel(
        id: account.id,
        userId: account.userId,
        name: account.name,
        type: account.type,
        balance: newBalance,
        currency: account.currency,
        icon: account.icon,
        color: account.color,
        cardLastDigits: account.cardLastDigits,
        isActive: account.isActive,
        includeInTotal: account.includeInTotal,
        createdAt: account.createdAt,
        updatedAt: DateTime.now(),
      );

      _calculateTotalBalance();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update balance: ${e.toString()}');
      return false;
    }
  }

  void selectAccount(AccountModel? account) {
    _selectedAccount = account;
    notifyListeners();
  }

  AccountModel? getAccountById(String id) {
    try {
      return _accounts.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  void _calculateTotalBalance() {
    _totalBalance = _accounts
        .where((a) => a.isActive && a.includeInTotal)
        .fold(0.0, (sum, a) => sum + a.balance);
  }

  // ==================== TRANSACTIONS CRUD ====================

  List<TransactionModel> get transactions => _filteredTransactions.isEmpty ? _transactions : _filteredTransactions;
  TransactionFilter get transactionFilter => _transactionFilter;
  bool get hasMoreTransactions => _hasMoreTransactions;

  Future<TransactionModel?> createTransaction({
    required TransactionType type,
    required double amount,
    required String categoryId,
    required String accountId,
    String? description,
    required DateTime date,
    String? receiptUrl,
    List<String>? tags,
    String? notes,
    String? location,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final transaction = TransactionModel(
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
        status: 'completed',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _transactions.add(transaction);
      _applyTransactionFilter();

      // Update account balance
      await _updateAccountBalanceFromTransaction(accountId, type, amount);

      // Recalculate dashboard
      await _recalculateDashboard();

      notifyListeners();
      return transaction;
    } catch (e) {
      _setError('Failed to create transaction: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<TransactionModel?> updateTransaction({
    required String transactionId,
    TransactionType? type,
    double? amount,
    String? categoryId,
    String? accountId,
    String? description,
    DateTime? date,
    String? receiptUrl,
    List<String>? tags,
    String? notes,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final index = _transactions.indexWhere((t) => t.id == transactionId);
      if (index == -1) {
        _setError('Transaction not found');
        return null;
      }

      final oldTransaction = _transactions[index];

      // Reverse old transaction effect
      await _updateAccountBalanceFromTransaction(
        oldTransaction.accountId,
        oldTransaction.type,
        -oldTransaction.amount,
      );

      final updatedTransaction = TransactionModel(
        id: oldTransaction.id,
        userId: oldTransaction.userId,
        accountId: accountId ?? oldTransaction.accountId,
        type: type ?? oldTransaction.type,
        amount: amount ?? oldTransaction.amount,
        categoryId: categoryId ?? oldTransaction.categoryId,
        description: description ?? oldTransaction.description,
        date: date ?? oldTransaction.date,
        receiptUrl: receiptUrl ?? oldTransaction.receiptUrl,
        tags: tags ?? oldTransaction.tags,
        notes: notes ?? oldTransaction.notes,
        location: oldTransaction.location,
        status: oldTransaction.status,
        createdAt: oldTransaction.createdAt,
        updatedAt: DateTime.now(),
      );

      _transactions[index] = updatedTransaction;
      _applyTransactionFilter();

      // Apply new transaction effect
      await _updateAccountBalanceFromTransaction(
        updatedTransaction.accountId,
        updatedTransaction.type,
        updatedTransaction.amount,
      );

      await _recalculateDashboard();

      notifyListeners();
      return updatedTransaction;
    } catch (e) {
      _setError('Failed to update transaction: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteTransaction(String transactionId) async {
    _setLoading(true);
    _clearError();

    try {
      final index = _transactions.indexWhere((t) => t.id == transactionId);
      if (index == -1) {
        _setError('Transaction not found');
        return false;
      }

      final transaction = _transactions[index];

      // Reverse transaction effect
      await _updateAccountBalanceFromTransaction(
        transaction.accountId,
        transaction.type,
        -transaction.amount,
      );

      _transactions.removeAt(index);
      _applyTransactionFilter();

      await _recalculateDashboard();

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete transaction: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> transferBetweenAccounts({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    String? description,
    DateTime? date,
    double fee = 0,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Create expense from source account
      final expenseCategory = _categories.firstWhere(
        (c) => c.name == 'Transfer' && c.type == 'expense',
        orElse: () => _categories.firstWhere((c) => c.type == 'expense'),
      );

      final incomeCategory = _categories.firstWhere(
        (c) => c.name == 'Transfer Masuk' && c.type == 'income',
        orElse: () => _categories.firstWhere((c) => c.type == 'income'),
      );

      // Expense transaction
      await createTransaction(
        type: TransactionType.expense,
        amount: amount + fee,
        categoryId: expenseCategory.id,
        accountId: fromAccountId,
        description: description ?? 'Transfer ke ${getAccountById(toAccountId)?.name ?? "akun lain"}',
        date: date ?? DateTime.now(),
      );

      // Income transaction
      await createTransaction(
        type: TransactionType.income,
        amount: amount,
        categoryId: incomeCategory.id,
        accountId: toAccountId,
        description: description ?? 'Transfer dari ${getAccountById(fromAccountId)?.name ?? "akun lain"}',
        date: date ?? DateTime.now(),
      );

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to transfer: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void setTransactionFilter(TransactionFilter filter) {
    _transactionFilter = filter;
    _applyTransactionFilter();
    notifyListeners();
  }

  void clearTransactionFilter() {
    _transactionFilter = TransactionFilter();
    _filteredTransactions.clear();
    notifyListeners();
  }

  void _applyTransactionFilter() {
    var filtered = List<TransactionModel>.from(_transactions);

    if (_transactionFilter.accountId != null) {
      filtered = filtered.where((t) => t.accountId == _transactionFilter.accountId).toList();
    }

    if (_transactionFilter.type != null) {
      filtered = filtered.where((t) => t.type == _transactionFilter.type).toList();
    }

    if (_transactionFilter.categoryId != null) {
      filtered = filtered.where((t) => t.categoryId == _transactionFilter.categoryId).toList();
    }

    if (_transactionFilter.startDate != null) {
      filtered = filtered.where((t) => t.date.isAfter(_transactionFilter.startDate!) || 
        t.date.isAtSameMomentAs(_transactionFilter.startDate!)).toList();
    }

    if (_transactionFilter.endDate != null) {
      filtered = filtered.where((t) => t.date.isBefore(_transactionFilter.endDate!) ||
        t.date.isAtSameMomentAs(_transactionFilter.endDate!)).toList();
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
        (t.tags?.any((tag) => tag.toLowerCase().contains(query)) ?? false)
      ).toList();
    }

    // Sort by date
    filtered.sort((a, b) => _transactionFilter.sortOrder == 'asc' 
      ? a.date.compareTo(b.date) 
      : b.date.compareTo(a.date));

    _filteredTransactions = filtered;
  }

  List<TransactionModel> getTransactionsByDateRange(DateTime start, DateTime end) {
    return _transactions.where((t) => 
      t.date.isAfter(start) && t.date.isBefore(end.add(const Duration(days: 1)))
    ).toList();
  }

  List<TransactionModel> getTransactionsByAccount(String accountId) {
    return _transactions.where((t) => t.accountId == accountId).toList();
  }

  Future<void> _updateAccountBalanceFromTransaction(
    String accountId, 
    TransactionType type, 
    double amount,
  ) async {
    final index = _accounts.indexWhere((a) => a.id == accountId);
    if (index == -1) return;

    final account = _accounts[index];
    final newBalance = type == TransactionType.income 
      ? account.balance + amount 
      : account.balance - amount;

    _accounts[index] = AccountModel(
      id: account.id,
      userId: account.userId,
      name: account.name,
      type: account.type,
      balance: newBalance,
      currency: account.currency,
      icon: account.icon,
      color: account.color,
      cardLastDigits: account.cardLastDigits,
      isActive: account.isActive,
      includeInTotal: account.includeInTotal,
      createdAt: account.createdAt,
      updatedAt: DateTime.now(),
    );

    _calculateTotalBalance();
  }

  // ==================== CATEGORIES CRUD ====================

  List<CategoryModel> get categories => _categories;
  List<CategoryModel> get incomeCategories => _incomeCategories;
  List<CategoryModel> get expenseCategories => _expenseCategories;

  Future<CategoryModel?> createCategory({
    required String name,
    required CategoryType type,
    String? icon,
    String? color,
    String? parentId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final category = CategoryModel(
        id: _uuid.v4(),
        userId: _currentUser?.id,
        name: name,
        type: type,
        icon: icon ?? 'folder',
        color: color ?? '#6366F1',
        parentId: parentId,
        isSystem: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _categories.add(category);

      if (type == CategoryType.income) {
        _incomeCategories.add(category);
      } else {
        _expenseCategories.add(category);
      }

      notifyListeners();
      return category;
    } catch (e) {
      _setError('Failed to create category: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<CategoryModel?> updateCategory({
    required String categoryId,
    String? name,
    String? icon,
    String? color,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final index = _categories.indexWhere((c) => c.id == categoryId);
      if (index == -1) {
        _setError('Category not found');
        return null;
      }

      final oldCategory = _categories[index];
      
      if (oldCategory.isSystem) {
        _setError('Cannot modify system category');
        return null;
      }

      final updatedCategory = CategoryModel(
        id: oldCategory.id,
        userId: oldCategory.userId,
        name: name ?? oldCategory.name,
        type: oldCategory.type,
        icon: icon ?? oldCategory.icon,
        color: color ?? oldCategory.color,
        parentId: oldCategory.parentId,
        isSystem: oldCategory.isSystem,
        createdAt: oldCategory.createdAt,
        updatedAt: DateTime.now(),
      );

      _categories[index] = updatedCategory;

      // Update in type-specific lists
      _incomeCategories = _categories.where((c) => c.type == 'income').toList();
      _expenseCategories = _categories.where((c) => c.type == 'expense').toList();

      notifyListeners();
      return updatedCategory;
    } catch (e) {
      _setError('Failed to update category: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteCategory(String categoryId) async {
    _setLoading(true);
    _clearError();

    try {
      final index = _categories.indexWhere((c) => c.id == categoryId);
      if (index == -1) {
        _setError('Category not found');
        return false;
      }

      final category = _categories[index];
      
      if (category.isSystem) {
        _setError('Cannot delete system category');
        return false;
      }

      _categories.removeAt(index);
      _incomeCategories = _categories.where((c) => c.type == 'income').toList();
      _expenseCategories = _categories.where((c) => c.type == 'expense').toList();

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete category: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  CategoryModel? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  List<CategoryModel> getCategoriesByType(CategoryType type) {
    return _categories.where((c) => c.type == type).toList();
  }

  // ==================== SAVINGS GOALS CRUD ====================

  List<SavingsGoalModel> get savingsGoals => _savingsGoals;
  double get totalSavingsTarget => _totalSavingsTarget;
  double get totalSavingsCurrent => _totalSavingsCurrent;
  double get overallSavingsProgress => _totalSavingsTarget > 0 
    ? (_totalSavingsCurrent / _totalSavingsTarget) * 100 
    : 0;

  Future<SavingsGoalModel?> createSavingsGoal({
    required String name,
    required double targetAmount,
    DateTime? deadline,
    String? icon,
    String? color,
    int? priority,
    double? initialAmount,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final goal = SavingsGoalModel(
        id: _uuid.v4(),
        userId: _currentUser?.id ?? '',
        name: name,
        targetAmount: targetAmount,
        currentAmount: initialAmount ?? 0,
        deadline: deadline,
        icon: icon ?? 'target',
        color: color ?? '#6366F1',
        priority: priority ?? 1,
        status: GoalStatus.active,
        contributions: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _savingsGoals.add(goal);
      _calculateSavingsTotals();

      notifyListeners();
      return goal;
    } catch (e) {
      _setError('Failed to create savings goal: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<SavingsGoalModel?> updateSavingsGoal({
    required String goalId,
    String? name,
    double? targetAmount,
    DateTime? deadline,
    String? icon,
    String? color,
    int? priority,
    GoalStatus? status,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final index = _savingsGoals.indexWhere((g) => g.id == goalId);
      if (index == -1) {
        _setError('Savings goal not found');
        return null;
      }

      final goal = _savingsGoals[index];
      final updatedGoal = SavingsGoalModel(
        id: goal.id,
        userId: goal.userId,
        name: name ?? goal.name,
        targetAmount: targetAmount ?? goal.targetAmount,
        currentAmount: goal.currentAmount,
        deadline: deadline ?? goal.deadline,
        icon: icon ?? goal.icon,
        color: color ?? goal.color,
        priority: priority ?? goal.priority,
        status: status ?? goal.status,
        contributions: goal.contributions,
        createdAt: goal.createdAt,
        updatedAt: DateTime.now(),
      );

      _savingsGoals[index] = updatedGoal;
      _calculateSavingsTotals();

      notifyListeners();
      return updatedGoal;
    } catch (e) {
      _setError('Failed to update savings goal: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteSavingsGoal(String goalId) async {
    _setLoading(true);
    _clearError();

    try {
      _savingsGoals.removeWhere((g) => g.id == goalId);
      _calculateSavingsTotals();

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete savings goal: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<SavingsGoalModel?> contributeToGoal({
    required String goalId,
    required double amount,
    String? note,
    String? accountId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final index = _savingsGoals.indexWhere((g) => g.id == goalId);
      if (index == -1) {
        _setError('Savings goal not found');
        return null;
      }

      final goal = _savingsGoals[index];

      // Create contribution record
      final contribution = SavingsContribution(
        id: _uuid.v4(),
        amount: amount,
        date: DateTime.now(),
        note: note,
        accountId: accountId,
      );

      final newCurrentAmount = goal.currentAmount + amount;
      final isCompleted = newCurrentAmount >= goal.targetAmount;

      final updatedGoal = SavingsGoalModel(
        id: goal.id,
        userId: goal.userId,
        name: goal.name,
        targetAmount: goal.targetAmount,
        currentAmount: newCurrentAmount,
        deadline: goal.deadline,
        icon: goal.icon,
        color: goal.color,
        priority: goal.priority,
        status: isCompleted ? GoalStatus.completed : GoalStatus.active,
        contributions: [...goal.contributions, contribution],
        createdAt: goal.createdAt,
        updatedAt: DateTime.now(),
      );

      _savingsGoals[index] = updatedGoal;
      _calculateSavingsTotals();

      // Create expense transaction if account specified
      if (accountId != null) {
        final category = _categories.firstWhere(
          (c) => c.name == 'Tabungan',
          orElse: () => _categories.firstWhere((c) => c.type == 'expense'),
        );

        await createTransaction(
          type: TransactionType.expense,
          amount: amount,
          categoryId: category.id,
          accountId: accountId,
          description: 'Kontribusi ${goal.name}',
          date: DateTime.now(),
        );
      }

      notifyListeners();
      return updatedGoal;
    } catch (e) {
      _setError('Failed to contribute to goal: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> withdrawFromGoal({
    required String goalId,
    required double amount,
    String? note,
    String? accountId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final index = _savingsGoals.indexWhere((g) => g.id == goalId);
      if (index == -1) {
        _setError('Savings goal not found');
        return false;
      }

      final goal = _savingsGoals[index];

      if (amount > goal.currentAmount) {
        _setError('Insufficient funds in goal');
        return false;
      }

      final updatedGoal = SavingsGoalModel(
        id: goal.id,
        userId: goal.userId,
        name: goal.name,
        targetAmount: goal.targetAmount,
        currentAmount: goal.currentAmount - amount,
        deadline: goal.deadline,
        icon: goal.icon,
        color: goal.color,
        priority: goal.priority,
        status: GoalStatus.active,
        contributions: goal.contributions,
        createdAt: goal.createdAt,
        updatedAt: DateTime.now(),
      );

      _savingsGoals[index] = updatedGoal;
      _calculateSavingsTotals();

      // Create income transaction if account specified
      if (accountId != null) {
        final category = _categories.firstWhere(
          (c) => c.name == 'Tabungan',
          orElse: () => _categories.firstWhere((c) => c.type == 'income'),
        );

        await createTransaction(
          type: TransactionType.income,
          amount: amount,
          categoryId: category.id,
          accountId: accountId,
          description: 'Penarikan ${goal.name}',
          date: DateTime.now(),
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to withdraw from goal: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _calculateSavingsTotals() {
    _totalSavingsTarget = _savingsGoals
        .where((g) => g.status == GoalStatus.active)
        .fold(0.0, (sum, g) => sum + g.targetAmount);
    
    _totalSavingsCurrent = _savingsGoals
        .where((g) => g.status == GoalStatus.active)
        .fold(0.0, (sum, g) => sum + g.currentAmount);
  }

  SavingsGoalModel? getSavingsGoalById(String id) {
    try {
      return _savingsGoals.firstWhere((g) => g.id == id);
    } catch (e) {
      return null;
    }
  }

  List<SavingsGoalModel> getActiveGoals() {
    return _savingsGoals.where((g) => g.status == GoalStatus.active).toList();
  }

  List<SavingsGoalModel> getCompletedGoals() {
    return _savingsGoals.where((g) => g.status == GoalStatus.completed).toList();
  }

  // ==================== PORTFOLIO CRUD ====================

  List<PortfolioHoldingModel> get portfolioHoldings => _portfolioHoldings;
  double get totalPortfolioValue => _totalPortfolioValue;
  double get totalPortfolioInvested => _totalPortfolioInvested;
  double get totalPortfolioProfitLoss => _totalPortfolioProfitLoss;
  double get totalPortfolioReturnPercent => _totalPortfolioReturnPercent;

  Future<PortfolioHoldingModel?> addStock({
    required String symbol,
    required String companyName,
    required double shares,
    required double buyPrice,
    DateTime? buyDate,
    String? sector,
    String? exchange,
    double? fees,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Check if holding already exists
      final existingIndex = _portfolioHoldings.indexWhere(
        (h) => h.symbol == symbol.toUpperCase(),
      );

      if (existingIndex != -1) {
        // Update existing holding with average price
        return await buyMoreStock(
          symbol: symbol,
          additionalShares: shares,
          price: buyPrice,
          date: buyDate,
          fees: fees,
        );
      }

      final totalCost = (shares * buyPrice) + (fees ?? 0);

      final holding = PortfolioHoldingModel(
        id: _uuid.v4(),
        userId: _currentUser?.id ?? '',
        symbol: symbol.toUpperCase(),
        companyName: companyName,
        shares: shares,
        averagePrice: buyPrice,
        currentPrice: buyPrice,
        sector: sector,
        exchange: exchange ?? 'IDX',
        totalInvested: totalCost,
        totalValue: totalCost,
        profitLoss: 0,
        profitLossPercent: 0,
        lastUpdated: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _portfolioHoldings.add(holding);
      _calculatePortfolioTotals();

      notifyListeners();
      return holding;
    } catch (e) {
      _setError('Failed to add stock: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<PortfolioHoldingModel?> buyMoreStock({
    required String symbol,
    required double additionalShares,
    required double price,
    DateTime? date,
    double? fees,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final index = _portfolioHoldings.indexWhere(
        (h) => h.symbol == symbol.toUpperCase(),
      );

      if (index == -1) {
        _setError('Stock not found in portfolio');
        return null;
      }

      final holding = _portfolioHoldings[index];
      
      // Calculate new average price
      final totalOldCost = holding.shares * holding.averagePrice;
      final totalNewCost = additionalShares * price + (fees ?? 0);
      final totalShares = holding.shares + additionalShares;
      final newAveragePrice = (totalOldCost + totalNewCost) / totalShares;
      final newTotalInvested = holding.totalInvested + totalNewCost;

      final updatedHolding = PortfolioHoldingModel(
        id: holding.id,
        userId: holding.userId,
        symbol: holding.symbol,
        companyName: holding.companyName,
        shares: totalShares,
        averagePrice: newAveragePrice,
        currentPrice: holding.currentPrice,
        sector: holding.sector,
        exchange: holding.exchange,
        totalInvested: newTotalInvested,
        totalValue: totalShares * holding.currentPrice,
        profitLoss: (totalShares * holding.currentPrice) - newTotalInvested,
        profitLossPercent: ((totalShares * holding.currentPrice - newTotalInvested) / newTotalInvested) * 100,
        lastUpdated: DateTime.now(),
        createdAt: holding.createdAt,
        updatedAt: DateTime.now(),
      );

      _portfolioHoldings[index] = updatedHolding;
      _calculatePortfolioTotals();

      notifyListeners();
      return updatedHolding;
    } catch (e) {
      _setError('Failed to buy more stock: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<PortfolioHoldingModel?> sellStock({
    required String symbol,
    required double shares,
    required double price,
    DateTime? date,
    double? fees,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final index = _portfolioHoldings.indexWhere(
        (h) => h.symbol == symbol.toUpperCase(),
      );

      if (index == -1) {
        _setError('Stock not found in portfolio');
        return null;
      }

      final holding = _portfolioHoldings[index];

      if (shares > holding.shares) {
        _setError('Insufficient shares');
        return null;
      }

      final saleValue = (shares * price) - (fees ?? 0);
      final remainingShares = holding.shares - shares;

      if (remainingShares == 0) {
        // Remove holding completely
        _portfolioHoldings.removeAt(index);
      } else {
        // Update holding
        // Proportionally reduce total invested
        final proportionSold = shares / holding.shares;
        final investedReduction = holding.totalInvested * proportionSold;

        final updatedHolding = PortfolioHoldingModel(
          id: holding.id,
          userId: holding.userId,
          symbol: holding.symbol,
          companyName: holding.companyName,
          shares: remainingShares,
          averagePrice: holding.averagePrice, // Average doesn't change
          currentPrice: holding.currentPrice,
          sector: holding.sector,
          exchange: holding.exchange,
          totalInvested: holding.totalInvested - investedReduction,
          totalValue: remainingShares * holding.currentPrice,
          profitLoss: (remainingShares * holding.currentPrice) - (holding.totalInvested - investedReduction),
          profitLossPercent: (((remainingShares * holding.currentPrice) - (holding.totalInvested - investedReduction)) / (holding.totalInvested - investedReduction)) * 100,
          lastUpdated: DateTime.now(),
          createdAt: holding.createdAt,
          updatedAt: DateTime.now(),
        );

        _portfolioHoldings[index] = updatedHolding;
      }

      _calculatePortfolioTotals();

      notifyListeners();
      return holding;
    } catch (e) {
      _setError('Failed to sell stock: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<PortfolioHoldingModel?> updateStockPrice({
    required String symbol,
    required double newPrice,
  }) async {
    try {
      final index = _portfolioHoldings.indexWhere(
        (h) => h.symbol == symbol.toUpperCase(),
      );

      if (index == -1) {
        return null;
      }

      final holding = _portfolioHoldings[index];
      final newValue = holding.shares * newPrice;

      final updatedHolding = PortfolioHoldingModel(
        id: holding.id,
        userId: holding.userId,
        symbol: holding.symbol,
        companyName: holding.companyName,
        shares: holding.shares,
        averagePrice: holding.averagePrice,
        currentPrice: newPrice,
        sector: holding.sector,
        exchange: holding.exchange,
        totalInvested: holding.totalInvested,
        totalValue: newValue,
        profitLoss: newValue - holding.totalInvested,
        profitLossPercent: ((newValue - holding.totalInvested) / holding.totalInvested) * 100,
        lastUpdated: DateTime.now(),
        createdAt: holding.createdAt,
        updatedAt: DateTime.now(),
      );

      _portfolioHoldings[index] = updatedHolding;
      _calculatePortfolioTotals();

      notifyListeners();
      return updatedHolding;
    } catch (e) {
      _setError('Failed to update stock price: ${e.toString()}');
      return null;
    }
  }

  Future<bool> removeStock(String holdingId) async {
    _setLoading(true);
    _clearError();

    try {
      _portfolioHoldings.removeWhere((h) => h.id == holdingId);
      _calculatePortfolioTotals();

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to remove stock: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _calculatePortfolioTotals() {
    _totalPortfolioValue = _portfolioHoldings.fold(0.0, (sum, h) => sum + h.totalValue);
    _totalPortfolioInvested = _portfolioHoldings.fold(0.0, (sum, h) => sum + h.totalInvested);
    _totalPortfolioProfitLoss = _totalPortfolioValue - _totalPortfolioInvested;
    _totalPortfolioReturnPercent = _totalPortfolioInvested > 0 
      ? (_totalPortfolioProfitLoss / _totalPortfolioInvested) * 100 
      : 0;
  }

  PortfolioHoldingModel? getHoldingBySymbol(String symbol) {
    try {
      return _portfolioHoldings.firstWhere(
        (h) => h.symbol == symbol.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

  List<PortfolioHoldingModel> getTopPerformers({int limit = 3}) {
    final sorted = List<PortfolioHoldingModel>.from(_portfolioHoldings)
      ..sort((a, b) => b.profitLossPercent.compareTo(a.profitLossPercent));
    return sorted.take(limit).toList();
  }

  List<PortfolioHoldingModel> getWorstPerformers({int limit = 3}) {
    final sorted = List<PortfolioHoldingModel>.from(_portfolioHoldings)
      ..sort((a, b) => a.profitLossPercent.compareTo(b.profitLossPercent));
    return sorted.take(limit).toList();
  }

  Map<String, double> getSectorAllocation() {
    final allocation = <String, double>{};
    
    for (final holding in _portfolioHoldings) {
      final sector = holding.sector ?? 'Lainnya';
      allocation[sector] = (allocation[sector] ?? 0) + holding.totalValue;
    }

    return allocation;
  }

  // ==================== WATCHLIST CRUD ====================

  List<WatchlistItemModel> get watchlist => _watchlist;

  Future<WatchlistItemModel?> addToWatchlist({
    required String symbol,
    String? companyName,
    double? targetPrice,
    String? notes,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Check if already in watchlist
      if (_watchlist.any((w) => w.symbol == symbol.toUpperCase())) {
        _setError('Symbol already in watchlist');
        return null;
      }

      final item = WatchlistItemModel(
        id: _uuid.v4(),
        userId: _currentUser?.id ?? '',
        symbol: symbol.toUpperCase(),
        companyName: companyName ?? symbol.toUpperCase(),
        targetPrice: targetPrice,
        notes: notes,
        alertEnabled: targetPrice != null,
        addedAt: DateTime.now(),
      );

      _watchlist.add(item);

      notifyListeners();
      return item;
    } catch (e) {
      _setError('Failed to add to watchlist: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<WatchlistItemModel?> updateWatchlistItem({
    required String itemId,
    double? targetPrice,
    String? notes,
    bool? alertEnabled,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final index = _watchlist.indexWhere((w) => w.id == itemId);
      if (index == -1) {
        _setError('Watchlist item not found');
        return null;
      }

      final item = _watchlist[index];
      final updatedItem = WatchlistItemModel(
        id: item.id,
        userId: item.userId,
        symbol: item.symbol,
        companyName: item.companyName,
        targetPrice: targetPrice ?? item.targetPrice,
        notes: notes ?? item.notes,
        alertEnabled: alertEnabled ?? item.alertEnabled,
        lastPrice: item.lastPrice,
        priceChange: item.priceChange,
        priceChangePercent: item.priceChangePercent,
        addedAt: item.addedAt,
        updatedAt: DateTime.now(),
      );

      _watchlist[index] = updatedItem;

      notifyListeners();
      return updatedItem;
    } catch (e) {
      _setError('Failed to update watchlist item: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> removeFromWatchlist(String itemId) async {
    _setLoading(true);
    _clearError();

    try {
      _watchlist.removeWhere((w) => w.id == itemId);

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to remove from watchlist: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> isInWatchlist(String symbol) async {
    return _watchlist.any((w) => w.symbol == symbol.toUpperCase());
  }

  // ==================== DASHBOARD & STATISTICS ====================

  DashboardModel? get dashboardData => _dashboardData;
  List<CashflowData> get cashflowData => _cashflowData;
  List<NetWorthData> get netWorthHistory => _netWorthHistory;
  List<FinancialInsight> get insights => _insights;

  double get monthlyIncome => _monthlyIncome;
  double get monthlyExpenses => _monthlyExpenses;
  double get savingsRate => _savingsRate;
  Map<String, double> get expensesByCategory => _expensesByCategory;
  Map<String, double> get incomeByCategory => _incomeByCategory;

  Future<void> refreshDashboard() async {
    _setLoading(true);
    _clearError();

    try {
      await _recalculateDashboard();
      await _calculateStatistics();
      await _generateInsights();

      notifyListeners();
    } catch (e) {
      _setError('Failed to refresh dashboard: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _recalculateDashboard() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    // Get this month's transactions
    final monthlyTransactions = getTransactionsByDateRange(startOfMonth, endOfMonth);

    // Calculate monthly income and expenses
    _monthlyIncome = monthlyTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    _monthlyExpenses = monthlyTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    final netFlow = _monthlyIncome - _monthlyExpenses;
    _savingsRate = _monthlyIncome > 0 ? (netFlow / _monthlyIncome) * 100 : 0;

    // Calculate category breakdown
    _expensesByCategory = {};
    _incomeByCategory = {};

    for (final transaction in monthlyTransactions) {
      final category = getCategoryById(transaction.categoryId);
      final categoryName = category?.name ?? 'Lainnya';

      if (transaction.type == TransactionType.income) {
        _incomeByCategory[categoryName] = 
            (_incomeByCategory[categoryName] ?? 0) + transaction.amount;
      } else {
        _expensesByCategory[categoryName] = 
            (_expensesByCategory[categoryName] ?? 0) + transaction.amount;
      }
    }

    // Update dashboard data
    _dashboardData = DashboardModel(
      totalBalance: _totalBalance,
      monthlyIncome: _monthlyIncome,
      monthlyExpenses: _monthlyExpenses,
      netFlow: netFlow,
      totalSavings: _totalSavingsCurrent,
      savingsTarget: _totalSavingsTarget,
      savingsProgress: overallSavingsProgress,
      portfolioValue: _totalPortfolioValue,
      portfolioChange: _totalPortfolioProfitLoss,
      portfolioChangePercent: _totalPortfolioReturnPercent,
      lastUpdated: DateTime.now(),
    );

    // Calculate cashflow data for chart (last 6 months)
    _cashflowData = await _calculateCashflowData(6);

    // Calculate net worth history
    _netWorthHistory = await _calculateNetWorthHistory();
  }

  Future<void> _calculateStatistics() async {
    // Statistics are already calculated in _recalculateDashboard
  }

  Future<void> _generateInsights() async {
    _insights = [];

    // Spending insights
    if (_expensesByCategory.isNotEmpty) {
      final topCategory = _expensesByCategory.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      
      _insights.add(FinancialInsight(
        id: _uuid.v4(),
        type: InsightType.spending,
        title: 'Pengeluaran Tertinggi',
        description: 'Kategori "${topCategory.key}" memiliki pengeluaran tertinggi bulan ini sebesar ${_formatCurrency(topCategory.value)}',
        priority: InsightPriority.medium,
        createdAt: DateTime.now(),
      ));
    }

    // Savings insights
    if (_savingsRate < 20 && _monthlyIncome > 0) {
      _insights.add(FinancialInsight(
        id: _uuid.v4(),
        type: InsightType.savings,
        title: 'Tingkat Tabungan Rendah',
        description: 'Tingkat tabungan Anda bulan ini ${_savingsRate.toStringAsFixed(1)}%. Idealnya minimal 20% dari penghasilan.',
        priority: InsightPriority.high,
        createdAt: DateTime.now(),
      ));
    } else if (_savingsRate >= 20 && _monthlyIncome > 0) {
      _insights.add(FinancialInsight(
        id: _uuid.v4(),
        type: InsightType.savings,
        title: 'Tabungan Sehat! 🎉',
        description: 'Tingkat tabungan Anda ${_savingsRate.toStringAsFixed(1)}% bulan ini. Pertahankan!',
        priority: InsightPriority.low,
        createdAt: DateTime.now(),
      ));
    }

    // Portfolio insights
    if (_portfolioHoldings.isNotEmpty) {
      if (_totalPortfolioProfitLoss > 0) {
        _insights.add(FinancialInsight(
          id: _uuid.v4(),
          type: InsightType.investment,
          title: 'Portfolio Menguntungkan',
          description: 'Portofolio saham Anda untung ${_formatCurrency(_totalPortfolioProfitLoss)} (${_totalPortfolioReturnPercent.toStringAsFixed(2)}%)',
          priority: InsightPriority.medium,
          createdAt: DateTime.now(),
        ));
      } else if (_totalPortfolioProfitLoss < 0) {
        _insights.add(FinancialInsight(
          id: _uuid.v4(),
          type: InsightType.investment,
          title: 'Portfolio Minus',
          description: 'Portofolio saham Anda rugi ${_formatCurrency(_totalPortfolioProfitLoss.abs())}. Jangan panik, tetap pantau.',
          priority: InsightPriority.medium,
          createdAt: DateTime.now(),
        ));
      }
    }

    // Savings goal insights
    final activeGoals = getActiveGoals();
    for (final goal in activeGoals) {
      final progress = (goal.currentAmount / goal.targetAmount) * 100;
      if (progress >= 75 && progress < 100) {
        _insights.add(FinancialInsight(
          id: _uuid.v4(),
          type: InsightType.goal,
          title: '${goal.name} Hampir Tercapai!',
          description: 'Anda sudah mencapai ${progress.toStringAsFixed(0)}% dari target ${goal.name}. Lanjutkan!',
          priority: InsightPriority.medium,
          data: {'goalId': goal.id},
          createdAt: DateTime.now(),
        ));
      }
    }
  }

  Future<List<CashflowData>> _calculateCashflowData(int months) async {
    final data = <CashflowData>[];
    final now = DateTime.now();

    for (int i = months - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final endOfMonth = DateTime(now.year, now.month - i + 1, 0);
      
      final monthTransactions = getTransactionsByDateRange(month, endOfMonth);
      
      final income = monthTransactions
          .where((t) => t.type == TransactionType.income)
          .fold(0.0, (sum, t) => sum + t.amount);
      
      final expense = monthTransactions
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (sum, t) => sum + t.amount);

      data.add(CashflowData(
        month: month,
        income: income,
        expense: expense,
        netFlow: income - expense,
      ));
    }

    return data;
  }

  Future<List<NetWorthData>> _calculateNetWorthHistory() async {
    final data = <NetWorthData>[];
    final now = DateTime.now();

    // Last 6 months history
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      
      data.add(NetWorthData(
        date: month,
        totalAssets: _totalBalance + _totalPortfolioValue + _totalSavingsCurrent,
        totalLiabilities: 0,
        netWorth: _totalBalance + _totalPortfolioValue + _totalSavingsCurrent,
      ));
    }

    return data;
  }

  // ==================== SETTINGS ====================

  SettingsModel get settings => _settings;

  Future<void> updateSettings(SettingsModel newSettings) async {
    _setLoading(true);

    try {
      _settings = newSettings;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateTheme(String theme) async {
    _settings = SettingsModel(
      theme: theme,
      currency: _settings.currency,
      language: _settings.language,
      dateFormat: _settings.dateFormat,
      notificationsEnabled: _settings.notificationsEnabled,
      biometricEnabled: _settings.biometricEnabled,
    );
    notifyListeners();
  }

  Future<void> updateCurrency(String currency) async {
    _settings = SettingsModel(
      theme: _settings.theme,
      currency: currency,
      language: _settings.language,
      dateFormat: _settings.dateFormat,
      notificationsEnabled: _settings.notificationsEnabled,
      biometricEnabled: _settings.biometricEnabled,
    );
    notifyListeners();
  }

  // ==================== SYNC ====================

  SyncStatus get syncStatus => _syncStatus;
  DateTime? get lastSyncTime => _lastSyncTime;
  int get pendingChanges => _pendingChanges;

  Future<void> syncData() async {
    if (_syncStatus == SyncStatus.syncing) return;

    _syncStatus = SyncStatus.syncing;
    notifyListeners();

    try {
      // Simulate sync
      await Future.delayed(const Duration(seconds: 2));

      _lastSyncTime = DateTime.now();
      _pendingChanges = 0;
      _syncStatus = SyncStatus.synced;

      notifyListeners();
    } catch (e) {
      _syncStatus = SyncStatus.error;
      _setError('Sync failed: ${e.toString()}');
      notifyListeners();
    }
  }

  void addPendingChange() {
    _pendingChanges++;
    notifyListeners();
  }

  void setOfflineMode() {
    _syncStatus = SyncStatus.offline;
    notifyListeners();
  }

  // ==================== USER PROFILE ====================

  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      if (_currentUser == null) {
        _setError('User not found');
        return false;
      }

      _currentUser = UserModel(
        id: _currentUser!.id,
        email: _currentUser!.email,
        fullName: fullName ?? _currentUser!.fullName,
        avatarUrl: avatarUrl ?? _currentUser!.avatarUrl,
        phone: phone ?? _currentUser!.phone,
        emailVerified: _currentUser!.emailVerified,
        createdAt: _currentUser!.createdAt,
        updatedAt: DateTime.now(),
      );

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update profile: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      // In real app, verify current password and update
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to change password: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteAccount(String password) async {
    _setLoading(true);
    _clearError();

    try {
      await Future.delayed(const Duration(seconds: 1));
      
      // Clear all user data
      _accounts.clear();
      _transactions.clear();
      _savingsGoals.clear();
      _portfolioHoldings.clear();
      _watchlist.clear();
      
      // Logout
      await logout();

      return true;
    } catch (e) {
      _setError('Failed to delete account: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==================== UTILITY METHODS ====================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)}jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)}rb';
    }
    return 'Rp ${amount.toStringAsFixed(0)}';
  }

  String _getDefaultIconForType(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return 'wallet';
      case AccountType.bank:
        return 'account_balance';
      case AccountType.ewallet:
        return 'phone_android';
      case AccountType.savings:
        return 'savings';
      case AccountType.investment:
        return 'trending_up';
      default:
        return 'account_balance_wallet';
    }
  }

  String _getDefaultColorForType(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return '#10B981';
      case AccountType.bank:
        return '#2563EB';
      case AccountType.ewallet:
        return '#8B5CF6';
      case AccountType.savings:
        return '#F59E0B';
      case AccountType.investment:
        return '#EC4899';
      default:
        return '#6366F1';
    }
  }

  List<CategoryModel> _getDefaultCategories() {
    return [
      // Income categories
      CategoryModel(
        id: _uuid.v4(),
        name: 'Gaji',
        type: CategoryType.income,
        icon: 'briefcase',
        color: '#10B981',
        isSystem: true,
        createdAt: DateTime.now(),
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Freelance',
        type: CategoryType.income,
        icon: 'laptop',
        color: '#F59E0B',
        isSystem: true,
        createdAt: DateTime.now(),
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Investasi',
        type: CategoryType.income,
        icon: 'trending_up',
        color: '#6366F1',
        isSystem: true,
        createdAt: DateTime.now(),
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Hadiah',
        type: CategoryType.income,
        icon: 'gift',
        color: '#EC4899',
        isSystem: true,
        createdAt: DateTime.now(),
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Saldo Awal',
        type: CategoryType.income,
        icon: 'play_arrow',
        color: '#06B6D4',
        isSystem: true,
        createdAt: DateTime.now(),
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Transfer Masuk',
        type: CategoryType.income,
        icon: 'call_received',
        color: '#14B8A6',
        isSystem: true,
        createdAt: DateTime.now(),
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Lainnya',
        type: CategoryType.income,
        icon: 'plus_circle',
        color: '#94A3B8',
        isSystem: true,
        createdAt: DateTime.now(),
      ),
      // Expense categories
      CategoryModel(
        id: _uuid.v4(),
        name: 'Makanan & Minuman',
        type: CategoryType.expense,
        icon: 'restaurant',
        color: '#EF4444',
        isSystem: true,
        createdAt: DateTime.now(),
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Transportasi',
        type: CategoryType.expense,
        icon: 'directions_car',
        color: '#F59E0B',
        isSystem: true,
        createdAt: DateTime.now(),
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Belanja',
        type: CategoryType.expense,
        icon: 'shopping_bag',
        color: '#10B981',
        isSystem: true,
        createdAt: DateTime.now(),
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Hiburan',
        type: CategoryType.expense,
        icon: 'movie',
        color: '#8B5CF6',
        isSystem: true,
        createdAt: DateTime.now(),
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Kesehatan',
        type: CategoryType.expense,
        icon: 'favorite',
        color: '#EC4899',
        isSystem: true,
        createdAt: DateTime.now(),
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Pendidikan',
        type: CategoryType.expense,
        icon: 'school',
        color: '#06B6D4',
        isSystem: true,
        createdAt: DateTime.now(),
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Tagihan',
        type: CategoryType.expense,
        icon: 'receipt',
        color: '#6366F1',
        isSystem: true,
        createdAt: DateTime.now(),
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Tabungan',
        type: CategoryType.expense,
        icon: 'savings',
        color: '#14B8A6',
        isSystem: true,
        createdAt: DateTime.now(),
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Transfer',
        type: CategoryType.expense,
        icon: 'call_made',
        color: '#F97316',
        isSystem: true,
        createdAt: DateTime.now(),
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Lainnya',
        type: CategoryType.expense,
        icon: 'more_horiz',
        color: '#94A3B8',
        isSystem: true,
        createdAt: DateTime.now(),
      ),
    ];
  }

  // ==================== EXPORT/IMPORT ====================

  Map<String, dynamic> exportData() {
    return {
      'version': '1.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'user': _currentUser?.toJson(),
      'accounts': _accounts.map((a) => a.toJson()).toList(),
      'transactions': _transactions.map((t) => t.toJson()).toList(),
      'categories': _categories.map((c) => c.toJson()).toList(),
      'savingsGoals': _savingsGoals.map((g) => g.toJson()).toList(),
      'portfolio': _portfolioHoldings.map((h) => h.toJson()).toList(),
      'watchlist': _watchlist.map((w) => w.toJson()).toList(),
      'settings': _settings.toJson(),
    };
  }

  Future<bool> importData(Map<String, dynamic> data) async {
    _setLoading(true);
    _clearError();

    try {
      // Validate version
      if (data['version'] == null) {
        _setError('Invalid data format');
        return false;
      }

      // Import accounts
      if (data['accounts'] != null) {
        _accounts = (data['accounts'] as List)
            .map((a) => AccountModel.fromJson(a))
            .toList();
      }

      // Import transactions
      if (data['transactions'] != null) {
        _transactions = (data['transactions'] as List)
            .map((t) => TransactionModel.fromJson(t))
            .toList();
      }

      // Import categories
      if (data['categories'] != null) {
        _categories = (data['categories'] as List)
            .map((c) => CategoryModel.fromJson(c))
            .toList();
        _incomeCategories = _categories.where((c) => c.type == 'income').toList();
        _expenseCategories = _categories.where((c) => c.type == 'expense').toList();
      }

      // Import savings goals
      if (data['savingsGoals'] != null) {
        _savingsGoals = (data['savingsGoals'] as List)
            .map((g) => SavingsGoalModel.fromJson(g))
            .toList();
      }

      // Import portfolio
      if (data['portfolio'] != null) {
        _portfolioHoldings = (data['portfolio'] as List)
            .map((h) => PortfolioHoldingModel.fromJson(h))
            .toList();
      }

      // Import watchlist
      if (data['watchlist'] != null) {
        _watchlist = (data['watchlist'] as List)
            .map((w) => WatchlistItemModel.fromJson(w))
            .toList();
      }

      // Recalculate totals
      _calculateTotalBalance();
      _calculateSavingsTotals();
      _calculatePortfolioTotals();
      await _recalculateDashboard();

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to import data: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==================== CLEANUP ====================

  @override
  void dispose() {
    _accounts.clear();
    _transactions.clear();
    _filteredTransactions.clear();
    _categories.clear();
    _incomeCategories.clear();
    _expenseCategories.clear();
    _savingsGoals.clear();
    _portfolioHoldings.clear();
    _watchlist.clear();
    _cashflowData.clear();
    _netWorthHistory.clear();
    _insights.clear();
    super.dispose();
  }
}

// ==================== FILTER & ENUM CLASSES ====================

enum SyncStatus { idle, syncing, synced, error, offline }

class TransactionFilter {
  String? accountId;
  TransactionType? type;
  String? categoryId;
  DateTime? startDate;
  DateTime? endDate;
  double? minAmount;
  double? maxAmount;
  String? searchQuery;
  String sortBy;
  String sortOrder;

  TransactionFilter({
    this.accountId,
    this.type,
    this.categoryId,
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
    this.searchQuery,
    this.sortBy = 'date',
    this.sortOrder = 'desc',
  });

  void clear() {
    accountId = null;
    type = null;
    categoryId = null;
    startDate = null;
    endDate = null;
    minAmount = null;
    maxAmount = null;
    searchQuery = null;
    sortBy = 'date';
    sortOrder = 'desc';
  }

  bool get hasActiveFilters {
    return accountId != null ||
        type != null ||
        categoryId != null ||
        startDate != null ||
        endDate != null ||
        minAmount != null ||
        maxAmount != null ||
        (searchQuery != null && searchQuery!.isNotEmpty);
  }
}
