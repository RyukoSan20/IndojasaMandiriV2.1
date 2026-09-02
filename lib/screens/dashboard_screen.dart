import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/account_model.dart';
import '../models/transaction_model.dart';
import '../models/savings_goal_model.dart';
import '../models/stock_model.dart';
import '../services/mock_data_service.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/savings_goal_card.dart';
import '../widgets/stock_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/finance_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final MockDataService _mockDataService = MockDataService();
  bool _isLoading = true;
  int _selectedNavIndex = 0;

  List<AccountModel> _accounts = [];
  List<TransactionModel> _transactions = [];
  List<SavingsGoalModel> _savingsGoals = [];
  List<StockModel> _stocks = [];
  double _totalBalance = 0.0;
  double _monthlyIncome = 0.0;
  double _monthlyExpenses = 0.0;
  List<Map<String, dynamic>> _weeklySpending = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 500));

    _accounts = _mockDataService.getAccounts();
    _transactions = _mockDataService.getTransactions();
    _savingsGoals = _mockDataService.getSavingsGoals();
    _stocks = _mockDataService.getStocks();
    _weeklySpending = _mockDataService.getWeeklySpending();

    _totalBalance = _accounts.fold(0.0, (sum, account) => sum + account.balance);
    _monthlyIncome = _mockDataService.getMonthlyIncome();
    _monthlyExpenses = _mockDataService.getMonthlyExpenses();

    setState(() => _isLoading = false);
  }

  void _onNavItemTapped(int index) {
    setState(() => _selectedNavIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.onPrimary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.account_balance_wallet,
                size: 24,
                color: theme.colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'FinTrack',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(isSmallScreen ? 12 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreetingSection(theme),
                    const SizedBox(height: 20),
                    _buildBalanceOverviewSection(theme, currencyFormat, isSmallScreen),
                    const SizedBox(height: 24),
                    _buildQuickActionsSection(theme),
                    const SizedBox(height: 24),
                    _buildSpendingChartSection(theme, isSmallScreen),
                    const SizedBox(height: 24),
                    _buildAccountsSection(theme, currencyFormat, isSmallScreen),
                    const SizedBox(height: 24),
                    _buildRecentTransactionsSection(theme, currencyFormat),
                    const SizedBox(height: 24),
                    _buildSavingsGoalsSection(theme, currencyFormat, isSmallScreen),
                    const SizedBox(height: 24),
                    _buildStockPortfolioSection(theme, currencyFormat, isSmallScreen),
                    const SizedBox(height: 24),
                    _buildFinancialInsightsSection(theme),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedNavIndex,
        onDestinationSelected: _onNavItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_outlined),
            selectedIcon: Icon(Icons.account_balance),
            label: 'Accounts',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up_outlined),
            selectedIcon: Icon(Icons.trending_up),
            label: 'Stocks',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingSection(ThemeData theme) {
    final hour = DateTime.now().hour;
    String greeting;
    IconData greetingIcon;

    if (hour < 12) {
      greeting = 'Good Morning';
      greetingIcon = Icons.wb_sunny_outlined;
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
      greetingIcon = Icons.wb_sunny;
    } else {
      greeting = 'Good Evening';
      greetingIcon = Icons.nights_stay_outlined;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onPrimary.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Welcome back!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onPrimary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              greetingIcon,
              size: 32,
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceOverviewSection(
    ThemeData theme,
    NumberFormat currencyFormat,
    bool isSmallScreen,
  ) {
    final savingsRate = _monthlyIncome > 0
        ? ((_monthlyIncome - _monthlyExpenses) / _monthlyIncome * 100)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Financial Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                theme,
                'Total Balance',
                currencyFormat.format(_totalBalance),
                Icons.account_balance_wallet,
                theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                theme,
                'Monthly Income',
                currencyFormat.format(_monthlyIncome),
                Icons.arrow_upward,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                theme,
                'Monthly Expenses',
                currencyFormat.format(_monthlyExpenses),
                Icons.arrow_downward,
                Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                theme,
                'Savings Rate',
                '${savingsRate.toStringAsFixed(1)}%',
                Icons.savings,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String title,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: iconColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
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
                color: Colors.green,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Add Income feature coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              QuickActionButton(
                icon: Icons.remove_circle_outline,
                label: 'Add Expense',
                color: Colors.red,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Add Expense feature coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              QuickActionButton(
                icon: Icons.transfer_outlined,
                label: 'Transfer',
                color: Colors.blue,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transfer feature coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              QuickActionButton(
                icon: Icons.savings_outlined,
                label: 'Add Goal',
                color: Colors.orange,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Add Goal feature coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              QuickActionButton(
                icon: Icons.show_chart,
                label: 'Buy Stock',
                color: Colors.purple,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Buy Stock feature coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpendingChartSection(ThemeData theme, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Weekly Spending',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('View detailed analytics coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FinanceChart(weeklySpending: _weeklySpending),
        ),
      ],
    );
  }

  Widget _buildAccountsSection(
    ThemeData theme,
    NumberFormat currencyFormat,
    bool isSmallScreen,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Accounts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('View all accounts coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _accounts.length,
            itemBuilder: (context, index) {
              final account = _accounts[index];
              return Padding(
                padding: EdgeInsets.only(right: index < _accounts.length - 1 ? 12 : 0),
                child: BalanceCard(
                  account: account,
                  currencyFormat: currencyFormat,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Viewing ${account.name}'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactionsSection(
    ThemeData theme,
    NumberFormat currencyFormat,
  ) {
    final recentTransactions = _transactions.take(5).toList();

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
                color: theme.colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('View all transactions coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentTransactions.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: theme.colorScheme.outlineVariant,
            ),
            itemBuilder: (context, index) {
              final transaction = recentTransactions[index];
              return TransactionListItem(
                transaction: transaction,
                currencyFormat: currencyFormat,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Transaction: ${transaction.description}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSavingsGoalsSection(
    ThemeData theme,
    NumberFormat currencyFormat,
    bool isSmallScreen,
  ) {
    final activeGoals = _savingsGoals.where((g) => !g.isCompleted).take(3).toList();

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
                color: theme.colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('View all goals coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (activeGoals.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.savings_outlined,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No active savings goals',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Create savings goal coming soon!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Text('Create Goal'),
                  ),
                ],
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isSmallScreen ? 1 : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: isSmallScreen ? 3.5 : 2,
            ),
            itemCount: activeGoals.length,
            itemBuilder: (context, index) {
              final goal = activeGoals[index];
              return SavingsGoalCard(
                goal: goal,
                currencyFormat: currencyFormat,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Viewing goal: ${goal.name}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            },
          ),
      ],
    );
  }

  Widget _buildStockPortfolioSection(
    ThemeData theme,
    NumberFormat currencyFormat,
    bool isSmallScreen,
  ) {
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
                color: theme.colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('View full portfolio coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_stocks.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.show_chart,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No stocks in portfolio',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Buy stocks coming soon!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Text('Start Investing'),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _stocks.length,
              itemBuilder: (context, index) {
                final stock = _stocks[index];
                return Padding(
                  padding: EdgeInsets.only(right: index < _stocks.length - 1 ? 12 : 0),
                  child: StockCard(
                    stock: stock,
                    currencyFormat: currencyFormat,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Viewing ${stock.symbol}'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildFinancialInsightsSection(ThemeData theme) {
    final insights = _generateInsights();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Financial Insights',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: insights.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: theme.colorScheme.outlineVariant,
            ),
            itemBuilder: (context, index) {
              final insight = insights[index];
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: insight['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    insight['icon'],
                    color: insight['color'],
                    size: 24,
                  ),
                ),
                title: Text(
                  insight['title'],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(insight['description']),
                trailing: Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(insight['title']),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _generateInsights() {
    final insights = <Map<String, dynamic>>[];
    final savingsRate = _monthlyIncome > 0
        ? ((_monthlyIncome - _monthlyExpenses) / _monthlyIncome * 100)
        : 0.0;

    if (savingsRate >= 20) {
      insights.add({
        'icon': Icons.celebration,
        'color': Colors.green,
        'title': 'Great Savings Rate!',
        'description': 'You\'re saving ${savingsRate.toStringAsFixed(1)}% of your income. Keep it up!',
      });
    } else if (savingsRate > 0) {
      insights.add({
        'icon': Icons.trending_up,
        'color': Colors.orange,
        'title': 'Room for Improvement',
        'description': 'Try to increase your savings rate to at least 20% of your income.',
      });
    } else {
      insights.add({
        'icon': Icons.warning_amber,
        'color': Colors.red,
        'title': 'Spending Exceeds Income',
        'description': 'Consider reviewing your expenses to avoid overspending.',
      });
    }

    final topExpense = _getTopExpenseCategory();
    if (topExpense != null) {
      insights.add({
        'icon': Icons.pie_chart,
        'color': Colors.blue,
        'title': 'Top Expense Category',
        'description': 'Your highest expense is $topExpense. Consider reducing costs here.',
      });
    }

    if (_stocks.isNotEmpty) {
      final totalStockValue = _stocks.fold(0.0, (sum, s) => sum + s.currentValue);
      insights.add({
        'icon': Icons.show_chart,
        'color': Colors.purple,
        'title': 'Investment Portfolio',
        'description': 'Your portfolio is worth ${NumberFormat.currency(symbol: '\$').format(totalStockValue)}.',
      });
    }

    if (_savingsGoals.isNotEmpty) {
      final activeGoals = _savingsGoals.where((g) => !g.isCompleted).length;
      insights.add({
        'icon': Icons.flag,
        'color': Colors.teal,
        'title': 'Savings Goals Progress',
        'description': 'You have $activeGoals active savings goals. Stay focused!',
      });
    }

    return insights;
  }

  String? _getTopExpenseCategory() {
    final categoryTotals = <String, double>{};
    for (final transaction in _transactions) {
      if (transaction.type == 'expense') {
        categoryTotals[transaction.category] =
            (categoryTotals[transaction.category] ?? 0) + transaction.amount;
      }
    }
    if (categoryTotals.isEmpty) return null;

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedCategories.first.key;
  }
}
