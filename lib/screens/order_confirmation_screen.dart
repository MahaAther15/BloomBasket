import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import '../app_theme.dart';
import '../widgets/primary_button.dart';

// ─── Shared Palette (Matching Your App) ──────────────────────────────────────
const _kPurple = Color(0xFF7457A2);
const _kPurpleLight = Color(0xFF9B7BC8);
const _kPurpleSoft = Color(0xFFEDE7F6);
const _kBg = Color(0xFFFAF8FF);
const _kWhite = Colors.white;
const _kText = Color(0xFF2D1B4E);
const _kTextSub = Color(0xFF8E7BAE);
const _kGold = Color(0xFFF7C948);
const _kGreen = Color(0xFF4CAF50);

class OrderConfirmationScreen extends StatefulWidget {
  const OrderConfirmationScreen({super.key});

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _iconScaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _buttonAnimation;
  late Animation<double> _confettiAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _iconScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _buttonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 0.9, curve: Curves.easeOutBack),
      ),
    );

    _confettiAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1, 0.8, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _kBg,
                  _kPurpleSoft.withOpacity(0.3),
                ],
              ),
            ),
          ),
          // Confetti particles
          if (_confettiAnimation.value > 0)
            ..._buildConfettiParticles(isSmallScreen),
          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(isSmallScreen ? 20 : 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: isSmallScreen ? 20 : 40),
                    // Animated Check Icon with Ring effect
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Pulsing ring animation
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0.8, end: 1.2),
                          duration: const Duration(milliseconds: 1500),
                          builder: (context, double scale, child) {
                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _kPurple.withOpacity(0.1),
                                ),
                              ),
                            );
                          },
                          onEnd: () {
                            Future.delayed(const Duration(milliseconds: 500),
                                () {
                              if (mounted) setState(() {});
                            });
                          },
                        ),
                        // Main icon with scale animation
                        ScaleTransition(
                          scale: _iconScaleAnimation,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [_kPurple, _kPurpleLight],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _kPurple.withOpacity(0.3),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 80,
                              color: _kWhite,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Animated Title
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [_kPurple, _kGold],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: Text(
                          'ORDER CONFIRMED',
                          style: TextStyle(
                            letterSpacing: 4,
                            fontSize: isSmallScreen ? 20 : 24,
                            fontWeight: FontWeight.bold,
                            color: _kWhite,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Animated Subtitle
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 0 : 20,
                          ),
                          child: Text(
                            'THANK YOU FOR YOUR PURCHASE. YOUR BOTANICAL ARRANGEMENT IS BEING PREPARED WITH CARE.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _kTextSub,
                              height: 1.8,
                              fontSize: isSmallScreen ? 11 : 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    // Animated Summary Container
                    SlideTransition(
                      position: _slideAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0.8, end: 1.0),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutBack,
                          builder: (context, double scale, child) {
                            return Transform.scale(scale: scale, child: child);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _kWhite,
                                  _kPurpleSoft.withOpacity(0.3),
                                ],
                              ),
                              border: Border.all(
                                color: _kGold.withOpacity(0.2),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: _kPurple.withOpacity(0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _AnimatedSummaryRow(
                                  label: 'ORDER NUMBER',
                                  value: '#BB-89012',
                                  delay: 0.2,
                                ),
                                const SizedBox(height: 12),
                                _AnimatedSummaryRow(
                                  label: 'ESTIMATED DELIVERY',
                                  value: 'MAY 28, 2026',
                                  delay: 0.4,
                                ),
                                const SizedBox(height: 12),
                                _AnimatedSummaryRow(
                                  label: 'TOTAL AMOUNT',
                                  value: '\$156.00',
                                  delay: 0.6,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    // Animated Buttons
                    ScaleTransition(
                      scale: _buttonAnimation,
                      child: Column(
                        children: [
                          PrimaryButton(
                            label: 'Track Order',
                            onPressed: () {
                              _navigateWithAnimation(context, '/track');
                            },
                          ),
                          const SizedBox(height: 16),
                          TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 600),
                            builder: (context, double value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: child,
                                ),
                              );
                            },
                            child: TextButton(
                              onPressed: () {
                                _navigateWithAnimation(context, '/');
                              },
                              child: Text(
                                'BACK TO HOME',
                                style: TextStyle(
                                  color: _kPurple,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 20 : 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildConfettiParticles(bool isSmallScreen) {
    List<Widget> particles = [];
    final colors = [
      _kPurple,
      _kGold,
      const Color(0xFF9B7BC8),
      const Color(0xFFE8D5F5),
      _kPurpleLight,
    ];

    for (int i = 0; i < 40; i++) {
      final delay = (i * 0.025);
      final startPosition = (i * 37 % 360) * (3.14159 / 180);
      final radius = 180.0 + (i % 80);

      particles.add(
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: Duration(milliseconds: (800 + (delay * 200)).toInt()),
          builder: (context, double value, child) {
            if (value < delay) return const SizedBox.shrink();

            final progress = (value - delay) / (1 - delay);
            final x = radius * cos(startPosition + progress * 3.14159);
            final y = radius * sin(startPosition + progress * 2);

            return Positioned(
              left: MediaQuery.of(context).size.width / 2 + x * progress,
              top: -50 + y * progress,
              child: Opacity(
                opacity: 1 - progress * 1.2,
                child: Transform.rotate(
                  angle: progress * 15,
                  child: Container(
                    width: isSmallScreen ? 5 : 7,
                    height: isSmallScreen ? 5 : 7,
                    decoration: BoxDecoration(
                      color: colors[i % colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
    return particles;
  }

  void _navigateWithAnimation(BuildContext context, String route) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(route);
          });
          return const SizedBox.shrink();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = const Offset(1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.easeInOutCubic;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}

// ─── Animated Summary Row ─────────────────────────────────────────────────────
class _AnimatedSummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final double delay;

  const _AnimatedSummaryRow({
    required this.label,
    required this.value,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: (400 + (delay * 200)).toInt()),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(20 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: _kTextSub,
              letterSpacing: 1,
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _kPurple.withOpacity(0.08),
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: _kPurple,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Optional: Confetti Widget for more celebration effect ───────────────────
class ConfettiWidget extends StatefulWidget {
  final Animation<double> animation;

  const ConfettiWidget({super.key, required this.animation});

  @override
  State<ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _particles = List.generate(50, (index) => ConfettiParticle());
    widget.animation.addListener(_onAnimationUpdate);
    _controller.forward();
  }

  void _onAnimationUpdate() {
    setState(() {});
  }

  @override
  void dispose() {
    widget.animation.removeListener(_onAnimationUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.animation.value <= 0) return const SizedBox.shrink();

    return Stack(
      children: _particles.map((particle) {
        final progress = widget.animation.value;
        final position = particle.updatePosition(progress);

        return Positioned(
          left: position.dx,
          top: position.dy,
          child: Transform.rotate(
            angle: particle.rotation * progress,
            child: Container(
              width: particle.size,
              height: particle.size,
              decoration: BoxDecoration(
                color: particle.color,
                shape: particle.shape,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class ConfettiParticle {
  final double startX;
  final double startY;
  final double velocityX;
  final double velocityY;
  final double size;
  final Color color;
  final BoxShape shape;
  double rotation;

  ConfettiParticle()
      : startX = (DateTime.now().millisecondsSinceEpoch % 1000) / 1000,
        startY = 0,
        velocityX = (DateTime.now().millisecondsSinceEpoch % 200 - 100) / 50,
        velocityY = 2 + (DateTime.now().millisecondsSinceEpoch % 100) / 50,
        size = 4 + (DateTime.now().millisecondsSinceEpoch % 8),
        color = [
          _kPurple,
          _kGold,
          Colors.pink.shade300,
          const Color(0xFF9B7BC8),
          _kPurpleLight,
        ][DateTime.now().millisecondsSinceEpoch % 5],
        shape = BoxShape.circle,
        rotation = 0;

  Offset updatePosition(double progress) {
    return Offset(
      startX * 300 + velocityX * progress * 100,
      startY + velocityY * progress * 200,
    );
  }
}
