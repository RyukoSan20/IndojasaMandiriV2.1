// ignore_for_file: unused_field, deprecated_member_use, prefer_const_declarations
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

// Color Constants
class AppColors {
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color secondary = Color(0xFF10B981);
  static const Color accent = Color(0xFFF59E0B);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFEAB308);
  static const Color error = Color(0xFFEF4444);
  static const Color income = Color(0xFF10B981);
  static const Color expense = Color(0xFFEF4444);
  static const Color cardShadow = Color(0x1A000000);

  // Dark theme colors
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
}

// Category Icons Mapping
class CategoryIcons {
  static const Map<String, IconData> icons = {
    'food': Icons.restaurant_rounded,
    'transport': Icons.directions_car_rounded,
    'shopping': Icons.shopping_bag_rounded,
    'entertainment': Icons.movie_rounded,
    'health': Icons.favorite_rounded,
    'education': Icons.school_rounded,
    'bills': Icons.receipt_long_rounded,
    'salary': Icons.work_rounded,
    'freelance': Icons.laptop_mac_rounded,
    'investment': Icons.trending_up_rounded,
    'gift': Icons.card_giftcard_rounded,
    'other': Icons.more_horiz_rounded,
  };

  static IconData getIcon(String? category) {
    return icons[category?.toLowerCase()] ?? Icons.category_rounded;
  }
}

// Transaction Model
class Transaction {
  final String id;
  final String type;
  final double amount;
  final String category;
  final String description;
  final DateTime date;
  final IconData icon;
  final Color categoryColor;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    required this.icon,
    required this.categoryColor,
  });

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';
}

// Account Model
class Account {
  final String id;
  final String name;
  final String type;
  double balance;
  final String icon;
  final Color color;

  Account({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.icon,
    required this.color,
  });
}

// Savings Goal Model
class SavingsGoal {
  final String id;
  final String name;
  final double targetAmount;
  double currentAmount;
  final DateTime? deadline;
  final IconData icon;
  final Color color;

  SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    this.deadline,
    required this.icon,
    required this.color,
  });

  double get progress => (currentAmount / targetAmount).clamp(0.0, 1.0);
  double get remaining => targetAmount - currentAmount;
  int get daysRemaining => deadline != null ? deadline!.difference(DateTime.now()).inDays : 0;
}

// Stock Holding Model
class StockHolding {
  final String symbol;
  final String companyName;
  final double shares;
  final double averagePrice;
  final double currentPrice;
  final double profitLoss;
  final double profitLossPercent;

  StockHolding({
    required this.symbol,
    required this.companyName,
    required this.shares,
    required this.averagePrice,
    required this.currentPrice,
    required this.profitLoss,
    required this.profitLossPercent,
  });

  double get totalValue => shares * currentPrice;
  double get totalInvested => shares * averagePrice;
}

// Dashboard State & Business Logic
class DashboardData {
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpense;
  final double totalSavings;
  final double portfolioValue;
  final double portfolioProfitLoss;
  final double portfolioProfitLossPercent;
  final List<Transaction> recentTransactions;
  final List<Account> accounts;
  final List<SavingsGoal> savingsGoals;
  final List<StockHolding> topHoldings;
  final Map<String, double> expenseByCategory;
  final List<Map<String, dynamic>> cashflowHistory;

  DashboardData({
    required this.totalBalance,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.totalSavings,
    required this.portfolioValue,
    required this.portfolioProfitLoss,
    required this.portfolioProfitLossPercent,
    required this.recentTransactions,
    required this.accounts,
    required this.savingsGoals,
    required this.topHoldings,
    required this.expenseByCategory,
    required this.cashflowHistory,
  });

  double get cashBalance => accounts.fold(0.0, (sum, acc) => sum + acc.balance);
  double get monthlyNetFlow => monthlyIncome - monthlyExpense;
  double get savingsProgress => totalSavings > 0 ? totalSavings / totalBalance : 0;

  factory DashboardData.empty() => DashboardData(
        totalBalance: 0,
        monthlyIncome: 0,
        monthlyExpense: 0,
        totalSavings: 0,
        portfolioValue: 0,
        portfolioProfitLoss: 0,
        portfolioProfitLossPercent: 0,
        recentTransactions: [],
        accounts: [],
        savingsGoals: [],
        topHoldings: [],
        expenseByCategory: {},
        cashflowHistory: [],
      );

