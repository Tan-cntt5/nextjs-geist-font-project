import 'package:flutter/material.dart';
import 'package:eventease/theme/app_theme.dart';
import 'package:eventease/utils/animations.dart';

class CustomExpansionPanel extends StatefulWidget {
  final String title;
  final Widget content;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onExpansionChanged;
  final bool canTapHeader;
  final EdgeInsets? padding;
  final EdgeInsets? contentPadding;
  final Color? backgroundColor;
  final Color? headerColor;
  final TextStyle? headerStyle;
  final IconData? expandIcon;
  final IconData? collapseIcon;
  final bool animated;
  final ExpansionStyle style;
  final Widget? leading;
  final Widget? trailing;
  final bool showDivider;
  final double borderRadius;

  const CustomExpansionPanel({
    super.key,
    required this.title,
    required this.content,
    this.initiallyExpanded = false,
    this.onExpansionChanged,
    this.canTapHeader = true,
    this.padding,
    this.contentPadding,
    this.backgroundColor,
    this.headerColor,
    this.headerStyle,
    this.expandIcon,
    this.collapseIcon,
    this.animated = true,
    this.style = ExpansionStyle.standard,
    this.leading,
    this.trailing,
    this.showDivider = true,
    this.borderRadius = 12,
  });

  @override
  State<CustomExpansionPanel> createState() => _CustomExpansionPanelState();
}

class _CustomExpansionPanelState extends State<CustomExpansionPanel>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _iconTurns;
  late Animation<double> _heightFactor;
  late Animation<double> _headerOpacity;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _iconTurns = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    _heightFactor = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    _headerOpacity = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.canTapHeader) return;
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      widget.onExpansionChanged?.call(_isExpanded);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool closed = !_isExpanded && _controller.isDismissed;

    Widget result = Container(
      decoration: _getDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(closed),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  heightFactor: _heightFactor.value,
                  child: child,
                ),
              );
            },
            child: closed ? null : _buildContent(),
          ),
        ],
      ),
    );

    if (widget.animated) {
      result = AnimatedWidget(
        fadeIn: true,
        scale: true,
        child: result,
      );
    }

    return result;
  }

  Widget _buildHeader(bool closed) {
    return InkWell(
      onTap: _handleTap,
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(widget.borderRadius),
        bottom: Radius.circular(closed ? widget.borderRadius : 0),
      ),
      child: Padding(
        padding: widget.padding ?? const EdgeInsets.all(16),
        child: Row(
          children: [
            if (widget.leading != null) ...[
              widget.leading!,
              const SizedBox(width: 16),
            ],
            Expanded(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _headerOpacity.value,
                    child: Text(
                      widget.title,
                      style: widget.headerStyle ??
                          TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: widget.headerColor ?? Colors.black87,
                          ),
                    ),
                  );
                },
              ),
            ),
            if (widget.trailing != null) ...[
              const SizedBox(width: 16),
              widget.trailing!,
            ],
            const SizedBox(width: 8),
            RotationTransition(
              turns: _iconTurns,
              child: Icon(
                _isExpanded
                    ? (widget.collapseIcon ?? Icons.keyboard_arrow_up_rounded)
                    : (widget.expandIcon ?? Icons.keyboard_arrow_down_rounded),
                color: widget.headerColor ?? Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        if (widget.showDivider)
          const Divider(height: 1),
        Padding(
          padding: widget.contentPadding ?? const EdgeInsets.all(16),
          child: widget.content,
        ),
      ],
    );
  }

  BoxDecoration _getDecoration() {
    switch (widget.style) {
      case ExpansionStyle.standard:
        return BoxDecoration(
          color: widget.backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        );
      case ExpansionStyle.outlined:
        return BoxDecoration(
          color: widget.backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 1.5,
          ),
        );
      case ExpansionStyle.filled:
        return BoxDecoration(
          color: widget.backgroundColor ?? Colors.grey[50],
          borderRadius: BorderRadius.circular(widget.borderRadius),
        );
      case ExpansionStyle.elevated:
        return BoxDecoration(
          color: widget.backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        );
    }
  }
}

enum ExpansionStyle {
  standard,
  outlined,
  filled,
  elevated,
}

// Expansion Panel List
class CustomExpansionPanelList extends StatefulWidget {
  final List<ExpansionPanelItem> items;
  final bool allowMultiple;
  final ExpansionStyle style;
  final bool animated;
  final double spacing;
  final bool showDivider;
  final double borderRadius;

  const CustomExpansionPanelList({
    super.key,
    required this.items,
    this.allowMultiple = false,
    this.style = ExpansionStyle.standard,
    this.animated = true,
    this.spacing = 8,
    this.showDivider = true,
    this.borderRadius = 12,
  });

  @override
  State<CustomExpansionPanelList> createState() =>
      _CustomExpansionPanelListState();
}

class _CustomExpansionPanelListState extends State<CustomExpansionPanelList> {
  final Set<int> _expandedItems = {};

  void _handleExpansion(int index, bool isExpanded) {
    setState(() {
      if (isExpanded) {
        if (!widget.allowMultiple) {
          _expandedItems.clear();
        }
        _expandedItems.add(index);
      } else {
        _expandedItems.remove(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        widget.items.length * 2 - 1,
        (index) {
          if (index.isOdd) {
            return SizedBox(height: widget.spacing);
          }
          final itemIndex = index ~/ 2;
          final item = widget.items[itemIndex];
          return CustomExpansionPanel(
            title: item.title,
            content: item.content,
            initiallyExpanded: _expandedItems.contains(itemIndex),
            onExpansionChanged: (isExpanded) =>
                _handleExpansion(itemIndex, isExpanded),
            style: widget.style,
            animated: widget.animated,
            leading: item.leading,
            trailing: item.trailing,
            showDivider: widget.showDivider,
            borderRadius: widget.borderRadius,
          );
        },
      ),
    );
  }
}

class ExpansionPanelItem {
  final String title;
  final Widget content;
  final Widget? leading;
  final Widget? trailing;

  const ExpansionPanelItem({
    required this.title,
    required this.content,
    this.leading,
    this.trailing,
  });
}
