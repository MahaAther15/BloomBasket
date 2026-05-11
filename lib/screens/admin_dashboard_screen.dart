import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_state.dart';
import '../models/order.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  static const Color neonCyan = Color(0xFF00FFFF);
  static const Color neonMagenta = Color(0xFFFF00FF);
  static const Color neonLime = Color(0xFF39FF14);
  static const Color neonPink = Color(0xFFFF10F0);
  static const Color darkBg = Color(0xFF0D0D0D);

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final orders = appState.orders;

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        title: Text(
          'NEON ADMIN PANEL',
          style: TextStyle(
            color: neonCyan,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            shadows: [
              Shadow(color: neonCyan.withOpacity(0.8), blurRadius: 10),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined, color: neonLime),
            onPressed: () {
              context.push('/upload');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Animated neon grid + scanline
          Positioned.fill(
            child: _NeonGridBackground(
              cyan: neonCyan,
              magenta: neonMagenta,
            ),
          ),

          // Background Animation (Lottie)
          Positioned(
            right: -50,
            top: -50,
            child: SizedBox(
              width: 220,
              height: 220,
              child: Lottie.network(
                'https://assets10.lottiefiles.com/packages/lf20_96py9mdf.json', // 3D Flower
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const _NeonFallbackParticles(),
              ),
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsGrid(appState),
                const SizedBox(height: 30),
                _animatedSectionHeader('ORDER MANAGEMENT', neonMagenta),
                const SizedBox(height: 15),
                orders.isEmpty
                    ? _emptyState()
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          return _AnimatedOrderEntry(
                            index: index,
                            child: _OrderNeonCard(order: orders[index]),
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _animatedSectionHeader(String title, Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        final glow = (6 + 16 * t);
        final thickness = (3 + 1 * t).toDouble();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: color, width: thickness),
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              shadows: [
                Shadow(color: color.withOpacity(0.35), blurRadius: glow),
                Shadow(color: color.withOpacity(0.15), blurRadius: glow * 1.8),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildStatsGrid(AppState appState) {
    final products = appState.products.length.toString();
    final ordersCount = appState.orders.length.toString();
    final totalSales = '\$${_calculateTotalSales(appState.orders)}';
    const customers = '124';

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _NeonPulsingCard(
          delayMs: 0,
          label: 'PRODUCTS',
          value: products,
          color: neonCyan,
          icon: Icons.inventory_2,
        ),
        _NeonPulsingCard(
          delayMs: 120,
          label: 'ORDERS',
          value: ordersCount,
          color: neonMagenta,
          icon: Icons.shopping_bag,
        ),
        _NeonPulsingCard(
          delayMs: 240,
          label: 'TOTAL SALES',
          value: totalSales,
          color: neonLime,
          icon: Icons.payments,
        ),
        _NeonPulsingCard(
          delayMs: 360,
          label: 'CUSTOMERS',
          value: customers,
          color: neonPink,
          icon: Icons.people,
        ),
      ],
    );
  }


  String _calculateTotalSales(List<BBOrder> orders) {
    return orders.fold(0.0, (sum, o) => sum + o.totalAmount).toStringAsFixed(0);
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.receipt_long, color: Colors.grey.withOpacity(0.3), size: 80),
          const SizedBox(height: 10),
          Text(
            'NO ORDERS YET',
            style: TextStyle(color: Colors.grey.withOpacity(0.5), letterSpacing: 2),
          ),
        ],
      ),
    );
  }
}

class _NeonPulsingCard extends StatefulWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final int delayMs;

  const _NeonPulsingCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.delayMs,
  });

  @override
  State<_NeonPulsingCard> createState() => _NeonPulsingCardState();
}

class _NeonPulsingCardState extends State<_NeonPulsingCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final glow = 6 + 14 * (1 - (t - 0.5).abs() * 2);
        final borderAlpha = 0.18 + 0.22 * t;

        return Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AdminDashboardScreen.darkBg,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: widget.color.withOpacity(borderAlpha), width: 1),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.22),
                blurRadius: glow,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(widget.icon, color: widget.color, size: 20),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: widget.color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.color,
                          blurRadius: 2 + 8 * t,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: widget.color.withOpacity(0.45),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.color.withOpacity(0.75),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AnimatedOrderEntry extends StatelessWidget {
  final int index;
  final Widget child;

  const _AnimatedOrderEntry({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    final delay = (index * 60).clamp(0, 420);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,

      builder: (context, t, _) {
        final opacity = 0.2 + 0.8 * t;
        final offsetY = 14 * (1 - t);
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, offsetY),
            child: child,
          ),
        );
      },
    );
  }
}

class _NeonGridBackground extends StatefulWidget {
  final Color cyan;
  final Color magenta;

