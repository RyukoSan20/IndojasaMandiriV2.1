import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/account.dart';
import '../models/transaction_model.dart';
import '../models/savings_goal.dart';
import '../models/stock_portfolio.dart';
import '../services/api_service.dart';
import '../widgets/account_card.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/savings_goal_card.dart';
import '../widgets/stock_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/balance_summary_card.dart';
import '../utils/currency_formatter.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;

  Map<String, dynamic>? _userProfile;
  List<Account> _accounts = [];
  List<TransactionModel> _recentTransactions = [];
  List<SavingsGoal> _savingsGoals = [];
  List<StockPortfolio> _stockPortfolio = [];
  Map<String, double> _monthlyStats = {};

  final ApiService _apiService = ApiService();
  final CurrencyFormatter _currencyFormatter = CurrencyFormatter();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    if (_isRefreshing) {
      setState(() {
        _isRefreshing = true;
      });
    } else {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final results = await Future.wait([
        _apiService.getUserProfile(),
        _apiService.getAccounts(),
        _apiService.getRecentTransactions(limit: 10),
        _apiService.getSavingsGoals(),
        _apiService.getStockPortfolio(),
        _apiService.getMonthlyStats(),
      ]);

      if (mounted) {
        setState(() {
          _userProfile = results[0] as Map<String, dynamic>?;
          _accounts = results[1] as List<Account>;
          _recentTransactions = results[2] as List<TransactionModel>;
          _savingsGoals = results[3] as List<SavingsGoal>;
          _stockPortfolio = results[4] as List<StockPortfolio>;
          _monthlyStats = results[5] as Map<String, double>;
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _getErrorMessage(e);
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is PlatformException) {
      switch (error.code) {
        case 'NETWORK_ERROR':
          return 'Unable to connect. Please check your internet connection.';
        case 'AUTH_ERROR':
          return 'Session expired. Please log in again.';
        case 'SERVER_ERROR':
          return 'Server is temporarily unavailable. Please try again later.';
        default:
          return 'Something went wrong. Please try again.';
      }
    }
    return 'An unexpected error occurred.';
  }

  double get _totalBalance {
    return _accounts.fold(0.0, (sum, account) => sum + account.balance);
  }

  double get _totalSavingsProgress {
    if (_savingsGoals.isEmpty) return 0.0;
    double totalTarget = 0.0;
    double totalCurrent = 0.0;
    for (var goal in _savingsGoals) {
      totalTarget += goal.targetAmount;
      totalCurrent += goal.currentAmount;
    }
    return totalTarget > 0 ? (totalCurrent / totalTarget) * 100 : 0.0;
  }

  double get _totalPortfolioValue {
    return _stockPortfolio.fold(0.0, (sum, stock) => sum + stock.currentValue);
  }

  double get _totalPortfolioGainLoss {
    return _stockPortfolio.fold(0.0, (sum, stock) => sum + stock.gainLoss);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingState()
            : _errorMessage != null
                ? _buildErrorState()
                : _buildDashboardContent(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading your finances...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _loadDashboardData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),
                _buildBalanceSummary(),
                const SizedBox(height: 16),
                _buildQuickActions(),
                const SizedBox(height: 24),
                _buildTabSection(),
                const SizedBox(height: 16),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    final greeting = _getGreeting();
    final userName = _userProfile?['name'] ?? 'User';

    return SliverAppBar(
      floating: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          Text(
            userName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _showNotifications,
          icon: Badge(
            smallSize: 8,
            child: const Icon(Icons.notifications_outlined),
          ),
        ),
        IconButton(
          onPressed: _showSettings,
          icon: const Icon(Icons.settings_outlined),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  Widget _buildBalanceSummary() {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return BalanceSummaryCard(
      totalBalance: _totalBalance,
      formattedBalance: formatter.format(_totalBalance),
      income: _monthlyStats['income'] ?? 0.0,
      expenses: _monthlyStats['expenses'] ?? 0.0,
      onViewDetails: _navigateToAccounts,
    );
  }

  Widget _buildQuickActions() {
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          QuickActionButton(
            icon: Icons.add_circle_outline_rounded,
            label: 'Add Money',
            color: Colors.green,
            onTap: _navigateToAddMoney,
          ),
          const SizedBox(width: 12),
          QuickActionButton(
            icon: Icons.send_rounded,
            label: 'Transfer',
            color: Colors.blue,
            onTap: _navigateToTransfer,
          ),
          const SizedBox(width: 12),
          QuickActionButton(
            icon: Icons.receipt_long_outlined,
            label: 'Pay Bills',
            color: Colors.orange,
            onTap: _navigateToPayBills,
          ),
          const SizedBox(width: 12),
          QuickActionButton(
            icon: Icons.show_chart_rounded,
            label: 'Invest',
            color: Colors.purple,
            onTap: _navigateToInvest,
          ),
          const SizedBox(width: 12),
          QuickActionButton(
            icon: Icons.qr_code_scanner_rounded,
            label: 'Scan',
            color: Colors.teal,
            onTap: _navigateToScan,
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Theme.of(context).colorScheme.onPrimaryContainer,
            unselectedLabelColor:
                Theme.of(context).colorScheme.onSurfaceVariant,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'Accounts'),
              Tab(text: 'Goals'),
              Tab(text: 'Stocks'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildAccountsTab(),
              _buildSavingsGoalsTab(),
              _buildStocksTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountsTab() {
    if (_accounts.isEmpty) {
      return _buildEmptyState(
        icon: Icons.account_balance_wallet_outlined,
        title: 'No Accounts Yet',
        subtitle: 'Add your first account to start tracking',
        actionLabel: 'Add Account',
        onAction: _navigateToAddAccount,
      );
    }

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: _accounts.length + 1,
      separatorBuilder: (context, index) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        if (index == _accounts.length) {
          return _buildAddAccountCard();
        }
        return AccountCard(
          account: _accounts[index],
          onTap: () => _navigateToAccountDetails(_accounts[index]),
        );
      },
    );
  }

  Widget _buildAddAccountCard() {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          width: 2,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _navigateToAddAccount,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_rounded,
                  size: 32,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Add Account',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Link a new account',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSavingsGoalsTab() {
    if (_savingsGoals.isEmpty) {
      return _buildEmptyState(
        icon: Icons.savings_outlined,
        title: 'No Savings Goals',
        subtitle: 'Create a goal to start saving',
        actionLabel: 'Create Goal',
        onAction: _navigateToCreateGoal,
      );
    }

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: _savingsGoals.length,
      separatorBuilder: (context, index) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        return SavingsGoalCard(
          goal: _savingsGoals[index],
          onTap: () => _navigateToGoalDetails(_savingsGoals[index]),
        );
      },
    );
  }

  Widget _buildStocksTab() {
    if (_stockPortfolio.isEmpty) {
      return _buildEmptyState(
        icon: Icons.trending_up_rounded,
        title: 'No Stocks Yet',
        subtitle: 'Start investing in your future',
        actionLabel: 'Explore Stocks',
        onAction: _navigateToInvest,
      );
    }

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: _stockPortfolio.length,
      separatorBuilder: (context, index) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        return StockCard(
          stock: _stockPortfolio[index],
          onTap: () => _navigateToStockDetails(_stockPortfolio[index]),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: onAction,
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: _navigateToAllTransactions,
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_recentTransactions.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No transactions yet',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentTransactions.length.clamp(0, 5),
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return TransactionTile(
                  transaction: _recentTransactions[index],
                  onTap: () =>
                      _navigateToTransactionDetails(_recentTransactions[index]),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildInsightsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.insights_rounded,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Financial Insights',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInsightItem(
            icon: Icons.savings_rounded,
            title: 'Savings Rate',
            value: '${((_monthlyStats['income'] ?? 0) > 0 ? ((_monthlyStats['income']! - (_monthlyStats['expenses'] ?? 0)) / _monthlyStats['income']! * 100) : 0).toStringAsFixed(1)}%',
            subtitle: 'of your income saved',
          ),
          const SizedBox(height: 12),
          _buildInsightItem(
            icon: Icons.pie_chart_outline_rounded,
            title: 'Top Category',
            value: _getTopExpenseCategory(),
            subtitle: 'highest expense',
          ),
          const SizedBox(height: 12),
          _buildInsightItem(
            icon: Icons.trending_up_rounded,
            title: 'Portfolio Return',
            value: _stockPortfolio.isNotEmpty
                ? '${((_totalPortfolioGainLoss / (_totalPortfolioValue - _totalPortfolioGainLoss)) * 100).toStringAsFixed(2)}%'
                : '0.00%',
            subtitle: 'all time gain/loss',
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimaryContainer
                          .withOpacity(0.7),
                    ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
        ),
      ],
    );
  }

  String _getTopExpenseCategory() {
    final categoryTotals = <String, double>{};
    for (var transaction in _recentTransactions) {
      if (transaction.type == TransactionType.expense) {
        categoryTotals[transaction.category] =
            (categoryTotals[transaction.category] ?? 0) +
                transaction.amount.abs();
      }
    }
    if (categoryTotals.isEmpty) return 'None';
    final topCategory = categoryTotals.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );
    return topCategory.key;
  }

  void _showNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifications coming soon!')),
    );
  }

  void _showSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings coming soon!')),
    );
  }

  void _navigateToAccounts() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigating to accounts...')),
    );
  }

  void _navigateToAddMoney() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add money feature coming soon!')),
    );
  }

  void _navigateToTransfer() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transfer feature coming soon!')),
    );
  }

  void _navigateToPayBills() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bill pay feature coming soon!')),
    );
  }

  void _navigateToInvest() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invest feature coming soon!')),
    );
  }

  void _navigateToScan() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scan feature coming soon!')),
    );
  }

  void _navigateToAddAccount() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add account coming soon!')),
    );
  }

  void _navigateToAccountDetails(Account account) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing ${account.name}...')),
    );
  }

  void _navigateToCreateGoal() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create goal coming soon!')),
    );
  }

  void _navigateToGoalDetails(SavingsGoal goal) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing ${goal.name}...')),
    );
  }

  void _navigateToStockDetails(StockPortfolio stock) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing ${stock.symbol}...')),
    );
  }

  void _navigateToAllTransactions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All transactions coming soon!')),
    );
  }

  void _navigateToTransactionDetails(TransactionModel transaction) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing transaction...')),
    );
  }
}
