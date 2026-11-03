import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/landing/web_landing_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  PaintingBinding.instance.imageCache.maximumSize = 2000;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 200 * 1024 * 1024; // 200MB memory image cache
  runApp(const BiteHubApp());
}

class BiteHubApp extends StatelessWidget {
  const BiteHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BiteHub - Food & Grocery Delivery Platform',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: kIsWeb ? const WebLandingScreen() : const SplashScreen(),
    );
  }
}

