import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'auth_screen.dart';

/// Premium, high-performance splash screen animation for BiteHub
/// Features 5 distinct motion phases:
/// Phase 1 (0–400ms): Ambient background radial glow reveal
/// Phase 2 (400–1000ms): Centered logo entrance (scale 75% -> 100% + soft shadow bloom)
/// Phase 3 (1000–1600ms): Quick-commerce delivery orbit & subtle energy pulse
/// Phase 4 (1600–2100ms): Brand typography & tagline reveal ("Food. Groceries. Delivered.")
/// Phase 5 (2100–2500ms): Seamless fade-scale transition to AuthScreen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Phase 1: Background & Radial Glow (0 - 450ms)
  late final Animation<double> _glowExpansion;
  late final Animation<double> _glowOpacity;

  // Phase 2: Logo Entrance (400 - 1000ms)
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoShadowElevation;

  // Phase 3: Brand Motion / Delivery Orbit (1000 - 1600ms)
  late final Animation<double> _orbitProgress;
  late final Animation<double> _orbitOpacity;
  late final Animation<double> _pulseScale;
  late final Animation<double> _pulseOpacity;

  // Phase 4: Brand Reveal Typography (1600 - 2100ms)
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _taglineOpacity;
  late final Animation<Offset> _taglineSlide;

  // State guard to prevent multiple transitions
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    // Phase 1 (0.00 - 0.20 -> 0 to 480ms)
    _glowExpansion = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.00, 0.25, curve: Curves.easeOutCubic),
      ),
    );
    _glowOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.00, 0.18, curve: Curves.easeIn),
      ),
    );

    // Phase 2 (0.16 - 0.42 -> 384 to 1008ms)
    _logoScale = Tween<double>(begin: 0.74, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.16, 0.42, curve: Curves.easeOutCubic),
      ),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.16, 0.32, curve: Curves.easeOut),
      ),
    );
    _logoShadowElevation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.45, curve: Curves.easeOut),
      ),
    );

    // Phase 3 (0.42 - 0.67 -> 1008 to 1608ms)
    _orbitProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.42, 0.67, curve: Curves.easeInOutCubic),
      ),
    );
    _orbitOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.42, 0.50, curve: Curves.easeIn),
      ),
    );
    _pulseScale = Tween<double>(begin: 0.95, end: 1.45).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.46, 0.68, curve: Curves.easeOut),
      ),
    );
    _pulseOpacity = Tween<double>(begin: 0.45, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.46, 0.68, curve: Curves.easeOut),
      ),
    );

    // Phase 4 (0.66 - 0.88 -> 1584 to 2112ms)
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.66, 0.80, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.28),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.66, 0.82, curve: Curves.easeOutCubic),
      ),
    );

    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.72, 0.88, curve: Curves.easeOut),
      ),
    );
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.72, 0.88, curve: Curves.easeOutCubic),
      ),
    );

    // Trigger transition on sequence completion
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToNext();
      }
    });

    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respect accessibility reduced-motion preference
    if (MediaQuery.of(context).disableAnimations && !_hasNavigated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToNext();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToNext() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    // Phase 5: Smooth, seamless transition into existing initial screen (AuthScreen)
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AuthScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Status bar & navigation bar theme styling
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor:
            isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF090D16) : AppTheme.backgroundColor,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Phase 1: Clean ambient light background with center radial glow
                _buildRadialAmbientGlow(size, isDark),

                // Center Stack: Logo, Quick-Commerce Brand Motion & Typography
                Center(
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Logo & Accent Orbit Canvas
                          _buildLogoContainer(isDark),

                          const SizedBox(height: 32),

                          // Phase 4: Brand Title ("BiteHub")
                          _buildBrandTitle(isDark),

                          const SizedBox(height: 10),

                          // Phase 4: Brand Tagline ("Food. Groceries. Delivered.")
                          _buildTagline(isDark),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Phase 1: Subtle radial ambient glow at the center using brand colors
  Widget _buildRadialAmbientGlow(Size size, bool isDark) {
    final glowVal = _glowExpansion.value;
    final opacityVal = _glowOpacity.value.clamp(0.0, 1.0);
    final glowRadius = math.min(size.width, size.height) * 0.45 * glowVal;

    return Center(
      child: Container(
        width: glowRadius * 2,
        height: glowRadius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: isDark
                ? [
                    const Color(0xFF6366F1).withValues(alpha: 0.16 * opacityVal),
                    const Color(0xFF10B981).withValues(alpha: 0.08 * opacityVal),
                    Colors.transparent,
                  ]
                : [
                    const Color(0xFF6366F1).withValues(alpha: 0.12 * opacityVal),
                    const Color(0xFF10B981).withValues(alpha: 0.06 * opacityVal),
                    Colors.transparent,
                  ],
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
      ),
    );
  }

  /// Phase 2 & 3: Logo Entrance and Quick-Commerce Delivery Orbit Accent
  Widget _buildLogoContainer(bool isDark) {
    const double logoBoxSize = 104.0;
    final shadowElevation = _logoShadowElevation.value;

    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Phase 3: Ambient ripple pulse
          if (_pulseOpacity.value > 0.01)
            Transform.scale(
              scale: _pulseScale.value,
              child: Container(
                width: logoBoxSize + 24,
                height: logoBoxSize + 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(34),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(
                      alpha: _pulseOpacity.value,
                    ),
                    width: 1.8,
                  ),
                ),
              ),
            ),

          // Phase 3: Subtle quick-commerce orbital sweep
          CustomPaint(
            size: const Size(180, 180),
            painter: _QuickCommerceOrbitPainter(
              progress: _orbitProgress.value,
              opacity: _orbitOpacity.value,
              primaryColor: const Color(0xFF6366F1),
              accentColor: const Color(0xFF10B981),
            ),
          ),

          // Phase 2: Centered BiteHub Logo
          Opacity(
            opacity: _logoOpacity.value.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: _logoScale.value,
              child: Container(
                width: logoBoxSize,
                height: logoBoxSize,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0).withValues(alpha: 0.9),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withValues(
                        alpha: 0.20 * shadowElevation,
                      ),
                      blurRadius: 28,
                      spreadRadius: 2,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(
                        alpha: 0.10 * shadowElevation,
                      ),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/logo.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error2, stackTrace2) => Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            "B",
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
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
    );
  }

  /// Phase 4: Brand Title ("BiteHub") with fade & subtle slide up
  Widget _buildBrandTitle(bool isDark) {
    return FadeTransition(
      opacity: _titleOpacity,
      child: SlideTransition(
        position: _titleSlide,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Bite",
              style: GoogleFonts.outfit(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                letterSpacing: -0.6,
              ),
            ),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                "Hub",
                style: GoogleFonts.outfit(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.6,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.only(top: 14),
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Phase 4: Brand Tagline ("Food. Groceries. Delivered.")
  Widget _buildTagline(bool isDark) {
    return FadeTransition(
      opacity: _taglineOpacity,
      child: SlideTransition(
        position: _taglineSlide,
        child: Text(
          "Food. Groceries. Delivered.",
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            letterSpacing: 1.6,
          ),
        ),
      ),
    );
  }
}

/// Custom painter for Phase 3:
/// Creates a refined quick-commerce orbit ring around the logo with an animated
/// gradient arc and a glowing courier dot.
class _QuickCommerceOrbitPainter extends CustomPainter {
  final double progress;
  final double opacity;
  final Color primaryColor;
  final Color accentColor;

  _QuickCommerceOrbitPainter({
    required this.progress,
    required this.opacity,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0.001) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.44;

    // 1. Subtle static guide circle
    final guidePaint = Paint()
      ..color = const Color(0xFFE2E8F0).withValues(alpha: 0.45 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawCircle(center, radius, guidePaint);

    if (progress <= 0.001) return;

    // 2. Animated gradient sweep arc
    final sweepAngle = math.pi * 1.85 * progress;
    final startAngle = -math.pi / 2 + (math.pi * 0.4 * progress);

    final sweepPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: [
          primaryColor.withValues(alpha: 0.15 * opacity),
          primaryColor.withValues(alpha: 0.85 * opacity),
          accentColor.withValues(alpha: 1.0 * opacity),
        ],
        stops: const [0.0, 0.65, 1.0],
      ).createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      sweepPaint,
    );

    // 3. Glowing courier/quick-commerce dot at the head of the arc
    final headAngle = startAngle + sweepAngle;
    final headX = center.dx + radius * math.cos(headAngle);
    final headY = center.dy + radius * math.sin(headAngle);
    final headPos = Offset(headX, headY);

    // Dot soft glow halo
    final glowDotPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.35 * opacity)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(headPos, 6.0, glowDotPaint);

    // Dot core
    final coreDotPaint = Paint()
      ..color = accentColor.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(headPos, 3.2, coreDotPaint);
  }

  @override
  bool shouldRepaint(covariant _QuickCommerceOrbitPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.opacity != opacity ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.accentColor != accentColor;
  }
}