  factory DashboardData.sample() {
    return DashboardData(
      totalBalance: 45750000,
      monthlyIncome: 15000000,
      monthlyExpense: 8750000,
      totalSavings: 25000000,
      portfolioValue: 12500000,
      portfolioProfitLoss: 1250000,
      portfolioProfitLossPercent: 11.1,
      recentTransactions: [
        Transaction(
          id: '1',
          type: 'expense',
          amount: 75000,
          category: 'food',
          description: 'Makan siang kantor',
          date: DateTime.now().subtract(const Duration(hours: 2)),
          icon: Icons.restaurant_rounded,
          categoryColor: const Color(0xFFEF4444),
        ),
        Transaction(
          id: '2',
          type: 'income',
          amount: 15000000,
          category: 'salary',
          description: 'Gaji Bulanan',
          date: DateTime.now().subtract(const Duration(days: 1)),
          icon: Icons.work_rounded,
          categoryColor: const Color(0xFF10B981),
        ),
        Transaction(
          id: '3',
          type: 'expense',
          amount: 250000,
          category: 'transport',
          description: 'Bensin mingguan',
          date: DateTime.now().subtract(const Duration(days: 2)),
          icon: Icons.directions_car_rounded,
          categoryColor: const Color(0xFFF59E0B),
        ),
      ],
      accounts: [
        Account(
          id: '1',
          name: 'Bank BCA',
          type: 'bank',
          balance: 25000000,
          icon: 'account_balance',
          color: const Color(0xFF1E3A5F),
        ),
        Account(
          id: '2',
          name: 'OVO',
          type: 'ewallet',
          balance: 1500000,
          icon: 'smartphone',
          color: const Color(0xFF6B3FA0),
        ),
        Account(
          id: '3',
          name: 'Dana Tunai',
          type: 'cash',
          balance: 500000,
          icon: 'wallet',
          color: const Color(0xFF22C55E),
        ),
        Account(
          id: '4',
          name: 'Tabungan',
          type: 'savings',
          balance: 18750000,
          icon: 'savings',
          color: const Color(0xFF2563EB),
        ),
      ],
      savingsGoals: [
        SavingsGoal(
          id: '1',
          name: 'Dana Darurat',
          targetAmount: 36000000,
          currentAmount: 27000000,
          deadline: DateTime.now().add(const Duration(days: 180)),
          icon: Icons.shield_rounded,
          color: const Color(0xFF2196F3),
        ),
        SavingsGoal(
          id: '2',
          name: 'Liburan',
          targetAmount: 10000000,
          currentAmount: 6500000,
          deadline: DateTime.now().add(const Duration(days: 90)),
          icon: Icons.flight_rounded,
          color: const Color(0xFF10B981),
        ),
        SavingsGoal(
          id: '3',
          name: 'DP Mobil',
          targetAmount: 50000000,
          currentAmount: 15000000,
          deadline: DateTime.now().add(const Duration(days: 365)),
          icon: Icons.directions_car_rounded,
          color: const Color(0xFFF59E0B),
        ),
      ],
      topHoldings: [
        StockHolding(
          symbol: 'BBCA.JK',
          companyName: 'Bank Central Asia',
          shares: 100,
          averagePrice: 8500,
          currentPrice: 9200,
          profitLoss: 70000,
          profitLossPercent: 8.24,
        ),
        StockHolding(
          symbol: 'TLKM.JK',
          companyName: 'Telkom Indonesia',
          shares: 200,
          averagePrice: 3100,
          currentPrice: 2950,
          profitLoss: -30000,
          profitLossPercent: -4.84,
        ),
        StockHolding(
          symbol: 'AMMN.JK',
          companyName: 'Ammann Mineral',
          shares: 50,
          averagePrice: 12500,
          currentPrice: 14250,
          profitLoss: 87500,
          profitLossPercent: 14.0,
        ),
      ],
      expenseByCategory: {
        'Makanan': 2500000,
        'Transport': 1500000,
        'Belanja': 2000000,
        'Hiburan': 750000,
        'Tagihan': 1200000,
        'Lainnya': 800000,
      },
      cashflowHistory: List.generate(
        30,
        (index) => {
          'day': index + 1,
          'income': 500000 + math.Random().nextDouble() * 1500000,
          'expense': 200000 + math.Random().nextDouble() * 800000,
        },
      ),
    );
  }
}

