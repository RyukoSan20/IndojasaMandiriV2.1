import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Account type enumeration for financial accounts
enum AccountCardType {
  cash,
  bank,
  ewallet,
  savings,
  investment,
}

/// Transaction type for income/expense display
enum TransactionDisplayType {
  income,
  expense,
  transfer,
}

/// Savings goal status
enum SavingsGoalStatus {
  active,
  completed,
  cancelled,
}

/// Core data models for the widgets

class AccountModel {
  final String id;
  final String name;
  final AccountCardType type;
  final double balance;
  final String currency;
  final String? iconName;
  final Color? color;
  final bool isActive;

  const AccountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    this.currency = 'IDR',
    this.iconName,
    this.color,
    this.isActive = true,
  });

  IconData get icon {
    switch (type) {
      case AccountCardType.cash:
        return Icons.wallet;
      case AccountCardType.bank:
        return Icons.account_balance;
      case AccountCardType.ewallet:
        return Icons.phone_android;
      case AccountCardType.savings:
        return Icons.savings;
      case AccountCardType.investment:
        return Icons.trending_up;
    }
  }

  String get formattedBalance {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: currency == 'IDR' ? 'Rp' : '\$',
      decimalDigits: 0,
    );
    return formatter.format(balance);
  }

  AccountModel copyWith({
    String? id,
    String? name,
    AccountCardType? type,
    double? balance,
    String? currency,
    String? iconName,
    Color? color,
    bool? isActive,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      iconName: iconName ?? this.iconName,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
    );
  }
}

class TransactionModel {
  final String id;
  final TransactionDisplayType type;
  final double amount;
  final String category;
  final String? description;
  final DateTime date;
  final String? receiptUrl;
  final String? iconName;
  final Color? categoryColor;
  final List<String>? tags;

  const TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    this.description,
    required this.date,
    this.receiptUrl,
    this.iconName,
    this.categoryColor,
    this.tags,
  });

  IconData get categoryIcon {
    switch (category.toLowerCase()) {
      case 'makanan':
        return Icons.restaurant;
      case 'transportasi':
        return Icons.directions_car;
      case 'belanja':
        return Icons.shopping_bag;
      case 'hiburan':
        return Icons.movie;
      case 'kesehatan':
        return Icons.favorite;
      case 'pendidikan':
        return Icons.school;
      case 'tagihan':
        return Icons.receipt_long;
      case 'gaji':
        return Icons.work;
      case 'freelance':
        return Icons.laptop;
      case 'investasi':
        return Icons.trending_up;
      default:
        return Icons.more_horiz;
    }
  }

  Color get typeColor {
    switch (type) {
      case TransactionDisplayType.income:
        return const Color(0xFF10B981);
      case TransactionDisplayType.expense:
        return const Color(0xFFEF4444);
      case TransactionDisplayType.transfer:
        return const Color(0xFF6366F1);
    }
  }

  String get formattedAmount {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );
    final prefix = type == TransactionDisplayType.income ? '+' : '-';
    return '$prefix Rp ${formatter.format(amount)}';
  }

  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Hari ini';
    } else if (transactionDate == yesterday) {
      return 'Kemarin';
    } else {
      return DateFormat('dd MMM yyyy', 'id_ID').format(date);
    }
  }
}

class SavingsGoalModel {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final String? iconName;
  final Color? color;
  final SavingsGoalStatus status;
  final int? priority;

  const SavingsGoalModel({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0,
    this.deadline,
    this.iconName,
    this.color,
    this.status = SavingsGoalStatus.active,
    this.priority,
  });

  double get progress => targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  int get progressPercent => (progress * 100).round();

  String get formattedTargetAmount {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(targetAmount);
  }

  String get formattedCurrentAmount {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(currentAmount);
  }

  String get remainingAmount {
    final remaining = targetAmount - currentAmount;
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(remaining > 0 ? remaining : 0);
  }

  String? get formattedDeadline {
    if (deadline == null) return null;
    return DateFormat('dd MMM yyyy', 'id_ID').format(deadline!);
  }

