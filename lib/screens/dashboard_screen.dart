import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../models/savings_goal.dart';
import '../models/portfolio_stock.dart';
import '../services/finance_service.dart';
import '../widgets/account_card.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/savings_goal_card.dart';
import '../widgets/stock_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/balance_chart.dart';
import '../widgets/expense_breakdown_chart.dart';
import '../utils/formatters.dart';

class DashboardScreen extends StatefulWidget {
  final String userId;

  const DashboardScreen({
    super.key,
    required this.userId,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FinanceService _financeService = FinanceService();
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$');
  final NumberFormat _percentFormat = NumberFormat.percentPattern();

  bool _isLoading = true;
  bool _showBalances = true;

  double _totalBalance = 0.0;
  double _monthlyIncome = 0.0;
  double _monthlyExpenses = 0.0;
  double _totalInvested = 0.0;
  double _portfolioChange = 0.0;

  List<Account> _accounts = [];
  List<Transaction> _recentTransactions = [];
  List<SavingsGoal> _savingsGoals = [];
  List<PortfolioStock> _portfolioStocks = [];
  Map<String, double> _expenseCategories = {};

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _financeService.getTotalBalance(widget.userId),
        _financeService.getMonthlyIncome(widget.userId),
        _financeService.getMonthlyExpenses(widget.userId),
        _financeService.getAccounts(widget.userId),
        _financeService.getRecentTransactions(widget.userId, limit: 5),
        _financeService.getSavingsGoals(widget.userId),
        _financeService.getPortfolioStocks(widget.userId),
        _financeService.getPortfolioValue(widget.userId),
        _financeService.getPortfolioChange(widget.userId),
        _financeService.getExpenseCategories(widget.userId),
      ]);

