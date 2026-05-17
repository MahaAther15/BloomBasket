import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_state.dart';
import '../models/product.dart';
import '../widgets/image_fallback.dart';

// ─── Shared Palette ────────────────────────────────────────────────────────
const _kPurple = Color(0xFF7457A2); // Updated primary color
const _kBgGrey = Color(0xFFF7F7F7);
const _kText = Color(0xFF2D1B4E);
const _kTextSub = Color(0xFF8E7BAE);
const _kWhite = Colors.white;
const _kYellow = Color(0xFFFFD54F); // For star rating

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  bool _isDescriptionExpanded = false;

  Future<void> _launchDiscord() async {
    final Uri url = Uri.parse('https://discord.gg/your-invite-link');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch Discord')),
        );
      }
    }
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final product = appState.products.firstWhere(
      (p) => p.id == widget.productId,
      orElse: () => Product(
        id: 'error',
        name: 'Product Not Found',
        description: '',
        price: 0,
        imageUrl: '',
        category: '',
        tags: [],
      ),
    );

    if (product.id == 'error') {
      return const Scaffold(body: Center(child: Text('Product not found')));
    }

    final isFav = appState.isFavorite(product);

    return Scaffold(
      backgroundColor: _kWhite,
      body: Stack(
        children: [
          // ── Main Content ─────────────────────────────────────────
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Image Header (Flower image with gradient overlay)
                _buildImageHeader(product),

                // 2. Product Info
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: _kText,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Subtitle / Flower type
                      Text(
                        "Tied Ribbon Tulip Flower",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: _kTextSub,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Rating Stars
                      Row(
                        children: [
                          ...List.generate(
                              5,
                              (index) => const Icon(Icons.star,
                                  color: _kYellow, size: 20)),
                          const SizedBox(width: 8),
                          const Text(
                            "5.0",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: _kText,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            " (120 reviews)",
                            style: TextStyle(
                              color: _kTextSub,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Description with "Read more"
                      _buildDescription(product),
                      const SizedBox(height: 24),

                      // Seller Info (Florist & Designer)
                      _buildSellerSection(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Top Nav ──────────────────────────────────────────────
          _buildTopNav(context, isFav, product, appState),

          // ── Bottom Action ────────────────────────────────────────
          _buildBottomAction(product, appState),
        ],
      ),
    );
  }

  // ── Image Header with Gradient Overlay (like the image) ─────────────────────────
  Widget _buildImageHeader(Product product) {
    return Container(
      width: double.infinity,
      height: 420,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _kPurple.withOpacity(0.3),
            Colors.white.withOpacity(0.95),
          ],
          stops: const [0.0, 0.6],
        ),
      ),
      child: Center(
        child: Hero(
          tag: 'product_${product.id}',
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 60, 30, 40),
            child: product.imageUrl.startsWith('assets/')
                ? Image.asset(
                    product.imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) =>
                        const ImageFallback(iconSize: 100),
                  )
                : const ImageFallback(iconSize: 100),
          ),
        ),
      ),
    );
  }

  // ── Description Widget ────────────────────────────────────────
  Widget _buildDescription(Product product) {
    // Use the description from the image
    final descriptionText = product.description.isNotEmpty
        ? product.description
        : "Yellow tulips represent happiness, cheerfulness, and hope. Victorians even believed yellow tulips literally meant, \"there's sunshine in your smile.\"";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () =>
              setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: _isDescriptionExpanded
                      ? descriptionText
                      : (descriptionText.length > 150
                          ? '${descriptionText.substring(0, 150)}...'
                          : descriptionText),
                  style: const TextStyle(
                    color: _kTextSub,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                if (descriptionText.length > 150)
                  TextSpan(
                    text: _isDescriptionExpanded ? " Read less" : " Read more",
                    style: const TextStyle(
                      color: _kPurple,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Seller Section (Florist & Designer) ────────────────────────────────────────
  Widget _buildSellerSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kBgGrey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _kWhite,
              shape: BoxShape.circle,
              border: Border.all(color: _kPurple.withOpacity(0.2), width: 2),
            ),
            child: const Center(
              child: Icon(Icons.person, color: _kPurple, size: 28),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Jacob Doe",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: _kText,
                  ),
                ),
                Text(
                  "Florist & Designer",
                  style: TextStyle(color: _kTextSub, fontSize: 13),
                ),
              ],
            ),
          ),
          // Discord Connect Button
          GestureDetector(
            onTap: _launchDiscord,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF5865F2), // Discord Blue
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5865F2).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.discord, color: _kWhite, size: 18),
                  SizedBox(width: 8),
                  Text(
                    "Connect",
                    style: TextStyle(
                      color: _kWhite,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Top Nav ──────────────────────────────────────────────────────
  Widget _buildTopNav(
      BuildContext context, bool isFav, Product product, AppState appState) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCircularBtn(
            icon: Icons.arrow_back,
            onTap: () => context.pop(),
          ),
          Row(
            children: [
              _buildCircularBtn(
                icon: isFav ? Icons.favorite : Icons.favorite_border,
                iconColor: isFav ? Colors.red : _kText,
                onTap: () => appState.toggleFavorite(product),
              ),
              const SizedBox(width: 12),
              _buildCircularBtn(
                icon: Icons.share_outlined,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircularBtn(
      {required IconData icon, Color? iconColor, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _kWhite,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor ?? _kText, size: 20),
      ),
    );
  }

  // ── Bottom Action ────────────────────────────────────────────────
  Widget _buildBottomAction(Product product, AppState appState) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
        decoration: BoxDecoration(
          color: _kWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Quantity Selector
            Container(
              decoration: BoxDecoration(
                color: _kBgGrey,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  _buildQuantityButton(Icons.remove, _decrementQuantity),
                  Container(
                    width: 45,
                    child: Text(
                      '$_quantity',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _kText,
                      ),
                    ),
                  ),
                  _buildQuantityButton(Icons.add, _incrementQuantity),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Add to Cart Button
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (!appState.isAuthenticated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                        content: Text('Please sign in before adding items to your cart.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    context.go('/signin');
                    return;
                  }

                  final cartItemIndex = appState.cart.indexWhere(
                    (item) => item.product.id == product.id,
                  );

                  if (cartItemIndex >= 0) {
                    appState.updateQuantity(
                      product,
                      appState.cart[cartItemIndex].quantity + _quantity,
                    );
                  } else {
                    appState.addToCart(product);
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: _kPurple,
                      behavior: SnackBarBehavior.floating,
                      content: const Text('Added to cart'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: _kPurple,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: _kPurple.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "ADD TO CART",
                      style: TextStyle(
                        color: _kWhite,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
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

  Widget _buildQuantityButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _kWhite,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, color: _kPurple, size: 20),
      ),
    );
  }
}
