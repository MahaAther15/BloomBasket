import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/app_state.dart';

// ─── Shared Palette (Matching Your App) ──────────────────────────────────────
const _kPurple = Color(0xFF7457A2);
const _kPurpleLight = Color(0xFF9B7BC8);
const _kPurpleSoft = Color(0xFFEDE7F6);
const _kGold = Color(0xFFF7C948);
const _kWhite = Colors.white;
const _kText = Color(0xFF2D1B4E);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Fade animation for the entire screen
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    // Scale animation for the icon
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    // Slide animation for the text
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Rotation animation for the icon
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    // Pulse animation for the icon (continuous)
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();

    // Always navigate to home after animation completes
    Timer(const Duration(milliseconds: 3000), () {
      if (mounted) {
        context.go('/');
      }
    });
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _kPurple,
              _kPurpleLight,
              const Color(0xFFB8A9D4),
              _kPurpleSoft,
              _kPurple,
            ],
            stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
          ),
        ),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Icon with rotation and pulse
                    Transform.rotate(
                      angle: _rotationAnimation.value * 3.14159 * 2,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                padding:
                                    EdgeInsets.all(isSmallScreen ? 16 : 20),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      _kWhite.withOpacity(0.3),
                                      _kWhite.withOpacity(0.1),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _kWhite.withOpacity(0.25),
                                      blurRadius: 30,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.local_florist,
                                  size: 80,
                                  color: _kWhite,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Animated Main Title
                    SlideTransition(
                      position: _slideAnimation,
                      child: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            _kWhite,
                            _kWhite,
                            _kGold,
                            _kWhite,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: Text(
                          'BLOOMBASKET',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 28 : 36,
                            letterSpacing: isSmallScreen ? 6 : 8,
                            fontWeight: FontWeight.bold,
                            color: _kWhite,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Animated Subtitle
                    SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 16 : 24,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _kWhite.withOpacity(0.2),
                              _kWhite.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          'BOTANICAL PRESTIGE',
                          style: TextStyle(
                            color: _kWhite.withOpacity(0.9),
                            letterSpacing: isSmallScreen ? 2 : 4,
                            fontSize: isSmallScreen ? 10 : 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    // Loading indicator
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        width: 40,
                        height: 40,
                        padding: const EdgeInsets.all(8),
                        child: const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _kWhite,
                          ),
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Alternative Version with Dynamic Gradient Animation ─────────────────────
class SplashScreenAnimated extends StatefulWidget {
  const SplashScreenAnimated({super.key});

  @override
  State<SplashScreenAnimated> createState() => _SplashScreenAnimatedState();
}

class _SplashScreenAnimatedState extends State<SplashScreenAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController _gradientController;
  late Animation<Alignment> _gradientAnimation;
  late AnimationController _mainController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Gradient animation controller
    _gradientController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _gradientAnimation = Tween<Alignment>(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).animate(
      CurvedAnimation(
        parent: _gradientController,
        curve: Curves.easeInOut,
      ),
    );

    // Main animation controller
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Curves.elasticOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Curves.easeOutCubic,
      ),
    );

    _mainController.forward();

    Timer(const Duration(milliseconds: 3000), () {
      if (mounted) {
        context.go('/');
      }
    });
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _gradientAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: _gradientAnimation.value,
                end: Alignment.center,
                colors: [
                  _kPurple,
                  _kPurpleLight,
                  const Color(0xFFC4B5E0),
                  _kPurpleSoft,
                  _kPurple,
                ],
              ),
            ),
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Logo Container
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              _kWhite.withOpacity(0.3),
                              _kWhite.withOpacity(0.1),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _kWhite.withOpacity(0.3),
                              blurRadius: 40,
                              spreadRadius: 15,
                            ),
                          ],
                        ),
                        child: TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 360),
                          duration: const Duration(seconds: 3),
                          builder: (context, double angle, child) {
                            return Transform.rotate(
                              angle: angle * 3.14159 / 180,
                              child: const Icon(
                                Icons.spa,
                                size: 80,
                                color: _kWhite,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Animated Main Title
                    SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          Text(
                            'BLOOM',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 40 : 48,
                              fontWeight: FontWeight.bold,
                              color: _kWhite,
                              letterSpacing: 4,
                              shadows: [
                                Shadow(
                                  color: _kPurple.withOpacity(0.5),
                                  blurRadius: 10,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'BASKET',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 40 : 48,
                              fontWeight: FontWeight.bold,
                              color: _kGold,
                              letterSpacing: 4,
                              shadows: [
                                Shadow(
                                  color: _kPurple.withOpacity(0.5),
                                  blurRadius: 10,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Animated Subtitle
                    SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 20 : 32,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _kWhite.withOpacity(0.2),
                              Colors.transparent,
                              _kWhite.withOpacity(0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          'BOTANICAL PRESTIGE',
                          style: TextStyle(
                            color: _kWhite.withOpacity(0.9),
                            letterSpacing: isSmallScreen ? 2 : 4,
                            fontSize: isSmallScreen ? 10 : 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),
                    // Loading dots animation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return AnimatedBuilder(
                          animation: _mainController,
                          builder: (context, child) {
                            final delay = index * 0.2;
                            final value =
                                (_mainController.value - delay).clamp(0.0, 1.0);
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              child: Transform.scale(
                                scale: value,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _kWhite,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
