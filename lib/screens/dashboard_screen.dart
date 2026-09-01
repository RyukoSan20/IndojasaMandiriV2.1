import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../models/savings_goal.dart';
import '../models/portfolio_item.dart';
import '../services/api_service.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';
import '../widgets/account_card.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/savings_goal_card.dart';
import '../widgets/portfolio_summary_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/balance_trend_chart.dart';
import '../widgets/expense_category_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _isRefreshing = false;
  String _selectedTimeRange = '30d';

  List<Account> _accounts = [];
  List<Transaction> _recentTransactions = [];
  List<SavingsGoal> _savingsGoals = [];
  List<PortfolioItem> _portfolioItems = [];

  double _totalBalance = 0.0;
  double _monthlyIncome = 0.0;
  double _monthlyExpenses = 0.0;
  double _portfolioValue = 0.0;
  double _portfolioChange = 0.0;
  double _portfolioChangePercent = 0.0;

  final Map<String, double> _expensesByCategory = {};

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
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        ApiService.getAccounts(),
        ApiService.getRecentTransactions(limit: 10),
        ApiService.getSavingsGoals(),
        ApiService.getPortfolioItems(),
        ApiService.getMonthlySummary(),
        ApiService.getBalanceHistory(timeRange: _selectedTimeRange),
        ApiService.getExpenseCategories(),
      ]);

      if (mounted) {
        setState(() {
          _accounts = results[0] as List<Account>;
          _recentTransactions = results[1] as List<Transaction>;
          _savingsGoals = results[2] as List<SavingsGoal>;
          _portfolioItems = results[3] as List<PortfolioItem>;

          final monthlySummary = results[4] as Map<String, dynamic>;
          _totalBalance = monthlySummary['totalBalance'] ?? 0.0;
          _monthlyIncome = monthlySummary['income'] ?? 0.0;
          _monthlyExpenses = monthlySummary['expenses'] ?? 0.0;

          final portfolioSummary = results[5] as Map<String, dynamic>;
          _portfolioValue = portfolioSummary['value'] ?? 0.0;
          _portfolioChange = portfolioSummary['change'] ?? 0.0;
          _portfolioChangePercent = portfolioSummary['changePercent'] ?? 0.0;

          _expensesByCategory.clear();
          final categories = results[6] as Map<String, dynamic>;
          categories.forEach((key, value) {
            _expensesByCategory[key] = (value as num).toDouble();
          });

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Failed to load dashboard data');
      }
    }
  }

  Future<void> _refreshDashboardData() async {
    setState(() {
      _isRefreshing = true;
    });

    await _loadDashboardData();

    if (mounted) {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _loadDashboardData,
        ),
      ),
    );
  }

  void _navigateToAddTransaction() {
    Navigator.pushNamed(context, '/add-transaction');
  }

  void _navigateToAccounts() {
    Navigator.pushNamed(context, '/accounts');
  }

  void _navigateToSavingsGoals() {
    Navigator.pushNamed(context, '/savings-goals');
  }

  void _navigateToPortfolio() {
    Navigator.pushNamed(context, '/portfolio');
  }

  void _navigateToAnalytics() {
    Navigator.pushNamed(context, '/analytics');
  }

  void _onTimeRangeChanged(String range) {
    setState(() {
      _selectedTimeRange = range;
    });
    _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingState() : _buildDashboardContent(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FinTrack',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            DateFormat('EEEE, MMMM d').format(DateTime.now()),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: _navigateToNotifications,
          tooltip: 'Notifications',
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: _navigateToSettings,
          tooltip: 'Settings',
        ),
        const SizedBox(width: 8),
      ],
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Transactions'),
          Tab(text: 'Portfolio'),
        ],
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor:
            Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        indicatorColor: Theme.of(context).colorScheme.primary,
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
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return RefreshIndicator(
      onRefresh: _refreshDashboardData,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildTransactionsTab(),
          _buildPortfolioTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBalanceSummaryCard(),
          const SizedBox(height: 16),
          _buildQuickActionsSection(),
          const SizedBox(height: 24),
          _buildBalanceTrendSection(),
          const SizedBox(height: 24),
          _buildAccountsSection(),
          const SizedBox(height: 24),
          _buildExpenseBreakdownSection(),
          const SizedBox(height: 24),
          _buildSavingsGoalsSection(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildBalanceSummaryCard() {
    final isPositiveChange = _monthlyIncome - _monthlyExpenses >= 0;
    final netChange = _monthlyIncome - _monthlyExpenses;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Balance',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _selectedTimeRange,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(_totalBalance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.arrow_upward,
                  label: 'Income',
                  value: CurrencyFormatter.format(_monthlyIncome),
                  color: Colors.greenAccent,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.arrow_downward,
                  label: 'Expenses',
                  value: CurrencyFormatter.format(_monthlyExpenses),
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white24),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                isPositiveChange
                    ? Icons.trending_up
                    : Icons.trending_down,
                color: isPositiveChange ? Colors.greenAccent : Colors.redAccent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Net: ${CurrencyFormatter.format(netChange)}',
                style: TextStyle(
                  color: isPositiveChange
                      ? Colors.greenAccent
                      : Colors.redAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'this month',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            QuickActionButton(
              icon: Icons.add_circle_outline,
              label: 'Add',
              onTap: _navigateToAddTransaction,
            ),
            QuickActionButton(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Accounts',
              onTap: _navigateToAccounts,
            ),
            QuickActionButton(
              icon: Icons.savings_outlined,
              label: 'Savings',
              onTap: _navigateToSavingsGoals,
            ),
            QuickActionButton(
              icon: Icons.analytics_outlined,
              label: 'Analytics',
              onTap: _navigateToAnalytics,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBalanceTrendSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Balance Trend',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            _buildTimeRangeSelector(),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: BalanceTrendChart(
            timeRange: _selectedTimeRange,
            onTimeRangeChanged: _onTimeRangeChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTimeRangeChip('7d'),
          _buildTimeRangeChip('30d'),
          _buildTimeRangeChip('90d'),
          _buildTimeRangeChip('1y'),
        ],
      ),
    );
  }

  Widget _buildTimeRangeChip(String range) {
    final isSelected = _selectedTimeRange == range;
    return GestureDetector(
      onTap: () => _onTimeRangeChanged(range),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          range,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildAccountsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Accounts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: _navigateToAccounts,
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_accounts.isEmpty)
          _buildEmptyState(
            icon: Icons.account_balance_wallet_outlined,
            message: 'No accounts yet',
            actionLabel: 'Add Account',
            onAction: _navigateToAccounts,
          )
        else
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _accounts.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return AccountCard(
                  account: _accounts[index],
                  onTap: () => _navigateToAccountDetail(_accounts[index]),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildExpenseBreakdownSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Expense Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: _navigateToAnalytics,
              child: const Text('See Details'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: _expensesByCategory.isEmpty
              ? _buildEmptyState(
                  icon: Icons.pie_chart_outline,
                  message: 'No expense data',
                  actionLabel: 'Add Transactions',
                  onAction: _navigateToAddTransaction,
                )
              : ExpenseCategoryChart(
                  expensesByCategory: _expensesByCategory,
                ),
        ),
      ],
    );
  }

  Widget _buildSavingsGoalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Savings Goals',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: _navigateToSavingsGoals,
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_savingsGoals.isEmpty)
          _buildEmptyState(
            icon: Icons.savings_outlined,
            message: 'No savings goals yet',
            actionLabel: 'Create Goal',
            onAction: _navigateToSavingsGoals,
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _savingsGoals.length > 3 ? 3 : _savingsGoals.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return SavingsGoalCard(
                goal: _savingsGoals[index],
                onTap: () => _navigateToSavingsGoalDetail(_savingsGoals[index]),
              );
            },
          ),
      ],
    );
  }

  Widget _buildTransactionsTab() {
    return RefreshIndicator(
      onRefresh: _refreshDashboardData,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTransactionSummary(),
                  const SizedBox(height: 16),
                  _buildTransactionFilters(),
                ],
              ),
            ),
          ),
          if (_recentTransactions.isEmpty)
            SliverFillRemaining(
              child: _buildEmptyState(
                icon: Icons.receipt_long_outlined,
                message: 'No transactions yet',
                actionLabel: 'Add Transaction',
                onAction: _navigateToAddTransaction,
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final transaction = _recentTransactions[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: TransactionListItem(
                      transaction: transaction,
                      onTap: () =>
                          _navigateToTransactionDetail(transaction),
                    ),
                  );
                },
                childCount: _recentTransactions.length,
              ),
            ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionSummary() {
    final totalTransactions = _recentTransactions.length;
    final totalTransactionAmount = _recentTransactions.fold<double>(
      0,
      (sum, t) => sum + t.amount.abs(),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Transactions',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalTransactions',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Amount',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.format(totalTransactionAmount),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionFilters() {
    return Row(
      children: [
        _buildFilterChip('All', true),
        const SizedBox(width: 8),
        _buildFilterChip('Income', false),
        const SizedBox(width: 8),
        _buildFilterChip('Expenses', false),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        HapticFeedback.selectionClick();
      },
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildPortfolioTab() {
    return RefreshIndicator(
      onRefresh: _refreshDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPortfolioSummaryCard(),
            const SizedBox(height: 24),
            _buildPortfolioHoldingsSection(),
            const SizedBox(height: 24),
            _buildTopMoversSection(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildPortfolioSummaryCard() {
    final isPositiveChange = _portfolioChange >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.shade400,
            Colors.deepPurple.shade600,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Portfolio Value',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositiveChange
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: isPositiveChange
                          ? Colors.greenAccent
                          : Colors.redAccent,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${isPositiveChange ? '+' : ''}${_portfolioChangePercent.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: isPositiveChange
                            ? Colors.greenAccent
                            : Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(_portfolioValue),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                isPositiveChange
                    ? Icons.trending_up
                    : Icons.trending_down,
                color:
                    isPositiveChange ? Colors.greenAccent : Colors.redAccent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '${isPositiveChange ? '+' : ''}${CurrencyFormatter.format(_portfolioChange)}',
                style: TextStyle(
                  color:
                      isPositiveChange ? Colors.greenAccent : Colors.redAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'today',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildPortfolioStat(
                  label: 'Holdings',
                  value: '${_portfolioItems.length}',
                  icon: Icons.pie_chart_outline,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPortfolioStat(
                  label: 'Day\'s P/L',
                  value: CurrencyFormatter.format(_portfolioChange),
                  icon: Icons.calendar_today_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioStat({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioHoldingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Holdings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: _navigateToPortfolio,
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_portfolioItems.isEmpty)
          _buildEmptyState(
            icon: Icons.trending_up,
            message: 'No holdings yet',
            actionLabel: 'Add Stock',
            onAction: _navigateToPortfolio,
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount:
                _portfolioItems.length > 5 ? 5 : _portfolioItems.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return PortfolioSummaryCard(
                item: _portfolioItems[index],
                onTap: () =>
                    _navigateToPortfolioItemDetail(_portfolioItems[index]),
              );
            },
          ),
      ],
    );
  }

  Widget _buildTopMoversSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Movers',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: Colors.orange.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Coming Soon',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Track top gaining and losing stocks',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _showAddOptionsSheet,
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  void _showAddOptionsSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Add New',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_downward,
                      color: Colors.green,
                    ),
                  ),
                  title: const Text('Income'),
                  subtitle: const Text('Add incoming money'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToAddTransactionWithType('income');
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_upward,
                      color: Colors.red,
                    ),
                  ),
                  title: const Text('Expense'),
                  subtitle: const Text('Add outgoing money'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToAddTransactionWithType('expense');
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_balance,
                      color: Colors.blue,
                    ),
                  ),
                  title: const Text('Account'),
                  subtitle: const Text('Add a new account'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToAddAccount();
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.savings,
                      color: Colors.purple,
                    ),
                  ),
                  title: const Text('Savings Goal'),
                  subtitle: const Text('Create a new savings goal'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToAddSavingsGoal();
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToNotifications() {
    Navigator.pushNamed(context, '/notifications');
  }

  void _navigateToSettings() {
    Navigator.pushNamed(context, '/settings');
  }

  void _navigateToAccountDetail(Account account) {
    Navigator.pushNamed(context, '/account-detail', arguments: account);
  }

  void _navigateToTransactionDetail(Transaction transaction) {
    Navigator.pushNamed(context, '/transaction-detail', arguments: transaction);
  }

  void _navigateToSavingsGoalDetail(SavingsGoal goal) {
    Navigator.pushNamed(context, '/savings-goal-detail', arguments: goal);
  }

  void _navigateToPortfolioItemDetail(PortfolioItem item) {
    Navigator.pushNamed(context, '/portfolio-item-detail', arguments: item);
  }

  void _navigateToAddTransactionWithType(String type) {
    Navigator.pushNamed(
      context,
      '/add-transaction',
      arguments: {'type': type},
    );
  }

  void _navigateToAddAccount() {
    Navigator.pushNamed(context, '/add-account');
  }

  void _navigateToAddSavingsGoal() {
    Navigator.pushNamed(context, '/add-savings-goal');
  }
}
