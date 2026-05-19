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

  // Card Design Selection
  String _selectedCardDesign = 'Classic Lavender';
  final List<String> _cardDesignOptions = [
    'Classic Lavender',
    'Golden Anniversary',
    'Romantic Crimson',
    'Warm Sunshine',
    'Midnight Elegance',
  ];

  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  int _selectedTabIndex = 0;

  final List<String> _flowerOptions = [
    'Roses',
    'Lilies',
    'Tulips',
    'Daisies',
    'Peonies',
    'Sunflowers'
  ];

  // Flower styling helper
  final Map<String, Map<String, dynamic>> _flowerStyles = {
    'Roses': {'color': Color(0xFFE53935), 'emoji': '🌹', 'price': 5.0},
    'Lilies': {'color': Color(0xFFF48FB1), 'emoji': '🌸', 'price': 6.0},
    'Tulips': {'color': Color(0xFFFFB300), 'emoji': '🌷', 'price': 5.0},
    'Daisies': {'color': Color(0xFFFFF176), 'emoji': '🌼', 'price': 4.0},
    'Peonies': {'color': Color(0xFFEC407A), 'emoji': '🌺', 'price': 7.0},
    'Sunflowers': {'color': Color(0xFFFF8F00), 'emoji': '🌻', 'price': 5.0},
  };

  final List<Map<String, dynamic>> _ribbonOptions = [
    {'name': 'Silk Cream', 'price': 0.0, 'color': Color(0xFFFFFDD0)},
    {'name': 'Forest Velvet', 'price': 3.0, 'color': Color(0xFF1B4D3E)},
    {'name': 'Gold Satin', 'price': 4.0, 'color': Color(0xFFD4AF37)},
    {'name': 'Midnight Blue', 'price': 3.0, 'color': Color(0xFF191970)},
    {'name': 'None', 'price': 0.0, 'color': Colors.transparent}
  ];

  final List<Map<String, dynamic>> _basketOptions = [
    {'name': 'Classic Wicker', 'price': 0.0, 'desc': 'Traditional hand-woven cane basket', 'icon': Icons.shopping_basket},
    {'name': 'Modern Wooden', 'price': 5.0, 'desc': 'Sleek minimalist wooden crate style', 'icon': Icons.widgets_outlined},
    {'name': 'Luxury Velvet Box', 'price': 10.0, 'desc': 'Plush velvet casing for high premium gifting', 'icon': Icons.all_inbox_rounded},
    {'name': 'Vintage Tray', 'price': 4.0, 'desc': 'Rustic wooden serving tray display', 'icon': Icons.table_chart_outlined}
  ];

  final Map<String, Map<String, dynamic>> _addonDetails = {
    'Roses': {'price': 12.0, 'emoji': '🌹', 'desc': 'Fresh stem red roses'},
    'Chocolates': {'price': 10.0, 'emoji': '🍫', 'desc': 'Luxury Belgian truffles'},
    'Teddy Bear': {'price': 15.0, 'emoji': '🧸', 'desc': 'Soft organic mini-plush'},
    'Greeting Card': {'price': 4.0, 'emoji': '✉️', 'desc': 'Calligraphy keepsake card'},
    'Scented Candle': {'price': 8.0, 'emoji': '🕯️', 'desc': 'Lavender essential oil candle'},
  };

  String _selectedWrapping = 'Premium Craft';
  final List<Map<String, dynamic>> _wrappingOptions = [
    {'name': 'Premium Craft', 'price': 3.0, 'emoji': '📜'},
    {'name': 'Luxury Gold', 'price': 5.0, 'emoji': '✨'},
    {'name': 'Floral Pattern', 'price': 4.0, 'emoji': '🌸'},
    {'name': 'Minimalist White', 'price': 3.0, 'emoji': '🤍'},
    {'name': 'None', 'price': 0.0, 'emoji': '❌'}
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
    _instructionsController.dispose();
    super.dispose();
  }

  // Botanical Theme Palette
  static const Color _kPurple = Color(0xFF7457A2);
  static const Color _kPurpleLight = Color(0xFF9B7BC8);
  static const Color _kPurpleSoft = Color(0xFFEDE7F6);
  static const Color _kBg = Color(0xFFFAF8FF);
  static const Color _kWhite = Colors.white;
  static const Color _kText = Color(0xFF2D1B4E);
  static const Color _kTextSub = Color(0xFF8E7BAE);
  static const Color _kGold = Color(0xFFF7C948);
  static const Color _kGreen = Color(0xFF4CAF50);

  // Dynamic price getter
  double get _currentTotalPrice {
    final isBouquet = _selectedTabIndex == 0;
    double price = isBouquet ? 25.0 : 35.0; // Base prices

    if (isBouquet) {
      _selectedFlowers.forEach((name, count) {
        final flowerPrice = _flowerStyles[name]?['price'] as double? ?? 5.0;
        price += count * flowerPrice;
      });

      final ribbonObj = _ribbonOptions.firstWhere((r) => r['name'] == _selectedBouquetRibbon, orElse: () => _ribbonOptions.first);
      price += ribbonObj['price'] as double;
    } else {
      final basketObj = _basketOptions.firstWhere((b) => b['name'] == _selectedBasketType, orElse: () => _basketOptions.first);
      price += basketObj['price'] as double;

      _basketContents.forEach((name, selected) {
        if (selected) {
          final addonPrice = _addonDetails[name]?['price'] as double? ?? 10.0;
          price += addonPrice;
        }
      });
    }

    final wrapObj = _wrappingOptions.firstWhere((w) => w['name'] == _selectedWrapping, orElse: () => _wrappingOptions.first);
    price += wrapObj['price'] as double;

    return price;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kWhite,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _kText),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'BESPOKE CREATIONS',
          style: GoogleFonts.orbitron(
            color: _kText,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: _kPurpleSoft,
              borderRadius: BorderRadius.circular(30),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: _kPurple,
              ),
              labelColor: _kWhite,
              unselectedLabelColor: _kTextSub,
              labelStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
              tabs: const [
                Tab(text: 'DESIGN BOUQUET'),
                Tab(text: 'DESIGN BASKET'),
              ],
            ),
          ),
        ),
      ),
      body: GlitterWidget(
        color: _kPurple.withOpacity(0.08),
        child: Column(
          children: [
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

    // Collect active ingredients list
    final List<String> activeIngredients = [];
    if (isBouquet) {
      _selectedFlowers.forEach((flower, count) {
        if (count > 0) {
          activeIngredients.add('$count × ${flower}');
        }
      });
      if (_selectedBouquetRibbon != 'None') {
        activeIngredients.add('🎗️ $_selectedBouquetRibbon Ribbon');
      }
    } else {
      activeIngredients.add('🧺 $_selectedBasketType');
      _basketContents.forEach((addon, active) {
        if (active) {
          activeIngredients.add('${_addonDetails[addon]?['emoji']} $addon');
        }
      });
    }

    if (_selectedWrapping != 'None') {
      activeIngredients.add('🎁 $_selectedWrapping Wrap');
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: _kWhite,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _kPurpleSoft, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: _kPurple.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Preview Image
            Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: _kPurpleSoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      imageAsset,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(
                          isBouquet ? Icons.local_florist : Icons.shopping_basket,
                          size: 36,
                          color: _kPurple,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _kGold,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Bespoke',
                      style: GoogleFonts.manrope(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: _kText,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Build ingredients and real-time pricing details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          isBouquet ? 'YOUR CUSTOM BOUQUET' : 'YOUR CUSTOM BASKET',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: _kText,
                            letterSpacing: 1,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _kPurple,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '\$${_currentTotalPrice.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _kWhite,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Recipe Chips List
                  activeIngredients.isEmpty
                      ? Text(
                          'Begin selecting options below to design your masterpiece...',
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                            color: _kTextSub,
                          ),
                        )
                      : Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: activeIngredients.map((item) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _kPurpleSoft.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item,
                                style: GoogleFonts.manrope(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color: _kPurple,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBouquetCustomization(bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCustomizationPreview(isDark),
          const SizedBox(height: 24),
          _buildSectionTitle('1. CHOOSE YOUR BLOOMS', isDark),
          const SizedBox(height: 4),
          Text(
            'Mix and match high premium flowers. Prices per single stem shown below.',
            style: GoogleFonts.manrope(fontSize: 11, color: _kTextSub),
          ),
          const SizedBox(height: 16),
          ..._flowerOptions
              .map((flower) => _buildFlowerCounterCard(flower, isDark)),
          const SizedBox(height: 32),
          _buildSectionTitle('2. CHOOSE A SATIN RIBBON', isDark),
          const SizedBox(height: 16),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _ribbonOptions.length,
              itemBuilder: (context, index) {
                final ribbon = _ribbonOptions[index];
                final name = ribbon['name'] as String;
                final isSelected = _selectedBouquetRibbon == name;

                return GestureDetector(
                  onTap: () => setState(() => _selectedBouquetRibbon = name),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(right: 12),
                    width: 100,
                    decoration: BoxDecoration(
                      color: isSelected ? _kPurpleSoft : _kWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? _kPurple : _kPurpleSoft,
                        width: isSelected ? 2 : 1.5,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: _kPurple.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Colored Circle for ribbon preview
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ribbon['color'] as Color,
                            border: Border.all(color: _kText.withOpacity(0.15)),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, size: 14, color: _kWhite)
                              : null,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          name.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.manrope(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? _kPurple : _kText,
                          ),
                        ),
                        if ((ribbon['price'] as double) > 0)
                          Text(
                            '+\$${(ribbon['price'] as double).toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: _kGreen,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          _buildSectionTitle('3. LUXURY GIFT WRAPPING', isDark),
          const SizedBox(height: 16),
          _buildWrappingSelector(),
        ],
      ),
    );
  }

  Widget _buildBasketCustomization(bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCustomizationPreview(isDark),
          const SizedBox(height: 24),
          _buildSectionTitle('1. SELECT BASKET CASING STYLE', isDark),
          const SizedBox(height: 16),
          ..._basketOptions.map((basket) => _buildBasketOptionCard(basket)),
          const SizedBox(height: 32),
          _buildSectionTitle('2. ADD HIGH-END CONTENTS', isDark),
          const SizedBox(height: 16),
          ..._basketContents.keys.map((content) => _buildAddonCheckboxCard(content)),
          const SizedBox(height: 32),
          _buildSectionTitle('3. LUXURY GIFT WRAPPING', isDark),
          const SizedBox(height: 16),
          _buildWrappingSelector(),
        ],
      ),
    );
  }

  Widget _buildFlowerCounterCard(String name, bool isDark) {
    final style = _flowerStyles[name]!;
    final color = style['color'] as Color;
    final emoji = style['emoji'] as String;
    final price = style['price'] as double;
    final count = _selectedFlowers[name] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kPurpleSoft, width: 1.5),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Emoji avatar with colored badge
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 22),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.toUpperCase(),
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _kText,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '\$${price.toStringAsFixed(2)} / stem',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _kTextSub,
                  ),
                ),
              ],
            ),
          ),
          // Interactive quantity control buttons
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() {
                  if (count > 0) {
                    _selectedFlowers[name] = count - 1;
                  }
                }),
                icon: Icon(
                  Icons.remove_circle,
                  color: count > 0 ? _kPurple : _kPurpleSoft,
                  size: 26,
                ),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 28),
                child: Center(
                  child: Text(
                    '$count',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: count > 0 ? _kPurple : _kTextSub,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() {
                  _selectedFlowers[name] = count + 1;
                }),
                icon: const Icon(
                  Icons.add_circle,
                  color: _kPurple,
                  size: 26,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBasketOptionCard(Map<String, dynamic> basket) {
    final name = basket['name'] as String;
    final isSelected = _selectedBasketType == name;
    final desc = basket['desc'] as String;
    final price = basket['price'] as double;
    final icon = basket['icon'] as IconData;

    return GestureDetector(
      onTap: () => setState(() => _selectedBasketType = name),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected ? _kPurpleSoft : _kWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _kPurple : _kPurpleSoft,
            width: isSelected ? 2 : 1.5,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? _kPurple.withOpacity(0.15) : _kPurpleSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: _kPurple, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name.toUpperCase(),
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: _kText,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (price > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _kGreen.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '+\$${price.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: _kGreen,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      color: _kTextSub,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? _kPurple : _kTextSub.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddonCheckboxCard(String content) {
    final active = _basketContents[content] ?? false;
    final details = _addonDetails[content]!;
    final emoji = details['emoji'] as String;
    final desc = details['desc'] as String;
    final price = details['price'] as double;

    return GestureDetector(
      onTap: () => setState(() => _basketContents[content] = !active),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: active ? _kPurpleSoft : _kWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? _kPurple : _kPurpleSoft,
            width: active ? 2 : 1.5,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: active ? _kPurple.withOpacity(0.15) : _kPurpleSoft,
                shape: BoxShape.circle,
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        content.toUpperCase(),
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: _kText,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _kGreen.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '+\$${price.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: _kGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      color: _kTextSub,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              active ? Icons.check_box : Icons.check_box_outline_blank,
              color: active ? _kPurple : _kTextSub.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWrappingSelector() {
    return SizedBox(
      height: 75,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _wrappingOptions.length,
        itemBuilder: (context, index) {
          final option = _wrappingOptions[index];
          final name = option['name'] as String;
          final isSelected = _selectedWrapping == name;

          return GestureDetector(
            onTap: () => setState(() => _selectedWrapping = name),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(right: 12),
              width: 120,
              decoration: BoxDecoration(
                color: isSelected ? _kPurpleSoft : _kWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? _kPurple : _kPurpleSoft,
                  width: isSelected ? 2 : 1.5,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(option['emoji'] as String, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.manrope(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? _kPurple : _kText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          (option['price'] as double) > 0 ? '+\$${(option['price'] as double).toStringAsFixed(0)}' : 'Free',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: (option['price'] as double) > 0 ? _kGreen : _kTextSub,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: _kPurple.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Elegant Message and Card Customization Section ───
            Row(
              children: [
                Expanded(
                  child: Text(
                    'KEEPSAKE CARD DESIGN',
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: _kTextSub,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedCardDesign,
                  onChanged: (val) => setState(() => _selectedCardDesign = val!),
                  underline: const SizedBox(),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _kPurple,
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down, color: _kPurple, size: 18),
                  items: _cardDesignOptions.map((design) {
                    return DropdownMenuItem<String>(
                      value: design,
                      child: Text(design),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _messageController,
              maxLines: 2,
              maxLength: 120,
              style: GoogleFonts.manrope(fontSize: 13, color: _kText, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'WRITE YOUR HEARTFELT PERSONAL MESSAGE...',
                hintStyle: GoogleFonts.manrope(fontSize: 11, color: _kTextSub.withOpacity(0.5)),
                filled: true,
                fillColor: _kBg,
                counterText: '',
                prefixIcon: const Icon(Icons.favorite_outline, color: _kPurple, size: 18),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: _kPurpleSoft, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: _kPurple, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _instructionsController,
              maxLines: 2,
              maxLength: 150,
              style: GoogleFonts.manrope(fontSize: 13, color: _kText, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'ADD SPECIAL CUSTOMIZATION INSTRUCTIONS...',
                hintStyle: GoogleFonts.manrope(fontSize: 11, color: _kTextSub.withOpacity(0.5)),
                filled: true,
                fillColor: _kBg,
                counterText: '',
                prefixIcon: const Icon(Icons.edit_note_rounded, color: _kPurple, size: 18),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: _kPurpleSoft, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: _kPurple, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final appState = context.read<AppState>();
                final isBouquet = _tabController.index == 0;
                final title = isBouquet ? "Custom Bouquet" : "Custom Basket";

                String details = "";
                if (isBouquet) {
                  details += "🌺 Type: Custom Bouquet\n💐 Flowers:\n";
                  bool hasFlowers = false;
                  _selectedFlowers.forEach((name, count) {
                    if (count > 0) {
                      details += "  - $count × $name\n";
                      hasFlowers = true;
                    }
                  });
                  if (!hasFlowers) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                        content: Text('Please select at least 1 flower to design your bouquet!'),
                      ),
                    );
                    return;
                  }
                  details += "🎗️ Ribbon: $_selectedBouquetRibbon\n";
                } else {
                  details += "🧺 Type: Custom Basket\n📦 Casing: $_selectedBasketType\n📦 Add-ons:\n";
                  _basketContents.forEach((name, selected) {
                    if (selected) {
                      details += "  - $name\n";
                    }
                  });
                }

                details += "🎁 Wrapping: $_selectedWrapping\n";
                details += "✉️ Card Design: $_selectedCardDesign\n";

                if (_messageController.text.trim().isNotEmpty) {
                  details += "💌 Message: \"${_messageController.text.trim()}\"\n";
                }

                if (_instructionsController.text.trim().isNotEmpty) {
                  details += "📝 Instructions: \"${_instructionsController.text.trim()}\"\n";
                }

                final customProduct = Product(
                  id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
                  name: title,
                  description: details,
                  price: _currentTotalPrice,
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
                    content: Text('✨ Bespoke $title added to cart successfully!'),
                    backgroundColor: _kPurple,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                );
                context.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPurple,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
                shadowColor: _kPurple.withOpacity(0.3),
              ),
              child: const Text(
                'ADD TO COLLECTION',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: GoogleFonts.manrope(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 2,
        color: _kText,
      ),
    );
  }
}
