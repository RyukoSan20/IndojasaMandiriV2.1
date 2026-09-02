import 'package:flutter/material.dart';

/// A customizable card widget for the FinTrack application.
///
/// This widget provides a consistent card design across the app with
/// support for various styling options, gradients, and interactive states.
///
/// Example usage:
/// dart
/// CustomCard(
///   child: Text('Account Balance'),
///   elevation: 2.0,
///   borderRadius: 16.0,
///   onTap: () => print('Card tapped'),
/// )
/// 
class CustomCard extends StatelessWidget {
  /// The child widget to display inside the card.
  final Widget child;

  /// The padding inside the card.
  final EdgeInsetsGeometry padding;

  /// The margin around the card.
  final EdgeInsetsGeometry? margin;

  /// The elevation of the card.
  final double elevation;

  /// The border radius of the card.
  final double borderRadius;

  /// The background color of the card.
  final Color? backgroundColor;

  /// The gradient to use for the card background.
  /// If provided, [backgroundColor] will be ignored.
  final Gradient? gradient;

  /// The border color of the card.
  final Color? borderColor;

  /// The width of the border.
  final double borderWidth;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  /// Callback when the card is long-pressed.
  final VoidCallback? onLongPress;

  /// Whether the card should animate on tap.
  final bool animateOnTap;

  /// The width of the card (null = full width).
  final double? width;

  /// The height of the card (null = auto height).
  final double? height;

  /// Custom decoration for the card.
  final Decoration? decoration;

  const CustomCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.elevation = 2.0,
    this.borderRadius = 12.0,
    this.backgroundColor,
    this.gradient,
    this.borderColor,
    this.borderWidth = 1.0,
    this.onTap,
    this.onLongPress,
    this.animateOnTap = true,
    this.width,
    this.height,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget cardContent = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: _buildDecoration(isDark, theme),
      child: child,
    );

    if (onTap != null || onLongPress != null) {
      return Padding(
        padding: margin ?? EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(borderRadius),
            splashColor: theme.colorScheme.primary.withOpacity(0.1),
            highlightColor: theme.colorScheme.primary.withOpacity(0.05),
            child: cardContent,
          ),
        ),
      );
    }

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: cardContent,
    );
  }

  Decoration _buildDecoration(bool isDark, ThemeData theme) {
    if (decoration != null) {
      return decoration!;
    }

    Color bgColor;
    if (gradient != null) {
      bgColor = Colors.transparent;
    } else if (backgroundColor != null) {
      bgColor = backgroundColor!;
    } else {
      bgColor = isDark
          ? const Color(0xFF1E1E1E)
          : const Color(0xFFFFFFFF);
    }

    return BoxDecoration(
      color: gradient == null ? bgColor : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(borderRadius),
      border: borderColor != null
          ? Border.all(
              color: borderColor!,
              width: borderWidth,
            )
          : null,
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withOpacity(0.3)
              : Colors.black.withOpacity(0.08),
          blurRadius: elevation * 2,
          offset: Offset(0, elevation),
        ),
        if (elevation > 0)
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.white.withOpacity(0.05),
            blurRadius: elevation,
            offset: const Offset(0, 1),
          ),
      ],
    );
  }
}

/// A variant of CustomCard specifically designed for displaying statistics.
class StatCard extends StatelessWidget {
  /// The title of the statistic.
  final String title;

  /// The value to display.
  final String value;

  /// The subtitle or additional information.
  final String? subtitle;

  /// The icon to display.
  final IconData? icon;

  /// The color of the icon.
  final Color? iconColor;

