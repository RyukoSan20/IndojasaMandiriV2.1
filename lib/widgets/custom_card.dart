import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// A customizable card widget for FinTrack application.
/// Provides consistent styling for displaying financial data across the app.
class CustomCard extends StatelessWidget {
  /// The child widget to display inside the card.
  final Widget child;

  /// Optional title text displayed at the top of the card.
  final String? title;

  /// Optional subtitle text displayed below the title.
  final String? subtitle;

  /// Optional leading icon or widget displayed before the content.
  final Widget? leading;

  /// Optional trailing widget displayed at the end of the card.
  final Widget? trailing;

  /// The amount of padding inside the card.
  final double padding;

  /// The margin around the card.
  final EdgeInsetsGeometry? margin;

  /// The border radius of the card.
  final double borderRadius;

  /// Whether the card has an elevation shadow.
  final bool hasElevation;

  /// Whether the card has a colored left border accent.
  final bool hasAccentBorder;

  /// The color of the accent border (if enabled).
  final Color accentColor;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  /// Whether the card is in a loading state.
  final bool isLoading;

  /// Optional loading message text.
  final String? loadingMessage;

  const CustomCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.padding = 16.0,
    this.margin,
    this.borderRadius = 12.0,
    this.hasElevation = true,
    this.hasAccentBorder = false,
    this.accentColor = AppColors.primary,
    this.onTap,
    this.isLoading = false,
    this.loadingMessage,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(borderRadius),
        border: hasAccentBorder
            ? Border(
                left: BorderSide(
                  color: accentColor,
                  width: 4.0,
                ),
              )
            : null,
        boxShadow: hasElevation
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8.0,
                  offset: const Offset(0, 2),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4.0,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: isLoading ? _buildLoadingContent() : _buildContent(),
            ),
          ),
        ),
      ),
    );

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: cardContent,
    );
  }

  Widget _buildContent() {
    if (title == null && subtitle == null && leading == null && trailing == null) {
      return child;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null || subtitle != null || leading != null || trailing != null)
          _buildHeader(),
        if (title != null || subtitle != null || leading != null || trailing != null)
          const SizedBox(height: 12.0),
        child,
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: 12.0),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null)
                Text(
                  title!,
                  style: AppTextStyles.cardTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              if (subtitle != null) ...[
                const SizedBox(height: 2.0),
                Text(
                  subtitle!,
                  style: AppTextStyles.cardSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12.0),
          trailing!,
        ],
      ],
    );
  }

  Widget _buildLoadingContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20.0),
        const CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
        if (loadingMessage != null) ...[
          const SizedBox(height: 16.0),
          Text(
            loadingMessage!,
            style: AppTextStyles.cardSubtitle,
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 20.0),
      ],
    );
  }
}

/// A variant of CustomCard specifically designed for displaying financial amounts.
class FinancialCard extends StatelessWidget {
  /// The main amount to display.
  final String amount;

  /// The currency symbol or code.
  final String currencySymbol;

  /// The label describing what this amount represents.
  final String label;

  /// The change amount (positive or negative) for comparison.
  final String? changeAmount;

  /// The percentage change.
  final double? changePercentage;

  /// Whether the change is positive (green) or negative (red).
  final bool isPositiveChange;

  /// The icon to display with the amount.
  final IconData? icon;

  /// The color theme for this card.
  final Color? themeColor;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  const FinancialCard({
    super.key,
    required this.amount,
    this.currencySymbol = '\$',
    required this.label,
    this.changeAmount,
    this.changePercentage,
    this.isPositiveChange = true,
    this.icon,
    this.themeColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = themeColor ?? AppColors.primary;

    return CustomCard(
      onTap: onTap,
      hasAccentBorder: true,
      accentColor: effectiveColor,
      padding: 20.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: effectiveColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Icon(
                    icon,
                    color: effectiveColor,
                    size: 20.0,
                  ),
                ),
                const SizedBox(width: 12.0),
              ],
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.cardSubtitle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  '$currencySymbol$amount',
                  style: AppTextStyles.financialAmount.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (changeAmount != null || changePercentage != null)
                _buildChangeIndicator(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChangeIndicator() {
    final color = isPositiveChange ? AppColors.success : AppColors.error;
    final icon = isPositiveChange ? Icons.arrow_upward : Icons.arrow_downward;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 14.0,
          ),
          if (changePercentage != null)
            Text(
              '${changePercentage!.toStringAsFixed(1)}%',
              style: AppTextStyles.changeIndicator.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

/// A compact variant of CustomCard for list items.
class CompactCard extends StatelessWidget {
  /// The primary text content.
  final String title;

  /// The secondary text content.
  final String? subtitle;

  /// The leading widget.
  final Widget? leading;

  /// The trailing widget.
  final Widget? trailing;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  const CompactCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Material(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10.0),
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.05),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: 12.0),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.listItemTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2.0),
                        Text(
                          subtitle!,
                          style: AppTextStyles.listItemSubtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 12.0),
                  trailing!,
                ] else if (onTap != null)
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                    size: 20.0,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
