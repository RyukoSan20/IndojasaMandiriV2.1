import 'package:flutter/material.dart';

/// A reusable custom card widget for the FinTrack application.
/// 
/// Provides consistent card styling across the app with support for:
/// - Custom padding and margins
/// - Optional leading widget (icon, image, etc.)
/// - Title and subtitle text
/// - Trailing action area
/// - Custom background and border colors
/// - Pressable state with visual feedback
/// - Elevation control
/// 
/// Example usage:
/// dart
/// CustomCard(
///   title: 'Total Balance',
///   subtitle: '\$12,500.00',
///   leading: Icon(Icons.account_balance_wallet),
///   trailing: Icon(Icons.arrow_forward_ios, size: 16),
///   onTap: () => navigateToDetails(),
/// )
/// 
class CustomCard extends StatelessWidget {
  /// The primary text content of the card.
  final String title;

  /// Secondary text content displayed below the title.
  final String? subtitle;

  /// Widget displayed at the start of the card content area.
  final Widget? leading;

  /// Widget displayed at the end of the card content area.
  final Widget? trailing;

  /// Callback invoked when the card is tapped.
  final VoidCallback? onTap;

  /// Callback invoked when the card is long-pressed.
  final VoidCallback? onLongPress;

  /// Background color of the card.
  /// 
  /// Defaults to [Theme.of(context).cardColor].
  final Color? backgroundColor;

  /// Border color of the card.
  /// 
  /// If provided, a border will be drawn around the card.
  final Color? borderColor;

  /// Width of the border (if [borderColor] is provided).
  /// 
  /// Defaults to 1.0.
  final double borderWidth;

  /// Elevation (shadow) of the card.
  /// 
  /// Defaults to 2.0.
  final double elevation;

  /// Internal padding of the card content.
  /// 
  /// Defaults to 16.0 on all sides.
  final double padding;

  /// External margin around the card.
  /// 
  /// Defaults to 8.0 on all sides.
  final double margin;

  /// Border radius of the card corners.
  /// 
  /// Defaults to 12.0.
  final double borderRadius;

  /// Whether the card should animate on press.
  /// 
  /// Defaults to true.
  final bool animateOnPress;

  /// Whether the card is in a loading state.
  /// 
  /// When true, shows a shimmer effect overlay.
  final bool isLoading;

  /// Custom text style for the title.
  final TextStyle? titleStyle;

  /// Custom text style for the subtitle.
  final TextStyle? subtitleStyle;

  const CustomCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.elevation = 2.0,
    this.padding = 16.0,
    this.margin = 8.0,
    this.borderRadius = 12.0,
    this.animateOnPress = true,
    this.isLoading = false,
    this.titleStyle,
    this.subtitleStyle,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color effectiveBackgroundColor =
        backgroundColor ?? theme.cardColor;
    final Color effectiveBorderColor =
        borderColor ?? theme.colorScheme.outline.withOpacity(0.1);

