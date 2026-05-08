import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'app_theme.dart';
import 'routes.dart';
import 'providers/app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialization for Web with your specific keys
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBvayYojzsI1ptfbR6wJ4DE--IWUtA1B5U",
      authDomain: "bloom-basket-shop.firebaseapp.com",
      projectId: "bloom-basket-shop",
      storageBucket: "bloom-basket-shop.firebasestorage.app",
      messagingSenderId: "620907192484",
      appId: "1:620907192484:web:2f18589143922708570631",
    ),
  );

  // Initialize Google Sign In for Web & Mobile
  await _initializeGoogleSignIn();

  runApp(const BloomBasketApp());
}

// Initialize Google Sign In with proper configuration
Future<void> _initializeGoogleSignIn() async {
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // For Web - specify client ID
    clientId: "352717362565-mjjnb1nhd53tvg7ed34dlijo8nub0sib.apps.googleusercontent.com",
  );

  // Optional: Check if user is already signed in
  try {
    await googleSignIn.isSignedIn();
  } catch (e) {
    print('Google Sign In initialization error: $e');
  }
}

class BloomBasketApp extends StatelessWidget {
  const BloomBasketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp.router(
        title: 'BloomBasket',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.neonTheme,
        themeMode: ThemeMode.dark, // Force Dark Neon Mode as requested
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
