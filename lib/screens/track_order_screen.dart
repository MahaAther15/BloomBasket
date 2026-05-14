import 'package:flutter/material.dart';
import '../app_theme.dart';

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

class TrackOrderScreen extends StatefulWidget {
  const TrackOrderScreen({super.key});

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _mapAnimation;
  late List<Animation<double>> _stepAnimations;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _cardAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _mapAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Staggered animations for each step
    _stepAnimations = List.generate(4, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(0.2 + (index * 0.1), 0.6 + (index * 0.1),
              curve: Curves.easeOut),
        ),
      );
    });

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
      appBar: AppBar(
        backgroundColor: _kWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _kText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'TRACK ORDER',
          style: TextStyle(
            letterSpacing: 4,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: _kText,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: _kPurple),
            onPressed: () {
              _animationController.reset();
              _animationController.forward();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animated Order Info Card
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
                  ),
                ),
                child: ScaleTransition(
                  scale: _cardAnimation,
                  child: _buildOrderCard(isSmallScreen),
                ),
              ),
            ),

            const SizedBox(height: 48),

            // Animated Status Title
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.1, 0.4, curve: Curves.easeOut),
                  ),
                ),
                child: Text(
                  'ORDER STATUS',
                  style: TextStyle(
                    letterSpacing: 3,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: _kTextSub,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Animated Vertical Stepper
            ..._buildAnimatedStatusSteps(),

            const SizedBox(height: 48),

            // Animated Map Placeholder
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
                  ),
                ),
                child: ScaleTransition(
                  scale: _mapAnimation,
                  child: _buildMapPlaceholder(isSmallScreen),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kPurple, _kPurpleLight],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _kPurple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ORDER #BB-89012',
                    style: TextStyle(
                      color: _kWhite,
                      letterSpacing: 2,
                      fontSize: isSmallScreen ? 10 : 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildStatusChip(),
                ],
              ),
              _buildAnimatedIcon(),
            ],
          ),
          const Divider(height: 32, color: Colors.white24),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _kWhite.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: _kWhite,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '123 BOTANICAL GARDENS, LONDON, UK',
                  style: TextStyle(
                    color: _kWhite.withOpacity(0.9),
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _kWhite.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.white70,
                ),
                const SizedBox(width: 8),
                Text(
                  'Estimated delivery: 2:30 PM today',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isSmallScreen ? 10 : 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _kGold,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 800),
        builder: (context, double value, child) {
          return Opacity(
            opacity: value,
            child: Transform.scale(
              scale: value,
              child: const Text(
                'IN PROGRESS',
                style: TextStyle(
                  color: _kWhite,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 360),
      duration: const Duration(seconds: 2),
      builder: (context, double angle, child) {
        return Transform.rotate(
          angle: angle * 3.14159 / 180,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _kWhite.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_shipping,
              color: _kWhite,
              size: 24,
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildAnimatedStatusSteps() {
    final steps = [
      {
        'title': 'ORDER CONFIRMED',
        'time': 'MAY 26, 10:30 AM',
        'completed': true
      },
      {
        'title': 'PREPARING ARRANGEMENT',
        'time': 'MAY 26, 11:45 AM',
        'completed': true,
        'current': true
      },
      {
        'title': 'OUT FOR DELIVERY',
        'time': 'ESTIMATED 2:00 PM',
        'completed': false
      },
      {'title': 'DELIVERED', 'time': 'ESTIMATED 2:30 PM', 'completed': false},
    ];

    return List.generate(steps.length, (index) {
      return AnimatedStatusStep(
        title: steps[index]['title'] as String,
        time: steps[index]['time'] as String,
        isCompleted: steps[index]['completed'] as bool,
        isCurrent: steps[index]['current'] == true,
        isFirst: index == 0,
        isLast: index == steps.length - 1,
        animation: _stepAnimations[index],
        index: index,
      );
    });
  }

  Widget _buildMapPlaceholder(bool isSmallScreen) {
    return Container(
      height: isSmallScreen ? 150 : 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _kPurple.withOpacity(0.08),
            _kPurpleSoft.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _kPurple.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _kPurple.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 1000),
                  builder: (context, double scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _kPurple.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.map_outlined,
                          size: 48,
                          color: _kPurple,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'Live location tracking coming soon',
                  style: TextStyle(
                    color: _kTextSub,
                    fontSize: isSmallScreen ? 10 : 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    final delay = index * 0.2;
                    final value =
                        (_animationController.value - delay).clamp(0.0, 1.0);
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: Transform.scale(
                        scale: value,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _kPurple.withOpacity(value),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Animated Status Step Widget ─────────────────────────────────────────────
class AnimatedStatusStep extends StatelessWidget {
  final String title;
  final String time;
  final bool isCompleted;
  final bool isCurrent;
  final bool isFirst;
  final bool isLast;
  final Animation<double> animation;
  final int index;

  const AnimatedStatusStep({
    super.key,
    required this.title,
    required this.time,
    required this.isCompleted,
    this.isCurrent = false,
    this.isFirst = false,
    this.isLast = false,
    required this.animation,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return IntrinsicHeight(
      child: FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.5),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: Row(
            children: [
              Column(
                children: [
                  // Animated Step Icon
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: Duration(milliseconds: 400 + (index * 100)),
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: value,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted ? _kPurple : Colors.transparent,
                            border: Border.all(
                              color: isCompleted
                                  ? _kPurple
                                  : _kTextSub.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: isCurrent
                              ? Container(
                                  margin: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _kPurple,
                                  ),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                  // Animated connecting line
                  if (!isLast)
                    Expanded(
                      child: TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: Duration(milliseconds: 600 + (index * 100)),
                        builder: (context, double value, child) {
                          return Container(
                            width: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: isCompleted
                                    ? [
                                        _kPurple,
                                        _kPurple.withOpacity(value),
                                      ]
                                    : [
                                        _kTextSub.withOpacity(0.1),
                                        _kTextSub.withOpacity(0.05),
                                      ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title with animation
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          color: isCompleted ? _kPurple : _kTextSub,
                          fontWeight:
                              isCurrent ? FontWeight.w700 : FontWeight.w500,
                          letterSpacing: 0.5,
                          fontSize: isSmallScreen ? 11 : 12,
                        ),
                        child: Row(
                          children: [
                            Text(title),
                            if (isCurrent) ...[
                              const SizedBox(width: 8),
                              const _PulsingDot(),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Time with animation
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: Duration(milliseconds: 500 + (index * 100)),
                        builder: (context, double value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(20 * (1 - value), 0),
                              child: Text(
                                time,
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 10 : 12,
                                  color: isCompleted
                                      ? _kPurple.withOpacity(0.7)
                                      : _kTextSub.withOpacity(0.5),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      // Progress indicator for current step
                      if (isCurrent)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0, end: 0.6),
                            duration: const Duration(milliseconds: 1500),
                            builder: (context, double value, child) {
                              return LinearProgressIndicator(
                                value: value,
                                backgroundColor: _kPurple.withOpacity(0.1),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  _kPurple,
                                ),
                                borderRadius: BorderRadius.circular(2),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Pulsing Dot Widget ──────────────────────────────────────────────────────
class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> {
  double _endValue = 1.2;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.8, end: _endValue),
      duration: const Duration(milliseconds: 800),
      builder: (context, double scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _kPurple,
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted) {
          setState(() {
            _endValue = _endValue == 1.2 ? 0.8 : 1.2;
          });
        }
      },
    );
  }
}
