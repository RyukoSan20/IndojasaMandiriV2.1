import 'package:flutter/material.dart';

/// A customizable card widget for FinTrack application.
///
/// Provides various card styles, states, and customization options
/// suitable for displaying financial data like accounts, transactions,
/// stock quotes, and savings goals.
class CustomCard extends StatelessWidget {
  /// The child widget to display inside the card.
  final Widget child;

  /// Optional header widget displayed at the top of the card.
  final Widget? header;

  /// Optional footer widget displayed at the bottom of the card.
  final Widget? footer;

  /// The card style variant.
  final CustomCardStyle style;

  /// Background color of the card.
  final Color? backgroundColor;

  /// Border color of the card (used in outlined style).
  final Color? borderColor;

  /// Border radius of the card.
  final double borderRadius;

  /// Elevation of the card (used in elevated style).
  final double elevation;

  /// Horizontal padding inside the card.
  final double horizontalPadding;

  /// Vertical padding inside the card.
  final double verticalPadding;

  /// Margin around the card.
  final EdgeInsetsGeometry? margin;

  /// Whether the card is in a loading state.
  final bool isLoading;

  /// Whether the card displays an error state.
  final bool hasError;

  /// Error message to display when hasError is true.
  final String? errorMessage;

  /// Whether the card is interactive (shows touch feedback).
  final bool isInteractive;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  /// Callback when the card is long-pressed.
  final VoidCallback? onLongPress;

  /// Duration of the tap animation.
  final Duration tapAnimationDuration;

  /// Icon to display in the top-left corner.
  final IconData? leadingIcon;

  /// Color of the leading icon.
  final Color? leadingIconColor;

  /// Size of the leading icon.
  final double leadingIconSize;

  /// Whether to show a divider between header and body.
  final bool showHeaderDivider;

  /// Whether to show a divider between body and footer.
  final bool showFooterDivider;

  /// Custom decoration for the card.
  final BoxDecoration? customDecoration;

  /// Creates a CustomCard widget.
  const CustomCard({
    super.key,
    required this.child,
    this.header,
    this.footer,
    this.style = CustomCardStyle.elevated,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 16.0,
    this.elevation = 2.0,
    this.horizontalPadding = 16.0,
    this.verticalPadding = 16.0,
    this.margin,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.isInteractive = false,
    this.onTap,
    this.onLongPress,
    this.tapAnimationDuration = const Duration(milliseconds: 150),
    this.leadingIcon,
    this.leadingIconColor,
    this.leadingIconSize = 24.0,
    this.showHeaderDivider = false,
    this.showFooterDivider = false,
    this.customDecoration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: tapAnimationDuration,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isInteractive ? onTap : null,
          onLongPress: isInteractive ? onLongPress : null,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: theme.colorScheme.primary.withOpacity(0.1),
          highlightColor: theme.colorScheme.primary.withOpacity(0.05),
          child: Ink(
            decoration: _buildDecoration(context, isDarkMode),
            child: _buildCardContent(context),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration(BuildContext context, bool isDarkMode) {
    if (customDecoration != null) {
      return customDecoration!;
    }

    final bgColor = backgroundColor ??
        (isDarkMode ? const Color(0xFF1E1E1E) : Colors.white);

    switch (style) {
      case CustomCardStyle.elevated:
        return BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
              blurRadius: elevation * 2,
              offset: Offset(0, elevation),
            ),
          ],
        );

      case CustomCardStyle.outlined:
        return BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: borderColor ?? theme.dividerColor,
            width: 1.0,
          ),
        );