  int? get daysRemaining {
    if (deadline == null) return null;
    return deadline!.difference(DateTime.now()).inDays;
  }

  IconData get icon {
    switch (name.toLowerCase()) {
      case 'dana darurat':
        return Icons.shield;
      case 'liburan':
        return Icons.flight;
      case 'laptop':
        return Icons.laptop;
      case 'kendaraan':
        return Icons.directions_car;
      case 'rumah':
        return Icons.home;
      default:
        return Icons.flag;
    }
  }
}

class PortfolioHoldingModel {
  final String id;
  final String symbol;
  final String companyName;
  final double shares;
  final double averagePrice;
  final double currentPrice;
  final String? sector;
  final String? exchange;

  const PortfolioHoldingModel({
    required this.id,
    required this.symbol,
    required this.companyName,
    required this.shares,
    required this.averagePrice,
    required this.currentPrice,
    this.sector,
    this.exchange,
  });

  double get totalInvested => shares * averagePrice;
  double get currentValue => shares * currentPrice;
  double get profitLoss => currentValue - totalInvested;
  double get profitLossPercent => totalInvested > 0 ? (profitLoss / totalInvested) * 100 : 0;
  bool get isProfit => profitLoss >= 0;

  String get formattedCurrentValue {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(currentValue);
  }

  String get formattedProfitLoss {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );
    final prefix = isProfit ? '+' : '';
    return '$prefix Rp ${formatter.format(profitLoss.abs())}';
  }

  Color get profitLossColor => isProfit ? const Color(0xFF10B981) : const Color(0xFFEF4444);
}

class BalanceSummaryModel {
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;
  final double totalSavings;
  final double portfolioValue;
  final double? dayChange;
  final double? dayChangePercent;

  const BalanceSummaryModel({
    required this.totalBalance,
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.totalSavings = 0,
    this.portfolioValue = 0,
    this.dayChange,
    this.dayChangePercent,
  });

  double get netCashFlow => totalIncome - totalExpense;
  double get savingsRate => totalIncome > 0 ? (netCashFlow / totalIncome) * 100 : 0;

  String get formattedTotalBalance {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(totalBalance);
  }

  String get formattedTotalIncome {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(totalIncome);
  }

  String get formattedTotalExpense {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(totalExpense);
  }

  String get formattedNetCashFlow {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(netCashFlow);
  }
}

/// Custom Card Widget - Base Material 3 Card

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double? elevation;
  final bool isOutlined;
  final bool isGradient;
  final List<Color>? gradientColors;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.onTap,
    this.onLongPress,
    this.elevation,
    this.isOutlined = false,
    this.isGradient = false,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget cardContent = isGradient
        ? Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors ??
                    [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(borderRadius ?? 16),
            ),
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          )
        : Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          );

    if (isOutlined) {
      return Container(
        margin: margin,
        decoration: BoxDecoration(
          color: isGradient ? null : (backgroundColor ?? theme.colorScheme.surface),
          borderRadius: BorderRadius.circular(borderRadius ?? 16),
          border: Border.all(
            color: borderColor ?? theme.colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(borderRadius ?? 16),
            child: cardContent,
          ),
        ),
      );
    }

    return Container(
      margin: margin,
      child: Material(
        color: isGradient
            ? Colors.transparent
            : (backgroundColor ?? theme.colorScheme.surface),
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
        elevation: elevation ?? (isDark ? 0 : 2),
        shadowColor: theme.colorScheme.shadow.withOpacity(0.1),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(borderRadius ?? 16),
          child: cardContent,
        ),
      ),
    );
  }
}

/// Balance Summary Card Widget

class BalanceSummaryCard extends StatelessWidget {
  final BalanceSummaryModel summary;
  final bool showDetails;
  final bool isCompact;
  final VoidCallback? onTap;
  final Color? primaryColor;
  final Color? incomeColor;
  final Color? expenseColor;