// Global App State Notifier untuk Pengaturan Tema, Bahasa, & Mata Uang Dinamis
class AppSettings extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  String _language = 'Indonesia';
  String _currency = 'IDR';

  ThemeMode get themeMode => _themeMode;
  String get language => _language;
  String get currency => _currency;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  void setCurrency(String curr) {
    _currency = curr;
    notifyListeners();
  }
}

final appSettings = AppSettings();

// Format Currency dengan Dukungan Simbol Dinamis
String formatCurrency(double amount, {String symbol = 'Rp', bool compact = false}) {
  if (compact) {
    if (amount >= 1000000000) {
      return '$symbol ${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '$symbol ${(amount / 1000000).toStringAsFixed(1)}jt';
    } else if (amount >= 1000) {
      return '$symbol ${(amount / 1000).toStringAsFixed(0)}rb';
    }
  }
  final formatted = amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );
  return '$symbol $formatted';
}

String formatPercentage(double value) {
  final sign = value >= 0 ? '+' : '';
  return '$sign${value.toStringAsFixed(2)}%';
}

String formatDate(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);

  if (diff.inMinutes < 60) {
    return '${diff.inMinutes} menit lalu';
  } else if (diff.inHours < 24) {
    return '${diff.inHours} jam lalu';
  } else if (diff.inDays < 7) {
    return '${diff.inDays} hari lalu';
  } else {
    return '${date.day}/${date.month}/${date.year}';
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const FinTrackApp());
}

class FinTrackApp extends StatelessWidget {
  const FinTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appSettings,
      builder: (context, child) {
        return MaterialApp(
          title: 'FinTrack',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryBlue,
              brightness: Brightness.light,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryBlue,
              brightness: Brightness.dark,
            ),
          ),
          themeMode: appSettings.themeMode,
          home: const DashboardScreen(),
        );
      },
    );
  }
}