      case CustomCardStyle.filled:
        return BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(borderRadius),
        );

      case CustomCardStyle.glass:
        return BoxDecoration(
          color: bgColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: borderColor ?? Colors.white.withOpacity(0.2),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        );
    }
  }

  Widget _buildCardContent(BuildContext context) {
    if (hasError) {
      return _buildErrorContent(context);
    }

    if (isLoading) {
      return _buildLoadingContent(context);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _buildCardChildren(context),
    );
  }

  List<Widget> _buildCardChildren(BuildContext context) {
    final List<Widget> children = [];

    if (header != null || leadingIcon != null) {
      children.add(_buildHeader(context));
      if (showHeaderDivider) {
        children.add(_buildDivider(context));
      }
    }

    children.add(
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: child,
      ),
    );

    if (footer != null) {
      if (showFooterDivider) {
        children.add(_buildDivider(context));
      }
      children.add(_buildFooter(context));
    }

    return children;
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        top: horizontalPadding,
        bottom: header != null ? 0 : verticalPadding,
      ),
      child: Row(
        children: [
          if (leadingIcon != null) ...[
            Icon(
              leadingIcon,
              color: leadingIconColor ?? theme.colorScheme.primary,
              size: leadingIconSize,
            ),
            const SizedBox(width: 12),
          ],
          if (header != null) Expanded(child: header!),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        top: 0,
        bottom: verticalPadding,
      ),
      child: footer!,
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(context).dividerColor.withOpacity(0.5),
    );
  }

  Widget _buildLoadingContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(horizontalPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24),
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildErrorContent(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.all(horizontalPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24),
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 12),
          Text(
            errorMessage ?? 'An error occurred',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// Card style variants for CustomCard.
enum CustomCardStyle {
  /// Elevated card with shadow effect.
  elevated,

  /// Card with border outline.
  outlined,

  /// Filled card without shadow or border.
  filled,

  /// Glass-morphism style card.
  glass,
}

/// A convenience builder for creating account cards.
class AccountCard extends StatelessWidget {
  /// The account name.
  final String accountName;

  /// The account type (e.g., Checking, Savings, Credit).
  final String accountType;

  /// The current balance.
  final String balance;

  /// The account icon.
  final IconData icon;

  /// The icon background color.
  final Color iconBackgroundColor;

  /// Whether the balance is negative (for credit cards).
  final bool isNegative;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  /// Creates an AccountCard widget.
  const AccountCard({
    super.key,
    required this.accountName,
    required this.accountType,
    required this.balance,
    required this.icon,
    this.iconBackgroundColor = const Color(0xFF4CAF50),
    this.isNegative = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomCard(
      isInteractive: onTap != null,
      onTap: onTap,
      header: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBackgroundColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconBackgroundColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  accountName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  accountType,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'Current Balance',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            balance,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isNegative
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// A convenience builder for creating transaction cards.
class TransactionCard extends StatelessWidget {
  /// The transaction title/description.
  final String title;

  /// The transaction category.
  final String category;

  /// The transaction amount.
  final String amount;

  /// The transaction date.
  final String date;

  /// The transaction icon.
  final IconData icon;

  /// The icon background color.
  final Color iconBackgroundColor;

  /// Whether the transaction is an expense.
  final bool isExpense;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  /// Creates a TransactionCard widget.
  const TransactionCard({
    super.key,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.icon,
    this.iconBackgroundColor = const Color(0xFF2196F3),
    this.isExpense = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amountColor = isExpense
        ? theme.colorScheme.error
        : const Color(0xFF4CAF50);

    return CustomCard(
      isInteractive: onTap != null,
      onTap: onTap,
      horizontalPadding: 12,
      verticalPadding: 12,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBackgroundColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconBackgroundColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
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
                Text(
                  '$category • $date',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${isExpense ? '-' : '+'}$amount',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// A convenience builder for creating stock quote cards.
class StockQuoteCard extends StatelessWidget {
  /// The stock symbol.
  final String symbol;

  /// The company name.
  final String companyName;

  /// The current price.
  final String currentPrice;

  /// The price change.
  final String priceChange;

  /// The percentage change.
  final String percentageChange;

  /// Whether the stock price is up.
  final bool isUp;

  /// The stock chart widget (optional).
  final Widget? chart;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  /// Creates a StockQuoteCard widget.
  const StockQuoteCard({
    super.key,
    required this.symbol,
    required this.companyName,
    required this.currentPrice,
    required this.priceChange,
    required this.percentageChange,
    required this.isUp,
    this.chart,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final changeColor = isUp ? const Color(0xFF4CAF50) : theme.colorScheme.error;

    return CustomCard(
      isInteractive: onTap != null,
      onTap: onTap,
      header: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                symbol.toUpperCase(),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                companyName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
          if (chart != null)
            SizedBox(
              width: 80,
              height: 40,
              child: chart,
            ),
        ],
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Price',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                ),
              ),
              Text(
                currentPrice,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: changeColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isUp ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: changeColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '$percentageChange%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: changeColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      child: const SizedBox.shrink(),
    );
  }
}

/// A convenience builder for creating savings goal cards.
class SavingsGoalCard extends StatelessWidget {
  /// The goal name.
  final String goalName;

  /// The target amount.
  final String targetAmount;

  /// The current saved amount.
  final String currentAmount;

  /// The progress percentage (0.0 to 1.0).
  final double progress;

  /// The target date.
  final String? targetDate;

  /// The goal icon.
  final IconData icon;

  /// The icon background color.
  final Color iconBackgroundColor;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  /// Creates a SavingsGoalCard widget.
  const SavingsGoalCard({
    super.key,
    required this.goalName,
    required this.targetAmount,
    required this.currentAmount,
    required this.progress,
    this.targetDate,
    this.icon = Icons.savings_outlined,
    this.iconBackgroundColor = const Color(0xFFFF9800),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressPercent = (progress * 100).clamp(0, 100).toInt();
    final isComplete = progress >= 1.0;

    return CustomCard(
      isInteractive: onTap != null,
      onTap: onTap,
      header: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBackgroundColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isComplete ? Icons.check_circle : icon,
              color: iconBackgroundColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goalName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (targetDate != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Target: $targetDate',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isComplete)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Complete!',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF4CAF50),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                currentAmount,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              Text(
                'of $targetAmount',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: theme.dividerColor.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                isComplete ? const Color(0xFF4CAF50) : iconBackgroundColor,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$progressPercent% complete',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

/// A convenience builder for creating summary/stat cards.
class SummaryCard extends StatelessWidget {
  /// The card title.
  final String title;

  /// The card value.
  final String value;

  /// The subtitle or description.
  final String? subtitle;

  /// The trend indicator (up, down, or neutral).
  final SummaryCardTrend trend;

  /// The trend value (e.g., "+5.2%" or "-2.1%").
  final String? trendValue;

  /// The icon to display.
  final IconData icon;

  /// The icon background color.
  final Color iconBackgroundColor;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  /// Creates a SummaryCard widget.
  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.trend = SummaryCardTrend.neutral,
    this.trendValue,
    this.icon = Icons.analytics_outlined,
    this.iconBackgroundColor = const Color(0xFF2196F3),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color getTrendColor() {
      switch (trend) {
        case SummaryCardTrend.up:
          return const Color(0xFF4CAF50);
        case SummaryCardTrend.down:
          return theme.colorScheme.error;
        case SummaryCardTrend.neutral:
          return theme.textTheme.bodySmall?.color ?? Colors.grey;
      }
    }

    IconData getTrendIcon() {
      switch (trend) {
        case SummaryCardTrend.up:
          return Icons.trending_up;
        case SummaryCardTrend.down:
          return Icons.trending_down;
        case SummaryCardTrend.neutral:
          return Icons.trending_flat;
      }
    }

    return CustomCard(
      isInteractive: onTap != null,
      onTap: onTap,
      horizontalPadding: 16,
      verticalPadding: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackgroundColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: iconBackgroundColor,
                  size: 20,
                ),
              ),
              if (trendValue != null && trend != SummaryCardTrend.neutral)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: getTrendColor().withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        getTrendIcon(),
                        size: 14,
                        color: getTrendColor(),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        trendValue!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: getTrendColor(),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Trend direction for SummaryCard.
enum SummaryCardTrend {
  /// Price/value is trending up.
  up,

  /// Price/value is trending down.
  down,

  /// No significant trend.
  neutral,
}
