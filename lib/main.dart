import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';
import 'app_theme.dart';
import 'routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Google Sign In
  await _initializeGoogleSignIn();

  runApp(const BloomBasketApp());
}

// Google Sign In Initialization
Future<void> _initializeGoogleSignIn() async {
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],

    // Web client ID (safe to keep for web support)
    clientId:
        "712198995530-9dvnog7dj51m0vdk2olioaou6hu8kd4g.apps.googleusercontent.com",
  );

  try {
    await googleSignIn.isSignedIn();
  } catch (e) {
    debugPrint('Google Sign In initialization error: $e');
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
        debugShowCheckedModeBanner: false,

        // Themes
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.neonTheme,
        themeMode: ThemeMode.dark,

        // Routes
        routerConfig: router,
      ),
    );
  }
}
