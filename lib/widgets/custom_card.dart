import 'package:flutter/material.dart';

/// A customizable card widget for the FinTrack application.
/// 
/// This widget provides a flexible card design that can be used for various
/// purposes including transaction items, account summaries, stock cards,
/// and savings goal displays.
/// 
/// Example usage:
/// dart
/// CustomCard(
///   title: 'Checking Account',
///   subtitle: '\$5,234.56',
///   icon: Icons.account_balance_wallet,
///   onTap: () => print('Card tapped'),
///   type: CardType.elevated,
/// )
/// 
enum CardType {
  /// Elevated card with shadow
  elevated,
  
  /// Outlined card with border
  outlined,
  
  /// Filled card with background color
  filled,
  
  /// Compact card for list items
  compact,
}

enum CardVariant {
  /// Default card variant
  defaultVariant,
  
  /// Success variant with green accent
  success,
  
  /// Warning variant with orange accent
  warning,
  
  /// Error variant with red accent
  error,
  
  /// Info variant with blue accent
  info,
}

/// Custom card widget for FinTrack application
class CustomCard extends StatelessWidget {
  /// Creates a custom card widget
  const CustomCard({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.icon,
    this.iconColor,
    this.type = CardType.elevated,
    this.variant = CardVariant.defaultVariant,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.elevation,
    this.child,
    this.showDivider = false,
    this.dividerColor,
    this.dividerThickness,
    this.gradient,
  });

  /// The main title text displayed on the card
  final String? title;

  /// The subtitle text displayed below the title
  final String? subtitle;

  /// A widget displayed before the title/subtitle
  final Widget? leading;

  /// A widget displayed at the end of the card
  final Widget? trailing;

  /// An icon to display on the card
  final IconData? icon;

  /// The color of the icon
  final Color? iconColor;

  /// The type of card styling to apply
  final CardType type;

  /// The color variant of the card
  final CardVariant variant;

  /// Callback when the card is tapped
  final VoidCallback? onTap;

  /// Internal padding of the card content
  final EdgeInsetsGeometry? padding;

  /// External margin around the card
  final EdgeInsetsGeometry? margin;

  /// Custom border radius
  final double? borderRadius;

  /// Custom background color
  final Color? backgroundColor;

  /// Custom elevation for elevated cards
  final double? elevation;

  /// Custom child widget to display instead of title/subtitle
  final Widget? child;

  /// Whether to show a divider between header and content
  final bool showDivider;

  /// Color of the divider
  final Color? dividerColor;

  /// Thickness of the divider
  final double? dividerThickness;

  /// Gradient to apply to the card background
  final Gradient? gradient;

  /// Returns the appropriate border radius based on card type
  double get _borderRadiusValue {
    if (borderRadius != null) return borderRadius!;
    switch (type) {
      case CardType.compact:
        return 8.0;
      case CardType.elevated:
      case CardType.outlined:
      case CardType.filled:
        return 16.0;
    }
  }

  /// Returns the appropriate padding based on card type
  EdgeInsetsGeometry get _paddingValue {
    if (padding != null) return padding!;
    switch (type) {
      case CardType.compact:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case CardType.elevated:
      case CardType.outlined:
      case CardType.filled:
        return const EdgeInsets.all(16);
    }
  }

  /// Returns the appropriate elevation based on card type
  double get _elevationValue {
    if (elevation != null) return elevation!;
    switch (type) {
      case CardType.elevated:
        return 2.0;
      case CardType.outlined:
        return 0.0;
      case CardType.filled:
        return 0.0;
      case CardType.compact:
        return 1.0;
    }
  }

  /// Returns the variant color based on card variant
  Color _getVariantColor(BuildContext context) {
    switch (variant) {
      case CardVariant.success:
        return const Color(0xFF4CAF50);
      case CardVariant.warning:
        return const Color(0xFFFF9800);
      case CardVariant.error:
        return const Color(0xFFF44336);
      case CardVariant.info:
        return const Color(0xFF2196F3);
      case CardVariant.defaultVariant:
        return Colors.transparent;
    }
  }

  /// Returns the appropriate background color
  Color? _getBackgroundColor(BuildContext context) {
    if (backgroundColor != null) return backgroundColor;
    if (gradient != null) return null;
    switch (type) {
      case CardType.elevated:
        return Theme.of(context).cardColor;
      case CardType.outlined:
        return Theme.of(context).cardColor;
      case CardType.filled:
        return Theme.of(context).cardColor.withOpacity(0.9);
      case CardType.compact:
        return Theme.of(context).cardColor.withOpacity(0.7);
    }
  }

