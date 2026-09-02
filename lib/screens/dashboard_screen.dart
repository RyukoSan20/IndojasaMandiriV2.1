import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const FinTrackApp());
}

class FinTrackApp extends StatelessWidget {
  const FinTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ),
        fontFamily: 'Inter',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Inter',
      ),
      themeMode: ThemeMode.system,
      home: const DashboardScreen(),
    );
  }
}

// ============================================================================
// DATA MODELS
// ============================================================================

class Account {
  final String id;
  final String name;
  final String type;
  final double balance;
  final String currency;
  final String icon;
  final String color;

  Account({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.currency,
    required this.icon,
    required this.color,
  });
}

class Transaction {
  final String id;
  final String type;
  final double amount;
  final String category;
  final String description;
  final DateTime date;
  final String? receiptUrl;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    this.receiptUrl,
  });
}

class SavingsGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final String icon;
  final String color;
  final double progress;

  SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    this.deadline,
    required this.icon,
    required this.color,
    required this.progress,
  });
}

class PortfolioHolding {
  final String symbol;
  final String companyName;
  final double shares;
  final double averagePrice;
  final double currentPrice;
  final double profitLoss;
  final double profitLossPercent;

  PortfolioHolding({
    required this.symbol,
    required this.companyName,
    required this.shares,
    required this.averagePrice,
    required this.currentPrice,
    required this.profitLoss,
    required this.profitLossPercent,
  });
}

class FinancialInsight {
  final String id;
  final String title;
  final String description;
  final String type;
  final IconData icon;
  final Color color;

  FinancialInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.icon,
    required this.color,
  });
}

class DashboardData {
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpense;
  final double totalSavings;
  final double portfolioValue;
  final double portfolioChange;
  final double portfolioChangePercent;
  final List<Account> accounts;
  final List<SavingsGoal> savingsGoals;
  final List<PortfolioHolding> portfolioHoldings;
  final List<FinancialInsight> insights;
  final List<CashFlowData> cashFlowData;
  final List<NetWorthData> netWorthHistory;

  DashboardData({
    required this.totalBalance,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.totalSavings,
    required this.portfolioValue,
    required this.portfolioChange,
    required this.portfolioChangePercent,
    required this.accounts,
    required this.savingsGoals,
    required this.portfolioHoldings,
    required this.insights,
    required this.cashFlowData,
    required this.netWorthHistory,
  });
}

class CashFlowData {
  final DateTime date;
  final double income;
  final double expense;

  CashFlowData({
    required this.date,
    required this.income,
    required this.expense,
  });
}

class NetWorthData {
  final DateTime date;
  final double netWorth;

  NetWorthData({
    required this.date,
    required this.netWorth,
  });
}

// ============================================================================
// MOCK DATA PROVIDER
// ============================================================================

class MockDataProvider {
  static DashboardData getDashboardData() {
    final currencyFormat = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);
    
