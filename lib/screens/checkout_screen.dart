import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../app_theme.dart';
import '../providers/app_state.dart';
import '../widgets/primary_button.dart';

// ─── Shared Palette (Matching Your App) ──────────────────────────────────────
const _kPurple = Color(0xFF7457A2);
const _kPurpleLight = Color(0xFF9B7BC8);
const _kPurpleSoft = Color(0xFFEDE7F6);
const _kBg = Color(0xFFFAF8FF);
const _kWhite = Colors.white;
const _kText = Color(0xFF2D1B4E);
const _kTextSub = Color(0xFF8E7BAE);
const _kGold = Color(0xFFF7C948);
const _kGreen = Color(0xFF4CAF50);
const _kRed = Color(0xFFE57373);

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 0;

  // Address method: 0 = manual, 1 = live location
  int _addressMethod = 0;

  // Controllers for manual address
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();

  // Controllers for payment
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardNameController = TextEditingController();

  // Live location state
  bool _isLoadingLocation = false;
  String? _detectedAddress;

  DateTime? _selectedDate;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _cardNameController.dispose();
    super.dispose();
  }

  // ✅ Get live location and convert to address
  Future<void> _fetchLiveLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _detectedAddress = null;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Location permission denied. Please enable it in settings.'),
                backgroundColor: _kRed,
              ),
            );
          }
          setState(() => _isLoadingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Location permission permanently denied. Please enable from app settings.'),
              backgroundColor: _kRed,
            ),
          );
        }
        setState(() => _isLoadingLocation = false);
        return;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Location services are disabled. Please enable GPS.'),
              backgroundColor: _kRed,
            ),
          );
        }
        setState(() => _isLoadingLocation = false);
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        final String fullAddress = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.postalCode,
          place.country,
        ].where((e) => e != null && e.isNotEmpty).join(', ');

        _addressController.text =
            '${place.street ?? ''} ${place.subLocality ?? ''}'.trim();
        _cityController.text = place.locality ?? '';
        _zipController.text = place.postalCode ?? '';

        setState(() {
          _detectedAddress = fullAddress;
          _isLoadingLocation = false;
        });
      } else {
        setState(() {
          _detectedAddress =
              'Could not determine address. Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      setState(() => _isLoadingLocation = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location: ${e.toString()}'),
            backgroundColor: _kRed,
          ),
        );
      }
    }
  }

  bool _validateStep() {
    if (_currentStep == 0) {
      if (_nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please enter your full name"),
            
          ),
        );
        return false;
      }
      if (_addressMethod == 0) {
        if (_addressController.text.trim().isEmpty ||
            _cityController.text.trim().isEmpty ||
            _zipController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please fill all address fields")),
          );
          return false;
        }
      } else {
        if (_detectedAddress == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Please fetch your live location first")),
          );
          return false;
        }
      }
    }

    if (_currentStep == 1 && _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select delivery date")),
      );
      return false;
    }

    if (_currentStep == 2) {
      if (_cardNumberController.text.trim().length != 16) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a valid 16-digit card number")),
        );
        return false;
      }
      if (_expiryDateController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter expiry date")),
        );
        return false;
      }
      if (_cvvController.text.trim().length < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a valid CVV")),
        );
        return false;
      }
      if (_cardNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter name on card")),
        );
        return false;
      }
    }

    return true;
  }

  String get _finalAddress {
    if (_addressMethod == 1 && _detectedAddress != null) {
      return _detectedAddress!;
    }
    return "${_addressController.text.trim()}, ${_cityController.text.trim()}";
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _kText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'CHECKOUT',
          style: TextStyle(
            letterSpacing: 4,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: _kText,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        child: Column(
          children: [
            // Custom Stepper
            _buildCustomStepper(isSmallScreen),
            const SizedBox(height: 32),

            // Step Content
            _buildStepContent(appState, isSmallScreen),

            const SizedBox(height: 32),

            // Navigation Buttons
            _buildNavigationButtons(isSmallScreen),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomStepper(bool isSmallScreen) {
    return Row(
      children: List.generate(3, (index) {
        final isActive = _currentStep >= index;
        final isCompleted = _currentStep > index;

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isActive ? _kPurple : _kPurpleSoft,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? _kPurple : _kWhite,
                  border: Border.all(
                    color: isActive ? _kPurple : _kTextSub.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, color: _kWhite, size: 20)
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isActive ? _kWhite : _kTextSub,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                index == 0 ? 'ADDRESS' : (index == 1 ? 'DELIVERY' : 'PAYMENT'),
                style: TextStyle(
                  fontSize: isSmallScreen ? 10 : 11,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? _kPurple : _kTextSub,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStepContent(AppState appState, bool isSmallScreen) {
    switch (_currentStep) {
      case 0:
        return _buildAddressStep(isSmallScreen);
      case 1:
        return _buildDeliveryStep(isSmallScreen);
      case 2:
        return _buildPaymentStep(appState, isSmallScreen);
      default:
        return const SizedBox();
    }
  }

  Widget _buildAddressStep(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Full name
        Container(
          decoration: BoxDecoration(
            color: _kWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _kPurple.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              labelStyle: TextStyle(color: _kTextSub),
              prefixIcon: Icon(Icons.person_outline, color: _kPurple),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: _kWhite,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
            cursorColor: _kPurple,
            style: const TextStyle(color: _kText),
          ),
        ),
        const SizedBox(height: 20),

        // Address method toggle
        Text(
          'DELIVERY ADDRESS',
          style: TextStyle(
            letterSpacing: 2,
            fontSize: 11,
            color: _kTextSub,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _AddressMethodCard(
                icon: Icons.edit_location_alt_outlined,
                label: 'Enter Manually',
                isSelected: _addressMethod == 0,
                onTap: () => setState(() => _addressMethod = 0),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _AddressMethodCard(
                icon: Icons.my_location_rounded,
                label: 'Use My Location',
                isSelected: _addressMethod == 1,
                onTap: () => setState(() => _addressMethod = 1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Manual fields
        if (_addressMethod == 0) ...[
          Container(
            decoration: BoxDecoration(
              color: _kWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _kPurple.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Street Address',
                labelStyle: TextStyle(color: _kTextSub),
                prefixIcon: Icon(Icons.home_outlined, color: _kPurple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: _kWhite,
              ),
              cursorColor: _kPurple,
              style: TextStyle(color: _kText),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: _kWhite,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _kPurple.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: 'City',
                      labelStyle: TextStyle(color: _kTextSub),
                      prefixIcon: Icon(Icons.location_city_outlined, color: _kPurple),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: _kWhite,
                    ),
                    cursorColor: _kPurple,
                    style: TextStyle(color: _kText),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: _kWhite,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _kPurple.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _zipController,
                    decoration: InputDecoration(
                      labelText: 'ZIP',
                      labelStyle: TextStyle(color: _kTextSub),
                      prefixIcon: Icon(Icons.mail_outline, color: _kPurple),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: _kWhite,
                    ),
                    cursorColor: _kPurple,
                    style: TextStyle(color: _kText),
                  ),
                ),
              ),
            ],
          ),
        ],

        // Live location section
        if (_addressMethod == 1) ...[
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _isLoadingLocation
                ? _buildLoadingCard(isSmallScreen)
                : _detectedAddress != null
                    ? _buildDetectedAddressCard(_detectedAddress!, isSmallScreen)
                    : _buildFetchLocationButton(isSmallScreen),
          ),
        ],
      ],
    );
  }


  Widget _buildDeliveryStep(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT DELIVERY DATE',
          style: TextStyle(
            letterSpacing: 2,
            fontSize: 11,
            color: _kTextSub,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
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
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: _kPurple,
                onPrimary: _kWhite,
                onSurface: _kText,
              ),
            ),
            child: CalendarDatePicker(
              initialDate: DateTime.now().add(const Duration(days: 1)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 30)),
              onDateChanged: (date) {
                setState(() => _selectedDate = date);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLength,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _kPurple.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: _kTextSub),
          prefixIcon: Icon(icon, color: _kPurple),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: _kWhite,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          counterText: '',
        ),
        cursorColor: _kPurple,
        style: const TextStyle(color: _kText),
      ),
    );
  }

  Widget _buildPaymentStep(AppState appState, bool isSmallScreen) {
    return Column(
      children: [
        _buildTextField(
          controller: _cardNumberController,
          label: 'Card Number',
          icon: Icons.credit_card,
          keyboardType: TextInputType.number,
          maxLength: 16,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _expiryDateController,
                label: 'Expiry (MM/YY)',
                icon: Icons.calendar_today,
                keyboardType: TextInputType.datetime,
                maxLength: 5,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _cvvController,
                label: 'CVV',
                icon: Icons.security,
                keyboardType: TextInputType.number,
                maxLength: 4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _cardNameController,
          label: 'Name on Card',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _kPurpleSoft,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _kTextSub,
                  letterSpacing: 1,
                ),
              ),
              Text(
                '\$${appState.cartTotal.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _kPurple,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(bool isSmallScreen) {
    return Column(
      children: [
        PrimaryButton(
          label: _currentStep == 2 ? 'Place Order' : 'Continue',
          onPressed: () {
            if (!_validateStep()) return;
            if (_currentStep < 2) {
              setState(() => _currentStep++);
            } else {
              final appState = Provider.of<AppState>(context, listen: false);
              appState.placeOrder(_finalAddress, deliveryDate: _selectedDate);
              context.go('/confirmation');
            }
          },
        ),
        if (_currentStep > 0) ...[
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => setState(() => _currentStep--),
            style: OutlinedButton.styleFrom(
              foregroundColor: _kPurple,
              side: BorderSide(color: _kPurpleSoft),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Back'),
          ),
        ],
      ],
    );
  }

  // ── Helpers for live location UI ──
  Widget _buildFetchLocationButton(bool isSmallScreen) {
    return GestureDetector(
      onTap: _fetchLiveLocation,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
            vertical: isSmallScreen ? 20 : 24, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: _kPurple.withOpacity(0.3),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(20),
          color: _kPurpleSoft,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kPurple.withOpacity(0.1),
              ),
              child: Icon(
                Icons.my_location_rounded,
                color: _kPurple,
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'TAP TO DETECT MY LOCATION',
              style: TextStyle(
                color: _kPurple,
                letterSpacing: 1.5,
                fontSize: isSmallScreen ? 10 : 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'We\'ll use your GPS to auto-fill your address',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _kTextSub,
                fontSize: isSmallScreen ? 9 : 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard(bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          vertical: isSmallScreen ? 28 : 32, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: _kPurple.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(20),
        color: _kPurpleSoft,
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_kPurple),
            strokeWidth: 2.5,
          ),
          const SizedBox(height: 14),
          Text(
            'DETECTING YOUR LOCATION...',
            style: TextStyle(
              color: _kPurple,
              letterSpacing: 1.5,
              fontSize: isSmallScreen ? 9 : 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectedAddressCard(String address, bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: _kPurple, width: 1.5),
        borderRadius: BorderRadius.circular(20),
        color: _kWhite,
        boxShadow: [
          BoxShadow(
            color: _kPurple.withOpacity(0.08),
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
              Icon(Icons.location_on, color: _kPurple, size: 18),
              const SizedBox(width: 8),
              Text(
                'LIVE LOCATION DETECTED',
                style: TextStyle(
                  color: _kPurple,
                  fontSize: isSmallScreen ? 9 : 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(Icons.check_circle, color: _kGreen, size: 18),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            address,
            style: TextStyle(
              color: _kText,
              fontSize: isSmallScreen ? 12 : 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _fetchLiveLocation,
            child: Text(
              '↻  Refresh Location',
              style: TextStyle(
                color: _kPurple,
                fontSize: isSmallScreen ? 10 : 11,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Address Method Card ─────────────────────────────────────────────────────
class _AddressMethodCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AddressMethodCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? _kPurple : _kPurple.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          color: isSelected ? _kPurpleSoft : _kWhite,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? _kPurple : _kTextSub,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? _kPurple : _kTextSub,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