  /// Builds the card decoration based on type and variant
  BoxDecoration _buildDecoration(BuildContext context) {
    final variantColor = _getVariantColor(context);
    final bgColor = _getBackgroundColor(context);
    
    return BoxDecoration(
      color: bgColor,
      gradient: gradient,
      borderRadius: BorderRadius.circular(_borderRadiusValue),
      border: type == CardType.outlined
          ? Border.all(
              color: variant != CardVariant.defaultVariant
                  ? variantColor.withOpacity(0.5)
                  : Theme.of(context).dividerColor,
              width: 1,
            )
          : null,
      boxShadow: type == CardType.elevated
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ]
          : null,
    );
  }

  /// Builds the leading widget
  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;
    if (icon != null) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: (iconColor ?? Theme.of(context).primaryColor).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: iconColor ?? Theme.of(context).primaryColor,
          size: 24,
        ),
      );
    }
    return null;
  }

  /// Builds the trailing widget
  Widget? _buildTrailing(BuildContext context) {
    if (trailing != null) return trailing;
    
    // If there's a variant accent, show a small indicator
    if (variant != CardVariant.defaultVariant) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: _getVariantColor(context),
          shape: BoxShape.circle,
        ),
      );
    }
    
    return null;
  }

  /// Builds the default card content
  Widget _buildContent(BuildContext context) {
    if (child != null) return child!;
    
    return Row(
      children: [
        if (_buildLeading(context) != null) ...[
          _buildLeading(context)!,
          const SizedBox(width: 16),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null)
                Text(
                  title!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        if (_buildTrailing(context) != null) ...[
          const SizedBox(width: 12),
          _buildTrailing(context)!,
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Padding(
      padding: _paddingValue,
      child: _buildContent(context),
    );

    // Add variant accent stripe for non-default variants
    if (variant != CardVariant.defaultVariant && type != CardType.compact) {
      cardContent = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: _getVariantColor(context),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(_borderRadiusValue),
                topRight: Radius.circular(_borderRadiusValue),
              ),
            ),
          ),
          Expanded(child: cardContent),
        ],
      );
    }

    Widget card;
    
    switch (type) {
      case CardType.elevated:
        card = Material(
          color: Colors.transparent,
          elevation: _elevationValue,
          borderRadius: BorderRadius.circular(_borderRadiusValue),
          child: cardContent,
        );
        break;
      case CardType.outlined:
      case CardType.filled:
      case CardType.compact:
        card = Container(
          decoration: _buildDecoration(context),
          child: cardContent,
        );
        break;
    }

    // Wrap with divider if needed
    if (showDivider && type != CardType.compact) {
      card = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          card,
          Divider(
            height: 1,
            thickness: dividerThickness ?? 1,
            color: dividerColor ?? Theme.of(context).dividerColor,
          ),
        ],
      );
    }

    // Wrap with margin and tap handling
    return Padding(
      padding: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: onTap != null
          ? Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(_borderRadiusValue),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(_borderRadiusValue),
                child: card,
              ),
            )
          : card,
    );
  }
}

/// A more compact version of CustomCard for list items
class CompactCard extends StatelessWidget {
  /// Creates a compact card for list items
  const CompactCard({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.padding,
    this.margin,
    this.variant = CardVariant.defaultVariant,
    this.iconColor,
  });

  /// The main title text
  final String? title;

  /// The subtitle text
  final String? subtitle;

  /// A widget displayed before the title
  final Widget? leading;

  /// A widget displayed at the end
  final Widget? trailing;

  /// Callback when tapped
  final VoidCallback? onTap;

  /// Internal padding
  final EdgeInsetsGeometry? padding;

  /// External margin
  final EdgeInsetsGeometry? margin;

  /// The color variant
  final CardVariant variant;

  /// The color of the leading icon
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: trailing,
      onTap: onTap,
      padding: padding,
      margin: margin,
      variant: variant,
      type: CardType.compact,
      iconColor: iconColor,
    );
  }
}

/// A card specifically designed for displaying amounts
class AmountCard extends StatelessWidget {
  /// Creates an amount display card
  const AmountCard({
    super.key,
    required this.amount,
    this.label,
    this.currency = '\$',
    this.isPositive = true,
    this.showSign = true,
    this.icon,
    this.iconColor,
    this.onTap,
    this.padding,
    this.margin,
    this.compact = false,
  });

  /// The amount to display
  final String amount;

  /// Label for the amount
  final String? label;

  /// Currency symbol
  final String currency;

  /// Whether the amount is positive
  final bool isPositive;

