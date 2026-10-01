import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';

/// A delightfully bouncy animated checkbox with spring pop effect, checkmark drawing,
/// and tactile haptic feedback.
class BouncyCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? checkColor;
  final double size;
  final bool isCircle;
  final double borderRadius;
  final String? semanticLabel;

  const BouncyCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.checkColor = Colors.white,
    this.size = 28,
    this.isCircle = true,
    this.borderRadius = 8,
    this.semanticLabel,
  });

  @override
  State<BouncyCheckbox> createState() => _BouncyCheckboxState();
}

class _BouncyCheckboxState extends State<BouncyCheckbox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Spring pop: 1.0 -> 0.85 -> 1.15 -> 1.0
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.85,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.85,
          end: 1.15,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.15,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant BouncyCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onChanged == null) return;
    HapticFeedback.lightImpact();
    _controller.forward(from: 0.0);
    widget.onChanged!(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = widget.activeColor ?? AppColors.primary;

    final borderDecoration = BoxDecoration(
      color: widget.value ? color : Colors.transparent,
      shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: widget.isCircle
          ? null
          : BorderRadius.circular(widget.borderRadius),
      border: Border.all(
        color: widget.value
            ? color
            : (isDark ? AppColors.darkTextSecondary : AppColors.textDisabled),
        width: 2,
      ),
    );

    return Semantics(
      label: widget.semanticLabel,
      checked: widget.value,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onChanged != null ? _handleTap : null,
        child: SizedBox(
          width: widget.size + 16,
          height: widget.size + 16,
          child: Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                width: widget.size,
                height: widget.size,
                decoration: borderDecoration,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: widget.value
                      ? Icon(
                          Icons.check_rounded,
                          key: const ValueKey('checked_icon'),
                          size: widget.size * 0.65,
                          color: widget.checkColor,
                        )
                      : const SizedBox.shrink(key: ValueKey('unchecked_empty')),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
