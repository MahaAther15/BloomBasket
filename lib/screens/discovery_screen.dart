import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_state.dart';
import '../models/product.dart';
import '../widgets/image_fallback.dart';

// ─── Shared Palette (matches home_screen.dart) ─────────────────────────────
const _kPurple = Color(0xFF7B5EA7);
const _kPurpleLight = Color(0xFFEDE7F6);
const _kPurpleSoft = Color(0xFFF3EEFE);
const _kBg = Color(0xFFFAF8FF);
const _kText = Color(0xFF2D1B4E);
const _kTextSub = Color(0xFF8E7BAE);
const _kWhite = Colors.white;

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen>
    with SingleTickerProviderStateMixin {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final _searchController = TextEditingController();
  late AnimationController _headerAnim;
  late Animation<double> _headerFade;

  final List<Map<String, dynamic>> _categories = [
    {'label': 'All', 'icon': Icons.apps_rounded},
    {'label': 'Seasonal', 'icon': Icons.wb_sunny_outlined},
    {'label': 'Boutique', 'icon': Icons.storefront_outlined},
    {'label': 'Artisanal', 'icon': Icons.auto_awesome_outlined},
    {'label': 'Rose', 'icon': Icons.local_florist_outlined},
    {'label': 'Tulip', 'icon': Icons.spa_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _headerFade = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
    _headerAnim.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _headerAnim.dispose();
    super.dispose();
  }

  List<Product> _getFilteredProducts(List<Product> products) {
    List<Product> result = _selectedCategory == 'All'
        ? products
        : products.where((p) {
            final cat = _selectedCategory.toLowerCase();
            return p.category.toLowerCase().contains(cat) ||
                p.name.toLowerCase().contains(cat) ||
                p.tags.any((t) => t.toLowerCase().contains(cat));
          }).toList();

    if (_searchQuery.isNotEmpty) {
      final words = _searchQuery.toLowerCase().trim().split(' ');
      result = result.where((p) {
        return words.every(
          (word) =>
              p.name.toLowerCase().contains(word) ||
              p.description.toLowerCase().contains(word) ||
              p.category.toLowerCase().contains(word) ||
              p.tags.any((tag) => tag.toLowerCase().contains(word)),
        );
      }).toList();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final filteredProducts = _getFilteredProducts(appState.products);

    return Scaffold(
      backgroundColor: _kBg,
      bottomNavigationBar: _buildBottomNav(context),
      body: SafeArea(
        child: Column(
          children: [
            // ── Gradient header ──────────────────────────────
            FadeTransition(
              opacity: _headerFade,
              child: _buildHeader(context),
            ),
            // ── Category chips ───────────────────────────────
            _buildCategoryChips(),
            const SizedBox(height: 4),
            // ── Results count bar ────────────────────────────
            _buildResultsBar(filteredProducts.length),
            // ── Grid ─────────────────────────────────────────
            Expanded(
              child: filteredProducts.isEmpty
                  ? _buildEmptyState()
                  : _buildGrid(filteredProducts),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header with gradient + search ─────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF9C6FD6), Color(0xFF7B5EA7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: back-less title + cart
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Discover',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: _kWhite,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Find your perfect bloom ✨',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              // Cart button
              GestureDetector(
                onTap: () => context.go('/cart'),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_cart_outlined,
                    color: _kWhite,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Search bar
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: _kWhite,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                const Icon(Icons.search, color: _kTextSub, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: const TextStyle(fontSize: 14, color: _kText),
                    decoration: InputDecoration(
                      hintText: _selectedCategory == 'All'
                          ? 'Search all flowers...'
                          : 'Search in $_selectedCategory...',
                      hintStyle:
                          const TextStyle(color: _kTextSub, fontSize: 14),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(Icons.close, color: _kTextSub, size: 18),
                    ),
                  )
                else
                  Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: _kPurple,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.tune, color: _kWhite, size: 16),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Category chips ─────────────────────────────────────────
  Widget _buildCategoryChips() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        height: 44,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _categories.length,
          itemBuilder: (context, i) {
            final cat = _categories[i];
            final label = cat['label'] as String;
            final icon = cat['icon'] as IconData;
            final isActive = _selectedCategory == label;

            return GestureDetector(
              onTap: () => setState(() {
                _selectedCategory = label;
                _searchQuery = '';
                _searchController.clear();
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? _kPurple : _kWhite,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color:
                        isActive ? _kPurple : _kPurple.withOpacity(0.25),
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: _kPurple.withOpacity(0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ],
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: 14,
                      color: isActive ? _kWhite : _kTextSub,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isActive ? _kWhite : _kTextSub,
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

  // ── Results count bar ──────────────────────────────────────
  Widget _buildResultsBar(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: _kPurple,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count ${count == 1 ? 'result' : 'results'} found',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _kText,
            ),
          ),
          const Spacer(),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _kPurpleLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Clear',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _kPurple,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Grid ───────────────────────────────────────────────────
  Widget _buildGrid(List<Product> products) {
    return LayoutBuilder(builder: (context, constraints) {
      int crossAxisCount = 2;
      if (constraints.maxWidth > 1200) {
        crossAxisCount = 5;
      } else if (constraints.maxWidth > 900) {
        crossAxisCount = 4;
      } else if (constraints.maxWidth > 600) {
        crossAxisCount = 3;
      }

      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.68,
          crossAxisSpacing: 14,
          mainAxisSpacing: 16,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return _DiscoveryProductCard(
            product: product,
            onTap: () => context.push('/product/${product.id}'),
          );
        },
      );
    });
  }

  // ── Empty state ─────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: _kPurpleLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 40,
              color: _kPurple,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No flowers found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _kText,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try a different search or category',
            style: TextStyle(fontSize: 13, color: _kTextSub),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = 'All';
                _searchQuery = '';
                _searchController.clear();
              });
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: _kPurple,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: _kPurple.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                'Clear Filters',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _kWhite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Nav ─────────────────────────────────────────────
  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kWhite,
        boxShadow: [
          BoxShadow(
            color: _kPurple.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: 1,
        onTap: (i) {
          switch (i) {
            case 0:
              context.go('/');
              break;
            case 1:
              break;
            case 2:
              context.go('/cart');
              break;
            case 3:
              context.go('/profile');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: _kWhite,
        selectedItemColor: _kPurple,
        unselectedItemColor: _kTextSub,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 24),
            activeIcon: Icon(Icons.home_rounded, size: 24),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, size: 24),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined, size: 24),
            activeIcon: Icon(Icons.shopping_cart_rounded, size: 24),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 24),
            activeIcon: Icon(Icons.person, size: 24),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ─── Discovery Product Card ─────────────────────────────────────────────────
class _DiscoveryProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;

  const _DiscoveryProductCard({required this.product, required this.onTap});

  @override
  State<_DiscoveryProductCard> createState() => _DiscoveryProductCardState();
}

class _DiscoveryProductCardState extends State<_DiscoveryProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _scaleCtrl;
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _scaleCtrl.reverse(),
        onTapUp: (_) {
          _scaleCtrl.forward();
          widget.onTap();
        },
        onTapCancel: () => _scaleCtrl.forward(),
        child: Container(
          decoration: BoxDecoration(
            color: _kWhite,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _kPurple.withOpacity(0.1),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image ──────────────────────────────────────
              Expanded(
                flex: 6,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(18)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Soft bg
                      Container(color: _kPurpleSoft),
                      // Product image
                      product.imageUrl.startsWith('assets/')
                          ? Image.asset(
                              product.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) =>
                                  const ImageFallback(iconSize: 36),
                            )
                          : const ImageFallback(iconSize: 36),
                      // Favourite heart
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: _kWhite.withOpacity(0.92),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite_border,
                            color: _kPurple,
                            size: 15,
                          ),
                        ),
                      ),
                      // Category tag
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _kPurple.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            product.category,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: _kWhite,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // ── Info ───────────────────────────────────────
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _kText,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${product.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: _kPurple,
                            ),
                          ),
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: _kPurple,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: _kWhite,
                              size: 16,
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
        ),
      ),
    );
  }
}