      setState(() {
        _totalBalance = results[0] as double;
        _monthlyIncome = results[1] as double;
        _monthlyExpenses = results[2] as double;
        _accounts = results[3] as List<Account>;
        _recentTransactions = results[4] as List<Transaction>;
        _savingsGoals = results[5] as List<SavingsGoal>;
        _portfolioStocks = results[6] as List<PortfolioStock>;
        _totalInvested = results[7] as double;
        _portfolioChange = results[8] as double;
        _expenseCategories = results[9] as Map<String, double>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading dashboard: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _refreshData() async {
    await _loadDashboardData();
  }

  void _navigateToAccounts() {
    Navigator.pushNamed(context, '/accounts');
  }

  void _navigateToTransactions() {
    Navigator.pushNamed(context, '/transactions');
  }

  void _navigateToSavingsGoals() {
    Navigator.pushNamed(context, '/savings-goals');
  }

  void _navigateToPortfolio() {
    Navigator.pushNamed(context, '/portfolio');
  }

  void _navigateToAddTransaction() {
    Navigator.pushNamed(context, '/add-transaction');
  }

  void _navigateToAddAccount() {
    Navigator.pushNamed(context, '/add-account');
  }

  void _navigateToSettings() {
    Navigator.pushNamed(context, '/settings');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingState() : _buildDashboardContent(),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FinTrack',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(
            DateFormat('EEEE, MMM d').format(DateTime.now()),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(_showBalances ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _showBalances = !_showBalances),
          tooltip: _showBalances ? 'Hide balances' : 'Show balances',
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _refreshData,
          tooltip: 'Refresh',
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: _navigateToSettings,
          tooltip: 'Settings',
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading your finances...'),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceOverviewCard(),
            const SizedBox(height: 16),
            _buildQuickActions(),
            const SizedBox(height: 24),
            _buildMonthlySummary(),
            const SizedBox(height: 24),
            _buildAccountsSection(),
            const SizedBox(height: 24),
            _buildRecentTransactionsSection(),
            const SizedBox(height: 24),
            _buildSavingsGoalsSection(),
            const SizedBox(height: 24),
            _buildPortfolioSection(),
            const SizedBox(height: 24),
            _buildExpenseBreakdownSection(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceOverviewCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _totalBalance >= 0 ? Icons.trending_up : Icons.trending_down,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _showBalances
                              ? (_totalBalance >= 0 ? 'Positive' : 'Negative')
                              : '***',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _showBalances ? Formatters.formatCurrency(_totalBalance) : '\$••••••',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildBalanceStat(
                      'Income',
                      _monthlyIncome,
                      Icons.arrow_upward,
                      Colors.greenAccent,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white24,
                  ),
                  Expanded(
                    child: _buildBalanceStat(
                      'Expenses',
                      _monthlyExpenses,
                      Icons.arrow_downward,
                      Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceStat(String label, double amount, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              Text(
                _showBalances ? Formatters.formatCurrency(amount) : '\$•••',
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

  Widget _buildQuickActions() {
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          QuickActionButton(
            icon: Icons.add_circle_outline,
            label: 'Add\nTransaction',
            color: Theme.of(context).colorScheme.primary,
            onTap: _navigateToAddTransaction,
          ),
          QuickActionButton(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Add\nAccount',
            color: Colors.blue,
            onTap: _navigateToAddAccount,
          ),
          QuickActionButton(
            icon: Icons.savings_outlined,
            label: 'Savings\nGoals',
            color: Colors.green,
            onTap: _navigateToSavingsGoals,
          ),
          QuickActionButton(
            icon: Icons.show_chart,
            label: 'View\nPortfolio',
            color: Colors.purple,
            onTap: _navigateToPortfolio,
          ),
          QuickActionButton(
            icon: Icons.receipt_long_outlined,
            label: 'All\nTransactions',
            color: Colors.orange,
            onTap: _navigateToTransactions,
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySummary() {
    final savings = _monthlyIncome - _monthlyExpenses;
    final savingsRate = _monthlyIncome > 0 ? savings / _monthlyIncome : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Monthly Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: _navigateToTransactions,
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryItem(
                        'Net Savings',
                        _showBalances ? Formatters.formatCurrency(savings) : '\$•••',
                        savings >= 0 ? Colors.green : Colors.red,
                        savings >= 0 ? Icons.trending_up : Icons.trending_down,
                      ),
                    ),
                    Expanded(
                      child: _buildSummaryItem(
                        'Savings Rate',
                        _showBalances ? _percentFormat.format(savingsRate) : '••%',
                        savingsRate >= 0.2 ? Colors.green : Colors.orange,
                        Icons.percent,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                SizedBox(
                  height: 120,
                  child: BalanceChart(
                    income: _monthlyIncome,
                    expenses: _monthlyExpenses,
                    showBalances: _showBalances,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
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
              child: const Text('Manage'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_accounts.isEmpty)
          _buildEmptyState(
            'No accounts yet',
            'Add your first account to start tracking',
            Icons.account_balance_wallet_outlined,
          )
        else
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _accounts.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < _accounts.length - 1 ? 12 : 0,
                  ),
                  child: AccountCard(
                    account: _accounts[index],
                    showBalance: _showBalances,
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/account-detail',
                      arguments: _accounts[index].id,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildRecentTransactionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: _navigateToTransactions,
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_recentTransactions.isEmpty)
          _buildEmptyState(
            'No transactions yet',
            'Your recent transactions will appear here',
            Icons.receipt_long_outlined,
          )
        else
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentTransactions.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return TransactionListItem(
                  transaction: _recentTransactions[index],
                  showAmount: _showBalances,
                );
              },
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
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_savingsGoals.isEmpty)
          _buildEmptyState(
            'No savings goals',
            'Set your first savings goal to start saving',
            Icons.savings_outlined,
          )
        else
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _savingsGoals.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < _savingsGoals.length - 1 ? 12 : 0,
                  ),
                  child: SavingsGoalCard(
                    goal: _savingsGoals[index],
                    showAmount: _showBalances,
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/savings-goal-detail',
                      arguments: _savingsGoals[index].id,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildPortfolioSection() {
    final isPositiveChange = _portfolioChange >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Stock Portfolio',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: _navigateToPortfolio,
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Invested',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _showBalances
                              ? Formatters.formatCurrency(_totalInvested)
                              : '\$••••••',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: (isPositiveChange ? Colors.green : Colors.red).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isPositiveChange ? Icons.trending_up : Icons.trending_down,
                            color: isPositiveChange ? Colors.green : Colors.red,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _showBalances
                                ? '${isPositiveChange ? '+' : ''}${Formatters.formatCurrency(_portfolioChange)}'
                                : '\$•••',
                            style: TextStyle(
                              color: isPositiveChange ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_portfolioStocks.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _portfolioStocks.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: StockCard(
                            stock: _portfolioStocks[index],
                            showValue: _showBalances,
                          ),
                        );
                      },
                    ),
                  ),
                ] else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.show_chart,
                          size: 40,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No stocks in portfolio',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseBreakdownSection() {
    if (_expenseCategories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expense Breakdown',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: ExpenseBreakdownChart(
                    categories: _expenseCategories,
                    showValues: _showBalances,
                  ),
                ),
                const SizedBox(height: 16),
                ..._expenseCategories.entries.map((entry) {
                  return _buildCategoryItem(
                    entry.key,
                    entry.value,
                    _monthlyExpenses > 0 ? entry.value / _monthlyExpenses : 0,
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(String category, double amount, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getCategoryColor(category),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              category,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            _showBalances ? Formatters.formatCurrency(amount) : '\$•••',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 50,
            child: Text(
              _showBalances ? _percentFormat.format(percentage) : '••%',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'Food & Dining': Colors.orange,
      'Transportation': Colors.blue,
      'Shopping': Colors.pink,
      'Entertainment': Colors.purple,
      'Bills & Utilities': Colors.red,
      'Healthcare': Colors.green,
      'Travel': Colors.teal,
      'Education': Colors.indigo,
      'Personal': Colors.amber,
      'Other': Colors.grey,
    };
    return colors[category] ?? Colors.grey;
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _navigateToAddTransaction,
      icon: const Icon(Icons.add),
      label: const Text('Add'),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
    );
  }
}
