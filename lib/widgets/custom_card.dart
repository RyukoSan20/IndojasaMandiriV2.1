import 'package:flutter/material.dart';

/// A customizable card widget for the FinTrack application.
/// Provides consistent card styling across the app with support for
/// different card variants, states, and interactive behaviors.
enum CardVariant {
  /// Standard card with subtle elevation
  standard,
  
  /// Elevated card with stronger shadow
  elevated,
  
  /// Outlined card with border
  outlined,
  
  /// Filled card with background color
  filled,
  
  /// Gradient card for premium/featured content
  gradient,
  
  /// Compact card for list items
  compact,
}

enum CardStatus {
  /// Default normal state
  normal,
  
  /// Success state with green accent
  success,
  
  /// Warning state with amber accent
  warning,
  
  /// Error state with red accent
  error,
  
  /// Disabled state with reduced opacity
  disabled,
}

class CustomCard extends StatelessWidget {
  /// The main content of the card
  final Widget child;
  
  /// Optional header widget displayed at the top
  final Widget? header;
  
  /// Optional footer widget displayed at the bottom
  final Widget? footer;
  
  /// Card variant determining visual style
  final CardVariant variant;
  
  /// Card status for semantic coloring
  final CardStatus status;
  
  /// Custom padding inside the card
  final EdgeInsetsGeometry? padding;
  
  /// Custom margin around the card
  final EdgeInsetsGeometry? margin;
  
  /// Custom border radius
  final double? borderRadius;
  
  /// Custom elevation for elevated variants
  final double? elevation;
  
  /// Background color override
  final Color? backgroundColor;
  
  /// Border color for outlined variant
  final Color? borderColor;
  
  /// Gradient colors for gradient variant
  final List<Color>? gradientColors;
  
  /// Gradient direction
  final AlignmentGeometry gradientBegin;
  
  /// Gradient end alignment
  final AlignmentGeometry gradientEnd;
  
  /// Callback when card is tapped
  final VoidCallback? onTap;
  
  /// Callback when card is long pressed
  final VoidCallback? onLongPress;
  
  /// Whether card should show loading state
  final bool isLoading;
  
  /// Custom loading indicator widget
  final Widget? loadingIndicator;
  
  /// Whether card is enabled (affects interactivity)
  final bool enabled;
  
  /// Custom shadow color
  final Color? shadowColor;
  
  /// Clip behavior for content overflow
  final Clip clipBehavior;
  
  /// Width constraint
  final double? width;
  
  /// Height constraint
  final double? height;

  const CustomCard({
    super.key,
    required this.child,
    this.header,
    this.footer,
    this.variant = CardVariant.standard,
    this.status = CardStatus.normal,
    this.padding,
    this.margin,
    this.borderRadius,
    this.elevation,
    this.backgroundColor,
    this.borderColor,
    this.gradientColors,
    this.gradientBegin = Alignment.topLeft,
    this.gradientEnd = Alignment.bottomRight,
    this.onTap,
    this.onLongPress,
    this.isLoading = false,
    this.loadingIndicator,
    this.enabled = true,
    this.shadowColor,
    this.clipBehavior = Clip.none,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Calculate effective border radius
    final effectiveBorderRadius = borderRadius ?? _getDefaultBorderRadius();
    
    // Calculate effective elevation
    final effectiveElevation = elevation ?? _getDefaultElevation();
    
    // Calculate effective shadow color
    final effectiveShadowColor = shadowColor ?? 
        (isDark ? Colors.black54 : Colors.black26);
    
    // Determine background color based on variant, status, and theme
    final effectiveBackgroundColor = backgroundColor ?? 
        _getBackgroundColor(theme, isDark);
    
    // Determine border color for outlined variant
    final effectiveBorderColor = borderColor ?? 
        _getBorderColor(theme, isDark);
    
    // Determine gradient colors
    final effectiveGradientColors = gradientColors ?? 
        _getGradientColors(theme, isDark);

    Widget cardContent = _buildCardContent(
      context,
      theme,
      effectiveBackgroundColor,
      effectiveBorderColor,
      effectiveBorderRadius,
      effectiveElevation,
      effectiveShadowColor,
      effectiveGradientColors,
    );

    // Apply tap handlers if enabled and callbacks provided
    if (enabled && (onTap != null || onLongPress != null)) {
      cardContent = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          onLongPress: enabled ? onLongPress : null,
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          child: cardContent,
        ),
      );
    }

    // Apply constraints
    if (width != null || height != null) {
      cardContent = SizedBox(
        width: width,
        height: height,
        child: cardContent,
      );
    }

