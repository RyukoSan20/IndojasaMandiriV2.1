import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shimmer/shimmer.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/dashboard/dashboard_bloc.dart';
import '../blocs/accounts/accounts_bloc.dart';
import '../blocs/transactions/transactions_bloc.dart';
import '../blocs/savings/savings_bloc.dart';
import '../blocs/portfolio/portfolio_bloc.dart';
import '../models/user.dart';
import '../models/transaction_model.dart';
import '../models/account.dart';
import '../models/savings_goal.dart';
import '../models/portfolio_holding.dart';
import '../services/formatters.dart';
import '../services/navigation_service.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/app_spacing.dart';
import '../widgets/cards/summary_card.dart';
import '../widgets/cards/account_card.dart';
import '../widgets/cards/transaction_item.dart';
import '../widgets/charts/cashflow_chart.dart';
import '../widgets/charts/networth_chart.dart';
import '../widgets/charts/expense_pie_chart.dart';
import '../widgets/dialogs/add_transaction_dialog.dart';
import '../widgets/dialogs/transfer_dialog.dart';
import '../widgets/buttons/quick_action_button.dart';
import '../widgets/common/loading_shimmer.dart';
import '../widgets/common/error_view.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/section_header.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDashboardData();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.offset > 50 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 50 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  void _loadDashboardData() {
    context.read<DashboardBloc>().add(LoadDashboard());
    context.read<AccountsBloc>().add(LoadAccounts());
    context.read<TransactionsBloc>().add(LoadRecentTransactions(limit: 5));
    context.read<SavingsBloc>().add(LoadSavingsGoals());
    context.read<PortfolioBloc>().add(LoadPortfolioSummary());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc bloc) => bloc.state.user);
    final currency = user?.currency ?? 'IDR';
    final currencySymbol = Formatters.getCurrencySymbol(currency);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _loadDashboardData(),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BastingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              _buildAppBar(user, currencySymbol),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreetingSection(user, currency),
                    const SizedBox(height: AppSpacing.lg),
                    _buildFinancialSummarySection(currencySymbol),
                    const SizedBox(height: AppSpacing.lg),
                    _buildQuickActionsSection(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildCashflowChartSection(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildAccountsSection(currencySymbol),
                    const SizedBox(height: AppSpacing.lg),
                    _buildSavingsGoalsSection(currencySymbol),
                    const SizedBox(height: AppSpacing.lg),
                    _buildPortfolioSection(currencySymbol),
                    const SizedBox(height: AppSpacing.lg),
                    _buildRecentTransactionsSection(currencySymbol),
                    const SizedBox(height: AppSpacing.lg),
                    _buildExpensesBreakdownSection(currencySymbol),
                    const SizedBox(height: AppSpacing.xl),
                    _buildInsightsSection(),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(User? user, String currencySymbol) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      expandedHeight: 60,
      backgroundColor: _isScrolled
          ? Theme.of(context).scaffoldBackgroundColor
          : Colors.transparent,
      elevation: _isScrolled ? 2 : 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            Theme.of(context).brightness == Brightness.light
                ? Brightness.dark
                : Brightness.light,
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: AppSpacing.md),
        child: GestureDetector(
          onTap: () => NavigationService.openDrawer(),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary,
            child: user?.avatarUrl != null
                ? ClipOval(
                    child: Image.network(
                      user!.avatarUrl!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(user),
                    ),
                  )
                : _buildAvatarPlaceholder(user),
          ),
        ),
      ),
      title: _isScrolled
          ? Text(
              'FinTrack',
              style: AppTypography.headlineSmall.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            )
          : null,
      actions: [
        IconButton(
          onPressed: () => NavigationService.navigateTo('/notifications'),
          icon: Badge(
            label: const Text('3'),
            child: Icon(
              Icons.notifications_outlined,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
        ),
        IconButton(
          onPressed: () => NavigationService.navigateTo('/settings'),
          icon: Icon(
            Icons.settings_outlined,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
    );
  }

  Widget _buildAvatarPlaceholder(User? user) {
    final initials = user?.name?.isNotEmpty == true
        ? user!.name!.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
        : '?';
    return Text(
      initials.toUpperCase(),
      style: AppTypography.titleMedium.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildGreetingSection(User? user, String currency) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Selamat Pagi';
    } else if (hour < 15) {
      greeting = 'Selamat Siang';
    } else if (hour < 18) {
      greeting = 'Selamat Sore';
    } else {
      greeting = 'Selamat Malam';
    }

    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final totalBalance = state is DashboardLoaded
            ? state.summary.totalBalance
            : 0.0;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: AppTypography.bodyLarge.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                user?.name ?? 'User',
                style: AppTypography.headlineMedium.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.lg),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Saldo',
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              Formatters.formatCurrency(totalBalance,
                                  symbol: Formatters.getCurrencySymbol(currency)),
                              style: AppTypography.headlineLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppSpacing.full),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.trending_up,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                '+2.5%',
                                style: AppTypography.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        _buildMiniStat(
                          'Pemasukan',
                          Formatters.formatCurrency(
                            state is DashboardLoaded ? state.summary.monthlyIncome : 0,
                            symbol: Formatters.getCurrencySymbol(currency),
                            compact: true,
                          ),
                          Icons.arrow_downward,
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        _buildMiniStat(
                          'Pengeluaran',
                          Formatters.formatCurrency(
                            state is DashboardLoaded ? state.summary.monthlyExpense : 0,
                            symbol: Formatters.getCurrencySymbol(currency),
                            compact: true,
                          ),
                          Icons.arrow_upward,
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        _buildMiniStat(
                          'Tabungan',
                          Formatters.formatCurrency(
                            state is DashboardLoaded ? state.summary.totalSavings : 0,
                            symbol: Formatters.getCurrencySymbol(currency),
                            compact: true,
                          ),
                          Icons.savings_outlined,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white.withOpacity(0.8), size: 14),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummarySection(String currencySymbol) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Row(
                children: List.generate(
                  4,
                  (index) => Expanded(
                    child: Container(
                      height: 100,
                      margin: EdgeInsets.only(
                        right: index < 3 ? AppSpacing.md : 0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppSpacing.md),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        if (state is! DashboardLoaded) {
          return const SizedBox.shrink();
        }

        final summary = state.summary;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: SummaryCard(
                  title: 'Total Aset',
                  value: Formatters.formatCurrency(
                    summary.totalAssets,
                    symbol: currencySymbol,
                    compact: true,
                  ),
                  icon: Icons.account_balance_wallet_outlined,
                  color: AppColors.primary,
                  trend: '+5.2%',
                  trendPositive: true,
                  onTap: () => NavigationService.navigateTo('/accounts'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: SummaryCard(
                  title: 'Investasi',
                  value: Formatters.formatCurrency(
                    summary.totalInvestments,
                    symbol: currencySymbol,
                    compact: true,
                  ),
                  icon: Icons.trending_up,
                  color: AppColors.success,
                  trend: '+12.3%',
                  trendPositive: true,
                  onTap: () => NavigationService.navigateTo('/portfolio'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: SectionHeader(
            title: 'Aksi Cepat',
            actionLabel: 'Lihat Semua',
            onAction: () => NavigationService.navigateTo('/transactions'),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              QuickActionButton(
                icon: Icons.add_circle_outline,
                label: 'Pemasukan',
                color: AppColors.success,
                onTap: () => _showAddTransactionDialog(type: 'income'),
              ),
              const SizedBox(width: AppSpacing.md),
              QuickActionButton(
                icon: Icons.remove_circle_outline,
                label: 'Pengeluaran',
                color: AppColors.error,
                onTap: () => _showAddTransactionDialog(type: 'expense'),
              ),
              const SizedBox(width: AppSpacing.md),
              QuickActionButton(
                icon: Icons.swap_horiz,
                label: 'Transfer',
                color: AppColors.secondary,
                onTap: () => _showTransferDialog(),
              ),
              const SizedBox(width: AppSpacing.md),
              QuickActionButton(
                icon: Icons.savings_outlined,
                label: 'Tabungan',
                color: AppColors.accent,
                onTap: () => _showAddSavingsDialog(),
              ),
              const SizedBox(width: AppSpacing.md),
              QuickActionButton(
                icon: Icons.receipt_long_outlined,
                label: 'Struk',
                color: AppColors.info,
                onTap: () => _uploadReceipt(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCashflowChartSection() {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.lg),
                ),
              ),
            ),
          );
        }

        final cashflowData = state is DashboardLoaded
            ? state.cashflowData
            : <CashflowDataPoint>[];

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(AppSpacing.lg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
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
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.full),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelColor: AppColors.primary,
                      unselectedLabelColor:
                          Theme.of(context).textTheme.bodySmall?.color,
                      indicatorSize: TabBarIndicatorSize.label,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.full),
                      ),
                      tabs: const [
                        Tab(text: 'Mingguan'),
                        Tab(text: 'Bulanan'),
                        Tab(text: 'Tahunan'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 180,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    CashflowChart(
                      data: cashflowData.take(7).toList(),
                      period: 'weekly',
                    ),
                    CashflowChart(
                      data: cashflowData.take(12).toList(),
                      period: 'monthly',
                    ),
                    CashflowChart(
                      data: cashflowData.take(12).toList(),
                      period: 'yearly',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccountsSection(String currencySymbol) {
    return BlocBuilder<AccountsBloc, AccountsState>(
      builder: (context, state) {
        if (state is AccountsLoading) {
          return _buildAccountsShimmer();
        }

        if (state is! AccountsLoaded) {
          return const SizedBox.shrink();
        }

        final accounts = state.accounts.where((a) => a.isActive).toList();

        if (accounts.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: EmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Belum Ada Akun',
              subtitle: 'Tambahkan akun untuk mulai melacak keuangan',
              actionLabel: 'Tambah Akun',
              onAction: () => NavigationService.navigateTo('/accounts/add'),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Akun Keuangan',
              actionLabel: 'Lihat Semua',
              onAction: () => NavigationService.navigateTo('/accounts'),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: accounts.length,
                itemBuilder: (context, index) {
                  final account = accounts[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < accounts.length - 1 ? AppSpacing.md : 0,
                    ),
                    child: AccountCard(
                      account: account,
                      currencySymbol: currencySymbol,
                      onTap: () => NavigationService.navigateTo(
                        '/accounts/${account.id}',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAccountsShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SizedBox(
        height: 140,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          itemCount: 3,
          itemBuilder: (context, index) => Container(
            width: 200,
            margin: EdgeInsets.only(
              right: index < 2 ? AppSpacing.md : 0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.lg),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSavingsGoalsSection(String currencySymbol) {
    return BlocBuilder<SavingsBloc, SavingsState>(
      builder: (context, state) {
        if (state is SavingsLoading) {
          return _buildSavingsShimmer();
        }

        if (state is! SavingsLoaded) {
          return const SizedBox.shrink();
        }

        final goals = state.goals.where((g) => g.status == 'active').toList();

        if (goals.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: EmptyState(
              icon: Icons.savings_outlined,
              title: 'Belum Ada Target Tabungan',
              subtitle: 'Buat target tabungan untuk mencapai impianmu',
              actionLabel: 'Buat Target',
              onAction: () => NavigationService.navigateTo('/savings/add'),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Target Tabungan',
              actionLabel: 'Lihat Semua',
              onAction: () => NavigationService.navigateTo('/savings'),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: goals.length,
                itemBuilder: (context, index) {
                  final goal = goals[index];
                  final progress = goal.targetAmount > 0
                      ? goal.currentAmount / goal.targetAmount
                      : 0.0;
                  final remaining = goal.targetAmount - goal.currentAmount;

                  return Container(
                    width: 280,
                    margin: EdgeInsets.only(
                      right: index < goals.length - 1 ? AppSpacing.md : 0,
                    ),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(int.parse(goal.color.replaceFirst('#', '0xFF'))),
                          Color(int.parse(goal.color.replaceFirst('#', '0xFF')))
                              .withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppSpacing.lg),
                      boxShadow: [
                        BoxShadow(
                          color: Color(int.parse(goal.color.replaceFirst('#', '0xFF')))
                              .withOpacity(0.3),
                          blurRadius: 12,
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
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(AppSpacing.md),
                              ),
                              child: Icon(
                                _getIconForGoal(goal.icon),
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            if (goal.deadline != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius:
                                      BorderRadius.circular(AppSpacing.full),
                                ),
                                child: Text(
                                  '${goal.deadline!.difference(DateTime.now()).inDays} hari',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          goal.name,
                          style: AppTypography.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${Formatters.formatCurrency(goal.currentAmount, symbol: currencySymbol)} dari ${Formatters.formatCurrency(goal.targetAmount, symbol: currencySymbol)}',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const Spacer(),
                        LinearPercentIndicator(
                          lineHeight: 8,
                          percent: progress.clamp(0.0, 1.0),
                          backgroundColor: Colors.white.withOpacity(0.3),
                          progressColor: Colors.white,
                          barRadius: const Radius.circular(4),
                          padding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${(progress * 100).toStringAsFixed(1)}%',
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Sisa: ${Formatters.formatCurrency(remaining > 0 ? remaining : 0, symbol: currencySymbol, compact: true)}',
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSavingsShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          itemCount: 2,
          itemBuilder: (context, index) => Container(
            width: 280,
            margin: EdgeInsets.only(
              right: index < 1 ? AppSpacing.md : 0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.lg),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForGoal(String? iconName) {
    final iconMap = {
      'shield': Icons.shield_outlined,
      'flight': Icons.flight_outlined,
      'home': Icons.home_outlined,
      'car': Icons.directions_car_outlined,
      'laptop': Icons.laptop_outlined,
      'school': Icons.school_outlined,
      'health': Icons.favorite_outline,
      'gift': Icons.card_giftcard_outlined,
    };
    return iconMap[iconName] ?? Icons.savings_outlined;
  }

  Widget _buildPortfolioSection(String currencySymbol) {
    return BlocBuilder<PortfolioBloc, PortfolioState>(
      builder: (context, state) {
        if (state is PortfolioLoading) {
          return _buildPortfolioShimmer();
        }

        if (state is! PortfolioLoaded) {
          return const SizedBox.shrink();
        }

        final summary = state.summary;
        final holdings = state.holdings.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Portofolio Saham',
              actionLabel: 'Lihat Detail',
              onAction: () => NavigationService.navigateTo('/portfolio'),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.success, Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.lg),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withOpacity(0.3),
                    blurRadius: 12,
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
                          Text(
                            'Total Nilai',
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            Formatters.formatCurrency(
                              summary.totalValue,
                              symbol: currencySymbol,
                            ),
                            style: AppTypography.headlineMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppSpacing.full),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              summary.totalProfitLossPercent >= 0
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              '${summary.totalProfitLossPercent >= 0 ? '+' : ''}${summary.totalProfitLossPercent.toStringAsFixed(2)}%',
                              style: AppTypography.bodyMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPortfolioMiniStat(
                          'Total Profit/Loss',
                          Formatters.formatCurrency(
                            summary.totalProfitLoss,
                            symbol: currencySymbol,
                            compact: true,
                          ),
                          summary.totalProfitLoss >= 0,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      Expanded(
                        child: _buildPortfolioMiniStat(
                          'Jumlah Saham',
                          '${holdings.length}',
                          true,
                        ),
                      ),
                    ],
                  ),
                  if (holdings.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: AppSpacing.md),
                    ...holdings.map((holding) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      holding.symbol,
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      holding.companyName,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    Formatters.formatCurrency(
                                      holding.currentValue,
                                      symbol: currencySymbol,
                                      compact: true,
                                    ),
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        holding.profitLossPercent >= 0
                                            ? Icons.arrow_upward
                                            : Icons.arrow_downward,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                      Text(
                                        '${holding.profitLossPercent >= 0 ? '+' : ''}${holding.profitLossPercent.toStringAsFixed(2)}%',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPortfolioMiniStat(String label, String value, bool isPositive) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 250,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.lg),
        ),
      ),
    );
  }

  Widget _buildRecentTransactionsSection(String currencySymbol) {
    return BlocBuilder<TransactionsBloc, TransactionsState>(
      builder: (context, state) {
        if (state is TransactionsLoading) {
          return _buildTransactionsShimmer();
        }

        if (state is! TransactionsLoaded) {
          return const SizedBox.shrink();
        }

        final transactions = state.transactions;

        if (transactions.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Belum Ada Transaksi',
              subtitle: 'Mulai catat transaksi pertamamu',
              actionLabel: 'Tambah Transaksi',
              onAction: () => _showAddTransactionDialog(),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Transaksi Terbaru',
              actionLabel: 'Lihat Semua',
              onAction: () => NavigationService.navigateTo('/transactions'),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(AppSpacing.lg),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length > 5 ? 5 : transactions.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  indent: AppSpacing.md,
                  endIndent: AppSpacing.md,
                  color: Theme.of(context).dividerColor,
                ),
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return TransactionItem(
                    transaction: transaction,
                    currencySymbol: currencySymbol,
                    onTap: () => NavigationService.navigateTo(
                      '/transactions/${transaction.id}',
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTransactionsShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.lg),
        ),
        child: Column(
          children: List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.md),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 100,
                          height: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Container(
                          width: 60,
                          height: 10,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 14,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpensesBreakdownSection(String currencySymbol) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is! DashboardLoaded) {
          return const SizedBox.shrink();
        }

        final categoryData = state.expensesByCategory;

        if (categoryData.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Pengeluaran per Kategori',
              actionLabel: 'Lihat Detail',
              onAction: () => NavigationService.navigateTo('/statistics'),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(AppSpacing.lg),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: ExpensePieChart(
                      data: categoryData,
                      currencySymbol: currencySymbol,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...categoryData.take(5).map((data) {
                    final percent = state.summary.monthlyExpense > 0
                        ? data.amount / state.summary.monthlyExpense
                        : 0.0;
                    return Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Color(int.parse(data.color.replaceFirst('#', '0xFF'))),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              data.categoryName,
                              style: AppTypography.bodyMedium,
                            ),
                          ),
                          Text(
                            Formatters.formatCurrency(
                              data.amount,
                              symbol: currencySymbol,
                              compact: true,
                            ),
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          SizedBox(
                            width: 50,
                            child: Text(
                              '${(percent * 100).toStringAsFixed(1)}%',
                              style: AppTypography.bodySmall.copyWith(
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInsightsSection() {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is! DashboardLoaded) {
          return const SizedBox.shrink();
        }

        final insights = state.insights;

        if (insights.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Wawasan & Insights',
              actionLabel: 'Pengaturan',
              onAction: () => NavigationService.navigateTo('/settings/insights'),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: insights.length,
                itemBuilder: (context, index) {
                  final insight = insights[index];
                  return Container(
                    width: 260,
                    margin: EdgeInsets.only(
                      right: index < insights.length - 1 ? AppSpacing.md : 0,
                    ),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(AppSpacing.lg),
                      border: Border.all(
                        color: _getInsightColor(insight.type).withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: _getInsightColor(insight.type)
                                    .withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.md),
                              ),
                              child: Icon(
                                _getInsightIcon(insight.type),
                                color: _getInsightColor(insight.type),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                insight.title,
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Expanded(
                          child: Text(
                            insight.description,
                            style: AppTypography.bodySmall.copyWith(
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (insight.actionLabel != null)
                          TextButton(
                            onPressed: () => NavigationService.navigateTo(
                              insight.actionRoute ?? '/',
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              insight.actionLabel!,
                              style: AppTypography.bodySmall.copyWith(
                                color: _getInsightColor(insight.type),
                                fontWeight: FontWeight.w600,
                              ),
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
      },
    );
  }

  Color _getInsightColor(String type) {
    switch (type) {
      case 'tip':
        return AppColors.info;
      case 'warning':
        return AppColors.warning;
      case 'success':
        return AppColors.success;
      case 'alert':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  IconData _getInsightIcon(String type) {
    switch (type) {
      case 'tip':
        return Icons.lightbulb_outline;
      case 'warning':
        return Icons.warning_amber_outlined;
      case 'success':
        return Icons.check_circle_outline;
      case 'alert':
        return Icons.error_outline;
      default:
        return Icons.info_outline;
    }
  }

  void _showAddTransactionDialog({String? type}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTransactionDialog(initialType: type),
    );
  }

  void _showTransferDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TransferDialog(),
    );
  }

  void _showAddSavingsDialog() {
    NavigationService.navigateTo('/savings/add');
  }

  void _uploadReceipt() {
    NavigationService.navigateTo('/transactions/upload-receipt');
  }
}
