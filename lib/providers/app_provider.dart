import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/account_model.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/savings_goal_model.dart';
import '../models/portfolio_holding_model.dart';
import '../models/watchlist_item_model.dart';
import '../models/dashboard_model.dart';

class AppProvider with ChangeNotifier {
  UserModel? _currentUser;
  List<AccountModel> _accounts = [];
  List<TransactionModel> _transactions = [];
  List<CategoryModel> _categories = [];
  List<SavingsGoalModel> _savingsGoals = [];
  List<PortfolioHoldingModel> _portfolioHoldings = [];
  List<WatchlistItemModel> _watchlist = [];

  UserModel? get currentUser => _currentUser;
  List<AccountModel> get accounts => _accounts;
  List<TransactionModel> get transactions => _transactions;
  List<CategoryModel> get categories => _categories;
  List<SavingsGoalModel> get savingsGoals => _savingsGoals;
  List<PortfolioHoldingModel> get portfolioHoldings => _portfolioHoldings;
  List<WatchlistItemModel> get watchlist => _watchlist;

  double get _totalBalance => _accounts.fold(0.0, (sum, item) => sum + item.balance);
  double get _totalPortfolioValue => _portfolioHoldings.fold(0.0, (sum, item) => sum + item.totalValue);
  double get _totalSavingsCurrent => _savingsGoals.fold(0.0, (sum, item) => sum + item.currentAmount);

  Future<bool> deleteAccount(String accountId) async {
    _accounts.removeWhere((a) => a.id == accountId);
    notifyListeners();
    return true;
  }

  void addPortfolioHolding(PortfolioHoldingModel holding) {
    _portfolioHoldings.add(holding);
    notifyListeners();
  }

  void addWatchlistItem(WatchlistItemModel item) {
    _watchlist.add(item);
    notifyListeners();
  }
}
