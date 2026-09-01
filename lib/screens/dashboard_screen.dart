import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../models/savings_goal.dart';
import '../models/stock.dart';
import '../services/finance_service.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/savings_goal_card.dart';
import '../widgets/stock_portfolio_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/financial_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FinanceService _financeService = FinanceService();
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$');
  final NumberFormat _percentFormat = NumberFormat.percentPattern();

  bool _isLoading = true;
  double _totalBalance = 0.0;
  double _monthlyIncome = 0.0;
  double _monthlyExpenses = 0.0;
  double _totalInvested = 0.0;
  double _portfolioChange = 0.0;
  List<Account> _accounts = [];
  List<Transaction> _recentTransactions = [];
  List<SavingsGoal> _savingsGoals = [];
  List<Stock> _stocks = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final accounts = await _financeService.getAccounts();
      final transactions = await _financeService.getTransactions();
      final goals = await _financeService.getSavingsGoals();
      final stocks = await _financeService.getStocks();

      final totalBalance = accounts.fold<double>(
        0.0,
        (sum, account) => sum + account.balance,
      );

      final monthlyIncome = transactions
          .where((t) =>
              t.type == TransactionType.income &&
              t.date.month == DateTime.now().month)
          .fold<double>(0.0, (sum, t) => sum + t.amount);

      final monthlyExpenses = transactions
          .where((t) =>
              t.type == TransactionType.expense &&
              t.date.month == DateTime.now().month)
          .fold<double>(0.0, (sum, t) => sum + t.amount);

      final totalInvested = stocks.fold<double>(
        0.0,
        (sum, stock) => sum + (stock.currentPrice * stock.quantity),
      );

      final portfolioChange = stocks.fold<double>(
        0.0,
        (sum, stock) => sum + stock.changePercent,
      );

      setState(() {
        _accounts = accounts;
        _recentTransactions = transactions.take(5).toList();
        _savingsGoals = goals;
        _stocks = stocks;
        _totalBalance = totalBalance;
        _monthlyIncome = monthlyIncome;
        _monthlyExpenses = monthlyExpenses;
        _totalInvested = totalInvested;
        _portfolioChange = portfolioChange / (stocks.isEmpty ? 1 : stocks.length);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load dashboard data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E88E5),
        title: const Text(
          'FinTrack',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: _isLoading ? _buildLoadingState() : _buildDashboardContent(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddTransaction,
        backgroundColor: const Color(0xFF43A047),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Transaction',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E88E5)),
          ),
          SizedBox(height: 16),
          Text(
            'Loading your finances...',
            style: TextStyle(
              color: Color(0xFF666666),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      color: const Color(0xFF1E88E5),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: 24),
            _buildSummaryCards(),
            const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 24),
            _buildFinancialOverviewChart(),
            const SizedBox(height: 24),
            _buildRecentTransactions(),
            const SizedBox(height: 24),
            _buildSavingsGoalsSection(),
            const SizedBox(height: 24),
            _buildPortfolioSection(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final now = DateTime.now();
    String greeting;
    if (now.hour < 12) {
      greeting = 'Good Morning';
    } else if (now.hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('EEEE, MMMM d, yyyy').format(now),
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF888888),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Financial Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: 'Total Balance',
                amount: _currencyFormat.format(_totalBalance),
                icon: Icons.account_balance_wallet,
                color: const Color(0xFF1E88E5),
                onTap: _navigateToAccounts,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SummaryCard(
                title: 'Monthly Income',
                amount: _currencyFormat.format(_monthlyIncome),
                icon: Icons.trending_up,
                color: const Color(0xFF43A047),
                onTap: _navigateToAnalytics,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: 'Monthly Expenses',
                amount: _currencyFormat.format(_monthlyExpenses),
                icon: Icons.trending_down,
                color: const Color(0xFFE53935),
                onTap: _navigateToAnalytics,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SummaryCard(
                title: 'Invested',
                amount: _currencyFormat.format(_totalInvested),
                subtitle: _portfolioChange >= 0
                    ? '+${_percentFormat.format(_portfolioChange / 100)}'
                    : _percentFormat.format(_portfolioChange / 100),
                icon: Icons.show_chart,
                color: const Color(0xFFFF9800),
                onTap: _navigateToPortfolio,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              QuickActionButton(
                icon: Icons.add_circle_outline,
                label: 'Add Income',
                color: const Color(0xFF43A047),
                onTap: () => Navigator.pushNamed(
                  context,
                  '/add-transaction',
                  arguments: {'type': 'income'},
                ),
              ),
              const SizedBox(width: 12),
              QuickActionButton(
                icon: Icons.remove_circle_outline,
                label: 'Add Expense',
                color: const Color(0xFFE53935),
                onTap: () => Navigator.pushNamed(
                  context,
                  '/add-transaction',
                  arguments: {'type': 'expense'},
                ),
              ),
              const SizedBox(width: 12),
              QuickActionButton(
                icon: Icons.savings_outlined,
                label: 'Savings Goal',
                color: const Color(0xFF8E24AA),
                onTap: _navigateToSavingsGoals,
              ),
              const SizedBox(width: 12),
              QuickActionButton(
                icon: Icons.analytics_outlined,
                label: 'Analytics',
                color: const Color(0xFF00ACC1),
                onTap: _navigateToAnalytics,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialOverviewChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                'Income vs Expenses',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              TextButton(
                onPressed: _navigateToAnalytics,
                child: const Text(
                  'View Details',
                  style: TextStyle(
                    color: Color(0xFF1E88E5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: FinancialChart(
              income: _monthlyIncome,
              expenses: _monthlyExpenses,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/transactions'),
                child: const Text(
                  'See All',
                  style: TextStyle(
                    color: Color(0xFF1E88E5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_recentTransactions.isEmpty)
            _buildEmptyTransactionsState()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentTransactions.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final transaction = _recentTransactions[index];
                return TransactionListItem(
                  transaction: transaction,
                  currencyFormat: _currencyFormat,
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/transaction-details',
                    arguments: {'transactionId': transaction.id},
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyTransactionsState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'No transactions yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first transaction',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsGoalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Savings Goals',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            TextButton(
              onPressed: _navigateToSavingsGoals,
              child: const Text(
                'See All',
                style: TextStyle(
                  color: Color(0xFF1E88E5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_savingsGoals.isEmpty)
          _buildEmptySavingsGoalsState()
        else
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _savingsGoals.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final goal = _savingsGoals[index];
                return SavingsGoalCard(
                  goal: goal,
                  currencyFormat: _currencyFormat,
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/savings-goal-details',
                    arguments: {'goalId': goal.id},
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildEmptySavingsGoalsState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[300]!,
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.savings_outlined,
            size: 40,
            color: Colors.grey[400],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No savings goals yet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Create your first savings goal to start tracking',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _navigateToSavingsGoals,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8E24AA),
            ),
            child: const Text(
              'Create',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Stock Portfolio',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            TextButton(
              onPressed: _navigateToPortfolio,
              child: const Text(
                'See All',
                style: TextStyle(
                  color: Color(0xFF1E88E5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_stocks.isEmpty)
          _buildEmptyPortfolioState()
        else
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _stocks.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final stock = _stocks[index];
                return StockPortfolioCard(
                  stock: stock,
                  currencyFormat: _currencyFormat,
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/stock-details',
                    arguments: {'stockSymbol': stock.symbol},
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyPortfolioState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[300]!,
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.show_chart,
            size: 40,
            color: Colors.grey[400],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No stocks in portfolio',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add stocks to track your investments',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _navigateToPortfolio,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9800),
            ),
            child: const Text(
              'Add Stock',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
