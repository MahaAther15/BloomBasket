import 'dart:math';
import 'package:flutter/material.dart';

class GlitterWidget extends StatefulWidget {
  final Widget child;
  final int particleCount;
  final Color color;

  const GlitterWidget({
    super.key,
    required this.child,
    this.particleCount = 20,
    this.color = Colors.white,
  });

  @override
  State<GlitterWidget> createState() => _GlitterWidgetState();
}

class _GlitterWidgetState extends State<GlitterWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<GlitterParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    for (int i = 0; i < widget.particleCount; i++) {
      _particles.add(GlitterParticle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 3 + 1,
        speed: _random.nextDouble() * 0.002 + 0.001,
        opacity: _random.nextDouble(),
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: GlitterPainter(
                  particles: _particles,
                  color: widget.color,
                  progress: _controller.value,
                ),
                child: const SizedBox.expand(),
              );
            },
          ),
        ),
      ],
    );
  }
}

class GlitterParticle {
  double x;
  double y;
  double size;
  double speed;
  double opacity;

  GlitterParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });

  void update() {
    y -= speed;
    if (y < 0) y = 1.0;
    opacity = (sin(DateTime.now().millisecondsSinceEpoch / 200 + x * 10) + 1) / 2;
  }
}

class GlitterPainter extends CustomPainter {
  final List<GlitterParticle> particles;
  final Color color;
  final double progress;

  GlitterPainter({
    required this.particles,
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var p in particles) {
      p.update();
      paint.color = color.withOpacity(p.opacity * 0.6);
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.size,
        paint,
      );
      
      // Draw cross for extra sparkle
      if (p.opacity > 0.7) {
        final crossPaint = Paint()
          ..color = color.withOpacity(p.opacity * 0.4)
          ..strokeWidth = 0.5;
        canvas.drawLine(
          Offset(p.x * size.width - p.size * 1.5, p.y * size.height),
          Offset(p.x * size.width + p.size * 1.5, p.y * size.height),
          crossPaint,
        );
        canvas.drawLine(
          Offset(p.x * size.width, p.y * size.height - p.size * 1.5),
          Offset(p.x * size.width, p.y * size.height + p.size * 1.5),
          crossPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
