import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A decorative animated flower button: rotating petals + pulsing scale.
class FlowerButton extends StatefulWidget {
  final VoidCallback onPressed;
  final double size;
  final String? assetImage; // optional asset path for flower image

  const FlowerButton({super.key, required this.onPressed, this.size = 56, this.assetImage});

  @override
  State<FlowerButton> createState() => _FlowerButtonState();
}

class _FlowerButtonState extends State<FlowerButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double size = widget.size;

    return GestureDetector(
      onTap: widget.onPressed,
      child: SizedBox(
        width: size,
        height: size,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, child) {
            final rotation = _ctrl.value * 2 * math.pi;
            final pulse = 0.95 + (math.sin(_ctrl.value * 2 * math.pi) * 0.05);

            return Transform.rotate(
              angle: rotation * 0.2,
              child: Transform.scale(
                scale: pulse,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.pink.shade200,
                        Colors.purple.shade300,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.18),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: widget.assetImage != null
                        ? ClipOval(
                            child: Image.asset(
                              widget.assetImage!,
                              width: size * 0.6,
                              height: size * 0.6,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.local_florist_rounded,
                            color: Colors.white,
                            size: size * 0.56,
                          ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
