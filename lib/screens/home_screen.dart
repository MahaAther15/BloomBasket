import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../app_theme.dart';
import '../providers/app_state.dart';
import '../widgets/product_card.dart';
import '../widgets/flower_button.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/image_fallback.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isMediumScreen = screenSize.width >= 600 && screenSize.width < 900;
    final isLargeScreen = screenSize.width >= 900;

    final filteredProducts = _selectedCategory == 'All'
        ? appState.products
        : appState.products.where((p) => p.category == _selectedCategory).toList();

    final double heroHeight = isSmallScreen ? 300.0 : (isMediumScreen ? 350.0 : 420.0);

    Widget hero = SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppTheme.pastelBg, Colors.white],
              ),
            ),
            child: Image.asset(
              'assets/images/blackrose.webp',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const ImageFallback(iconSize: 64),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.28), Colors.transparent],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ephemeral\nBeauty',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppTheme.pastelText,
                        fontSize: isSmallScreen ? 32 : (isMediumScreen ? 40 : 48),
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: isSmallScreen ? 8 : 12),
                Text(
                  'ARTISANAL ARRANGEMENTS FOR THE DISCERNING',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppTheme.pastelText.withOpacity(0.7),
                        letterSpacing: 1.2,
                        fontSize: isSmallScreen ? 10 : 12,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    Widget content = SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          _OffersSlider(height: isSmallScreen ? 150 : (isMediumScreen ? 180 : 200)),
          const SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 24),
            child: Text(
              'COLLECTIONS',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppTheme.richGold,
                    letterSpacing: 2,
                  ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: isSmallScreen ? 36 : 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 20),
              children: ['All', 'Seasonal', 'Boutique', 'Artisanal'].map((cat) {
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: _CategoryChip(label: cat, isActive: _selectedCategory == cat, isSmallScreen: isSmallScreen),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 20),
            child: LayoutBuilder(builder: (context, constraints) {
              int crossAxisCount = 2;
              if (constraints.maxWidth > 1200) crossAxisCount = 5;
              else if (constraints.maxWidth > 900) crossAxisCount = 4;
              else if (constraints.maxWidth > 600) crossAxisCount = 3;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.66,
                ),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  return ProductCard(product: product, onTap: () => context.push('/product/${product.id}'));
                },
              );
            }),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: AppTheme.pastelBg,
      floatingActionButton: kDebugMode
          ? FlowerButton(size: 64, assetImage: 'assets/images/flower1.jfif', onPressed: () => context.go('/admin'))
          : null,
      appBar: AppBar(
        title: Text(
          isSmallScreen ? 'FLORAL ATELIER' : 'THE FLORAL ATELIER',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(letterSpacing: isSmallScreen ? 2 : 4, fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppTheme.pastelBg,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.shopping_bag_outlined), onPressed: () => context.push('/cart')),
          if (kDebugMode)
            IconButton(icon: const Icon(Icons.admin_panel_settings), tooltip: 'Admin (debug)', onPressed: () => context.go('/admin')),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              final appState = Provider.of<AppState>(context, listen: false);
              await appState.signOut();
              if (context.mounted) context.go('/signin');
            },
          ),
        ],
      ),
      bottomNavigationBar: const BotanicalBottomNavBar(currentIndex: 0),
      body: isLargeScreen
          ? Row(
              children: [
                Expanded(flex: 4, child: hero),
                Expanded(flex: 6, child: Padding(padding: const EdgeInsets.all(16.0), child: content)),
              ],
            )
          : SingleChildScrollView(child: Column(children: [hero, const SizedBox(height: 12), content])),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isSmallScreen;

  const _CategoryChip({required this.label, this.isActive = false, this.isSmallScreen = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: isSmallScreen ? 8 : 12),
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 18, vertical: isSmallScreen ? 6 : 10),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryGreen : Colors.transparent,
        border: Border.all(color: isActive ? AppTheme.primaryGreen : AppTheme.outline.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Center(
        child: Text(label.toUpperCase(), style: Theme.of(context).textTheme.labelLarge?.copyWith(color: isActive ? Colors.white : AppTheme.primaryGreen)),
      ),
    );
  }
}

class _OffersSlider extends StatefulWidget {
  final double height;
  const _OffersSlider({this.height = 180, super.key});

  @override
  State<_OffersSlider> createState() => _OffersSliderState();
}

class _OffersSliderState extends State<_OffersSlider> {
  late final PageController _controller;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = [
      'assets/images/offer1.webp',
      'assets/images/offer2.webp',
      'assets/images/offer3.webp',
      'assets/images/offer4.webp',
    ];

    return SizedBox(
      height: widget.height,
      child: PageView.builder(
        controller: _controller,
        itemCount: images.length,
        onPageChanged: (i) => setState(() => _page = i),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(images[index], fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.grey[300])),
            ),
          );
        },
      ),
    );
  }
}
