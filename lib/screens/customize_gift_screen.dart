import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/glitter_widget.dart';
import '../providers/app_state.dart';
import '../models/product.dart';

class CustomizeGiftScreen extends StatefulWidget {
  const CustomizeGiftScreen({super.key});

  @override
  State<CustomizeGiftScreen> createState() => _CustomizeGiftScreenState();
}

class _CustomizeGiftScreenState extends State<CustomizeGiftScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Bouquet Selections
  final Map<String, int> _selectedFlowers = {};
  String _selectedBouquetRibbon = 'Silk Cream';

  // Basket Selections
  String _selectedBasketType = 'Classic Wicker';
  final Map<String, bool> _basketContents = {
    'Roses': true,
    'Chocolates': false,
    'Teddy Bear': false,
    'Greeting Card': true,
    'Scented Candle': false,
  };

  final TextEditingController _messageController = TextEditingController();
  int _selectedTabIndex = 0;

  final List<String> _flowerOptions = [
    'Roses',
    'Lilies',
    'Tulips',
    'Daisies',
    'Peonies',
    'Sunflowers'
  ];
  final List<String> _ribbonOptions = [
    'Silk Cream',
    'Forest Velvet',
    'Gold Satin',
    'Midnight Blue',
    'None'
  ];
  final List<String> _basketOptions = [
    'Classic Wicker',
    'Modern Wooden',
    'Luxury Velvet Box',
    'Vintage Tray'
  ];

  String _selectedWrapping = 'Premium Craft';
  final List<String> _wrappingOptions = [
    'Premium Craft',
    'Luxury Gold',
    'Floral Pattern',
    'Minimalist White',
    'None'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedTabIndex = _tabController.index;
    _tabController.addListener(() {
      if (mounted && !_tabController.indexIsChanging) {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
      }
    });
    for (var flower in _flowerOptions) {
      _selectedFlowers[flower] = 0;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // Botanical Palette matching AppTheme
  static const Color _kPurple = Color.fromARGB(255, 203, 178, 244);
  static const Color _kGold = Color(0xFFF7C948);
  static const Color _kWhite = Colors.white;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'BESPOKE CREATIONS',
          style: GoogleFonts.orbitron(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black.withOpacity(0.4),
          labelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          tabs: const [
            Tab(text: 'CUSTOM BOUQUET'),
            Tab(text: 'CUSTOM BASKET'),
          ],
        ),
      ),
      body: GlitterWidget(
        color: Colors.white.withOpacity(0.3),
        child: Column(
          children: [
            _buildCustomizationPreview(isDark),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBouquetCustomization(isDark),
                  _buildBasketCustomization(isDark),
                ],
              ),
            ),
            _buildFooter(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomizationPreview(bool isDark) {
    final isBouquet = _selectedTabIndex == 0;
    final imageAsset = isBouquet
        ? 'assets/images/flower14.png'
        : 'assets/images/flower.png';
    final title = isBouquet ? 'DUMMY BOUQUET PREVIEW' : 'DUMMY BASKET PREVIEW';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            SizedBox(
              height: 160,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  imageAsset,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Icon(
                      isBouquet ? Icons.local_florist : Icons.shopping_basket,
                      size: 48,
                      color: _kPurple,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.black : Colors.black,
                  ),
                ),
                Text(
                  'Preview',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBouquetCustomization(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('FLOWER QUANTITIES', isDark),
          const SizedBox(height: 16),
          ..._flowerOptions
              .map((flower) => _buildFlowerCounter(flower, isDark)),
          const SizedBox(height: 32),
          _buildSectionTitle('RIBBON SELECTION', isDark),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _ribbonOptions
                .map((ribbon) => _buildOptionChip(
                      ribbon,
                      _selectedBouquetRibbon == ribbon,
                      () => setState(() => _selectedBouquetRibbon = ribbon),
                      isDark,
                    ))
                .toList(),
          ),
          const SizedBox(height: 32),
          _buildSectionTitle('GIFT WRAPPING', isDark),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _wrappingOptions
                .map((wrap) => _buildOptionChip(
                      wrap,
                      _selectedWrapping == wrap,
                      () => setState(() => _selectedWrapping = wrap),
                      isDark,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBasketCustomization(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('BASKET STYLE', isDark),
          const SizedBox(height: 16),
          ..._basketOptions.map((basket) => RadioListTile<String>(
                title: Text(basket.toUpperCase(),
                    style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black)),
                value: basket,
                groupValue: _selectedBasketType,
                activeColor: Colors.black,
                onChanged: (val) => setState(() => _selectedBasketType = val!),
                contentPadding: EdgeInsets.zero,
              )),
          const SizedBox(height: 32),
          _buildSectionTitle('GIFT ADD-ONS', isDark),
          const SizedBox(height: 16),
          ..._basketContents.keys.map((content) => CheckboxListTile(
                title: Text(content.toUpperCase(),
                    style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black)),
                value: _basketContents[content],
                activeColor: Colors.black,
                checkColor: Colors.white,
                onChanged: (val) =>
                    setState(() => _basketContents[content] = val!),
                contentPadding: EdgeInsets.zero,
              )),
          const SizedBox(height: 32),
          _buildSectionTitle('GIFT WRAPPING', isDark),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _wrappingOptions
                .map((wrap) => _buildOptionChip(
                      wrap,
                      _selectedWrapping == wrap,
                      () => setState(() => _selectedWrapping = wrap),
                      isDark,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _messageController,
            maxLines: 2,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: 'ADD A PERSONAL MESSAGE...',
              hintStyle:
                  GoogleFonts.manrope(fontSize: 12, color: Colors.black45),
              filled: true,
              fillColor: Colors.white,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              final appState = context.read<AppState>();
              final isBouquet = _tabController.index == 0;
              final title = isBouquet ? "Custom Bouquet" : "Custom Basket";

              String details = "";
              double totalPrice = isBouquet ? 25.0 : 35.0; // Base prices

              if (isBouquet) {
                details += "Flowers: ";
                _selectedFlowers.forEach((name, count) {
                  if (count > 0) {
                    details += "$count $name, ";
                    totalPrice += count * 5.0;
                  }
                });
                details += "Ribbon: $_selectedBouquetRibbon";
              } else {
                details += "Style: $_selectedBasketType, Contents: ";
                _basketContents.forEach((name, selected) {
                  if (selected) {
                    details += "$name, ";
                    totalPrice += 10.0;
                  }
                });
              }

              details += "\nWrapping: $_selectedWrapping";

              if (_messageController.text.isNotEmpty) {
                details += "\nMessage: ${_messageController.text}";
              }

              final customProduct = Product(
                id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
                name: title,
                description: details,
                price: totalPrice,
                imageUrl: isBouquet
                    ? 'assets/images/flower14.png'
                    : 'assets/images/flower.png',
                category: 'Bespoke',
                tags: ['Custom', 'Bespoke'],
              );

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

              appState.addToCart(customProduct);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$title added to cart!'),
                  backgroundColor: _kPurple,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPurple,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            child: const Text(
              'ADD TO COLLECTION',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        letterSpacing: 2,
        color: Colors.black,
      ),
    );
  }

  Widget _buildFlowerCounter(String name, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name.toUpperCase(),
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              )),
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() {
                  if (_selectedFlowers[name]! > 0)
                    _selectedFlowers[name] = _selectedFlowers[name]! - 1;
                }),
                icon: const Icon(Icons.remove_circle_outline,
                    color: Colors.black),
              ),
              SizedBox(
                width: 30,
                child: Center(
                  child: Text(
                    '${_selectedFlowers[name]}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(
                    () => _selectedFlowers[name] = _selectedFlowers[name]! + 1),
                icon: const Icon(Icons.add_circle_outline, color: Colors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionChip(
      String label, bool isActive, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : Colors.white.withOpacity(0.2),
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.manrope(
            color: isActive ? Colors.white : Colors.black,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
