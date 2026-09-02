import 'package:flutter/material.dart';

/// Custom Card Widget - Material 3 Design
/// Part of FinTrack Personal Finance App
/// Version: 1.0.0

// ============================================================================
// ENUMS & CONSTANTS
// ============================================================================

enum CardVariant { elevated, filled, outlined, gradient }
enum BalanceCardType { total, income, expense, savings }
enum TransactionType { income, expense, transfer }

class CustomCardColors {
  static const Color primaryLight = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color secondary = Color(0xFF10B981);
  static const Color accent = Color(0xFFF59E0B);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFEAB308);
  static const Color error = Color(0xFFEF4444);
  static const Color incomeGreen = Color(0xFF10B981);
  static const Color expenseRed = Color(0xFFEF4444);
  static const Color transferBlue = Color(0xFF3B82F6);
  
  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color textPrimaryLight = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
}

class CustomCardSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class CustomCardRadius {
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double full = 9999.0;
}

// ============================================================================
// CUSTOM CARD WIDGET
// ============================================================================

/// A customizable Material 3 card widget with multiple variants
class CustomCard extends StatelessWidget {
  final Widget child;
  final CardVariant variant;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final bool isSelected;
  final double elevation;

  const CustomCard({
    super.key,
    required this.child,
    this.variant = CardVariant.elevated,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = CustomCardRadius.lg,
    this.onTap,
    this.onLongPress,
    this.boxShadow,
    this.gradient,
    this.isSelected = false,
    this.elevation = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      width: width,
      height: height,
      margin: margin ?? const EdgeInsets.symmetric(
        horizontal: CustomCardSpacing.md,
        vertical: CustomCardSpacing.sm,
      ),
      decoration: _buildDecoration(isDark),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(CustomCardSpacing.md),
            child: child,
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration(bool isDark) {
    final defaultBackground = isDark 
        ? CustomCardColors.surfaceDark 
        : CustomCardColors.surfaceLight;
    
    switch (variant) {
      case CardVariant.elevated:
        return BoxDecoration(
          color: backgroundColor ?? defaultBackground,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: boxShadow ?? [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
          border: isSelected 
              ? Border.all(color: CustomCardColors.primaryLight, width: 2)
              : null,
        );
        
      case CardVariant.filled:
        return BoxDecoration(
          color: backgroundColor ?? (isDark 
              ? CustomCardColors.surfaceDark.withOpacity(0.8)
              : CustomCardColors.surfaceLight),
          borderRadius: BorderRadius.circular(borderRadius),
          border: borderColor != null 
              ? Border.all(color: borderColor!) 
              : null,
        );
        
      case CardVariant.outlined:
        return BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: borderColor ?? (isDark 
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1)),
            width: 1,
          ),
        );
        
      case CardVariant.gradient:
        return BoxDecoration(
          gradient: gradient ?? LinearGradient(
            colors: [
              CustomCardColors.primaryLight,
              CustomCardColors.primaryDark,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: boxShadow ?? [
            BoxShadow(
              color: CustomCardColors.primaryLight.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        );
    }
  }
}

// ============================================================================
// BALANCE SUMMARY CARD
// ============================================================================

/// A card widget displaying balance summary information
class BalanceSummaryCard extends StatelessWidget {
  final BalanceCardType type;
  final String title;
  final String amount;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final bool showTrend;
  final double? trendPercentage;
  final bool isTrendPositive;
  final CardVariant variant;

  const BalanceSummaryCard({
    super.key,
    required this.type,
    required this.title,
    required this.amount,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.backgroundColor,
    this.gradient,
    this.onTap,
    this.showTrend = false,
    this.trendPercentage,
    this.isTrendPositive = true,
    this.variant = CardVariant.elevated,
  });

  Color _getDefaultColor() {
    switch (type) {
      case BalanceCardType.total:
        return CustomCardColors.primaryLight;
      case BalanceCardType.income:
        return CustomCardColors.incomeGreen;
      case BalanceCardType.expense:
        return CustomCardColors.expenseRed;
      case BalanceCardType.savings:
        return CustomCardColors.secondary;
    }
  }

  IconData _getDefaultIcon() {
    switch (type) {
      case BalanceCardType.total:
        return Icons.account_balance_wallet;
      case BalanceCardType.income:
        return Icons.arrow_downward;
      case BalanceCardType.expense:
        return Icons.arrow_upward;
      case BalanceCardType.savings:
        return Icons.savings;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveColor = iconColor ?? _getDefaultColor();
    
    return CustomCard(
      variant: variant,
      gradient: gradient,
      backgroundColor: gradient == null ? backgroundColor : null,
      onTap: onTap,
      boxShadow: variant == CardVariant.elevated 
          ? [
              BoxShadow(
                color: effectiveColor.withOpacity(isDark ? 0.2 : 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(CustomCardSpacing.sm),
                decoration: BoxDecoration(
                  color: effectiveColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(CustomCardRadius.md),
                ),
                child: Icon(
                  icon ?? _getDefaultIcon(),
                  color: effectiveColor,
                  size: 20,
                ),
              ),
              if (showTrend && trendPercentage != null)
                _TrendIndicator(
                  percentage: trendPercentage!,
                  isPositive: isTrendPositive,
                ),
            ],
          ),
          const SizedBox(height: CustomCardSpacing.md),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark 
                  ? CustomCardColors.textSecondaryDark
                  : CustomCardColors.textSecondaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: CustomCardSpacing.xs),
          Text(
            amount,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: isDark 
                  ? CustomCardColors.textPrimaryDark
                  : CustomCardColors.textPrimaryLight,
              fontWeight: FontWeight.bold,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: CustomCardSpacing.xs),
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark 
                    ? CustomCardColors.textSecondaryDark.withOpacity(0.7)
                    : CustomCardColors.textSecondaryLight.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TrendIndicator extends StatelessWidget {
  final double percentage;
  final bool isPositive;

  const _TrendIndicator({
    required this.percentage,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPositive 
        ? CustomCardColors.success 
        : CustomCardColors.error;
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CustomCardSpacing.sm,
        vertical: CustomCardSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(CustomCardRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 2),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TRANSACTION ROW CARD
// ============================================================================

/// A compact card widget for displaying transaction items
class TransactionRowCard extends StatelessWidget {
  final TransactionType type;
  final String title;
  final String? description;
  final String amount;
  final String date;
  final String? categoryName;
  final IconData? categoryIcon;
  final Color? categoryColor;
  final String? accountName;
  final bool showDate;
  final bool showCategory;
  final bool showAccount;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isCompact;

  const TransactionRowCard({
    super.key,
    required this.type,
    required this.title,
    this.description,
    required this.amount,
    required this.date,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    this.accountName,
    this.showDate = true,
    this.showCategory = true,
    this.showAccount = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.isCompact = false,
  });

  Color _getTypeColor() {
    switch (type) {
      case TransactionType.income:
        return CustomCardColors.incomeGreen;
      case TransactionType.expense:
        return CustomCardColors.expenseRed;
      case TransactionType.transfer:
        return CustomCardColors.transferBlue;
    }
  }

  IconData _getTypeIcon() {
    switch (type) {
      case TransactionType.income:
        return Icons.arrow_downward;
      case TransactionType.expense:
        return Icons.arrow_upward;
      case TransactionType.transfer:
        return Icons.swap_horiz;
    }
  }

  String _formatAmount() {
    final prefix = type == TransactionType.income ? '+' : '-';
    return '$prefix$amount';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final typeColor = _getTypeColor();
    
    if (isCompact) {
      return _buildCompactRow(context, theme, isDark, typeColor);
    }
    
    return _buildFullRow(context, theme, isDark, typeColor);
  }

  Widget _buildCompactRow(BuildContext context, ThemeData theme, bool isDark, Color typeColor) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(CustomCardRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: CustomCardSpacing.md,
          vertical: CustomCardSpacing.sm,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (categoryColor ?? typeColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(CustomCardRadius.md),
              ),
              child: Icon(
                categoryIcon ?? _getTypeIcon(),
                color: categoryColor ?? typeColor,
                size: 20,
              ),
            ),
            const SizedBox(width: CustomCardSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (showCategory && categoryName != null)
                    Text(
                      categoryName!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark 
                            ? CustomCardColors.textSecondaryDark
                            : CustomCardColors.textSecondaryLight,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatAmount(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: typeColor,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                if (showDate)
                  Text(
                    date,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark 
                          ? CustomCardColors.textSecondaryDark
                          : CustomCardColors.textSecondaryLight,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullRow(BuildContext context, ThemeData theme, bool isDark, Color typeColor) {
    return Dismissible(
      key: Key('transaction_${title}_$date'),
      direction: DismissDirection.horizontal,
      background: _buildSwipeBackground(
        context,
        Icons.edit,
        CustomCardColors.accent,
        Alignment.centerLeft,
      ),
      secondaryBackground: _buildSwipeBackground(
        context,
        Icons.delete,
        CustomCardColors.error,
        Alignment.centerRight,
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
      child: CustomCard(
        onTap: onTap,
        margin: const EdgeInsets.symmetric(
          horizontal: CustomCardSpacing.md,
          vertical: CustomCardSpacing.xs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(CustomCardSpacing.sm),
                  decoration: BoxDecoration(
                    color: (categoryColor ?? typeColor).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(CustomCardRadius.md),
                  ),
                  child: Icon(
                    categoryIcon ?? _getTypeIcon(),
                    color: categoryColor ?? typeColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: CustomCardSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      if (description != null)
                        Text(
                          description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark 
                                ? CustomCardColors.textSecondaryDark
                                : CustomCardColors.textSecondaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (showCategory && categoryName != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: (categoryColor ?? typeColor).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  categoryName!,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: categoryColor ?? typeColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (showAccount && accountName != null) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.account_balance_wallet_outlined,
                                  size: 12,
                                  color: isDark 
                                      ? CustomCardColors.textSecondaryDark
                                      : CustomCardColors.textSecondaryLight,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  accountName!,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: isDark 
                                        ? CustomCardColors.textSecondaryDark
                                        : CustomCardColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatAmount(),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: typeColor,
                        fontWeight: FontWeight.bold,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    if (showDate)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          date,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark 
                                ? CustomCardColors.textSecondaryDark
                                : CustomCardColors.textSecondaryLight,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(
    BuildContext context,
    IconData icon,
    Color color,
    Alignment alignment,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: CustomCardSpacing.md,
        vertical: CustomCardSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(CustomCardRadius.lg),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: CustomCardSpacing.lg),
      child: Icon(icon, color: color),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: CustomCardColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  }
}

// ============================================================================
// ACCOUNT CARD
// ============================================================================

/// A card widget displaying account information
class AccountCard extends StatelessWidget {
  final String name;
  final String type;
  final String balance;
  final String? accountNumber;
  final IconData? icon;
  final Color? color;
  final bool isActive;
  final double? percentageChange;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;

  const AccountCard({
    super.key,
    required this.name,
    required this.type,
    required this.balance,
    this.accountNumber,
    this.icon,
    this.color,
    this.isActive = true,
    this.percentageChange,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
  });

  IconData _getTypeIcon() {
    switch (type.toLowerCase()) {
      case 'cash':
        return Icons.wallet;
      case 'bank':
        return Icons.account_balance;
      case 'ewallet':
        return Icons.phone_android;
      case 'savings':
        return Icons.savings;
      case 'investment':
        return Icons.trending_up;
      default:
        return Icons.account_balance_wallet;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveColor = color ?? CustomCardColors.primaryLight;
    
    return CustomCard(
      variant: isSelected ? CardVariant.elevated : CardVariant.filled,
      isSelected: isSelected,
      onTap: onTap,
      onLongPress: onLongPress,
      margin: const EdgeInsets.symmetric(
        horizontal: CustomCardSpacing.md,
        vertical: CustomCardSpacing.sm,
      ),
      boxShadow: isSelected
          ? [
              BoxShadow(
                color: effectiveColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
          : null,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: effectiveColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(CustomCardRadius.md),
            ),
            child: Icon(
              icon ?? _getTypeIcon(),
              color: effectiveColor,
              size: 24,
            ),
          ),
          const SizedBox(width: CustomCardSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isActive 
                            ? CustomCardColors.success.withOpacity(0.1)
                            : CustomCardColors.textSecondaryLight.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isActive ? 'Active' : 'Inactive',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isActive 
                              ? CustomCardColors.success
                              : CustomCardColors.textSecondaryLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      type.toUpperCase(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: effectiveColor,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (accountNumber != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '• $accountNumber',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark 
                              ? CustomCardColors.textSecondaryDark
                              : CustomCardColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: CustomCardSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                balance,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (percentageChange != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      percentageChange! >= 0 
                          ? Icons.arrow_upward 
                          : Icons.arrow_downward,
                      size: 12,
                      color: percentageChange! >= 0 
                          ? CustomCardColors.success 
                          : CustomCardColors.error,
                    ),
                    Text(
                      '${percentageChange!.abs().toStringAsFixed(1)}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: percentageChange! >= 0 
                            ? CustomCardColors.success 
                            : CustomCardColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SAVINGS GOAL CARD
// ============================================================================

/// A card widget displaying savings goal progress
class SavingsGoalCard extends StatelessWidget {
  final String name;
  final String targetAmount;
  final String currentAmount;
  final double progress;
  final DateTime? deadline;
  final IconData? icon;
  final Color? color;
  final String? deadlineText;
  final VoidCallback? onTap;
  final VoidCallback? onContribute;

  const SavingsGoalCard({
    super.key,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.progress,
    this.deadline,
    this.icon,
    this.color,
    this.deadlineText,
    this.onTap,
    this.onContribute,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveColor = color ?? CustomCardColors.secondary;
    final progressPercent = (progress * 100).clamp(0, 100);
    final isCompleted = progress >= 1.0;
    
    return CustomCard(
      onTap: onTap,
      margin: const EdgeInsets.symmetric(
        horizontal: CustomCardSpacing.md,
        vertical: CustomCardSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(CustomCardSpacing.sm),
                decoration: BoxDecoration(
                  color: effectiveColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(CustomCardRadius.md),
                ),
                child: Icon(
                  icon ?? Icons.savings,
                  color: effectiveColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: CustomCardSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: CustomCardColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 12,
                                  color: CustomCardColors.success,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Completed',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: CustomCardColors.success,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          currentAmount,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: effectiveColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          ' / $targetAmount',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark 
                                ? CustomCardColors.textSecondaryDark
                                : CustomCardColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isCompleted && onContribute != null)
                IconButton(
                  onPressed: onContribute,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: effectiveColor,
                      borderRadius: BorderRadius.circular(CustomCardRadius.sm),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: CustomCardSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(CustomCardRadius.sm),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: effectiveColor.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
            ),
          ),
          const SizedBox(height: CustomCardSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${progressPercent.toStringAsFixed(0)}% achieved',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: effectiveColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (deadline != null || deadlineText != null)
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: isDark 
                          ? CustomCardColors.textSecondaryDark
                          : CustomCardColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      deadlineText ?? _formatDeadline(deadline!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark 
                            ? CustomCardColors.textSecondaryDark
                            : CustomCardColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final daysLeft = deadline.difference(now).inDays;
    
    if (daysLeft < 0) {
      return 'Overdue';
    } else if (daysLeft == 0) {
      return 'Due today';
    } else if (daysLeft == 1) {
      return 'Due tomorrow';
    } else if (daysLeft <= 7) {
      return '$daysLeft days left';
    } else if (daysLeft <= 30) {
      return '${(daysLeft / 7).floor()} weeks left';
    } else {
      return '${(daysLeft / 30).floor()} months left';
    }
  }
}

// ============================================================================
// STOCK HOLDING CARD
// ============================================================================

/// A card widget displaying stock portfolio holding
class StockHoldingCard extends StatelessWidget {
  final String symbol;
  final String? companyName;
  final String shares;
  final String averagePrice;
  final String currentPrice;
  final String totalValue;
  final String profitLoss;
  final double profitLossPercent;
  final String? sector;
  final bool showProfitLoss;
  final VoidCallback? onTap;
  final VoidCallback? onBuy;
  final VoidCallback? onSell;

  const StockHoldingCard({
    super.key,
    required this.symbol,
    this.companyName,
    required this.shares,
    required this.averagePrice,
    required this.currentPrice,
    required this.totalValue,
    required this.profitLoss,
    required this.profitLossPercent,
    this.sector,
    this.showProfitLoss = true,
    this.onTap,
    this.onBuy,
    this.onSell,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isProfit = profitLossPercent >= 0;
    final profitColor = isProfit 
        ? CustomCardColors.success 
        : CustomCardColors.error;
    
    return CustomCard(
      onTap: onTap,
      margin: const EdgeInsets.symmetric(
        horizontal: CustomCardSpacing.md,
        vertical: CustomCardSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CustomCardColors.primaryLight,
                      CustomCardColors.primaryDark,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(CustomCardRadius.md),
                ),
                alignment: Alignment.center,
                child: Text(
                  symbol.length > 2 ? symbol.substring(0, 2) : symbol,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: CustomCardSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      symbol,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (companyName != null)
                      Text(
                        companyName!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark 
                              ? CustomCardColors.textSecondaryDark
                              : CustomCardColors.textSecondaryLight,
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
                    totalValue,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  if (showProfitLoss)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isProfit ? Icons.trending_up : Icons.trending_down,
                          size: 14,
                          color: profitColor,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '$profitLoss (${profitLossPercent >= 0 ? '+' : ''}${profitLossPercent.toStringAsFixed(2)}%)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: profitColor,
                            fontWeight: FontWeight.w500,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: CustomCardSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: CustomCardSpacing.md),
          Row(
            children: [
              Expanded(
                child: _InfoColumn(
                  label: 'Shares',
                  value: shares,
                  theme: theme,
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: _InfoColumn(
                  label: 'Avg. Price',
                  value: averagePrice,
                  theme: theme,
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: _InfoColumn(
                  label: 'Current',
                  value: currentPrice,
                  theme: theme,
                  isDark: isDark,
                  valueColor: profitColor,
                ),
              ),
            ],
          ),
          if (sector != null) ...[
            const SizedBox(height: CustomCardSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: CustomCardColors.primaryLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                sector!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: CustomCardColors.primaryLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          if (onBuy != null || onSell != null) ...[
            const SizedBox(height: CustomCardSpacing.md),
            Row(
              children: [
                if (onBuy != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onBuy,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Buy'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: CustomCardColors.success,
                        side: const BorderSide(color: CustomCardColors.success),
                      ),
                    ),
                  ),
                if (onBuy != null && onSell != null)
                  const SizedBox(width: CustomCardSpacing.sm),
                if (onSell != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onSell,
                      icon: const Icon(Icons.remove, size: 18),
                      label: const Text('Sell'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: CustomCardColors.error,
                        side: const BorderSide(color: CustomCardColors.error),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;
  final bool isDark;
  final Color? valueColor;

  const _InfoColumn({
    required this.label,
    required this.value,
    required this.theme,
    required this.isDark,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark 
                ? CustomCardColors.textSecondaryDark
                : CustomCardColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// DASHBOARD SUMMARY CARD
// ============================================================================

/// A large card widget for main dashboard summary
class DashboardSummaryCard extends StatelessWidget {
  final String title;
  final String mainValue;
  final String? subtitle;
  final IconData? icon;
  final Color? backgroundColor;
  final Gradient? gradient;
  final List<DashboardMetricItem>? metrics;
  final VoidCallback? onTap;
  final CardVariant variant;

  const DashboardSummaryCard({
    super.key,
    required this.title,
    required this.mainValue,
    this.subtitle,
    this.icon,
    this.backgroundColor,
    this.gradient,
    this.metrics,
    this.onTap,
    this.variant = CardVariant.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.all(CustomCardSpacing.md),
      decoration: BoxDecoration(
        gradient: gradient ?? LinearGradient(
          colors: [
            CustomCardColors.primaryLight,
            CustomCardColors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(CustomCardRadius.xl),
        boxShadow: [
          BoxShadow(
            color: CustomCardColors.primaryLight.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(CustomCardRadius.xl),
          child: Padding(
            padding: const EdgeInsets.all(CustomCardSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (icon != null) ...[
                      Container(
                        padding: const EdgeInsets.all(CustomCardSpacing.sm),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(CustomCardRadius.md),
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: CustomCardSpacing.md),
                    ],
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (onTap != null)
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white.withOpacity(0.7),
                        size: 16,
                      ),
                  ],
                ),
                const SizedBox(height: CustomCardSpacing.lg),
                Text(
                  mainValue,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: CustomCardSpacing.xs),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
                if (metrics != null && metrics!.isNotEmpty) ...[
                  const SizedBox(height: CustomCardSpacing.lg),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: CustomCardSpacing.md),
                  Row(
                    children: metrics!.map((metric) {
                      return Expanded(
                        child: _MetricItem(
                          label: metric.label,
                          value: metric.value,
                          color: metric.color ?? Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardMetricItem {
  final String label;
  final String value;
  final Color? color;

  const DashboardMetricItem({
    required this.label,
    required this.value,
    this.color,
  });
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// INSIGHT CARD
// ============================================================================

/// A card widget for displaying financial insights
class InsightCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData? icon;
  final Color? color;
  final String? actionLabel;
  final VoidCallback? onAction;
  final InsightType type;

  const InsightCard({
    super.key,
    required this.title,
    required this.description,
    this.icon,
    this.color,
    this.actionLabel,
    this.onAction,
    this.type = InsightType.info,
  });

  Color _getDefaultColor() {
    switch (type) {
      case InsightType.info:
        return CustomCardColors.primaryLight;
      case InsightType.success:
        return CustomCardColors.success;
      case InsightType.warning:
        return CustomCardColors.warning;
      case InsightType.error:
        return CustomCardColors.error;
      case InsightType.tip:
        return CustomCardColors.accent;
    }
  }

  IconData _getDefaultIcon() {
    switch (type) {
      case InsightType.info:
        return Icons.info_outline;
      case InsightType.success:
        return Icons.check_circle_outline;
      case InsightType.warning:
        return Icons.warning_amber_outlined;
      case InsightType.error:
        return Icons.error_outline;
      case InsightType.tip:
        return Icons.lightbulb_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveColor = color ?? _getDefaultColor();
    
    return CustomCard(
      variant: CardVariant.filled,
      margin: const EdgeInsets.symmetric(
        horizontal: CustomCardSpacing.md,
        vertical: CustomCardSpacing.sm,
      ),
      backgroundColor: effectiveColor.withOpacity(isDark ? 0.15 : 0.05),
      borderColor: effectiveColor.withOpacity(0.3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(CustomCardSpacing.sm),
            decoration: BoxDecoration(
              color: effectiveColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(CustomCardRadius.md),
            ),
            child: Icon(
              icon ?? _getDefaultIcon(),
              color: effectiveColor,
              size: 20,
            ),
          ),
          const SizedBox(width: CustomCardSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: CustomCardSpacing.xs),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark 
                        ? CustomCardColors.textSecondaryDark
                        : CustomCardColors.textSecondaryLight,
                  ),
                ),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: CustomCardSpacing.sm),
                  TextButton(
                    onPressed: onAction,
                    style: TextButton.styleFrom(
                      foregroundColor: effectiveColor,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      actionLabel!,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum InsightType { info, success, warning, error, tip }

// ============================================================================
// CATEGORY SELECTOR CARD
// ============================================================================

/// A card widget for selecting transaction categories
class CategorySelectorCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategorySelectorCard({
    super.key,
    required this.name,
    required this.icon,
    required this.color,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(CustomCardSpacing.md),
        decoration: BoxDecoration(
          color: isSelected 
              ? color.withOpacity(0.15)
              : (isDark 
                  ? CustomCardColors.surfaceDark
                  : CustomCardColors.surfaceLight),
          borderRadius: BorderRadius.circular(CustomCardRadius.lg),
          border: Border.all(
            color: isSelected 
                ? color 
                : (isDark 
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(CustomCardSpacing.sm),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(CustomCardRadius.md),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: CustomCardSpacing.sm),
            Text(
              name,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected 
                    ? color 
                    : (isDark 
                        ? CustomCardColors.textPrimaryDark
                        : CustomCardColors.textPrimaryLight),
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

// ============================================================================
// EXPORT
// ============================================================================

export 'custom_card.dart';
