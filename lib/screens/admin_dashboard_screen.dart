import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_state.dart';
import '../models/order.dart';
import '../models/product.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  // Botanical Palette
  static const Color primaryPurple = Color(0xFF7457A2);
  static const Color accentGold = Color(0xFFF7C948);
  static const Color darkBg = Color(0xFFF8F6FF);
  static const Color surfaceColor = Colors.white;

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isMobile = MediaQuery.of(context).size.width < 900;
    
    return Scaffold(
      backgroundColor: AdminDashboardScreen.darkBg,
      drawer: isMobile ? _buildDrawer(context) : null,
      appBar: isMobile ? AppBar(
        backgroundColor: AdminDashboardScreen.surfaceColor,
        title: Text('ADMIN DASHBOARD', style: GoogleFonts.orbitron(fontSize: 12, color: AdminDashboardScreen.primaryPurple)),
        iconTheme: const IconThemeData(color: AdminDashboardScreen.primaryPurple),
      ) : null,
      floatingActionButton: _selectedIndex == 1 ? FloatingActionButton(
        backgroundColor: AdminDashboardScreen.accentGold,
        onPressed: () => _showAddProductDialog(context, appState),
        child: const Icon(Icons.add, color: AdminDashboardScreen.darkBg),
      ) : null,
      body: Row(
        children: [
          // Sidebar (only on Desktop)
          if (!isMobile) _buildSidebar(context),
          
          // Main Content
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                _buildDashboardView(appState, isMobile),
                _buildProductsView(appState, isMobile),
                _buildOrdersView(appState, isMobile),
                _buildAnalyticsView(appState, isMobile),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardView(AppState appState, bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('SYSTEM OVERVIEW', 'REAL-TIME PERFORMANCE METRICS', isMobile),
          const SizedBox(height: 32),
          _buildStatsGrid(appState, isMobile),
          const SizedBox(height: 32),
          _buildRecentOrders(appState, isMobile),
        ],
      ),
    );
  }

  Widget _buildProductsView(AppState appState, bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('PRODUCT INVENTORY', 'MANAGE YOUR BLOOMS', isMobile),
          const SizedBox(height: 32),
          if (appState.products.isEmpty)
            _buildEmptyState('NO PRODUCTS IN INVENTORY')
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: appState.products.length,
              itemBuilder: (context, index) {
                final p = appState.products[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AdminDashboardScreen.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AdminDashboardScreen.darkBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.local_florist, color: AdminDashboardScreen.accentGold),
                    ),
                    title: Text(p.name, style: GoogleFonts.orbitron(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: Text(p.category, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11)),
                    trailing: Text('\$${p.price.toInt()}', style: GoogleFonts.orbitron(color: AdminDashboardScreen.accentGold, fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildOrdersView(AppState appState, bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('ORDER MANAGEMENT', 'TRACK ALL CUSTOMER REQUESTS', isMobile),
          const SizedBox(height: 32),
          if (appState.orders.isEmpty)
            _buildEmptyState('NO ORDERS PENDING')
          else
            ...appState.orders.map((o) => _OrderCard(order: o, isMobile: isMobile, onStatusChanged: (s) {})),
        ],
      ),
    );
  }

  Widget _buildAnalyticsView(AppState appState, bool isMobile) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 64, color: AdminDashboardScreen.primaryPurple.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('ANALYTICS ENGINE LOADING...', style: GoogleFonts.orbitron(color: Colors.white24)),
        ],
      ),
    );
  }

  void _showAddProductDialog(BuildContext context, AppState appState) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminDashboardScreen.surfaceColor,
        title: Text('ADD NEW BLOOM', style: GoogleFonts.orbitron(color: AdminDashboardScreen.primaryPurple, fontSize: 14)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('FLOWER NAME'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('PRICE (\$)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: categoryController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('CATEGORY'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: TextStyle(color: Colors.white.withOpacity(0.5))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AdminDashboardScreen.primaryPurple),
            onPressed: () {
              if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                final newProduct = Product(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  description: 'New artisanal flower arrangement.',
                  price: double.tryParse(priceController.text) ?? 0.0,
                  imageUrl: 'assets/images/flower.png',
                  category: categoryController.text,
                  tags: ['Admin', 'New'],
                );
                appState.addProduct(newProduct);
                Navigator.pop(context);
              }
            },
            child: const Text('ADD TO SHOP', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AdminDashboardScreen.primaryPurple.withOpacity(0.5), fontSize: 10),
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AdminDashboardScreen.primaryPurple.withOpacity(0.2))),
      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AdminDashboardScreen.primaryPurple)),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 260,
      color: Colors.white,
      child: _SidebarContent(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          print("Admin Sidebar Clicked: $index");
          setState(() => _selectedIndex = index);
        },
        onLogout: () => context.go('/'),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: _SidebarContent(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          print("Admin Drawer Clicked: $index");
          setState(() => _selectedIndex = index);
          Navigator.pop(context);
        },
        onLogout: () => context.go('/'),
      ),
    );
  }

  Widget _buildHeader(String title, String sub, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.orbitron(
            color: AdminDashboardScreen.primaryPurple,
            fontSize: isMobile ? 18 : 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          sub,
          style: GoogleFonts.orbitron(
            color: AdminDashboardScreen.primaryPurple.withOpacity(0.5),
            fontSize: isMobile ? 8 : 10,
            letterSpacing: isMobile ? 2 : 4,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(AppState appState, bool isMobile) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isMobile ? 2 : 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _AdminStatCard(label: 'TOTAL REVENUE', value: '\$${appState.totalRevenue.toInt()}', color: AdminDashboardScreen.accentGold),
        _AdminStatCard(label: 'ACTIVE ORDERS', value: '${appState.orders.length}', color: Colors.blue),
        _AdminStatCard(label: 'PRODUCTS', value: '${appState.products.length}', color: Colors.green),
        _AdminStatCard(label: 'CUSTOMERS', value: '1.2K', color: Colors.purple),
      ],
    );
  }

  Widget _buildRecentOrders(AppState appState, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'RECENT LOGS',
              style: GoogleFonts.orbitron(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
            TextButton(
              onPressed: () => setState(() => _selectedIndex = 2),
              child: Text('VIEW ALL', style: GoogleFonts.orbitron(color: AdminDashboardScreen.accentGold, fontSize: 10)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (appState.orders.isEmpty) _buildEmptyState('NO DATA STREAM DETECTED')
        else
          ...appState.orders.take(5).map((order) => _OrderCard(
                order: order,
                isMobile: isMobile,
                onStatusChanged: (s) {},
              )),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AdminDashboardScreen.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.data_array, color: Colors.white.withOpacity(0.2), size: 64),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.orbitron(color: Colors.white24, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _SidebarContent extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final VoidCallback onLogout;
  
  const _SidebarContent({
    required this.selectedIndex,
    required this.onTap,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        _SidebarItem(icon: Icons.dashboard, label: 'DASHBOARD', isActive: selectedIndex == 0, onTap: () => onTap(0)),
        _SidebarItem(icon: Icons.inventory_2, label: 'PRODUCTS', isActive: selectedIndex == 1, onTap: () => onTap(1)),
        _SidebarItem(icon: Icons.shopping_basket, label: 'ORDERS', isActive: selectedIndex == 2, onTap: () => onTap(2)),
        _SidebarItem(icon: Icons.analytics, label: 'ANALYTICS', isActive: selectedIndex == 3, onTap: () => onTap(3)),
        const Spacer(),
        _SidebarItem(
          icon: Icons.logout, 
          label: 'LOGOUT', 
          isActive: false, 
          onTap: onLogout,
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _AdminStatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminDashboardScreen.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            child: Text(
              label,
              style: GoogleFonts.orbitron(color: color.withOpacity(0.7), fontSize: 8, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              value,
              style: GoogleFonts.orbitron(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final BBOrder order;
  final bool isMobile;
  final Function(OrderStatus) onStatusChanged;

  const _OrderCard({
    required this.order,
    required this.isMobile,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminDashboardScreen.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AdminDashboardScreen.primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.receipt_long, color: AdminDashboardScreen.primaryPurple, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ORDER #${order.id.substring(0, 8).toUpperCase()}',
                  style: GoogleFonts.orbitron(color: AdminDashboardScreen.primaryPurple, fontSize: 10, fontWeight: FontWeight.bold),
                ),
                Text(
                  order.customerName ?? 'Guest',
                  style: TextStyle(color: AdminDashboardScreen.primaryPurple.withOpacity(0.5), fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${order.totalAmount.toInt()}',
                style: GoogleFonts.orbitron(
                  color: AdminDashboardScreen.accentGold, 
                  fontSize: 14, 
                  fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 4),
              _StatusChip(status: order.status),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final OrderStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = AdminDashboardScreen.primaryPurple;
    if (status == OrderStatus.confirmed) color = AdminDashboardScreen.accentGold;
    if (status == OrderStatus.delivered) color = Colors.green;
    if (status == OrderStatus.cancelled) color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.toString().split('.').last.toUpperCase(),
        style: GoogleFonts.orbitron(color: color, fontSize: 7, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: isActive ? AdminDashboardScreen.accentGold : AdminDashboardScreen.primaryPurple.withOpacity(0.3)),
      title: Text(
        label,
        style: GoogleFonts.orbitron(
          color: isActive ? AdminDashboardScreen.primaryPurple : AdminDashboardScreen.primaryPurple.withOpacity(0.3),
          fontSize: 12,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          letterSpacing: 2,
        ),
      ),
      selected: isActive,
    );
  }
}
