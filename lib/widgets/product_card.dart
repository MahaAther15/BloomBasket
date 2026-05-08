import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product.dart';
import '../app_theme.dart';
import 'image_fallback.dart';

/// Animated 3D product card with subtle tilt, depth shadow and image parallax.
class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  // rotation angles (radians)
  double _rx = 0.0;
  double _ry = 0.0;
  double _tilt = 0.0;
  double _scale = 1.0;

  late final AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  void _onHover(PointerEvent e, BoxConstraints box) {
    final local = e.localPosition;
    final cx = box.maxWidth / 2;
    final cy = box.maxHeight / 2;
    final dx = (local.dx - cx) / cx; // -1..1
    final dy = (local.dy - cy) / cy; // -1..1

    setState(() {
      _ry = dx * 0.12; // rotate around Y
      _rx = -dy * 0.12; // rotate around X
      _tilt = math.sqrt(dx * dx + dy * dy);
      _scale = 1.02;
    });
  }

  void _resetTilt() {
    setState(() {
      _rx = 0;
      _ry = 0;
      _tilt = 0;
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _scale = 0.98),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 7,
            child: LayoutBuilder(builder: (context, box) {
              return MouseRegion(
                onHover: (e) => _onHover(e, box),
                onExit: (_) => _resetTilt(),
                child: AnimatedBuilder(
                  animation: _floatController,
                  builder: (context, child) {
                    final floatOffset = (math.sin(_floatController.value * 2 * math.pi) * 6);
                    final matrix = Matrix4.identity()
                      ..setEntry(3, 2, 0.0015) // perspective
                      ..translate(0.0, -floatOffset * 0.2, 0.0)
                      ..rotateX(_rx)
                      ..rotateY(_ry)
                      ..scale(_scale);

                    return Transform(
                      transform: matrix,
                      alignment: FractionalOffset.center,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12 + _tilt * 0.08),
                              blurRadius: 18 + (_tilt * 12),
                              offset: Offset(0, 8 + (_tilt * 6)),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // subtle parallax image layer
                              Positioned.fill(
                                child: AnimatedFractionalTranslation(
                                  rx: _rx,
                                  ry: _ry,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Center(
                                      child: product.imageUrl.startsWith('assets/')
                                          ? Image.asset(
                                              product.imageUrl,
                                              fit: BoxFit.contain,
                                              errorBuilder: (context, error, stackTrace) =>
                                                  const ImageFallback(),
                                            )
                                          : CachedNetworkImage(
                                              imageUrl: product.imageUrl,
                                              fit: BoxFit.contain,
                                              placeholder: (context, url) =>
                                                  const ImageFallback(),
                                              errorWidget: (context, url, error) =>
                                                  const ImageFallback(),
                                            ),
                                    ),
                                  ),
                                ),
                              ),

                              // soft neon rim for style
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: RadialGradient(
                                        center: const Alignment(-0.4, -0.6),
                                        radius: 1.2,
                                        colors: [
                                          Colors.transparent,
                                          Colors.transparent,
                                          AppTheme.primaryGreen.withOpacity(0.02),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            product.name.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${product.price.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.primaryGreen.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small helper that shifts its child slightly for parallax based on card rotation.
class AnimatedFractionalTranslation extends StatelessWidget {
  final Widget child;
  final double rx;
  final double ry;

  const AnimatedFractionalTranslation({super.key, required this.child, required this.rx, required this.ry});

  @override
  Widget build(BuildContext context) {
    final tx = ry * 10; // move horizontally opposite of Y rotation
    final ty = rx * 8; // move vertically for X rotation
    return Transform.translate(
      offset: Offset(tx, ty),
      child: child,
    );
  }
}
