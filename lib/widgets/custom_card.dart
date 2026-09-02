import 'package:flutter/material.dart';

/// A customizable card widget for the FinTrack application.
///
/// This widget provides a consistent card styling throughout the app
/// with support for elevation, border radius, padding, and custom content.
class CustomCard extends StatelessWidget {
  /// The primary content of the card.
  final Widget child;

  /// The margin around the card.
  final EdgeInsetsGeometry? margin;

  /// The padding inside the card.
  final EdgeInsetsGeometry? padding;

  /// The border radius of the card.
  final double? borderRadius;

  /// The elevation of the card shadow.
  final double elevation;

  /// The color of the card background.
  final Color? color;

  /// An optional leading widget displayed before the child.
  final Widget? leading;

  /// An optional trailing widget displayed after the child.
  final Widget? trailing;

  /// Whether the card has a border.
  final bool hasBorder;

  /// The color of the border if [hasBorder] is true.
  final Color? borderColor;

  /// The width of the border if [hasBorder] is true.
  final double borderWidth;

  /// Whether the card is tappable.
  final bool isTappable;

  /// The callback when the card is tapped (only used if [isTappable] is true).
  final VoidCallback? onTap;

  /// The callback when the card is long pressed (only used if [isTappable] is true).
  final VoidCallback? onLongPress;

  /// The gradient background of the card (overrides [color] if provided).
  final Gradient? gradient;

