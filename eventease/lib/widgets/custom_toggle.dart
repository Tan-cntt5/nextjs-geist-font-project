import 'package:flutter/material.dart';
import 'package:eventease/theme/app_theme.dart';
import 'package:eventease/utils/animations.dart';

class CustomToggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? thumbColor;
  final double width;
  final double height;
  final bool enabled;
  final bool animated;
  final ToggleStyle style;
  final String? label;
  final IconData? activeIcon;
  final IconData? inactiveIcon;
  final Duration animationDuration;

  const CustomToggle({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
    this.width = 48,
    this.height = 24,
    this.enabled = true,
    this.animated = true,
    this.style = ToggleStyle.standard,
    this.label,
    this.activeIcon,
    this.inactiveIcon,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  State<CustomToggle> createState() => _CustomToggleState();
}

class _CustomToggleState extends State<CustomToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    if (widget.value) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CustomToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  void _handleTap() {
    if (!widget.enabled) return;
    widget.onChanged?.call(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    Widget toggle = GestureDetector(
      onTap: _handleTap,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: _getTrackDecoration(),
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Positioned(
                  left: _getThumbPosition(),
                  top: (widget.height - _getThumbSize()) / 2,
                  child: _buildThumb(),
                );
              },
            ),
            if (widget.style == ToggleStyle.icon)
              _buildIcons(),
          ],
        ),
      ),
    );

    if (widget.animated) {
      toggle = AnimatedWidget(
        fadeIn: true,
        scale: true,
        child: toggle,
      );
    }

    if (widget.label != null) {
      toggle = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          toggle,
          const SizedBox(width: 8),
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 14,
              color: widget.enabled ? Colors.black87 : Colors.grey,
            ),
          ),
        ],
      );
    }

    return toggle;
  }

  BoxDecoration _getTrackDecoration() {
    final activeColor = widget.activeColor ?? AppTheme.primaryColor;
    final inactiveColor = widget.inactiveColor ?? Colors.grey[300];

    switch (widget.style) {
      case ToggleStyle.standard:
      case ToggleStyle.icon:
        return BoxDecoration(
          color: widget.enabled
              ? Color.lerp(inactiveColor, activeColor, _controller.value)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(widget.height),
        );
      case ToggleStyle.ios:
        return BoxDecoration(
          color: widget.enabled
              ? Color.lerp(Colors.white, activeColor, _controller.value)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(widget.height),
          border: Border.all(
            color: widget.enabled
                ? Color.lerp(Colors.grey[300]!, activeColor, _controller.value)!
                : Colors.grey[300]!,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        );
      case ToggleStyle.material:
        return BoxDecoration(
          color: widget.enabled
              ? Color.lerp(inactiveColor, activeColor.withOpacity(0.5), _controller.value)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(widget.height),
        );
    }
  }

  Widget _buildThumb() {
    final size = _getThumbSize();
    final activeColor = widget.activeColor ?? AppTheme.primaryColor;
    final thumbColor = widget.thumbColor ?? Colors.white;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: widget.style == ToggleStyle.ios
            ? thumbColor
            : widget.enabled
                ? Color.lerp(thumbColor, activeColor, _controller.value)
                : Colors.grey[400],
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  Widget _buildIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Icon(
          widget.inactiveIcon ?? Icons.close_rounded,
          color: Colors.white,
          size: widget.height * 0.6,
        ),
        Icon(
          widget.activeIcon ?? Icons.check_rounded,
          color: Colors.white,
          size: widget.height * 0.6,
        ),
      ],
    );
  }

  double _getThumbPosition() {
    final trackWidth = widget.width;
    final thumbSize = _getThumbSize();
    final position = _controller.value * (trackWidth - thumbSize);
    return position;
  }

  double _getThumbSize() {
    switch (widget.style) {
      case ToggleStyle.standard:
      case ToggleStyle.icon:
        return widget.height - 4;
      case ToggleStyle.ios:
        return widget.height - 2;
      case ToggleStyle.material:
        return widget.height * 1.2;
    }
  }
}

enum ToggleStyle {
  standard,
  ios,
  material,
  icon,
}

// Toggle Group
class CustomToggleGroup<T> extends StatelessWidget {
  final List<ToggleItem<T>> items;
  final T? selectedValue;
  final ValueChanged<T?>? onChanged;
  final bool enabled;
  final bool animated;
  final ToggleGroupStyle style;
  final Color? activeColor;
  final Color? inactiveColor;
  final double spacing;
  final double height;
  final double borderRadius;

  const CustomToggleGroup({
    super.key,
    required this.items,
    this.selectedValue,
    this.onChanged,
    this.enabled = true,
    this.animated = true,
    this.style = ToggleGroupStyle.filled,
    this.activeColor,
    this.inactiveColor,
    this.spacing = 0,
    this.height = 40,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _getGroupDecoration(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: items.map((item) {
          final isSelected = item.value == selectedValue;
          final index = items.indexOf(item);

          Widget toggle = InkWell(
            onTap: enabled ? () => onChanged?.call(item.value) : null,
            child: Container(
              height: height,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: _getItemDecoration(isSelected, index),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.icon != null) ...[
                      Icon(
                        item.icon,
                        color: _getTextColor(isSelected),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      item.label,
                      style: TextStyle(
                        color: _getTextColor(isSelected),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );

          if (animated) {
            toggle = AnimatedWidget(
              fadeIn: true,
              scale: true,
              child: toggle,
            );
          }

          if (spacing > 0 && index < items.length - 1) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                toggle,
                SizedBox(width: spacing),
              ],
            );
          }

          return toggle;
        }).toList(),
      ),
    );
  }

  BoxDecoration _getGroupDecoration() {
    switch (style) {
      case ToggleGroupStyle.filled:
        return BoxDecoration(
          color: inactiveColor ?? Colors.grey[100],
          borderRadius: BorderRadius.circular(borderRadius),
        );
      case ToggleGroupStyle.outlined:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: inactiveColor ?? Colors.grey[300]!,
            width: 1.5,
          ),
        );
    }
  }

  BoxDecoration? _getItemDecoration(bool isSelected, int index) {
    final color = activeColor ?? AppTheme.primaryColor;

    switch (style) {
      case ToggleGroupStyle.filled:
        return isSelected
            ? BoxDecoration(
                color: enabled ? color : Colors.grey,
                borderRadius: BorderRadius.circular(borderRadius),
              )
            : null;
      case ToggleGroupStyle.outlined:
        return isSelected
            ? BoxDecoration(
                color: enabled ? color : Colors.grey,
                borderRadius: BorderRadius.circular(borderRadius),
              )
            : null;
    }
  }

  Color _getTextColor(bool isSelected) {
    if (!enabled) return Colors.grey;
    return isSelected ? Colors.white : Colors.black87;
  }
}

class ToggleItem<T> {
  final String label;
  final IconData? icon;
  final T value;

  const ToggleItem({
    required this.label,
    this.icon,
    required this.value,
  });
}

enum ToggleGroupStyle {
  filled,
  outlined,
}