    return DashboardData(
      totalBalance: 45500000,
      monthlyIncome: 12500000,
      monthlyExpense: 8750000,
      totalSavings: 28000000,
      portfolioValue: 18500000,
      portfolioChange: 450000,
      portfolioChangePercent: 2.5,
      accounts: [
        Account(
          id: '1',
          name: 'Bank BCA',
          type: 'bank',
          balance: 25000000,
          currency: 'IDR',
          icon: 'account_balance',
          color: '#1E3A5F',
        ),
        Account(
          id: '2',
          name: 'OVO',
          type: 'ewallet',
          balance: 3500000,
          currency: 'IDR',
          icon: 'smartphone',
          color: '#6B3FA0',
        ),
        Account(
          id: '3',
          name: 'Cash',
          type: 'cash',
          balance: 500000,
          currency: 'IDR',
          icon: 'wallet',
          color: '#10B981',
        ),
        Account(
          id: '4',
          name: 'Tabungan',
          type: 'savings',
          balance: 16500000,
          currency: 'IDR',
          icon: 'savings',
          color: '#F59E0B',
        ),
      ],
      savingsGoals: [
        SavingsGoal(
          id: '1',
          name: 'Dana Darurat',
          targetAmount: 36000000,
          currentAmount: 18000000,
          deadline: DateTime(2024, 12, 31),
          icon: 'shield',
          color: '#2563EB',
          progress: 0.5,
        ),
        SavingsGoal(
          id: '2',
          name: 'Liburan',
          targetAmount: 10000000,
          currentAmount: 7000000,
          deadline: DateTime(2024, 6, 30),
          icon: 'flight',
          color: '#10B981',
          progress: 0.7,
        ),
        SavingsGoal(
          id: '3',
          name: 'Gadget Baru',
          targetAmount: 15000000,
          currentAmount: 3000000,
          deadline: DateTime(2024, 8, 1),
          icon: 'devices',
          color: '#8B5CF6',
          progress: 0.2,
        ),
      ],
      portfolioHoldings: [
        PortfolioHolding(
          symbol: 'BBCA',
          companyName: 'Bank Central Asia',
          shares: 100,
          averagePrice: 8500,
          currentPrice: 9200,
          profitLoss: 70000,
          profitLossPercent: 8.24,
        ),
        PortfolioHolding(
          symbol: 'TLKM',
          companyName: 'Telkom Indonesia',
          shares: 200,
          averagePrice: 3100,
          currentPrice: 2950,
          profitLoss: -30000,
          profitLossPercent: -4.84,
        ),
        PortfolioHolding(
          symbol: 'AMMN',
          companyName: 'Ammann Mineral',
          shares: 50,
          averagePrice: 12000,
          currentPrice: 13500,
          profitLoss: 75000,
          profitLossPercent: 12.5,
        ),
      ],
      insights: [
        FinancialInsight(
          id: '1',
          title: 'Tren Pengeluaran Meningkat',
          description: 'Pengeluaran Anda meningkat 15% dibanding bulan lalu. Kategori terbesar adalah makanan dan transportasi.',
          type: 'warning',
          icon: Icons.trending_up,
          color: const Color(0xFFF59E0B),
        ),
        FinancialInsight(
          id: '2',
          title: 'Target Terdepan',
          description: 'Anda hanyaRp 3.000.000 lagi untuk mencapai target liburan. Terus semangat!',
          type: 'success',
          icon: Icons.flag,
          color: const Color(0xFF10B981),
        ),
        FinancialInsight(
          id: '3',
          title: 'Portofolio Berkembang',
          description: 'Investasi Anda sudah naik 12% sejak awal tahun. Pertimbangkan untuk diversifikasi.',
          type: 'info',
          icon: Icons.trending_up,
          color: const Color(0xFF2563EB),
        ),
      ],
      cashFlowData: List.generate(7, (index) {
        final date = DateTime.now().subtract(Duration(days: 6 - index));
        return CashFlowData(
          date: date,
          income: (index + 1) * 1500000 + (index.isEven ? 500000 : 0),
          expense: (index + 1) * 800000 + (index.isOdd ? 300000 : 0),
        );
      }),
      netWorthHistory: List.generate(30, (index) {
        final date = DateTime.now().subtract(Duration(days: 29 - index));
        return NetWorthData(
          date: date,
          netWorth: 40000000 + (index * 150000) + (index % 3 == 0 ? 500000 : 0),
        );
      }),
    );
  }
}

// ============================================================================
// CURRENCY FORMATTER
// ============================================================================

class CurrencyFormatter {
  static final NumberFormat _idrFormat = NumberFormat.currency(
    symbol: 'Rp ',
    decimalDigits: 0,
    locale: 'id_ID',
  );

  static final NumberFormat _compactFormat = NumberFormat.compact(
    locale: 'id_ID',
  );

  static String format(double amount) {
    return _idrFormat.format(amount);
  }

  static String formatCompact(double amount) {
    if (amount >= 1000000) {
      return 'Rp ${_compactFormat.format(amount)}';
    }
    return format(amount);
  }

  static String formatWithSign(double amount) {
    final prefix = amount >= 0 ? '+' : '';
    return '$prefix${_idrFormat.format(amount)}';
  }

  static String formatPercent(double percent) {
    final prefix = percent >= 0 ? '+' : '';
    return '$prefix${percent.toStringAsFixed(2)}%';
  }
}

// ============================================================================
// THEME CONFIGURATION
// ============================================================================

class AppColors {
  // Light Theme Colors
  static const Color primaryLight = Color(0xFF2563EB);
  static const Color primaryDarkLight = Color(0xFF1D4ED8);
  static const Color secondaryLight = Color(0xFF10B981);
  static const Color accentLight = Color(0xFFF59E0B);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF1E293B);
  static const Color textSecondaryLight = Color(0xFF64748B);
  
  // Dark Theme Colors
  static const Color primaryDark = Color(0xFF3B82F6);
  static const Color primaryDarkDark = Color(0xFF2563EB);
  static const Color secondaryDark = Color(0xFF34D399);
  static const Color accentDark = Color(0xFFFBBF24);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  
  // Semantic Colors
  static const Color income = Color(0xFF10B981);
  static const Color expense = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFEAB308);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF2563EB);

  // Account Type Colors
  static const Map<String, Color> accountColors = {
    'cash': Color(0xFF10B981),
    'bank': Color(0xFF2563EB),
    'ewallet': Color(0xFF8B5CF6),
    'savings': Color(0xFFF59E0B),
    'investment': Color(0xFFEC4899),
  };
}

