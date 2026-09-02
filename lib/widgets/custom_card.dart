import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? shadowColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool isDark;

  const CustomCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.shadowColor,
    this.borderRadius = 16,
    this.padding,
    this.margin,
    this.onTap,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final darkMode = isDark || brightness == Brightness.dark;

    final defaultBgColor = darkMode
        ? const Color(0xFF1E293B)
        : const Color(0xFFFFFFFF);
    final defaultShadowColor = darkMode
        ? Colors.black.withValues(alpha: 0.2)
        : const Color(0x1A000000);

    final bgColor = backgroundColor ?? defaultBgColor;
    final sdColor = shadowColor ?? defaultShadowColor;
    final brColor = borderColor;

    final cardDecoration = BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: brColor != null
          ? Border.all(color: brColor, width: 1)
          : null,
      boxShadow: [
        BoxShadow(
          color: sdColor,
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );

    if (onTap != null) {
      return Padding(
        padding: margin ?? EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Container(
              padding: padding ?? const EdgeInsets.all(16),
              decoration: cardDecoration,
              child: child,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: cardDecoration,
        child: child,
      ),
    );
  }
}

// Custom Card with Gradient Support
class GradientCard extends StatelessWidget {
  final Widget child;
  final List<Color> gradientColors;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final List<BoxShadow>? boxShadow;

  const GradientCard({
    super.key,
    required this.child,
    required this.gradientColors,
    this.borderRadius = 20,
    this.padding,
    this.margin,
    this.onTap,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradientColors,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: boxShadow ??
          [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
    );

    if (onTap != null) {
      return Padding(
        padding: margin ?? EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Container(
              padding: padding ?? const EdgeInsets.all(24),
              decoration: decoration,
              child: child,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Container(
        padding: padding ?? const EdgeInsets.all(24),
        decoration: decoration,
        child: child,
      ),
    );
  }
}

// Interactive Card with Press Effect
class InteractiveCard extends StatefulWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isDark;

  const InteractiveCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 16,
    this.padding,
    this.margin,
    this.onTap,
    this.onLongPress,
    this.isDark = false,
  });

  @override
  State<InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<InteractiveCard>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final darkMode = widget.isDark || brightness == Brightness.dark;

    final defaultBgColor = darkMode
        ? const Color(0xFF1E293B)
        : const Color(0xFFFFFFFF);
    final defaultShadowColor = darkMode
        ? Colors.black.withValues(alpha: 0.2)
        : const Color(0x1A000000);

    final bgColor = widget.backgroundColor ?? defaultBgColor;
    final sdColor = defaultShadowColor;
    final brColor = widget.borderColor;

    return Padding(
      padding: widget.margin ?? EdgeInsets.zero,
      child: GestureDetector(
        onTapDown: widget.onTap != null ? _onTapDown : null,
        onTapUp: widget.onTap != null ? _onTapUp : null,
        onTapCancel: widget.onTap != null ? _onTapCancel : null,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: Container(
            padding: widget.padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: brColor != null
                  ? Border.all(color: brColor, width: 1)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: sdColor,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
