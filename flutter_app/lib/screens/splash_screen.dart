import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'auth_screen.dart';

/// Modern Digital Brutalism 2.0 Splash Screen for BiteHub
/// Heavy geometric layout, stark typography, yellow ticker tape, hard drop shadows
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _scaleAnim = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToAuth();
      }
    });

    // Fallback timer
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted && !_hasNavigated) {
        _navigateToAuth();
      }
    });
  }

  void _navigateToAuth() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    HapticFeedback.mediumImpact();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AuthScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Stack(
          children: [
            // Top Brutalist Ticker
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(
                  color: AppTheme.yellow,
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.black,
                      width: AppTheme.borderWidth,
                    ),
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  child: Row(
                    children: List.generate(
                      8,
                      (i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          "⚡ HYPER-LOCAL COMMERCE // INSTANT DISPATCH ⚡",
                          style: GoogleFonts.ibmPlexMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.black,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Corner crosshairs (+)
            Positioned(
              top: 45,
              left: 16,
              child: Text(
                "+",
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.black,
                ),
              ),
            ),
            Positioned(
              top: 45,
              right: 16,
              child: Text(
                "+",
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.black,
                ),
              ),
            ),
            Positioned(
              bottom: 45,
              left: 16,
              child: Text(
                "+",
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.black,
                ),
              ),
            ),
            Positioned(
              bottom: 45,
              right: 16,
              child: Text(
                "+",
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.black,
                ),
              ),
            ),

            // Center Content Poster
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Main brutalist brand card
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius:
                                BorderRadius.circular(AppTheme.borderRadius),
                            border: Border.all(
                              color: AppTheme.black,
                              width: 3.0,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: AppTheme.black,
                                offset: Offset(6, 6),
                                blurRadius: 0,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Top status badge row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.black,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: Text(
                                      "SYS_INIT: OK",
                                      style: GoogleFonts.ibmPlexMono(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.yellow,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.yellow,
                                      border: Border.all(
                                        color: AppTheme.black,
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: Text(
                                      "BRUTALISM 2.0",
                                      style: GoogleFonts.ibmPlexMono(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: AppTheme.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Big Brand Icon / Geometric box
                              Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  color: AppTheme.yellow,
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.borderRadius),
                                  border: Border.all(
                                    color: AppTheme.black,
                                    width: 3.0,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: AppTheme.black,
                                      offset: Offset(4, 4),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.bolt_rounded,
                                    size: 56,
                                    color: AppTheme.black,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Oversized Brand Name
                              Text(
                                "BITEHUB",
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.black,
                                  letterSpacing: -1.5,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Divider bar
                              Container(
                                height: 3,
                                width: 140,
                                color: AppTheme.black,
                              ),
                              const SizedBox(height: 10),

                              // Editorial Tagline
                              Text(
                                "FOOD • GROCERY • 10-MIN DISPATCH",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.ibmPlexMono(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.black,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Animated loading bar
                        SlideTransition(
                          position: _slideAnim,
                          child: Container(
                            width: 200,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              border: Border.all(
                                color: AppTheme.black,
                                width: 2.0,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppTheme.black,
                                  offset: Offset(3, 3),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: LinearProgressIndicator(
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppTheme.black,
                              ),
                              backgroundColor: AppTheme.yellow,
                              minHeight: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Ticker Tape
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(
                  color: AppTheme.black,
                  border: Border(
                    top: BorderSide(
                      color: AppTheme.black,
                      width: AppTheme.borderWidth,
                    ),
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  child: Row(
                    children: List.generate(
                      8,
                      (i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          "★ RELATIONAL DBMS INTEGRATED // 1NF 2NF 3NF VERIFIED ★",
                          style: GoogleFonts.ibmPlexMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.yellow,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
