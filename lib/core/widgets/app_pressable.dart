import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum AppHapticFeedback { none, selection, light, medium, heavy }

/// A lightweight, high-performance touchable widget that provides a subtle
/// spring scale compression on press, accompanied by optional tactile haptic feedback.
class AppPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressedScale;
  final Duration duration;
  final Curve curve;
  final AppHapticFeedback haptic;
  final BorderRadius? borderRadius;
  final HitTestBehavior behavior;

  const AppPressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.96,
    this.duration = const Duration(milliseconds: 100),
    this.curve = Curves.easeOutCubic,
    this.haptic = AppHapticFeedback.light,
    this.borderRadius,
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  State<AppPressable> createState() => _AppPressableState();
}

class _AppPressableState extends State<AppPressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pressedScale,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  @override
  void didUpdateWidget(covariant AppPressable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pressedScale != widget.pressedScale ||
        oldWidget.duration != widget.duration ||
        oldWidget.curve != widget.curve) {
      _controller.duration = widget.duration;
      _scaleAnimation = Tween<double>(
        begin: 1.0,
        end: widget.pressedScale,
      ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _triggerHaptic() {
    switch (widget.haptic) {
      case AppHapticFeedback.none:
        break;
      case AppHapticFeedback.selection:
        HapticFeedback.selectionClick();
        break;
      case AppHapticFeedback.light:
        HapticFeedback.lightImpact();
        break;
      case AppHapticFeedback.medium:
        HapticFeedback.mediumImpact();
        break;
      case AppHapticFeedback.heavy:
        HapticFeedback.heavyImpact();
        break;
    }
  }

  void _handleTapDown(TapDownDetails _) {
    if (widget.onTap != null || widget.onLongPress != null) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails _) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final hasAction = widget.onTap != null || widget.onLongPress != null;

    Widget result = ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );

    if (widget.borderRadius != null) {
      result = ClipRRect(borderRadius: widget.borderRadius!, child: result);
    }

    if (!hasAction) {
      return result;
    }

    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: () {
        _triggerHaptic();
        widget.onTap?.call();
      },
      onLongPress: widget.onLongPress != null
          ? () {
              _triggerHaptic();
              widget.onLongPress?.call();
            }
          : null,
      child: result,
    );
  }
}
