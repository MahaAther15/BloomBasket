import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_state.dart';
import '../models/order.dart';

// ─── Shared Palette (Matching Home Screen) ──────────────────────────────────
const _kPurple = Color(0xFF7457A2);
const _kPurpleLight = Color(0xFFEDE7F6);
const _kPurpleSoft = Color(0xFFF3EEFE);
const _kBg = Color(0xFFFAF8FF);
const _kWhite = Colors.white;
const _kText = Color(0xFF2D1B4E);
const _kTextSub = Color(0xFF8E7BAE);
const _kGold = Color(0xFFF7C948);
const _kGreen = Color(0xFF4CAF50);
const _kOrange = Color(0xFFFF9800);
const _kRed = Color(0xFFE57373);

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  static const Color darkBg = Color(0xFF0D0D0D);

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final orders = appState.orders;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _kPurpleSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.admin_panel_settings,
                  color: _kPurple, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Admin Dashboard',
              style: TextStyle(
                color: _kText,
                fontWeight: FontWeight.w700,
                fontSize: 20,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: _kWhite,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _kPurpleSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add, color: _kPurple, size: 20),
              ),
              onPressed: () {
                context.push('/upload');
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh logic if needed
          await Future.delayed(const Duration(milliseconds: 500));
        },
        color: _kPurple,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeSection(appState),
              const SizedBox(height: 24),
              // Stats Grid
              _buildStatsGrid(appState),
              const SizedBox(height: 32),
              // Orders Section Header
              _buildSectionHeader(
                  'Recent Orders', Icons.receipt_long, orders.length),
              const SizedBox(height: 16),
              // Orders List
              orders.isEmpty
                  ? _buildEmptyOrders()
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        return _AnimatedOrderCard(
                          index: index,
                          order: orders[index],
                          onStatusChanged: (status) {
                            context
                                .read<AppState>()
                                .updateOrderStatus(orders[index].id, status);
                          },
                        );
                      },
                    ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(AppState appState) {
    final orderCount = appState.orders.length;
    final productCount = appState.products.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_kPurple, _kPurple.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _kPurple.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back!',
                  style: TextStyle(
                    color: _kWhite,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You have $orderCount orders and $productCount products',
                  style: const TextStyle(
                    color: _kWhite,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _kWhite.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.store, color: _kWhite, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Bloom & Co.',
                        style: TextStyle(color: _kWhite, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Animated Flower Icon
          SizedBox(
            width: 80,
            height: 80,
            child: Lottie.network(
              'https://assets10.lottiefiles.com/packages/lf20_96py9mdf.json',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: BoxDecoration(
                  color: _kWhite.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.local_florist, color: _kWhite, size: 40),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, int count) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _kPurpleSoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _kPurple, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _kText,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _kPurpleSoft,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _kPurple,
            ),
          ),
        ),
      ],
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
      childAspectRatio: 1.4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _StatCard(
          label: 'Total Products',
          value: products,
          icon: Icons.inventory_2_outlined,
          color: _kPurple,
          gradientColors: [_kPurpleSoft, _kPurple.withOpacity(0.1)],
        ),
        _StatCard(
          label: 'Total Orders',
          value: ordersCount,
          icon: Icons.shopping_bag_outlined,
          color: _kGreen,
          gradientColors: [
            const Color(0xFFE8F5E9),
            Colors.green.withOpacity(0.1)
          ],
        ),
        _StatCard(
          label: 'Total Sales',
          value: totalSales,
          icon: Icons.payments_outlined,
          color: _kGold,
          gradientColors: [
            const Color(0xFFFFF8E1),
            Colors.amber.withOpacity(0.1)
          ],
        ),
        _StatCard(
          label: 'Customers',
          value: customers,
          icon: Icons.people_outline,
          color: _kOrange,
          gradientColors: [
            const Color(0xFFFFF3E0),
            Colors.orange.withOpacity(0.1)
          ],
        ),
      ],
    );
  }

  String _calculateTotalSales(List<BBOrder> orders) {
    return orders.fold(0.0, (sum, o) => sum + o.totalAmount).toStringAsFixed(0);
  }

  Widget _buildEmptyOrders() {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: _kWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kPurpleSoft),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined,
              color: _kTextSub.withOpacity(0.5), size: 64),
          const SizedBox(height: 16),
          Text(
            'No Orders Yet',
            style: TextStyle(
              color: _kTextSub,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Orders will appear here once customers checkout',
            style: TextStyle(
              color: _kTextSub.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stat Card Widget ───────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final List<Color> gradientColors;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: _kText,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _kTextSub,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Animated Order Card ────────────────────────────────────────────────────
class _AnimatedOrderCard extends StatefulWidget {
  final int index;
  final BBOrder order;
  final Function(OrderStatus) onStatusChanged;

  const _AnimatedOrderCard({
    required this.index,
    required this.order,
    required this.onStatusChanged,
  });

  @override
  State<_AnimatedOrderCard> createState() => _AnimatedOrderCardState();
}

class _AnimatedOrderCardState extends State<_AnimatedOrderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Transform.translate(
        offset: Offset(0, _slideAnimation.value),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _OrderCard(
            order: widget.order,
            onStatusChanged: widget.onStatusChanged,
          ),
        ),
      ),
    );
  }
}

