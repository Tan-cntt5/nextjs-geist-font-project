import 'package:flutter/material.dart';
import 'package:eventease/theme/app_theme.dart';
import 'package:eventease/utils/animations.dart';

class CustomTooltip extends StatefulWidget {
  final Widget child;
  final String message;
  final TooltipPosition position;
  final Color? backgroundColor;
  final Color? textColor;
  final double maxWidth;
  final EdgeInsets padding;
  final Duration showDuration;
  final Duration animationDuration;
  final bool preferBelow;
  final bool animated;
  final TooltipStyle style;
  final VoidCallback? onTap;
  final bool showArrow;
  final double arrowWidth;
  final double arrowHeight;
  final double borderRadius;
  final bool enabled;

  const CustomTooltip({
    super.key,
    required this.child,
    required this.message,
    this.position = TooltipPosition.top,
    this.backgroundColor,
    this.textColor,
    this.maxWidth = 200,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 8,
    ),
    this.showDuration = const Duration(seconds: 2),
    this.animationDuration = const Duration(milliseconds: 200),
    this.preferBelow = false,
    this.animated = true,
    this.style = TooltipStyle.standard,
    this.onTap,
    this.showArrow = true,
    this.arrowWidth = 12,
    this.arrowHeight = 6,
    this.borderRadius = 6,
    this.enabled = true,
  });

  @override
  State<CustomTooltip> createState() => _CustomTooltipState();
}

class _CustomTooltipState extends State<CustomTooltip>
    with SingleTickerProviderStateMixin {
  late OverlayEntry _overlayEntry;
  bool _isVisible = false;
  final LayerLink _layerLink = LayerLink();

  @override
  void dispose() {
    if (_isVisible) {
      _overlayEntry.remove();
    }
    super.dispose();
  }

  void _showTooltip() {
    if (!widget.enabled) return;

    setState(() {
      _isVisible = true;
    });

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry);

    if (widget.showDuration != Duration.zero) {
      Future.delayed(widget.showDuration, _hideTooltip);
    }
  }

  void _hideTooltip() {
    if (!mounted || !_isVisible) return;

    setState(() {
      _isVisible = false;
    });

    _overlayEntry.remove();
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) {
        return _TooltipOverlay(
          link: _layerLink,
          message: widget.message,
          position: widget.position,
          backgroundColor: widget.backgroundColor,
          textColor: widget.textColor,
          maxWidth: widget.maxWidth,
          padding: widget.padding,
          animationDuration: widget.animationDuration,
          preferBelow: widget.preferBelow,
          animated: widget.animated,
          style: widget.style,
          showArrow: widget.showArrow,
          arrowWidth: widget.arrowWidth,
          arrowHeight: widget.arrowHeight,
          borderRadius: widget.borderRadius,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTapDown: widget.onTap != null ? (_) => widget.onTap!() : null,
        onLongPress: _showTooltip,
        onLongPressEnd: (_) => _hideTooltip(),
        child: widget.child,
      ),
    );
  }
}

class _TooltipOverlay extends StatelessWidget {
  final LayerLink link;
  final String message;
  final TooltipPosition position;
  final Color? backgroundColor;
  final Color? textColor;
  final double maxWidth;
  final EdgeInsets padding;
  final Duration animationDuration;
  final bool preferBelow;
  final bool animated;
  final TooltipStyle style;
  final bool showArrow;
  final double arrowWidth;
  final double arrowHeight;
  final double borderRadius;

  const _TooltipOverlay({
    required this.link,
    required this.message,
    required this.position,
    this.backgroundColor,
    this.textColor,
    required this.maxWidth,
    required this.padding,
    required this.animationDuration,
    required this.preferBelow,
    required this.animated,
    required this.style,
    required this.showArrow,
    required this.arrowWidth,
    required this.arrowHeight,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return CompositedTransformFollower(
      link: link,
      offset: _getOffset(),
      targetAnchor: _getTargetAnchor(),
      followerAnchor: _getFollowerAnchor(),
      child: Material(
        color: Colors.transparent,
        child: _buildTooltip(),
      ),
    );
  }

  Widget _buildTooltip() {
    Widget tooltip = Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      decoration: _getDecoration(),
      padding: padding,
      child: Text(
        message,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );

    if (showArrow) {
      tooltip = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (position == TooltipPosition.bottom) _buildArrow(),
          tooltip,
          if (position == TooltipPosition.top) _buildArrow(isUp: true),
        ],
      );
    }

