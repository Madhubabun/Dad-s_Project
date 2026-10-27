import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Five water drops: one filled for every 20% chance of rain.
/// 0% → all empty, 100% → all five blue.
class RainDrops extends StatelessWidget {
  const RainDrops({super.key, required this.chance, this.size = 30});

  final int chance;
  final double size;

  @override
  Widget build(BuildContext context) {
    final filled = (chance / 20).ceil().clamp(0, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 5; i++)
          Icon(
            i < filled ? Icons.water_drop : Icons.water_drop_outlined,
            size: size,
            color: i < filled
                ? const Color(0xFF1E88E5)
                : const Color(0xFF90A4AE),
          ),
      ],
    );
  }
}

/// Drops that fall slowly behind the rain card when rain is likely.
/// Stays still when the phone has animations turned off.
class FallingRain extends StatefulWidget {
  const FallingRain({super.key, required this.child, required this.active});

  final Widget child;
  final bool active;

  @override
  State<FallingRain> createState() => _FallingRainState();
}

class _FallingRainState extends State<FallingRain>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _update();
  }

  @override
  void didUpdateWidget(FallingRain oldWidget) {
    super.didUpdateWidget(oldWidget);
    _update();
  }

  void _update() {
    final animate = widget.active && !MediaQuery.of(context).disableAnimations;
    if (animate && !_c.isAnimating) _c.repeat();
    if (!animate) _c.stop();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return widget.child;
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) =>
                CustomPaint(painter: _RainPainter(_c.value)),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _RainPainter extends CustomPainter {
  _RainPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E88E5).withValues(alpha: 0.18)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    // Fixed columns, each falling at its own speed and start point.
    final random = math.Random(7);
    for (var i = 0; i < 14; i++) {
      final x = random.nextDouble() * size.width;
      final speed = 0.6 + random.nextDouble() * 0.8;
      final y =
          ((random.nextDouble() + t * speed) % 1.0) * (size.height + 30) - 15;
      canvas.drawLine(Offset(x, y), Offset(x - 3, y + 14), paint);
    }
  }

  @override
  bool shouldRepaint(_RainPainter old) => old.t != t;
}