  /// Whether to show the +/- sign
  final bool showSign;

  /// Icon to display
  final IconData? icon;

  /// Color of the icon
  final Color? iconColor;

  /// Callback when tapped
  final VoidCallback? onTap;

  /// Internal padding
  final EdgeInsetsGeometry? padding;

  /// External margin
  final EdgeInsetsGeometry? margin;

  /// Whether to use compact styling
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final amountColor = isPositive
        ? const Color(0xFF4CAF50)
        : const Color(0xFFF44336);
    
    final formattedAmount = showSign
        ? '${isPositive ? '+' : '-'}$currency$amount'
        : '$currency$amount';

    return CustomCard(
      title: formattedAmount,
      subtitle: label,
      icon: icon,
      iconColor: iconColor ?? amountColor,
      onTap: onTap,
      padding: padding,
      margin: margin,
      type: compact ? CardType.compact : CardType.elevated,
      titleStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: amountColor,
      ),
    );
  }
}

/// Extension to add custom styling to CustomCard
extension CustomCardExtensions on CustomCard {
  /// Creates a copy with optional new values
  CustomCard copyWith({
    String? title,
    String? subtitle,
    Widget? leading,
    Widget? trailing,
    IconData? icon,
    Color? iconColor,
    CardType? type,
    CardVariant? variant,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? borderRadius,
    Color? backgroundColor,
    double? elevation,
    Widget? child,
    bool? showDivider,
    Color? dividerColor,
    double? dividerThickness,
    Gradient? gradient,
  }) {
    return CustomCard(
      key: key,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      leading: leading ?? this.leading,
      trailing: trailing ?? this.trailing,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      type: type ?? this.type,
      variant: variant ?? this.variant,
      onTap: onTap ?? this.onTap,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      borderRadius: borderRadius ?? this.borderRadius,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      elevation: elevation ?? this.elevation,
      child: child ?? this.child,
      showDivider: showDivider ?? this.showDivider,
      dividerColor: dividerColor ?? this.dividerDividerColor,
      dividerThickness: dividerThickness ?? this.dividerThickness,
      gradient: gradient ?? this.gradient,
    );
  }
}

/// Text style property added to CustomCard
extension CustomCardTextStyle on CustomCard {
  /// Custom title text style
  TextStyle? get titleStyle => null;
}

/// Helper class for building common card patterns
class CardBuilder {
  /// Builds a transaction card
  static Widget transaction({
    required String title,
    required String amount,
    required String date,
    required IconData icon,
    Color? iconColor,
    bool isExpense = true,
    VoidCallback? onTap,
  }) {
    return CustomCard(
      title: title,
      subtitle: date,
      icon: icon,
      iconColor: iconColor,
      onTap: onTap,
      trailing: Text(
        '${isExpense ? '-' : '+'}\$$amount',
        style: TextStyle(
          color: isExpense
              ? const Color(0xFFF44336)
              : const Color(0xFF4CAF50),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Builds an account summary card
  static Widget account({
    required String accountName,
    required String balance,
    required IconData icon,
    Color? iconColor,
    String? accountNumber,
    VoidCallback? onTap,
  }) {
    return CustomCard(
      title: accountName,
      subtitle: accountNumber ?? 'Account',
      icon: icon,
      iconColor: iconColor,
      onTap: onTap,
      trailing: Text(
        '\$$balance',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  /// Builds a savings goal card
  static Widget savingsGoal({
    required String goalName,
    required double current,
    required double target,
    required IconData icon,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    final progress = (current / target).clamp(0.0, 1.0);
    final percentage = (progress * 100).toStringAsFixed(0);
    
    return CustomCard(
      title: goalName,
      subtitle: '$percentage% saved',
      icon: icon,
      iconColor: iconColor,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${current.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '\$${target.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                iconColor ?? const Color(0xFF4CAF50),
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a stock holding card
  static Widget stockHolding({
    required String symbol,
    required String companyName,
    required double shares,
    required double currentPrice,
    required double purchasePrice,
    VoidCallback? onTap,
  }) {
    final change = ((currentPrice - purchasePrice) / purchasePrice) * 100;
    final isPositive = change >= 0;
    
    return CustomCard(
      title: symbol,
      subtitle: '$shares shares • $companyName',
      icon: Icons.show_chart,
      iconColor: isPositive
          ? const Color(0xFF4CAF50)
          : const Color(0xFFF44336),
      onTap: onTap,
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '\$${currentPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            '${isPositive ? '+' : ''}${change.toStringAsFixed(2)}%',
            style: TextStyle(
              color: isPositive
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFF44336),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