    if (animated) {
      tooltip = AnimatedWidget(
        fadeIn: true,
        scale: true,
        slideOffset: _getSlideOffset(),
        child: tooltip,
      );
    }

    return tooltip;
  }

  Widget _buildArrow({bool isUp = false}) {
    return Transform.rotate(
      angle: isUp ? 3.14159 : 0,
      child: CustomPaint(
        size: Size(arrowWidth, arrowHeight),
        painter: _ArrowPainter(
          color: backgroundColor ?? AppTheme.primaryColor,
          style: style,
        ),
      ),
    );
  }

  BoxDecoration _getDecoration() {
    final color = backgroundColor ?? AppTheme.primaryColor;

    switch (style) {
      case TooltipStyle.standard:
        return BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(borderRadius),
        );
      case TooltipStyle.outlined:
        return BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: color,
            width: 1,
          ),
        );
      case TooltipStyle.glass:
        return BoxDecoration(
          color: color.withOpacity(0.9),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        );
    }
  }

  Offset _getOffset() {
    switch (position) {
      case TooltipPosition.top:
        return const Offset(0, -8);
      case TooltipPosition.bottom:
        return const Offset(0, 8);
      case TooltipPosition.left:
        return const Offset(-8, 0);
      case TooltipPosition.right:
        return const Offset(8, 0);
    }
  }

  Alignment _getTargetAnchor() {
    switch (position) {
      case TooltipPosition.top:
        return Alignment.topCenter;
      case TooltipPosition.bottom:
        return Alignment.bottomCenter;
      case TooltipPosition.left:
        return Alignment.centerLeft;
      case TooltipPosition.right:
        return Alignment.centerRight;
    }
  }

  Alignment _getFollowerAnchor() {
    switch (position) {
      case TooltipPosition.top:
        return Alignment.bottomCenter;
      case TooltipPosition.bottom:
        return Alignment.topCenter;
      case TooltipPosition.left:
        return Alignment.centerRight;
      case TooltipPosition.right:
        return Alignment.centerLeft;
    }
  }

  Offset _getSlideOffset() {
    switch (position) {
      case TooltipPosition.top:
        return const Offset(0, 0.5);
      case TooltipPosition.bottom:
        return const Offset(0, -0.5);
      case TooltipPosition.left:
        return const Offset(0.5, 0);
      case TooltipPosition.right:
        return const Offset(-0.5, 0);
    }
  }
}

class _ArrowPainter extends CustomPainter {
  final Color color;
  final TooltipStyle style;

  const _ArrowPainter({
    required this.color,
    required this.style,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = style == TooltipStyle.outlined
          ? color.withOpacity(0.1)
          : color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);

    if (style == TooltipStyle.outlined) {
      final borderPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum TooltipPosition {
  top,
  bottom,
  left,
  right,
}

enum TooltipStyle {
  standard,
  outlined,
  glass,
}

// Rich Tooltip
class RichTooltip extends StatelessWidget {
  final Widget child;
  final String title;
  final String message;
  final Widget? icon;
  final List<Widget>? actions;
  final TooltipPosition position;
  final Color? backgroundColor;
  final bool showArrow;
  final bool animated;

  const RichTooltip({
    super.key,
    required this.child,
    required this.title,
    required this.message,
    this.icon,
    this.actions,
    this.position = TooltipPosition.top,
    this.backgroundColor,
    this.showArrow = true,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTooltip(
      message: '',
      position: position,
      backgroundColor: backgroundColor,
      showArrow: showArrow,
      animated: animated,
      maxWidth: 300,
      child: child,
      padding: EdgeInsets.zero,
      style: TooltipStyle.glass,
      showDuration: Duration.zero,
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor ?? Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(height: 16),
                  ],
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (actions != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: actions!,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