    // Apply margin
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: cardContent,
    );
  }

  Widget _buildCardContent(
    BuildContext context,
    ThemeData theme,
    Color backgroundColor,
    Color borderColor,
    double borderRadius,
    double elevation,
    Color shadowColor,
    List<Color> gradientColors,
  ) {
    switch (variant) {
      case CardVariant.outlined:
        return _buildOutlinedCard(
          theme,
          backgroundColor,
          borderColor,
          borderRadius,
        );
      
      case CardVariant.gradient:
        return _buildGradientCard(
          theme,
          gradientColors,
          borderRadius,
          shadowColor,
          elevation,
        );
      
      case CardVariant.filled:
        return _buildFilledCard(
          theme,
          backgroundColor,
          borderRadius,
        );
      
      case CardVariant.elevated:
      case CardVariant.standard:
      case CardVariant.compact:
        return _buildElevatedCard(
          theme,
          backgroundColor,
          borderRadius,
          shadowColor,
          elevation,
        );
    }
  }

  Widget _buildElevatedCard(
    ThemeData theme,
    Color backgroundColor,
    double borderRadius,
    Color shadowColor,
    double elevation,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: _getStatusAdjustedColor(backgroundColor),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.1),
            blurRadius: elevation,
            offset: Offset(0, elevation / 2),
          ),
          BoxShadow(
            color: shadowColor.withOpacity(0.05),
            blurRadius: elevation * 2,
            offset: Offset(0, elevation),
          ),
        ],
      ),
      child: _buildInnerContent(theme, borderRadius),
    );
  }

  Widget _buildOutlinedCard(
    ThemeData theme,
    Color backgroundColor,
    Color borderColor,
    double borderRadius,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: _getStatusAdjustedColor(backgroundColor),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: _getStatusAdjustedColor(borderColor),
          width: 1.5,
        ),
      ),
      child: _buildInnerContent(theme, borderRadius),
    );
  }

  Widget _buildFilledCard(
    ThemeData theme,
    Color backgroundColor,
    double borderRadius,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: _getStatusAdjustedColor(backgroundColor),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: _buildInnerContent(theme, borderRadius),
    );
  }

  Widget _buildGradientCard(
    ThemeData theme,
    List<Color> gradientColors,
    double borderRadius,
    Color shadowColor,
    double elevation,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getStatusAdjustedGradient(gradientColors),
          begin: gradientBegin,
          end: gradientEnd,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.2),
            blurRadius: elevation,
            offset: Offset(0, elevation / 2),
          ),
        ],
      ),
      child: _buildInnerContent(
        theme,
        borderRadius,
        contentColor: Colors.white,
      ),
    );
  }

  Widget _buildInnerContent(
    ThemeData theme,
    double borderRadius, {
    Color? contentColor,
  }) {
    final effectivePadding = padding ?? _getDefaultPadding();
    final effectiveContentColor = contentColor ?? 
        (variant == CardVariant.gradient ? Colors.white : null);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      clipBehavior: clipBehavior,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header != null)
            _buildHeader(theme, effectiveContentColor),
          Padding(
            padding: effectivePadding,
            child: isLoading
                ? _buildLoadingState(theme)
                : _buildChild(theme, effectiveContentColor),
          ),
          if (footer != null)
            _buildFooter(theme, effectiveContentColor),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, Color? contentColor) {
    final effectiveColor = contentColor ?? theme.colorScheme.onSurface;
    return Container(
      padding: EdgeInsets.only(
        left: padding?.horizontal / 2 ?? 16,
        right: padding?.horizontal / 2 ?? 16,
        top: padding?.vertical / 2 ?? 12,
        bottom: padding?.vertical / 4 ?? 6,
      ),
      decoration: BoxDecoration(
        border: variant == CardVariant.outlined
            ? Border(
                bottom: BorderSide(
                  color: theme.dividerColor.withOpacity(0.5),
                  width: 1,
                ),
              )
            : null,
      ),
      child: DefaultTextStyle(
        style: theme.textTheme.titleMedium!.copyWith(
          color: effectiveColor,
          fontWeight: FontWeight.w600,
        ),
        child: header!,
      ),
    );
  }

  Widget _buildFooter(ThemeData theme, Color? contentColor) {
    final effectiveColor = contentColor ?? theme.colorScheme.onSurface;
    return Container(
      padding: EdgeInsets.only(
        left: padding?.horizontal / 2 ?? 16,
        right: padding?.horizontal / 2 ?? 16,
        top: padding?.vertical / 4 ?? 6,
        bottom: padding?.vertical / 2 ?? 12,
      ),
      decoration: BoxDecoration(
        border: variant == CardVariant.outlined
            ? Border(
                top: BorderSide(
                  color: theme.dividerColor.withOpacity(0.5),
                  width: 1,
                ),
              )
            : null,
      ),
      child: DefaultTextStyle(
        style: theme.textTheme.bodySmall!.copyWith(
          color: effectiveColor.withOpacity(0.7),
        ),
        child: footer!,
      ),
    );
  }

  Widget _buildChild(ThemeData theme, Color? contentColor) {
    if (contentColor != null) {
      return DefaultTextStyle(
        style: theme.textTheme.bodyMedium!.copyWith(
          color: contentColor,
        ),
        child: child,
      );
    }
    return child;
  }

  Widget _buildLoadingState(ThemeData theme) {
    if (loadingIndicator != null) {
      return Center(child: loadingIndicator);
    }
    return SizedBox(
      height: 60,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(ThemeData theme, bool isDark) {
    switch (variant) {
      case CardVariant.filled:
        return isDark
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.surfaceContainerLow;
      case CardVariant.compact:
        return isDark
            ? theme.colorScheme.surface
            : Colors.white;
      default:
        return isDark
            ? theme.colorScheme.surface
            : Colors.white;
    }
  }

  Color _getBorderColor(ThemeData theme, bool isDark) {
    switch (status) {
      case CardStatus.success:
        return theme.colorScheme.tertiary;
      case CardStatus.warning:
        return theme.colorScheme.error;
      case CardStatus.error:
        return theme.colorScheme.error;
      default:
        return isDark
            ? theme.colorScheme.outline.withOpacity(0.3)
            : theme.colorScheme.outline.withOpacity(0.2);
    }
  }

  List<Color> _getGradientColors(ThemeData theme, bool isDark) {
    switch (status) {
      case CardStatus.success:
        return [
          theme.colorScheme.primary,
          theme.colorScheme.tertiary,
        ];
      case CardStatus.warning:
        return [
          theme.colorScheme.tertiary,
          Colors.orange,
        ];
      case CardStatus.error:
        return [
          theme.colorScheme.error,
          theme.colorScheme.tertiary,
        ];
      default:
        return [
          theme.colorScheme.primary,
          theme.colorScheme.secondary,
        ];
    }
  }

  double _getDefaultBorderRadius() {
    switch (variant) {
      case CardVariant.compact:
        return 8.0;
      case CardVariant.filled:
        return 12.0;
      default:
        return 16.0;
    }
  }

  double _getDefaultElevation() {
    switch (variant) {
      case CardVariant.compact:
        return 0.0;
      case CardVariant.elevated:
        return 8.0;
      case CardVariant.standard:
        return 4.0;
      default:
        return 0.0;
    }
  }

  EdgeInsetsGeometry _getDefaultPadding() {
    switch (variant) {
      case CardVariant.compact:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case CardVariant.filled:
        return const EdgeInsets.all(16);
      default:
        return const EdgeInsets.all(16);
    }
  }

  Color _getStatusAdjustedColor(Color color) {
    switch (status) {
      case CardStatus.disabled:
        return color.withOpacity(0.5);
      case CardStatus.success:
        return color.withOpacity(0.9);
      case CardStatus.warning:
        return color.withOpacity(0.9);
      case CardStatus.error:
        return color.withOpacity(0.9);
      default:
        return color;
    }
  }

  List<Color> _getStatusAdjustedGradient(List<Color> colors) {
    if (status == CardStatus.disabled) {
      return colors.map((c) => c.withOpacity(0.5)).toList();
    }
    return colors;
  }
}

/// A transaction card specifically designed for displaying
/// financial transaction items with consistent styling.
class TransactionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final bool isPositive;
  final IconData? icon;
  final Color? iconColor;
  final DateTime? date;
  final VoidCallback? onTap;

  const TransactionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    this.isPositive = true,
    this.icon,
    this.iconColor,
    this.date,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amountColor = isPositive
        ? theme.colorScheme.tertiary
        : theme.colorScheme.error;

    return CustomCard(
      variant: CardVariant.compact,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (iconColor ?? theme.colorScheme.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor ?? theme.colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (date != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(date!),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '${isPositive ? '+' : '-'}$amount',
            style: theme.textTheme.titleMedium?.copyWith(
              color: amountColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// A summary card designed for displaying account or portfolio summaries.
class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final double? changePercent;
  final bool isPositiveChange;
  final VoidCallback? onTap;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.changePercent,
    this.isPositiveChange = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomCard(
      variant: CardVariant.elevated,
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 40,
                  height: 40,
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
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null || changePercent != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                if (subtitle != null) ...[
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  if (changePercent != null)
                    const SizedBox(width: 8),
                ],
                if (changePercent != null)
                  _buildChangeIndicator(theme),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChangeIndicator(ThemeData theme) {
    final changeColor = isPositiveChange
        ? theme.colorScheme.tertiary
        : theme.colorScheme.error;
    final changeIcon = isPositiveChange
        ? Icons.trending_up
        : Icons.trending_down;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: changeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            changeIcon,
            size: 12,
            color: changeColor,
          ),
          const SizedBox(width: 2),
          Text(
            '${isPositiveChange ? '+' : ''}${changePercent!.toStringAsFixed(2)}%',
            style: theme.textTheme.labelSmall?.copyWith(
              color: changeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// A chart card wrapper for displaying charts within cards.
class ChartCard extends StatelessWidget {
  final String title;
  final Widget chart;
  final String? subtitle;
  final Widget? legend;
  final EdgeInsetsGeometry? chartPadding;

  const ChartCard({
    super.key,
    required this.title,
    required this.chart,
    this.subtitle,
    this.legend,
    this.chartPadding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomCard(
      variant: CardVariant.filled,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: chartPadding ?? const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: chart,
          ),
          if (legend != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: legend!,
            ),
        ],
      ),
    );
  }
}
