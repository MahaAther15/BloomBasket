import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // Botanical Palette
  static const Color primaryPurple = Color(0xFF7457A2);
  static const Color accentGold = Color(0xFFF7C948);
  static const Color darkBg = Color(0xFF1A1523);
  static const Color surfaceColor = Color(0xFF261F33);

  void _handleLogin() async {
    setState(() => _isLoading = true);
    
    // Simulate admin login check
    await Future.delayed(const Duration(seconds: 1));
    
    if (_idController.text == 'admin' && _passwordController.text == 'admin123') {
      Provider.of<AppState>(context, listen: false).setAdminAuthenticated(true);
      if (mounted) context.go('/admin');
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid Admin Credentials'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Botanical Logo
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: primaryPurple, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: primaryPurple.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.admin_panel_settings, color: primaryPurple, size: 64),
              ),
              const SizedBox(height: 32),
              Text(
                'ADMIN GATEWAY',
                style: GoogleFonts.orbitron(
                  color: primaryPurple,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'RESTRICTED ACCESS ONLY',
                style: GoogleFonts.orbitron(
                  color: accentGold,
                  fontSize: 10,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 48),
              
              // ID Field
              TextField(
                controller: _idController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'ADMIN ID',
                  labelStyle: const TextStyle(color: primaryPurple),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryPurple.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: primaryPurple, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person_outline, color: primaryPurple),
                ),
              ),
              const SizedBox(height: 20),
              
              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'PASSWORD',
                  labelStyle: const TextStyle(color: primaryPurple),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryPurple.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: primaryPurple, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline, color: primaryPurple),
                ),
              ),
              const SizedBox(height: 40),
              
              // Login Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 10,
                    shadowColor: primaryPurple.withOpacity(0.5),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'INITIALIZE ACCESS',
                        style: GoogleFonts.orbitron(fontWeight: FontWeight.bold),
                      ),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => context.go('/'),
                child: Text(
                  'RETURN TO CLIENT INTERFACE',
                  style: TextStyle(color: primaryPurple.withOpacity(0.6), fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