// ─── Order Card Widget ──────────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final BBOrder order;
  final Function(OrderStatus) onStatusChanged;

  const _OrderCard({
    required this.order,
    required this.onStatusChanged,
  });

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return _kOrange;
      case OrderStatus.confirmed:
        return _kPurple;
      case OrderStatus.shipped:
        return Colors.blue;
      case OrderStatus.prepared:
        return _kGold;
      case OrderStatus.outForDelivery:
        return Colors.indigo;
      case OrderStatus.delivered:
        return _kGreen;
      case OrderStatus.cancelled:
        return _kRed;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.pending_outlined;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case OrderStatus.shipped:
        return Icons.local_shipping_outlined;
      case OrderStatus.prepared:
        return Icons.inventory_2_outlined;
      case OrderStatus.outForDelivery:
        return Icons.delivery_dining;
      case OrderStatus.delivered:
        return Icons.celebration_outlined;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _kPurple.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_getStatusIcon(order.status),
                    color: statusColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'ORDER #${order.id.substring(0, 8).toUpperCase()}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _kText,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            order.status.displayText.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '\$${order.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _kPurple,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusDropdown(
                currentStatus: order.status,
                onChanged: onStatusChanged,
                statusColor: statusColor,
              ),
            ],
          ),
          if (order.items.isNotEmpty) ...[
            const SizedBox(height: 12),
            Divider(color: _kPurpleSoft, height: 1),
            const SizedBox(height: 8),
            SizedBox(
              height: 32,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: order.items.length > 3 ? 3 : order.items.length,
                itemBuilder: (context, index) {
                  final item = order.items[index];
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: _kPurpleSoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${item.product.name} x${item.quantity}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: _kTextSub,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Status Dropdown Widget ─────────────────────────────────────────────────
class _StatusDropdown extends StatelessWidget {
  final OrderStatus currentStatus;
  final Function(OrderStatus) onChanged;
  final Color statusColor;

  const _StatusDropdown({
    required this.currentStatus,
    required this.onChanged,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: PopupMenuButton<OrderStatus>(
        initialValue: currentStatus,
        offset: const Offset(0, 30),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onSelected: onChanged,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentStatus.displayText,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            Icon(Icons.arrow_drop_down, color: statusColor, size: 18),
          ],
        ),
        itemBuilder: (BuildContext context) => OrderStatus.values.map((status) {
          Color itemColor;
          switch (status) {
            case OrderStatus.prepared:
              itemColor = _kGold;
              break;
            case OrderStatus.outForDelivery:
              itemColor = Colors.indigo;
              break;
            case OrderStatus.confirmed:
              itemColor = _kPurple;
              break;
            case OrderStatus.shipped:
              itemColor = Colors.blue;
              break;
            case OrderStatus.delivered:
              itemColor = _kGreen;
              break;
            case OrderStatus.cancelled:
              itemColor = _kRed;
              break;
            case OrderStatus.pending:
              itemColor = _kOrange;
              break;
          }
          return PopupMenuItem<OrderStatus>(
            value: status,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: itemColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  status.displayText,
                  style: TextStyle(
                    color: itemColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