// Dashboard Screen
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DashboardData _dashboardData = DashboardData.sample();
  bool _isLoading = false;
  int _selectedPeriodIndex = 1;

  final List<String> _periods = ['Minggu', 'Bulan', 'Tahun'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fungsi Tambah Transaksi Dinamis & Update State Saldo Real-Time
  void _addNewTransaction(String type, double amount, String category, String description) {
    setState(() {
      final isIncome = type == 'income';
      final newTx = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: type,
        amount: amount,
        category: category,
        description: description.isNotEmpty ? description : category,
        date: DateTime.now(),
        icon: CategoryIcons.getIcon(category),
        categoryColor: isIncome ? AppColors.income : AppColors.expense,
      );

      _dashboardData.recentTransactions.insert(0, newTx);

      if (_dashboardData.accounts.isNotEmpty) {
        if (isIncome) {
          _dashboardData.accounts.first.balance += amount;
        } else {
          _dashboardData.accounts.first.balance -= amount;
        }
      }

      if (_dashboardData.expenseByCategory.containsKey(category)) {
        _dashboardData.expenseByCategory[category] = (_dashboardData.expenseByCategory[category]! + (isIncome ? 0 : amount));
      }
    });
  }

  // Fungsi Transfer Saldo Antar Akun Real-Time
  void _executeTransfer(String fromName, String toName, double amount) {
    setState(() {
      final fromAcc = _dashboardData.accounts.firstWhere((a) => a.name == fromName);
      final toAcc = _dashboardData.accounts.firstWhere((a) => a.name == toName);

      if (fromAcc.balance >= amount) {
        fromAcc.balance -= amount;
        toAcc.balance += amount;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: AppColors.primaryBlue,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                floating: true,
                backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
                elevation: 0,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat Pagi',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Maya Putri',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    onPressed: () => _showNotificationsDialog(context),
                    icon: Stack(
                      children: [
                        Icon(
                          Icons.notifications_outlined,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showSettingsDialog(context),
                    icon: Icon(
                      Icons.settings_outlined,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildTotalBalanceCard(context, isDark),
                    const SizedBox(height: 24),
                    _buildQuickActions(context, isDark),
                    const SizedBox(height: 24),
                    _buildFinancialSummary(context, isDark),
                    const SizedBox(height: 24),
                    _buildCashFlowChart(context, isDark),
                    const SizedBox(height: 24),
                    _buildPeriodSelector(context, isDark),
                    const SizedBox(height: 16),
                    _buildTabContent(context, isDark),
                    const SizedBox(height: 24),
                    _buildPortfolioSummary(context, isDark),
                    const SizedBox(height: 24),
                    _buildSavingsGoals(context, isDark),
                    const SizedBox(height: 24),
                    _buildFinancialInsights(context, isDark),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalBalanceCard(BuildContext context, bool isDark) {
    final symbol = appSettings.currency == 'USD' ? '\$' : 'Rp';
    final computedTotal = _dashboardData.cashBalance + _dashboardData.portfolioValue;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryBlue, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.3),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Saldo',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatCurrency(computedTotal, symbol: symbol),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.trending_up_rounded, color: AppColors.success, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '+5.2%',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildBalanceItem(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Tunai & Bank',
                value: formatCurrency(_dashboardData.cashBalance, symbol: symbol),
                color: Colors.white,
              ),
              const SizedBox(width: 16),
              _buildBalanceItem(
                icon: Icons.show_chart_rounded,
                label: 'Investasi',
                value: formatCurrency(_dashboardData.portfolioValue, symbol: symbol),
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: color.withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickActionButton(
              context: context,
              icon: Icons.add_rounded,
              label: 'Pemasukan',
              color: AppColors.income,
              onTap: () => _showAddTransactionDialog(context, 'income'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionButton(
              context: context,
              icon: Icons.remove_rounded,
              label: 'Pengeluaran',
              color: AppColors.expense,
              onTap: () => _showAddTransactionDialog(context, 'expense'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionButton(
              context: context,
              icon: Icons.swap_horiz_rounded,
              label: 'Transfer',
              color: AppColors.accent,
              onTap: () => _showTransferDialog(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialSummary(BuildContext context, bool isDark) {
    final symbol = appSettings.currency == 'USD' ? '\$' : 'Rp';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              context: context,
              icon: Icons.arrow_downward_rounded,
              label: 'Pemasukan',
              value: formatCurrency(_dashboardData.monthlyIncome, symbol: symbol),
              color: AppColors.income,
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              context: context,
              icon: Icons.arrow_upward_rounded,
              label: 'Pengeluaran',
              value: formatCurrency(_dashboardData.monthlyExpense, symbol: symbol),
              color: AppColors.expense,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.2) : AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashFlowChart(BuildContext context, bool isDark) {
    final symbol = appSettings.currency == 'USD' ? '\$' : 'Rp';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.2) : AppColors.cardShadow,
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
              Text(
                'Arus Kas',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.income.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '+${formatCurrency(_dashboardData.monthlyNetFlow, symbol: symbol)}',
                  style: const TextStyle(
                    color: AppColors.income,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: CustomPaint(
              size: const Size(double.infinity, 180),
              painter: CashFlowChartPainter(
                data: _dashboardData.cashflowHistory,
                isDark: isDark,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Pemasukan', AppColors.income),
              const SizedBox(width: 24),
              _buildLegendItem('Pengeluaran', AppColors.expense),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: List.generate(_periods.length, (index) {
            final isSelected = _selectedPeriodIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedPeriodIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _periods[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, bool isDark) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: AppColors.primaryBlue,
            unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'Transaksi'),
              Tab(text: 'Akun'),
              Tab(text: 'Kategori'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 320,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTransactionsTab(context, isDark),
              _buildAccountsTab(context, isDark),
              _buildCategoriesTab(context, isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsTab(BuildContext context, bool isDark) {
    final symbol = appSettings.currency == 'USD' ? '\$' : 'Rp';
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _dashboardData.recentTransactions.length,
      itemBuilder: (context, index) {
        final transaction = _dashboardData.recentTransactions[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withValues(alpha: 0.2) : AppColors.cardShadow,
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
                  color: transaction.categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  transaction.icon,
                  color: transaction.categoryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${transaction.category} • ${formatDate(transaction.date)}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${transaction.isIncome ? '+' : '-'}${formatCurrency(transaction.amount, symbol: symbol)}',
                style: TextStyle(
                  color: transaction.isIncome ? AppColors.income : AppColors.expense,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccountsTab(BuildContext context, bool isDark) {
    final symbol = appSettings.currency == 'USD' ? '\$' : 'Rp';
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _dashboardData.accounts.length,
      itemBuilder: (context, index) {
        final account = _dashboardData.accounts[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withValues(alpha: 0.2) : AppColors.cardShadow,
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
                  color: account.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getAccountIcon(account.type),
                  color: account.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getAccountTypeLabel(account.type),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                formatCurrency(account.balance, symbol: symbol),
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoriesTab(BuildContext context, bool isDark) {
    final symbol = appSettings.currency == 'USD' ? '\$' : 'Rp';
    final categories = _dashboardData.expenseByCategory.entries.toList();
    final total = categories.fold<double>(0, (sum, e) => sum + e.value);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final percentage = total > 0 ? (category.value / total * 100) : 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withValues(alpha: 0.2) : AppColors.cardShadow,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(index).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getCategoryIcon(index),
                      color: _getCategoryColor(index),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.key,
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (percentage / 100).clamp(0.0, 1.0),
                            backgroundColor: AppColors.textSecondary.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getCategoryColor(index),
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatCurrency(category.value, symbol: symbol),
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPortfolioSummary(BuildContext context, bool isDark) {
    final symbol = appSettings.currency == 'USD' ? '\$' : 'Rp';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.2) : AppColors.cardShadow,
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
              Text(
                'Portofolio Saham',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Membuka detail lengkap portofolio saham...')),
                  );
                },
                child: const Text(
                  'Lihat Detail',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Nilai',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatCurrency(_dashboardData.portfolioValue, symbol: symbol),
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _dashboardData.portfolioProfitLoss >= 0
                      ? AppColors.income.withValues(alpha: 0.1)
                      : AppColors.expense.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _dashboardData.portfolioProfitLoss >= 0
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      color: _dashboardData.portfolioProfitLoss >= 0
                          ? AppColors.income
                          : AppColors.expense,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${formatCurrency(_dashboardData.portfolioProfitLoss.abs(), symbol: symbol)} (${formatPercentage(_dashboardData.portfolioProfitLossPercent)})',
                      style: TextStyle(
                        color: _dashboardData.portfolioProfitLoss >= 0
                            ? AppColors.income
                            : AppColors.expense,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          ...List.generate(_dashboardData.topHoldings.length, (index) {
            final holding = _dashboardData.topHoldings[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        holding.symbol.substring(0, 2.clamp(0, holding.symbol.length)),
                        style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          holding.symbol,
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          holding.companyName,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatCurrency(holding.totalValue, symbol: symbol),
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formatPercentage(holding.profitLossPercent),
                        style: TextStyle(
                          color: holding.profitLossPercent >= 0
                              ? AppColors.income
                              : AppColors.expense,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSavingsGoals(BuildContext context, bool isDark) {
    final symbol = appSettings.currency == 'USD' ? '\$' : 'Rp';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Target Tabungan',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Membuka semua daftar target tabungan...')),
                  );
                },
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _dashboardData.savingsGoals.length,
            itemBuilder: (context, index) {
              final goal = _dashboardData.savingsGoals[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: goal.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: goal.color.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: goal.color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(goal.icon, color: goal.color, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                goal.name,
                                style: TextStyle(
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (goal.deadline != null)
                                Text(
                                  '${goal.daysRemaining} hari lagi',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: goal.progress,
                        backgroundColor: goal.color.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(goal.color),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formatCurrency(goal.currentAmount, symbol: symbol),
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${(goal.progress * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: goal.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'dari ${formatCurrency(goal.targetAmount, symbol: symbol)}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialInsights(BuildContext context, bool isDark) {
    final symbol = appSettings.currency == 'USD' ? '\$' : 'Rp';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accent.withValues(alpha: 0.1),
            AppColors.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: AppColors.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Wawasan Finansial',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInsightItem(
            icon: Icons.savings_rounded,
            title: 'Tabungan Optimal',
            description: 'Anda bisa menabung ${formatCurrency(6250000, symbol: symbol)} bulan ini jika mengurangi pengeluaran hiburan.',
            color: AppColors.secondary,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildInsightItem(
            icon: Icons.trending_up_rounded,
            title: 'Portofolio Bergerak Positif',
            description: 'Investasi Anda naik ${formatPercentage(_dashboardData.portfolioProfitLossPercent)} bulan ini. Pertimbangkan untuk melakukan diversifikasi.',
            color: AppColors.income,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildInsightItem(
            icon: Icons.warning_amber_rounded,
            title: 'Peringatan Budget',
            description: 'Pengeluaran makanan sudah mencapai 85% dari budget bulanan.',
            color: AppColors.warning,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getAccountIcon(String type) {
    switch (type) {
      case 'bank':
        return Icons.account_balance_rounded;
      case 'ewallet':
        return Icons.smartphone_rounded;
      case 'cash':
        return Icons.wallet_rounded;
      case 'savings':
        return Icons.savings_rounded;
      case 'investment':
        return Icons.trending_up_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }

  String _getAccountTypeLabel(String type) {
    switch (type) {
      case 'bank':
        return 'Rekening Bank';
      case 'ewallet':
        return 'E-Wallet';
      case 'cash':
        return 'Tunai';
      case 'savings':
        return 'Tabungan';
      case 'investment':
        return 'Investasi';
      default:
        return 'Lainnya';
    }
  }

  IconData _getCategoryIcon(int index) {
    const icons = [
      Icons.restaurant_rounded,
      Icons.directions_car_rounded,
      Icons.shopping_bag_rounded,
      Icons.movie_rounded,
      Icons.receipt_long_rounded,
      Icons.more_horiz_rounded,
    ];
    return icons[index % icons.length];
  }

  Color _getCategoryColor(int index) {
    const colors = [
      Color(0xFFEF4444),
      Color(0xFFF59E0B),
      Color(0xFF10B981),
      Color(0xFF8B5CF6),
      Color(0xFF6366F1),
      Color(0xFF94A3B8),
    ];
    return colors[index % colors.length];
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Notifikasi'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.savings_rounded, color: AppColors.secondary),
              title: Text('Target tercapai!'),
              subtitle: Text('Dana darurat sudah 75%'),
            ),
            ListTile(
              leading: Icon(Icons.trending_up_rounded, color: AppColors.income),
              title: Text('BBCA naik 3%'),
              subtitle: Text('Portofolio Anda untung'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  // Pengaturan Dialog yang Sekarang Berfungsi 100% (Tema, Bahasa, Mata Uang)
  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Pengaturan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.dark_mode_rounded),
                title: const Text('Tema Gelap'),
                trailing: Switch(
                  value: appSettings.themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    setDialogState(() {
                      appSettings.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                    });
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.language_rounded),
                title: const Text('Bahasa'),
                subtitle: Text(appSettings.language),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Pilih Bahasa'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: ['Indonesia', 'English'].map((lang) {
                          return ListTile(
                            title: Text(lang),
                            onTap: () {
                              appSettings.setLanguage(lang);
                              Navigator.pop(ctx);
                              setDialogState(() {});
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_money_rounded),
                title: const Text('Mata Uang'),
                subtitle: Text('${appSettings.currency} - ${appSettings.currency == 'IDR' ? 'Rupiah' : 'US Dollar'}'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Pilih Mata Uang'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: ['IDR', 'USD'].map((curr) {
                          return ListTile(
                            title: Text(curr),
                            onTap: () {
                              appSettings.setCurrency(curr);
                              Navigator.pop(ctx);
                              setDialogState(() {});
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        ),
      ),
    );
  }

  // Form Tambah Transaksi Interaktif Terhubung ke Dashboard State
  void _showAddTransactionDialog(BuildContext context, String type) {
    final isIncome = type == 'income';
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = isIncome ? 'Gaji' : 'Makanan';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isIncome ? 'Tambah Pemasukan' : 'Tambah Pengeluaran',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Jumlah',
                    prefixText: appSettings.currency == 'USD' ? '\$ ' : 'Rp ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Kategori', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (isIncome
                          ? ['Gaji', 'Freelance', 'Investasi', 'Hadiah', 'Lainnya']
                          : ['Makanan', 'Transport', 'Belanja', 'Hiburan', 'Kesehatan', 'Tagihan', 'Lainnya'])
                      .map((category) => ChoiceChip(
                            label: Text(category),
                            selected: selectedCategory == category,
                            onSelected: (selected) {
                              if (selected) {
                                setModalState(() => selectedCategory = category);
                              }
                            },
                          ))
                      .toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final val = double.tryParse(amountController.text) ?? 0.0;
                      if (val > 0) {
                        _addNewTransaction(type, val, selectedCategory, descriptionController.text);
                      }
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isIncome ? 'Pemasukan berhasil ditambahkan' : 'Pengeluaran berhasil ditambahkan',
                          ),
                          backgroundColor: isIncome ? AppColors.income : AppColors.expense,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isIncome ? AppColors.income : AppColors.expense,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Simpan',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Form Dialog Transfer Saldo Interaktif
  void _showTransferDialog(BuildContext context) {
    final amountController = TextEditingController();
    String fromAccount = _dashboardData.accounts.isNotEmpty ? _dashboardData.accounts.first.name : 'Bank BCA';
    String toAccount = _dashboardData.accounts.length > 1 ? _dashboardData.accounts[1].name : 'Tabungan';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Transfer',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Dari Akun', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: fromAccount,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: _dashboardData.accounts
                      .map((a) => DropdownMenuItem(
                            value: a.name,
                            child: Text(a.name),
                          ))
                      .toList(),
                  onChanged: (value) => setModalState(() => fromAccount = value!),
                ),
                const SizedBox(height: 16),
                const Text('Ke Akun', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: toAccount,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: _dashboardData.accounts
                      .where((a) => a.name != fromAccount)
                      .map((a) => DropdownMenuItem(
                            value: a.name,
                            child: Text(a.name),
                          ))
                      .toList(),
                  onChanged: (value) => setModalState(() => toAccount = value!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Jumlah',
                    prefixText: appSettings.currency == 'USD' ? '\$ ' : 'Rp ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final val = double.tryParse(amountController.text) ?? 0.0;
                      if (val > 0) {
                        _executeTransfer(fromAccount, toAccount, val);
                      }
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Transfer berhasil dilakukan'),
                          backgroundColor: AppColors.accent,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Transfer Sekarang',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Cash Flow Chart Painter
class CashFlowChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final bool isDark;

  CashFlowChartPainter({required this.data, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final padding = 40.0;
    final chartWidth = size.width - padding * 2;
    final chartHeight = size.height - padding * 2;

    final maxValue = data.fold<double>(0, (max, item) => math.max(max, (item['income'] as double?) ?? 0));
    final maxExpense = data.fold<double>(0, (max, item) => math.max(max, (item['expense'] as double?) ?? 0));
    final globalMax = math.max(maxValue, maxExpense);

    if (globalMax == 0) return;

    final incomePaint = Paint()
      ..color = AppColors.income
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final expensePaint = Paint()
      ..color = AppColors.expense
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final gridPaint = Paint()
      ..color = (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary).withValues(alpha: 0.2)
      ..strokeWidth = 1;

    for (var i = 0; i <= 4; i++) {
      final y = padding + (chartHeight / 4) * i;
      canvas.drawLine(
        Offset(padding, y),
        Offset(size.width - padding, y),
        gridPaint,
      );
    }

    final incomePath = Path();
    final expensePath = Path();

    for (var i = 0; i < data.length; i++) {
      final x = padding + (chartWidth / (data.length - 1).clamp(1, data.length)) * i;
      final incomeY = padding + chartHeight - ((data[i]['income'] as double?) ?? 0) / globalMax * chartHeight;
      final expenseY = padding + chartHeight - ((data[i]['expense'] as double?) ?? 0) / globalMax * chartHeight;

      if (i == 0) {
        incomePath.moveTo(x, incomeY);
        expensePath.moveTo(x, expenseY);
      } else {
        incomePath.lineTo(x, incomeY);
        expensePath.lineTo(x, expenseY);
      }
    }

    canvas.drawPath(incomePath, incomePaint);
    canvas.drawPath(expensePath, expensePaint);

    final incomeGradient = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.income.withValues(alpha: 0.3),
          AppColors.income.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final incomeFillPath = Path.from(incomePath)
      ..lineTo(padding + chartWidth, padding + chartHeight)
      ..lineTo(padding, padding + chartHeight)
      ..close();
    canvas.drawPath(incomeFillPath, incomeGradient);
  }

  @override
  bool shouldRepaint(covariant CashFlowChartPainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.isDark != isDark;
}