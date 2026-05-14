import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../widgets/image_fallback.dart';

// ─── Shared Palette ────────────────────────────────────────────────────────
const _kPurple = Color(0xFF7457A2);
const _kPurpleLight = Color(0xFFEDE7F6);
const _kPurpleSoft = Color(0xFFF3EEFE);
const _kBg = Color(0xFFFAF8FF);
const _kText = Color(0xFF2D1B4E);
const _kTextSub = Color(0xFF8E7BAE);
const _kWhite = Colors.white;
const _kRed = Color(0xFFE57373);
const _kGreen = Color(0xFF81C784);

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final cartItems = appState.cart;
    final subtotal = appState.cartTotal;
    final shipping = subtotal > 0 ? 0.0 : 0.0; // Free shipping
    final total = subtotal + shipping;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: _buildAppBar(context, cartItems.length, appState),
      body: cartItems.isEmpty
          ? _buildEmptyCart(context)
          : _buildFilledCart(
              context, cartItems, subtotal, shipping, total, appState),
    );
  }

  // ─── App Bar ──────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(
      BuildContext context, int itemCount, AppState appState) {
    return AppBar(
      backgroundColor: _kWhite,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: _kText),
        onPressed: () => context.pop(),
      ),
      title: Column(
        children: [
          const Text(
            'MY CART',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _kText,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            '${itemCount} ${itemCount == 1 ? 'item' : 'items'}',
            style: const TextStyle(
              fontSize: 12,
              color: _kTextSub,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        if (itemCount > 0)
          TextButton(
            onPressed: () => _showClearCartDialog(context, appState),
            child: const Text(
              'Clear',
              style: TextStyle(
                color: _kRed,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: _kPurple.withOpacity(0.1),
        ),
      ),
    );
  }

  // ─── Empty Cart Widget ────────────────────────────────────────────────────
  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty Cart Illustration
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: _kPurpleSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 80,
                color: _kPurple,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'YOUR CART IS EMPTY',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _kText,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Explore our collections and add your favourite arrangements.',
              style: TextStyle(
                fontSize: 15,
                color: _kTextSub,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Shop Now Button
            GestureDetector(
              onTap: () => context.go('/discovery'),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_kPurple, Color(0xFF9C6FD6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: _kPurple.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  'SHOP NOW',
                  style: TextStyle(
                    color: _kWhite,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Filled Cart Widget ───────────────────────────────────────────────────
  Widget _buildFilledCart(
    BuildContext context,
    List<CartItem> cartItems,
    double subtotal,
    double shipping,
    double total,
    AppState appState,
  ) {
    return Column(
      children: [
        // Cart Items List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final item = cartItems[index];
              return _CartItemCard(
                item: item,
                onQuantityChanged: (newQuantity) {
                  appState.updateQuantity(item.product, newQuantity);
                },
                onRemove: () {
                  appState.removeFromCart(item.product);
                },
              );
            },
          ),
        ),

        // Order Summary & Checkout
        _buildOrderSummary(context, subtotal, shipping, total, appState),
      ],
    );
  }

  // ─── Order Summary Widget ─────────────────────────────────────────────────
  Widget _buildOrderSummary(
    BuildContext context,
    double subtotal,
    double shipping,
    double total,
    AppState appState,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: _kWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: _kPurple.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
        child: Column(
          children: [
            // Subtotal Row
            _buildSummaryRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
            const SizedBox(height: 12),
            // Shipping Row
            _buildSummaryRow(
              'Shipping',
              shipping == 0 ? 'Free' : '\$${shipping.toStringAsFixed(2)}',
              valueColor: shipping == 0 ? _kGreen : null,
            ),
            const Divider(height: 24, thickness: 1, color: Color(0xFFEEEEEE)),
            // Total Row
            _buildSummaryRow(
              'TOTAL',
              '\$${total.toStringAsFixed(2)}',
              isTotal: true,
            ),
            const SizedBox(height: 24),
            // Proceed to Checkout Button
            GestureDetector(
              onTap: () => context.push('/checkout'),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_kPurple, Color(0xFF9C6FD6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: _kPurple.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'PROCEED TO CHECKOUT',
                    style: TextStyle(
                      color: _kWhite,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isTotal = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isTotal ? _kText : _kTextSub,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20 : 15,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? (isTotal ? _kPurple : _kText),
            letterSpacing: isTotal ? 0 : -0.3,
          ),
        ),
      ],
    );
  }

  // ─── Helper Methods ───────────────────────────────────────────────────────
  void _showClearCartDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Clear Cart?'),
        content: const Text(
            'Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: _kTextSub)),
          ),
          TextButton(
            onPressed: () {
              appState.clearCart();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cart cleared'),
                  backgroundColor: _kPurple,
                ),
              );
            },
            child: const Text('Clear', style: TextStyle(color: _kRed)),
          ),
        ],
      ),
    );
  }

  void _showCheckoutDialog(
      BuildContext context, double total, AppState appState) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _kPurpleSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: _kPurple, size: 32),
              ),
              const SizedBox(height: 20),
              const Text(
                'Order Placed!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _kText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Total: \$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _kPurple,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your flowers will bloom at your doorstep soon.',
                style: TextStyle(color: _kTextSub, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  appState.clearCart();
                  Navigator.pop(ctx);
                  context.go('/');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _kPurple,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                    child: Text(
                      'Continue Shopping',
                      style: TextStyle(
                        color: _kWhite,
                        fontWeight: FontWeight.w700,
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
  }
}

// ─── Cart Item Card Widget ──────────────────────────────────────────────────
class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final itemTotal = product.price * item.quantity;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(20)),
            child: Container(
              width: 100,
              height: 120,
              color: _kPurpleSoft,
              child: product.imageUrl.startsWith('assets/')
                  ? Image.asset(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) =>
                          const ImageFallback(iconSize: 40),
                    )
                  : const ImageFallback(iconSize: 40),
            ),
          ),
          // Product Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _kText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: onRemove,
                        child: const Icon(
                          Icons.close,
                          size: 18,
                          color: _kTextSub,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'BOUTIQUE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: _kTextSub,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Quantity Selector
                      Container(
                        decoration: BoxDecoration(
                          color: _kPurpleSoft,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            _buildQuantityIcon(Icons.remove, () {
                              if (item.quantity > 1) {
                                onQuantityChanged(item.quantity - 1);
                              }
                            }),
                            Container(
                              width: 35,
                              child: Text(
                                '${item.quantity}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _kText,
                                ),
                              ),
                            ),
                            _buildQuantityIcon(Icons.add, () {
                              onQuantityChanged(item.quantity + 1);
                            }),
                          ],
                        ),
                      ),
                      // Price
                      Text(
                        '\$${itemTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _kPurple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 16, color: _kPurple),
      ),
    );
  }
}
