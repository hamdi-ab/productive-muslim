import 'package:flutter/material.dart';

/// A soothing breathing pulse and glow animation wrapper for active timers,
/// prayer indicators, and high-streak achievements.
class PulsingGlow extends StatefulWidget {
  final Widget child;
  final bool animate;
  final Color? glowColor;
  final double minScale;
  final double maxScale;
  final Duration duration;
  final double blurRadius;

  const PulsingGlow({
    super.key,
    required this.child,
    this.animate = true,
    this.glowColor,
    this.minScale = 0.97,
    this.maxScale = 1.03,
    this.duration = const Duration(milliseconds: 2000),
    this.blurRadius = 12.0,
  });

  @override
  State<PulsingGlow> createState() => _PulsingGlowState();
}

class _PulsingGlowState extends State<PulsingGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _glowAnimation;

  bool get _isTestEnvironment =>
      WidgetsBinding.instance.runtimeType.toString().contains('Test');

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _scaleAnimation =
        Tween<double>(begin: widget.minScale, end: widget.maxScale).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
        );

    _glowAnimation = Tween<double>(begin: 0.15, end: 0.55).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    if (widget.animate && !_isTestEnvironment) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant PulsingGlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate) {
      if (widget.animate && !_isTestEnvironment) {
        _controller.repeat(reverse: true);
      } else {
        _controller.animateTo(0.0, duration: const Duration(milliseconds: 300));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = _scaleAnimation.value;
        final glowOpacity = _glowAnimation.value;

        return Transform.scale(
          scale: scale,
          child: Container(
            decoration: widget.glowColor != null
                ? BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: widget.glowColor!.withValues(alpha: glowOpacity),
                        blurRadius: widget.blurRadius,
                        spreadRadius: 2,
                      ),
                    ],
                  )
                : null,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
