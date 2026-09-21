import 'dart:math';
import 'package:flutter/material.dart';

class Particle {
  double x;
  double y;
  double size;
  double speed;
  double angle;
  double opacity;
  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.angle,
    required this.opacity,
  });
  void update() {
    x += cos(angle) * speed;
    y += sin(angle) * speed;
    size *= 0.99; // Gradually shrink
    opacity *= 0.97; // Gradually fade
  }
}
class SmokePainter extends CustomPainter {
  final List<Particle> particles;
  SmokePainter(this.particles);
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (final particle in particles) {
      final paint = Paint()
        ..color = Colors.grey.withValues(alpha:particle.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      canvas.drawCircle(
        center + Offset(particle.x, particle.y),
        particle.size,
        paint,
      );
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CarSmokeParticleWidget extends StatefulWidget {
  const CarSmokeParticleWidget({super.key});
  @override
  State<CarSmokeParticleWidget> createState() => _CarSmokeParticleWidgetState();
}
class _CarSmokeParticleWidgetState extends State<CarSmokeParticleWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final Random _random = Random();
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return  AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_random.nextDouble() < 0.3) {
          _particles.add(Particle(
            x: -30 + _random.nextDouble() * 20,
            y: 20 + _random.nextDouble() * 10,
            size: 5 + _random.nextDouble() * 10,
            speed: 0.5 + _random.nextDouble() * 1.5,
            angle: -_random.nextDouble() * 0.5,
            opacity: 0.7 + _random.nextDouble() * 0.3,
          ));
        }
        for (var p in _particles) {
          p.update();
        }
        _particles.removeWhere((p) => p.opacity <= 0 || p.size <= 0);
        return CustomPaint(
          painter: SmokePainter(_particles),
          size: const Size(220, 300),
        );
      },
    );
  }
}