  const BalanceSummaryCard({
    super.key,
    required this.summary,
    this.showDetails = true,
    this.isCompact = false,
    this.onTap,
    this.primaryColor,
    this.incomeColor,
    this.expenseColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isCompact) {
      return _buildCompactCard(context, theme);
    }

    return CustomCard(
      onTap: onTap,
      isGradient: true,
      gradientColors: [
        primaryColor ?? theme.colorScheme.primary,
        (primaryColor ?? theme.colorScheme.primary).withOpacity(0.8),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Saldo',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      summary.dayChange != null && summary.dayChange! >= 0
                          ? Icons.trending_up
                          : Icons.trending_down,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${summary.dayChangePercent?.toStringAsFixed(1) ?? '0'}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            summary.formattedTotalBalance,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 28,
              letterSpacing: -0.5,
            ),
          ),
          if (showDetails) ...[
            const SizedBox(height: 20),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    icon: Icons.arrow_downward,
                    label: 'Pemasukan',
                    value: summary.formattedTotalIncome,
                    color: incomeColor ?? const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    icon: Icons.arrow_upward,
                    label: 'Pengeluaran',
                    value: summary.formattedTotalExpense,
                    color: expenseColor ?? const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactCard(BuildContext context, ThemeData theme) {
    return CustomCard(
      onTap: onTap,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (primaryColor ?? theme.colorScheme.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.account_balance_wallet,
              color: primaryColor ?? theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Saldo',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  summary.formattedTotalBalance,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (summary.dayChangePercent != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: summary.dayChangePercent! >= 0
                    ? const Color(0xFF10B981).withOpacity(0.1)
                    : const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    summary.dayChangePercent! >= 0
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    color: summary.dayChangePercent! >= 0
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                    size: 14,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${summary.dayChangePercent!.toStringAsFixed(1)}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: summary.dayChangePercent! >= 0
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Account Card Widget

class AccountCard extends StatelessWidget {
  final AccountModel account;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showBalance;

  const AccountCard({
    super.key,
    required this.account,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
    this.showBalance = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = account.color ?? theme.colorScheme.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: CustomCard(
        onTap: onTap,
        onLongPress: onLongPress,
        backgroundColor: isSelected
            ? cardColor.withOpacity(0.1)
            : theme.colorScheme.surface,
        borderColor: isSelected ? cardColor : null,
        isOutlined: !isSelected,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    account.icon,
                    color: cardColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getAccountTypeLabel(account.type),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!account.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Nonaktif',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
              ],
            ),
            if (showBalance) ...[
              const SizedBox(height: 16),
              Text(
                account.formattedBalance,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getAccountTypeLabel(AccountCardType type) {
    switch (type) {
      case AccountCardType.cash:
        return 'Tunai';
      case AccountCardType.bank:
        return 'Rekening Bank';
      case AccountCardType.ewallet:
        return 'E-Wallet';
      case AccountCardType.savings:
        return 'Tabungan';
      case AccountCardType.investment:
        return 'Investasi';
    }
  }
}

/// Transaction Row Widget

class TransactionRow extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showDate;
  final bool enableSwipeActions;

  const TransactionRow({
    super.key,
    required this.transaction,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showDate = true,
    this.enableSwipeActions = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget row = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (transaction.categoryColor ?? transaction.typeColor)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                transaction.categoryIcon,
                color: transaction.categoryColor ?? transaction.typeColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.category,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (showDate) ...[
                        Text(
                          transaction.formattedDate,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurfaceVariant,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          transaction.description ?? transaction.category,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  transaction.formattedAmount,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: transaction.typeColor,
                  ),
                ),
                if (transaction.tags != null && transaction.tags!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: transaction.tags!
                        .take(2)
                        .map((tag) => Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                tag,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSecondaryContainer,
                                  fontSize: 10,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );

    if (enableSwipeActions && (onEdit != null || onDelete != null)) {
      return Dismissible(
        key: Key(transaction.id),
        direction: DismissDirection.horizontal,
        background: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
          color: theme.colorScheme.primary,
          child: const Icon(Icons.edit, color: Colors.white),
        ),
        secondaryBackground: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          color: theme.colorScheme.error,
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            onEdit?.call();
            return false;
          } else {
            return await _showDeleteConfirmation(context);
          }
        },
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {
            onDelete?.call();
          }
        },
        child: row,
      );
    }

    return row;
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hapus Transaksi'),
            content: const Text(
              'Apakah Anda yakin ingin menghapus transaksi ini?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Hapus'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

/// Transaction List Card Widget

class TransactionListCard extends StatelessWidget {
  final List<TransactionModel> transactions;
  final String title;
  final String? subtitle;
  final VoidCallback? onViewAll;
  final Function(TransactionModel)? onTransactionTap;
  final Function(TransactionModel)? onTransactionEdit;
  final Function(TransactionModel)? onTransactionDelete;
  final bool showViewAll;
  final bool enableSwipeActions;
  final bool isLoading;
  final Widget? emptyState;

  const TransactionListCard({
    super.key,
    required this.transactions,
    this.title = 'Transaksi Terbaru',
    this.subtitle,
    this.onViewAll,
    this.onTransactionTap,
    this.onTransactionEdit,
    this.onTransactionDelete,
    this.showViewAll = true,
    this.enableSwipeActions = false,
    this.isLoading = false,
    this.emptyState,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
                if (showViewAll && onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: const Text('Lihat Semua'),
                  ),
              ],
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (transactions.isEmpty && emptyState != null)
            emptyState!
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: theme.colorScheme.outlineVariant,
              ),
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return TransactionRow(
                  transaction: transaction,
                  onTap: onTransactionTap != null
                      ? () => onTransactionTap!(transaction)
                      : null,
                  onEdit: onTransactionEdit != null
                      ? () => onTransactionEdit!(transaction)
                      : null,
                  onDelete: onTransactionDelete != null
                      ? () => onTransactionDelete!(transaction)
                      : null,
                  enableSwipeActions: enableSwipeActions,
                );
              },
            ),
        ],
      ),
    );
  }
}

/// Savings Goal Card Widget

class SavingsGoalCard extends StatelessWidget {
  final SavingsGoalModel goal;
  final VoidCallback? onTap;
  final VoidCallback? onContribute;
  final bool showActions;
  final bool isCompact;

  const SavingsGoalCard({
    super.key,
    required this.goal,
    this.onTap,
    this.onContribute,
    this.showActions = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final goalColor = goal.color ?? theme.colorScheme.primary;

    if (isCompact) {
      return _buildCompactCard(context, theme, goalColor);
    }

    return CustomCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: goalColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  goal.icon,
                  color: goalColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            goal.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (goal.status == SavingsGoalStatus.completed)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  size: 12,
                                  color: Color(0xFF10B981),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Tercapai',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: const Color(0xFF10B981),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Target: ${goal.formattedTargetAmount}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
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
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.formattedCurrentAmount,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${goal.progressPercent}% dari target',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    goal.remainingAmount,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: goalColor,
                    ),
                  ),
                  if (goal.daysRemaining != null)
                    Text(
                      goal.daysRemaining! > 0
                          ? '${goal.daysRemaining} hari lagi'
                          : 'Melewati deadline',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: goal.daysRemaining! > 0
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.error,
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (showActions && goal.status == SavingsGoalStatus.active) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: onContribute,
                child: const Text('Tambah Tabungan'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactCard(
    BuildContext context,
    ThemeData theme,
    Color goalColor,
  ) {
    return CustomCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: goalColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              goal.icon,
              color: goalColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: goal.progress,
                    backgroundColor: goalColor.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(goalColor),
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
                '${goal.progressPercent}%',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: goalColor,
                ),
              ),
              Text(
                goal.formattedCurrentAmount,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Portfolio Holding Card Widget

class PortfolioHoldingCard extends StatelessWidget {
  final PortfolioHoldingModel holding;
  final VoidCallback? onTap;
  final VoidCallback? onBuy;
  final VoidCallback? onSell;
  final bool showActions;

  const PortfolioHoldingCard({
    super.key,
    required this.holding,
    this.onTap,
    this.onBuy,
    this.onSell,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: holding.isProfit
                      ? const Color(0xFF10B981).withOpacity(0.1)
                      : const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    holding.symbol.substring(0, holding.symbol.length > 2 ? 2 : holding.symbol.length),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: holding.profitLossColor,
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
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      holding.companyName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
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
                    holding.formattedCurrentValue,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: holding.profitLossColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          holding.isProfit
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 12,
                          color: holding.profitLossColor,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${holding.profitLossPercent.toStringAsFixed(2)}%',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: holding.profitLossColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoColumn(
                  context,
                  label: 'Jumlah Lot',
                  value: holding.shares.toStringAsFixed(0),
                ),
              ),
              Expanded(
                child: _buildInfoColumn(
                  context,
                  label: 'Harga Avg',
                  value: NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: 'Rp',
                    decimalDigits: 0,
                  ).format(holding.averagePrice),
                ),
              ),
              Expanded(
                child: _buildInfoColumn(
                  context,
                  label: 'Harga Saat Ini',
                  value: NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: 'Rp',
                    decimalDigits: 0,
                  ).format(holding.currentPrice),
                ),
              ),
            ],
          ),
          if (showActions) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onSell,
                    icon: const Icon(Icons.sell, size: 18),
                    label: const Text('Jual'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onBuy,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Beli'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoColumn(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Quick Action Button Widget

class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;
  final bool isLarge;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.color,
    this.onTap,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = color ?? theme.colorScheme.primary;

    if (isLarge) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 80,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: buttonColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: buttonColor,
                  size: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 64,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: buttonColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: buttonColor,
                size: 20,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Quick Actions Row Widget

class QuickActionsRow extends StatelessWidget {
  final Function(int index)? onActionTap;
  final List<QuickActionItem>? customActions;

  const QuickActionsRow({
    super.key,
    this.onActionTap,
    this.customActions,
  });

  static const List<QuickActionItem> defaultActions = [
    QuickActionItem(icon: Icons.add, label: 'Pemasukan', color: Color(0xFF10B981)),
    QuickActionItem(icon: Icons.remove, label: 'Pengeluaran', color: Color(0xFFEF4444)),
    QuickActionItem(icon: Icons.swap_horiz, label: 'Transfer', color: Color(0xFF6366F1)),
    QuickActionItem(icon: Icons.receipt_long, label: 'Struk', color: Color(0xFFF59E0B)),
  ];

  @override
  Widget build(BuildContext context) {
    final actions = customActions ?? defaultActions;

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: actions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final action = actions[index];
          return QuickActionButton(
            icon: action.icon,
            label: action.label,
            color: action.color,
            isLarge: true,
            onTap: onActionTap != null ? () => onActionTap!(index) : null,
          );
        },
      ),
    );
  }
}

class QuickActionItem {
  final IconData icon;
  final String label;
  final Color? color;

  const QuickActionItem({
    required this.icon,
    required this.label,
    this.color,
  });
}

/// Stat Card Widget for Dashboard

class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? change;
  final double? changePercent;
  final Color? iconColor;
  final Color? valueColor;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.change,
    this.changePercent,
    this.iconColor,
    this.valueColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (iconColor ?? theme.colorScheme.primary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const Spacer(),
              if (changePercent != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (changePercent! >= 0
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444))
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        changePercent! >= 0
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 10,
                        color: changePercent! >= 0
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${changePercent!.toStringAsFixed(1)}%',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: changePercent! >= 0
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          if (change != null) ...[
            const SizedBox(height: 2),
            Text(
              change!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Empty State Widget

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Section Header Widget

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTrailingTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null)
            onTrailingTap != null
                ? InkWell(
                    onTap: onTrailingTap,
                    borderRadius: BorderRadius.circular(8),
                    child: trailing,
                  )
                : trailing,
        ],
      ),
    );
  }
}