    Widget cardContent = Container(
      margin: EdgeInsets.all(margin),
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderColor != null
            ? Border.all(
                color: effectiveBorderColor,
                width: borderWidth,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: elevation * 2,
            offset: Offset(0, elevation / 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Row(
              children: [
                // Leading widget
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: 12.0),
                ],
                // Main content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: titleStyle ??
                            theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4.0),
                        Text(
                          subtitle!,
                          style: subtitleStyle ??
                              theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.7),
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                // Trailing widget
                if (trailing != null) ...[
                  const SizedBox(width: 12.0),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );

    // Wrap with loading overlay if needed
    if (isLoading) {
      cardContent = Stack(
        children: [
          cardContent,
          Positioned.fill(
            child: Container(
              margin: EdgeInsets.all(margin),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: const Center(
                child: SizedBox(
                  width: 24.0,
                  height: 24.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Handle interactivity
    if (onTap != null || onLongPress != null) {
      return GestureDetector(
        onTap: isLoading ? null : onTap,
        onLongPress: isLoading ? null : onLongPress,
        child: animateOnPress
            ? _AnimatedPressableCard(
                child: cardContent,
              )
            : cardContent,
      );
    }

    return cardContent;
  }
}

/// Internal widget that handles press animations.
class _AnimatedPressableCard extends StatefulWidget {
  final Widget child;

  const _AnimatedPressableCard({
    required this.child,
  });

  @override
  State<_AnimatedPressableCard> createState() => _AnimatedPressableCardState();
}

class _AnimatedPressableCardState extends State<_AnimatedPressableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// A specialized card variant for displaying financial summary data.
/// 
/// Optimized for displaying account balances, portfolio values,
/// and other key financial metrics with emphasis styling.
class FinancialSummaryCard extends StatelessWidget {
  /// The label describing the financial metric.
  final String label;

  /// The monetary value to display.
  final String value;

  /// The change amount (positive or negative) for display.
  final double? changeAmount;

  /// The change percentage for display.
  final double? changePercentage;

  /// Icon to display alongside the value.
  final IconData? icon;

  /// Color to use for positive changes (green by default).
  final Color positiveColor;

  /// Color to use for negative changes (red by default).
  final Color negativeColor;

  /// Whether to format the change as currency.
  final bool formatChangeAsCurrency;

  /// Callback invoked when the card is tapped.
  final VoidCallback? onTap;

  const FinancialSummaryCard({
    super.key,
    required this.label,
    required this.value,
    this.changeAmount,
    this.changePercentage,
    this.icon,
    this.positiveColor = const Color(0xFF4CAF50),
    this.negativeColor = const Color(0xFFE53935),
    this.formatChangeAsCurrency = false,
    this.onTap,
  });

  bool get _hasChange => changeAmount != null || changePercentage != null;

  bool get _isPositive {
    if (changeAmount != null) return changeAmount! >= 0;
    if (changePercentage != null) return changePercentage! >= 0;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color changeColor = _isPositive ? positiveColor : negativeColor;
    final IconData changeIcon =
        _isPositive ? Icons.arrow_upward : Icons.arrow_downward;

    return CustomCard(
      title: label,
      subtitle: value,
      onTap: onTap,
      leading: icon != null
          ? Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.onPrimaryContainer,
                size: 24.0,
              ),
            )
          : null,
      trailing: _hasChange
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  changeIcon,
                  color: changeColor,
                  size: 16.0,
                ),
                const SizedBox(width: 4.0),
                Text(
                  _buildChangeText(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: changeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          : null,
      titleStyle: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface.withOpacity(0.7),
      ),
      subtitleStyle: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  String _buildChangeText() {
    final List<String> parts = [];

    if (changeAmount != null) {
      final String amountStr = formatChangeAsCurrency
          ? '\$${changeAmount!.abs().toStringAsFixed(2)}'
          : changeAmount!.abs().toStringAsFixed(2);
      parts.add(amountStr);
    }

    if (changePercentage != null) {
      parts.add('${changePercentage!.abs().toStringAsFixed(2)}%');
    }

    return parts.join(' ');
  }
}

/// A specialized card variant for displaying transaction items.
/// 
/// Optimized for transaction list displays with icon, title,
/// category, and amount styling.
class TransactionCard extends StatelessWidget {
  /// The transaction title/description.
  final String title;

  /// The transaction category.
  final String category;

  /// The transaction amount (positive for income, negative for expense).
  final double amount;

  /// The transaction date.
  final DateTime date;

  /// Icon representing the transaction category.
  final IconData icon;

  /// Color for the category icon background.
  final Color iconBackgroundColor;

  /// Callback invoked when the card is tapped.
  final VoidCallback? onTap;

  const TransactionCard({
    super.key,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.icon,
    this.iconBackgroundColor = const Color(0xFFE3F2FD),
    this.onTap,
  });

  bool get _isIncome => amount >= 0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color amountColor = _isIncome
        ? const Color(0xFF4CAF50)
        : theme.colorScheme.onSurface;
    final String amountPrefix = _isIncome ? '+' : '-';
    final String amountString =
        '$amountPrefix\$${amount.abs().toStringAsFixed(2)}';

    return CustomCard(
      onTap: onTap,
      padding: 12.0,
      margin: 4.0,
      leading: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: iconBackgroundColor,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 20.0,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            amountString,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: amountColor,
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            _formatDate(date),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
      titleStyle: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w500,
        color: theme.colorScheme.onSurface,
      ),
      subtitleStyle: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurface.withOpacity(0.6),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[date.month - 1]} ${date.day}';
    }
  }
}
