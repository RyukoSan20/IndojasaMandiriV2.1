import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../models/stock.dart';
import '../models/savings_goal.dart';
import '../services/financial_service.dart';
import '../widgets/balance_card.dart';
import '../widgets/account_list_tile.dart';
import '../widgets/transaction_list_tile.dart';
import '../widgets/stock_card.dart';
import '../widgets/savings_progress_card.dart';
import '../widgets/expense_chart.dart';
import '../widgets/quick_action_button.dart';

class DashboardScreen extends StatefulWidget {
  final String userId;
  final VoidCallback onNavigateToAccounts;
  final VoidCallback onNavigateToTransactions;
  final VoidCallback onNavigateToSavings;
  final VoidCallback onNavigateToStocks;
  final VoidCallback onNavigateToAnalytics;
  final VoidCallback onNavigateToSettings;

  const DashboardScreen({
    super.key,
    required this.userId,
    required this.onNavigateToAccounts,
    required this.onNavigateToTransactions,
    required this.onNavigateToSavings,
    required this.onNavigateToStocks,
    required this.onNavigateToAnalytics,
    required this.onNavigateToSettings,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final FinancialService _financialService = FinancialService();
  final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  final DateFormat _timeFormat = DateFormat('hh:mm a');

  bool _isLoading = true;
  bool _isRefreshing = false;

  double _totalBalance = 0.0;
  double _monthlyIncome = 0.0;
  double _monthlyExpenses = 0.0;
  double _monthlySavings = 0.0;
  double _savingsRate = 0.0;

  List<Account> _accounts = [];
  List<Transaction> _recentTransactions = [];
  List<Stock> _topStocks = [];
  List<SavingsGoal> _savingsGoals = [];

  Map<String, double> _expensesByCategory = {};
  List<double> _weeklyExpenses = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadDashboardData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      await Future.wait([
        _loadAccounts(),
        _loadTransactions(),
        _loadStocks(),
        _loadSavingsGoals(),
        _loadFinancialSummary(),
      ]);

      _animationController.forward();
    } catch (e) {
      _showErrorSnackBar('Failed to load dashboard data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadAccounts() async {
    try {
      final accounts = await _financialService.getAccounts(widget.userId);
      if (mounted) {
        setState(() {
          _accounts = accounts;
          _totalBalance = accounts.fold(
            0.0,
            (sum, account) => sum + account.balance,
          );
        });
      }
    } catch (e) {
      debugPrint('Error loading accounts: $e');
    }
  }

  Future<void> _loadTransactions() async {
    try {
      final transactions = await _financialService.getRecentTransactions(
        widget.userId,
        limit: 5,
      );
      final expenses = await _financialService.getExpensesByCategory(
        widget.userId,
      );
      final weekly = await _financialService.getWeeklyExpenses(widget.userId);

      if (mounted) {
        setState(() {
          _recentTransactions = transactions;
          _expensesByCategory = expenses;
          _weeklyExpenses = weekly;
        });
      }
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    }
  }

  Future<void> _loadStocks() async {
    try {
      final stocks = await _financialService.getStocks(widget.userId);
      if (mounted) {
        setState(() {
          _topStocks = stocks.take(3).toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading stocks: $e');
    }
  }

  Future<void> _loadSavingsGoals() async {
    try {
      final goals = await _financialService.getSavingsGoals(widget.userId);
      if (mounted) {
        setState(() {
          _savingsGoals = goals;
        });
      }
    } catch (e) {
      debugPrint('Error loading savings goals: $e');
    }
  }

  Future<void> _loadFinancialSummary() async {
    try {
      final summary = await _financialService.getFinancialSummary(
        widget.userId,
      );

      if (mounted) {
        setState(() {
          _monthlyIncome = summary['monthlyIncome'] ?? 0.0;
          _monthlyExpenses = summary['monthlyExpenses'] ?? 0.0;
          _monthlySavings = summary['monthlySavings'] ?? 0.0;
          _savingsRate = summary['savingsRate'] ?? 0.0;
        });
      }
    } catch (e) {
      debugPrint('Error loading financial summary: $e');
    }
  }

  Future<void> _refreshDashboard() async {
    setState(() => _isRefreshing = true);

    try {
      await _loadDashboardData();
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
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

  void _showQuickAddMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Quick Add',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildQuickAddOption(
              icon: Icons.add_circle_outline,
              label: 'Add Income',
              color: Colors.green,
              onTap: () {
                Navigator.pop(context);
                _showAddTransactionDialog(isIncome: true);
              },
            ),
            _buildQuickAddOption(
              icon: Icons.remove_circle_outline,
              label: 'Add Expense',
              color: Colors.red,
              onTap: () {
                Navigator.pop(context);
                _showAddTransactionDialog(isIncome: false);
              },
            ),
            _buildQuickAddOption(
              icon: Icons.savings_outlined,
              label: 'Add to Savings Goal',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(context);
                _showAddSavingsDialog();
              },
            ),
            _buildQuickAddOption(
              icon: Icons.show_chart,
              label: 'Add Stock Purchase',
              color: Colors.purple,
              onTap: () {
                Navigator.pop(context);
                _showAddStockDialog();
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAddOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showAddTransactionDialog({required bool isIncome}) {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'Other';
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isIncome ? 'Add Income' : 'Add Expense'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$ ',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                ),
                items: _getCategories(isIncome).map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedCategory = value ?? 'Other';
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                subtitle: Text(_dateFormat.format(selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    selectedDate = date;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                await _financialService.addTransaction(
                  userId: widget.userId,
                  amount: amount,
                  description: descriptionController.text,
                  category: selectedCategory,
                  date: selectedDate,
                  isIncome: isIncome,
                );
                Navigator.pop(context);
                _loadDashboardData();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  List<String> _getCategories(bool isIncome) {
    if (isIncome) {
      return ['Salary', 'Freelance', 'Investment', 'Gift', 'Refund', 'Other'];
    }
    return [
      'Food & Dining',
      'Transportation',
      'Shopping',
      'Entertainment',
      'Bills & Utilities',
      'Healthcare',
      'Education',
      'Travel',
      'Groceries',
      'Insurance',
      'Other',
    ];
  }

  void _showAddSavingsDialog() {
    if (_savingsGoals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No savings goals found. Create one first!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    SavingsGoal? selectedGoal;
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add to Savings Goal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<SavingsGoal>(
                decoration: const InputDecoration(
                  labelText: 'Select Goal',
                ),
                items: _savingsGoals.map((goal) {
                  return DropdownMenuItem(
                    value: goal,
                    child: Text(goal.name),
                  );
                }).toList(),
                onChanged: (goal) {
                  setDialogState(() => selectedGoal = goal);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$ ',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text);
                if (amount != null && amount > 0 && selectedGoal != null) {
                  await _financialService.addToSavingsGoal(
                    goalId: selectedGoal!.id,
                    amount: amount,
                  );
                  Navigator.pop(context);
                  _loadDashboardData();
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddStockDialog() {
    final symbolController = TextEditingController();
    final sharesController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Stock Purchase'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: symbolController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Stock Symbol',
                  hintText: 'e.g., AAPL',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: sharesController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,4}')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Number of Shares',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Price per Share',
                  prefixText: '\$ ',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final shares = double.tryParse(sharesController.text);
              final price = double.tryParse(priceController.text);
              if (shares != null && shares > 0 && price != null && price > 0) {
                await _financialService.addStockPurchase(
                  userId: widget.userId,
                  symbol: symbolController.text.toUpperCase(),
                  shares: shares,
                  pricePerShare: price,
                );
                Navigator.pop(context);
                _loadDashboardData();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _refreshDashboard,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    _buildAppBar(),
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildBalanceSection(),
                          const SizedBox(height: 24),
                          _buildFinancialSummaryCards(),
                          const SizedBox(height: 24),
                          _buildQuickActionsSection(),
                          const SizedBox(height: 24),
                          _buildExpensesChartSection(),
                          const SizedBox(height: 24),
                          _buildAccountsSection(),
                          const SizedBox(height: 24),
                          _buildRecentTransactionsSection(),
                          const SizedBox(height: 24),
                          _buildSavingsGoalsSection(),
                          const SizedBox(height: 24),
                          _buildPortfolioSection(),
                          const SizedBox(height: 24),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showQuickAddMenu,
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: const Color(0xFFF5F7FA),
      elevation: 0,
      title: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Good Morning!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Your Finances',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Color(0xFF1A1A2E)),
          onPressed: () {
            // Navigate to notifications
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Color(0xFF1A1A2E)),
          onPressed: widget.onNavigateToSettings,
        ),
      ],
    );
  }

  Widget _buildBalanceSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: BalanceCard(
          totalBalance: _totalBalance,
          monthlyIncome: _monthlyIncome,
          monthlyExpenses: _monthlyExpenses,
          savingsRate: _savingsRate,
          onTap: widget.onNavigateToAccounts,
        ),
      ),
    );
  }

  Widget _buildFinancialSummaryCards() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                title: 'Income',
                amount: _monthlyIncome,
                icon: Icons.arrow_downward,
                iconColor: Colors.green,
                backgroundColor: Colors.green.shade50,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                title: 'Expenses',
                amount: _monthlyExpenses,
                icon: Icons.arrow_upward,
                iconColor: Colors.red,
                backgroundColor: Colors.red.shade50,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                title: 'Savings',
                amount: _monthlySavings,
                icon: Icons.savings,
                iconColor: Colors.blue,
                backgroundColor: Colors.blue.shade50,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _currencyFormat.format(amount),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
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
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              QuickActionButton(
                icon: Icons.add_circle_outline,
                label: 'Add Income',
                color: Colors.green,
                onTap: () => _showAddTransactionDialog(isIncome: true),
              ),
              QuickActionButton(
                icon: Icons.remove_circle_outline,
                label: 'Add Expense',
                color: Colors.red,
                onTap: () => _showAddTransactionDialog(isIncome: false),
              ),
              QuickActionButton(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Accounts',
                color: Colors.blue,
                onTap: widget.onNavigateToAccounts,
              ),
              QuickActionButton(
                icon: Icons.pie_chart_outline,
                label: 'Analytics',
                color: Colors.purple,
                onTap: widget.onNavigateToAnalytics,
              ),
              QuickActionButton(
                icon: Icons.savings_outlined,
                label: 'Savings',
                color: Colors.orange,
                onTap: widget.onNavigateToSavings,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpensesChartSection() {
    if (_expensesByCategory.isEmpty) return const SizedBox.shrink();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
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
                    'Expense Breakdown',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onNavigateToAnalytics,
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        color: Color(0xFF6C63FF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: ExpenseChart(expenses: _expensesByCategory),
              ),
              const SizedBox(height: 16),
              _buildExpenseLegend(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseLegend() {
    final colors = [
      const Color(0xFF6C63FF),
      const Color(0xFFFF6B6B),
      const Color(0xFFFFD93D),
      const Color(0xFF6BCB77),
      const Color(0xFF4D96FF),
      const Color(0xFFFF9F43),
    ];

    final entries = _expensesByCategory.entries.toList();
    final total = entries.fold(0.0, (sum, e) => sum + e.value);

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: entries.asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value.key;
        final amount = entry.value.value;
        final percentage = total > 0 ? (amount / total * 100) : 0;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$category (${percentage.toStringAsFixed(1)}%)',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildAccountsSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
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
                    'Your Accounts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onNavigateToAccounts,
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        color: Color(0xFF6C63FF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_accounts.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No accounts added yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _accounts.take(3).length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final account = _accounts[index];
                    return AccountListTile(
                      account: account,
                      onTap: () {
                        // Navigate to account details
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTransactionsSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onNavigateToTransactions,
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        color: Color(0xFF6C63FF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_recentTransactions.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No transactions yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _recentTransactions.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final transaction = _recentTransactions[index];
                    return TransactionListTile(
                      transaction: transaction,
                      onTap: () {
                        // Navigate to transaction details
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSavingsGoalsSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
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
                    'Savings Goals',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onNavigateToSavings,
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        color: Color(0xFF6C63FF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_savingsGoals.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No savings goals yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 140,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _savingsGoals.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final goal = _savingsGoals[index];
                      return SavingsProgressCard(
                        goal: goal,
                        onTap: () {
                          // Navigate to goal details
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPortfolioSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
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
                    'Stock Portfolio',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onNavigateToStocks,
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        color: Color(0xFF6C63FF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_topStocks.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No stocks in portfolio',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _topStocks.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final stock = _topStocks[index];
                    return StockCard(
                      stock: stock,
                      onTap: () {
                        // Navigate to stock details
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
