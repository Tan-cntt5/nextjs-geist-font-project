import 'package:flutter/material.dart';
import 'package:eventease/theme/app_theme.dart';
import 'package:eventease/utils/animations.dart';

class CustomProgressIndicator extends StatelessWidget {
  final double? value;
  final Color? color;
  final double size;
  final double strokeWidth;
  final String? label;
  final bool showLabel;
  final ProgressStyle style;
  final bool animated;
  final Duration animationDuration;
  final Curve animationCurve;

  const CustomProgressIndicator({
    super.key,
    this.value,
    this.color,
    this.size = 40,
    this.strokeWidth = 4,
    this.label,
    this.showLabel = false,
    this.style = ProgressStyle.circular,
    this.animated = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    Widget indicator;

    switch (style) {
      case ProgressStyle.circular:
        indicator = _buildCircularIndicator();
        break;
      case ProgressStyle.linear:
        indicator = _buildLinearIndicator();
        break;
      case ProgressStyle.dots:
        indicator = _buildDotsIndicator();
        break;
      case ProgressStyle.pulse:
        indicator = _buildPulseIndicator();
        break;
    }

    if (showLabel && label != null) {
      indicator = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator,
          const SizedBox(height: 8),
          Text(
            label!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      );
    }

    if (animated) {
      indicator = AnimatedWidget(
        fadeIn: true,
        scale: true,
        child: indicator,
      );
    }

    return indicator;
  }

  Widget _buildCircularIndicator() {
    return SizedBox(
      width: size,
      height: size,
      child: value != null
          ? TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: value!),
              duration: animationDuration,
              curve: animationCurve,
              builder: (context, value, _) {
                return CircularProgressIndicator(
                  value: value,
                  strokeWidth: strokeWidth,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    color ?? AppTheme.primaryColor,
                  ),
                );
              },
            )
          : CircularProgressIndicator(
              strokeWidth: strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppTheme.primaryColor,
              ),
            ),
    );
  }

  Widget _buildLinearIndicator() {
    return value != null
        ? TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: value!),
            duration: animationDuration,
            curve: animationCurve,
            builder: (context, value, _) {
              return LinearProgressIndicator(
                value: value,
                valueColor: AlwaysStoppedAnimation<Color>(
                  color ?? AppTheme.primaryColor,
                ),
                backgroundColor: (color ?? AppTheme.primaryColor).withOpacity(0.2),
                minHeight: strokeWidth,
              );
            },
          )
        : LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? AppTheme.primaryColor,
            ),
            backgroundColor: (color ?? AppTheme.primaryColor).withOpacity(0.2),
            minHeight: strokeWidth,
          );
  }

  Widget _buildDotsIndicator() {
    return SizedBox(
      width: size,
      height: size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          3,
          (index) => _buildDot(index),
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color ?? AppTheme.primaryColor,
          shape: BoxShape.circle,
        ),
        child: const SizedBox(width: 8, height: 8),
      ),
    );
  }

  Widget _buildPulseIndicator() {
    return SizedBox(
      width: size,
      height: size,
      child: _PulseIndicator(
        color: color ?? AppTheme.primaryColor,
        size: size,
      ),
    );
  }
}

class _PulseIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const _PulseIndicator({
    required this.color,
    required this.size,
  });

  @override
  State<_PulseIndicator> createState() => _PulseIndicatorState();
}

class _PulseIndicatorState extends State<_PulseIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: _animation.value,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withOpacity(0.3),
                ),
              ),
            ),
            Container(
              width: widget.size * 0.5,
              height: widget.size * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
              ),
            ),
          ],
        );
      },
    );
  }
}

enum ProgressStyle {
  circular,
  linear,
  dots,
  pulse,
}

// Progress Bar
class CustomProgressBar extends StatelessWidget {
  final double value;
  final double maxValue;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double height;
  final bool showLabel;
  final String? label;
  final bool showPercentage;
  final bool animated;
  final Duration animationDuration;
  final Curve animationCurve;
  final double borderRadius;

  const CustomProgressBar({
    super.key,
    required this.value,
    this.maxValue = 100,
    this.backgroundColor,
    this.foregroundColor,
    this.height = 8,
    this.showLabel = false,
    this.label,
    this.showPercentage = false,
    this.animated = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel && (label != null || showPercentage)) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (label != null)
                Text(
                  label!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              if (showPercentage)
                Text(
                  '${((value / maxValue) * 100).round()}%',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Container(
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.grey[200],
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: value / maxValue),
            duration: animationDuration,
            curve: animationCurve,
            builder: (context, value, _) {
              return FractionallySizedBox(
                widthFactor: value.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: foregroundColor ?? AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