// ============================================================================
// DASHBOARD SCREEN - MAIN WIDGET
// ============================================================================

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DashboardData _dashboardData;
  bool _isLoading = true;
  int _selectedPeriod = 0; // 0: Week, 1: Month, 2: Year
  bool _showNetWorthChart = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (mounted) {
      setState(() {
        _dashboardData = MockDataProvider.getDashboardData();
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshDashboard() async {
    await _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDarkMode 
          ? AppColors.backgroundDark 
          : AppColors.backgroundLight,
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        color: colorScheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildAppBar(context, isDarkMode, colorScheme),
            SliverToBoxAdapter(
              child: _isLoading
                  ? _buildLoadingState()
                  : _buildDashboardContent(context, isDarkMode, colorScheme),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildQuickActionFAB(context, colorScheme),
    );
  }

  Widget _buildAppBar(
    BuildContext context, 
    bool isDarkMode, 
    ColorScheme colorScheme,
  ) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: isDarkMode ? AppColors.backgroundDark : colorScheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat Pagi,',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const Text(
              'John Doe',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () => _showNotifications(context),
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: () => _showSettings(context),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context, 
    bool isDarkMode, 
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Financial Summary Cards
          _buildFinancialSummarySection(context, isDarkMode, colorScheme),
          const SizedBox(height: 24),
          
          // Cash Flow Chart
          _buildCashFlowChartSection(context, isDarkMode, colorScheme),
          const SizedBox(height: 24),
          
          // Net Worth Chart
          _buildNetWorthChartSection(context, isDarkMode, colorScheme),
          const SizedBox(height: 24),
          
          // Accounts Section
          _buildAccountsSection(context, isDarkMode, colorScheme),
          const SizedBox(height: 24),
          
          // Savings Goals Section
          _buildSavingsGoalsSection(context, isDarkMode, colorScheme),
          const SizedBox(height: 24),
          
          // Portfolio Section
          _buildPortfolioSection(context, isDarkMode, colorScheme),
          const SizedBox(height: 24),
          
          // AI Insights Section
          _buildInsightsSection(context, isDarkMode, colorScheme),
          const SizedBox(height: 24),
          
          // Recent Transactions
          _buildRecentTransactionsSection(context, isDarkMode, colorScheme),
          const SizedBox(height: 100), // Space for FAB
        ],
      ),
    );
  }

  // =========================================================================
  // FINANCIAL SUMMARY SECTION
  // =========================================================================

  Widget _buildFinancialSummarySection(
    BuildContext context, 
    bool isDarkMode, 
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ringkasan Keuangan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode 
                ? AppColors.textPrimaryDark 
                : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 16),
        
        // Total Balance Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary,
                colorScheme.primary.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.3),
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
                    'Total Saldo',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
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
                        const Icon(
                          Icons.visibility_outlined,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isDarkMode ? 'Tersembunyi' : 'Tampil',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                CurrencyFormatter.format(_dashboardData.totalBalance),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Aset + Investasi',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Summary Cards Row
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                title: 'Pemasukan',
                amount: _dashboardData.monthlyIncome,
                icon: Icons.arrow_downward_rounded,
                iconColor: AppColors.income,
                isDarkMode: isDarkMode,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                context,
                title: 'Pengeluaran',
                amount: _dashboardData.monthlyExpense,
                icon: Icons.arrow_upward_rounded,
                iconColor: AppColors.expense,
                isDarkMode: isDarkMode,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                title: 'Tabungan',
                amount: _dashboardData.totalSavings,
                icon: Icons.savings_outlined,
                iconColor: AppColors.accentLight,
                isDarkMode: isDarkMode,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                context,
                title: 'Portofolio',
                amount: _dashboardData.portfolioValue,
                change: _dashboardData.portfolioChangePercent,
                icon: Icons.trending_up_rounded,
                iconColor: colorScheme.primary,
                isDarkMode: isDarkMode,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required double amount,
    required IconData icon,
    required Color iconColor,
    required bool isDarkMode,
    double? change,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
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
              if (change != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: change >= 0 
                        ? AppColors.income.withOpacity(0.1)
                        : AppColors.expense.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    CurrencyFormatter.formatPercent(change),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: change >= 0 ? AppColors.income : AppColors.expense,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode 
                  ? AppColors.textSecondaryDark 
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.formatCompact(amount),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode 
                  ? AppColors.textPrimaryDark 
                  : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // CASH FLOW CHART SECTION
  // =========================================================================

  Widget _buildCashFlowChartSection(
    BuildContext context, 
    bool isDarkMode, 
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Arus Kas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode 
                    ? AppColors.textPrimaryDark 
                    : AppColors.textPrimaryLight,
              ),
            ),
            _buildPeriodSelector(isDarkMode),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 220,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem('Pemasukan', AppColors.income),
                  const SizedBox(width: 24),
                  _buildLegendItem('Pengeluaran', AppColors.expense),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _getMaxCashFlowValue(),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (group) => isDarkMode 
                            ? AppColors.surfaceDark 
                            : Colors.grey[800]!,
                        tooltipPadding: const EdgeInsets.all(8),
                        tooltipMargin: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final data = _dashboardData.cashFlowData[group.x.toInt()];
                          final isIncome = rodIndex == 0;
                          return BarTooltipItem(
                            '${isIncome ? 'Pemasukan' : 'Pengeluaran'}\n',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            children: [
                              TextSpan(
                                text: CurrencyFormatter.formatCompact(
                                  isIncome ? data.income : data.expense,
                                ),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < _dashboardData.cashFlowData.length) {
                              final dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  dayNames[index % 7],
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDarkMode 
                                        ? AppColors.textSecondaryDark 
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                          reservedSize: 28,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              CurrencyFormatter.formatCompact(value),
                              style: TextStyle(
                                fontSize: 10,
                                color: isDarkMode 
                                    ? AppColors.textSecondaryDark 
                                    : AppColors.textSecondaryLight,
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: _getMaxCashFlowValue() / 4,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: isDarkMode 
                              ? Colors.white.withOpacity(0.1) 
                              : Colors.grey.withOpacity(0.1),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: _buildCashFlowBarGroups(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _buildCashFlowBarGroups() {
    return _dashboardData.cashFlowData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data.income,
            color: AppColors.income,
            width: 12,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
          BarChartRodData(
            toY: data.expense,
            color: AppColors.expense,
            width: 12,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
  }

  double _getMaxCashFlowValue() {
    double maxValue = 0;
    for (var data in _dashboardData.cashFlowData) {
      if (data.income > maxValue) maxValue = data.income;
      if (data.expense > maxValue) maxValue = data.expense;
    }
    return maxValue * 1.2;
  }

  Widget _buildPeriodSelector(bool isDarkMode) {
    final periods = ['Minggu', 'Bulan', 'Tahun'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? AppColors.surfaceDark 
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: periods.asMap().entries.map((entry) {
          final index = entry.key;
          final period = entry.value;
          final isSelected = _selectedPeriod == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedPeriod = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary 
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                period,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected 
                      ? Colors.white 
                      : (isDarkMode 
                          ? AppColors.textSecondaryDark 
                          : AppColors.textSecondaryLight),
                ),
              ),
            ),
          );
        }).toList(),
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
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  // =========================================================================
  // NET WORTH CHART SECTION
  // =========================================================================

  Widget _buildNetWorthChartSection(
    BuildContext context, 
    bool isDarkMode, 
    ColorScheme colorScheme,
  ) {
    final netWorth = _dashboardData.totalBalance + _dashboardData.portfolioValue;
    final previousNetWorth = netWorth * 0.95;
    final change = netWorth - previousNetWorth;
    final changePercent = (change / previousNetWorth) * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Kekayaan Bersih',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode 
                    ? AppColors.textPrimaryDark 
                    : AppColors.textPrimaryLight,
              ),
            ),
            TextButton.icon(
              onPressed: () => setState(() => _showNetWorthChart = !_showNetWorthChart),
              icon: Icon(
                _showNetWorthChart 
                    ? Icons.show_chart 
                    : Icons.hide_image_outlined,
                size: 18,
              ),
              label: Text(_showNetWorthChart ? 'Sembunyikan' : 'Tampilkan'),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyFormatter.format(netWorth),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDarkMode 
                    ? AppColors.textPrimaryDark 
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: change >= 0 
                    ? AppColors.income.withOpacity(0.1)
                    : AppColors.expense.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(
                    change >= 0 
                        ? Icons.trending_up_rounded 
                        : Icons.trending_down_rounded,
                    size: 14,
                    color: change >= 0 ? AppColors.income : AppColors.expense,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${CurrencyFormatter.formatWithSign(changePercent)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: change >= 0 ? AppColors.income : AppColors.expense,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Text(
          'Bulan ini',
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode 
                ? AppColors.textSecondaryDark 
                : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 16),
        
        if (_showNetWorthChart)
          Container(
            height: 180,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: netWorth * 0.05,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: isDarkMode 
                          ? Colors.white.withOpacity(0.1) 
                          : Colors.grey.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 7,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() % 7 == 0) {
                          final date = DateTime.now().subtract(
                            Duration(days: 29 - value.toInt()),
                          );
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat('d/M').format(date),
                              style: TextStyle(
                                fontSize: 10,
                                color: isDarkMode 
                                    ? AppColors.textSecondaryDark 
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: netWorth * 0.9,
                maxY: netWorth * 1.05,
                lineBarsData: [
                  LineChartBarData(
                    spots: _dashboardData.netWorthHistory.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.netWorth);
                    }).toList(),
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: colorScheme.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colorScheme.primary.withOpacity(0.3),
                          colorScheme.primary.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (spot) => isDarkMode 
                        ? AppColors.surfaceDark 
                        : Colors.grey[800]!,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          CurrencyFormatter.format(spot.y),
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // =========================================================================
  // ACCOUNTS SECTION
  // =========================================================================

  Widget _buildAccountsSection(
    BuildContext context, 
    bool isDarkMode, 
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Akun Keuangan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode 
                    ? AppColors.textPrimaryDark 
                    : AppColors.textPrimaryLight,
              ),
            ),
            TextButton(
              onPressed: () => _navigateToAccounts(context),
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _dashboardData.accounts.length,
            itemBuilder: (context, index) {
              final account = _dashboardData.accounts[index];
              return _buildAccountCard(context, account, isDarkMode, colorScheme);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAccountCard(
    BuildContext context, 
    Account account, 
    bool isDarkMode, 
    ColorScheme colorScheme,
  ) {
    final accountColor = AppColors.accountColors[account.type] ?? colorScheme.primary;
    
    return Container(
      width: 160,
      margin: EdgeInsets.only(right: index == _dashboardData.accounts.length - 1 ? 0 : 12),
      child: _AccountCardContent(
        account: account,
        accountColor: accountColor,
        isDarkMode: isDarkMode,
      ),
    );
  }

  int get index => 0;

  Widget _buildAccountCard2(
    BuildContext context, 
    Account account, 
    bool isDarkMode, 
    ColorScheme colorScheme,
  ) {
    final accountColor = AppColors.accountColors[account.type] ?? colorScheme.primary;
    
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
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
                  color: accountColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getAccountIcon(account.type),
                  size: 20,
                  color: accountColor,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: accountColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getAccountTypeLabel(account.type),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: accountColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            account.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDarkMode 
                  ? AppColors.textPrimaryDark 
                  : AppColors.textPrimaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.formatCompact(account.balance),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode 
                  ? AppColors.textPrimaryDark 
                  : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getAccountIcon(String type) {
    switch (type) {
      case 'cash':
        return Icons.wallet_outlined;
      case 'bank':
        return Icons.account_balance_outlined;
      case 'ewallet':
        return Icons.phone_android_outlined;
      case 'savings':
        return Icons.savings_outlined;
      case 'investment':
        return Icons.trending_up_outlined;
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }

  String _getAccountTypeLabel(String type) {
    switch (type) {
      case 'cash':
        return 'Tunai';
      case 'bank':
        return 'Bank';
      case 'ewallet':
        return 'E-Wallet';
      case 'savings':
        return 'Tabungan';
      case 'investment':
        return 'Investasi';
      default:
        return type;
    }
  }

  // =========================================================================
  // SAVINGS GOALS SECTION
  // =========================================================================

  Widget _buildSavingsGoalsSection(
    BuildContext context, 
    bool isDarkMode, 
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Target Tabungan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode 
                    ? AppColors.textPrimaryDark 
                    : AppColors.textPrimaryLight,
              ),
            ),
            TextButton(
              onPressed: () => _navigateToSavingsGoals(context),
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(_dashboardData.savingsGoals.length, (index) {
          final goal = _dashboardData.savingsGoals[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildSavingsGoalCard(context, goal, isDarkMode, colorScheme),
          );
        }),
      ],
    );
  }

  Widget _buildSavingsGoalCard(
    BuildContext context, 
    SavingsGoal goal, 
    bool isDarkMode, 
    ColorScheme colorScheme,
  ) {
    final goalColor = Color(int.parse(goal.color.replaceFirst('#', '0xFF')));
    final remaining = goal.targetAmount - goal.currentAmount;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
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
                  color: goalColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getGoalIcon(goal.icon),
                  size: 24,
                  color: goalColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode 
                            ? AppColors.textPrimaryDark 
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sisa ${CurrencyFormatter.formatCompact(remaining)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode 
                            ? AppColors.textSecondaryDark 
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(goal.progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: goalColor,
                    ),
                  ),
                  if (goal.deadline != null)
                    Text(
                      DateFormat('d MMM').format(goal.deadline!),
                      style: TextStyle(
                        fontSize: 10,
                        color: isDarkMode 
                            ? AppColors.textSecondaryDark 
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: goal.progress,
              backgroundColor: goalColor.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(goalColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                CurrencyFormatter.formatCompact(goal.currentAmount),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode 
                      ? AppColors.textSecondaryDark 
                      : AppColors.textSecondaryLight,
                ),
              ),
              Text(
                CurrencyFormatter.formatCompact(goal.targetAmount),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode 
                      ? AppColors.textSecondaryDark 
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getGoalIcon(String icon) {
    switch (icon) {
      case 'shield':
        return Icons.shield_outlined;
      case 'flight':
        return Icons.flight_outlined;
      case 'devices':
        return Icons.devices_outlined;
      case 'home':
        return Icons.home_outlined;
      case 'car':
        return Icons.directions_car_outlined;
      default:
        return Icons.flag_outlined;
    }
  }

  // =========================================================================
  // PORTFOLIO SECTION
  // =========================================================================

  Widget _buildPortfolioSection(
    BuildContext context, 
    bool isDarkMode, 
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Portofolio Saham',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode 
                    ? AppColors.textPrimaryDark 
                    : AppColors.textPrimaryLight,
              ),
            ),
            TextButton(
              onPressed: () => _navigateToPortfolio(context),
              child: const Text('Lihat Detail'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Nilai',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode 
                                ? AppColors.textSecondaryDark 
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.format(_dashboardData.portfolioValue),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode 
                                ? AppColors.textPrimaryDark 
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _dashboardData.portfolioChange >= 0
                          ? AppColors.income.withOpacity(0.1)
                          : AppColors.expense.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _dashboardData.portfolioChange >= 0
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          size: 16,
                          color: _dashboardData.portfolioChange >= 0
                              ? AppColors.income
                              : AppColors.expense,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          CurrencyFormatter.formatPercent(
                            _dashboardData.portfolioChangePercent,
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _dashboardData.portfolioChange >= 0
                                ? AppColors.income
                                : AppColors.expense,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              ...List.generate(
                _dashboardData.portfolioHoldings.length > 3 
                    ? 3 
                    : _dashboardData.portfolioHoldings.length,
                (index) => _buildHoldingItem(
                  context,
                  _dashboardData.portfolioHoldings[index],
                  isDarkMode,
                  colorScheme,
                ),
              ),
              if (_dashboardData.portfolioHoldings.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextButton(
                    onPressed: () => _navigateToPortfolio(context),
                    child: Text(
                      '+${_dashboardData.portfolioHoldings.length - 3} lainnya',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHoldingItem(
    BuildContext context, 
    PortfolioHolding holding, 
    bool isDarkMode, 
    ColorScheme colorScheme,
  ) {
    final isPositive = holding.profitLoss >= 0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                holding.symbol.substring(0, holding.symbol.length > 4 ? 4 : holding.symbol.length),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode 
                        ? AppColors.textPrimaryDark 
                        : AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  '${holding.shares.toStringAsFixed(0)} lot @ ${CurrencyFormatter.formatCompact(holding.averagePrice)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDarkMode 
                        ? AppColors.textSecondaryDark 
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.formatCompact(
                  holding.currentPrice * holding.shares,
                ),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode 
                      ? AppColors.textPrimaryDark 
                      : AppColors.textPrimaryLight,
                ),
              ),
              Text(
                CurrencyFormatter.formatPercent(holding.profitLossPercent),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isPositive ? AppColors.income : AppColors.expense,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // AI INSIGHTS SECTION
  // =========================================================================

  Widget _buildInsightsSection(
    BuildContext context, 
    bool isDarkMode, 
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 20,
                color: AppColors.info,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Insight Finansial',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode 
                    ? AppColors.textPrimaryDark 
                    : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...List.generate(_dashboardData.insights.length, (index) {
          final insight = _dashboardData.insights[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildInsightCard(context, insight, isDarkMode),
          );
        }),
      ],
    );
  }

  Widget _buildInsightCard(
    BuildContext context, 
    FinancialInsight insight, 
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: insight.color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: insight.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              insight.icon,
              size: 24,
              color: insight.color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode 
                        ? AppColors.textPrimaryDark 
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode 
                        ? AppColors.textSecondaryDark 
                        : AppColors.textSecondaryLight,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // RECENT TRANSACTIONS SECTION
  // =========================================================================

  Widget _buildRecentTransactionsSection(
    BuildContext context, 
    bool isDarkMode, 
    ColorScheme colorScheme,
  ) {
    // Generate sample recent transactions
    final recentTransactions = [
      Transaction(
        id: '1',
        type: 'expense',
        amount: 75000,
        category: 'Makanan',
        description: 'Makan siang kantor',
        date: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Transaction(
        id: '2',
        type: 'income',
        amount: 500000,
        category: 'Freelance',
        description: 'Pembayaran project design',
        date: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Transaction(
        id: '3',
        type: 'expense',
        amount: 250000,
        category: 'Transportasi',
        description: 'Bensin motor',
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Transaction(
        id: '4',
        type: 'expense',
        amount: 150000,
        category: 'Belanja',
        description: 'Groceries mingguan',
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Transaction(
        id: '5',
        type: 'income',
        amount: 12500000,
        category: 'Gaji',
        description: 'Gaji Bulanan',
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Transaksi Terbaru',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode 
                    ? AppColors.textPrimaryDark 
                    : AppColors.textPrimaryLight,
              ),
            ),
            TextButton(
              onPressed: () => _navigateToTransactions(context),
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: List.generate(recentTransactions.length, (index) {
              final transaction = recentTransactions[index];
              final isLast = index == recentTransactions.length - 1;
              return _buildTransactionItem(
                context, 
                transaction, 
                isDarkMode, 
                colorScheme,
                isLast: isLast,
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(
    BuildContext context, 
    Transaction transaction, 
    bool isDarkMode, 
    ColorScheme colorScheme, {
    required bool isLast,
  }) {
    final isIncome = transaction.type == 'income';
    
    return Container(
      decoration: BoxDecoration(
        border: isLast 
            ? null 
            : Border(
                bottom: BorderSide(
                  color: isDarkMode 
                      ? Colors.white.withOpacity(0.1) 
                      : Colors.grey.withOpacity(0.1),
                ),
              ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: (isIncome ? AppColors.income : AppColors.expense).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isIncome 
                ? Icons.arrow_downward_rounded 
                : Icons.arrow_upward_rounded,
            color: isIncome ? AppColors.income : AppColors.expense,
          ),
        ),
        title: Text(
          transaction.description,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDarkMode 
                ? AppColors.textPrimaryDark 
                : AppColors.textPrimaryLight,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${transaction.category} • ${_formatTransactionDate(transaction.date)}',
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode 
                ? AppColors.textSecondaryDark 
                : AppColors.textSecondaryLight,
          ),
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'}${CurrencyFormatter.formatCompact(transaction.amount)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isIncome ? AppColors.income : AppColors.expense,
          ),
        ),
        onTap: () => _showTransactionDetails(context, transaction),
      ),
    );
  }

  String _formatTransactionDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inHours < 24 && date.day == now.day) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return DateFormat('d MMM').format(date);
    }
  }

  // =========================================================================
  // FLOATING ACTION BUTTON
  // =========================================================================

  Widget _buildQuickActionFAB(BuildContext context, ColorScheme colorScheme) {
    return FloatingActionButton.extended(
      onPressed: () => _showQuickActionsSheet(context),
      backgroundColor: colorScheme.primary,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Tambah'),
    );
  }

  // =========================================================================
  // NAVIGATION & ACTIONS
  // =========================================================================

  void _navigateToAccounts(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigasi ke halaman Akun')),
    );
  }

  void _navigateToSavingsGoals(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigasi ke halaman Target Tabungan')),
    );
  }

  void _navigateToPortfolio(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigasi ke halaman Portofolio')),
    );
  }

  void _navigateToTransactions(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigasi ke halaman Transaksi')),
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildNotificationsSheet(context),
    );
  }

  void _showSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigasi ke halaman Settings')),
    );
  }

  void _showTransactionDetails(BuildContext context, Transaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTransactionDetailsSheet(context, transaction),
    );
  }

  void _showQuickActionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildQuickActionsSheet(context),
    );
  }

  Widget _buildNotificationsSheet(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.backgroundDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notifikasi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode 
                        ? AppColors.textPrimaryDark 
                        : AppColors.textPrimaryLight,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Tandai semua dibaca'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildNotificationItem(
                  context,
                  icon: Icons.savings_outlined,
                  iconColor: AppColors.income,
                  title: 'Target tercapai!',
                  message: 'Anda telah mencapai 50% target Dana Darurat',
                  time: '2 jam yang lalu',
                  isDarkMode: isDarkMode,
                ),
                _buildNotificationItem(
                  context,
                  icon: Icons.trending_up_rounded,
                  iconColor: AppColors.info,
                  title: 'Portofolio naik',
                  message: 'Investasi Anda naik 2.5% hari ini',
                  time: '5 jam yang lalu',
                  isDarkMode: isDarkMode,
                ),
                _buildNotificationItem(
                  context,
                  icon: Icons.warning_amber_rounded,
                  iconColor: AppColors.warning,
                  title: 'Pengeluaran tinggi',
                  message: 'Pengeluaran makanan meningkat 20% minggu ini',
                  time: '1 hari yang lalu',
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String time,
    required bool isDarkMode,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode 
                        ? AppColors.textPrimaryDark 
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode 
                        ? AppColors.textSecondaryDark 
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDarkMode 
                        ? AppColors.textSecondaryDark 
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetailsSheet(
    BuildContext context, 
    Transaction transaction,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isIncome = transaction.type == 'income';
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.backgroundDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isIncome ? AppColors.income : AppColors.expense).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncome 
                  ? Icons.arrow_downward_rounded 
                  : Icons.arrow_upward_rounded,
              size: 32,
              color: isIncome ? AppColors.income : AppColors.expense,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${isIncome ? '+' : '-'}${CurrencyFormatter.format(transaction.amount)}',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isIncome ? AppColors.income : AppColors.expense,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            transaction.description,
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode 
                  ? AppColors.textPrimaryDark 
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 24),
          _buildDetailRow('Kategori', transaction.category, isDarkMode),
          _buildDetailRow(
            'Tanggal', 
            DateFormat('EEEE, d MMMM yyyy • HH:mm').format(transaction.date),
            isDarkMode,
          ),
          _buildDetailRow('Akun', 'Bank BCA', isDarkMode),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Edit transaksi')),
                    );
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Hapus transaksi')),
                    );
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Hapus'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.expense,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode 
                  ? AppColors.textSecondaryDark 
                  : AppColors.textSecondaryLight,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDarkMode 
                  ? AppColors.textPrimaryDark 
                  : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSheet(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.backgroundDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Tambah Transaksi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode 
                  ? AppColors.textPrimaryDark 
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  context,
                  icon: Icons.arrow_downward_rounded,
                  label: 'Pemasukan',
                  color: AppColors.income,
                  onTap: () {
                    Navigator.pop(context);
                    _showAddTransactionDialog(context, isIncome: true);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionButton(
                  context,
                  icon: Icons.arrow_upward_rounded,
                  label: 'Pengeluaran',
                  color: AppColors.expense,
                  onTap: () {
                    Navigator.pop(context);
                    _showAddTransactionDialog(context, isIncome: false);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: _buildQuickActionButton(
              context,
              icon: Icons.swap_horiz_rounded,
              label: 'Transfer',
              color: AppColors.info,
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur Transfer')),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: _buildQuickActionButton(
              context,
              icon: Icons.show_chart_rounded,
              label: 'Catat Investasi',
              color: AppColors.accentLight,
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur Catat Investasi')),
                );
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode 
                      ? AppColors.textPrimaryDark 
                      : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context, {required bool isIncome}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isIncome ? 'Tambah Pemasukan' : 'Tambah Pengeluaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Jumlah',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
              items: isIncome
                  ? [
                      const DropdownMenuItem(value: 'gaji', child: Text('Gaji')),
                      const DropdownMenuItem(value: 'freelance', child: Text('Freelance')),
                      const DropdownMenuItem(value: 'investasi', child: Text('Investasi')),
                    ]
                  : [
                      const DropdownMenuItem(value: 'makanan', child: Text('Makanan')),
                      const DropdownMenuItem(value: 'transportasi', child: Text('Transportasi')),
                      const DropdownMenuItem(value: 'belanja', child: Text('Belanja')),
                      const DropdownMenuItem(value: 'hiburan', child: Text('Hiburan')),
                    ],
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
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
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ACCOUNT CARD CONTENT (Stateful Widget for index access)
// ============================================================================

class _AccountCardContent extends StatelessWidget {
  final Account account;
  final Color accountColor;
  final bool isDarkMode;

  const _AccountCardContent({
    required this.account,
    required this.accountColor,
    required this.isDarkMode,
  });

  IconData _getAccountIcon(String type) {
    switch (type) {
      case 'cash':
        return Icons.wallet_outlined;
      case 'bank':
        return Icons.account_balance_outlined;
      case 'ewallet':
        return Icons.phone_android_outlined;
      case 'savings':
        return Icons.savings_outlined;
      case 'investment':
        return Icons.trending_up_outlined;
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }

  String _getAccountTypeLabel(String type) {
    switch (type) {
      case 'cash':
        return 'Tunai';
      case 'bank':
        return 'Bank';
      case 'ewallet':
        return 'E-Wallet';
      case 'savings':
        return 'Tabungan';
      case 'investment':
        return 'Investasi';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
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
                  color: accountColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getAccountIcon(account.type),
                  size: 20,
                  color: accountColor,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: accountColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getAccountTypeLabel(account.type),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: accountColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            account.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDarkMode 
                  ? AppColors.textPrimaryDark 
                  : AppColors.textPrimaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.formatCompact(account.balance),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode 
                  ? AppColors.textPrimaryDark 
                  : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