  /// Whether the value represents a positive change.
  final bool? isPositive;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  /// The trend text (e.g., "+5.2%")
  final String? trendText;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.isPositive,
    this.onTap,
    this.trendText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (icon != null)
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: (iconColor ?? theme.colorScheme.primary)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: iconColor ?? theme.colorScheme.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12.0),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null || trendText != null) ...[
            const SizedBox(height: 4.0),
            Row(
              children: [
                if (trendText != null && isPositive != null) ...[
                  Icon(
                    isPositive! ? Icons.trending_up : Icons.trending_down,
                    size: 14,
                    color: isPositive!
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFF44336),
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    trendText!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isPositive!
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFF44336),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                ],
                if (subtitle != null)
                  Expanded(
                    child: Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

/// A variant of CustomCard designed for transaction list items.
class TransactionCard extends StatelessWidget {
  /// The transaction icon.
  final IconData icon;

  /// The color of the icon background.
  final Color iconColor;

  /// The transaction title.
  final String title;

  /// The transaction category or description.
  final String category;

  /// The transaction amount.
  final String amount;

  /// Whether the amount is positive (income) or negative (expense).
  final bool isIncome;

  /// The date of the transaction.
  final String date;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  const TransactionCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.category,
    required this.amount,
    required this.isIncome,
    required this.date,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amountColor = isIncome
        ? const Color(0xFF4CAF50)
        : theme.colorScheme.onSurface;

    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 48.0,
            height: 48.0,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12.0),
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
                const SizedBox(height: 2.0),
                Text(
                  '$category • $date',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          Text(
            '${isIncome ? '+' : '-'}$amount',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// A variant of CustomCard designed for stock portfolio items.
class StockCard extends StatelessWidget {
  /// The stock symbol.
  final String symbol;

  /// The company name.
  final String companyName;

  /// The current stock price.
  final String price;

  /// The change in price.
  final String change;

  /// The percentage change.
  final double changePercent;

  /// Whether to show a mini chart (placeholder).
  final Widget? chart;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  const StockCard({
    super.key,
    required this.symbol,
    required this.companyName,
    required this.price,
    required this.change,
    required this.changePercent,
    this.chart,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = changePercent >= 0;
    final changeColor = isPositive
        ? const Color(0xFF4CAF50)
        : const Color(0xFFF44336);

    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Text(
                        symbol,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    if (isPositive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6.0,
                          vertical: 2.0,
                        ),
                        decoration: BoxDecoration(
                          color: changeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.arrow_upward,
                              size: 10,
                              color: changeColor,
                            ),
                            const SizedBox(width: 2.0),
                            Text(
                              '${changePercent.toStringAsFixed(2)}%',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: changeColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6.0,
                          vertical: 2.0,
                        ),
                        decoration: BoxDecoration(
                          color: changeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.arrow_downward,
                              size: 10,
                              color: changeColor,
                            ),
                            const SizedBox(width: 2.0),
                            Text(
                              '${changePercent.abs().toStringAsFixed(2)}%',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: changeColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Text(
                  companyName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4.0),
                Text(
                  price,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  '$change ${isPositive ? '▲' : '▼'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: changeColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (chart != null) ...[
            const SizedBox(width: 16.0),
            SizedBox(
              width: 80,
              height: 40,
              child: chart!,
            ),
          ],
        ],
      ),
    );
  }
}

/// A variant of CustomCard designed for account/savings items.
class AccountCard extends StatelessWidget {
  /// The account icon.
  final IconData icon;

  /// The account name.
  final String name;

  /// The account type.
  final String type;

  /// The current balance.
  final String balance;

  /// The account color.
  final Color color;

  /// The progress towards a goal (0.0 to 1.0).
  final double? goalProgress;

  /// The goal amount text.
  final String? goalText;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  const AccountCard({
    super.key,
    required this.icon,
    required this.name,
    required this.type,
    required this.balance,
    required this.color,
    this.goalProgress,
    this.goalText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48.0,
                height: 48.0,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      type,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                balance,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          if (goalProgress != null && goalText != null) ...[
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Goal Progress',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                Text(
                  goalText!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: LinearProgressIndicator(
                value: goalProgress!.clamp(0.0, 1.0),
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8.0,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
