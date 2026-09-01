import 'package:flutter/material.dart';
import '../models/account.dart';
import '../models/transaction_model.dart';
import '../models/savings_goal.dart';
import '../models/stock.dart';
import '../services/database_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  
  double _totalBalance = 0.0;
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;
  List<TransactionModel> _recentTransactions = [];
  List<SavingsGoal> _savingsGoals = [];
  List<Stock> _stocks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final accounts = await _databaseHelper.getAccounts();
      final transactions = await _databaseHelper.getTransactions();
      final goals = await _databaseHelper.getSavingsGoals();
      final stocks = await _databaseHelper.getStocks();

      double balance = 0.0;
      double income = 0.0;
      double expenses = 0.0;

      for (var account in accounts) {
        balance += account.balance;
      }

      for (var transaction in transactions) {
        if (transaction.type == 'income') {
          income += transaction.amount;
        } else if (transaction.type == 'expense') {
          expenses += transaction.amount;
        }
      }

      setState(() {
        _totalBalance = balance;
        _totalIncome = income;
        _totalExpenses = expenses;
        _recentTransactions = transactions.take(5).toList();
        _savingsGoals = goals;
        _stocks = stocks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading dashboard: $e')),
        );
      }
    }
  }

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.movie;
      case 'utilities':
        return Icons.bolt;
      case 'salary':
        return Icons.work;
      case 'investment':
        return Icons.trending_up;
      default:
        return Icons.attach_money;
    }
  }

  Color _getCategoryColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'food':
        return Colors.orange;
      case 'transport':
        return Colors.blue;
      case 'shopping':
        return Colors.pink;
      case 'entertainment':
        return Colors.purple;
      case 'utilities':
        return Colors.yellow.shade700;
      case 'salary':
        return Colors.green;
      case 'investment':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'FinTrack',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBalanceCard(),
                    const SizedBox(height: 16),
                    _buildIncomeExpenseRow(),
                    const SizedBox(height: 24),
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                    _buildRecentTransactions(),
                    const SizedBox(height: 24),
                    _buildSavingsGoals(),
                    const SizedBox(height: 24),
                    _buildStockPortfolio(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddTransactionDialog(context);
        },
        backgroundColor: Colors.blue.shade700,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Transaction',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Balance',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatCurrency(_totalBalance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildMiniStat(Icons.arrow_upward, 'Income', _totalIncome, Colors.greenAccent),
              const SizedBox(width: 24),
              _buildMiniStat(Icons.arrow_downward, 'Expenses', _totalExpenses, Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String label, double amount, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
            Text(
              _formatCurrency(amount),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIncomeExpenseRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Income', _totalIncome, Colors.green, Icons.arrow_upward)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Expenses', _totalExpenses, Colors.red, Icons.arrow_downward)),
      ],
    );
  }

  Widget _buildStatCard(String title, double amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              Text(
                _formatCurrency(amount),
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionButton(
              'Transfer',
              Icons.swap_horiz,
              Colors.blue,
              () => Navigator.pushNamed(context, '/transfer'),
            ),
            _buildActionButton(
              'Accounts',
              Icons.account_balance_wallet,
              Colors.purple,
              () => Navigator.pushNamed(context, '/accounts'),
            ),
            _buildActionButton(
              'Goals',
              Icons.flag,
              Colors.orange,
              () => Navigator.pushNamed(context, '/goals'),
            ),
            _buildActionButton(
              'Stocks',
              Icons.show_chart,
              Colors.teal,
              () => Navigator.pushNamed(context, '/stocks'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
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
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/transactions'),
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _recentTransactions.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          'No transactions yet',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _recentTransactions.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: Colors.grey.shade200,
                  ),
                  itemBuilder: (context, index) {
                    final transaction = _recentTransactions[index];
                    return _buildTransactionTile(transaction);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTransactionTile(TransactionModel transaction) {
    final isIncome = transaction.type == 'income';
    final categoryColor = _getCategoryColor(transaction.category);
    
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: categoryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          _getCategoryIcon(transaction.category),
          color: categoryColor,
          size: 24,
        ),
      ),
      title: Text(
        transaction.description.isEmpty 
            ? (transaction.category ?? 'Transaction')
            : transaction.description,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        transaction.category ?? 'General',
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 13,
        ),
      ),
      trailing: Text(
        '${isIncome ? '+' : '-'}${_formatCurrency(transaction.amount)}',
        style: TextStyle(
          color: isIncome ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildSavingsGoals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Savings Goals',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/goals'),
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _savingsGoals.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.flag_outlined, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          'No savings goals yet',
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Start saving for your dreams!',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: _savingsGoals.take(3).length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final goal = _savingsGoals[index];
                    return _buildSavingsGoalTile(goal);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSavingsGoalTile(SavingsGoal goal) {
    final progress = goal.targetAmount > 0 
        ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    final progressPercent = (progress * 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.flag,
                      color: Colors.orange.shade700,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Target: ${_formatCurrency(goal.targetAmount)}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                '$progressPercent%',
                style: TextStyle(
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade700),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_formatCurrency(goal.currentAmount)} saved',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockPortfolio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Stock Portfolio',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/stocks'),
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _stocks.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.show_chart, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          'No stocks in portfolio',
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Start investing today!',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _stocks.take(5).length,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: Colors.grey.shade200,
                  ),
                  itemBuilder: (context, index) {
                    final stock = _stocks[index];
                    return _buildStockTile(stock);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStockTile(Stock stock) {
    final isPositive = stock.priceChange >= 0;
    final changeColor = isPositive ? Colors.green : Colors.red;

    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.teal.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            stock.symbol.substring(0, stock.symbol.length > 2 ? 2 : stock.symbol.length),
            style: TextStyle(
              color: Colors.teal.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
      title: Text(
        stock.symbol,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        stock.name,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 13,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '\$${stock.currentPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                color: changeColor,
                size: 14,
              ),
              Text(
                '${isPositive ? '+' : ''}${stock.priceChange.toStringAsFixed(2)}%',
                style: TextStyle(
                  color: changeColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    String selectedType = 'expense';
    String selectedCategory = 'General';

    final List<String> expenseCategories = [
      'Food',
      'Transport',
      'Shopping',
      'Entertainment',
      'Utilities',
      'Healthcare',
      'Education',
      'Other'
    ];

    final List<String> incomeCategories = [
      'Salary',
      'Investment',
      'Freelance',
      'Gift',
      'Refund',
      'Other'
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final categories = selectedType == 'expense' ? expenseCategories : incomeCategories;
            
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Add Transaction',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setModalState(() {
                                selectedType = 'expense';
                                selectedCategory = 'Food';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: selectedType == 'expense'
                                    ? Colors.red.shade50
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selectedType == 'expense'
                                      ? Colors.red
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Expense',
                                  style: TextStyle(
                                    color: selectedType == 'expense'
                                        ? Colors.red
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setModalState(() {
                                selectedType = 'income';
                                selectedCategory = 'Salary';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: selectedType == 'income'
                                    ? Colors.green.shade50
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selectedType == 'income'
                                      ? Colors.green
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Income',
                                  style: TextStyle(
                                    color: selectedType == 'income'
                                        ? Colors.green
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.description),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        hintText: '0.00',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.attach_money),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Category',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((category) {
                        final isSelected = selectedCategory == category;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectedCategory = category;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (selectedType == 'expense'
                                      ? Colors.red.shade50
                                      : Colors.green.shade50)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? (selectedType == 'expense'
                                        ? Colors.red
                                        : Colors.green)
                                    : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getCategoryIcon(category),
                                  size: 16,
                                  color: isSelected
                                      ? (selectedType == 'expense'
                                          ? Colors.red
                                          : Colors.green)
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  category,
                                  style: TextStyle(
                                    color: isSelected
                                        ? (selectedType == 'expense'
                                            ? Colors.red
                                            : Colors.green)
                                        : Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final amount = double.tryParse(amountController.text);
                          if (amount == null || amount <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a valid amount'),
                              ),
                            );
                            return;
                          }

                          final transaction = TransactionModel(
                            id: 0,
                            accountId: 1,
                            type: selectedType,
                            amount: amount,
                            category: selectedCategory,
                            description: descriptionController.text,
                            date: DateTime.now(),
                          );

                          try {
                            await _databaseHelper.insertTransaction(transaction);
                            if (mounted) {
                              Navigator.pop(context);
                              _loadDashboardData();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${selectedType == 'income' ? 'Income' : 'Expense'} added successfully!',
                                  ),
                                  backgroundColor: selectedType == 'income'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedType == 'income'
                              ? Colors.green
                              : Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Add Transaction',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