  const _NeonGridBackground({required this.cyan, required this.magenta, super.key});

  @override
  State<_NeonGridBackground> createState() => _NeonGridBackgroundState();
}

class _NeonGridBackgroundState extends State<_NeonGridBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final v = _controller.value;
        final scanY = 1 - v;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.black,
                Colors.black.withOpacity(0.4),
                Colors.black,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Grid
              Opacity(
                opacity: 0.22,
                child: CustomPaint(
                  painter: _NeonGridPainter(cyan: widget.cyan, magenta: widget.magenta),
                  size: MediaQuery.sizeOf(context),
                ),
              ),
              // Scanline glow
              Positioned.fill(
                child: Align(
                  alignment: Alignment(0, -0.9 + 1.8 * scanY),
                  child: Container(
                    width: double.infinity,
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.cyan.withOpacity(0.0),
                          widget.cyan.withOpacity(0.9),
                          widget.magenta.withOpacity(0.9),
                          widget.magenta.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Subtle vignette
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(0, -0.2),
                      radius: 1.1,
                      colors: [
                        Colors.transparent,
                        Color(0xFF0D0D0D),
                      ],
                      stops: [0.55, 1.0],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NeonGridPainter extends CustomPainter {
  final Color cyan;
  final Color magenta;

  _NeonGridPainter({required this.cyan, required this.magenta});

  @override
  void paint(Canvas canvas, Size size) {
    const step = 28.0;
    final paintCyan = Paint()
      ..color = cyan.withOpacity(0.22)
      ..strokeWidth = 1;
    final paintMagenta = Paint()
      ..color = magenta.withOpacity(0.18)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), (x ~/ step) % 2 == 0 ? paintCyan : paintMagenta);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), (y ~/ step) % 2 == 0 ? paintCyan : paintMagenta);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NeonFallbackParticles extends StatefulWidget {
  const _NeonFallbackParticles();

  @override
  State<_NeonFallbackParticles> createState() => _NeonFallbackParticlesState();
}

class _NeonFallbackParticlesState extends State<_NeonFallbackParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cyan = const Color(0xFF00FFFF);
    final magenta = const Color(0xFFFF00FF);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Stack(
          children: List.generate(18, (i) {
            final p = i / 18;
            final x = 10 + 180 * p;
            final y = 10 + 180 * ((i % 3) / 3);
            final dx = 20 * (t - 0.5) * (i % 2 == 0 ? 1 : -1);
            return Positioned(
              left: x.toDouble() + dx,
              top: y.toDouble(),
              child: Container(
                width: 4 + (i % 4).toDouble(),
                height: 4 + (i % 4).toDouble(),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (i % 2 == 0 ? cyan : magenta).withOpacity(0.9),
                  boxShadow: [
                    BoxShadow(
                      color: (i % 2 == 0 ? cyan : magenta).withOpacity(0.6),
                      blurRadius: 12,
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}


class _OrderNeonCard extends StatefulWidget {
  final BBOrder order;

  const _OrderNeonCard({required this.order});

  @override
  State<_OrderNeonCard> createState() => _OrderNeonCardState();
}

class _OrderNeonCardState extends State<_OrderNeonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.order.status.color;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final glow = 6 + 18 * (0.5 - (_controller.value - 0.5).abs());
        final borderAlpha = 0.15 + 0.35 * _controller.value;

        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AdminDashboardScreen.darkBg.withOpacity(0.6),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color.withOpacity(borderAlpha)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.22),
                blurRadius: glow,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withOpacity(0.55)),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.25),
                      blurRadius: glow * 0.6,
                    ),
                  ],
                ),
                child: Icon(widget.order.status.icon, color: color),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ORDER #${widget.order.id.substring(0, 8).toUpperCase()}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        shadows: [
                          Shadow(
                            color: color.withOpacity(0.35),
                            blurRadius: glow,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${widget.order.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusDropdown(order: widget.order),
            ],
          ),
        );
      },
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  final BBOrder order;

  const _StatusDropdown({required this.order});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<OrderStatus>(
      initialValue: order.status,
      onSelected: (OrderStatus status) {
        context.read<AppState>().updateOrderStatus(order.id, status);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: order.status.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: order.status.color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              order.status.displayText,
              style: TextStyle(
                color: order.status.color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(Icons.arrow_drop_down, color: order.status.color, size: 16),
          ],
        ),
      ),
      itemBuilder: (BuildContext context) => OrderStatus.values.map((status) {
        return PopupMenuItem<OrderStatus>(
          value: status,
          child: Text(
            status.displayText,
            style: TextStyle(color: status.color, fontWeight: FontWeight.bold),
          ),
        );
      }).toList(),
    );
  }
}
