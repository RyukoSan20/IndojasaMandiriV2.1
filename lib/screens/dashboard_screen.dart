import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction_model.dart';
import '../models/account_model.dart';
import '../models/savings_goal_model.dart';
import '../models/portfolio_model.dart';
import '../services/finance_service.dart';
import '../widgets/summary_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/cashflow_chart.dart';
import '../widgets/portfolio_card.dart';
import '../widgets/insight_card.dart';
import '../widgets/transaction_list_item.dart';
import '../theme/app_theme.dart';

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

  // Dashboard data
  double _totalBalance = 0;
  double _monthlyIncome = 0;
  double _monthlyExpense = 0;
  double _totalSavings = 0;
  double _portfolioValue = 0;
  double _portfolioChange = 0;
  double _portfolioChangePercent = 0;

  List<TransactionModel> _recentTransactions = [];
  List<AccountModel> _accounts = [];
  List<SavingsGoalModel> _savingsGoals = [];
  List<PortfolioHolding> _portfolioHoldings = [];
  List<Map<String, dynamic>> _cashflowData = [];
  List<Map<String, dynamic>> _networthHistory = [];
  List<FinancialInsight> _insights = [];

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final NumberFormat _compactCurrencyFormat = NumberFormat.compactCurrency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

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
    setState(() => _isLoading = true);

    try {
      final financeService = FinanceService();

      // Load all dashboard data in parallel
      final results = await Future.wait([
        financeService.getTotalBalance(),
        financeService.getMonthlyIncome(),
        financeService.getMonthlyExpense(),
        financeService.getTotalSavings(),
        financeService.getPortfolioSummary(),
        financeService.getRecentTransactions(limit: 5),
        financeService.getAccounts(),
        financeService.getSavingsGoals(),
        financeService.getPortfolioHoldings(),
        financeService.getCashflowData(),
        financeService.getNetworthHistory(),
        financeService.getFinancialInsights(),
      ]);

      setState(() {
        _totalBalance = results[0] as double;
        _monthlyIncome = results[1] as double;
        _monthlyExpense = results[2] as double;
        _totalSavings = results[3] as double;

        final portfolioSummary = results[4] as Map<String, dynamic>;
        _portfolioValue = portfolioSummary['totalValue'] as double;
        _portfolioChange = portfolioSummary['dayChange'] as double;
        _portfolioChangePercent = portfolioSummary['dayChangePercent'] as double;

        _recentTransactions = results[5] as List<TransactionModel>;
        _accounts = results[6] as List<AccountModel>;
        _savingsGoals = results[7] as List<SavingsGoalModel>;
        _portfolioHoldings = results[8] as List<PortfolioHolding>;
        _cashflowData = results[9] as List<Map<String, dynamic>>;
        _networthHistory = results[10] as List<Map<String, dynamic>>;
        _insights = results[11] as List<FinancialInsight>;

        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showErrorSnackbar('Gagal memuat data dashboard');
      }
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    await _loadDashboardData();
    setState(() => _isRefreshing = false);
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _navigateToAddTransaction(String type) {
    Navigator.pushNamed(
      context,
      '/add-transaction',
      arguments: {'type': type},
    ).then((_) => _refreshData());
  }

  void _navigateToTransfer() {
    Navigator.pushNamed(context, '/transfer').then((_) => _refreshData());
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

  void _navigateToStatistics() {
    Navigator.pushNamed(context, '/statistics');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: AppTheme.primaryColor,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _buildAppBar(),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (_isLoading) _buildLoadingState(),
                    if (!_isLoading) ...[
                      _buildFinancialSummarySection(),
                      const SizedBox(height: 24),
                      _buildQuickActionsSection(),
                      const SizedBox(height: 24),
                      _buildPortfolioOverviewSection(),
                      const SizedBox(height: 24),
                      _buildCashflowChartSection(),
                      const SizedBox(height: 24),
                      _buildInsightsSection(),
                      const SizedBox(height: 24),
                      _buildRecentTransactionsSection(),
                      const SizedBox(height: 24),
                      _buildSavingsGoalsSection(),
                      const SizedBox(height: 100),
                    ],
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: AppTheme.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat Pagi, User',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const Text(
              'FinTrack',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColorDark,
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
          tooltip: 'Notifikasi',
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => Navigator.pushNamed(context, '/settings'),
          tooltip: 'Pengaturan',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildLoadingState() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          const SizedBox(height: 40),
          const CircularProgressIndicator(
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Memuat data...',
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFinancialSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Ringkasan Keuangan', onSeeAll: _navigateToStatistics),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColorDark,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
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
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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
                        const Icon(Icons.account_balance_wallet, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '${_accounts.length} Akun',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _currencyFormat.format(_totalBalance),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      icon: Icons.arrow_downward,
                      label: 'Pemasukan',
                      amount: _monthlyIncome,
                      color: AppTheme.incomeColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryItem(
                      icon: Icons.arrow_upward,
                      label: 'Pengeluaran',
                      amount: _monthlyExpense,
                      color: AppTheme.expenseColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.savings_outlined, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Total Tabungan',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _currencyFormat.format(_totalSavings),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required double amount,
    required Color color,
  }) {
    return Container(
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
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _compactCurrencyFormat.format(amount),
                  style: const TextStyle(
                    color: Colors.white,
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
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Aksi Cepat'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: QuickActionButton(
                icon: Icons.add_circle_outline,
                label: 'Pemasukan',
                color: AppTheme.incomeColor,
                onTap: () => _navigateToAddTransaction('income'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionButton(
                icon: Icons.remove_circle_outline,
                label: 'Pengeluaran',
                color: AppTheme.expenseColor,
                onTap: () => _navigateToAddTransaction('expense'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionButton(
                icon: Icons.swap_horiz,
                label: 'Transfer',
                color: AppTheme.primaryColor,
                onTap: _navigateToTransfer,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPortfolioOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Portofolio Saham', onSeeAll: _navigateToPortfolio),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBackgroundColor,
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
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nilai Portofolio',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currencyFormat.format(_portfolioValue),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _portfolioChange >= 0
                          ? AppTheme.incomeColor.withValues(alpha: 0.1)
                          : AppTheme.expenseColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _portfolioChange >= 0
                              ? Icons.trending_up
                              : Icons.trending_down,
                          color: _portfolioChange >= 0
                              ? AppTheme.incomeColor
                              : AppTheme.expenseColor,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_portfolioChangePercent >= 0 ? '+' : ''}${_portfolioChangePercent.toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: _portfolioChange >= 0
                                ? AppTheme.incomeColor
                                : AppTheme.expenseColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_portfolioHoldings.isNotEmpty) ...[
                const Divider(height: 1),
                const SizedBox(height: 12),
                ..._portfolioHoldings.take(3).map((holding) => _buildHoldingItem(holding)),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.show_chart,
                        size: 48,
                        color: AppTheme.textSecondaryColor.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Belum ada portofolio',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _navigateToPortfolio,
                        child: const Text('Mulai Investasi'),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHoldingItem(PortfolioHolding holding) {
    final changePercent = holding.profitLossPercent;
    final isPositive = changePercent >= 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                holding.symbol.substring(0, holding.symbol.length > 3 ? 3 : holding.symbol.length),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: AppTheme.primaryColor,
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                Text(
                  '${holding.shares} lot',
                  style: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _currencyFormat.format(holding.currentValue),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              Text(
                '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
                style: TextStyle(
                  color: isPositive ? AppTheme.incomeColor : AppTheme.expenseColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCashflowChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Arus Kas', onSeeAll: _navigateToStatistics),
        const SizedBox(height: 12),
        Container(
          height: 220,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBackgroundColor,
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
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildChartLegend('Pemasukan', AppTheme.incomeColor),
                  _buildChartLegend('Pengeluaran', AppTheme.expenseColor),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _cashflowData.isNotEmpty
                    ? _buildBarChart()
                    : _buildEmptyChartState(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartLegend(String label, Color color) {
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
            color: AppTheme.textSecondaryColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    final maxY = _cashflowData.fold<double>(0, (max, item) {
      final income = (item['income'] as num).toDouble();
      final expense = (item['expense'] as num).toDouble();
      final localMax = income > expense ? income : expense;
      return localMax > max ? localMax : max;
    });

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppTheme.textPrimaryColor,
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final item = _cashflowData[group.x.toInt()];
              final label = groupIndex == 0 ? 'Pemasukan' : 'Pengeluaran';
              final value = groupIndex == 0
                  ? item['income'] as double
                  : item['expense'] as double;
              return BarTooltipItem(
                '$label\n${_compactCurrencyFormat.format(value)}',
                const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
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
                if (value.toInt() >= _cashflowData.length) {
                  return const SizedBox();
                }
                final item = _cashflowData[value.toInt()];
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    item['label'] as String,
                    style: const TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 10,
                    ),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: _buildBarGroups(),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(_cashflowData.length, (index) {
      final item = _cashflowData[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: (item['income'] as num).toDouble(),
            color: AppTheme.incomeColor,
            width: 12,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
          BarChartRodData(
            toY: (item['expense'] as num).toDouble(),
            color: AppTheme.expenseColor,
            width: 12,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildEmptyChartState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 48,
            color: AppTheme.textSecondaryColor.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 8),
          Text(
            'Belum ada data arus kas',
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection() {
    if (_insights.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Wawasan Keuangan'),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _insights.length,
            itemBuilder: (context, index) {
              return InsightCard(
                insight: _insights[index],
                onTap: () => _handleInsightTap(_insights[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  void _handleInsightTap(FinancialInsight insight) {
    // Handle insight action based on type
    if (insight.actionRoute != null) {
      Navigator.pushNamed(context, insight.actionRoute!);
    }
  }

  Widget _buildRecentTransactionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Transaksi Terbaru', onSeeAll: _navigateToTransactions),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBackgroundColor,
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
            children: [
              if (_recentTransactions.isNotEmpty) ...[
                ...List.generate(_recentTransactions.length, (index) {
                  final transaction = _recentTransactions[index];
                  return Column(
                    children: [
                      TransactionListItem(
                        transaction: transaction,
                        onTap: () => _navigateToTransactionDetail(transaction),
                        onEdit: () => _editTransaction(transaction),
                        onDelete: () => _deleteTransaction(transaction),
                      ),
                      if (index < _recentTransactions.length - 1)
                        const Divider(height: 1, indent: 72),
                    ],
                  );
                }),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _navigateToTransactions,
                  child: const Text('Lihat Semua Transaksi'),
                ),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 48,
                        color: AppTheme.textSecondaryColor.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Belum ada transaksi',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _navigateToAddTransaction('expense'),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Tambah Transaksi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _navigateToTransactionDetail(TransactionModel transaction) {
    Navigator.pushNamed(
      context,
      '/transaction-detail',
      arguments: {'id': transaction.id},
    );
  }

  void _editTransaction(TransactionModel transaction) {
    Navigator.pushNamed(
      context,
      '/edit-transaction',
      arguments: {'transaction': transaction},
    ).then((_) => _refreshData());
  }

  Future<void> _deleteTransaction(TransactionModel transaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Transaksi'),
        content: const Text('Apakah Anda yakin ingin menghapus transaksi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final financeService = FinanceService();
        await financeService.deleteTransaction(transaction.id);
        _refreshData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaksi berhasil dihapus')),
          );
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackbar('Gagal menghapus transaksi');
        }
      }
    }
  }

  Widget _buildSavingsGoalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Target Tabungan', onSeeAll: _navigateToSavingsGoals),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: _savingsGoals.isNotEmpty
              ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _savingsGoals.length,
                  itemBuilder: (context, index) {
                    return _buildSavingsGoalCard(_savingsGoals[index]);
                  },
                )
              : _buildEmptySavingsState(),
        ),
      ],
    );
  }

  Widget _buildSavingsGoalCard(SavingsGoalModel goal) {
    final progress = goal.targetAmount > 0
        ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    final progressPercent = (progress * 100).toInt();

    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackgroundColor,
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(int.parse(goal.color.replaceFirst('#', '0xFF'))).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.flag,
                  color: Color(int.parse(goal.color.replaceFirst('#', '0xFF'))),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  goal.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppTheme.textPrimaryColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _compactCurrencyFormat.format(goal.currentAmount),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'dari ${_compactCurrencyFormat.format(goal.targetAmount)}',
            style: const TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.surfaceColor,
            valueColor: AlwaysStoppedAnimation<Color>(
              Color(int.parse(goal.color.replaceFirst('#', '0xFF'))),
            ),
            borderRadius: BorderRadius.circular(4),
            minHeight: 6,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$progressPercent%',
                style: TextStyle(
                  color: Color(int.parse(goal.color.replaceFirst('#', '0xFF'))),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              if (goal.deadline != null)
                Text(
                  DateFormat('dd MMM').format(goal.deadline!),
                  style: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySavingsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.savings_outlined,
            size: 48,
            color: AppTheme.textSecondaryColor.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'Mulai menabung untuk mencapai tujuanmu',
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _navigateToSavingsGoals,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Buat Target'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _SectionTitle(title: title),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: const Row(
              children: [
                Text(
                  'Lihat Semua',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, size: 12),
              ],
            ),
          ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimaryColor,
      ),
    );
  }
}

// Supporting model classes for the dashboard
class FinancialInsight {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String color;
  final String? actionRoute;
  final Map<String, dynamic>? data;

  FinancialInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.actionRoute,
    this.data,
  });

  factory FinancialInsight.fromJson(Map<String, dynamic> json) {
    return FinancialInsight(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      actionRoute: json['actionRoute'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}
