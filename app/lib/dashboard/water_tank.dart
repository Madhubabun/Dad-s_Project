import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A tank that fills with gently moving water up to [percent] (0–100).
/// The big number sits on top, so the level reads at a glance.
///
/// The wave only moves while the screen is visible (Flutter pauses it in
/// the background), and stays still if the phone has animations turned off.
class WaterTank extends StatefulWidget {
  const WaterTank({super.key, required this.percent, this.size = 120});

  final double percent;
  final double size;

  @override
  State<WaterTank> createState() => _WaterTankState();
}

class _WaterTankState extends State<WaterTank> with TickerProviderStateMixin {
  late final AnimationController _wave = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  );
  late final AnimationController _fill = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _wave.stop();
      _fill.value = 1;
    } else if (!_wave.isAnimating) {
      _wave.repeat();
    }
  }

  @override
  void dispose() {
    _wave.dispose();
    _fill.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final level = (widget.percent.clamp(0, 100)) / 100;
    return SizedBox(
      width: widget.size,
      height: widget.size * 1.15,
      child: AnimatedBuilder(
        animation: Listenable.merge([_wave, _fill]),
        builder: (context, _) => CustomPaint(
          painter: _TankPainter(
            level: level * Curves.easeOutCubic.transform(_fill.value),
            phase: _wave.value * 2 * math.pi,
            border: theme.colorScheme.outline,
          ),
          child: Center(
            child: Text(
              '${widget.percent.round()}%',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: level > 0.45 ? Colors.white : const Color(0xFF0D47A1),
                shadows: level > 0.45
                    ? const [Shadow(blurRadius: 4, color: Colors.black45)]
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TankPainter extends CustomPainter {
  _TankPainter({
    required this.level,
    required this.phase,
    required this.border,
  });

  final double level; // 0..1
  final double phase;
  final Color border;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final tank = RRect.fromRectAndRadius(
      rect.deflate(2),
      const Radius.circular(18),
    );
    canvas.save();
    canvas.clipRRect(tank);
    canvas.drawRect(rect, Paint()..color = const Color(0xFFE3F2FD));

    final waterTop = size.height * (1 - level);
    // Two waves, slightly out of step, look like real water.
    for (final (offset, color) in [
      (0.0, const Color(0xFF64B5F6)),
      (math.pi, const Color(0xFF1E88E5)),
    ]) {
      final path = Path()..moveTo(0, size.height);
      for (double x = 0; x <= size.width; x += 2) {
        final y =
            waterTop +
            math.sin(x / size.width * 2 * math.pi + phase + offset) * 5;
        path.lineTo(x, y);
      }
      path
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(path, Paint()..color = color.withValues(alpha: 0.85));
    }
    canvas.restore();
    canvas.drawRRect(
      tank,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = border,
    );
  }

  @override
  bool shouldRepaint(_TankPainter old) =>
      old.level != level || old.phase != phase || old.border != border;
}
