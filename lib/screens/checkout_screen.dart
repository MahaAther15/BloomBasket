import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../app_theme.dart';
import '../providers/app_state.dart';
import '../widgets/primary_button.dart';

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
    super.dispose();
  }

  // ✅ Get live location and convert to address
  Future<void> _fetchLiveLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _detectedAddress = null;
    });

    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permission denied. Please enable it in settings.'),
                backgroundColor: Colors.redAccent,
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
              content: Text('Location permission permanently denied. Please enable from app settings.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        setState(() => _isLoadingLocation = false);
        return;
      }

      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location services are disabled. Please enable GPS.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() => _isLoadingLocation = false);
        return;
      }

      // Get current position
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Convert coordinates to address
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

        // Also populate manual fields for editing
        _addressController.text = '${place.street ?? ''} ${place.subLocality ?? ''}'.trim();
        _cityController.text = place.locality ?? '';
        _zipController.text = place.postalCode ?? '';

        setState(() {
          _detectedAddress = fullAddress;
          _isLoadingLocation = false;
        });
      } else {
        setState(() {
          _detectedAddress = 'Could not determine address. Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      setState(() => _isLoadingLocation = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // ✅ Validation
  bool _validateStep() {
    if (_currentStep == 0) {
      if (_nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter your full name")),
        );
        return false;
      }
      if (_addressMethod == 0) {
        // Manual validation
        if (_addressController.text.trim().isEmpty ||
            _cityController.text.trim().isEmpty ||
            _zipController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please fill all address fields")),
          );
          return false;
        }
      } else {
        // Live location validation
        if (_detectedAddress == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please fetch your live location first")),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CHECKOUT',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            letterSpacing: 4,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: SafeArea(
        child: Stepper(
          type: StepperType.horizontal,
          elevation: 0,
          currentStep: _currentStep,

          onStepContinue: () {
            if (!_validateStep()) return;

            if (_currentStep < 2) {
              setState(() => _currentStep++);
            } else {
              appState.placeOrder(_finalAddress);
              context.go('/confirmation');
            }
          },

          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              context.pop();
            }
          },

          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      label: _currentStep == 2 ? 'Place Order' : 'Continue',
                      onPressed: details.onStepContinue!,
                    ),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: details.onStepCancel,
                        child: const Text('BACK'),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },

          steps: [
            // ─── STEP 1 - ADDRESS ───
            Step(
              isActive: _currentStep >= 0,
              title: const SizedBox(),
              label: Text(
                'ADDRESS',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 8),
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Full name (always shown)
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'FULL NAME'),
                  ),
                  const SizedBox(height: 20),

                  // ── Address method toggle ──
                  Text(
                    'DELIVERY ADDRESS',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          letterSpacing: 2,
                          fontSize: 11,
                          color: AppTheme.outline,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Toggle buttons
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

                  // ── Manual fields ──
                  if (_addressMethod == 0) ...[
                    TextField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'STREET ADDRESS'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _cityController,
                            decoration: const InputDecoration(labelText: 'CITY'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _zipController,
                            decoration: const InputDecoration(labelText: 'ZIP'),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // ── Live location section ──
                  if (_addressMethod == 1) ...[
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: _isLoadingLocation
                          ? _buildLoadingCard()
                          : _detectedAddress != null
                              ? _buildDetectedAddressCard(_detectedAddress!)
                              : _buildFetchLocationButton(),
                    ),
                  ],
                ],
              ),
            ),

            // ─── STEP 2 - DELIVERY ───
            Step(
              isActive: _currentStep >= 1,
              title: const SizedBox(),
              label: Text(
                'DELIVERY',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 8),
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SELECT DELIVERY DATE',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(letterSpacing: 2),
                  ),
                  const SizedBox(height: 12),
                  CalendarDatePicker(
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                    onDateChanged: (date) {
                      setState(() => _selectedDate = date);
                    },
                  ),
                ],
              ),
            ),

            // ─── STEP 3 - PAYMENT ───
            Step(
              isActive: _currentStep >= 2,
              title: const SizedBox(),
              label: Text(
                'PAYMENT',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 8),
              ),
              content: Column(
                children: [
                  _PaymentOption(
                    title: 'CREDIT CARD',
                    subtitle: '**** **** **** 4242',
                    icon: Icons.credit_card,
                    isSelected: true,
                  ),
                  const SizedBox(height: 12),
                  _PaymentOption(
                    title: 'APPLE PAY',
                    subtitle: '**** 9012',
                    icon: Icons.apple,
                    isSelected: false,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TOTAL',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      Text(
                        '\$${appState.cartTotal.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers for live location UI ──

  Widget _buildFetchLocationButton() {
    return GestureDetector(
      onTap: _fetchLiveLocation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppTheme.primaryGreen.withOpacity(0.4),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
          color: AppTheme.primaryGreen.withOpacity(0.04),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryGreen.withOpacity(0.2),
                    AppTheme.primaryContainer.withOpacity(0.1),
                  ],
                ),
              ),
              child: Icon(
                Icons.my_location_rounded,
                color: AppTheme.primaryGreen,
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'TAP TO DETECT MY LOCATION',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppTheme.primaryGreen,
                    letterSpacing: 1.5,
                    fontSize: 11,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'We\'ll use your GPS to auto-fill your address',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.outline,
                    fontSize: 10,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
        color: AppTheme.primaryGreen.withOpacity(0.04),
      ),
      child: Column(
        children: [
          CircularProgressIndicator(
            color: AppTheme.primaryGreen,
            strokeWidth: 2.5,
          ),
          const SizedBox(height: 14),
          Text(
            'DETECTING YOUR LOCATION...',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.primaryGreen,
                  letterSpacing: 1.5,
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectedAddressCard(String address) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.primaryGreen, width: 1.5),
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryGreen.withOpacity(0.06),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: AppTheme.primaryGreen, size: 18),
              const SizedBox(width: 8),
              Text(
                'LIVE LOCATION DETECTED',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.primaryGreen,
                      fontSize: 10,
                      letterSpacing: 1.5,
                    ),
              ),
              const Spacer(),
              Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 18),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            address,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black87,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _fetchLiveLocation,
            child: Text(
              '↻  Refresh Location',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppTheme.primaryGreen,
                    fontSize: 11,
                    decoration: TextDecoration.underline,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Address Method Card ──
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
            color: isSelected
                ? AppTheme.primaryGreen
                : AppTheme.outline.withOpacity(0.25),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? AppTheme.primaryGreen.withOpacity(0.08)
              : Colors.white,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryGreen : AppTheme.outline,
              size: 26,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isSelected ? AppTheme.primaryGreen : AppTheme.outline,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.normal,
                    fontSize: 10,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Payment Option Widget ──
class _PaymentOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;

  const _PaymentOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected
              ? AppTheme.primaryGreen
              : AppTheme.outline.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          if (isSelected)
            const Icon(Icons.check_circle, color: AppTheme.primaryGreen),
        ],
      ),
    );
  }
}
