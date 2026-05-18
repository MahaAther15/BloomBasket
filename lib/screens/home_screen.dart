import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_state.dart';
import '../widgets/image_fallback.dart';
import '../models/product.dart';

// ─── Palette ──────────────────────────────────────────────
const _kPurple = Color(0xFF7B5EA7);
const _kPurpleLight = Color(0xFFEDE7F6);
const _kPurpleSoft = Color(0xFFF3EEFE);
const _kAccent = Color(0xFF9C6FD6);
const _kBg = Color(0xFFFAF8FF);
const _kText = Color(0xFF2D1B4E);
const _kTextSub = Color(0xFF8E7BAE);
const _kGold = Color(0xFFF7C948);
const _kWhite = Colors.white;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentLocation = 'Detecting Location...';
  String _selectedCategory = 'All';
  final _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Jasmine',
    'Rose',
    'Daisy',
    'Tulip',
  ];

  @override
  void initState() {
    super.initState();
    _detectLocation();
  }

  Future<void> _detectLocation() async {
    // Simulate location detection
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _currentLocation = 'Faisalabad, Pakistan';
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final filteredProducts = _selectedCategory == 'All'
        ? appState.products
        : appState.products.where((p) {
            final cat = _selectedCategory.toLowerCase();
            return p.category.toLowerCase().contains(cat) ||
                p.name.toLowerCase().contains(cat) ||
                p.tags.any((t) => t.toLowerCase().contains(cat));
          }).toList();

    return Scaffold(
      backgroundColor: _kBg,
      floatingActionButton: null,
      bottomNavigationBar: const _BloomBottomNav(currentIndex: 0),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive scaling factor based on screen width
            final screenWidth = MediaQuery.of(context).size.width;
            final scaleFactor = (screenWidth / 375).clamp(0.8, 1.2);

            final bottomNavHeight = 85 * scaleFactor;
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomNavHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(appState, scaleFactor),
                    _buildSearchBar(scaleFactor),
                    _buildOfferBanner(scaleFactor),
                    _buildCategoriesSection(scaleFactor),
                    _buildTrendingSection(filteredProducts, scaleFactor),
                    _buildBespokeSection(scaleFactor),
                    _buildOccasionSection(appState.products, scaleFactor),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Header (Responsive) ──────────────────────────────────────────────
  Widget _buildHeader(AppState appState, double scaleFactor) {
    final user = appState.user;
    final name = user?.displayName ?? user?.email?.split('@').first ?? 'Guest';

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20 * scaleFactor, 16 * scaleFactor, 20 * scaleFactor, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi, $name 👋',
                  style: TextStyle(
                    fontSize: 18 * scaleFactor,
                    fontWeight: FontWeight.w800,
                    color: _kText,
                    fontFamily: 'sans-serif',
                  ),
                ),
                SizedBox(height: 4 * scaleFactor),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 14 * scaleFactor, color: _kPurple),
                    SizedBox(width: 3 * scaleFactor),
                    Text(
                      '$_currentLocation ▾',
                      style: TextStyle(
                        fontSize: 12 * scaleFactor,
                        fontWeight: FontWeight.w600,
                        color: _kTextSub,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => appState.isAuthenticated
                ? context.go('/profile')
                : context.go('/signin'),
            child: Container(
              width: 48 * scaleFactor,
              height: 48 * scaleFactor,
              decoration: BoxDecoration(
                color: _kWhite,
                shape: BoxShape.circle,
                border: Border.all(color: _kPurple.withOpacity(0.15)),
                boxShadow: [
                  BoxShadow(
                    color: _kPurple.withOpacity(0.15),
                    blurRadius: 12 * scaleFactor,
                    offset: Offset(0, 4 * scaleFactor),
                  ),
                ],
              ),
              child: ClipOval(
                child: user?.photoURL != null
                    ? Image.network(user!.photoURL!)
                    : Icon(Icons.person_rounded,
                        color: _kPurple, size: 28 * scaleFactor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Search (Responsive) ──────────────────────────────────────────────
  Widget _buildSearchBar(double scaleFactor) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20 * scaleFactor, 14 * scaleFactor, 20 * scaleFactor, 0),
      child: Container(
        height: 48 * scaleFactor,
        decoration: BoxDecoration(
          color: _kWhite,
          borderRadius: BorderRadius.circular(24 * scaleFactor),
          boxShadow: [
            BoxShadow(
              color: _kPurple.withOpacity(0.08),
              blurRadius: 16 * scaleFactor,
              offset: Offset(0, 4 * scaleFactor),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(width: 16 * scaleFactor),
            Icon(Icons.search, color: _kTextSub, size: 20 * scaleFactor),
            SizedBox(width: 10 * scaleFactor),
            Expanded(
              child: TextField(
                controller: _searchController,
                style: TextStyle(
                  fontSize: 14 * scaleFactor,
                  color: _kText,
                ),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle:
                      TextStyle(color: _kTextSub, fontSize: 14 * scaleFactor),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            Container(
              width: 36 * scaleFactor,
              height: 36 * scaleFactor,
              margin: EdgeInsets.only(right: 6 * scaleFactor),
              decoration: BoxDecoration(
                color: _kPurple,
                borderRadius: BorderRadius.circular(18 * scaleFactor),
              ),
              child: Icon(Icons.mic, color: _kWhite, size: 18 * scaleFactor),
            ),
          ],
        ),
      ),
    );
  }

  // ── Offer Banner (Responsive) ─────────────────────────────────────────
  Widget _buildOfferBanner(double scaleFactor) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20 * scaleFactor, 18 * scaleFactor, 20 * scaleFactor, 0),
      child: _OfferBannerSlider(scaleFactor: scaleFactor),
    );
  }

  // ── Categories (Responsive) ───────────────────────────────────────────
  Widget _buildCategoriesSection(double scaleFactor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20 * scaleFactor, 20 * scaleFactor,
              20 * scaleFactor, 12 * scaleFactor),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categories',
                style: TextStyle(
                  fontSize: 16 * scaleFactor,
                  fontWeight: FontWeight.w700,
                  color: _kText,
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/discovery'),
                child: Text(
                  'See All',
                  style: TextStyle(
                    fontSize: 13 * scaleFactor,
                    color: _kPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 40 * scaleFactor,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20 * scaleFactor),
            itemCount: _categories.length,
            itemBuilder: (context, i) {
              final cat = _categories[i];
              final isActive = _selectedCategory == cat;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(right: 10 * scaleFactor),
                  padding: EdgeInsets.symmetric(horizontal: 18 * scaleFactor),
                  decoration: BoxDecoration(
                    color: isActive ? _kPurple : _kWhite,
                    borderRadius: BorderRadius.circular(20 * scaleFactor),
                    border: Border.all(
                      color: isActive ? _kPurple : _kPurple.withOpacity(0.25),
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: _kPurple.withOpacity(0.3),
                              blurRadius: 10 * scaleFactor,
                              offset: Offset(0, 4 * scaleFactor),
                            )
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 13 * scaleFactor,
                        fontWeight: FontWeight.w600,
                        color: isActive ? _kWhite : _kTextSub,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Trending Section (Responsive) ─────────────────────────────────────
  Widget _buildTrendingSection(List<Product> products, double scaleFactor) {
    final cardWidth = 140 * scaleFactor;
    final cardMargin = 14 * scaleFactor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20 * scaleFactor, 22 * scaleFactor,
              20 * scaleFactor, 14 * scaleFactor),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trending Now',
                style: TextStyle(
                  fontSize: 16 * scaleFactor,
                  fontWeight: FontWeight.w700,
                  color: _kText,
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/discovery'),
                child: Text(
                  'See All',
                  style: TextStyle(
                    fontSize: 13 * scaleFactor,
                    color: _kPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 230 * scaleFactor,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20 * scaleFactor),
            itemCount: products.length > 8 ? 8 : products.length,
            itemBuilder: (context, i) {
              final product = products[i];
              return _TrendingCard(
                product: product,
                scaleFactor: scaleFactor,
                onTap: () => context.push('/product/${product.id}'),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Bespoke Section (Customization) ───────────────────────────────────
  Widget _buildBespokeSection(double scaleFactor) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20 * scaleFactor, 22 * scaleFactor, 20 * scaleFactor, 0),
      child: GestureDetector(
        onTap: () => context.push('/customize'),
        child: Container(
          height: 120 * scaleFactor,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20 * scaleFactor),
            gradient: const LinearGradient(
              colors: [Color(0xFF2D1B4E), Color(0xFF7B5EA7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: _kPurple.withOpacity(0.3),
                blurRadius: 15 * scaleFactor,
                offset: Offset(0, 8 * scaleFactor),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20 * scaleFactor,
                bottom: -20 * scaleFactor,
                child: Opacity(
                  opacity: 0.2,
                  child: Icon(Icons.auto_awesome,
                      size: 140 * scaleFactor, color: Colors.white),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20 * scaleFactor),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'BESPOKE COLLECTION',
                            style: TextStyle(
                              color: _kGold,
                              fontSize: 10 * scaleFactor,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            ),
                          ),
                          SizedBox(height: 4 * scaleFactor),
                          Text(
                            'Design Your Own\nBouquet or Basket',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18 * scaleFactor,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10 * scaleFactor),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_forward_ios,
                          size: 14 * scaleFactor, color: _kPurple),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Occasion Section (Responsive) ─────────────────────────────────────
  Widget _buildOccasionSection(List<Product> products, double scaleFactor) {
    final ocProducts = products.length > 8
        ? products.sublist(8, products.length > 16 ? 16 : products.length)
        : products;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20 * scaleFactor, 22 * scaleFactor,
              20 * scaleFactor, 14 * scaleFactor),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Occasion Picks',
                style: TextStyle(
                  fontSize: 16 * scaleFactor,
                  fontWeight: FontWeight.w700,
                  color: _kText,
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/discovery'),
                child: Text(
                  'See All',
                  style: TextStyle(
                    fontSize: 13 * scaleFactor,
                    color: _kPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 230 * scaleFactor,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20 * scaleFactor),
            itemCount: ocProducts.length > 8 ? 8 : ocProducts.length,
            itemBuilder: (context, i) {
              final product = ocProducts[i];
              return _TrendingCard(
                product: product,
                scaleFactor: scaleFactor,
                onTap: () => context.push('/product/${product.id}'),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Offer Banner Slider (Responsive) ───────────────────────────────────
class _OfferBannerSlider extends StatefulWidget {
  final double scaleFactor;
  const _OfferBannerSlider({required this.scaleFactor});

  @override
  State<_OfferBannerSlider> createState() => _OfferBannerSliderState();
}

class _OfferBannerSliderState extends State<_OfferBannerSlider> {
  final _pageController = PageController();
  int _page = 0;
  Timer? _timer;

  final List<_BannerData> _banners = const [
    _BannerData(
      label: 'Special Offers',
      headline: 'Get 40% Off Discount',
      buttonText: 'Get Now',
      image: 'assets/images/offer1.png',
      gradientStart: Color(0xFF9C6FD6),
      gradientEnd: Color(0xFF6A3DAB),
    ),
    _BannerData(
      label: 'New Arrivals',
      headline: 'Fresh Spring Collection',
      buttonText: 'Shop Now',
      image: 'assets/images/offer2.png',
      gradientStart: Color(0xFF7B5EA7),
      gradientEnd: Color(0xFF4A2D88),
    ),
    _BannerData(
      label: 'Limited Deal',
      headline: 'Get 25% Off Today',
      buttonText: 'Grab Deal',
      image: 'assets/images/offer3.png',
      gradientStart: Color(0xFFA67DD6),
      gradientEnd: Color(0xFF7B4FA7),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_page < _banners.length - 1) {
        _page++;
      } else {
        _page = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _page,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160 * widget.scaleFactor,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _page = i),
            itemCount: _banners.length,
            itemBuilder: (context, i) {
              final b = _banners[i];
              return _BannerCard(data: b, scaleFactor: widget.scaleFactor);
            },
          ),
        ),
        SizedBox(height: 10 * widget.scaleFactor),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 3 * widget.scaleFactor),
              width:
                  _page == i ? 20 * widget.scaleFactor : 6 * widget.scaleFactor,
              height: 6 * widget.scaleFactor,
              decoration: BoxDecoration(
                color: _page == i ? _kPurple : _kPurple.withOpacity(0.3),
                borderRadius: BorderRadius.circular(3 * widget.scaleFactor),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

@immutable
class _BannerData {
  final String label;
  final String headline;
  final String buttonText;
  final String image;
  final Color gradientStart;
  final Color gradientEnd;

  const _BannerData({
    required this.label,
    required this.headline,
    required this.buttonText,
    required this.image,
    required this.gradientStart,
    required this.gradientEnd,
  });
}

class _BannerCard extends StatelessWidget {
  final _BannerData data;
  final double scaleFactor;
  const _BannerCard({required this.data, required this.scaleFactor});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85 * scaleFactor,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20 * scaleFactor),
        gradient: LinearGradient(
          colors: [data.gradientStart, data.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: data.gradientEnd.withOpacity(0.4),
            blurRadius: 20 * scaleFactor,
            offset: Offset(0, 8 * scaleFactor),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20 * scaleFactor,
            right: 80 * scaleFactor,
            child: Container(
              width: 100 * scaleFactor,
              height: 100 * scaleFactor,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -30 * scaleFactor,
            left: -20 * scaleFactor,
            child: Container(
              width: 120 * scaleFactor,
              height: 120 * scaleFactor,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 20 * scaleFactor, vertical: 16 * scaleFactor),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10 * scaleFactor,
                            vertical: 4 * scaleFactor),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(12 * scaleFactor),
                        ),
                        child: Text(
                          data.label,
                          style: TextStyle(
                            fontSize: 10 * scaleFactor,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 8 * scaleFactor),
                      Text(
                        data.headline,
                        style: TextStyle(
                          fontSize: 18 * scaleFactor,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 12 * scaleFactor),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: _kPurple,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                              horizontal: 16 * scaleFactor,
                              vertical: 8 * scaleFactor),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(20 * scaleFactor),
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              data.buttonText,
                              style: TextStyle(
                                fontSize: 12 * scaleFactor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 4 * scaleFactor),
                            Icon(Icons.arrow_forward, size: 12 * scaleFactor),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8 * scaleFactor),
                Expanded(
                  flex: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14 * scaleFactor),
                    child: SizedBox(
                      height: 130 * scaleFactor,
                      child: Image.asset(
                        data.image,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          color: Colors.white.withOpacity(0.2),
                          child: Icon(Icons.local_florist,
                              color: Colors.white54, size: 40 * scaleFactor),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Trending Card (Responsive) ─────────────────────────────────────────
class _TrendingCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final double scaleFactor;

  const _TrendingCard({
    required this.product,
    required this.onTap,
    required this.scaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140 * scaleFactor,
        margin: EdgeInsets.only(right: 14 * scaleFactor),
        decoration: BoxDecoration(
          color: _kWhite,
          borderRadius: BorderRadius.circular(16 * scaleFactor),
          boxShadow: [
            BoxShadow(
              color: _kPurple.withOpacity(0.1),
              blurRadius: 14 * scaleFactor,
              offset: Offset(0, 4 * scaleFactor),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16 * scaleFactor)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: _kPurpleSoft),
                    product.imageUrl.startsWith('assets/')
                        ? Image.asset(
                            product.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) =>
                                const ImageFallback(logoHeight: 40),
                          )
                        : product.imageUrl.isNotEmpty
                            ? Image.network(
                                product.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) =>
                                    const ImageFallback(logoHeight: 40),
                              )
                            : const ImageFallback(logoHeight: 40),
                    Positioned(
                      top: 8 * scaleFactor,
                      right: 8 * scaleFactor,
                      child: Container(
                        width: 28 * scaleFactor,
                        height: 28 * scaleFactor,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.favorite_border,
                            color: _kPurple, size: 14 * scaleFactor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10 * scaleFactor, 8 * scaleFactor,
                  10 * scaleFactor, 10 * scaleFactor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 12 * scaleFactor,
                      fontWeight: FontWeight.w600,
                      color: _kText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3 * scaleFactor),
                  Text(
                    '\$${product.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 13 * scaleFactor,
                      fontWeight: FontWeight.w700,
                      color: _kPurple,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom Nav Bar (Responsive) ────────────────────────────────────────
class _BloomBottomNav extends StatelessWidget {
  final int currentIndex;
  const _BloomBottomNav({required this.currentIndex});

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/discovery');
        break;
      case 2:
        context.go('/cart');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaleFactor = MediaQuery.of(context).size.width / 375;

    return Container(
      height: 85 * scaleFactor,
      decoration: BoxDecoration(
        color: _kWhite,
        boxShadow: [
          BoxShadow(
            color: _kPurple.withOpacity(0.12),
            blurRadius: 20 * scaleFactor,
            offset: Offset(0, -4 * scaleFactor),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => _onTap(context, i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: _kWhite,
        selectedItemColor: _kPurple,
        unselectedItemColor: _kTextSub,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(
          fontSize: 10 * scaleFactor,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 10 * scaleFactor,
          fontWeight: FontWeight.w500,
        ),
        elevation: 0,
        iconSize: 28 * scaleFactor,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 28 * scaleFactor),
            activeIcon: Icon(Icons.home_rounded, size: 28 * scaleFactor),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, size: 28 * scaleFactor),
            activeIcon: Icon(Icons.search, size: 28 * scaleFactor),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined, size: 28 * scaleFactor),
            activeIcon:
                Icon(Icons.shopping_cart_rounded, size: 28 * scaleFactor),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 28 * scaleFactor),
            activeIcon: Icon(Icons.person, size: 28 * scaleFactor),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
