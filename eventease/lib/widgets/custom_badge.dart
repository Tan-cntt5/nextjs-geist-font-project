import 'package:flutter/material.dart';
import 'package:eventease/theme/app_theme.dart';
import 'package:eventease/utils/animations.dart';

class CustomBadge extends StatelessWidget {
  final Widget? child;
  final String? label;
  final BadgePosition position;
  final Color? backgroundColor;
  final Color? textColor;
  final double size;
  final bool showZero;
  final bool animated;
  final BadgeStyle style;
  final EdgeInsets padding;
  final double borderRadius;
  final bool visible;
  final VoidCallback? onTap;

  const CustomBadge({
    super.key,
    this.child,
    this.label,
    this.position = const BadgePosition(),
    this.backgroundColor,
    this.textColor,
    this.size = 20,
    this.showZero = false,
    this.animated = true,
    this.style = BadgeStyle.standard,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    this.borderRadius = 12,
    this.visible = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return child ?? const SizedBox.shrink();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child ?? const SizedBox.shrink(),
        if (visible) _buildBadge(),
      ],
    );
  }

  Widget _buildBadge() {
    Widget badge = Container(
      constraints: BoxConstraints(
        minWidth: size,
        minHeight: size,
      ),
      padding: label != null ? padding : EdgeInsets.zero,
      decoration: _getDecoration(),
      child: Center(
        child: _buildContent(),
      ),
    );

    if (animated) {
      badge = AnimatedWidget(
        fadeIn: true,
        scale: true,
        child: badge,
      );
    }

    if (onTap != null) {
      badge = GestureDetector(
        onTap: onTap,
        child: badge,
      );
    }

    return Positioned(
      top: position.top,
      right: position.right,
      bottom: position.bottom,
      left: position.left,
      child: badge,
    );
  }

  Widget? _buildContent() {
    if (label == null) return null;

    // If the label is a number
    if (int.tryParse(label!) != null) {
      final count = int.parse(label!);
      if (count == 0 && !showZero) return null;
    }

    return Text(
      label!,
      style: TextStyle(
        color: textColor ?? Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  BoxDecoration _getDecoration() {
    final color = backgroundColor ?? AppTheme.primaryColor;

    switch (style) {
      case BadgeStyle.standard:
        return BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(borderRadius),
        );
      case BadgeStyle.dot:
        return BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        );
      case BadgeStyle.outlined:
        return BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: color,
            width: 1.5,
          ),
        );
    }
  }

  // Factory constructors for common use cases
  factory CustomBadge.count({
    required Widget child,
    required int count,
    bool showZero = false,
    Color? backgroundColor,
    Color? textColor,
    BadgePosition position = const BadgePosition(),
    bool animated = true,
  }) {
    return CustomBadge(
      child: child,
      label: count.toString(),
      backgroundColor: backgroundColor,
      textColor: textColor,
      position: position,
      showZero: showZero,
      animated: animated,
      visible: count > 0 || showZero,
    );
  }

  factory CustomBadge.dot({
    required Widget child,
    Color? color,
    BadgePosition position = const BadgePosition(top: -4, right: -4),
    bool animated = true,
  }) {
    return CustomBadge(
      child: child,
      backgroundColor: color,
      position: position,
      size: 8,
      style: BadgeStyle.dot,
      animated: animated,
    );
  }

  factory CustomBadge.status({
    required Widget child,
    required bool active,
    Color? activeColor,
    Color? inactiveColor,
    BadgePosition position = const BadgePosition(bottom: 0, right: 0),
    bool animated = true,
  }) {
    return CustomBadge(
      child: child,
      backgroundColor: active
          ? (activeColor ?? Colors.green)
          : (inactiveColor ?? Colors.grey),
      position: position,
      size: 12,
      style: BadgeStyle.dot,
      animated: animated,
    );
  }
}

class BadgePosition {
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;

  const BadgePosition({
    this.top = -8,
    this.right = -8,
    this.bottom,
    this.left,
  });

  factory BadgePosition.topStart({
    double top = -8,
    double left = -8,
  }) {
    return BadgePosition(
      top: top,
      left: left,
    );
  }

  factory BadgePosition.topEnd({
    double top = -8,
    double right = -8,
  }) {
    return BadgePosition(
      top: top,
      right: right,
    );
  }

  factory BadgePosition.bottomStart({
    double bottom = -8,
    double left = -8,
  }) {
    return BadgePosition(
      bottom: bottom,
      left: left,
    );
  }

  factory BadgePosition.bottomEnd({
    double bottom = -8,
    double right = -8,
  }) {
    return BadgePosition(
      bottom: bottom,
      right: right,
    );
  }

  factory BadgePosition.center() {
    return const BadgePosition(
      top: 0,
      right: 0,
      bottom: 0,
      left: 0,
    );
  }
}

enum BadgeStyle {
  standard,
  dot,
  outlined,
}

// Notification Badge
class NotificationBadge extends StatelessWidget {
  final Widget child;
  final int count;
  final Color? color;
  final bool showZero;
  final VoidCallback? onTap;
  final bool animated;

  const NotificationBadge({
    super.key,
    required this.child,
    required this.count,
    this.color,
    this.showZero = false,
    this.onTap,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomBadge.count(
      child: child,
      count: count,
      backgroundColor: color ?? AppTheme.errorColor,
      showZero: showZero,
      animated: animated,
      position: const BadgePosition(top: 0, right: 0),
    );
  }
}

// Status Badge
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool outlined;
  final VoidCallback? onTap;
  final bool animated;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.outlined = false,
    this.onTap,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomBadge(
      label: label,
      backgroundColor: color,
      textColor: outlined ? color : Colors.white,
      style: outlined ? BadgeStyle.outlined : BadgeStyle.standard,
      onTap: onTap,
      animated: animated,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  // Factory constructors for common statuses
  factory StatusBadge.success({
    String label = 'Success',
    bool outlined = false,
    VoidCallback? onTap,
    bool animated = true,
  }) {
    return StatusBadge(
      label: label,
      color: Colors.green,
      outlined: outlined,
      onTap: onTap,
      animated: animated,
    );
  }

  factory StatusBadge.error({
    String label = 'Error',
    bool outlined = false,
    VoidCallback? onTap,
    bool animated = true,
  }) {
    return StatusBadge(
      label: label,
      color: Colors.red,
      outlined: outlined,
      onTap: onTap,
      animated: animated,
    );
  }

  factory StatusBadge.warning({
    String label = 'Warning',
    bool outlined = false,
    VoidCallback? onTap,
    bool animated = true,
  }) {
    return StatusBadge(
      label: label,
      color: Colors.orange,
      outlined: outlined,
      onTap: onTap,
      animated: animated,
    );
  }

  factory StatusBadge.info({
    String label = 'Info',
    bool outlined = false,
    VoidCallback? onTap,
    bool animated = true,
  }) {
    return StatusBadge(
      label: label,
      color: Colors.blue,
      outlined: outlined,
      onTap: onTap,
      animated: animated,
    );
  }
}