  /// Creates a [CustomCard].
  const CustomCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.borderRadius,
    this.elevation = 2.0,
    this.color,
    this.leading,
    this.trailing,
    this.hasBorder = false,
    this.borderColor,
    this.borderWidth = 1.0,
    this.isTappable = false,
    this.onTap,
    this.onLongPress,
    this.gradient,
  });

  /// Creates a [CustomCard] with a standard appearance for the FinTrack app.
  factory CustomCard.standard({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    bool isTappable = false,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return CustomCard(
      key: key,
      child: child,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16.0),
      borderRadius: 12.0,
      elevation: 2.0,
      color: Colors.white,
      hasBorder: false,
      isTappable: isTappable,
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  /// Creates a [CustomCard] for displaying financial data with amounts.
  factory CustomCard.financialData({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Widget? leading,
    Widget? trailing,
    bool isTappable = false,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return CustomCard(
      key: key,
      child: Row(
        children: [
          if (leading != null) ...[
            leading,
            const SizedBox(width: 12.0),
          ],
          Expanded(child: child),
          if (trailing != null) ...[
            const SizedBox(width: 12.0),
            trailing,
          ],
        ],
      ),
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16.0),
      borderRadius: 12.0,
      elevation: 1.5,
      color: Colors.white,
      hasBorder: true,
      borderColor: Colors.grey.shade200,
      isTappable: isTappable,
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  /// Creates a [CustomCard] for transaction items.
  factory CustomCard.transaction({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Widget? leading,
    Widget? trailing,
    bool isTappable = true,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return CustomCard(
      key: key,
      child: Row(
        children: [
          if (leading != null) ...[
            leading,
            const SizedBox(width: 12.0),
          ],
          Expanded(child: child),
          if (trailing != null) trailing,
        ],
      ),
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      padding: padding ?? const EdgeInsets.all(12.0),
      borderRadius: 10.0,
      elevation: 1.0,
      color: Colors.white,
      hasBorder: true,
      borderColor: Colors.grey.shade100,
      isTappable: isTappable,
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  /// Creates a [CustomCard] for savings goal displays.
  factory CustomCard.savingsGoal({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Color? accentColor,
    bool isTappable = false,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return CustomCard(
      key: key,
      child: child,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16.0),
      borderRadius: 16.0,
      elevation: 3.0,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          (accentColor ?? const Color(0xFF4CAF50)).withOpacity(0.1),
          Colors.white,
        ],
      ),
      hasBorder: true,
      borderColor: (accentColor ?? const Color(0xFF4CAF50)).withOpacity(0.3),
      borderWidth: 1.5,
      isTappable: isTappable,
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  /// Creates a [CustomCard] for stock portfolio items.
  factory CustomCard.portfolioItem({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Widget? leading,
    Widget? trailing,
    bool isPositive = true,
    bool isTappable = true,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return CustomCard(
      key: key,
      child: Row(
        children: [
          if (leading != null) ...[
            leading,
            const SizedBox(width: 12.0),
          ],
          Expanded(child: child),
          if (trailing != null) trailing,
        ],
      ),
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      padding: padding ?? const EdgeInsets.all(14.0),
      borderRadius: 12.0,
      elevation: 1.5,
      color: Colors.white,
      hasBorder: true,
      borderColor: isPositive
          ? Colors.green.shade100
          : Colors.red.shade100,
      borderWidth: 1.0,
      isTappable: isTappable,
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  /// Creates a [CustomCard] for summary/statistics displays.
  factory CustomCard.summary({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Color? accentColor,
    bool isTappable = false,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return CustomCard(
      key: key,
      child: child,
      margin: margin ?? const EdgeInsets.all(8.0),
      padding: padding ?? const EdgeInsets.all(20.0),
      borderRadius: 16.0,
      elevation: 4.0,
      color: Colors.white,
      hasBorder: false,
      isTappable: isTappable,
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultBorderRadius = borderRadius ?? 12.0;

    Widget cardContent = Container(
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? Colors.white) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(defaultBorderRadius),
        border: hasBorder
            ? Border.all(
                color: borderColor ?? Colors.grey.shade300,
                width: borderWidth,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: elevation * 2,
            offset: Offset(0, elevation),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(defaultBorderRadius),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16.0),
          child: leading != null || trailing != null
              ? Row(
                  children: [
                    if (leading != null) ...[
                      leading!,
                      const SizedBox(width: 12.0),
                    ],
                    Expanded(child: child),
                    if (trailing != null) ...[
                      const SizedBox(width: 12.0),
                      trailing!,
                    ],
                  ],
                )
              : child,
        ),
      ),
    );

    if (isTappable) {
      return Container(
        margin: margin,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(defaultBorderRadius),
            child: cardContent,
          ),
        ),
      );
    }

    return Container(
      margin: margin,
      child: cardContent,
    );
  }
}

/// A widget that displays a section header with optional action.
class CardSectionHeader extends StatelessWidget {
  /// The title of the section.
  final String title;

  /// An optional subtitle for the section.
  final String? subtitle;

  /// An optional action widget (e.g., button) displayed on the right.
  final Widget? action;

  /// The padding around the header.
  final EdgeInsetsGeometry? padding;

  /// Creates a [CardSectionHeader].
  const CardSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2.0),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

/// A widget that displays a card with an icon header.
class CustomCardWithIcon extends StatelessWidget {
  /// The icon to display in the header.
  final IconData icon;

  /// The color of the icon.
  final Color iconColor;

  /// The background color of the icon container.
  final Color? iconBackgroundColor;

  /// The title of the card.
  final String title;

  /// The subtitle of the card.
  final String? subtitle;

  /// The value or content to display.
  final String value;

  /// The change or delta to display (e.g., percentage change).
  final String? change;

  /// Whether the change is positive.
  final bool? isPositiveChange;

  /// The border radius of the card.
  final double borderRadius;

  /// The margin around the card.
  final EdgeInsetsGeometry? margin;

  /// Whether the card is tappable.
  final bool isTappable;

  /// The callback when the card is tapped.
  final VoidCallback? onTap;

  /// Creates a [CustomCardWithIcon].
  const CustomCardWithIcon({
    super.key,
    required this.icon,
    required this.iconColor,
    this.iconBackgroundColor,
    required this.title,
    this.subtitle,
    required this.value,
    this.change,
    this.isPositiveChange,
    this.borderRadius = 12.0,
    this.margin,
    this.isTappable = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      margin: margin,
      padding: const EdgeInsets.all(16.0),
      borderRadius: borderRadius,
      elevation: 2.0,
      color: Colors.white,
      isTappable: isTappable,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: iconBackgroundColor ?? iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade500,
                            ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                ),
              ),
              if (change != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: isPositiveChange == true
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Text(
                    change!,
                    style: TextStyle(
                      color: isPositiveChange == true
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.0,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
